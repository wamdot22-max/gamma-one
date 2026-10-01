<?php

namespace App\Services;

use App\Models\CourseSetting;
use App\Models\Enrollment;
use App\Models\Invoice;
use App\Models\NotificationLog;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Pembuatan invoice bulanan dari enrollment aktif. Idempoten: dijalankan
 * ulang untuk periode yang sama tidak membuat invoice ganda.
 */
class InvoiceService
{
    private NotificationService $notifications;

    public function __construct(?NotificationService $notifications = null)
    {
        $this->notifications = $notifications ?? new NotificationService;
    }

    public function generateMonthly(?string $period = null): array
    {
        $period ??= Carbon::now('Asia/Jakarta')->format('Y-m');
        $today = Carbon::now('Asia/Jakarta')->toDateString();
        $dueDays = (int) (CourseSetting::query()->first()?->invoice_due_days ?? 7);

        $enrollments = Enrollment::with(['student:id,name', 'schoolClass.program'])
            ->where('status', 'aktif')->get();

        $created = 0;
        $skipped = 0;

        foreach ($enrollments as $enrollment) {
            $exists = Invoice::where('enrollment_id', $enrollment->id)->where('period', $period)->exists();
            if ($exists) {
                $skipped++;

                continue;
            }

            DB::transaction(function () use ($enrollment, $period, $today, $dueDays, &$created) {
                $program = $enrollment->schoolClass->program ?? null;
                $amount = (int) ($program->fee ?? 0);
                // Biaya pendaftaran hanya pada invoice pertama siswa.
                $firstBill = ! Invoice::where('student_id', $enrollment->student_id)->exists();
                $registrationFee = $firstBill ? (int) ($program->registration_fee ?? 0) : 0;

                $invoice = Invoice::create([
                    'invoice_no' => 'TMP',
                    'student_id' => $enrollment->student_id,
                    'enrollment_id' => $enrollment->id,
                    'school_class_id' => $enrollment->school_class_id,
                    'period' => $period,
                    'issue_date' => $today,
                    'due_date' => Carbon::parse($today)->addDays($dueDays)->toDateString(),
                    'amount' => $amount,
                    'discount' => 0,
                    'registration_fee' => $registrationFee,
                    'total' => $amount + $registrationFee,
                    'paid_amount' => 0,
                    'status' => 'belum_bayar',
                    'source' => 'otomatis',
                ]);
                $invoice->update(['invoice_no' => $this->numberFor($invoice->id, $period)]);
                $created++;

                $this->notifications->notifyParents(
                    $enrollment->student,
                    'tagihan_baru',
                    [
                        'invoice' => $invoice->invoice_no,
                        'nominal' => number_format($invoice->total, 0, ',', '.'),
                        'jatuh_tempo' => $invoice->due_date->toDateString(),
                    ],
                    $invoice
                );
            });
        }

        return ['period' => $period, 'created' => $created, 'skipped' => $skipped];
    }

    public function refreshStatus(Invoice $invoice): Invoice
    {
        $invoice->refresh();
        $paid = (int) $invoice->payments()->sum('amount');
        $invoice->paid_amount = $paid;

        if ($paid >= $invoice->total && $invoice->total > 0) {
            $invoice->status = 'lunas';
        } elseif ($paid > 0) {
            $invoice->status = Carbon::parse($invoice->due_date)->isPast() ? 'terlambat' : 'sebagian';
        } else {
            $invoice->status = Carbon::parse($invoice->due_date)->isPast() ? 'terlambat' : 'belum_bayar';
        }
        $invoice->save();

        return $invoice->fresh();
    }

    public function recalculateTotal(Invoice $invoice): Invoice
    {
        $invoice->total = max(0, $invoice->amount - $invoice->discount) + $invoice->registration_fee;
        $invoice->save();

        return $this->refreshStatus($invoice);
    }

    public function markOverdue(): int
    {
        $today = Carbon::now('Asia/Jakarta')->toDateString();

        $invoices = Invoice::with('student.guardians.user')
            ->whereIn('status', ['belum_bayar', 'sebagian'])
            ->whereDate('due_date', '<', $today)
            ->get();

        foreach ($invoices as $invoice) {
            $invoice->update(['status' => 'terlambat']);

            // Jangan spam harian: ingatkan maksimal sekali seminggu per invoice.
            $recent = NotificationLog::where('template_key', 'tagihan_jatuh_tempo')
                ->where('related_type', Invoice::class)
                ->where('related_id', $invoice->id)
                ->where('created_at', '>=', now()->subDays(7))
                ->exists();
            if ($recent) {
                continue;
            }

            $this->notifications->notifyParents(
                $invoice->student,
                'tagihan_jatuh_tempo',
                [
                    'invoice' => $invoice->invoice_no,
                    'nominal' => number_format($invoice->total - $invoice->paid_amount, 0, ',', '.'),
                ],
                $invoice
            );
        }

        return $invoices->count();
    }

    private function numberFor(int $id, ?string $period): string
    {
        $prefix = $period ? str_replace('-', '', $period) : Carbon::now('Asia/Jakarta')->format('Ym');

        return sprintf('INV/%s/%04d', $prefix, $id);
    }
}
