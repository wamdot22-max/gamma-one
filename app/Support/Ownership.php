<?php

namespace App\Support;

use App\Models\Enrollment;
use App\Models\Guardian;
use App\Models\Session;
use App\Models\Student;
use App\Models\Tutor;
use App\Models\User;

/**
 * Aturan kepemilikan data: siswa/orang tua hanya melihat miliknya,
 * tutor melihat kelasnya plus kelas yang ia gantikan. Admin/staf/super-admin
 * melihat semua. Mengembalikan null bila boleh melihat semua, atau array id
 * yang boleh dilihat.
 */
class Ownership
{
    public static function isPrivileged(User $user): bool
    {
        return $user->hasAnyRole(['super-admin', 'admin', 'staf']);
    }

    public static function studentRecord(User $user): ?Student
    {
        return Student::where('user_id', $user->id)->first();
    }

    public static function guardianRecord(User $user): ?Guardian
    {
        return Guardian::where('user_id', $user->id)->first();
    }

    public static function tutorRecord(User $user): ?Tutor
    {
        return Tutor::where('user_id', $user->id)->first();
    }

    /**
     * Id siswa yang boleh dilihat user. Null = semua.
     */
    public static function studentIdsFor(User $user): ?array
    {
        if (self::isPrivileged($user)) {
            return null;
        }

        if ($user->hasRole('siswa')) {
            $student = self::studentRecord($user);

            return $student ? [$student->id] : [];
        }

        if ($user->hasRole('orang_tua')) {
            $guardian = self::guardianRecord($user);

            return $guardian ? $guardian->students()->pluck('students.id')->all() : [];
        }

        if ($user->hasRole('tutor')) {
            $classIds = self::classIdsFor($user);

            return $classIds === [] ? [] : Enrollment::whereIn('school_class_id', $classIds)
                ->where('status', 'aktif')
                ->distinct()->pluck('student_id')->all();
        }

        return [];
    }

    /**
     * Id kelas yang boleh dilihat user. Null = semua.
     */
    public static function classIdsFor(User $user): ?array
    {
        if (self::isPrivileged($user)) {
            return null;
        }

        if ($user->hasRole('tutor')) {
            $tutor = self::tutorRecord($user);
            if (! $tutor) {
                return [];
            }
            $own = $tutor->schoolClasses()->pluck('id')->all();
            $substituted = Session::where('substitute_tutor_id', $tutor->id)
                ->where('status', '!=', 'dibatalkan')
                ->distinct()->pluck('school_class_id')->all();

            return array_values(array_unique([...$own, ...$substituted]));
        }

        $studentIds = self::studentIdsFor($user);
        if ($studentIds === null) {
            return null;
        }
        if ($studentIds === []) {
            return [];
        }

        return Enrollment::whereIn('student_id', $studentIds)
            ->where('status', 'aktif')
            ->distinct()->pluck('school_class_id')->all();
    }

    /**
     * Id orang tua yang boleh dilihat user. Null = semua.
     */
    public static function guardianIdsFor(User $user): ?array
    {
        if (self::isPrivileged($user)) {
            return null;
        }

        if ($user->hasRole('orang_tua')) {
            $guardian = self::guardianRecord($user);

            return $guardian ? [$guardian->id] : [];
        }

        if ($user->hasRole('siswa')) {
            $student = self::studentRecord($user);

            return $student ? $student->guardians()->pluck('parents.id')->all() : [];
        }

        return [];
    }

    /**
     * Id tutor yang boleh dilihat user. Null = semua.
     */
    public static function tutorIdsFor(User $user): ?array
    {
        if (self::isPrivileged($user)) {
            return null;
        }

        if ($user->hasRole('tutor')) {
            $tutor = self::tutorRecord($user);

            return $tutor ? [$tutor->id] : [];
        }

        return [];
    }
}
