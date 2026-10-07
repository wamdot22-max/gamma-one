<?php

use App\Http\Controllers\Api\V1\Academic\AssessmentController;
use App\Http\Controllers\Api\V1\Academic\AssignmentController;
use App\Http\Controllers\Api\V1\Academic\GradeController;
use App\Http\Controllers\Api\V1\Academic\JournalController;
use App\Http\Controllers\Api\V1\Academic\MaterialController;
use App\Http\Controllers\Api\V1\Academic\ReportCardController;
use App\Http\Controllers\Api\V1\Academic\SubmissionController;
use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\Auth\PasswordResetController;
use App\Http\Controllers\Api\V1\Auth\ProfileController;
use App\Http\Controllers\Api\V1\Finance\InvoiceController;
use App\Http\Controllers\Api\V1\Finance\PaymentController;
use App\Http\Controllers\Api\V1\Finance\PayrollController;
use App\Http\Controllers\Api\V1\Finance\ReportController;
use App\Http\Controllers\Api\V1\Finance\TutorRecapController;
use App\Http\Controllers\Api\V1\Finance\WebhookController;
use App\Http\Controllers\Api\V1\IAM\PermissionController;
use App\Http\Controllers\Api\V1\IAM\PermissionGroupController;
use App\Http\Controllers\Api\V1\IAM\RoleController;
use App\Http\Controllers\Api\V1\IAM\UserController;
use App\Http\Controllers\Api\V1\Master\EnrollmentController;
use App\Http\Controllers\Api\V1\Master\GuardianController;
use App\Http\Controllers\Api\V1\Master\ProgramController;
use App\Http\Controllers\Api\V1\Master\RoomController;
use App\Http\Controllers\Api\V1\Master\SchoolClassController;
use App\Http\Controllers\Api\V1\Master\StudentsController;
use App\Http\Controllers\Api\V1\Master\SubjectController;
use App\Http\Controllers\Api\V1\Master\TutorController;
use App\Http\Controllers\Api\V1\Notifications\NotificationLogController;
use App\Http\Controllers\Api\V1\Notifications\NotificationTemplateController;
use App\Http\Controllers\Api\V1\Notifications\PreferenceController;
use App\Http\Controllers\Api\V1\Scheduling\RecapController;
use App\Http\Controllers\Api\V1\Scheduling\ScheduleController;
use App\Http\Controllers\Api\V1\Scheduling\SessionController;
use App\Http\Controllers\Api\V1\Scheduling\SessionSubstituteController;
use App\Http\Controllers\Api\V1\Settings\AppSettingController;
use App\Http\Controllers\Api\V1\Settings\CourseSettingController;
use App\Http\Controllers\Api\V1\System\BlamableLogController;
use App\Http\Controllers\Api\V1\System\DashboardController;
use App\Http\Controllers\Api\V1\System\FileUploadController;
use App\Http\Controllers\Api\V1\System\MenuController;
use Illuminate\Support\Facades\Route;

if (! function_exists('secureCrud')) {
    function secureCrud(string $resource, string $controller, string $prefix): void
    {
        Route::apiResource($resource, $controller)
            ->middlewareFor(['index', 'show'], ["permission:{$prefix}.view"])
            ->middlewareFor(['store'], ["permission:{$prefix}.create"])
            ->middlewareFor(['update'], ["permission:{$prefix}.update"])
            ->middlewareFor(['destroy'], ["permission:{$prefix}.delete"]);
    }
}

Route::prefix('v1')->group(function (): void {
    Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:5,1');
    Route::post('/auth/forgot-password', [PasswordResetController::class, 'forgot'])->middleware('throttle:5,1');
    Route::post('/auth/reset-password', [PasswordResetController::class, 'reset'])->middleware('throttle:5,1');
    Route::post('/webhooks/midtrans', [WebhookController::class, 'midtrans']);
    Route::get('/app-settings', [AppSettingController::class, 'show']);

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::put('/profile', [ProfileController::class, 'update']);
        Route::post('/files/upload', [FileUploadController::class, 'upload']);
        Route::put('/app-settings', [AppSettingController::class, 'update'])->middleware('permission:app-settings.update');
        Route::get('/course-settings', [CourseSettingController::class, 'show'])->middleware('permission:app-settings.view');
        Route::put('/course-settings', [CourseSettingController::class, 'update'])->middleware('permission:app-settings.update');
        Route::get('/dashboard/summary', [DashboardController::class, 'summary']);
        Route::get('/menus/sidebar', [MenuController::class, 'sidebar']);
        Route::get('/blamable-logs', [BlamableLogController::class, 'index'])->middleware('permission:blamable-logs.view');

        Route::post('/students/import', [StudentsController::class, 'import'])->middleware('permission:students.create');
        secureCrud('students', StudentsController::class, 'students');
        secureCrud('parents', GuardianController::class, 'parents');
        Route::get('/tutors/substitute-options', [TutorController::class, 'substituteOptions'])->middleware('permission:sessions.update');
        secureCrud('tutors', TutorController::class, 'tutors');
        secureCrud('programs', ProgramController::class, 'programs');
        secureCrud('subjects', SubjectController::class, 'subjects');
        secureCrud('rooms', RoomController::class, 'rooms');
        secureCrud('classes', SchoolClassController::class, 'classes');
        secureCrud('enrollments', EnrollmentController::class, 'enrollments');
        Route::get('/schedules-weekly', [ScheduleController::class, 'weekly'])->middleware('permission:schedules.view');
        secureCrud('schedules', ScheduleController::class, 'schedules');
        Route::get('/sessions', [SessionController::class, 'index'])->middleware('permission:sessions.view');
        Route::post('/sessions/generate', [SessionController::class, 'generate'])->middleware('permission:sessions.create');
        Route::get('/sessions/{session}', [SessionController::class, 'show'])->middleware('permission:sessions.view');
        Route::put('/sessions/{session}/reschedule', [SessionController::class, 'reschedule'])->middleware('permission:sessions.update');
        Route::put('/sessions/{session}/cancel', [SessionController::class, 'cancel'])->middleware('permission:sessions.update');
        Route::put('/sessions/{session}/complete', [SessionController::class, 'complete'])->middleware('permission:sessions.update');
        Route::put('/sessions/{session}/reopen', [SessionController::class, 'reopen'])->middleware('permission:sessions.update');
        Route::delete('/sessions/{session}', [SessionController::class, 'destroy'])->middleware('permission:sessions.delete');
        Route::get('/sessions/{session}/attendances', [SessionController::class, 'attendances'])->middleware('permission:sessions.view');
        Route::get('/sessions/{session}/history', [SessionController::class, 'history'])->middleware('permission:sessions.view');
        Route::get('/substitute-requests', [SessionSubstituteController::class, 'index'])->middleware('permission:sessions.view');
        Route::post('/sessions/{session}/substitute-requests', [SessionSubstituteController::class, 'store'])->middleware('permission:sessions.update');
        Route::put('/substitute-requests/{substituteRequest}/approve', [SessionSubstituteController::class, 'approve'])->middleware('permission:sessions.update');
        Route::put('/substitute-requests/{substituteRequest}/reject', [SessionSubstituteController::class, 'reject'])->middleware('permission:sessions.update');
        Route::put('/sessions/{session}/attendances', [SessionController::class, 'storeAttendances'])->middleware('permission:sessions.update');
        Route::post('/sessions/{session}/attendances/scan', [SessionController::class, 'scan'])->middleware('permission:sessions.update');
        Route::get('/attendances/recap', [RecapController::class, 'index'])->middleware('permission:sessions.view');
        Route::get('/attendances/export', [RecapController::class, 'export'])->middleware('permission:sessions.view');
        secureCrud('invoices', InvoiceController::class, 'invoices');
        Route::get('/invoices/{invoice}/receipt', [InvoiceController::class, 'receipt'])->middleware('permission:invoices.view');
        Route::post('/invoices/{invoice}/pay-link', [InvoiceController::class, 'payLink'])->middleware('permission:invoices.view');
        Route::get('/payments', [PaymentController::class, 'index'])->middleware('permission:payments.view');
        Route::post('/payments', [PaymentController::class, 'store'])->middleware('permission:payments.create');
        Route::get('/payments/{payment}', [PaymentController::class, 'show'])->middleware('permission:payments.view');
        Route::delete('/payments/{payment}', [PaymentController::class, 'destroy'])->middleware('permission:payments.delete');
        Route::get('/payrolls', [PayrollController::class, 'index'])->middleware('permission:payrolls.view');
        Route::get('/payrolls/{tutor}/slip', [PayrollController::class, 'slip'])->middleware('permission:payrolls.view');
        Route::get('/tutor-recaps', [TutorRecapController::class, 'index'])->middleware('permission:payrolls.view');
        Route::get('/tutor-recaps/export', [TutorRecapController::class, 'export'])->middleware('permission:payrolls.view');
        Route::get('/reports/income', [ReportController::class, 'income'])->middleware('permission:payments.view');
        Route::get('/reports/income-export', [ReportController::class, 'incomeExport'])->middleware('permission:payments.view');
        Route::get('/reports/income-pdf', [ReportController::class, 'incomePdf'])->middleware('permission:payments.view');
        secureCrud('assessments', AssessmentController::class, 'assessments');
        Route::get('/assessments/{assessment}/grades', [AssessmentController::class, 'grades'])->middleware('permission:grades.view');
        Route::put('/assessments/{assessment}/grades', [AssessmentController::class, 'storeGrades'])->middleware('permission:grades.update');
        Route::get('/grades', [GradeController::class, 'index'])->middleware('permission:grades.view');
        Route::get('/grades/averages', [GradeController::class, 'averages'])->middleware('permission:grades.view');
        Route::get('/journals', [JournalController::class, 'index'])->middleware('permission:sessions.view');
        secureCrud('materials', MaterialController::class, 'materials');
        secureCrud('assignments', AssignmentController::class, 'assignments');
        Route::get('/submissions', [SubmissionController::class, 'index'])->middleware('permission:submissions.view');
        Route::post('/submissions', [SubmissionController::class, 'store'])->middleware('permission:submissions.create');
        Route::delete('/submissions/{submission}', [SubmissionController::class, 'destroy'])->middleware('permission:submissions.delete');
        Route::get('/report-cards', [ReportCardController::class, 'index'])->middleware('permission:report-cards.view');
        Route::get('/report-cards/download', [ReportCardController::class, 'download'])->middleware('permission:report-cards.view');
        secureCrud('notification-templates', NotificationTemplateController::class, 'notification-templates');
        Route::get('/notifications', [NotificationLogController::class, 'index'])->middleware('permission:notifications.view');
        Route::post('/notifications/{notification}/retry', [NotificationLogController::class, 'retry'])->middleware('permission:notifications.update');
        Route::get('/notification-preferences', [PreferenceController::class, 'show']);
        Route::put('/notification-preferences', [PreferenceController::class, 'update']);
        secureCrud('users', UserController::class, 'users');
        secureCrud('roles', RoleController::class, 'roles');
        secureCrud('permission-groups', PermissionGroupController::class, 'permission-groups');
        Route::get('/permissions-role-options', [PermissionController::class, 'roleOptions'])->middleware('permission:permissions.view');
        secureCrud('permissions', PermissionController::class, 'permissions');
        secureCrud('menus', MenuController::class, 'menus');
    });
});
