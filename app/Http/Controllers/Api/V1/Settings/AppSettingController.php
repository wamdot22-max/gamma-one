<?php

namespace App\Http\Controllers\Api\V1\Settings;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AppSettingController extends Controller
{
    use ApiResponse;

    public function show()
    {
        return $this->ok($this->setting());
    }

    public function update(Request $request)
    {
        $data = $request->validate(['app_name' => ['required', 'string', 'max:255'], 'company_name' => ['nullable', 'string', 'max:255'], 'sidebar_logo_url' => ['nullable', 'string', 'max:2048'], 'login_logo_url' => ['nullable', 'string', 'max:2048'], 'favicon_url' => ['nullable', 'string', 'max:2048']]);
        $setting = $this->setting();
        $setting->update($data);

        return $this->ok($setting->fresh(), 'Pengaturan aplikasi diperbarui');
    }

    private function setting(): AppSetting
    {
        return AppSetting::query()->firstOrCreate(['id' => 1], [
            'app_name' => 'Gamma One',
            'company_name' => 'Gamma One',
            'sidebar_logo_url' => '/images/logo-gamma-one.svg',
            'login_logo_url' => '/images/logo-gamma-one.svg',
            'favicon_url' => '/images/logo-gamma-one.svg',
        ]);
    }
}
