<?php

namespace App\Http\Requests\Academic;

use Illuminate\Foundation\Http\FormRequest;

class GradeBulkRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1'],
            'items.*.student_id' => ['required', 'exists:students,id'],
            'items.*.score' => ['required', 'numeric', 'min:0', 'max:1000'],
            'items.*.note' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'items.required' => 'Daftar nilai wajib diisi.',
            'items.*.score.numeric' => 'Nilai harus berupa angka.',
        ];
    }
}
