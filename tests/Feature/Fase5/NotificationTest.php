<?php

namespace Tests\Feature\Fase5;

use App\Models\Enrollment;
use App\Models\Guardian;
use App\Models\Invoice;
use App\Models\NotificationLog;
use App\Models\NotificationTemplate;
use App\Models\Program;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Models\Student;
use App\Models\Tutor;
use App\Models\User;
use App\Services\InvoiceService;
use App\Services\Notifications\FonnteProvider;
use App\Services\NotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use RuntimeException;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    private User $parentA;

    private User $parentB;

    private User $tutorUser;

    private User $stafUser;

    private Student $studentA;

    private Student $studentB;

    private SchoolClass $classA;

    private Session $sessionA;

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['sessions.view', 'sessions.update', 'students.view', 'classes.view', 'enrollments.view', 'parents.view', 'payments.create'] as $name) {
            Permission::firstOrCreate(['name' => $name, 'guard_name' => 'web']);
        }
        Role::firstOrCreate(['name' => 'tutor', 'guard_name' => 'web'])->syncPermissions(['sessions.view', 'sessions.update', 'students.view', 'classes.view', 'enrollments.view']);
        Role::firstOrCreate(['name' => 'orang_tua', 'guard_name' => 'web'])->syncPermissions(['students.view', 'parents.view', 'classes.view', 'enrollments.view', 'sessions.view']);
        Role::firstOrCreate(['name' => 'staf', 'guard_name' => 'web'])->syncPermissions(['payments.create']);

        $program = Program::factory()->create(['fee' => 300000]);
        $tutor = Tutor::factory()->create();
        $this->classA = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutor->id]);

        $this->studentA = Student::factory()->create(['name' => 'Anak A']);
        $this->studentB = Student::factory()->create(['name' => 'Anak B']);
        Enrollment::factory()->create(['student_id' => $this->studentA->id, 'school_class_id' => $this->classA->id, 'status' => 'aktif']);
        Enrollment::factory()->create(['student_id' => $this->studentB->id, 'school_class_id' => $this->classA->id, 'status' => 'aktif']);

        $guardianA = Guardian::factory()->create();
        $guardianA->students()->attach($this->studentA->id, ['relationship' => 'ayah']);
        $guardianB = Guardian::factory()->create();
        $guardianB->students()->attach($this->studentB->id, ['relationship' => 'ibu']);

        $this->parentA = User::factory()->create(['email' => 'pa@dev.local', 'password' => 'password123']);
        $this->parentA->syncRoles(['orang_tua']);
        $guardianA->update(['user_id' => $this->parentA->id]);
        $this->parentB = User::factory()->create(['email' => 'pb@dev.local', 'password' => 'password123']);
        $this->parentB->syncRoles(['orang_tua']);
        $guardianB->update(['user_id' => $this->parentB->id]);

        $this->tutorUser = User::factory()->create(['email' => 'ta@dev.local', 'password' => 'password123']);
        $this->tutorUser->syncRoles(['tutor']);
        $tutor->update(['user_id' => $this->tutorUser->id]);

        $this->stafUser = User::factory()->create(['email' => 'st@dev.local', 'password' => 'password123']);
        $this->stafUser->syncRoles(['staf']);

        $this->sessionA = Session::factory()->create(['school_class_id' => $this->classA->id, 'tutor_id' => $tutor->id]);
    }

    public function test_invoice_baru_memperingatkan_ortu_yang_benar(): void
    {
        (new InvoiceService)->generateMonthly('2026-11');

        $logA = NotificationLog::where('user_id', $this->parentA->id)->where('template_key', 'tagihan_baru')->first();
        $this->assertNotNull($logA);
        $this->assertSame('terkirim', $logA->status);
        $this->assertStringContainsString('Anak A', $logA->body);

        $logB = NotificationLog::where('user_id', $this->parentB->id)->where('template_key', 'tagihan_baru')->first();
        $this->assertNotNull($logB);
        $this->assertStringContainsString('Anak B', $logB->body);
        $this->assertStringNotContainsString('Anak A', $logB->body);
    }

    public function test_absensi_memperingatkan_ortu(): void
    {
        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->sessionA->id}/attendances", [
            'items' => [['student_id' => $this->studentA->id, 'status' => 'hadir']],
        ])->assertOk();

        $this->assertTrue(NotificationLog::where('user_id', $this->parentA->id)
            ->where('template_key', 'kehadiran_ortu')->exists());
        $this->assertFalse(NotificationLog::where('user_id', $this->parentB->id)
            ->where('template_key', 'kehadiran_ortu')->exists());
    }

    public function test_pembayaran_memicu_konfirmasi(): void
    {
        $invoice = Invoice::factory()->create(['student_id' => $this->studentA->id, 'total' => 300000]);

        $this->actingAs($this->stafUser, 'sanctum')->postJson('/api/v1/payments', [
            'invoice_id' => $invoice->id, 'amount' => 300000, 'method' => 'tunai',
        ])->assertCreated();

        $log = NotificationLog::where('user_id', $this->parentA->id)->where('template_key', 'pembayaran_lunas')->first();
        $this->assertNotNull($log);
        $this->assertSame('terkirim', $log->status);
    }

    public function test_wa_gagal_fallback_email_dan_tandai(): void
    {
        $this->app->bind(FonnteProvider::class, fn () => new class extends FonnteProvider
        {
            public function send(string $to, string $body, string $title = ''): void
            {
                throw new RuntimeException('WA down');
            }
        });

        $log = (new NotificationService)->send($this->parentA, 'selamat_datang');

        $this->assertNotNull($log);
        $this->assertSame('terkirim', $log->fresh()->status);
        $this->assertSame('email', $log->fresh()->channel);
        $this->assertTrue($log->fresh()->needs_follow_up);
    }

    public function test_template_bisa_diubah_admin(): void
    {
        NotificationTemplate::create(['key' => 'selamat_datang', 'name' => 'X', 'body' => 'Halo {nama}, kode {siswa}!', 'is_active' => true]);

        $body = (new NotificationService)->render('selamat_datang', ['nama' => 'Budi', 'siswa' => 'G1-1']);

        $this->assertSame('Halo Budi, kode G1-1!', $body);
    }

    public function test_pengingat_tunggakan_tidak_spam_harian(): void
    {
        Invoice::factory()->create([
            'student_id' => $this->studentA->id, 'total' => 200000,
            'due_date' => now()->subDays(3)->toDateString(), 'status' => 'belum_bayar',
        ]);

        $service = new InvoiceService;
        $service->markOverdue();
        $service->markOverdue();

        $this->assertSame(1, NotificationLog::where('template_key', 'tagihan_jatuh_tempo')->count());
    }
}
