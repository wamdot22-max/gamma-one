<?php

namespace App\Http\Requests\Master;

use Illuminate\Foundation\Http\FormRequest;

class EnrollmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'student_id' => ['required', 'exists:students,id'],
            'school_class_id' => ['required', 'exists:school_classes,id'],
            'enrollment_date' => ['nullable', 'date'],
            'status' => ['sometimes', 'in:aktif,selesai,berhenti'],
        ];
    }

    public function messages(): array
    {
        return [
            'student_id.required' => 'Siswa wajib dipilih.',
            'school_class_id.required' => 'Kelas wajib dipilih.',
            'status.in' => 'Status tidak valid.',
        ];
    }
}
