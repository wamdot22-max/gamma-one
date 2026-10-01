<?php

namespace App\Http\Controllers\Api\V1\Notifications;

use App\Http\Controllers\Controller;
use App\Jobs\SendNotification;
use App\Models\NotificationLog;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class NotificationLogController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $q = trim((string) $request->get('q', ''));

        $query = NotificationLog::with('user:id,name')->orderByDesc('id');
        if ($q !== '') {
            $query->where('body', 'like', '%'.$q.'%');
        }
        foreach (['status', 'channel', 'template_key'] as $filter) {
            if ($request->get($filter)) {
                $query->where($filter, $request->get($filter));
            }
        }
        if ($request->has('needs_follow_up')) {
            $query->where('needs_follow_up', filter_var($request->get('needs_follow_up'), FILTER_VALIDATE_BOOL));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 20)));
    }

    public function retry(NotificationLog $notification)
    {
        if ($notification->status === 'terkirim') {
            return $this->fail('Notifikasi sudah terkirim.', 422);
        }

        $notification->update(['status' => 'pending', 'error' => null]);
        SendNotification::dispatch($notification->id);

        return $this->ok($notification->fresh(), 'Notifikasi dimasukkan antrean ulang');
    }
}
