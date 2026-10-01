<?php

namespace Database\Seeders;

use App\Models\Enrollment;
use App\Models\Guardian;
use App\Models\Program;
use App\Models\Room;
use App\Models\SchoolClass;
use App\Models\Student;
use App\Models\Subject;
use App\Models\Tutor;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

/**
 * Data contoh fiktif untuk pengembangan. Bukan data siswa asli.
 */
class MasterSampleSeeder extends Seeder
{
    public function run(): void
    {
        $reguler = Program::firstOrCreate(['name' => 'Reguler SMP'], ['description' => 'Bimbel reguler jenjang SMP.', 'fee' => 350000, 'registration_fee' => 100000, 'is_active' => true]);
        $intensif = Program::firstOrCreate(['name' => 'Intensif UTBK'], ['description' => 'Persiapan UTBK SNBT.', 'fee' => 750000, 'registration_fee' => 150000, 'is_active' => true]);
        $privat = Program::firstOrCreate(['name' => 'Privat SD'], ['description' => 'Les privat jenjang SD.', 'fee' => 500000, 'registration_fee' => 50000, 'is_active' => true]);

        $subjects = collect(['Matematika', 'Fisika', 'Kimia', 'Biologi', 'Bahasa Indonesia', 'Bahasa Inggris'])
            ->map(fn ($name) => Subject::firstOrCreate(['name' => $name]));

        $rooms = collect([
            ['name' => 'Ruang Anggrek', 'capacity' => 20, 'location' => 'Lantai 1'],
            ['name' => 'Ruang Melati', 'capacity' => 15, 'location' => 'Lantai 1'],
            ['name' => 'Ruang Kenanga', 'capacity' => 10, 'location' => 'Lantai 2'],
            ['name' => 'Ruang Cempaka', 'capacity' => 8, 'location' => 'Lantai 2'],
        ])->map(fn ($room) => Room::firstOrCreate(['name' => $room['name']], $room));

        $tutorNames = ['Dewi Lestari', 'Budi Santoso', 'Siti Rahayu', 'Agus Pratama', 'Rina Marlina'];
        $tutors = collect();
        foreach ($tutorNames as $i => $name) {
            $email = 'tutor'.($i + 1).'@contoh.local';
            $user = User::firstOrCreate(['email' => $email], [
                'name' => $name, 'phone' => '6282100000'.(11 + $i), 'password' => Hash::make('password123'),
            ]);
            $user->syncRoles(['tutor']);

            $tutor = Tutor::firstOrCreate(['user_id' => $user->id], [
                'name' => $name, 'phone' => $user->phone, 'fee_per_session' => 100000, 'bio' => 'Tutor contoh fiktif.',
            ]);
            $tutor->subjects()->sync([$subjects[$i % 6]->id, $subjects[($i + 1) % 6]->id]);
            $tutors->push($tutor);
        }

        $studentNames = ['Andi Wijaya', 'Bella Putri', 'Candra Gunawan', 'Dinda Safitri', 'Eko Saputra', 'Fitri Handayani', 'Gilang Ramadhan', 'Hana Kusuma', 'Irfan Maulana', 'Jihan Aulia', 'Kevin Alexander', 'Larasati Dewi', 'M faisal', 'Nadia Zahra', 'Oscar Mahendra', 'Putri Ayu', 'Rizky Febian', 'Sarah Amelia', 'Taufik Hidayat', 'Umi Kalsum'];
        $students = collect();
        foreach ($studentNames as $i => $name) {
            $n = $i + 1;
            $email = 'siswa'.$n.'@contoh.local';
            $user = User::firstOrCreate(['email' => $email], [
                'name' => $name, 'phone' => '6282200000'.(10 + $n), 'password' => Hash::make('password123'),
            ]);
            $user->syncRoles(['siswa']);

            $students->push(Student::firstOrCreate(['nis' => 'G1'.str_pad((string) (1000 + $n), 6, '0', STR_PAD_LEFT)], [
                'user_id' => $user->id, 'name' => $name, 'gender' => $n % 2 ? 'L' : 'P',
                'phone' => $user->phone, 'school' => 'SMPN '.(($n % 5) + 1), 'status' => 'aktif',
            ]));
        }

        $parentNames = ['Hendra Wijaya', 'Ratna Sari', 'Joko Susilo', 'Mega Wati', 'Yusuf Hidayat', 'Sri Mulyani', 'Dedi Kurniawan', 'Nina Kurnia', 'Fajar Nugroho', 'Wulan Purnama'];
        foreach ($parentNames as $i => $name) {
            $m = $i + 1;
            $email = 'ortu'.$m.'@contoh.local';
            $user = User::firstOrCreate(['email' => $email], [
                'name' => $name, 'phone' => '6282300000'.(10 + $m), 'password' => Hash::make('password123'),
            ]);
            $user->syncRoles(['orang_tua']);

            $guardian = Guardian::firstOrCreate(['user_id' => $user->id], ['name' => $name, 'phone' => $user->phone]);
            $kids = [$students[$i * 2]->id => ['relationship' => $m % 2 ? 'ayah' : 'ibu'], $students[$i * 2 + 1]->id => ['relationship' => $m % 2 ? 'ayah' : 'ibu']];
            $guardian->students()->syncWithoutDetaching($kids);
        }

        $classDefs = [
            ['name' => 'Matematika 7A', 'program' => $reguler, 'subject' => $subjects[0], 'tutor' => $tutors[0], 'room' => $rooms[0], 'capacity' => 20, 'type' => 'reguler'],
            ['name' => 'Fisika 8A', 'program' => $reguler, 'subject' => $subjects[1], 'tutor' => $tutors[1], 'room' => $rooms[1], 'capacity' => 15, 'type' => 'reguler'],
            ['name' => 'UTBK Camp 1', 'program' => $intensif, 'subject' => $subjects[0], 'tutor' => $tutors[2], 'room' => $rooms[0], 'capacity' => 20, 'type' => 'reguler'],
            ['name' => 'English 7B', 'program' => $reguler, 'subject' => $subjects[5], 'tutor' => $tutors[3], 'room' => $rooms[2], 'capacity' => 10, 'type' => 'reguler'],
            ['name' => 'Privat Andi', 'program' => $privat, 'subject' => $subjects[0], 'tutor' => $tutors[4], 'room' => $rooms[3], 'capacity' => 1, 'type' => 'privat'],
            ['name' => 'Biologi 9A', 'program' => $reguler, 'subject' => $subjects[3], 'tutor' => $tutors[0], 'room' => $rooms[1], 'capacity' => 15, 'type' => 'reguler'],
        ];
        $classes = collect();
        foreach ($classDefs as $def) {
            $classes->push(SchoolClass::firstOrCreate(['name' => $def['name']], [
                'program_id' => $def['program']->id, 'subject_id' => $def['subject']->id,
                'tutor_id' => $def['tutor']->id, 'room_id' => $def['room']->id,
                'capacity' => $def['capacity'], 'type' => $def['type'],
            ]));
        }

        $plan = [0 => [0, 1, 2, 3, 4, 5, 6, 7], 1 => [8, 9, 10, 11], 2 => [12, 13, 14], 3 => [15, 16], 4 => [0], 5 => [17, 18, 19]];
        foreach ($plan as $classIndex => $studentIndexes) {
            foreach ($studentIndexes as $si) {
                Enrollment::firstOrCreate(
                    ['student_id' => $students[$si]->id, 'school_class_id' => $classes[$classIndex]->id],
                    ['enrollment_date' => now()->toDateString(), 'status' => 'aktif']
                );
            }
        }
    }
}
