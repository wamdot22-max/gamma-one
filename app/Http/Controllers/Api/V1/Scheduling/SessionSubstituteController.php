<?php

namespace App\Http\Controllers\Api\V1\Scheduling;

use App\Http\Controllers\Controller;
use App\Models\Session;
use App\Models\SessionSubstituteRequest;
use App\Models\Tutor;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SessionSubstituteController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $classIds = Ownership::classIdsFor($request->user());

        $query = SessionSubstituteRequest::with(['session:id,school_class_id,session_date', 'session.schoolClass:id,name', 'originalTutor:id,name', 'proposedTutor:id,name', 'requester:id,name'])
            ->orderByDesc('id');
        if ($classIds !== null) {
            $query->whereHas('session', fn ($q) => $q->whereIn('school_class_id', $classIds));
        }
        if ($request->get('status')) {
            $query->where('status', $request->get('status'));
        }
        if ($request->get('session_id')) {
            $query->where('session_id', $request->get('session_id'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 15)));
    }

    /**
     * Tutor mengusulkan pengganti untuk sesinya (staf juga boleh mengusulkan).
     */
    public function store(Request $request, Session $session)
    {
        $this->assertVisible($request, $session);
        if ($session->status === 'dibatalkan') {
            return $this->fail('Sesi yang dibatalkan tidak bisa diganti tutornya.', 422);
        }
        if ($session->status === 'selesai') {
            return $this->fail('Sesi yang sudah selesai tidak bisa diganti tutornya.', 422);
        }

        $data = $request->validate([
            'proposed_tutor_id' => ['required', 'exists:tutors,id'],
            'reason' => ['required', 'string', 'max:1000'],
        ], [
            'proposed_tutor_id.required' => 'Tutor pengganti wajib dipilih.',
            'reason.required' => 'Alasan wajib diisi.',
        ]);

        $user = $request->user();
        $ownTutorId = Ownership::tutorRecord($user)?->id;
        if ($ownTutorId !== (int) $session->tutor_id && ! Ownership::isPrivileged($user)) {
            return $this->fail('Hanya tutor sesi ini atau staf yang boleh mengusulkan pengganti.', 403);
        }

        if ((int) $data['proposed_tutor_id'] === (int) $session->tutor_id) {
            return $this->fail('Tutor pengganti harus berbeda dari tutor asli.', 422);
        }

        $candidate = Tutor::with('subjects:id')->findOrFail($data['proposed_tutor_id']);
        $subjectId = $session->schoolClass->subject_id;
        if ($subjectId && ! $candidate->subjects->contains('id', (int) $subjectId)) {
            return $this->fail("{$candidate->name} tidak mengampu mapel kelas ini.", 422);
        }

        $pending = SessionSubstituteRequest::where('session_id', $session->id)->where('status', 'diusulkan')->exists();
        if ($pending) {
            return $this->fail('Sesi ini sudah punya usulan pengganti yang menunggu persetujuan.', 422);
        }

        if ($this->isBusy($candidate->id, $session)) {
            return $this->fail("{$candidate->name} bentrok dengan sesi lain di jam tersebut.", 422);
        }

        $proposal = SessionSubstituteRequest::create([
            'session_id' => $session->id,
            'original_tutor_id' => $session->tutor_id,
            'proposed_tutor_id' => $candidate->id,
            'reason' => $data['reason'],
            'status' => 'diusulkan',
            'requested_by' => $user->id,
        ]);

        return $this->ok($proposal->load(['proposedTutor:id,name']), 'Usulan pengganti dikirim, menunggu persetujuan staf', 201);
    }

    public function approve(Request $request, SessionSubstituteRequest $substituteRequest)
    {
        return $this->review($request, $substituteRequest, true);
    }

    public function reject(Request $request, SessionSubstituteRequest $substituteRequest)
    {
        return $this->review($request, $substituteRequest, false);
    }

    private function review(Request $request, SessionSubstituteRequest $substituteRequest, bool $approve)
    {
        if (! Ownership::isPrivileged($request->user())) {
            return $this->fail('Hanya admin/staf yang boleh menyetujui usulan.', 403);
        }
        if ($substituteRequest->status !== 'diusulkan') {
            return $this->fail('Usulan sudah diproses.', 422);
        }

        $data = $request->validate(['review_note' => ['nullable', 'string', 'max:1000']]);
        $session = $substituteRequest->session;
        if (! $session || $session->status === 'dibatalkan') {
            return $this->fail('Sesi sudah tidak aktif.', 422);
        }

        DB::transaction(function () use ($substituteRequest, $session, $request, $data, $approve) {
            $substituteRequest->update([
                'status' => $approve ? 'disetujui' : 'ditolak',
                'reviewed_by' => $request->user()->id,
                'reviewed_at' => now(),
                'review_note' => $data['review_note'] ?? null,
            ]);
            if ($approve) {
                $session->update(['substitute_tutor_id' => $substituteRequest->proposed_tutor_id]);
            }
        });

        return $this->ok(
            $substituteRequest->fresh()->load(['proposedTutor:id,name', 'session:id']),
            $approve ? 'Pengganti disetujui' : 'Usulan ditolak'
        );
    }

    private function isBusy(int $tutorId, Session $session): bool
    {
        return Session::whereDate('session_date', $session->session_date->toDateString())
            ->where('status', '!=', 'dibatalkan')
            ->where('id', '!=', $session->id)
            ->where(fn ($q) => $q->where('tutor_id', $tutorId)->orWhere('substitute_tutor_id', $tutorId))
            ->where('start_time', '<', substr((string) $session->end_time, 0, 8))
            ->where('end_time', '>', substr((string) $session->start_time, 0, 8))
            ->exists();
    }

    private function assertVisible(Request $request, Session $session): void
    {
        $allowed = Ownership::classIdsFor($request->user());
        if ($allowed !== null && ! in_array($session->school_class_id, $allowed)) {
            abort(404);
        }
    }
}
