import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import AppLayout from '../components/AppLayout.vue'
import PortalLayout from '../components/PortalLayout.vue'
import LoginPage from '../pages/auth/LoginPage.vue'
import ForgotPasswordPage from '../pages/auth/ForgotPasswordPage.vue'
import ResetPasswordPage from '../pages/auth/ResetPasswordPage.vue'
import DashboardPage from '../pages/dashboard/DashboardPage.vue'
import UsersPage from '../pages/iam/UsersPage.vue'
import RolesPage from '../pages/iam/RolesPage.vue'
import PermissionManagementPage from '../pages/iam/PermissionManagementPage.vue'
import CrudPage from '../pages/shared/CrudPage.vue'
import MenuManagementPage from '../pages/system/MenuManagementPage.vue'
import BlamableLogsPage from '../pages/system/BlamableLogsPage.vue'
import AppSettingsPage from '../pages/settings/AppSettingsPage.vue'
import StudentsPage from '../pages/master/StudentsPage.vue'
import ParentsPage from '../pages/master/ParentsPage.vue'
import TutorsPage from '../pages/master/TutorsPage.vue'
import ClassesPage from '../pages/master/ClassesPage.vue'
import EnrollmentsPage from '../pages/master/EnrollmentsPage.vue'
import PortalHomePage from '../pages/portal/PortalHomePage.vue'
import PortalSchedulePage from '../pages/portal/PortalSchedulePage.vue'
import PortalBillingPage from '../pages/portal/PortalBillingPage.vue'
import PortalNilaiPage from '../pages/portal/PortalNilaiPage.vue'
import PortalProfilePage from '../pages/portal/PortalProfilePage.vue'
import SchedulesPage from '../pages/scheduling/SchedulesPage.vue'
import SessionsPage from '../pages/scheduling/SessionsPage.vue'
import InvoicesPage from '../pages/finance/InvoicesPage.vue'
import PaymentsPage from '../pages/finance/PaymentsPage.vue'
import PayrollsPage from '../pages/finance/PayrollsPage.vue'
import TutorRecapsPage from '../pages/finance/TutorRecapsPage.vue'
import NotificationsPage from '../pages/notifications/NotificationsPage.vue'
import AssessmentsPage from '../pages/academic/AssessmentsPage.vue'
import MaterialsPage from '../pages/academic/MaterialsPage.vue'
import AssignmentsPage from '../pages/academic/AssignmentsPage.vue'
import ReportCardsPage from '../pages/academic/ReportCardsPage.vue'

const routes = [
  { path: '/login', component: LoginPage, meta: { requiresGuest: true } },
  { path: '/forgot-password', component: ForgotPasswordPage, meta: { requiresGuest: true } },
  { path: '/reset-password', component: ResetPasswordPage, meta: { requiresGuest: true } },
  {
    path: '/portal',
    component: PortalLayout,
    meta: { requiresAuth: true, portalOnly: true },
    children: [
      { path: '', component: PortalHomePage },
      { path: 'jadwal', component: PortalSchedulePage },
      { path: 'nilai', component: PortalNilaiPage },
      { path: 'tagihan', component: PortalBillingPage },
      { path: 'profil', component: PortalProfilePage },
    ],
  },
  {
    path: '/',
    component: AppLayout,
    meta: { requiresAuth: true },
    children: [
      { path: '', redirect: '/dashboard' },
      { path: 'dashboard', component: DashboardPage },
      { path: 'users', component: UsersPage, meta: { permission: 'users.view' } },
      { path: 'roles', component: RolesPage, meta: { permission: 'roles.view' } },
      {
        path: 'permission-groups',
        component: CrudPage,
        props: {
          permissionPrefix: 'permission-groups',
          title: 'Permission Groups',
          endpoint: 'permission-groups',
          fields: [
            { name: 'name', label: 'Nama' },
            { name: 'slug', label: 'Slug' },
            { name: 'description', label: 'Deskripsi', type: 'textarea', required: false },
          ],
          columns: [
            { title: 'Nama', dataIndex: 'name', key: 'name' },
            { title: 'Slug', dataIndex: 'slug', key: 'slug' },
            { title: 'Deskripsi', dataIndex: 'description', key: 'description' },
            { title: 'Aksi', key: 'action' },
          ],
        },
        meta: { permission: 'permission-groups.view' },
      },
      { path: 'permissions', component: PermissionManagementPage, meta: { permission: 'permissions.view' } },
      { path: 'menus', component: MenuManagementPage, meta: { permission: 'menus.view' } },
      { path: 'app-settings', component: AppSettingsPage, meta: { permission: 'app-settings.view' } },
      { path: 'blamable-logs', component: BlamableLogsPage, meta: { permission: 'blamable-logs.view' } },
      {
        path: 'programs',
        component: CrudPage,
        props: {
          permissionPrefix: 'programs',
          title: 'Programs',
          endpoint: 'programs',
          fields: [
            { name: 'name', label: 'Nama', required: true },
            { name: 'description', label: 'Deskripsi', type: 'textarea', required: false },
            { name: 'fee', label: 'Biaya (Rp)', type: 'number', required: false },
            { name: 'registration_fee', label: 'Biaya Pendaftaran (Rp)', type: 'number', required: false },
            { name: 'is_active', label: 'Aktif', type: 'switch', required: false },
          ],
          columns: [
            { title: 'Nama', dataIndex: 'name', key: 'name' },
            { title: 'Biaya', dataIndex: 'fee', key: 'fee' },
            { title: 'Aksi', key: 'action' },
          ],
        },
        meta: { permission: 'programs.view' },
      },
      {
        path: 'subjects',
        component: CrudPage,
        props: {
          permissionPrefix: 'subjects',
          title: 'Subjects',
          endpoint: 'subjects',
          fields: [
            { name: 'name', label: 'Nama', required: true },
            { name: 'code', label: 'Kode', required: false },
            { name: 'description', label: 'Deskripsi', type: 'textarea', required: false },
          ],
          columns: [
            { title: 'Nama', dataIndex: 'name', key: 'name' },
            { title: 'Kode', dataIndex: 'code', key: 'code' },
            { title: 'Aksi', key: 'action' },
          ],
        },
        meta: { permission: 'subjects.view' },
      },
      {
        path: 'rooms',
        component: CrudPage,
        props: {
          permissionPrefix: 'rooms',
          title: 'Rooms',
          endpoint: 'rooms',
          fields: [
            { name: 'name', label: 'Nama', required: true },
            { name: 'capacity', label: 'Kapasitas', type: 'number', required: false },
            { name: 'location', label: 'Lokasi', required: false },
          ],
          columns: [
            { title: 'Nama', dataIndex: 'name', key: 'name' },
            { title: 'Kapasitas', dataIndex: 'capacity', key: 'capacity' },
            { title: 'Lokasi', dataIndex: 'location', key: 'location' },
            { title: 'Aksi', key: 'action' },
          ],
        },
        meta: { permission: 'rooms.view' },
      },
      { path: 'students', component: StudentsPage, meta: { permission: 'students.view' } },
      { path: 'parents', component: ParentsPage, meta: { permission: 'parents.view' } },
      { path: 'tutors', component: TutorsPage, meta: { permission: 'tutors.view' } },
      { path: 'classes', component: ClassesPage, meta: { permission: 'classes.view' } },
      { path: 'enrollments', component: EnrollmentsPage, meta: { permission: 'enrollments.view' } },
      { path: 'schedules', component: SchedulesPage, meta: { permission: 'schedules.view' } },
      { path: 'sessions', component: SessionsPage, meta: { permission: 'sessions.view' } },
      { path: 'invoices', component: InvoicesPage, meta: { permission: 'invoices.view' } },
      { path: 'payments', component: PaymentsPage, meta: { permission: 'payments.view' } },
      { path: 'payrolls', component: PayrollsPage, meta: { permission: 'payrolls.view' } },
      { path: 'tutor-recaps', component: TutorRecapsPage, meta: { permission: 'payrolls.view' } },
      {
        path: 'notification-templates',
        component: CrudPage,
        props: {
          permissionPrefix: 'notification-templates',
          title: 'Template Pesan',
          endpoint: 'notification-templates',
          fields: [
            { name: 'key', label: 'Kode', required: true },
            { name: 'name', label: 'Nama', required: true },
            { name: 'body', label: 'Isi (gunakan {nama}, {siswa}, {kelas}, {tanggal}, {nominal}, {invoice}, {jam}, {status}, {sisa}, {jatuh_tempo})', type: 'textarea', required: true },
            { name: 'is_active', label: 'Aktif', type: 'switch', required: false },
          ],
          columns: [
            { title: 'Kode', dataIndex: 'key', key: 'key' },
            { title: 'Nama', dataIndex: 'name', key: 'name' },
            { title: 'Aksi', key: 'action' },
          ],
        },
        meta: { permission: 'notification-templates.view' },
      },
      { path: 'notifications', component: NotificationsPage, meta: { permission: 'notifications.view' } },
      { path: 'assessments', component: AssessmentsPage, meta: { permission: 'assessments.view' } },
      { path: 'materials', component: MaterialsPage, meta: { permission: 'materials.view' } },
      { path: 'assignments', component: AssignmentsPage, meta: { permission: 'assignments.view' } },
      { path: 'report-cards', component: ReportCardsPage, meta: { permission: 'report-cards.view' } },
    ],
  },
]

const router = createRouter({ history: createWebHistory(), routes, scrollBehavior: (to, from, savedPosition) => savedPosition || { top: 0 } })

router.beforeEach(async (to) => {
  const authStore = useAuthStore()
  if (authStore.loading) {
    await authStore.refreshMe()
    authStore.loading = false
  }
  if (to.meta.requiresAuth && !authStore.user) return '/login'
  if (to.meta.requiresGuest && authStore.user) return authStore.homePath
  // Pengguna portal (siswa/orang tua) memakai layout bawah, bukan sidebar.
  if (to.meta.portalOnly && !authStore.isPortalUser) return '/dashboard'
  if (to.path === '/dashboard' && authStore.isPortalUser) return '/portal'
  if (to.meta.permission && !authStore.can(to.meta.permission)) return authStore.homePath
})

export default router
