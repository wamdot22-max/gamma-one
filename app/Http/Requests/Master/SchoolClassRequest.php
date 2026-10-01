<?php

namespace App\Http\Requests\Master;

use Illuminate\Foundation\Http\FormRequest;

class SchoolClassRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'program_id' => ['required', 'exists:programs,id'],
            'subject_id' => ['nullable', 'exists:subjects,id'],
            'tutor_id' => ['nullable', 'exists:tutors,id'],
            'room_id' => ['nullable', 'exists:rooms,id'],
            'capacity' => ['nullable', 'integer', 'min:0'],
            'type' => ['sometimes', 'in:reguler,privat'],
            'description' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Nama kelas wajib diisi.',
            'program_id.required' => 'Program wajib dipilih.',
            'program_id.exists' => 'Program tidak ditemukan.',
            'capacity.min' => 'Kapasitas tidak boleh negatif.',
            'type.in' => 'Tipe hanya reguler atau privat.',
        ];
    }
}
