<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invoices', function (Blueprint $table): void {
            $table->id();
            $table->string('invoice_no', 40)->unique();
            $table->foreignId('student_id')->constrained('students')->cascadeOnDelete();
            $table->foreignId('enrollment_id')->nullable()->constrained('enrollments')->nullOnDelete();
            $table->foreignId('school_class_id')->nullable()->constrained('school_classes')->nullOnDelete();
            $table->string('period', 7)->nullable();
            $table->date('issue_date');
            $table->date('due_date');
            $table->unsignedBigInteger('amount')->default(0);
            $table->unsignedBigInteger('discount')->default(0);
            $table->unsignedBigInteger('registration_fee')->default(0);
            $table->unsignedBigInteger('total')->default(0);
            $table->unsignedBigInteger('paid_amount')->default(0);
            $table->string('status', 20)->default('belum_bayar');
            $table->string('source', 20)->default('manual');
            $table->text('notes')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('deleted_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();
            $table->index(['student_id', 'status']);
            $table->index(['status', 'due_date']);
        });

        Schema::create('payments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('invoice_id')->constrained('invoices')->cascadeOnDelete();
            $table->unsignedBigInteger('amount');
            $table->string('method', 20)->default('tunai');
            $table->date('paid_at');
            $table->string('proof_url', 2048)->nullable();
            $table->string('reference', 100)->nullable()->unique();
            $table->text('notes')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('deleted_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();
            $table->index(['invoice_id']);
        });

        Schema::create('gateway_transactions', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('invoice_id')->constrained('invoices')->cascadeOnDelete();
            $table->string('provider', 20)->default('midtrans');
            $table->string('order_id', 100)->unique();
            $table->unsignedBigInteger('gross_amount');
            $table->string('payment_type', 30)->nullable();
            $table->string('transaction_status', 30)->default('pending');
            $table->string('snap_token', 100)->nullable();
            $table->json('payload')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();
            $table->index(['invoice_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('gateway_transactions');
        Schema::dropIfExists('payments');
        Schema::dropIfExists('invoices');
    }
};
