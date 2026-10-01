<?php

namespace App\Http\Requests\Master;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $student = $this->route('student');

        return [
            'user_id' => ['nullable', 'exists:users,id', Rule::unique('students', 'user_id')->ignore($student?->id)->whereNull('deleted_at')],
            'nis' => ['required', 'string', 'max:30', Rule::unique('students', 'nis')->ignore($student?->id)->whereNull('deleted_at')],
            'name' => ['required', 'string', 'max:255'],
            'gender' => ['nullable', 'in:L,P'],
            'birth_date' => ['nullable', 'date'],
            'phone' => ['nullable', 'string', 'max:20'],
            'address' => ['nullable', 'string'],
            'school' => ['nullable', 'string', 'max:255'],
            'status' => ['sometimes', 'in:aktif,cuti,lulus'],
        ];
    }

    public function messages(): array
    {
        return [
            'nis.required' => 'NIS wajib diisi.',
            'nis.unique' => 'NIS sudah dipakai.',
            'name.required' => 'Nama siswa wajib diisi.',
            'gender.in' => 'Jenis kelamin hanya L atau P.',
            'status.in' => 'Status tidak valid.',
        ];
    }
}
