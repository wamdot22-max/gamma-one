<?php

namespace App\Http\Controllers\Api\V1\Master;

use App\Http\Controllers\Controller;
use App\Http\Requests\Master\GuardianRequest;
use App\Models\Guardian;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class GuardianController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $q = trim((string) $request->get('q', ''));
        $allowed = Ownership::guardianIdsFor($request->user());

        $query = Guardian::with(['user:id,name,email', 'students:id,name'])->orderBy('name');
        if ($allowed !== null) {
            $query->whereIn('id', $allowed);
        }
        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->where(fn ($x) => $x->whereRaw('LOWER(name) LIKE ?', [$qLike])->orWhere('phone', 'like', '%'.$q.'%'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 10)));
    }

    public function show(Request $request, Guardian $parent)
    {
        $allowed = Ownership::guardianIdsFor($request->user());
        if ($allowed !== null && ! in_array($parent->id, $allowed)) {
            abort(404);
        }

        return $this->ok($parent->load(['user:id,name,email', 'students']));
    }

    public function store(GuardianRequest $request)
    {
        $guardian = Guardian::create($request->safe()->except('students'));
        $this->syncStudents($guardian, $request->input('students', []));

        return $this->ok($guardian->load('students'), 'Orang tua dibuat', 201);
    }

    public function update(GuardianRequest $request, Guardian $parent)
    {
        $parent->update($request->safe()->except('students'));
        if ($request->has('students')) {
            $this->syncStudents($parent, $request->input('students', []));
        }

        return $this->ok($parent->fresh()->load('students'), 'Orang tua diperbarui');
    }

    public function destroy(Guardian $parent)
    {
        $parent->delete();

        return $this->ok(null, 'Orang tua dihapus');
    }

    private function syncStudents(Guardian $guardian, array $students): void
    {
        $sync = [];
        foreach ($students as $item) {
            $sync[$item['id']] = ['relationship' => $item['relationship'] ?? 'wali'];
        }
        $guardian->students()->sync($sync);
    }
}
