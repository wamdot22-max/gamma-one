<?php

namespace App\Http\Controllers\Api\V1\Finance;

use App\Http\Controllers\Controller;
use App\Http\Requests\Finance\PaymentRequest;
use App\Models\Invoice;
use App\Models\Payment;
use App\Services\InvoiceService;
use App\Services\NotificationService;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $studentIds = Ownership::studentIdsFor($request->user());

        $query = Payment::with(['invoice:id,invoice_no,student_id'])->orderByDesc('id');
        if ($studentIds !== null) {
            $query->whereHas('invoice', fn ($q) => $q->whereIn('student_id', $studentIds));
        }
        if ($request->get('invoice_id')) {
            $query->where('invoice_id', $request->get('invoice_id'));
        }
        if ($request->get('method')) {
            $query->where('method', $request->get('method'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 15)));
    }

    public function show(Request $request, Payment $payment)
    {
        $studentIds = Ownership::studentIdsFor($request->user());
        if ($studentIds !== null && ! in_array($payment->invoice->student_id, $studentIds)) {
            abort(404);
        }

        return $this->ok($payment->load('invoice'));
    }

    /**
     * Pembayaran manual staf (tunai/transfer + bukti). Mendukung cicilan:
     * status invoice dihitung ulang otomatis.
     */
    public function store(PaymentRequest $request, InvoiceService $service, NotificationService $notifications)
    {
        $data = $request->validated();
        $invoice = Invoice::findOrFail($data['invoice_id']);

        if ($invoice->status === 'lunas') {
            return $this->fail('Invoice sudah lunas.', 422);
        }
        if ($data['amount'] > $invoice->total - $invoice->paid_amount) {
            return $this->fail('Nominal melebihi sisa tagihan Rp'.number_format($invoice->total - $invoice->paid_amount, 0, ',', '.'), 422);
        }

        $payment = Payment::create([...$data, 'paid_at' => $data['paid_at'] ?? now()->toDateString()]);
        $invoice = $service->refreshStatus($invoice);

        $notifications->notifyParents(
            $invoice->student,
            'pembayaran_lunas',
            [
                'nominal' => number_format($payment->amount, 0, ',', '.'),
                'invoice' => $invoice->invoice_no,
                'sisa' => number_format($invoice->total - $invoice->paid_amount, 0, ',', '.'),
            ],
            $invoice
        );

        return $this->ok($payment->load('invoice'), 'Pembayaran dicatat', 201);
    }

    public function destroy(Payment $payment, InvoiceService $service)
    {
        $invoice = $payment->invoice;
        $payment->delete();
        $service->refreshStatus($invoice);

        return $this->ok(null, 'Pembayaran dihapus');
    }
}
