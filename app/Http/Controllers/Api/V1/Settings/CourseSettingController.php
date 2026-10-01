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
        ], [
            'school_name.required' => 'Nama sekolah wajib diisi.',
            'invoice_due_days.min' => 'Jatuh tempo minimal 1 hari.',
        ]);

        $setting = $this->setting();
        $setting->update($data);

        return $this->ok($setting->fresh(), 'Pengaturan bimbel diperbarui');
    }

    private function setting(): CourseSetting
    {
        return CourseSetting::query()->firstOrCreate(['id' => 1], ['school_name' => 'Gamma One']);
    }
}
