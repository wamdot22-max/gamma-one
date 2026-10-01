<?php

namespace Database\Seeders;

use App\Models\AppSetting;
use App\Models\Menu;
use App\Models\NotificationTemplate;
use App\Models\PermissionGroup;
use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $groups = collect([
            ['name' => 'Manajemen Pengguna', 'slug' => 'user-management'],
            ['name' => 'Peran & Izin', 'slug' => 'role-permission'],
            ['name' => 'Sistem', 'slug' => 'system'],
            ['name' => 'Data Master', 'slug' => 'master-data'],
            ['name' => 'Penjadwalan & Absensi', 'slug' => 'scheduling'],
            ['name' => 'Keuangan', 'slug' => 'finance'],
            ['name' => 'Notifikasi', 'slug' => 'notification'],
            ['name' => 'Akademik', 'slug' => 'academic'],
        ])->mapWithKeys(fn (array $group) => [$group['slug'] => PermissionGroup::firstOrCreate(['slug' => $group['slug']], $group)]);

        $permissions = [
            'users.view' => 'user-management', 'users.create' => 'user-management', 'users.update' => 'user-management', 'users.delete' => 'user-management',
            'roles.view' => 'role-permission', 'roles.create' => 'role-permission', 'roles.update' => 'role-permission', 'roles.delete' => 'role-permission',
            'permissions.view' => 'role-permission', 'permissions.create' => 'role-permission', 'permissions.update' => 'role-permission', 'permissions.delete' => 'role-permission',
            'permission-groups.view' => 'role-permission', 'permission-groups.create' => 'role-permission', 'permission-groups.update' => 'role-permission', 'permission-groups.delete' => 'role-permission',
            'menus.view' => 'system', 'menus.create' => 'system', 'menus.update' => 'system', 'menus.delete' => 'system',
            'app-settings.view' => 'system', 'app-settings.update' => 'system',
            'blamable-logs.view' => 'system',
        ];

        foreach (['students', 'parents', 'tutors', 'programs', 'subjects', 'rooms', 'classes', 'enrollments'] as $module) {
            foreach (['view', 'create', 'update', 'delete'] as $action) {
                $permissions["{$module}.{$action}"] = 'master-data';
            }
        }
        foreach (['schedules', 'sessions'] as $module) {
            foreach (['view', 'create', 'update', 'delete'] as $action) {
                $permissions["{$module}.{$action}"] = 'scheduling';
            }
        }
        foreach (['invoices', 'payments'] as $module) {
            foreach (['view', 'create', 'update', 'delete'] as $action) {
                $permissions["{$module}.{$action}"] = 'finance';
            }
        }
        $permissions['payrolls.view'] = 'finance';
        foreach (['notification-templates', 'notifications'] as $module) {
            foreach (['view', 'create', 'update', 'delete'] as $action) {
                $permissions["{$module}.{$action}"] = 'notification';
            }
        }
        foreach (['assessments', 'materials', 'assignments', 'submissions'] as $module) {
            foreach (['view', 'create', 'update', 'delete'] as $action) {
                $permissions["{$module}.{$action}"] = 'academic';
            }
        }
        $permissions['grades.view'] = 'academic';
        $permissions['grades.update'] = 'academic';
        $permissions['report-cards.view'] = 'academic';

        foreach ($permissions as $name => $group) {
            Permission::firstOrCreate(['name' => $name, 'guard_name' => 'web'], ['permission_group_id' => $groups[$group]->id]);
        }

        $superAdmin = Role::firstOrCreate(['name' => 'super-admin', 'guard_name' => 'web']);
        $superAdmin->syncPermissions(Permission::all());

        // Peran Gamma One. Izin modul bimbel (siswa, kelas, keuangan, ...)
        // didaftarkan bertahap di fase berikutnya.
        $admin = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'web']);
        $admin->syncPermissions(Permission::all());

        $staf = Role::firstOrCreate(['name' => 'staf', 'guard_name' => 'web']);
        $staf->syncPermissions([
            'users.view',
            'roles.view',
            'permissions.view',
            'permission-groups.view',
            'menus.view',
            'app-settings.view',
            'students.view', 'students.create', 'students.update', 'students.delete',
            'parents.view', 'parents.create', 'parents.update', 'parents.delete',
            'tutors.view', 'tutors.create', 'tutors.update', 'tutors.delete',
            'programs.view', 'programs.create', 'programs.update', 'programs.delete',
            'subjects.view', 'subjects.create', 'subjects.update', 'subjects.delete',
            'rooms.view', 'rooms.create', 'rooms.update', 'rooms.delete',
            'classes.view', 'classes.create', 'classes.update', 'classes.delete',
            'enrollments.view', 'enrollments.create', 'enrollments.update', 'enrollments.delete',
            'schedules.view', 'schedules.create', 'schedules.update', 'schedules.delete',
            'sessions.view', 'sessions.create', 'sessions.update', 'sessions.delete',
            'invoices.view', 'invoices.create', 'invoices.update', 'invoices.delete',
            'payments.view', 'payments.create', 'payments.delete',
            'payrolls.view',
            'notification-templates.view',
            'notifications.view',
            'assessments.view', 'assessments.create', 'assessments.update', 'assessments.delete',
            'grades.view', 'grades.update',
            'materials.view', 'materials.create', 'materials.update', 'materials.delete',
            'assignments.view', 'assignments.create', 'assignments.update', 'assignments.delete',
            'submissions.view', 'submissions.create', 'submissions.delete',
            'report-cards.view',
        ]);

        $tutor = Role::firstOrCreate(['name' => 'tutor', 'guard_name' => 'web']);
        $tutor->syncPermissions(['classes.view', 'students.view', 'enrollments.view', 'schedules.view', 'sessions.view', 'sessions.update', 'payrolls.view', 'assessments.view', 'assessments.create', 'assessments.update', 'assessments.delete', 'grades.view', 'grades.update', 'materials.view', 'materials.create', 'materials.update', 'materials.delete', 'assignments.view', 'assignments.create', 'assignments.update', 'assignments.delete', 'submissions.view', 'submissions.create', 'submissions.delete', 'report-cards.view']);

        $siswa = Role::firstOrCreate(['name' => 'siswa', 'guard_name' => 'web']);
        $siswa->syncPermissions(['students.view', 'classes.view', 'enrollments.view', 'schedules.view', 'sessions.view', 'invoices.view', 'grades.view', 'materials.view', 'assignments.view', 'submissions.view', 'submissions.create', 'report-cards.view']);

        $orangTua = Role::firstOrCreate(['name' => 'orang_tua', 'guard_name' => 'web']);
        $orangTua->syncPermissions(['students.view', 'parents.view', 'classes.view', 'enrollments.view', 'schedules.view', 'sessions.view', 'invoices.view', 'grades.view', 'materials.view', 'assignments.view', 'submissions.view', 'submissions.create', 'report-cards.view']);

        $this->seedExampleAccounts();

        $settingsMenu = Menu::firstOrCreate(['name' => 'Pengaturan'], ['path' => null, 'icon' => 'SettingOutlined', 'sort_order' => 99, 'permission_name' => null]);
        Menu::updateOrCreate(['path' => '/dashboard'], ['name' => 'Dashboard', 'icon' => 'DashboardOutlined', 'sort_order' => 1, 'permission_name' => null]);
        Menu::updateOrCreate(['path' => '/users'], ['name' => 'Users', 'icon' => 'TeamOutlined', 'sort_order' => 1, 'parent_id' => $settingsMenu->id, 'permission_name' => 'users.view']);
        Menu::updateOrCreate(['path' => '/roles'], ['name' => 'Roles', 'icon' => 'SafetyCertificateOutlined', 'sort_order' => 2, 'parent_id' => $settingsMenu->id, 'permission_name' => 'roles.view']);
        Menu::updateOrCreate(['path' => '/permission-groups'], ['name' => 'Permission Groups', 'icon' => 'AppstoreOutlined', 'sort_order' => 3, 'parent_id' => $settingsMenu->id, 'permission_name' => 'permission-groups.view']);
        Menu::updateOrCreate(['path' => '/permissions'], ['name' => 'Permissions', 'icon' => 'LockOutlined', 'sort_order' => 4, 'parent_id' => $settingsMenu->id, 'permission_name' => 'permissions.view']);
        Menu::updateOrCreate(['path' => '/menus'], ['name' => 'Menus', 'icon' => 'MenuOutlined', 'sort_order' => 5, 'parent_id' => $settingsMenu->id, 'permission_name' => 'menus.view']);
        Menu::updateOrCreate(['path' => '/app-settings'], ['name' => 'Aplikasi', 'icon' => 'ApartmentOutlined', 'sort_order' => 6, 'parent_id' => $settingsMenu->id, 'permission_name' => 'app-settings.view']);
        Menu::updateOrCreate(['path' => '/blamable-logs'], ['name' => 'Audit Log', 'icon' => 'HistoryOutlined', 'sort_order' => 7, 'parent_id' => $settingsMenu->id, 'permission_name' => 'blamable-logs.view']);

        $masterMenu = Menu::firstOrCreate(['name' => 'Data Master'], ['path' => null, 'icon' => 'BookOutlined', 'sort_order' => 10, 'permission_name' => null]);
        Menu::updateOrCreate(['path' => '/programs'], ['name' => 'Programs', 'icon' => 'AppstoreAddOutlined', 'sort_order' => 1, 'parent_id' => $masterMenu->id, 'permission_name' => 'programs.view']);
        Menu::updateOrCreate(['path' => '/subjects'], ['name' => 'Subjects', 'icon' => 'ReadOutlined', 'sort_order' => 2, 'parent_id' => $masterMenu->id, 'permission_name' => 'subjects.view']);
        Menu::updateOrCreate(['path' => '/rooms'], ['name' => 'Rooms', 'icon' => 'HomeOutlined', 'sort_order' => 3, 'parent_id' => $masterMenu->id, 'permission_name' => 'rooms.view']);
        Menu::updateOrCreate(['path' => '/classes'], ['name' => 'Classes', 'icon' => 'TeamOutlined', 'sort_order' => 4, 'parent_id' => $masterMenu->id, 'permission_name' => 'classes.view']);
        Menu::updateOrCreate(['path' => '/students'], ['name' => 'Students', 'icon' => 'UserOutlined', 'sort_order' => 5, 'parent_id' => $masterMenu->id, 'permission_name' => 'students.view']);
        Menu::updateOrCreate(['path' => '/parents'], ['name' => 'Parents', 'icon' => 'HeartOutlined', 'sort_order' => 6, 'parent_id' => $masterMenu->id, 'permission_name' => 'parents.view']);
        Menu::updateOrCreate(['path' => '/tutors'], ['name' => 'Tutors', 'icon' => 'SolutionOutlined', 'sort_order' => 7, 'parent_id' => $masterMenu->id, 'permission_name' => 'tutors.view']);
        Menu::updateOrCreate(['path' => '/enrollments'], ['name' => 'Enrollments', 'icon' => 'FormOutlined', 'sort_order' => 8, 'parent_id' => $masterMenu->id, 'permission_name' => 'enrollments.view']);

        $schedulingMenu = Menu::firstOrCreate(['name' => 'Penjadwalan'], ['path' => null, 'icon' => 'CalendarOutlined', 'sort_order' => 11, 'permission_name' => null]);
        Menu::updateOrCreate(['path' => '/schedules'], ['name' => 'Jadwal', 'icon' => 'ClockCircleOutlined', 'sort_order' => 1, 'parent_id' => $schedulingMenu->id, 'permission_name' => 'schedules.view']);
        Menu::updateOrCreate(['path' => '/sessions'], ['name' => 'Sesi & Absensi', 'icon' => 'CheckSquareOutlined', 'sort_order' => 2, 'parent_id' => $schedulingMenu->id, 'permission_name' => 'sessions.view']);

        $financeMenu = Menu::firstOrCreate(['name' => 'Keuangan'], ['path' => null, 'icon' => 'WalletOutlined', 'sort_order' => 12, 'permission_name' => null]);
        Menu::updateOrCreate(['path' => '/invoices'], ['name' => 'Invoices', 'icon' => 'FileTextOutlined', 'sort_order' => 1, 'parent_id' => $financeMenu->id, 'permission_name' => 'invoices.view']);
        Menu::updateOrCreate(['path' => '/payments'], ['name' => 'Pembayaran', 'icon' => 'DollarOutlined', 'sort_order' => 2, 'parent_id' => $financeMenu->id, 'permission_name' => 'payments.view']);
        Menu::updateOrCreate(['path' => '/payrolls'], ['name' => 'Gaji Tutor', 'icon' => 'BankOutlined', 'sort_order' => 3, 'parent_id' => $financeMenu->id, 'permission_name' => 'payrolls.view']);

        $notifMenu = Menu::firstOrCreate(['name' => 'Notifikasi'], ['path' => null, 'icon' => 'BellOutlined', 'sort_order' => 13, 'permission_name' => null]);
        Menu::updateOrCreate(['path' => '/notification-templates'], ['name' => 'Template Pesan', 'icon' => 'MessageOutlined', 'sort_order' => 1, 'parent_id' => $notifMenu->id, 'permission_name' => 'notification-templates.view']);
        Menu::updateOrCreate(['path' => '/notifications'], ['name' => 'Log Notifikasi', 'icon' => 'HistoryOutlined', 'sort_order' => 2, 'parent_id' => $notifMenu->id, 'permission_name' => 'notifications.view']);

        $academicMenu = Menu::firstOrCreate(['name' => 'Akademik'], ['path' => null, 'icon' => 'TrophyOutlined', 'sort_order' => 14, 'permission_name' => null]);
        Menu::updateOrCreate(['path' => '/assessments'], ['name' => 'Asesmen & Nilai', 'icon' => 'EditOutlined', 'sort_order' => 1, 'parent_id' => $academicMenu->id, 'permission_name' => 'assessments.view']);
        Menu::updateOrCreate(['path' => '/materials'], ['name' => 'Materi', 'icon' => 'ReadOutlined', 'sort_order' => 2, 'parent_id' => $academicMenu->id, 'permission_name' => 'materials.view']);
        Menu::updateOrCreate(['path' => '/assignments'], ['name' => 'Tugas', 'icon' => 'FormOutlined', 'sort_order' => 3, 'parent_id' => $academicMenu->id, 'permission_name' => 'assignments.view']);
        Menu::updateOrCreate(['path' => '/report-cards'], ['name' => 'Rapor', 'icon' => 'FileTextOutlined', 'sort_order' => 4, 'parent_id' => $academicMenu->id, 'permission_name' => 'report-cards.view']);

        foreach (NotificationService::DEFAULTS as $key => $template) {
            NotificationTemplate::firstOrCreate(['key' => $key], ['name' => $template['name'], 'body' => $template['body'], 'is_active' => true]);
        }

        AppSetting::firstOrCreate(['id' => 1], [
            'app_name' => 'Gamma One',
            'company_name' => 'Gamma One',
            'sidebar_logo_url' => '/images/logo-gamma-one.svg',
            'login_logo_url' => '/images/logo-gamma-one.svg',
            'favicon_url' => '/images/logo-gamma-one.svg',
        ]);

        $this->call(MasterSampleSeeder::class);
        $this->call(SchedulingSampleSeeder::class);
        $this->call(AcademicSampleSeeder::class);
    }

    private function seedExampleAccounts(): void
    {
        $accounts = [
            ['name' => 'Super Admin', 'email' => 'admin@dev.local', 'phone' => '628110000001', 'role' => 'super-admin'],
            ['name' => 'Admin Contoh', 'email' => 'admin.contoh@dev.local', 'phone' => '628110000002', 'role' => 'admin'],
            ['name' => 'Staf Contoh', 'email' => 'staf@dev.local', 'phone' => '628120000003', 'role' => 'staf'],
            ['name' => 'Tutor Contoh', 'email' => 'tutor@dev.local', 'phone' => '628130000004', 'role' => 'tutor'],
            ['name' => 'Siswa Contoh', 'email' => 'siswa@dev.local', 'phone' => '628140000005', 'role' => 'siswa'],
            ['name' => 'Orang Tua Contoh', 'email' => 'orangtua@dev.local', 'phone' => '628150000006', 'role' => 'orang_tua'],
        ];

        foreach ($accounts as $account) {
            $user = User::firstOrCreate(
                ['email' => $account['email']],
                ['name' => $account['name'], 'phone' => $account['phone'], 'password' => Hash::make('password123')]
            );
            $user->syncRoles([$account['role']]);
        }
    }
}
