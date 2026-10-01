<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('class_sessions', function (Blueprint $table): void {
            $table->foreignId('substitute_tutor_id')->nullable()->after('tutor_id')->constrained('tutors')->nullOnDelete();
        });

        Schema::create('session_substitute_requests', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('session_id')->constrained('class_sessions')->cascadeOnDelete();
            $table->foreignId('original_tutor_id')->nullable()->constrained('tutors')->nullOnDelete();
            $table->foreignId('proposed_tutor_id')->constrained('tutors')->cascadeOnDelete();
            $table->text('reason');
            $table->string('status', 20)->default('diusulkan');
            $table->foreignId('requested_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->text('review_note')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('deleted_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();
            $table->index(['session_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('session_substitute_requests');
        Schema::table('class_sessions', function (Blueprint $table): void {
            $table->dropConstrainedForeignId('substitute_tutor_id');
        });
    }
};
