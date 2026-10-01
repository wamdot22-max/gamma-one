<?php

namespace App\Http\Requests\Academic;

use Illuminate\Foundation\Http\FormRequest;

class SubmissionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'assignment_id' => ['required', 'exists:assignments,id'],
            'student_id' => ['required', 'exists:students,id'],
            'file_url' => ['required', 'string', 'max:2048'],
            'note' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'assignment_id.required' => 'Tugas wajib dipilih.',
            'student_id.required' => 'Siswa wajib diisi.',
            'file_url.required' => 'Berkas wajib diunggah.',
        ];
    }
}
