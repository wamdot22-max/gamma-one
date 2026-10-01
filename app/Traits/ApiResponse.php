<?php

namespace App\Traits;

trait ApiResponse
{
    protected function ok(mixed $data = null, string $message = 'OK', int $code = 200)
    {
        return response()->json(['success' => true, 'message' => $message, 'data' => $data], $code);
    }

    protected function fail(string $message = 'Terjadi kesalahan', int $code = 400, mixed $errors = null)
    {
        return response()->json(['success' => false, 'message' => $message, 'errors' => $errors], $code);
    }
}
