<?php

namespace App\Http\Requests\Finance;

use App\Models\Payment;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class PaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'invoice_id' => ['required', 'exists:invoices,id'],
            'amount' => ['required', 'integer', 'min:1000'],
            'method' => ['required', Rule::in(Payment::METHODS)],
            'paid_at' => ['sometimes', 'date'],
            'proof_url' => ['nullable', 'string', 'max:2048'],
            'notes' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'invoice_id.required' => 'Invoice wajib dipilih.',
            'amount.min' => 'Nominal minimal Rp1.000.',
            'method.in' => 'Metode tidak valid.',
        ];
    }
}
