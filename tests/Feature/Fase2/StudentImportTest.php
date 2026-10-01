<?php

namespace Tests\Feature\Fase2;

use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx as XlsxWriter;
use Tests\TestCase;

class StudentImportTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    public function test_impor_csv_melaporkan_baris_gagal(): void
    {
        $admin = User::where('email', 'admin.contoh@dev.local')->firstOrFail();

        $csv = "nis,name,gender,birth_date,phone,address,school\n"
            ."IMP001,Anak Impor Satu,L,2012-01-01,081111111111,Jl. Mawar 1,SMPN 1\n"
            .",Tanpa NIS,P,2012-02-02,082222222222,Jl. Melati 2,SMPN 2\n"
            ."IMP003,Anak Impor Tiga,P,2012-03-03,083333333333,Jl. Kenanga 3,SMPN 3\n";

        $file = UploadedFile::fake()->createWithContent('siswa.csv', $csv);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/students/import', ['file' => $file]);
        $response->assertOk();
        $response->assertJsonPath('data.imported', 2);
        $response->assertJsonPath('data.total', 3);
        $this->assertCount(1, $response->json('data.failed'));
        $this->assertSame(3, $response->json('data.failed')[0]['row']);

        $this->assertDatabaseHas('students', ['nis' => 'IMP001']);
        $this->assertDatabaseHas('students', ['nis' => 'IMP003']);
    }

    public function test_impor_xlsx_berhasil(): void
    {
        $admin = User::where('email', 'admin.contoh@dev.local')->firstOrFail();

        $spreadsheet = new Spreadsheet;
        $spreadsheet->getActiveSheet()->fromArray([
            ['nis', 'name', 'gender', 'birth_date', 'phone', 'address', 'school'],
            ['XLS001', 'Anak Xlsx Satu', 'L', '2012-04-04', '084444444444', 'Jl. Xlsx 1', 'SMPN 4'],
            ['XLS002', 'Anak Xlsx Dua', 'P', '2012-05-05', '085555555555', 'Jl. Xlsx 2', 'SMPN 5'],
        ], null, 'A1');

        $path = tempnam(sys_get_temp_dir(), 'siswa').'.xlsx';
        (new XlsxWriter($spreadsheet))->save($path);
        $file = new UploadedFile($path, 'siswa.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', null, true);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/students/import', ['file' => $file]);
        $response->assertOk();
        $response->assertJsonPath('data.imported', 2);
        $response->assertJsonPath('data.total', 2);

        $this->assertDatabaseHas('students', ['nis' => 'XLS001']);
        $this->assertDatabaseHas('students', ['nis' => 'XLS002']);

        @unlink($path);
    }

    public function test_impor_ditolak_tanpa_izin(): void
    {
        $siswa = User::where('email', 'siswa@dev.local')->firstOrFail();
        $file = UploadedFile::fake()->createWithContent('siswa.csv', "nis,name\nX,Anak X\n");

        $this->actingAs($siswa, 'sanctum')
            ->postJson('/api/v1/students/import', ['file' => $file])
            ->assertForbidden();
    }
}
