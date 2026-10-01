<?php

namespace App\Http\Requests\Scheduling;

use App\Models\Attendance;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AttendanceRequest extends FormRequest
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
            'items.*.status' => ['required', Rule::in(Attendance::STATUSES)],
            'items.*.note' => ['nullable', 'string', 'max:500'],
            'material_notes' => ['nullable', 'string'],
            'tutor_status' => ['nullable', Rule::in(Attendance::STATUSES)],
        ];
    }

    public function messages(): array
    {
        return [
            'items.required' => 'Daftar kehadiran wajib diisi.',
            'items.*.status.in' => 'Status hanya hadir, izin, sakit, atau alfa.',
        ];
    }
}
