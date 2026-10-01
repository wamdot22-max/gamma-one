<?php

namespace App\Traits;

use App\Models\BlamableLog;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Schema;

trait Blamable
{
    protected static function bootBlamable(): void
    {
        static::creating(function ($model) {
            $userId = Auth::id();
            if (! $userId) {
                return;
            }
            if (self::hasColumn($model, 'created_by') && ! $model->created_by) {
                $model->created_by = $userId;
            }
            if (self::hasColumn($model, 'updated_by')) {
                $model->updated_by = $userId;
            }
        });

        static::updating(function ($model) {
            $userId = Auth::id();
            if ($userId && self::hasColumn($model, 'updated_by')) {
                $model->updated_by = $userId;
            }
        });

        static::deleting(function ($model) {
            $userId = Auth::id();
            if ($userId && self::hasColumn($model, 'deleted_by') && method_exists($model, 'isForceDeleting') && ! $model->isForceDeleting()) {
                $model->deleted_by = $userId;
                $model->saveQuietly();
            }
        });

        static::created(function ($model) {
            self::writeLog($model, 'created', null, self::sanitize($model->getAttributes()));
        });

        static::updated(function ($model) {
            if (empty($model->getChanges())) {
                return;
            }
            self::writeLog($model, 'updated', self::sanitize($model->getOriginal()), self::sanitize($model->getAttributes()));
        });

        static::deleted(function ($model) {
            self::writeLog($model, 'deleted', self::sanitize($model->getOriginal()), null);
        });
    }

    private static function writeLog($model, string $action, ?array $oldValues, ?array $newValues): void
    {
        BlamableLog::create([
            'user_id' => Auth::id(),
            'model_type' => get_class($model),
            'model_id' => (string) $model->getKey(),
            'action' => $action,
            'old_values' => $oldValues,
            'new_values' => $newValues,
        ]);
    }

    private static function sanitize(array $values): array
    {
        unset($values['password'], $values['remember_token']);

        return $values;
    }

    private static function hasColumn($model, string $column): bool
    {
        static $cache = [];
        $table = $model->getTable();
        if (! isset($cache[$table])) {
            $cache[$table] = array_flip(Schema::getColumnListing($table));
        }

        return isset($cache[$table][$column]);
    }
}
