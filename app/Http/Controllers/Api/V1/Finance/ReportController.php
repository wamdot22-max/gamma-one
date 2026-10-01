<?php

namespace App\Http\Controllers\Api\V1\Finance;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Traits\ApiResponse;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Excel;

class ReportController extends Controller
{
    use ApiResponse;

    /**
     * Laporan pemasukan harian/bulanan dari pembayaran tercatat.
     */
    public function income(Request $request)
    {
        $data = $request->validate([
            'from_date' => ['nullable', 'date'],
            'to_date' => ['nullable', 'date'],
            'group' => ['sometimes', 'in:harian,bulanan'],
        ]);

        $rows = $this->aggregate($data);

        return $this->ok(['group' => $data['group'] ?? 'harian', 'rows' => $rows, 'total' => $rows->sum('total')]);
    }

    public function incomeExport(Request $request, Excel $excel)
    {
        $data = $request->validate([
            'from_date' => ['nullable', 'date'],
            'to_date' => ['nullable', 'date'],
            'group' => ['sometimes', 'in:harian,bulanan'],
        ]);

        $rows = $this->aggregate($data);
        $group = $data['group'] ?? 'harian';

        $export = new class($rows) implements FromCollection, WithHeadings
        {
            public function __construct(private $rows) {}

            public function collection()
            {
                return $this->rows->map(fn ($row) => [$row['periode'], $row['transaksi'], $row['total']]);
            }

            public function headings(): array
            {
                return ['Periode', 'Transaksi', 'Total (Rp)'];
            }
        };

        return $excel->download($export, "laporan-pemasukan-{$group}.xlsx");
    }

    public function incomePdf(Request $request)
    {
        $data = $request->validate([
            'from_date' => ['nullable', 'date'],
            'to_date' => ['nullable', 'date'],
            'group' => ['sometimes', 'in:harian,bulanan'],
        ]);

        $rows = $this->aggregate($data);
        $pdf = Pdf::loadView('pdf.income-report', [
            'group' => $data['group'] ?? 'harian',
            'rows' => $rows,
            'total' => $rows->sum('total'),
        ]);

        return $pdf->download('laporan-pemasukan.pdf');
    }

    private function aggregate(array $data)
    {
        $query = Payment::query()->orderBy('paid_at');
        if (! empty($data['from_date'])) {
            $query->whereDate('paid_at', '>=', $data['from_date']);
        }
        if (! empty($data['to_date'])) {
            $query->whereDate('paid_at', '<=', $data['to_date']);
        }

        // Dikelompokkan di PHP agar kompatibel MySQL dan SQLite.
        $monthly = ($data['group'] ?? 'harian') === 'bulanan';

        return $query->get(['paid_at', 'amount'])->groupBy(fn ($payment) => substr((string) $payment->paid_at, 0, $monthly ? 7 : 10))
            ->map(fn ($group, $periode) => ['periode' => $periode, 'transaksi' => $group->count(), 'total' => (int) $group->sum('amount')])
            ->values();
    }
}
