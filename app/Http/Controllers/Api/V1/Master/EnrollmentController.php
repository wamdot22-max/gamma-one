<?php

namespace App\Http\Controllers\Api\V1\Master;

use App\Exceptions\EnrollmentException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Master\EnrollmentRequest;
use App\Models\Enrollment;
use App\Models\SchoolClass;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class EnrollmentController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $studentIds = Ownership::studentIdsFor($request->user());
        $classIds = Ownership::classIdsFor($request->user());

        $query = Enrollment::with(['student:id,name,nis', 'schoolClass:id,name'])->orderByDesc('id');
        if ($studentIds !== null) {
            $query->whereIn('student_id', $studentIds);
        }
        if ($classIds !== null) {
            $query->whereIn('school_class_id', $classIds);
        }
        if ($request->get('school_class_id')) {
            $query->where('school_class_id', $request->get('school_class_id'));
        }
        if ($request->get('student_id')) {
            $query->where('student_id', $request->get('student_id'));
        }
        if ($request->get('status')) {
            $query->where('status', $request->get('status'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 10)));
    }

    public function show(Request $request, Enrollment $enrollment)
    {
        $this->assertVisible($request, $enrollment);

        return $this->ok($enrollment->load(['student', 'schoolClass']));
    }

    public function store(EnrollmentRequest $request)
    {
        $data = $request->validated();

        try {
            $enrollment = DB::transaction(function () use ($data) {
                // Kunci baris kelas agar dua pendaftaran bersamaan tidak
                // sama-sama lolos cek kapasitas (race condition).
                $class = SchoolClass::whereKey($data['school_class_id'])->lockForUpdate()->firstOrFail();

                $duplicate = Enrollment::withTrashed()
                    ->where('student_id', $data['student_id'])
                    ->where('school_class_id', $data['school_class_id'])->first();
                if ($duplicate && ! $duplicate->trashed()) {
                    throw new EnrollmentException('Siswa sudah terdaftar di kelas ini.');
                }

                if ($this->isFull($class, $data['status'] ?? 'aktif')) {
                    throw new EnrollmentException("Kelas {$class->name} sudah penuh ({$class->capacity} siswa).");
                }

                // Daftar ulang setelah dihapus: pulihkan baris lama
                // (unique DB tidak mengecualikan soft delete).
                if ($duplicate) {
                    $duplicate->restore();
                    $duplicate->update($data);

                    return $duplicate->fresh();
                }

                return Enrollment::create($data);
            });
        } catch (EnrollmentException $e) {
            return $this->fail($e->getMessage(), 422);
        }

        return $this->ok($enrollment, 'Pendaftaran dibuat', 201);
    }

    public function update(EnrollmentRequest $request, Enrollment $enrollment)
    {
        $data = $request->validated();

        try {
            $enrollment = DB::transaction(function () use ($data, $enrollment) {
                $class = SchoolClass::whereKey($data['school_class_id'])->lockForUpdate()->firstOrFail();

                $duplicate = Enrollment::where('student_id', $data['student_id'])
                    ->where('school_class_id', $data['school_class_id'])
                    ->where('id', '!=', $enrollment->id)->first();
                if ($duplicate) {
                    throw new EnrollmentException('Siswa sudah terdaftar di kelas ini.');
                }

                $moving = $enrollment->school_class_id != $data['school_class_id']
                    || ($enrollment->status !== 'aktif' && ($data['status'] ?? 'aktif') === 'aktif');
                if ($moving && $this->isFull($class, $data['status'] ?? 'aktif', $enrollment->id)) {
                    throw new EnrollmentException("Kelas {$class->name} sudah penuh ({$class->capacity} siswa).");
                }

                $enrollment->update($data);

                return $enrollment->fresh();
            });
        } catch (EnrollmentException $e) {
            return $this->fail($e->getMessage(), 422);
        }

        return $this->ok($enrollment, 'Pendaftaran diperbarui');
    }

    public function destroy(Enrollment $enrollment)
    {
        $enrollment->delete();

        return $this->ok(null, 'Pendaftaran dihapus');
    }

    private function isFull(SchoolClass $class, string $status, ?int $exceptId = null): bool
    {
        if ($status !== 'aktif' || $class->capacity <= 0) {
            return false;
        }

        $count = Enrollment::where('school_class_id', $class->id)
            ->where('status', 'aktif')
            ->when($exceptId, fn ($q) => $q->where('id', '!=', $exceptId))
            ->count();

        return $count >= $class->capacity;
    }

    private function assertVisible(Request $request, Enrollment $enrollment): void
    {
        $studentIds = Ownership::studentIdsFor($request->user());
        if ($studentIds !== null && ! in_array($enrollment->student_id, $studentIds)) {
            abort(404);
        }
        $classIds = Ownership::classIdsFor($request->user());
        if ($classIds !== null && ! in_array($enrollment->school_class_id, $classIds)) {
            abort(404);
        }
    }
}
