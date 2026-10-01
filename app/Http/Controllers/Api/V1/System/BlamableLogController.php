<?php

namespace App\Http\Controllers\Api\V1\System;

use App\Http\Controllers\Controller;
use App\Models\BlamableLog;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class BlamableLogController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $perPage = (int) $request->get('per_page', 20);
        $q = trim((string) $request->get('q', ''));
        $action = trim((string) $request->get('action', ''));
        $modelType = trim((string) $request->get('model_type', ''));
        $userId = $request->get('user_id');

        $query = BlamableLog::with(['user:id,name,email'])->latest('id');

        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->where(function ($x) use ($qLike) {
                $x->whereRaw('LOWER(model_type) LIKE ?', [$qLike])
                    ->orWhereRaw('LOWER(model_id) LIKE ?', [$qLike])
                    ->orWhereHas('user', fn ($u) => $u->whereRaw('LOWER(name) LIKE ?', [$qLike])->orWhereRaw('LOWER(email) LIKE ?', [$qLike]));
            });
        }

        if ($action !== '') {
            $query->where('action', $action);
        }
        if ($modelType !== '') {
            $query->where('model_type', $modelType);
        }
        if ($userId !== null && $userId !== '') {
            $query->where('user_id', $userId);
        }

        return $this->ok($query->paginate($perPage));
    }
}
