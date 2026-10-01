<?php

namespace App\Services;

use App\Models\Enrollment;
use App\Models\Schedule;
use App\Models\SchoolClass;
use App\Models\Session;
use Illuminate\Support\Carbon;

/**
 * Deteksi bentrok tutor, ruangan, dan siswa. Jam yang tepat bersambung
 * (selesai 09:00, mulai 09:00) TIDAK dianggap bentrok.
 */
class ScheduleConflictService
{
    /**
     * Cek jadwal mingguan. $attrs: school_class_id, day_of_week,
     * start_time, end_time, room_id?.
     *
     * @return array<int, array{type: string, message: string}>
     */
    public function checkSchedule(array $attrs, ?int $ignoreScheduleId = null): array
    {
        $class = SchoolClass::findOrFail($attrs['school_class_id']);
        $start = $this->time($attrs['start_time']);
        $end = $this->time($attrs['end_time']);
        $roomId = $attrs['room_id'] ?? $class->room_id;

        $others = Schedule::with('schoolClass:id,name,tutor_id,room_id')
            ->where('is_active', true)
            ->where('day_of_week', $attrs['day_of_week'])
            ->when($ignoreScheduleId, fn ($q) => $q->where('id', '!=', $ignoreScheduleId))
            ->get();

        $conflicts = [];
        $myStudents = $this->activeStudentIds($class->id);

        foreach ($others as $other) {
            if (! $this->overlaps($start, $end, $this->time($other->start_time), $this->time($other->end_time))) {
                continue;
            }
            $label = $this->label($other->schoolClass->name ?? '?', $other->start_time, $other->end_time);

            if ($class->tutor_id && $other->schoolClass && $other->schoolClass->tutor_id === $class->tutor_id && $other->school_class_id !== $class->id) {
                $tutor = $class->tutor?->name ?? 'tutor kelas ini';
                $conflicts[] = ['type' => 'tutor', 'message' => "Tutor {$tutor} bentrok antara {$class->name} dan {$label}."];
            }

            $otherRoom = $other->room_id ?? $other->schoolClass->room_id ?? null;
            if ($roomId && $otherRoom && (int) $otherRoom === (int) $roomId) {
                $conflicts[] = ['type' => 'ruangan', 'message' => "Ruangan dipakai bersamaan oleh {$class->name} dan {$label}."];
            }

            if ($other->school_class_id !== $class->id && $myStudents->intersect($this->activeStudentIds($other->school_class_id))->isNotEmpty()) {
                $conflicts[] = ['type' => 'siswa', 'message' => "Ada siswa yang terdaftar di {$class->name} dan {$label} pada jam bersamaan."];
            }
        }

        return $conflicts;
    }

    /**
     * Cek reschedule sesi ke tanggal/jam baru. $attrs: session_date,
     * start_time, end_time, room_id?.
     *
     * @return array<int, array{type: string, message: string}>
     */
    public function checkSessionReschedule(Session $session, array $attrs): array
    {
        $class = $session->schoolClass;
        $date = Carbon::parse($attrs['session_date']);
        $dayOfWeek = (int) $date->dayOfWeekIso;
        $start = $this->time($attrs['start_time']);
        $end = $this->time($attrs['end_time']);
        $roomId = $attrs['room_id'] ?? $session->room_id ?? $class->room_id;
        $tutorId = $session->tutor_id ?? $class->tutor_id;

        $conflicts = [];
        $myLabel = "{$class->name} ({$this->short($start)}-{$this->short($end)})";

        $schedules = Schedule::with('schoolClass:id,name,tutor_id,room_id')
            ->where('is_active', true)
            ->where('day_of_week', $dayOfWeek)
            ->when($session->schedule_id, fn ($q) => $q->where('id', '!=', $session->schedule_id))
            ->get();

        $myStudents = $this->activeStudentIds($class->id);
        foreach ($schedules as $schedule) {
            if (! $this->overlaps($start, $end, $this->time($schedule->start_time), $this->time($schedule->end_time))) {
                continue;
            }
            $label = $this->label($schedule->schoolClass->name ?? '?', $schedule->start_time, $schedule->end_time);

            if ($tutorId && $schedule->schoolClass && $schedule->schoolClass->tutor_id == $tutorId) {
                $conflicts[] = ['type' => 'tutor', 'message' => "Tutor bentrok: {$myLabel} vs jadwal {$label}."];
            }
            $scheduleRoom = $schedule->room_id ?? $schedule->schoolClass->room_id ?? null;
            if ($roomId && $scheduleRoom && (int) $scheduleRoom === (int) $roomId) {
                $conflicts[] = ['type' => 'ruangan', 'message' => "Ruangan bentrok: {$myLabel} vs jadwal {$label}."];
            }
            if ($myStudents->intersect($this->activeStudentIds($schedule->school_class_id))->isNotEmpty()) {
                $conflicts[] = ['type' => 'siswa', 'message' => "Siswa bentrok: {$myLabel} vs jadwal {$label}."];
            }
        }

        $sessions = Session::with('schoolClass:id,name,tutor_id,room_id')
            ->whereDate('session_date', $date->toDateString())
            ->where('status', '!=', 'dibatalkan')
            ->where('id', '!=', $session->id)
            ->get();

        foreach ($sessions as $other) {
            if (! $this->overlaps($start, $end, $this->time($other->start_time), $this->time($other->end_time))) {
                continue;
            }
            $label = $this->label($other->schoolClass->name ?? '?', $other->start_time, $other->end_time);
            $otherTutor = $other->tutor_id ?? $other->schoolClass->tutor_id ?? null;
            if ($tutorId && $otherTutor && (int) $otherTutor === (int) $tutorId) {
                $conflicts[] = ['type' => 'tutor', 'message' => "Tutor bentrok: {$myLabel} vs sesi {$label}."];
            }
            $otherRoom = $other->room_id ?? $other->schoolClass->room_id ?? null;
            if ($roomId && $otherRoom && (int) $otherRoom === (int) $roomId) {
                $conflicts[] = ['type' => 'ruangan', 'message' => "Ruangan bentrok: {$myLabel} vs sesi {$label}."];
            }
        }

        return $conflicts;
    }

    public function overlaps(string $startA, string $endA, string $startB, string $endB): bool
    {
        return $startA < $endB && $startB < $endA;
    }

    private function activeStudentIds(int $classId)
    {
        return Enrollment::where('school_class_id', $classId)->where('status', 'aktif')->pluck('student_id');
    }

    private function time($value): string
    {
        return substr((string) $value, 0, 8);
    }

    private function short(string $time): string
    {
        return substr($time, 0, 5);
    }

    private function label(string $name, $start, $end): string
    {
        return "{$name} ({$this->short($this->time($start))}-{$this->short($this->time($end))})";
    }
}
