<?php

namespace Tests\Feature\Fase4;

use App\Models\Enrollment;
use App\Models\Invoice;
use App\Models\Program;
use App\Models\SchoolClass;
use App\Models\Student;
use App\Services\InvoiceService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class InvoiceGenerationTest extends TestCase
{
    use RefreshDatabase;

    public function test_generate_idempoten(): void
    {
        $program = Program::factory()->create(['fee' => 350000, 'registration_fee' => 100000]);
        $class = SchoolClass::factory()->create(['program_id' => $program->id]);
        $student = Student::factory()->create();
        Enrollment::factory()->create(['student_id' => $student->id, 'school_class_id' => $class->id, 'status' => 'aktif']);

        $service = new InvoiceService;
        $first = $service->generateMonthly('2026-10');
        $second = $service->generateMonthly('2026-10');

        $this->assertSame(1, $first['created']);
        $this->assertSame(0, $second['created']);
        $this->assertSame(1, $second['skipped']);
        $this->assertSame(1, Invoice::where('period', '2026-10')->count());
    }

    public function test_biaya_pendaftaran_hanya_di_tagihan_pertama(): void
    {
        $program = Program::factory()->create(['fee' => 350000, 'registration_fee' => 100000]);
        $class = SchoolClass::factory()->create(['program_id' => $program->id]);
        $student = Student::factory()->create();
        Enrollment::factory()->create(['student_id' => $student->id, 'school_class_id' => $class->id, 'status' => 'aktif']);

        $service = new InvoiceService;
        $service->generateMonthly('2026-10');
        $service->generateMonthly('2026-11');

        $first = Invoice::where('period', '2026-10')->firstOrFail();
        $second = Invoice::where('period', '2026-11')->firstOrFail();

        $this->assertSame(450000, $first->total);
        $this->assertSame(100000, $first->registration_fee);
        $this->assertSame(350000, $second->total);
        $this->assertSame(0, $second->registration_fee);
    }

    public function test_enrollment_nonaktif_tidak_ditagih(): void
    {
        $program = Program::factory()->create();
        $class = SchoolClass::factory()->create(['program_id' => $program->id]);
        $student = Student::factory()->create();
        Enrollment::factory()->create(['student_id' => $student->id, 'school_class_id' => $class->id, 'status' => 'berhenti']);

        $result = (new InvoiceService)->generateMonthly('2026-10');

        $this->assertSame(0, $result['created']);
    }
}
