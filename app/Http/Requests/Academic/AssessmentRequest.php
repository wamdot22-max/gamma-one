<?php

namespace App\Http\Requests\Academic;

use App\Models\Assessment;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AssessmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'school_class_id' => ['required', 'exists:school_classes,id'],
            'subject_id' => ['nullable', 'exists:subjects,id'],
            'title' => ['required', 'string', 'max:255'],
            'type' => ['sometimes', Rule::in(Assessment::TYPES)],
            'assessment_date' => ['nullable', 'date'],
            'max_score' => ['nullable', 'numeric', 'min:1'],
            'weight' => ['nullable', 'numeric', 'min:0'],
        ];
    }

    public function messages(): array
    {
        return [
            'school_class_id.required' => 'Kelas wajib dipilih.',
            'title.required' => 'Judul asesmen wajib diisi.',
            'type.in' => 'Tipe hanya ulangan, tryout, atau tugas.',
        ];
    }
}
