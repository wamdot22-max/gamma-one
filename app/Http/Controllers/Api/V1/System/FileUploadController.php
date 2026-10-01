<?php

namespace App\Http\Controllers\Api\V1\System;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class FileUploadController extends Controller
{
    use ApiResponse;

    public function upload(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:png,jpg,jpeg,webp,svg,pdf|max:8192',
        ]);

        $path = $request->file('file')->store('uploads', 'public');
        $url = asset('storage/'.$path);

        return $this->ok(['url' => $url, 'path' => $path], 'Upload berhasil');
    }
}
