<?php

namespace App\Http\Controllers\Api\V1\Master;

use App\Http\Controllers\Controller;
use App\Http\Requests\Master\RoomRequest;
use App\Models\Room;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class RoomController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $q = trim((string) $request->get('q', ''));

        $query = Room::query()->orderBy('name');
        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->where(fn ($x) => $x->whereRaw('LOWER(name) LIKE ?', [$qLike])->orWhereRaw('LOWER(location) LIKE ?', [$qLike]));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 10)));
    }

    public function show(Room $room)
    {
        return $this->ok($room);
    }

    public function store(RoomRequest $request)
    {
        return $this->ok(Room::create($request->validated()), 'Ruangan dibuat', 201);
    }

    public function update(RoomRequest $request, Room $room)
    {
        $room->update($request->validated());

        return $this->ok($room->fresh(), 'Ruangan diperbarui');
    }

    public function destroy(Room $room)
    {
        $room->delete();

        return $this->ok(null, 'Ruangan dihapus');
    }
}
