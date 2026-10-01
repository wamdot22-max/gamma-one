<?php

namespace Database\Seeders;

use App\Models\Assessment;
use App\Models\Assignment;
use App\Models\Grade;
use App\Models\Material;
use App\Models\SchoolClass;
use App\Models\Submission;
use Illuminate\Database\Seeder;

/**
 * Contoh akademik fiktif: asesmen + nilai kelas pertama, materi, tugas.
 */
class AcademicSampleSeeder extends Seeder
{
    public function run(): void
    {
        $class = SchoolClass::where('name', 'Matematika 7A')->first();
        if (! $class) {
            return;
        }

        $month = now('Asia/Jakarta')->format('Y-m');
        $assessments = collect([
            ['title' => 'Ulangan Harian 1', 'type' => 'ulangan', 'date' => $month.'-05'],
            ['title' => 'Tryout 1', 'type' => 'tryout', 'date' => $month.'-12'],
        ])->map(fn ($def) => Assessment::firstOrCreate(
            ['school_class_id' => $class->id, 'title' => $def['title']],
            ['subject_id' => $class->subject_id, 'type' => $def['type'], 'assessment_date' => $def['date'], 'max_score' => 100, 'weight' => 1]
        ));

        $scores = [85, 90, 78, 88, 92, 75, 80, 95];
        $students = $class->students()->wherePivot('status', 'aktif')->get();
        foreach ($assessments as $ai => $assessment) {
            foreach ($students as $si => $student) {
                Grade::updateOrCreate(
                    ['assessment_id' => $assessment->id, 'student_id' => $student->id],
                    ['score' => $scores[($si + $ai * 3) % count($scores)], 'note' => $si === 0 ? 'Pertahankan!' : null]
                );
            }
        }

        Material::firstOrCreate(
            ['school_class_id' => $class->id, 'title' => 'Ringkasan Aljabar Dasar'],
            ['description' => 'Materi contoh fiktif.', 'file_url' => '/images/logo-gamma-one.svg']
        );

        $assignment = Assignment::firstOrCreate(
            ['school_class_id' => $class->id, 'title' => 'Latihan Soal 1'],
            ['description' => 'Kerjakan dan unggah hasilnya.', 'deadline' => now('Asia/Jakarta')->addDays(7)]
        );

        $first = $students->first();
        if ($first) {
            Submission::firstOrCreate(
                ['assignment_id' => $assignment->id, 'student_id' => $first->id],
                ['file_url' => '/images/logo-gamma-one.svg', 'note' => 'Contoh pengumpulan.', 'submitted_at' => now()]
            );
        }
    }
}
