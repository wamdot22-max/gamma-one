<?php

namespace App\Http\Controllers\Api\V1\Finance;

use App\Http\Controllers\Controller;
use App\Models\Session;
use App\Models\Tutor;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class PayrollController extends Controller
{
    use ApiResponse;

    /**
     * Honor tutor per bulan dari jumlah sesi × honor per sesi.
     */
    public function index(Request $request)
    {
        $month = $request->get('month', now()->format('Y-m'));
        $tutorIds = Ownership::tutorIdsFor($request->user());

        $tutors = Tutor::orderBy('name')
            ->when($tutorIds !== null, fn ($q) => $q->whereIn('id', $tutorIds))
            ->get();

        $rows = $tutors->map(fn ($tutor) => $this->row($tutor, $month));

        return $this->ok(['month' => $month, 'rows' => $rows]);
    }

    public function slip(Request $request, Tutor $tutor)
    {
        $tutorIds = Ownership::tutorIdsFor($request->user());
        if ($tutorIds !== null && ! in_array($tutor->id, $tutorIds)) {
            abort(404);
        }

        $month = $request->get('month', now()->format('Y-m'));
        $row = $this->row($tutor, $month);

        $pdf = Pdf::loadView('pdf.pay-slip', ['tutor' => $tutor, 'month' => $month, 'row' => $row]);

        return $pdf->download("slip-honor-{$tutor->id}-{$month}.pdf");
    }

    private function row(Tutor $tutor, string $month): array
    {
        // Sesi miliknya yang tidak digantikan + sesi yang ia gantikan.
        // Honor sesi pengganti memakai tarif tutor asli.
        // Honor hanya dari sesi yang selesai dilaksanakan.
        $sessions = Session::with(['schoolClass:id,name', 'tutor:id,fee_per_session'])
            ->where('status', 'selesai')
            ->where('session_date', 'like', "{$month}%")
            ->where(fn ($q) => $q->where('tutor_id', $tutor->id)->orWhere('substitute_tutor_id', $tutor->id))
            ->get();

        $items = [];
        foreach ($sessions as $session) {
            if ($session->substitute_tutor_id === $tutor->id) {
                $items[] = [
                    'id' => $session->id,
                    'session_date' => $session->session_date,
                    'class' => $session->schoolClass->name ?? '-',
                    'peran' => 'pengganti',
                    'honor' => (int) ($session->tutor->fee_per_session ?? 0),
                ];
            } elseif ($session->tutor_id === $tutor->id && ! $session->substitute_tutor_id) {
                $items[] = [
                    'id' => $session->id,
                    'session_date' => $session->session_date,
                    'class' => $session->schoolClass->name ?? '-',
                    'peran' => 'pengajar',
                    'honor' => (int) $tutor->fee_per_session,
                ];
            }
        }

        return [
            'tutor' => $tutor->only('id', 'name'),
            'sessions_count' => count($items),
            'fee_per_session' => (int) $tutor->fee_per_session,
            'total' => array_sum(array_column($items, 'honor')),
            'sessions' => $items,
        ];
    }
}
