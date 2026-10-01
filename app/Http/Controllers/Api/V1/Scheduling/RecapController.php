<?php

namespace App\Http\Controllers\Api\V1\Scheduling;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Enrollment;
use App\Models\SchoolClass;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Excel;

class RecapController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $data = $request->validate([
            'school_class_id' => ['required', 'exists:school_classes,id'],
            'from_date' => ['nullable', 'date'],
            'to_date' => ['nullable', 'date'],
        ]);

        $class = $this->visibleClass($request, (int) $data['school_class_id']);
        $studentIds = Ownership::studentIdsFor($request->user());

        $sessionQuery = $class->sessions()->where('status', '!=', 'dibatalkan');
        if (! empty($data['from_date'])) {
            $sessionQuery->whereDate('session_date', '>=', $data['from_date']);
        }
        if (! empty($data['to_date'])) {
            $sessionQuery->whereDate('session_date', '<=', $data['to_date']);
        }
        $sessionIds = $sessionQuery->pluck('id');
        $totalSessions = $sessionIds->count();

        $enrolled = Enrollment::with('student:id,name,nis')->where('school_class_id', $class->id)
            ->where('status', 'aktif')
            ->when($studentIds !== null, fn ($q) => $q->whereIn('student_id', $studentIds))
            ->get();

        $marks = Attendance::whereIn('session_id', $sessionIds)->get()->groupBy('student_id');

        $rows = $enrolled->map(function ($enrollment) use ($marks, $totalSessions) {
            $mine = $marks[$enrollment->student_id] ?? collect();
            $count = fn ($status) => $mine->where('status', $status)->count();
            $hadir = $count('hadir');

            return [
                'student' => $enrollment->student,
                'hadir' => $hadir,
                'izin' => $count('izin'),
                'sakit' => $count('sakit'),
                'alfa' => $count('alfa'),
                'total_sesi' => $totalSessions,
                'persen_hadir' => $totalSessions > 0 ? round($hadir / $totalSessions * 100, 1) : 0,
            ];
        });

        return $this->ok(['class' => $class->only('id', 'name'), 'total_sesi' => $totalSessions, 'rows' => $rows]);
    }

    public function export(Request $request, Excel $excel)
    {
        $response = $this->index($request);
        if ($response->getStatusCode() !== 200) {
            return $response;
        }
        $payload = $response->getData(true)['data'];

        $export = new class($payload['rows']) implements FromCollection, WithHeadings
        {
            public function __construct(private array $rows) {}

            public function collection()
            {
                return collect($this->rows)->map(fn ($row) => [
                    $row['student']['nis'] ?? '-', $row['student']['name'] ?? '-',
                    $row['hadir'], $row['izin'], $row['sakit'], $row['alfa'],
                    $row['total_sesi'], $row['persen_hadir'],
                ]);
            }

            public function headings(): array
            {
                return ['NIS', 'Nama', 'Hadir', 'Izin', 'Sakit', 'Alfa', 'Total Sesi', '% Hadir'];
            }
        };

        $classId = $payload['class']['id'];

        return $excel->download($export, "rekap-kehadiran-kelas-{$classId}.xlsx");
    }

    private function visibleClass(Request $request, int $classId): SchoolClass
    {
        $allowed = Ownership::classIdsFor($request->user());
        if ($allowed !== null && ! in_array($classId, $allowed)) {
            abort(404);
        }

        return SchoolClass::findOrFail($classId);
    }
}
