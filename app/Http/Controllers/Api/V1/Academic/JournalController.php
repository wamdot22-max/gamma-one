<?php

namespace App\Http\Controllers\Api\V1\Academic;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class JournalController extends Controller
{
    use ApiResponse;

    /**
     * Jurnal belajar siswa: kehadiran + pemahaman + catatan tutor per sesi,
     * untuk direview orang tua.
     */
    public function index(Request $request)
    {
        $data = $request->validate(['student_id' => ['required', 'exists:students,id']]);

        $studentIds = Ownership::studentIdsFor($request->user());
        if ($studentIds !== null && ! in_array((int) $data['student_id'], $studentIds)) {
            abort(404);
        }

        $classIds = Ownership::classIdsFor($request->user());

        $query = Attendance::with(['session:id,school_class_id,session_date,start_time', 'session.schoolClass:id,name,subject_id', 'session.schoolClass.subject:id,name'])
            ->where('student_id', $data['student_id'])
            ->orderByDesc('id');
        if ($classIds !== null) {
            $query->whereHas('session', fn ($q) => $q->whereIn('school_class_id', $classIds));
        }

        $entries = $query->paginate((int) $request->get('per_page', 20));
        $entries->getCollection()->transform(fn ($attendance) => [
            'id' => $attendance->id,
            'tanggal' => $attendance->session->session_date,
            'kelas' => $attendance->session->schoolClass->name ?? '-',
            'mapel' => $attendance->session->schoolClass->subject->name ?? '-',
            'status' => $attendance->status,
            'pemahaman' => $attendance->understanding,
            'catatan' => $attendance->note,
            'materi' => $attendance->session->material_notes,
        ]);

        return $this->ok($entries);
    }
}
