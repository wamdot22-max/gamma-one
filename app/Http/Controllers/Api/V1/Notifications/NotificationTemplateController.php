<?php

namespace App\Http\Controllers\Api\V1\Notifications;

use App\Http\Controllers\Controller;
use App\Http\Requests\Notifications\NotificationTemplateRequest;
use App\Models\NotificationTemplate;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class NotificationTemplateController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $q = trim((string) $request->get('q', ''));

        $query = NotificationTemplate::query()->orderBy('key');
        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->where(fn ($x) => $x->whereRaw('LOWER(name) LIKE ?', [$qLike])->orWhereRaw('LOWER(`key`) LIKE ?', [$qLike]));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 20)));
    }

    public function show(NotificationTemplate $notificationTemplate)
    {
        return $this->ok($notificationTemplate);
    }

    public function store(NotificationTemplateRequest $request)
    {
        return $this->ok(NotificationTemplate::create($request->validated()), 'Template dibuat', 201);
    }

    public function update(NotificationTemplateRequest $request, NotificationTemplate $notificationTemplate)
    {
        $notificationTemplate->update($request->validated());

        return $this->ok($notificationTemplate->fresh(), 'Template diperbarui');
    }

    public function destroy(NotificationTemplate $notificationTemplate)
    {
        $notificationTemplate->delete();

        return $this->ok(null, 'Template dihapus');
    }
}
