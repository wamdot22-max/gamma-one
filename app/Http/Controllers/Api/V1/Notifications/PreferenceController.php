<?php

namespace App\Http\Controllers\Api\V1\Notifications;

use App\Http\Controllers\Controller;
use App\Models\NotificationPreference;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class PreferenceController extends Controller
{
    use ApiResponse;

    public function show(Request $request)
    {
        return $this->ok(NotificationPreference::firstOrCreate(
            ['user_id' => $request->user()->id],
            ['wa_enabled' => true, 'email_enabled' => true]
        ));
    }

    public function update(Request $request)
    {
        $data = $request->validate([
            'wa_enabled' => ['sometimes', 'boolean'],
            'email_enabled' => ['sometimes', 'boolean'],
        ]);

        $pref = NotificationPreference::firstOrCreate(
            ['user_id' => $request->user()->id],
            ['wa_enabled' => true, 'email_enabled' => true]
        );
        $pref->update($data);

        return $this->ok($pref->fresh(), 'Preferensi disimpan');
    }
}
