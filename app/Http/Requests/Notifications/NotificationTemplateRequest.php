<?php

namespace App\Http\Requests\Notifications;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class NotificationTemplateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $template = $this->route('notification_template');

        return [
            'key' => ['required', 'string', 'max:50', Rule::unique('notification_templates', 'key')->ignore($template?->id)->whereNull('deleted_at')],
            'name' => ['required', 'string', 'max:255'],
            'body' => ['required', 'string'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'key.required' => 'Kode template wajib diisi.',
            'key.unique' => 'Kode template sudah dipakai.',
            'name.required' => 'Nama template wajib diisi.',
            'body.required' => 'Isi pesan wajib diisi.',
        ];
    }
}
