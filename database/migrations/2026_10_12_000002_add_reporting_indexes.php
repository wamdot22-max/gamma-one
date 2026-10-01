<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payments', function (Blueprint $table): void {
            $table->index('paid_at');
        });
        Schema::table('invoices', function (Blueprint $table): void {
            $table->index('period');
        });
        Schema::table('class_sessions', function (Blueprint $table): void {
            $table->index('session_date');
        });
    }

    public function down(): void
    {
        Schema::table('class_sessions', function (Blueprint $table): void {
            $table->dropIndex(['session_date']);
        });
        Schema::table('invoices', function (Blueprint $table): void {
            $table->dropIndex(['period']);
        });
        Schema::table('payments', function (Blueprint $table): void {
            $table->dropIndex(['paid_at']);
        });
    }
};
