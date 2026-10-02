<?php

use App\Models\CourseSetting;
use App\Services\InvoiceService;
use App\Services\NotificationService;
use App\Services\SessionService;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Schedule::call(fn () => app(InvoiceService::class)->generateMonthly())->monthlyOn(1, '02:00')->name('invoice-bulanan');
Schedule::call(fn () => app(InvoiceService::class)->markOverdue())->dailyAt('01:00')->name('tandai-tunggakan');
Schedule::call(fn () => app(NotificationService::class)->sendScheduleReminders())->dailyAt('19:00')->name('pengingat-jadwal-h1');
Schedule::call(fn () => app(SessionService::class)->autoCompletePastSessions())->dailyAt('23:00')->name('selesaikan-sesi');
Schedule::call(function () {
    $setting = CourseSetting::query()->first();
    $service = app(SessionService::class);
    if (! $service->shouldAutoGenerateToday($setting)) {
        return;
    }
    if (Cache::get('auto-generate:done') === now('Asia/Jakarta')->toDateString()) {
        return;
    }
    $service->autoGenerateUpcoming(3);
    Cache::put('auto-generate:done', now('Asia/Jakarta')->toDateString(), 86400);
})->hourly()->name('generate-sesi-otomatis');
Schedule::command('app:backup-database')->dailyAt('02:30')->name('backup-database');
