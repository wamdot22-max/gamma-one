<?php

namespace App\Http\Requests\Finance;

use Illuminate\Foundation\Http\FormRequest;

class InvoiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'student_id' => ['required', 'exists:students,id'],
            'school_class_id' => ['nullable', 'exists:school_classes,id'],
            'enrollment_id' => ['nullable', 'exists:enrollments,id'],
            'issue_date' => ['sometimes', 'date'],
            'due_date' => ['required', 'date'],
            'amount' => ['required', 'integer', 'min:0'],
            'discount' => ['nullable', 'integer', 'min:0'],
            'registration_fee' => ['nullable', 'integer', 'min:0'],
            'notes' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'student_id.required' => 'Siswa wajib dipilih.',
            'amount.min' => 'Nominal tidak boleh negatif.',
            'due_date.required' => 'Jatuh tempo wajib diisi.',
        ];
    }
}
