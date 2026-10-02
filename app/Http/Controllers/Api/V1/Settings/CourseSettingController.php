<?php

namespace App\Http\Controllers\Api\V1\Settings;

use App\Http\Controllers\Controller;
use App\Models\CourseSetting;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class CourseSettingController extends Controller
{
    use ApiResponse;

    public function show()
    {
        return $this->ok($this->setting());
    }

    public function update(Request $request)
    {
        $data = $request->validate([
            'school_name' => ['required', 'string', 'max:255'],
            'address' => ['nullable', 'string'],
            'phone' => ['nullable', 'string', 'max:20'],
            'email' => ['nullable', 'email', 'max:255'],
            'academic_year' => ['nullable', 'string', 'max:20'],
            'semester' => ['nullable', 'string', 'max:20'],
            'invoice_due_days' => ['required', 'integer', 'min:1', 'max:60'],
            'description' => ['nullable', 'string'],
            'auto_generate_enabled' => ['sometimes', 'boolean'],
            'auto_generate_time' => ['nullable', 'date_format:H:i'],
            'auto_generate_frequency' => ['sometimes', 'in:harian,mingguan,bulanan'],
            'auto_generate_day' => ['nullable', 'integer', 'min:1', 'max:28'],
        ], [
            'school_name.required' => 'Nama sekolah wajib diisi.',
            'invoice_due_days.min' => 'Jatuh tempo minimal 1 hari.',
            'auto_generate_frequency.in' => 'Frekuensi hanya harian, mingguan, atau bulanan.',
            'auto_generate_time.date_format' => 'Format jam HH:MM, contoh 06:00.',
            'auto_generate_day.min' => 'Hari/tanggal minimal 1.',
            'auto_generate_day.max' => 'Hari/tanggal maksimal 28.',
        ]);

        $setting = $this->setting();
        $setting->update($data);

        return $this->ok($setting->fresh(), 'Pengaturan bimbel diperbarui');
    }

    private function setting(): CourseSetting
    {
        return CourseSetting::query()->firstOrCreate(['id' => 1], [
            'school_name' => 'Gamma One',
            'auto_generate_enabled' => (bool) config('course_settings.auto_generate_enabled', true),
            'auto_generate_time' => (string) config('course_settings.auto_generate_time', '06:00'),
            'auto_generate_frequency' => 'harian',
            'auto_generate_day' => 1,
        ]);
    }
}
