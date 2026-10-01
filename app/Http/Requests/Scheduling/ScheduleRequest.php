<?php

namespace App\Http\Requests\Scheduling;

use Illuminate\Foundation\Http\FormRequest;

class ScheduleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'school_class_id' => ['required', 'exists:school_classes,id'],
            'day_of_week' => ['required', 'integer', 'between:1,7'],
            'start_time' => ['required', 'date_format:H:i'],
            'end_time' => ['required', 'date_format:H:i', 'after:start_time'],
            'room_id' => ['nullable', 'exists:rooms,id'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'school_class_id.required' => 'Kelas wajib dipilih.',
            'day_of_week.between' => 'Hari 1 (Senin) sampai 7 (Minggu).',
            'end_time.after' => 'Jam selesai harus setelah jam mulai.',
            'start_time.date_format' => 'Format jam mulai HH:MM.',
            'end_time.date_format' => 'Format jam selesai HH:MM.',
        ];
    }
}
