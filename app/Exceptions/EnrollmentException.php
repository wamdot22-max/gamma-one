<?php

namespace App\Exceptions;

use RuntimeException;

/**
 * Galat aturan bisnis pendaftaran (duplikat/penuh) yang diterjemahkan
 * controller menjadi respons 422, bukan 500.
 */
class EnrollmentException extends RuntimeException {}
