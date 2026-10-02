<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('course_settings', function (Blueprint $table): void {
            $table->boolean('auto_generate_enabled')->default(true);
            $table->string('auto_generate_time', 5)->default('06:00');
        });
    }

    public function down(): void
    {
        Schema::table('course_settings', function (Blueprint $table): void {
            $table->dropColumn(['auto_generate_enabled', 'auto_generate_time']);
        });
    }
};
