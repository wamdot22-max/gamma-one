<?php

namespace App\Http\Controllers\Api\V1\Master;

use App\Http\Controllers\Controller;
use App\Http\Requests\Master\StudentRequest;
use App\Models\Student;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Validator;
use Maatwebsite\Excel\Concerns\ToCollection;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Excel;

class StudentsController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $q = trim((string) $request->get('q', ''));
        $allowed = Ownership::studentIdsFor($request->user());

        $query = Student::with(['user:id,name,email', 'guardians:id,name'])->orderBy('name');
        if ($allowed !== null) {
            $query->whereIn('id', $allowed);
        }
        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->where(fn ($x) => $x->whereRaw('LOWER(name) LIKE ?', [$qLike])
                ->orWhereRaw('LOWER(nis) LIKE ?', [$qLike])
                ->orWhere('phone', 'like', '%'.$q.'%'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 10)));
    }

    public function show(Request $request, Student $student)
    {
        $allowed = Ownership::studentIdsFor($request->user());
        if ($allowed !== null && ! in_array($student->id, $allowed)) {
            abort(404);
        }

        return $this->ok($student->load(['user:id,name,email', 'guardians', 'schoolClasses:id,name']));
    }

    public function store(StudentRequest $request)
    {
        return $this->ok(Student::create($request->validated()), 'Siswa dibuat', 201);
    }

    public function update(StudentRequest $request, Student $student)
    {
        $student->update($request->validated());

        return $this->ok($student->fresh(), 'Siswa diperbarui');
    }

    public function destroy(Student $student)
    {
        $student->delete();

        return $this->ok(null, 'Siswa dihapus');
    }

    /**
     * Impor siswa dari Excel/CSV. Kolom: nis, name, gender, birth_date,
     * phone, address, school. Mengembalikan laporan baris yang gagal.
     */
    public function import(Request $request, Excel $excel)
    {
        $request->validate([
            'file' => ['required', 'file', 'mimes:xlsx,csv', 'max:5120'],
        ], [
            'file.required' => 'Berkas wajib diunggah.',
            'file.mimes' => 'Berkas harus Excel (.xlsx) atau CSV.',
        ]);

        $reader = new class implements ToCollection, WithHeadingRow
        {
            public function collection(Collection $rows): void {}
        };

        $sheets = $excel->toCollection($reader, $request->file('file'));
        $rows = $sheets->first() ?? collect();

        $imported = 0;
        $failed = [];

        foreach ($rows as $index => $row) {
            $data = [
                'nis' => trim((string) ($row['nis'] ?? '')),
                'name' => trim((string) ($row['name'] ?? '')),
                'gender' => ($g = strtoupper(trim((string) ($row['gender'] ?? '')))) !== '' ? $g : null,
                'birth_date' => ($b = trim((string) ($row['birth_date'] ?? ''))) !== '' ? $b : null,
                'phone' => ($p = trim((string) ($row['phone'] ?? ''))) !== '' ? $p : null,
                'address' => ($a = trim((string) ($row['address'] ?? ''))) !== '' ? $a : null,
                'school' => ($s = trim((string) ($row['school'] ?? ''))) !== '' ? $s : null,
            ];

            $validator = Validator::make($data, [
                'nis' => ['required', 'string', 'max:30', 'unique:students,nis'],
                'name' => ['required', 'string', 'max:255'],
                'gender' => ['nullable', 'in:L,P'],
                'birth_date' => ['nullable', 'date'],
                'phone' => ['nullable', 'string', 'max:20'],
            ], [
                'nis.required' => 'NIS wajib diisi.',
                'nis.unique' => 'NIS sudah dipakai.',
                'name.required' => 'Nama wajib diisi.',
            ]);

            if ($validator->fails()) {
                $failed[] = ['row' => $index + 2, 'nis' => $data['nis'] ?: null, 'errors' => $validator->errors()->all()];

                continue;
            }

            Student::create($validator->validated() + ['address' => $data['address'], 'school' => $data['school']]);
            $imported++;
        }

        return $this->ok(['total' => $rows->count(), 'imported' => $imported, 'failed' => $failed], "Impor selesai: {$imported} berhasil, ".count($failed).' gagal.');
    }
}
