<?php

namespace App\Http\Controllers\Api\V1\Finance;

use App\Http\Controllers\Controller;
use App\Http\Requests\Finance\InvoiceRequest;
use App\Models\Invoice;
use App\Services\InvoiceService;
use App\Services\NotificationService;
use App\Services\Payments\PaymentGateway;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class InvoiceController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $studentIds = Ownership::studentIdsFor($request->user());

        $query = Invoice::with(['student:id,name,nis', 'schoolClass:id,name'])->orderByDesc('id');
        if ($studentIds !== null) {
            $query->whereIn('student_id', $studentIds);
        }
        foreach (['status', 'student_id', 'school_class_id', 'period', 'source'] as $filter) {
            if ($request->get($filter)) {
                $query->where($filter, $request->get($filter));
            }
        }
        if ($request->boolean('overdue')) {
            $query->whereIn('status', ['belum_bayar', 'sebagian'])->whereDate('due_date', '<', now()->toDateString());
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 15)));
    }

    public function show(Request $request, Invoice $invoice)
    {
        $this->assertVisible($request, $invoice);

        return $this->ok($invoice->load(['student', 'schoolClass', 'payments', 'gatewayTransactions']));
    }

    public function store(InvoiceRequest $request, InvoiceService $service, NotificationService $notifications)
    {
        $data = $request->validated();
        $invoice = Invoice::create([
            ...$data,
            'invoice_no' => 'TMP',
            'issue_date' => $data['issue_date'] ?? now()->toDateString(),
            'discount' => $data['discount'] ?? 0,
            'registration_fee' => $data['registration_fee'] ?? 0,
            'paid_amount' => 0,
            'status' => 'belum_bayar',
            'source' => 'manual',
        ]);
        $invoice->update(['invoice_no' => sprintf('INV/MNL/%04d', $invoice->id)]);
        $invoice = $service->recalculateTotal($invoice);

        $notifications->notifyParents(
            $invoice->student,
            'tagihan_baru',
            [
                'invoice' => $invoice->invoice_no,
                'nominal' => number_format($invoice->total, 0, ',', '.'),
                'jatuh_tempo' => $invoice->due_date->toDateString(),
            ],
            $invoice
        );

        return $this->ok($invoice, 'Invoice dibuat', 201);
    }

    public function update(InvoiceRequest $request, Invoice $invoice, InvoiceService $service)
    {
        if ($invoice->source === 'otomatis') {
            $data = $request->safe()->only(['discount', 'due_date', 'notes']);
        } else {
            $data = $request->validated();
            unset($data['issue_date']);
        }
        $invoice->update($data);

        return $this->ok($service->recalculateTotal($invoice->fresh()), 'Invoice diperbarui');
    }

    public function destroy(Invoice $invoice)
    {
        $invoice->delete();

        return $this->ok(null, 'Invoice dihapus');
    }

    /**
     * Tautan bayar Midtrans (Snap) untuk sisa tagihan.
     */
    public function payLink(Request $request, Invoice $invoice, PaymentGateway $gateway)
    {
        $this->assertVisible($request, $invoice);
        if ($invoice->status === 'lunas') {
            return $this->fail('Invoice sudah lunas.', 422);
        }

        try {
            $charge = $gateway->createCharge($invoice->fresh());
        } catch (\Throwable $e) {
            report($e);

            return $this->fail('Gagal membuat tautan bayar. Coba lagi nanti.', 502);
        }

        return $this->ok($charge + [
            'client_key' => (string) config('services.midtrans.client_key'),
            'snap_url' => config('services.midtrans.is_production')
                ? 'https://app.midtrans.com/snap/snap.js'
                : 'https://app.sandbox.midtrans.com/snap/snap.js',
        ]);
    }

    public function receipt(Request $request, Invoice $invoice)
    {
        $this->assertVisible($request, $invoice);
        $invoice->load(['student', 'schoolClass', 'payments']);

        $pdf = Pdf::loadView('pdf.receipt', ['invoice' => $invoice]);

        return $pdf->download('kuitansi-'.str_replace(['/', '\\'], '-', $invoice->invoice_no).'.pdf');
    }

    private function assertVisible(Request $request, Invoice $invoice): void
    {
        $studentIds = Ownership::studentIdsFor($request->user());
        if ($studentIds !== null && ! in_array($invoice->student_id, $studentIds)) {
            abort(404);
        }
    }
}
