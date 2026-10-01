<?php

namespace App\Http\Requests\Master;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class TutorRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $tutor = $this->route('tutor');

        return [
            'user_id' => ['nullable', 'exists:users,id', Rule::unique('tutors', 'user_id')->ignore($tutor?->id)->whereNull('deleted_at')],
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'fee_per_session' => ['nullable', 'integer', 'min:0'],
            'availability' => ['nullable', 'array'],
            'bio' => ['nullable', 'string'],
            'subject_ids' => ['sometimes', 'array'],
            'subject_ids.*' => ['exists:subjects,id'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Nama tutor wajib diisi.',
            'fee_per_session.integer' => 'Honor harus berupa angka rupiah.',
            'subject_ids.*.exists' => 'Mapel tidak ditemukan.',
        ];
    }
}
