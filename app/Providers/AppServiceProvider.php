<?php

namespace App\Providers;

use App\Services\Payments\MidtransGateway;
use App\Services\Payments\PaymentGateway;
use Dedoc\Scramble\Scramble;
use Dedoc\Scramble\Support\Generator\OpenApi;
use Dedoc\Scramble\Support\Generator\SecurityScheme;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(PaymentGateway::class, MidtransGateway::class);
    }

    public function boot(): void
    {
        Scramble::configure()->withDocumentTransformers(fn (OpenApi $openApi) => $openApi->secure(SecurityScheme::http('bearer', 'JWT')));

        RateLimiter::for('api', fn (Request $request) => Limit::perMinute(60)->by($request->user()?->id ?: $request->ip()));
    }
}
