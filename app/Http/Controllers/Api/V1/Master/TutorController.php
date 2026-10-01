<?php

namespace App\Http\Controllers\Api\V1\Master;

use App\Http\Controllers\Controller;
use App\Http\Requests\Master\TutorRequest;
use App\Models\SchoolClass;
use App\Models\Tutor;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class TutorController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $q = trim((string) $request->get('q', ''));
        $allowed = Ownership::tutorIdsFor($request->user());

        $query = Tutor::with(['user:id,name,email', 'subjects:id,name'])->withCount('schoolClasses')->orderBy('name');
        if ($allowed !== null) {
            $query->whereIn('id', $allowed);
        }
        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->where(fn ($x) => $x->whereRaw('LOWER(name) LIKE ?', [$qLike])->orWhere('phone', 'like', '%'.$q.'%'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 10)));
    }

    public function show(Request $request, Tutor $tutor)
    {
        $allowed = Ownership::tutorIdsFor($request->user());
        if ($allowed !== null && ! in_array($tutor->id, $allowed)) {
            abort(404);
        }

        return $this->ok($tutor->load(['user:id,name,email', 'subjects', 'schoolClasses:id,name']));
    }

    /**
     * Opsi tutor pengganti: hanya id/nama (tanpa no HP) untuk kelas tertentu,
     * difilter yang mengampu mapel kelas tersebut.
     */
    public function substituteOptions(Request $request)
    {
        $data = $request->validate(['school_class_id' => ['required', 'exists:school_classes,id']]);

        $allowed = Ownership::classIdsFor($request->user());
        if ($allowed !== null && ! in_array((int) $data['school_class_id'], $allowed)) {
            abort(404);
        }

        $class = SchoolClass::findOrFail($data['school_class_id']);

        // select() harus sebelum withCount, kalau tidak withCount mengunci select *.
        $query = Tutor::select('id', 'name')->withCount('schoolClasses')->orderBy('school_classes_count')->orderBy('name');
        if ($class->subject_id) {
            $query->whereHas('subjects', fn ($q) => $q->where('subjects.id', $class->subject_id));
        }

        return $this->ok($query->get());
    }

    public function store(TutorRequest $request)
    {
        $tutor = Tutor::create($request->safe()->except('subject_ids'));
        if ($request->has('subject_ids')) {
            $tutor->subjects()->sync($request->input('subject_ids', []));
        }

        return $this->ok($tutor->load('subjects'), 'Tutor dibuat', 201);
    }

    public function update(TutorRequest $request, Tutor $tutor)
    {
        $tutor->update($request->safe()->except('subject_ids'));
        if ($request->has('subject_ids')) {
            $tutor->subjects()->sync($request->input('subject_ids', []));
        }

        return $this->ok($tutor->fresh()->load('subjects'), 'Tutor diperbarui');
    }

    public function destroy(Tutor $tutor)
    {
        $tutor->delete();

        return $this->ok(null, 'Tutor dihapus');
    }
}
