<?php

namespace App\Http\Requests\Master;

use Illuminate\Foundation\Http\FormRequest;

class ProgramRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'fee' => ['nullable', 'integer', 'min:0'],
            'registration_fee' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Nama program wajib diisi.',
            'fee.integer' => 'Biaya harus berupa angka rupiah.',
            'fee.min' => 'Biaya tidak boleh negatif.',
            'registration_fee.integer' => 'Biaya pendaftaran harus berupa angka rupiah.',
        ];
    }
}
