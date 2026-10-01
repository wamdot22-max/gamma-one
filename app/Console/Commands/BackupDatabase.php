<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Carbon;
use Symfony\Component\Process\Process;

class BackupDatabase extends Command
{
    protected $signature = 'app:backup-database';

    protected $description = 'Cadangkan database MySQL/MariaDB dengan mysqldump ke storage/app/backups.';

    public function handle(): int
    {
        $binary = (string) (env('MYSQLDUMP_PATH') ?: 'mysqldump');
        if (! $this->binaryExists($binary)) {
            $this->error("mysqldump tidak ditemukan (MYSQLDUMP_PATH={$binary}). Lewati backup.");

            return self::FAILURE;
        }

        $dir = storage_path('app/backups');
        if (! is_dir($dir)) {
            mkdir($dir, 0755, true);
        }
        $file = $dir.'/gamma-one-'.Carbon::now('Asia/Jakarta')->format('Ymd-His').'.sql';

        $process = new Process([
            $binary,
            '-h', (string) config('database.connections.mysql.host'),
            '-P', (string) config('database.connections.mysql.port'),
            '-u', (string) config('database.connections.mysql.username'),
            '--password='.(string) config('database.connections.mysql.password'),
            (string) config('database.connections.mysql.database'),
            '--result-file='.$file,
        ]);
        $process->setTimeout(300);
        $process->run();

        if (! $process->isSuccessful()) {
            $this->error('Backup gagal: '.$process->getErrorOutput());

            return self::FAILURE;
        }

        // Simpan 7 berkas terbaru saja.
        collect(glob($dir.'/gamma-one-*.sql') ?: [])
            ->sort()->reverse()->slice(7)
            ->each(fn ($old) => @unlink($old));

        $this->info("Backup tersimpan: {$file}");

        return self::SUCCESS;
    }

    private function binaryExists(string $binary): bool
    {
        if (is_file($binary)) {
            return true;
        }

        $process = new Process([$binary, '--version']);
        $process->run();

        return $process->isSuccessful();
    }
}
