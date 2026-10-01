<?php

namespace App\Http\Requests\Scheduling;

use Illuminate\Foundation\Http\FormRequest;

class SessionGenerateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'school_class_id' => ['required', 'exists:school_classes,id'],
            'from_date' => ['required', 'date'],
            'to_date' => ['required', 'date', 'after_or_equal:from_date'],
        ];
    }

    public function messages(): array
    {
        return [
            'school_class_id.required' => 'Kelas wajib dipilih.',
            'to_date.after_or_equal' => 'Tanggal akhir minimal sama dengan tanggal awal.',
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator): void {
            $from = $this->input('from_date');
            $to = $this->input('to_date');
            if ($from && $to && now()->parse($from)->diffInDays(now()->parse($to)) > 62) {
                $validator->errors()->add('to_date', 'Rentang maksimal 62 hari.');
            }
        });
    }
}
