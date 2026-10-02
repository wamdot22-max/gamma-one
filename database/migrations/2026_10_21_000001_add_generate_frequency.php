<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('course_settings', function (Blueprint $table): void {
            $table->string('auto_generate_frequency', 20)->default('harian');
            $table->unsignedInteger('auto_generate_day')->default(1);
        });
    }

    public function down(): void
    {
        Schema::table('course_settings', function (Blueprint $table): void {
            $table->dropColumn(['auto_generate_frequency', 'auto_generate_day']);
        });
    }
};
