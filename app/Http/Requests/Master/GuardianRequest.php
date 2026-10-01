<?php

namespace App\Http\Requests\Master;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class GuardianRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $guardian = $this->route('parent');

        return [
            'user_id' => ['nullable', 'exists:users,id', Rule::unique('parents', 'user_id')->ignore($guardian?->id)->whereNull('deleted_at')],
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'address' => ['nullable', 'string'],
            'students' => ['sometimes', 'array'],
            'students.*.id' => ['required_with:students', 'exists:students,id'],
            'students.*.relationship' => ['sometimes', 'in:ayah,ibu,wali,lainnya'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Nama orang tua wajib diisi.',
            'students.*.id.exists' => 'Siswa tidak ditemukan.',
            'students.*.relationship.in' => 'Hubungan hanya ayah, ibu, wali, atau lainnya.',
        ];
    }
}
