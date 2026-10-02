/*
 Navicat Premium Dump SQL

 Source Server         : Laragon SQL
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30)
 Source Host           : localhost:3306
 Source Schema         : gamma_one

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30)
 File Encoding         : 65001

 Date: 01/10/2026 10:22:54
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for app_settings
-- ----------------------------
DROP TABLE IF EXISTS `app_settings`;
CREATE TABLE `app_settings`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `app_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SIMRS',
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sidebar_logo_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `login_logo_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `favicon_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `app_settings_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `app_settings_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `app_settings_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `app_settings_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `app_settings_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `app_settings_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of app_settings
-- ----------------------------
INSERT INTO `app_settings` VALUES (1, NULL, 1, NULL, 'Gamma One', 'Gamma One', 'http://localhost:8000/storage/uploads/qTHGEd5LWo4m8Yd8QPH6bcJo2yyZXQWIHPCKOnjN.png', 'http://localhost:8000/storage/uploads/T6IXxDsomxTRc5i1txskZ3u5MhzrwWizvRcHeXTG.png', 'http://localhost:8000/storage/uploads/QBdRgMKKV3TCwdaxc6rF7jOYZQFYDIRikNoHgJgL.png', '2026-09-29 07:21:07', '2026-09-29 08:23:00', NULL);

-- ----------------------------
-- Table structure for assessments
-- ----------------------------
DROP TABLE IF EXISTS `assessments`;
CREATE TABLE `assessments`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `school_class_id` bigint UNSIGNED NOT NULL,
  `subject_id` bigint UNSIGNED NULL DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ulangan',
  `assessment_date` date NULL DEFAULT NULL,
  `max_score` decimal(5, 2) NOT NULL DEFAULT 100.00,
  `weight` decimal(5, 2) NOT NULL DEFAULT 1.00,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `assessments_subject_id_foreign`(`subject_id` ASC) USING BTREE,
  INDEX `assessments_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `assessments_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `assessments_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  INDEX `assessments_school_class_id_index`(`school_class_id` ASC) USING BTREE,
  CONSTRAINT `assessments_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `assessments_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `assessments_school_class_id_foreign` FOREIGN KEY (`school_class_id`) REFERENCES `school_classes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `assessments_subject_id_foreign` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `assessments_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of assessments
-- ----------------------------
INSERT INTO `assessments` VALUES (1, 1, 1, 'Ulangan Harian 1', 'ulangan', '2026-09-05', 100.00, 1.00, NULL, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18', NULL);
INSERT INTO `assessments` VALUES (2, 1, 1, 'Tryout 1', 'tryout', '2026-09-12', 100.00, 1.00, NULL, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18', NULL);

-- ----------------------------
-- Table structure for assignments
-- ----------------------------
DROP TABLE IF EXISTS `assignments`;
CREATE TABLE `assignments`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `school_class_id` bigint UNSIGNED NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `deadline` datetime NULL DEFAULT NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `assignments_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `assignments_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `assignments_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  INDEX `assignments_school_class_id_index`(`school_class_id` ASC) USING BTREE,
  CONSTRAINT `assignments_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `assignments_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `assignments_school_class_id_foreign` FOREIGN KEY (`school_class_id`) REFERENCES `school_classes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `assignments_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of assignments
-- ----------------------------
INSERT INTO `assignments` VALUES (1, 1, 'Latihan Soal 1', 'Kerjakan dan unggah hasilnya.', '2026-10-06 07:21:18', NULL, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18', NULL);
INSERT INTO `assignments` VALUES (2, 4, 'English Camp', NULL, '2026-09-30 08:04:59', 1, 1, NULL, '2026-09-29 08:05:10', '2026-09-29 08:05:10', NULL);
INSERT INTO `assignments` VALUES (3, 1, 'Latihan soal 2', 'kerjakan dengan teliti', '2026-09-30 16:00:00', 7, 7, NULL, '2026-09-30 07:39:41', '2026-09-30 07:39:41', NULL);

-- ----------------------------
-- Table structure for attendances
-- ----------------------------
DROP TABLE IF EXISTS `attendances`;
CREATE TABLE `attendances`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `session_id` bigint UNSIGNED NOT NULL,
  `student_id` bigint UNSIGNED NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'hadir',
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `marked_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `attendances_session_id_student_id_unique`(`session_id` ASC, `student_id` ASC) USING BTREE,
  INDEX `attendances_marked_by_foreign`(`marked_by` ASC) USING BTREE,
  INDEX `attendances_student_id_index`(`student_id` ASC) USING BTREE,
  CONSTRAINT `attendances_marked_by_foreign` FOREIGN KEY (`marked_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `attendances_session_id_foreign` FOREIGN KEY (`session_id`) REFERENCES `class_sessions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `attendances_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of attendances
-- ----------------------------
INSERT INTO `attendances` VALUES (1, 1, 2, 'hadir', NULL, 42, '2026-09-30 07:36:21', '2026-09-30 14:40:37');
INSERT INTO `attendances` VALUES (2, 1, 1, 'hadir', NULL, 42, '2026-09-30 14:40:37', '2026-09-30 14:40:37');
INSERT INTO `attendances` VALUES (3, 1, 3, 'hadir', NULL, 42, '2026-09-30 14:40:37', '2026-09-30 14:40:37');
INSERT INTO `attendances` VALUES (4, 1, 4, 'hadir', NULL, 42, '2026-09-30 14:40:37', '2026-09-30 14:40:37');
INSERT INTO `attendances` VALUES (5, 1, 5, 'hadir', NULL, 42, '2026-09-30 14:40:38', '2026-09-30 14:40:38');
INSERT INTO `attendances` VALUES (6, 1, 6, 'hadir', NULL, 42, '2026-09-30 14:40:38', '2026-09-30 14:40:38');
INSERT INTO `attendances` VALUES (7, 1, 7, 'hadir', NULL, 42, '2026-09-30 14:40:38', '2026-09-30 14:40:38');
INSERT INTO `attendances` VALUES (8, 1, 8, 'hadir', NULL, 42, '2026-09-30 14:40:38', '2026-09-30 14:40:38');

-- ----------------------------
-- Table structure for blamable_logs
-- ----------------------------
DROP TABLE IF EXISTS `blamable_logs`;
CREATE TABLE `blamable_logs`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL,
  `model_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `old_values` json NULL,
  `new_values` json NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `blamable_logs_user_id_foreign`(`user_id` ASC) USING BTREE,
  INDEX `blamable_logs_model_type_model_id_index`(`model_type` ASC, `model_id` ASC) USING BTREE,
  INDEX `blamable_logs_action_index`(`action` ASC) USING BTREE,
  INDEX `blamable_logs_created_at_index`(`created_at` ASC) USING BTREE,
  CONSTRAINT `blamable_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 195 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of blamable_logs
-- ----------------------------
INSERT INTO `blamable_logs` VALUES (1, NULL, 'App\\Models\\PermissionGroup', '1', 'created', NULL, '{\"id\": 1, \"name\": \"Manajemen Pengguna\", \"slug\": \"user-management\", \"created_at\": \"2026-09-29 07:21:04\", \"updated_at\": \"2026-09-29 07:21:04\"}', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `blamable_logs` VALUES (2, NULL, 'App\\Models\\PermissionGroup', '2', 'created', NULL, '{\"id\": 2, \"name\": \"Peran & Izin\", \"slug\": \"role-permission\", \"created_at\": \"2026-09-29 07:21:04\", \"updated_at\": \"2026-09-29 07:21:04\"}', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `blamable_logs` VALUES (3, NULL, 'App\\Models\\PermissionGroup', '3', 'created', NULL, '{\"id\": 3, \"name\": \"Sistem\", \"slug\": \"system\", \"created_at\": \"2026-09-29 07:21:04\", \"updated_at\": \"2026-09-29 07:21:04\"}', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `blamable_logs` VALUES (4, NULL, 'App\\Models\\PermissionGroup', '4', 'created', NULL, '{\"id\": 4, \"name\": \"Data Master\", \"slug\": \"master-data\", \"created_at\": \"2026-09-29 07:21:04\", \"updated_at\": \"2026-09-29 07:21:04\"}', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `blamable_logs` VALUES (5, NULL, 'App\\Models\\PermissionGroup', '5', 'created', NULL, '{\"id\": 5, \"name\": \"Penjadwalan & Absensi\", \"slug\": \"scheduling\", \"created_at\": \"2026-09-29 07:21:04\", \"updated_at\": \"2026-09-29 07:21:04\"}', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `blamable_logs` VALUES (6, NULL, 'App\\Models\\PermissionGroup', '6', 'created', NULL, '{\"id\": 6, \"name\": \"Keuangan\", \"slug\": \"finance\", \"created_at\": \"2026-09-29 07:21:04\", \"updated_at\": \"2026-09-29 07:21:04\"}', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `blamable_logs` VALUES (7, NULL, 'App\\Models\\PermissionGroup', '7', 'created', NULL, '{\"id\": 7, \"name\": \"Notifikasi\", \"slug\": \"notification\", \"created_at\": \"2026-09-29 07:21:04\", \"updated_at\": \"2026-09-29 07:21:04\"}', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `blamable_logs` VALUES (8, NULL, 'App\\Models\\PermissionGroup', '8', 'created', NULL, '{\"id\": 8, \"name\": \"Akademik\", \"slug\": \"academic\", \"created_at\": \"2026-09-29 07:21:04\", \"updated_at\": \"2026-09-29 07:21:04\"}', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `blamable_logs` VALUES (9, NULL, 'App\\Models\\User', '1', 'created', NULL, '{\"id\": 1, \"name\": \"Super Admin\", \"email\": \"admin@dev.local\", \"phone\": \"628110000001\", \"created_at\": \"2026-09-29 07:21:05\", \"updated_at\": \"2026-09-29 07:21:05\"}', '2026-09-29 07:21:05', '2026-09-29 07:21:05');
INSERT INTO `blamable_logs` VALUES (10, NULL, 'App\\Models\\User', '2', 'created', NULL, '{\"id\": 2, \"name\": \"Admin Contoh\", \"email\": \"admin.contoh@dev.local\", \"phone\": \"628110000002\", \"created_at\": \"2026-09-29 07:21:06\", \"updated_at\": \"2026-09-29 07:21:06\"}', '2026-09-29 07:21:06', '2026-09-29 07:21:06');
INSERT INTO `blamable_logs` VALUES (11, NULL, 'App\\Models\\User', '3', 'created', NULL, '{\"id\": 3, \"name\": \"Staf Contoh\", \"email\": \"staf@dev.local\", \"phone\": \"628120000003\", \"created_at\": \"2026-09-29 07:21:06\", \"updated_at\": \"2026-09-29 07:21:06\"}', '2026-09-29 07:21:06', '2026-09-29 07:21:06');
INSERT INTO `blamable_logs` VALUES (12, NULL, 'App\\Models\\User', '4', 'created', NULL, '{\"id\": 4, \"name\": \"Tutor Contoh\", \"email\": \"tutor@dev.local\", \"phone\": \"628130000004\", \"created_at\": \"2026-09-29 07:21:06\", \"updated_at\": \"2026-09-29 07:21:06\"}', '2026-09-29 07:21:06', '2026-09-29 07:21:06');
INSERT INTO `blamable_logs` VALUES (13, NULL, 'App\\Models\\User', '5', 'created', NULL, '{\"id\": 5, \"name\": \"Siswa Contoh\", \"email\": \"siswa@dev.local\", \"phone\": \"628140000005\", \"created_at\": \"2026-09-29 07:21:06\", \"updated_at\": \"2026-09-29 07:21:06\"}', '2026-09-29 07:21:06', '2026-09-29 07:21:06');
INSERT INTO `blamable_logs` VALUES (14, NULL, 'App\\Models\\User', '6', 'created', NULL, '{\"id\": 6, \"name\": \"Orang Tua Contoh\", \"email\": \"orangtua@dev.local\", \"phone\": \"628150000006\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (15, NULL, 'App\\Models\\Menu', '1', 'created', NULL, '{\"id\": 1, \"icon\": \"SettingOutlined\", \"name\": \"Pengaturan\", \"path\": null, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 99, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": null}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (16, NULL, 'App\\Models\\Menu', '2', 'created', NULL, '{\"id\": 2, \"icon\": \"DashboardOutlined\", \"name\": \"Dashboard\", \"path\": \"/dashboard\", \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 1, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": null}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (17, NULL, 'App\\Models\\Menu', '3', 'created', NULL, '{\"id\": 3, \"icon\": \"TeamOutlined\", \"name\": \"Users\", \"path\": \"/users\", \"parent_id\": 1, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 1, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"users.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (18, NULL, 'App\\Models\\Menu', '4', 'created', NULL, '{\"id\": 4, \"icon\": \"SafetyCertificateOutlined\", \"name\": \"Roles\", \"path\": \"/roles\", \"parent_id\": 1, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 2, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"roles.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (19, NULL, 'App\\Models\\Menu', '5', 'created', NULL, '{\"id\": 5, \"icon\": \"AppstoreOutlined\", \"name\": \"Permission Groups\", \"path\": \"/permission-groups\", \"parent_id\": 1, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 3, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"permission-groups.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (20, NULL, 'App\\Models\\Menu', '6', 'created', NULL, '{\"id\": 6, \"icon\": \"LockOutlined\", \"name\": \"Permissions\", \"path\": \"/permissions\", \"parent_id\": 1, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 4, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"permissions.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (21, NULL, 'App\\Models\\Menu', '7', 'created', NULL, '{\"id\": 7, \"icon\": \"MenuOutlined\", \"name\": \"Menus\", \"path\": \"/menus\", \"parent_id\": 1, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 5, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"menus.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (22, NULL, 'App\\Models\\Menu', '8', 'created', NULL, '{\"id\": 8, \"icon\": \"ApartmentOutlined\", \"name\": \"Aplikasi\", \"path\": \"/app-settings\", \"parent_id\": 1, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 6, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"app-settings.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (23, NULL, 'App\\Models\\Menu', '9', 'created', NULL, '{\"id\": 9, \"icon\": \"HistoryOutlined\", \"name\": \"Audit Log\", \"path\": \"/blamable-logs\", \"parent_id\": 1, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 7, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"blamable-logs.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (24, NULL, 'App\\Models\\Menu', '10', 'created', NULL, '{\"id\": 10, \"icon\": \"BookOutlined\", \"name\": \"Data Master\", \"path\": null, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 10, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": null}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (25, NULL, 'App\\Models\\Menu', '11', 'created', NULL, '{\"id\": 11, \"icon\": \"AppstoreAddOutlined\", \"name\": \"Programs\", \"path\": \"/programs\", \"parent_id\": 10, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 1, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"programs.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (26, NULL, 'App\\Models\\Menu', '12', 'created', NULL, '{\"id\": 12, \"icon\": \"ReadOutlined\", \"name\": \"Subjects\", \"path\": \"/subjects\", \"parent_id\": 10, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 2, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"subjects.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (27, NULL, 'App\\Models\\Menu', '13', 'created', NULL, '{\"id\": 13, \"icon\": \"HomeOutlined\", \"name\": \"Rooms\", \"path\": \"/rooms\", \"parent_id\": 10, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 3, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"rooms.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (28, NULL, 'App\\Models\\Menu', '14', 'created', NULL, '{\"id\": 14, \"icon\": \"TeamOutlined\", \"name\": \"Classes\", \"path\": \"/classes\", \"parent_id\": 10, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 4, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"classes.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (29, NULL, 'App\\Models\\Menu', '15', 'created', NULL, '{\"id\": 15, \"icon\": \"UserOutlined\", \"name\": \"Students\", \"path\": \"/students\", \"parent_id\": 10, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 5, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"students.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (30, NULL, 'App\\Models\\Menu', '16', 'created', NULL, '{\"id\": 16, \"icon\": \"HeartOutlined\", \"name\": \"Parents\", \"path\": \"/parents\", \"parent_id\": 10, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 6, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"parents.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (31, NULL, 'App\\Models\\Menu', '17', 'created', NULL, '{\"id\": 17, \"icon\": \"SolutionOutlined\", \"name\": \"Tutors\", \"path\": \"/tutors\", \"parent_id\": 10, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 7, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"tutors.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (32, NULL, 'App\\Models\\Menu', '18', 'created', NULL, '{\"id\": 18, \"icon\": \"FormOutlined\", \"name\": \"Enrollments\", \"path\": \"/enrollments\", \"parent_id\": 10, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 8, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"enrollments.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (33, NULL, 'App\\Models\\Menu', '19', 'created', NULL, '{\"id\": 19, \"icon\": \"CalendarOutlined\", \"name\": \"Penjadwalan\", \"path\": null, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 11, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": null}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (34, NULL, 'App\\Models\\Menu', '20', 'created', NULL, '{\"id\": 20, \"icon\": \"ClockCircleOutlined\", \"name\": \"Jadwal\", \"path\": \"/schedules\", \"parent_id\": 19, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 1, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"schedules.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (35, NULL, 'App\\Models\\Menu', '21', 'created', NULL, '{\"id\": 21, \"icon\": \"CheckSquareOutlined\", \"name\": \"Sesi & Absensi\", \"path\": \"/sessions\", \"parent_id\": 19, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 2, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"sessions.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (36, NULL, 'App\\Models\\Menu', '22', 'created', NULL, '{\"id\": 22, \"icon\": \"WalletOutlined\", \"name\": \"Keuangan\", \"path\": null, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 12, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": null}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (37, NULL, 'App\\Models\\Menu', '23', 'created', NULL, '{\"id\": 23, \"icon\": \"FileTextOutlined\", \"name\": \"Invoices\", \"path\": \"/invoices\", \"parent_id\": 22, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 1, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"invoices.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (38, NULL, 'App\\Models\\Menu', '24', 'created', NULL, '{\"id\": 24, \"icon\": \"DollarOutlined\", \"name\": \"Pembayaran\", \"path\": \"/payments\", \"parent_id\": 22, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 2, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"payments.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (39, NULL, 'App\\Models\\Menu', '25', 'created', NULL, '{\"id\": 25, \"icon\": \"BankOutlined\", \"name\": \"Gaji Tutor\", \"path\": \"/payrolls\", \"parent_id\": 22, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 3, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"payrolls.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (40, NULL, 'App\\Models\\Menu', '26', 'created', NULL, '{\"id\": 26, \"icon\": \"BellOutlined\", \"name\": \"Notifikasi\", \"path\": null, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 13, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": null}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (41, NULL, 'App\\Models\\Menu', '27', 'created', NULL, '{\"id\": 27, \"icon\": \"MessageOutlined\", \"name\": \"Template Pesan\", \"path\": \"/notification-templates\", \"parent_id\": 26, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 1, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"notification-templates.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (42, NULL, 'App\\Models\\Menu', '28', 'created', NULL, '{\"id\": 28, \"icon\": \"HistoryOutlined\", \"name\": \"Log Notifikasi\", \"path\": \"/notifications\", \"parent_id\": 26, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 2, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"notifications.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (43, NULL, 'App\\Models\\Menu', '29', 'created', NULL, '{\"id\": 29, \"icon\": \"TrophyOutlined\", \"name\": \"Akademik\", \"path\": null, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 14, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": null}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (44, NULL, 'App\\Models\\Menu', '30', 'created', NULL, '{\"id\": 30, \"icon\": \"EditOutlined\", \"name\": \"Asesmen & Nilai\", \"path\": \"/assessments\", \"parent_id\": 29, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 1, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"assessments.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (45, NULL, 'App\\Models\\Menu', '31', 'created', NULL, '{\"id\": 31, \"icon\": \"ReadOutlined\", \"name\": \"Materi\", \"path\": \"/materials\", \"parent_id\": 29, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 2, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"materials.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (46, NULL, 'App\\Models\\Menu', '32', 'created', NULL, '{\"id\": 32, \"icon\": \"FormOutlined\", \"name\": \"Tugas\", \"path\": \"/assignments\", \"parent_id\": 29, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 3, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"assignments.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (47, NULL, 'App\\Models\\Menu', '33', 'created', NULL, '{\"id\": 33, \"icon\": \"FileTextOutlined\", \"name\": \"Rapor\", \"path\": \"/report-cards\", \"parent_id\": 29, \"created_at\": \"2026-09-29 07:21:07\", \"sort_order\": 4, \"updated_at\": \"2026-09-29 07:21:07\", \"permission_name\": \"report-cards.view\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (48, NULL, 'App\\Models\\NotificationTemplate', '1', 'created', NULL, '{\"id\": 1, \"key\": \"jadwal_h1\", \"body\": \"Halo {nama},\\nBesok {tanggal} ada jadwal {kelas} pukul {jam} untuk {siswa}.\\n— Gamma One\", \"name\": \"Pengingat jadwal H-1\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (49, NULL, 'App\\Models\\NotificationTemplate', '2', 'created', NULL, '{\"id\": 2, \"key\": \"kehadiran_ortu\", \"body\": \"Halo {nama},\\n{siswa} tercatat {status} pada {kelas} tanggal {tanggal}.\\n— Gamma One\", \"name\": \"Kehadiran ke orang tua\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (50, NULL, 'App\\Models\\NotificationTemplate', '3', 'created', NULL, '{\"id\": 3, \"key\": \"tagihan_baru\", \"body\": \"Halo {nama},\\nTagihan {invoice} untuk {siswa} sebesar Rp{nominal}, jatuh tempo {jatuh_tempo}.\\n— Gamma One\", \"name\": \"Tagihan baru\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (51, NULL, 'App\\Models\\NotificationTemplate', '4', 'created', NULL, '{\"id\": 4, \"key\": \"tagihan_jatuh_tempo\", \"body\": \"Halo {nama},\\nTagihan {invoice} untuk {siswa} sebesar Rp{nominal} telah jatuh tempo. Segera lunasi.\\n— Gamma One\", \"name\": \"Pengingat jatuh tempo\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (52, NULL, 'App\\Models\\NotificationTemplate', '5', 'created', NULL, '{\"id\": 5, \"key\": \"pembayaran_lunas\", \"body\": \"Halo {nama},\\nPembayaran Rp{nominal} untuk {invoice} diterima. Sisa Rp{sisa}.\\n— Gamma One\", \"name\": \"Konfirmasi pembayaran\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (53, NULL, 'App\\Models\\NotificationTemplate', '6', 'created', NULL, '{\"id\": 6, \"key\": \"selamat_datang\", \"body\": \"Halo {nama},\\nSelamat datang di Gamma One — One Step, One Growth.\\n— Gamma One\", \"name\": \"Selamat datang\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (54, NULL, 'App\\Models\\AppSetting', '1', 'created', NULL, '{\"id\": 1, \"app_name\": \"Gamma One\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\", \"favicon_url\": \"/images/logo-gamma-one.svg\", \"company_name\": \"Gamma One\", \"login_logo_url\": \"/images/logo-gamma-one.svg\", \"sidebar_logo_url\": \"/images/logo-gamma-one.svg\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (55, NULL, 'App\\Models\\Program', '1', 'created', NULL, '{\"id\": 1, \"fee\": 350000, \"name\": \"Reguler SMP\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\", \"description\": \"Bimbel reguler jenjang SMP.\", \"registration_fee\": 100000}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (56, NULL, 'App\\Models\\Program', '2', 'created', NULL, '{\"id\": 2, \"fee\": 750000, \"name\": \"Intensif UTBK\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\", \"description\": \"Persiapan UTBK SNBT.\", \"registration_fee\": 150000}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (57, NULL, 'App\\Models\\Program', '3', 'created', NULL, '{\"id\": 3, \"fee\": 500000, \"name\": \"Privat SD\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\", \"description\": \"Les privat jenjang SD.\", \"registration_fee\": 50000}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (58, NULL, 'App\\Models\\Subject', '1', 'created', NULL, '{\"id\": 1, \"name\": \"Matematika\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (59, NULL, 'App\\Models\\Subject', '2', 'created', NULL, '{\"id\": 2, \"name\": \"Fisika\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (60, NULL, 'App\\Models\\Subject', '3', 'created', NULL, '{\"id\": 3, \"name\": \"Kimia\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (61, NULL, 'App\\Models\\Subject', '4', 'created', NULL, '{\"id\": 4, \"name\": \"Biologi\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (62, NULL, 'App\\Models\\Subject', '5', 'created', NULL, '{\"id\": 5, \"name\": \"Bahasa Indonesia\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (63, NULL, 'App\\Models\\Subject', '6', 'created', NULL, '{\"id\": 6, \"name\": \"Bahasa Inggris\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (64, NULL, 'App\\Models\\Room', '1', 'created', NULL, '{\"id\": 1, \"name\": \"Ruang Anggrek\", \"capacity\": 20, \"location\": \"Lantai 1\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (65, NULL, 'App\\Models\\Room', '2', 'created', NULL, '{\"id\": 2, \"name\": \"Ruang Melati\", \"capacity\": 15, \"location\": \"Lantai 1\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (66, NULL, 'App\\Models\\Room', '3', 'created', NULL, '{\"id\": 3, \"name\": \"Ruang Kenanga\", \"capacity\": 10, \"location\": \"Lantai 2\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (67, NULL, 'App\\Models\\Room', '4', 'created', NULL, '{\"id\": 4, \"name\": \"Ruang Cempaka\", \"capacity\": 8, \"location\": \"Lantai 2\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (68, NULL, 'App\\Models\\User', '7', 'created', NULL, '{\"id\": 7, \"name\": \"Dewi Lestari\", \"email\": \"tutor1@contoh.local\", \"phone\": \"628210000011\", \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\"}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (69, NULL, 'App\\Models\\Tutor', '1', 'created', NULL, '{\"id\": 1, \"bio\": \"Tutor contoh fiktif.\", \"name\": \"Dewi Lestari\", \"phone\": \"628210000011\", \"user_id\": 7, \"created_at\": \"2026-09-29 07:21:07\", \"updated_at\": \"2026-09-29 07:21:07\", \"fee_per_session\": 100000}', '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `blamable_logs` VALUES (70, NULL, 'App\\Models\\User', '8', 'created', NULL, '{\"id\": 8, \"name\": \"Budi Santoso\", \"email\": \"tutor2@contoh.local\", \"phone\": \"628210000012\", \"created_at\": \"2026-09-29 07:21:08\", \"updated_at\": \"2026-09-29 07:21:08\"}', '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `blamable_logs` VALUES (71, NULL, 'App\\Models\\Tutor', '2', 'created', NULL, '{\"id\": 2, \"bio\": \"Tutor contoh fiktif.\", \"name\": \"Budi Santoso\", \"phone\": \"628210000012\", \"user_id\": 8, \"created_at\": \"2026-09-29 07:21:08\", \"updated_at\": \"2026-09-29 07:21:08\", \"fee_per_session\": 100000}', '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `blamable_logs` VALUES (72, NULL, 'App\\Models\\User', '9', 'created', NULL, '{\"id\": 9, \"name\": \"Siti Rahayu\", \"email\": \"tutor3@contoh.local\", \"phone\": \"628210000013\", \"created_at\": \"2026-09-29 07:21:08\", \"updated_at\": \"2026-09-29 07:21:08\"}', '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `blamable_logs` VALUES (73, NULL, 'App\\Models\\Tutor', '3', 'created', NULL, '{\"id\": 3, \"bio\": \"Tutor contoh fiktif.\", \"name\": \"Siti Rahayu\", \"phone\": \"628210000013\", \"user_id\": 9, \"created_at\": \"2026-09-29 07:21:08\", \"updated_at\": \"2026-09-29 07:21:08\", \"fee_per_session\": 100000}', '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `blamable_logs` VALUES (74, NULL, 'App\\Models\\User', '10', 'created', NULL, '{\"id\": 10, \"name\": \"Agus Pratama\", \"email\": \"tutor4@contoh.local\", \"phone\": \"628210000014\", \"created_at\": \"2026-09-29 07:21:08\", \"updated_at\": \"2026-09-29 07:21:08\"}', '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `blamable_logs` VALUES (75, NULL, 'App\\Models\\Tutor', '4', 'created', NULL, '{\"id\": 4, \"bio\": \"Tutor contoh fiktif.\", \"name\": \"Agus Pratama\", \"phone\": \"628210000014\", \"user_id\": 10, \"created_at\": \"2026-09-29 07:21:08\", \"updated_at\": \"2026-09-29 07:21:08\", \"fee_per_session\": 100000}', '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `blamable_logs` VALUES (76, NULL, 'App\\Models\\User', '11', 'created', NULL, '{\"id\": 11, \"name\": \"Rina Marlina\", \"email\": \"tutor5@contoh.local\", \"phone\": \"628210000015\", \"created_at\": \"2026-09-29 07:21:08\", \"updated_at\": \"2026-09-29 07:21:08\"}', '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `blamable_logs` VALUES (77, NULL, 'App\\Models\\Tutor', '5', 'created', NULL, '{\"id\": 5, \"bio\": \"Tutor contoh fiktif.\", \"name\": \"Rina Marlina\", \"phone\": \"628210000015\", \"user_id\": 11, \"created_at\": \"2026-09-29 07:21:08\", \"updated_at\": \"2026-09-29 07:21:08\", \"fee_per_session\": 100000}', '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `blamable_logs` VALUES (78, NULL, 'App\\Models\\User', '12', 'created', NULL, '{\"id\": 12, \"name\": \"Andi Wijaya\", \"email\": \"siswa1@contoh.local\", \"phone\": \"628220000011\", \"created_at\": \"2026-09-29 07:21:09\", \"updated_at\": \"2026-09-29 07:21:09\"}', '2026-09-29 07:21:09', '2026-09-29 07:21:09');
INSERT INTO `blamable_logs` VALUES (79, NULL, 'App\\Models\\Student', '1', 'created', NULL, '{\"id\": 1, \"nis\": \"G1001001\", \"name\": \"Andi Wijaya\", \"phone\": \"628220000011\", \"gender\": \"L\", \"school\": \"SMPN 2\", \"status\": \"aktif\", \"user_id\": 12, \"created_at\": \"2026-09-29 07:21:09\", \"updated_at\": \"2026-09-29 07:21:09\"}', '2026-09-29 07:21:09', '2026-09-29 07:21:09');
INSERT INTO `blamable_logs` VALUES (80, NULL, 'App\\Models\\User', '13', 'created', NULL, '{\"id\": 13, \"name\": \"Bella Putri\", \"email\": \"siswa2@contoh.local\", \"phone\": \"628220000012\", \"created_at\": \"2026-09-29 07:21:09\", \"updated_at\": \"2026-09-29 07:21:09\"}', '2026-09-29 07:21:09', '2026-09-29 07:21:09');
INSERT INTO `blamable_logs` VALUES (81, NULL, 'App\\Models\\Student', '2', 'created', NULL, '{\"id\": 2, \"nis\": \"G1001002\", \"name\": \"Bella Putri\", \"phone\": \"628220000012\", \"gender\": \"P\", \"school\": \"SMPN 3\", \"status\": \"aktif\", \"user_id\": 13, \"created_at\": \"2026-09-29 07:21:09\", \"updated_at\": \"2026-09-29 07:21:09\"}', '2026-09-29 07:21:09', '2026-09-29 07:21:09');
INSERT INTO `blamable_logs` VALUES (82, NULL, 'App\\Models\\User', '14', 'created', NULL, '{\"id\": 14, \"name\": \"Candra Gunawan\", \"email\": \"siswa3@contoh.local\", \"phone\": \"628220000013\", \"created_at\": \"2026-09-29 07:21:09\", \"updated_at\": \"2026-09-29 07:21:09\"}', '2026-09-29 07:21:09', '2026-09-29 07:21:09');
INSERT INTO `blamable_logs` VALUES (83, NULL, 'App\\Models\\Student', '3', 'created', NULL, '{\"id\": 3, \"nis\": \"G1001003\", \"name\": \"Candra Gunawan\", \"phone\": \"628220000013\", \"gender\": \"L\", \"school\": \"SMPN 4\", \"status\": \"aktif\", \"user_id\": 14, \"created_at\": \"2026-09-29 07:21:09\", \"updated_at\": \"2026-09-29 07:21:09\"}', '2026-09-29 07:21:09', '2026-09-29 07:21:09');
INSERT INTO `blamable_logs` VALUES (84, NULL, 'App\\Models\\User', '15', 'created', NULL, '{\"id\": 15, \"name\": \"Dinda Safitri\", \"email\": \"siswa4@contoh.local\", \"phone\": \"628220000014\", \"created_at\": \"2026-09-29 07:21:10\", \"updated_at\": \"2026-09-29 07:21:10\"}', '2026-09-29 07:21:10', '2026-09-29 07:21:10');
INSERT INTO `blamable_logs` VALUES (85, NULL, 'App\\Models\\Student', '4', 'created', NULL, '{\"id\": 4, \"nis\": \"G1001004\", \"name\": \"Dinda Safitri\", \"phone\": \"628220000014\", \"gender\": \"P\", \"school\": \"SMPN 5\", \"status\": \"aktif\", \"user_id\": 15, \"created_at\": \"2026-09-29 07:21:10\", \"updated_at\": \"2026-09-29 07:21:10\"}', '2026-09-29 07:21:10', '2026-09-29 07:21:10');
INSERT INTO `blamable_logs` VALUES (86, NULL, 'App\\Models\\User', '16', 'created', NULL, '{\"id\": 16, \"name\": \"Eko Saputra\", \"email\": \"siswa5@contoh.local\", \"phone\": \"628220000015\", \"created_at\": \"2026-09-29 07:21:10\", \"updated_at\": \"2026-09-29 07:21:10\"}', '2026-09-29 07:21:10', '2026-09-29 07:21:10');
INSERT INTO `blamable_logs` VALUES (87, NULL, 'App\\Models\\Student', '5', 'created', NULL, '{\"id\": 5, \"nis\": \"G1001005\", \"name\": \"Eko Saputra\", \"phone\": \"628220000015\", \"gender\": \"L\", \"school\": \"SMPN 1\", \"status\": \"aktif\", \"user_id\": 16, \"created_at\": \"2026-09-29 07:21:10\", \"updated_at\": \"2026-09-29 07:21:10\"}', '2026-09-29 07:21:10', '2026-09-29 07:21:10');
INSERT INTO `blamable_logs` VALUES (88, NULL, 'App\\Models\\User', '17', 'created', NULL, '{\"id\": 17, \"name\": \"Fitri Handayani\", \"email\": \"siswa6@contoh.local\", \"phone\": \"628220000016\", \"created_at\": \"2026-09-29 07:21:10\", \"updated_at\": \"2026-09-29 07:21:10\"}', '2026-09-29 07:21:10', '2026-09-29 07:21:10');
INSERT INTO `blamable_logs` VALUES (89, NULL, 'App\\Models\\Student', '6', 'created', NULL, '{\"id\": 6, \"nis\": \"G1001006\", \"name\": \"Fitri Handayani\", \"phone\": \"628220000016\", \"gender\": \"P\", \"school\": \"SMPN 2\", \"status\": \"aktif\", \"user_id\": 17, \"created_at\": \"2026-09-29 07:21:10\", \"updated_at\": \"2026-09-29 07:21:10\"}', '2026-09-29 07:21:10', '2026-09-29 07:21:10');
INSERT INTO `blamable_logs` VALUES (90, NULL, 'App\\Models\\User', '18', 'created', NULL, '{\"id\": 18, \"name\": \"Gilang Ramadhan\", \"email\": \"siswa7@contoh.local\", \"phone\": \"628220000017\", \"created_at\": \"2026-09-29 07:21:10\", \"updated_at\": \"2026-09-29 07:21:10\"}', '2026-09-29 07:21:10', '2026-09-29 07:21:10');
INSERT INTO `blamable_logs` VALUES (91, NULL, 'App\\Models\\Student', '7', 'created', NULL, '{\"id\": 7, \"nis\": \"G1001007\", \"name\": \"Gilang Ramadhan\", \"phone\": \"628220000017\", \"gender\": \"L\", \"school\": \"SMPN 3\", \"status\": \"aktif\", \"user_id\": 18, \"created_at\": \"2026-09-29 07:21:10\", \"updated_at\": \"2026-09-29 07:21:10\"}', '2026-09-29 07:21:10', '2026-09-29 07:21:10');
INSERT INTO `blamable_logs` VALUES (92, NULL, 'App\\Models\\User', '19', 'created', NULL, '{\"id\": 19, \"name\": \"Hana Kusuma\", \"email\": \"siswa8@contoh.local\", \"phone\": \"628220000018\", \"created_at\": \"2026-09-29 07:21:11\", \"updated_at\": \"2026-09-29 07:21:11\"}', '2026-09-29 07:21:11', '2026-09-29 07:21:11');
INSERT INTO `blamable_logs` VALUES (93, NULL, 'App\\Models\\Student', '8', 'created', NULL, '{\"id\": 8, \"nis\": \"G1001008\", \"name\": \"Hana Kusuma\", \"phone\": \"628220000018\", \"gender\": \"P\", \"school\": \"SMPN 4\", \"status\": \"aktif\", \"user_id\": 19, \"created_at\": \"2026-09-29 07:21:11\", \"updated_at\": \"2026-09-29 07:21:11\"}', '2026-09-29 07:21:11', '2026-09-29 07:21:11');
INSERT INTO `blamable_logs` VALUES (94, NULL, 'App\\Models\\User', '20', 'created', NULL, '{\"id\": 20, \"name\": \"Irfan Maulana\", \"email\": \"siswa9@contoh.local\", \"phone\": \"628220000019\", \"created_at\": \"2026-09-29 07:21:11\", \"updated_at\": \"2026-09-29 07:21:11\"}', '2026-09-29 07:21:11', '2026-09-29 07:21:11');
INSERT INTO `blamable_logs` VALUES (95, NULL, 'App\\Models\\Student', '9', 'created', NULL, '{\"id\": 9, \"nis\": \"G1001009\", \"name\": \"Irfan Maulana\", \"phone\": \"628220000019\", \"gender\": \"L\", \"school\": \"SMPN 5\", \"status\": \"aktif\", \"user_id\": 20, \"created_at\": \"2026-09-29 07:21:11\", \"updated_at\": \"2026-09-29 07:21:11\"}', '2026-09-29 07:21:11', '2026-09-29 07:21:11');
INSERT INTO `blamable_logs` VALUES (96, NULL, 'App\\Models\\User', '21', 'created', NULL, '{\"id\": 21, \"name\": \"Jihan Aulia\", \"email\": \"siswa10@contoh.local\", \"phone\": \"628220000020\", \"created_at\": \"2026-09-29 07:21:11\", \"updated_at\": \"2026-09-29 07:21:11\"}', '2026-09-29 07:21:11', '2026-09-29 07:21:11');
INSERT INTO `blamable_logs` VALUES (97, NULL, 'App\\Models\\Student', '10', 'created', NULL, '{\"id\": 10, \"nis\": \"G1001010\", \"name\": \"Jihan Aulia\", \"phone\": \"628220000020\", \"gender\": \"P\", \"school\": \"SMPN 1\", \"status\": \"aktif\", \"user_id\": 21, \"created_at\": \"2026-09-29 07:21:11\", \"updated_at\": \"2026-09-29 07:21:11\"}', '2026-09-29 07:21:11', '2026-09-29 07:21:11');
INSERT INTO `blamable_logs` VALUES (98, NULL, 'App\\Models\\User', '22', 'created', NULL, '{\"id\": 22, \"name\": \"Kevin Alexander\", \"email\": \"siswa11@contoh.local\", \"phone\": \"628220000021\", \"created_at\": \"2026-09-29 07:21:12\", \"updated_at\": \"2026-09-29 07:21:12\"}', '2026-09-29 07:21:12', '2026-09-29 07:21:12');
INSERT INTO `blamable_logs` VALUES (99, NULL, 'App\\Models\\Student', '11', 'created', NULL, '{\"id\": 11, \"nis\": \"G1001011\", \"name\": \"Kevin Alexander\", \"phone\": \"628220000021\", \"gender\": \"L\", \"school\": \"SMPN 2\", \"status\": \"aktif\", \"user_id\": 22, \"created_at\": \"2026-09-29 07:21:12\", \"updated_at\": \"2026-09-29 07:21:12\"}', '2026-09-29 07:21:12', '2026-09-29 07:21:12');
INSERT INTO `blamable_logs` VALUES (100, NULL, 'App\\Models\\User', '23', 'created', NULL, '{\"id\": 23, \"name\": \"Larasati Dewi\", \"email\": \"siswa12@contoh.local\", \"phone\": \"628220000022\", \"created_at\": \"2026-09-29 07:21:12\", \"updated_at\": \"2026-09-29 07:21:12\"}', '2026-09-29 07:21:12', '2026-09-29 07:21:12');
INSERT INTO `blamable_logs` VALUES (101, NULL, 'App\\Models\\Student', '12', 'created', NULL, '{\"id\": 12, \"nis\": \"G1001012\", \"name\": \"Larasati Dewi\", \"phone\": \"628220000022\", \"gender\": \"P\", \"school\": \"SMPN 3\", \"status\": \"aktif\", \"user_id\": 23, \"created_at\": \"2026-09-29 07:21:12\", \"updated_at\": \"2026-09-29 07:21:12\"}', '2026-09-29 07:21:12', '2026-09-29 07:21:12');
INSERT INTO `blamable_logs` VALUES (102, NULL, 'App\\Models\\User', '24', 'created', NULL, '{\"id\": 24, \"name\": \"M faisal\", \"email\": \"siswa13@contoh.local\", \"phone\": \"628220000023\", \"created_at\": \"2026-09-29 07:21:12\", \"updated_at\": \"2026-09-29 07:21:12\"}', '2026-09-29 07:21:12', '2026-09-29 07:21:12');
INSERT INTO `blamable_logs` VALUES (103, NULL, 'App\\Models\\Student', '13', 'created', NULL, '{\"id\": 13, \"nis\": \"G1001013\", \"name\": \"M faisal\", \"phone\": \"628220000023\", \"gender\": \"L\", \"school\": \"SMPN 4\", \"status\": \"aktif\", \"user_id\": 24, \"created_at\": \"2026-09-29 07:21:12\", \"updated_at\": \"2026-09-29 07:21:12\"}', '2026-09-29 07:21:12', '2026-09-29 07:21:12');
INSERT INTO `blamable_logs` VALUES (104, NULL, 'App\\Models\\User', '25', 'created', NULL, '{\"id\": 25, \"name\": \"Nadia Zahra\", \"email\": \"siswa14@contoh.local\", \"phone\": \"628220000024\", \"created_at\": \"2026-09-29 07:21:12\", \"updated_at\": \"2026-09-29 07:21:12\"}', '2026-09-29 07:21:12', '2026-09-29 07:21:12');
INSERT INTO `blamable_logs` VALUES (105, NULL, 'App\\Models\\Student', '14', 'created', NULL, '{\"id\": 14, \"nis\": \"G1001014\", \"name\": \"Nadia Zahra\", \"phone\": \"628220000024\", \"gender\": \"P\", \"school\": \"SMPN 5\", \"status\": \"aktif\", \"user_id\": 25, \"created_at\": \"2026-09-29 07:21:12\", \"updated_at\": \"2026-09-29 07:21:12\"}', '2026-09-29 07:21:12', '2026-09-29 07:21:12');
INSERT INTO `blamable_logs` VALUES (106, NULL, 'App\\Models\\User', '26', 'created', NULL, '{\"id\": 26, \"name\": \"Oscar Mahendra\", \"email\": \"siswa15@contoh.local\", \"phone\": \"628220000025\", \"created_at\": \"2026-09-29 07:21:13\", \"updated_at\": \"2026-09-29 07:21:13\"}', '2026-09-29 07:21:13', '2026-09-29 07:21:13');
INSERT INTO `blamable_logs` VALUES (107, NULL, 'App\\Models\\Student', '15', 'created', NULL, '{\"id\": 15, \"nis\": \"G1001015\", \"name\": \"Oscar Mahendra\", \"phone\": \"628220000025\", \"gender\": \"L\", \"school\": \"SMPN 1\", \"status\": \"aktif\", \"user_id\": 26, \"created_at\": \"2026-09-29 07:21:13\", \"updated_at\": \"2026-09-29 07:21:13\"}', '2026-09-29 07:21:13', '2026-09-29 07:21:13');
INSERT INTO `blamable_logs` VALUES (108, NULL, 'App\\Models\\User', '27', 'created', NULL, '{\"id\": 27, \"name\": \"Putri Ayu\", \"email\": \"siswa16@contoh.local\", \"phone\": \"628220000026\", \"created_at\": \"2026-09-29 07:21:13\", \"updated_at\": \"2026-09-29 07:21:13\"}', '2026-09-29 07:21:13', '2026-09-29 07:21:13');
INSERT INTO `blamable_logs` VALUES (109, NULL, 'App\\Models\\Student', '16', 'created', NULL, '{\"id\": 16, \"nis\": \"G1001016\", \"name\": \"Putri Ayu\", \"phone\": \"628220000026\", \"gender\": \"P\", \"school\": \"SMPN 2\", \"status\": \"aktif\", \"user_id\": 27, \"created_at\": \"2026-09-29 07:21:13\", \"updated_at\": \"2026-09-29 07:21:13\"}', '2026-09-29 07:21:13', '2026-09-29 07:21:13');
INSERT INTO `blamable_logs` VALUES (110, NULL, 'App\\Models\\User', '28', 'created', NULL, '{\"id\": 28, \"name\": \"Rizky Febian\", \"email\": \"siswa17@contoh.local\", \"phone\": \"628220000027\", \"created_at\": \"2026-09-29 07:21:13\", \"updated_at\": \"2026-09-29 07:21:13\"}', '2026-09-29 07:21:13', '2026-09-29 07:21:13');
INSERT INTO `blamable_logs` VALUES (111, NULL, 'App\\Models\\Student', '17', 'created', NULL, '{\"id\": 17, \"nis\": \"G1001017\", \"name\": \"Rizky Febian\", \"phone\": \"628220000027\", \"gender\": \"L\", \"school\": \"SMPN 3\", \"status\": \"aktif\", \"user_id\": 28, \"created_at\": \"2026-09-29 07:21:13\", \"updated_at\": \"2026-09-29 07:21:13\"}', '2026-09-29 07:21:13', '2026-09-29 07:21:13');
INSERT INTO `blamable_logs` VALUES (112, NULL, 'App\\Models\\User', '29', 'created', NULL, '{\"id\": 29, \"name\": \"Sarah Amelia\", \"email\": \"siswa18@contoh.local\", \"phone\": \"628220000028\", \"created_at\": \"2026-09-29 07:21:14\", \"updated_at\": \"2026-09-29 07:21:14\"}', '2026-09-29 07:21:14', '2026-09-29 07:21:14');
INSERT INTO `blamable_logs` VALUES (113, NULL, 'App\\Models\\Student', '18', 'created', NULL, '{\"id\": 18, \"nis\": \"G1001018\", \"name\": \"Sarah Amelia\", \"phone\": \"628220000028\", \"gender\": \"P\", \"school\": \"SMPN 4\", \"status\": \"aktif\", \"user_id\": 29, \"created_at\": \"2026-09-29 07:21:14\", \"updated_at\": \"2026-09-29 07:21:14\"}', '2026-09-29 07:21:14', '2026-09-29 07:21:14');
INSERT INTO `blamable_logs` VALUES (114, NULL, 'App\\Models\\User', '30', 'created', NULL, '{\"id\": 30, \"name\": \"Taufik Hidayat\", \"email\": \"siswa19@contoh.local\", \"phone\": \"628220000029\", \"created_at\": \"2026-09-29 07:21:14\", \"updated_at\": \"2026-09-29 07:21:14\"}', '2026-09-29 07:21:14', '2026-09-29 07:21:14');
INSERT INTO `blamable_logs` VALUES (115, NULL, 'App\\Models\\Student', '19', 'created', NULL, '{\"id\": 19, \"nis\": \"G1001019\", \"name\": \"Taufik Hidayat\", \"phone\": \"628220000029\", \"gender\": \"L\", \"school\": \"SMPN 5\", \"status\": \"aktif\", \"user_id\": 30, \"created_at\": \"2026-09-29 07:21:14\", \"updated_at\": \"2026-09-29 07:21:14\"}', '2026-09-29 07:21:14', '2026-09-29 07:21:14');
INSERT INTO `blamable_logs` VALUES (116, NULL, 'App\\Models\\User', '31', 'created', NULL, '{\"id\": 31, \"name\": \"Umi Kalsum\", \"email\": \"siswa20@contoh.local\", \"phone\": \"628220000030\", \"created_at\": \"2026-09-29 07:21:14\", \"updated_at\": \"2026-09-29 07:21:14\"}', '2026-09-29 07:21:14', '2026-09-29 07:21:14');
INSERT INTO `blamable_logs` VALUES (117, NULL, 'App\\Models\\Student', '20', 'created', NULL, '{\"id\": 20, \"nis\": \"G1001020\", \"name\": \"Umi Kalsum\", \"phone\": \"628220000030\", \"gender\": \"P\", \"school\": \"SMPN 1\", \"status\": \"aktif\", \"user_id\": 31, \"created_at\": \"2026-09-29 07:21:14\", \"updated_at\": \"2026-09-29 07:21:14\"}', '2026-09-29 07:21:14', '2026-09-29 07:21:14');
INSERT INTO `blamable_logs` VALUES (118, NULL, 'App\\Models\\User', '32', 'created', NULL, '{\"id\": 32, \"name\": \"Hendra Wijaya\", \"email\": \"ortu1@contoh.local\", \"phone\": \"628230000011\", \"created_at\": \"2026-09-29 07:21:15\", \"updated_at\": \"2026-09-29 07:21:15\"}', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `blamable_logs` VALUES (119, NULL, 'App\\Models\\Guardian', '1', 'created', NULL, '{\"id\": 1, \"name\": \"Hendra Wijaya\", \"phone\": \"628230000011\", \"user_id\": 32, \"created_at\": \"2026-09-29 07:21:15\", \"updated_at\": \"2026-09-29 07:21:15\"}', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `blamable_logs` VALUES (120, NULL, 'App\\Models\\User', '33', 'created', NULL, '{\"id\": 33, \"name\": \"Ratna Sari\", \"email\": \"ortu2@contoh.local\", \"phone\": \"628230000012\", \"created_at\": \"2026-09-29 07:21:15\", \"updated_at\": \"2026-09-29 07:21:15\"}', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `blamable_logs` VALUES (121, NULL, 'App\\Models\\Guardian', '2', 'created', NULL, '{\"id\": 2, \"name\": \"Ratna Sari\", \"phone\": \"628230000012\", \"user_id\": 33, \"created_at\": \"2026-09-29 07:21:15\", \"updated_at\": \"2026-09-29 07:21:15\"}', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `blamable_logs` VALUES (122, NULL, 'App\\Models\\User', '34', 'created', NULL, '{\"id\": 34, \"name\": \"Joko Susilo\", \"email\": \"ortu3@contoh.local\", \"phone\": \"628230000013\", \"created_at\": \"2026-09-29 07:21:15\", \"updated_at\": \"2026-09-29 07:21:15\"}', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `blamable_logs` VALUES (123, NULL, 'App\\Models\\Guardian', '3', 'created', NULL, '{\"id\": 3, \"name\": \"Joko Susilo\", \"phone\": \"628230000013\", \"user_id\": 34, \"created_at\": \"2026-09-29 07:21:15\", \"updated_at\": \"2026-09-29 07:21:15\"}', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `blamable_logs` VALUES (124, NULL, 'App\\Models\\User', '35', 'created', NULL, '{\"id\": 35, \"name\": \"Mega Wati\", \"email\": \"ortu4@contoh.local\", \"phone\": \"628230000014\", \"created_at\": \"2026-09-29 07:21:15\", \"updated_at\": \"2026-09-29 07:21:15\"}', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `blamable_logs` VALUES (125, NULL, 'App\\Models\\Guardian', '4', 'created', NULL, '{\"id\": 4, \"name\": \"Mega Wati\", \"phone\": \"628230000014\", \"user_id\": 35, \"created_at\": \"2026-09-29 07:21:15\", \"updated_at\": \"2026-09-29 07:21:15\"}', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `blamable_logs` VALUES (126, NULL, 'App\\Models\\User', '36', 'created', NULL, '{\"id\": 36, \"name\": \"Yusuf Hidayat\", \"email\": \"ortu5@contoh.local\", \"phone\": \"628230000015\", \"created_at\": \"2026-09-29 07:21:16\", \"updated_at\": \"2026-09-29 07:21:16\"}', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `blamable_logs` VALUES (127, NULL, 'App\\Models\\Guardian', '5', 'created', NULL, '{\"id\": 5, \"name\": \"Yusuf Hidayat\", \"phone\": \"628230000015\", \"user_id\": 36, \"created_at\": \"2026-09-29 07:21:16\", \"updated_at\": \"2026-09-29 07:21:16\"}', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `blamable_logs` VALUES (128, NULL, 'App\\Models\\User', '37', 'created', NULL, '{\"id\": 37, \"name\": \"Sri Mulyani\", \"email\": \"ortu6@contoh.local\", \"phone\": \"628230000016\", \"created_at\": \"2026-09-29 07:21:16\", \"updated_at\": \"2026-09-29 07:21:16\"}', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `blamable_logs` VALUES (129, NULL, 'App\\Models\\Guardian', '6', 'created', NULL, '{\"id\": 6, \"name\": \"Sri Mulyani\", \"phone\": \"628230000016\", \"user_id\": 37, \"created_at\": \"2026-09-29 07:21:16\", \"updated_at\": \"2026-09-29 07:21:16\"}', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `blamable_logs` VALUES (130, NULL, 'App\\Models\\User', '38', 'created', NULL, '{\"id\": 38, \"name\": \"Dedi Kurniawan\", \"email\": \"ortu7@contoh.local\", \"phone\": \"628230000017\", \"created_at\": \"2026-09-29 07:21:16\", \"updated_at\": \"2026-09-29 07:21:16\"}', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `blamable_logs` VALUES (131, NULL, 'App\\Models\\Guardian', '7', 'created', NULL, '{\"id\": 7, \"name\": \"Dedi Kurniawan\", \"phone\": \"628230000017\", \"user_id\": 38, \"created_at\": \"2026-09-29 07:21:16\", \"updated_at\": \"2026-09-29 07:21:16\"}', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `blamable_logs` VALUES (132, NULL, 'App\\Models\\User', '39', 'created', NULL, '{\"id\": 39, \"name\": \"Nina Kurnia\", \"email\": \"ortu8@contoh.local\", \"phone\": \"628230000018\", \"created_at\": \"2026-09-29 07:21:17\", \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (133, NULL, 'App\\Models\\Guardian', '8', 'created', NULL, '{\"id\": 8, \"name\": \"Nina Kurnia\", \"phone\": \"628230000018\", \"user_id\": 39, \"created_at\": \"2026-09-29 07:21:17\", \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (134, NULL, 'App\\Models\\User', '40', 'created', NULL, '{\"id\": 40, \"name\": \"Fajar Nugroho\", \"email\": \"ortu9@contoh.local\", \"phone\": \"628230000019\", \"created_at\": \"2026-09-29 07:21:17\", \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (135, NULL, 'App\\Models\\Guardian', '9', 'created', NULL, '{\"id\": 9, \"name\": \"Fajar Nugroho\", \"phone\": \"628230000019\", \"user_id\": 40, \"created_at\": \"2026-09-29 07:21:17\", \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (136, NULL, 'App\\Models\\User', '41', 'created', NULL, '{\"id\": 41, \"name\": \"Wulan Purnama\", \"email\": \"ortu10@contoh.local\", \"phone\": \"628230000020\", \"created_at\": \"2026-09-29 07:21:17\", \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (137, NULL, 'App\\Models\\Guardian', '10', 'created', NULL, '{\"id\": 10, \"name\": \"Wulan Purnama\", \"phone\": \"628230000020\", \"user_id\": 41, \"created_at\": \"2026-09-29 07:21:17\", \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (138, NULL, 'App\\Models\\SchoolClass', '1', 'created', NULL, '{\"id\": 1, \"name\": \"Matematika 7A\", \"type\": \"reguler\", \"room_id\": 1, \"capacity\": 20, \"tutor_id\": 1, \"created_at\": \"2026-09-29 07:21:17\", \"program_id\": 1, \"subject_id\": 1, \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (139, NULL, 'App\\Models\\SchoolClass', '2', 'created', NULL, '{\"id\": 2, \"name\": \"Fisika 8A\", \"type\": \"reguler\", \"room_id\": 2, \"capacity\": 15, \"tutor_id\": 2, \"created_at\": \"2026-09-29 07:21:17\", \"program_id\": 1, \"subject_id\": 2, \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (140, NULL, 'App\\Models\\SchoolClass', '3', 'created', NULL, '{\"id\": 3, \"name\": \"UTBK Camp 1\", \"type\": \"reguler\", \"room_id\": 1, \"capacity\": 20, \"tutor_id\": 3, \"created_at\": \"2026-09-29 07:21:17\", \"program_id\": 2, \"subject_id\": 1, \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (141, NULL, 'App\\Models\\SchoolClass', '4', 'created', NULL, '{\"id\": 4, \"name\": \"English 7B\", \"type\": \"reguler\", \"room_id\": 3, \"capacity\": 10, \"tutor_id\": 4, \"created_at\": \"2026-09-29 07:21:17\", \"program_id\": 1, \"subject_id\": 6, \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (142, NULL, 'App\\Models\\SchoolClass', '5', 'created', NULL, '{\"id\": 5, \"name\": \"Privat Andi\", \"type\": \"privat\", \"room_id\": 4, \"capacity\": 1, \"tutor_id\": 5, \"created_at\": \"2026-09-29 07:21:17\", \"program_id\": 3, \"subject_id\": 1, \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (143, NULL, 'App\\Models\\SchoolClass', '6', 'created', NULL, '{\"id\": 6, \"name\": \"Biologi 9A\", \"type\": \"reguler\", \"room_id\": 2, \"capacity\": 15, \"tutor_id\": 1, \"created_at\": \"2026-09-29 07:21:17\", \"program_id\": 1, \"subject_id\": 4, \"updated_at\": \"2026-09-29 07:21:17\"}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (144, NULL, 'App\\Models\\Enrollment', '1', 'created', NULL, '{\"id\": 1, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 1, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (145, NULL, 'App\\Models\\Enrollment', '2', 'created', NULL, '{\"id\": 2, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 2, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (146, NULL, 'App\\Models\\Enrollment', '3', 'created', NULL, '{\"id\": 3, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 3, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (147, NULL, 'App\\Models\\Enrollment', '4', 'created', NULL, '{\"id\": 4, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 4, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (148, NULL, 'App\\Models\\Enrollment', '5', 'created', NULL, '{\"id\": 5, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 5, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (149, NULL, 'App\\Models\\Enrollment', '6', 'created', NULL, '{\"id\": 6, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 6, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (150, NULL, 'App\\Models\\Enrollment', '7', 'created', NULL, '{\"id\": 7, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 7, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (151, NULL, 'App\\Models\\Enrollment', '8', 'created', NULL, '{\"id\": 8, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 8, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (152, NULL, 'App\\Models\\Enrollment', '9', 'created', NULL, '{\"id\": 9, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 9, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 2}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (153, NULL, 'App\\Models\\Enrollment', '10', 'created', NULL, '{\"id\": 10, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 10, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 2}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (154, NULL, 'App\\Models\\Enrollment', '11', 'created', NULL, '{\"id\": 11, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 11, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 2}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (155, NULL, 'App\\Models\\Enrollment', '12', 'created', NULL, '{\"id\": 12, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 12, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 2}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (156, NULL, 'App\\Models\\Enrollment', '13', 'created', NULL, '{\"id\": 13, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 13, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 3}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (157, NULL, 'App\\Models\\Enrollment', '14', 'created', NULL, '{\"id\": 14, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 14, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 3}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (158, NULL, 'App\\Models\\Enrollment', '15', 'created', NULL, '{\"id\": 15, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 15, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 3}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (159, NULL, 'App\\Models\\Enrollment', '16', 'created', NULL, '{\"id\": 16, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 16, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 4}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (160, NULL, 'App\\Models\\Enrollment', '17', 'created', NULL, '{\"id\": 17, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 17, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 4}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (161, NULL, 'App\\Models\\Enrollment', '18', 'created', NULL, '{\"id\": 18, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 1, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 5}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (162, NULL, 'App\\Models\\Enrollment', '19', 'created', NULL, '{\"id\": 19, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 18, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 6}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (163, NULL, 'App\\Models\\Enrollment', '20', 'created', NULL, '{\"id\": 20, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 19, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 6}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (164, NULL, 'App\\Models\\Enrollment', '21', 'created', NULL, '{\"id\": 21, \"status\": \"aktif\", \"created_at\": \"2026-09-29 07:21:17\", \"student_id\": 20, \"updated_at\": \"2026-09-29 07:21:17\", \"enrollment_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 6}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (165, NULL, 'App\\Models\\Schedule', '1', 'created', NULL, '{\"id\": 1, \"room_id\": 1, \"end_time\": \"09:30:00\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:17\", \"start_time\": \"08:00:00\", \"updated_at\": \"2026-09-29 07:21:17\", \"day_of_week\": 1, \"school_class_id\": 1}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (166, NULL, 'App\\Models\\Schedule', '2', 'created', NULL, '{\"id\": 2, \"room_id\": 1, \"end_time\": \"09:30:00\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:17\", \"start_time\": \"08:00:00\", \"updated_at\": \"2026-09-29 07:21:17\", \"day_of_week\": 3, \"school_class_id\": 1}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (167, NULL, 'App\\Models\\Schedule', '3', 'created', NULL, '{\"id\": 3, \"room_id\": 2, \"end_time\": \"11:30:00\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:17\", \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-29 07:21:17\", \"day_of_week\": 2, \"school_class_id\": 2}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (168, NULL, 'App\\Models\\Schedule', '4', 'created', NULL, '{\"id\": 4, \"room_id\": 3, \"end_time\": \"14:30:00\", \"is_active\": true, \"created_at\": \"2026-09-29 07:21:17\", \"start_time\": \"13:00:00\", \"updated_at\": \"2026-09-29 07:21:17\", \"day_of_week\": 4, \"school_class_id\": 4}', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `blamable_logs` VALUES (169, NULL, 'App\\Models\\Session', '1', 'created', NULL, '{\"id\": 1, \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"09:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29 07:21:18\", \"start_time\": \"08:00:00\", \"updated_at\": \"2026-09-29 07:21:18\", \"schedule_id\": 1, \"session_date\": \"2026-09-28 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `blamable_logs` VALUES (170, NULL, 'App\\Models\\Session', '2', 'created', NULL, '{\"id\": 2, \"status\": \"terjadwal\", \"room_id\": 2, \"end_time\": \"11:30:00\", \"tutor_id\": 2, \"created_at\": \"2026-09-29 07:21:18\", \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-29 07:21:18\", \"schedule_id\": 3, \"session_date\": \"2026-09-29 00:00:00\", \"school_class_id\": 2}', '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `blamable_logs` VALUES (171, NULL, 'App\\Models\\Assessment', '1', 'created', NULL, '{\"id\": 1, \"type\": \"ulangan\", \"title\": \"Ulangan Harian 1\", \"weight\": 1, \"max_score\": 100, \"created_at\": \"2026-09-29 07:21:18\", \"subject_id\": 1, \"updated_at\": \"2026-09-29 07:21:18\", \"assessment_date\": \"2026-09-05 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `blamable_logs` VALUES (172, NULL, 'App\\Models\\Assessment', '2', 'created', NULL, '{\"id\": 2, \"type\": \"tryout\", \"title\": \"Tryout 1\", \"weight\": 1, \"max_score\": 100, \"created_at\": \"2026-09-29 07:21:18\", \"subject_id\": 1, \"updated_at\": \"2026-09-29 07:21:18\", \"assessment_date\": \"2026-09-12 00:00:00\", \"school_class_id\": 1}', '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `blamable_logs` VALUES (173, NULL, 'App\\Models\\Material', '1', 'created', NULL, '{\"id\": 1, \"title\": \"Ringkasan Aljabar Dasar\", \"file_url\": \"/images/logo-gamma-one.svg\", \"created_at\": \"2026-09-29 07:21:18\", \"updated_at\": \"2026-09-29 07:21:18\", \"description\": \"Materi contoh fiktif.\", \"school_class_id\": 1}', '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `blamable_logs` VALUES (174, NULL, 'App\\Models\\Assignment', '1', 'created', NULL, '{\"id\": 1, \"title\": \"Latihan Soal 1\", \"deadline\": \"2026-10-06 07:21:18\", \"created_at\": \"2026-09-29 07:21:18\", \"updated_at\": \"2026-09-29 07:21:18\", \"description\": \"Kerjakan dan unggah hasilnya.\", \"school_class_id\": 1}', '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `blamable_logs` VALUES (175, 1, 'App\\Models\\CourseSetting', '1', 'created', NULL, '{\"id\": 1, \"created_at\": \"2026-09-29 07:58:45\", \"created_by\": 1, \"updated_at\": \"2026-09-29 07:58:45\", \"updated_by\": 1, \"school_name\": \"Gamma One\"}', '2026-09-29 07:58:45', '2026-09-29 07:58:45');
INSERT INTO `blamable_logs` VALUES (176, 1, 'App\\Models\\AppSetting', '1', 'updated', '{\"id\": 1, \"app_name\": \"Gamma One\", \"created_at\": \"2026-09-29T00:21:07.000000Z\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"updated_at\": \"2026-09-29T00:21:07.000000Z\", \"updated_by\": null, \"favicon_url\": \"/images/logo-gamma-one.svg\", \"company_name\": \"Gamma One\", \"login_logo_url\": \"/images/logo-gamma-one.svg\", \"sidebar_logo_url\": \"/images/logo-gamma-one.svg\"}', '{\"id\": 1, \"app_name\": \"Gamma One\", \"created_at\": \"2026-09-29 07:21:07\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"updated_at\": \"2026-09-29 07:59:21\", \"updated_by\": 1, \"favicon_url\": \"http://localhost:8000/storage/uploads/JYV2aKfhWXmkUg33pxm7AW5g8dLy1II8F9x5AI1o.png\", \"company_name\": \"Gamma One\", \"login_logo_url\": \"http://localhost:8000/storage/uploads/T6IXxDsomxTRc5i1txskZ3u5MhzrwWizvRcHeXTG.png\", \"sidebar_logo_url\": \"http://localhost:8000/storage/uploads/qTHGEd5LWo4m8Yd8QPH6bcJo2yyZXQWIHPCKOnjN.png\"}', '2026-09-29 07:59:21', '2026-09-29 07:59:21');
INSERT INTO `blamable_logs` VALUES (177, 1, 'App\\Models\\Material', '2', 'created', NULL, '{\"id\": 2, \"title\": \"Bangun Datar\", \"file_url\": \"http://localhost:8000/storage/uploads/dlFRJAS1azpXJZyg69PcKhyDFdMG2ybsmiu5SiNq.pdf\", \"created_at\": \"2026-09-29 08:03:40\", \"created_by\": 1, \"updated_at\": \"2026-09-29 08:03:40\", \"updated_by\": 1, \"description\": null, \"school_class_id\": 1}', '2026-09-29 08:03:40', '2026-09-29 08:03:40');
INSERT INTO `blamable_logs` VALUES (178, 1, 'App\\Models\\Assignment', '2', 'created', NULL, '{\"id\": 2, \"title\": \"English Camp\", \"deadline\": \"2026-09-30 08:04:59\", \"created_at\": \"2026-09-29 08:05:10\", \"created_by\": 1, \"updated_at\": \"2026-09-29 08:05:10\", \"updated_by\": 1, \"description\": null, \"school_class_id\": 4}', '2026-09-29 08:05:10', '2026-09-29 08:05:10');
INSERT INTO `blamable_logs` VALUES (179, 1, 'App\\Models\\AppSetting', '1', 'updated', '{\"id\": 1, \"app_name\": \"Gamma One\", \"created_at\": \"2026-09-29T00:21:07.000000Z\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"updated_at\": \"2026-09-29T00:59:21.000000Z\", \"updated_by\": 1, \"favicon_url\": \"http://localhost:8000/storage/uploads/JYV2aKfhWXmkUg33pxm7AW5g8dLy1II8F9x5AI1o.png\", \"company_name\": \"Gamma One\", \"login_logo_url\": \"http://localhost:8000/storage/uploads/T6IXxDsomxTRc5i1txskZ3u5MhzrwWizvRcHeXTG.png\", \"sidebar_logo_url\": \"http://localhost:8000/storage/uploads/qTHGEd5LWo4m8Yd8QPH6bcJo2yyZXQWIHPCKOnjN.png\"}', '{\"id\": 1, \"app_name\": \"Gamma One\", \"created_at\": \"2026-09-29 07:21:07\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"updated_at\": \"2026-09-29 08:23:00\", \"updated_by\": 1, \"favicon_url\": \"http://localhost:8000/storage/uploads/QBdRgMKKV3TCwdaxc6rF7jOYZQFYDIRikNoHgJgL.png\", \"company_name\": \"Gamma One\", \"login_logo_url\": \"http://localhost:8000/storage/uploads/T6IXxDsomxTRc5i1txskZ3u5MhzrwWizvRcHeXTG.png\", \"sidebar_logo_url\": \"http://localhost:8000/storage/uploads/qTHGEd5LWo4m8Yd8QPH6bcJo2yyZXQWIHPCKOnjN.png\"}', '2026-09-29 08:23:00', '2026-09-29 08:23:00');
INSERT INTO `blamable_logs` VALUES (180, 7, 'App\\Models\\Assignment', '3', 'created', NULL, '{\"id\": 3, \"title\": \"Latihan soal 2\", \"deadline\": \"2026-09-30 16:00:00\", \"created_at\": \"2026-09-30 07:39:41\", \"created_by\": 7, \"updated_at\": \"2026-09-30 07:39:41\", \"updated_by\": 7, \"description\": \"kerjakan dengan teliti\", \"school_class_id\": 1}', '2026-09-30 07:39:41', '2026-09-30 07:39:41');
INSERT INTO `blamable_logs` VALUES (181, 1, 'App\\Models\\Schedule', '5', 'created', NULL, '{\"id\": 5, \"room_id\": 4, \"end_time\": \"09:30\", \"is_active\": true, \"created_at\": \"2026-09-30 08:06:46\", \"created_by\": 1, \"start_time\": \"08:00\", \"updated_at\": \"2026-09-30 08:06:46\", \"updated_by\": 1, \"day_of_week\": 1, \"school_class_id\": 2}', '2026-09-30 08:06:46', '2026-09-30 08:06:46');
INSERT INTO `blamable_logs` VALUES (182, 1, 'App\\Models\\Schedule', '5', 'updated', '{\"id\": 5, \"room_id\": 4, \"end_time\": \"09:30:00\", \"is_active\": true, \"created_at\": \"2026-09-30T01:06:46.000000Z\", \"created_by\": 1, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"08:00:00\", \"updated_at\": \"2026-09-30T01:06:46.000000Z\", \"updated_by\": 1, \"day_of_week\": 1, \"school_class_id\": 2}', '{\"id\": 5, \"room_id\": 3, \"end_time\": \"09:30\", \"is_active\": true, \"created_at\": \"2026-09-30 08:06:46\", \"created_by\": 1, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"08:00\", \"updated_at\": \"2026-09-30 08:07:06\", \"updated_by\": 1, \"day_of_week\": 1, \"school_class_id\": 2}', '2026-09-30 08:07:06', '2026-09-30 08:07:06');
INSERT INTO `blamable_logs` VALUES (183, 7, 'App\\Models\\Session', '1', 'updated', '{\"id\": 1, \"reason\": null, \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"09:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29T00:21:18.000000Z\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"08:00:00\", \"updated_at\": \"2026-09-29T00:21:18.000000Z\", \"updated_by\": null, \"schedule_id\": 1, \"session_date\": \"2026-09-27T17:00:00.000000Z\", \"tutor_status\": null, \"material_notes\": null, \"school_class_id\": 1}', '{\"id\": 1, \"reason\": \"mundur 2 jam\", \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"11:30\", \"tutor_id\": 1, \"created_at\": \"2026-09-29 07:21:18\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00\", \"updated_at\": \"2026-09-30 08:21:50\", \"updated_by\": 7, \"schedule_id\": 1, \"session_date\": \"2026-09-27 00:00:00\", \"tutor_status\": null, \"material_notes\": null, \"school_class_id\": 1}', '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `blamable_logs` VALUES (184, 1, 'App\\Models\\Tutor', '6', 'created', NULL, '{\"id\": 6, \"bio\": \"Biodata\", \"name\": \"Yosi AWK\", \"phone\": \"628996844000\", \"user_id\": null, \"created_at\": \"2026-09-30 08:45:15\", \"created_by\": 1, \"updated_at\": \"2026-09-30 08:45:15\", \"updated_by\": 1, \"fee_per_session\": 50000}', '2026-09-30 08:45:15', '2026-09-30 08:45:15');
INSERT INTO `blamable_logs` VALUES (185, 1, 'App\\Models\\User', '42', 'created', NULL, '{\"id\": 42, \"name\": \"Yosi AWK\", \"email\": \"yos@gmail.com\", \"phone\": \"628996844000\", \"avatar_url\": null, \"created_at\": \"2026-09-30 08:46:08\", \"created_by\": 1, \"updated_at\": \"2026-09-30 08:46:08\", \"updated_by\": 1}', '2026-09-30 08:46:08', '2026-09-30 08:46:08');
INSERT INTO `blamable_logs` VALUES (186, 7, 'App\\Models\\SessionSubstituteRequest', '1', 'created', NULL, '{\"id\": 1, \"reason\": \"capek, pengen libur\", \"status\": \"diusulkan\", \"created_at\": \"2026-09-30 09:03:35\", \"created_by\": 7, \"session_id\": 1, \"updated_at\": \"2026-09-30 09:03:35\", \"updated_by\": 7, \"requested_by\": 7, \"original_tutor_id\": 1, \"proposed_tutor_id\": 6}', '2026-09-30 09:03:35', '2026-09-30 09:03:35');
INSERT INTO `blamable_logs` VALUES (187, 3, 'App\\Models\\SessionSubstituteRequest', '1', 'updated', '{\"id\": 1, \"reason\": \"capek, pengen libur\", \"status\": \"diusulkan\", \"created_at\": \"2026-09-30T02:03:35.000000Z\", \"created_by\": 7, \"deleted_at\": null, \"deleted_by\": null, \"session_id\": 1, \"updated_at\": \"2026-09-30T02:03:35.000000Z\", \"updated_by\": 7, \"review_note\": null, \"reviewed_at\": null, \"reviewed_by\": null, \"requested_by\": 7, \"original_tutor_id\": 1, \"proposed_tutor_id\": 6}', '{\"id\": 1, \"reason\": \"capek, pengen libur\", \"status\": \"disetujui\", \"created_at\": \"2026-09-30 09:03:35\", \"created_by\": 7, \"deleted_at\": null, \"deleted_by\": null, \"session_id\": 1, \"updated_at\": \"2026-09-30 09:27:35\", \"updated_by\": 3, \"review_note\": null, \"reviewed_at\": \"2026-09-30 09:27:35\", \"reviewed_by\": 3, \"requested_by\": 7, \"original_tutor_id\": 1, \"proposed_tutor_id\": 6}', '2026-09-30 09:27:35', '2026-09-30 09:27:35');
INSERT INTO `blamable_logs` VALUES (188, 3, 'App\\Models\\Session', '1', 'updated', '{\"id\": 1, \"reason\": \"mundur 2 jam\", \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29T00:21:18.000000Z\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30T01:21:50.000000Z\", \"updated_by\": 7, \"schedule_id\": 1, \"session_date\": \"2026-09-26T17:00:00.000000Z\", \"tutor_status\": null, \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": null}', '{\"id\": 1, \"reason\": \"mundur 2 jam\", \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29 07:21:18\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30 09:27:35\", \"updated_by\": 3, \"schedule_id\": 1, \"session_date\": \"2026-09-27\", \"tutor_status\": null, \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '2026-09-30 09:27:35', '2026-09-30 09:27:35');
INSERT INTO `blamable_logs` VALUES (189, 1, 'App\\Models\\Tutor', '6', 'updated', '{\"id\": 6, \"bio\": \"Biodata\", \"name\": \"Yosi AWK\", \"phone\": \"628996844000\", \"user_id\": null, \"created_at\": \"2026-09-30T01:45:15.000000Z\", \"created_by\": 1, \"deleted_at\": null, \"deleted_by\": null, \"updated_at\": \"2026-09-30T01:45:15.000000Z\", \"updated_by\": 1, \"availability\": null, \"fee_per_session\": 50000}', '{\"id\": 6, \"bio\": \"Biodata\", \"name\": \"Yosi AWK\", \"phone\": \"628996844000\", \"user_id\": 42, \"created_at\": \"2026-09-30 08:45:15\", \"created_by\": 1, \"deleted_at\": null, \"deleted_by\": null, \"updated_at\": \"2026-09-30 10:43:28\", \"updated_by\": 1, \"availability\": null, \"fee_per_session\": 50000}', '2026-09-30 10:43:28', '2026-09-30 10:43:28');
INSERT INTO `blamable_logs` VALUES (190, 42, 'App\\Models\\Session', '1', 'updated', '{\"id\": 1, \"reason\": \"mundur 2 jam\", \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29T00:21:18.000000Z\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30T02:27:35.000000Z\", \"updated_by\": 3, \"schedule_id\": 1, \"session_date\": \"2026-09-26T17:00:00.000000Z\", \"tutor_status\": null, \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '{\"id\": 1, \"reason\": \"mundur 2 jam\", \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29 07:21:18\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30 14:40:39\", \"updated_by\": 42, \"schedule_id\": 1, \"session_date\": \"2026-09-27\", \"tutor_status\": \"hadir\", \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '2026-09-30 14:40:39', '2026-09-30 14:40:39');
INSERT INTO `blamable_logs` VALUES (191, 42, 'App\\Models\\Session', '1', 'updated', '{\"id\": 1, \"reason\": \"mundur 2 jam\", \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29T00:21:18.000000Z\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30T07:40:39.000000Z\", \"updated_by\": 42, \"schedule_id\": 1, \"session_date\": \"2026-09-26T17:00:00.000000Z\", \"tutor_status\": \"hadir\", \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '{\"id\": 1, \"reason\": \"mundur 2 jam\", \"status\": \"selesai\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29 07:21:18\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30 14:41:00\", \"updated_by\": 42, \"schedule_id\": 1, \"session_date\": \"2026-09-27\", \"tutor_status\": \"hadir\", \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '2026-09-30 14:41:00', '2026-09-30 14:41:00');
INSERT INTO `blamable_logs` VALUES (192, 1, 'App\\Models\\Session', '1', 'updated', '{\"id\": 1, \"reason\": \"mundur 2 jam\", \"status\": \"selesai\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29T00:21:18.000000Z\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30T07:41:00.000000Z\", \"updated_by\": 42, \"schedule_id\": 1, \"session_date\": \"2026-09-26T17:00:00.000000Z\", \"tutor_status\": \"hadir\", \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '{\"id\": 1, \"reason\": \"buka, permintaan\", \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29 07:21:18\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30 14:42:15\", \"updated_by\": 1, \"schedule_id\": 1, \"session_date\": \"2026-09-27\", \"tutor_status\": \"hadir\", \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '2026-09-30 14:42:15', '2026-09-30 14:42:15');
INSERT INTO `blamable_logs` VALUES (193, 42, 'App\\Models\\Session', '1', 'updated', '{\"id\": 1, \"reason\": \"buka, permintaan\", \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29T00:21:18.000000Z\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30T07:42:15.000000Z\", \"updated_by\": 1, \"schedule_id\": 1, \"session_date\": \"2026-09-26T17:00:00.000000Z\", \"tutor_status\": \"hadir\", \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '{\"id\": 1, \"reason\": \"buka, permintaan\", \"status\": \"selesai\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29 07:21:18\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30 15:22:31\", \"updated_by\": 42, \"schedule_id\": 1, \"session_date\": \"2026-09-27\", \"tutor_status\": \"hadir\", \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '2026-09-30 15:22:31', '2026-09-30 15:22:31');
INSERT INTO `blamable_logs` VALUES (194, 1, 'App\\Models\\Session', '1', 'updated', '{\"id\": 1, \"reason\": \"buka, permintaan\", \"status\": \"selesai\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29T00:21:18.000000Z\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30T08:22:31.000000Z\", \"updated_by\": 42, \"schedule_id\": 1, \"session_date\": \"2026-09-26T17:00:00.000000Z\", \"tutor_status\": \"hadir\", \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '{\"id\": 1, \"reason\": \"test buka lagi\", \"status\": \"terjadwal\", \"room_id\": 1, \"end_time\": \"11:30:00\", \"tutor_id\": 1, \"created_at\": \"2026-09-29 07:21:18\", \"created_by\": null, \"deleted_at\": null, \"deleted_by\": null, \"start_time\": \"10:00:00\", \"updated_at\": \"2026-09-30 15:23:13\", \"updated_by\": 1, \"schedule_id\": 1, \"session_date\": \"2026-09-27\", \"tutor_status\": \"hadir\", \"material_notes\": null, \"school_class_id\": 1, \"substitute_tutor_id\": 6}', '2026-09-30 15:23:13', '2026-09-30 15:23:13');

-- ----------------------------
-- Table structure for cache
-- ----------------------------
DROP TABLE IF EXISTS `cache`;
CREATE TABLE `cache`  (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`) USING BTREE,
  INDEX `cache_expiration_index`(`expiration` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cache
-- ----------------------------
INSERT INTO `cache` VALUES ('gamma-one-cache-5c785c036466adea360111aa28563bfd556b5fba', 'i:1;', 1790754164);
INSERT INTO `cache` VALUES ('gamma-one-cache-5c785c036466adea360111aa28563bfd556b5fba:timer', 'i:1790754164;', 1790754164);
INSERT INTO `cache` VALUES ('gamma-one-cache-73651a8e661cbf3b5a812bc846be2b2d', 'i:19;', 1790668337);
INSERT INTO `cache` VALUES ('gamma-one-cache-73651a8e661cbf3b5a812bc846be2b2d:timer', 'i:1790668337;', 1790668337);
INSERT INTO `cache` VALUES ('gamma-one-cache-7c2150d7106073168321f39ec452420d', 'i:12;', 1790668162);
INSERT INTO `cache` VALUES ('gamma-one-cache-7c2150d7106073168321f39ec452420d:timer', 'i:1790668162;', 1790668162);
INSERT INTO `cache` VALUES ('gamma-one-cache-7f3072bf378b98d6bbf2f013cff3e287', 'i:9;', 1790729084);
INSERT INTO `cache` VALUES ('gamma-one-cache-7f3072bf378b98d6bbf2f013cff3e287:timer', 'i:1790729084;', 1790729084);
INSERT INTO `cache` VALUES ('gamma-one-cache-9c7fd4ba5798dd608aa755cf24e8ea32', 'i:7;', 1790760373);
INSERT INTO `cache` VALUES ('gamma-one-cache-9c7fd4ba5798dd608aa755cf24e8ea32:timer', 'i:1790760373;', 1790760373);
INSERT INTO `cache` VALUES ('gamma-one-cache-a75f3f172bfb296f2e10cbfc6dfc1883', 'i:1;', 1790760374);
INSERT INTO `cache` VALUES ('gamma-one-cache-a75f3f172bfb296f2e10cbfc6dfc1883:timer', 'i:1790760374;', 1790760374);
INSERT INTO `cache` VALUES ('gamma-one-cache-ad4954e2e38bb42a3ba5cbc5eebbbdbc', 'i:10;', 1790668076);
INSERT INTO `cache` VALUES ('gamma-one-cache-ad4954e2e38bb42a3ba5cbc5eebbbdbc:timer', 'i:1790668076;', 1790668076);
INSERT INTO `cache` VALUES ('gamma-one-cache-b37e2b0b86a8368405df02e0b66d0b39', 'i:8;', 1790735344);
INSERT INTO `cache` VALUES ('gamma-one-cache-b37e2b0b86a8368405df02e0b66d0b39:timer', 'i:1790735344;', 1790735344);
INSERT INTO `cache` VALUES ('gamma-one-cache-d2bfa8e8b749d2772a21edee7b70a2b3', 'i:10;', 1790735702);
INSERT INTO `cache` VALUES ('gamma-one-cache-d2bfa8e8b749d2772a21edee7b70a2b3:timer', 'i:1790735702;', 1790735702);
INSERT INTO `cache` VALUES ('gamma-one-cache-dashboard:admin', 'a:6:{s:11:\"siswa_aktif\";i:20;s:19:\"pemasukan_bulan_ini\";i:0;s:16:\"tunggakan_jumlah\";i:0;s:15:\"tunggakan_total\";i:0;s:17:\"tingkat_kehadiran\";i:0;s:16:\"grafik_pemasukan\";a:6:{i:0;a:2:{s:5:\"month\";s:7:\"2026-04\";s:5:\"total\";i:0;}i:1;a:2:{s:5:\"month\";s:7:\"2026-05\";s:5:\"total\";i:0;}i:2;a:2:{s:5:\"month\";s:7:\"2026-06\";s:5:\"total\";i:0;}i:3;a:2:{s:5:\"month\";s:7:\"2026-07\";s:5:\"total\";i:0;}i:4;a:2:{s:5:\"month\";s:7:\"2026-08\";s:5:\"total\";i:0;}i:5;a:2:{s:5:\"month\";s:7:\"2026-09\";s:5:\"total\";i:0;}}}', 1790642646);
INSERT INTO `cache` VALUES ('gamma-one-cache-dashboard:admin:v2', 'a:7:{s:11:\"siswa_aktif\";i:20;s:19:\"pemasukan_bulan_ini\";i:0;s:16:\"tunggakan_jumlah\";i:0;s:15:\"tunggakan_total\";i:0;s:17:\"tingkat_kehadiran\";d:100;s:16:\"grafik_pemasukan\";a:6:{i:0;a:2:{s:5:\"month\";s:7:\"2026-04\";s:5:\"total\";i:0;}i:1;a:2:{s:5:\"month\";s:7:\"2026-05\";s:5:\"total\";i:0;}i:2;a:2:{s:5:\"month\";s:7:\"2026-06\";s:5:\"total\";i:0;}i:3;a:2:{s:5:\"month\";s:7:\"2026-07\";s:5:\"total\";i:0;}i:4;a:2:{s:5:\"month\";s:7:\"2026-08\";s:5:\"total\";i:0;}i:5;a:2:{s:5:\"month\";s:7:\"2026-09\";s:5:\"total\";i:0;}}s:13:\"kelas_teratas\";O:39:\"Illuminate\\Database\\Eloquent\\Collection\":2:{s:8:\"\0*\0items\";a:5:{i:0;O:22:\"App\\Models\\SchoolClass\":34:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:14:\"school_classes\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:16:{s:2:\"id\";i:1;s:4:\"name\";s:13:\"Matematika 7A\";s:10:\"program_id\";i:1;s:10:\"subject_id\";i:1;s:8:\"tutor_id\";i:1;s:7:\"room_id\";i:1;s:8:\"capacity\";i:20;s:4:\"type\";s:7:\"reguler\";s:11:\"description\";N;s:10:\"created_by\";N;s:10:\"updated_by\";N;s:10:\"deleted_by\";N;s:10:\"created_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"updated_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"deleted_at\";N;s:24:\"active_enrollments_count\";i:8;}s:11:\"\0*\0original\";a:16:{s:2:\"id\";i:1;s:4:\"name\";s:13:\"Matematika 7A\";s:10:\"program_id\";i:1;s:10:\"subject_id\";i:1;s:8:\"tutor_id\";i:1;s:7:\"room_id\";i:1;s:8:\"capacity\";i:20;s:4:\"type\";s:7:\"reguler\";s:11:\"description\";N;s:10:\"created_by\";N;s:10:\"updated_by\";N;s:10:\"deleted_by\";N;s:10:\"created_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"updated_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"deleted_at\";N;s:24:\"active_enrollments_count\";i:8;}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:2:{s:8:\"capacity\";s:7:\"integer\";s:10:\"deleted_at\";s:8:\"datetime\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:8:{i:0;s:4:\"name\";i:1;s:10:\"program_id\";i:2;s:10:\"subject_id\";i:3;s:8:\"tutor_id\";i:4;s:7:\"room_id\";i:5;s:8:\"capacity\";i:6;s:4:\"type\";i:7;s:11:\"description\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}s:16:\"\0*\0forceDeleting\";b:0;}i:1;O:22:\"App\\Models\\SchoolClass\":34:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:14:\"school_classes\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:16:{s:2:\"id\";i:2;s:4:\"name\";s:9:\"Fisika 8A\";s:10:\"program_id\";i:1;s:10:\"subject_id\";i:2;s:8:\"tutor_id\";i:2;s:7:\"room_id\";i:2;s:8:\"capacity\";i:15;s:4:\"type\";s:7:\"reguler\";s:11:\"description\";N;s:10:\"created_by\";N;s:10:\"updated_by\";N;s:10:\"deleted_by\";N;s:10:\"created_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"updated_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"deleted_at\";N;s:24:\"active_enrollments_count\";i:4;}s:11:\"\0*\0original\";a:16:{s:2:\"id\";i:2;s:4:\"name\";s:9:\"Fisika 8A\";s:10:\"program_id\";i:1;s:10:\"subject_id\";i:2;s:8:\"tutor_id\";i:2;s:7:\"room_id\";i:2;s:8:\"capacity\";i:15;s:4:\"type\";s:7:\"reguler\";s:11:\"description\";N;s:10:\"created_by\";N;s:10:\"updated_by\";N;s:10:\"deleted_by\";N;s:10:\"created_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"updated_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"deleted_at\";N;s:24:\"active_enrollments_count\";i:4;}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:2:{s:8:\"capacity\";s:7:\"integer\";s:10:\"deleted_at\";s:8:\"datetime\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:8:{i:0;s:4:\"name\";i:1;s:10:\"program_id\";i:2;s:10:\"subject_id\";i:3;s:8:\"tutor_id\";i:4;s:7:\"room_id\";i:5;s:8:\"capacity\";i:6;s:4:\"type\";i:7;s:11:\"description\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}s:16:\"\0*\0forceDeleting\";b:0;}i:2;O:22:\"App\\Models\\SchoolClass\":34:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:14:\"school_classes\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:16:{s:2:\"id\";i:3;s:4:\"name\";s:11:\"UTBK Camp 1\";s:10:\"program_id\";i:2;s:10:\"subject_id\";i:1;s:8:\"tutor_id\";i:3;s:7:\"room_id\";i:1;s:8:\"capacity\";i:20;s:4:\"type\";s:7:\"reguler\";s:11:\"description\";N;s:10:\"created_by\";N;s:10:\"updated_by\";N;s:10:\"deleted_by\";N;s:10:\"created_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"updated_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"deleted_at\";N;s:24:\"active_enrollments_count\";i:3;}s:11:\"\0*\0original\";a:16:{s:2:\"id\";i:3;s:4:\"name\";s:11:\"UTBK Camp 1\";s:10:\"program_id\";i:2;s:10:\"subject_id\";i:1;s:8:\"tutor_id\";i:3;s:7:\"room_id\";i:1;s:8:\"capacity\";i:20;s:4:\"type\";s:7:\"reguler\";s:11:\"description\";N;s:10:\"created_by\";N;s:10:\"updated_by\";N;s:10:\"deleted_by\";N;s:10:\"created_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"updated_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"deleted_at\";N;s:24:\"active_enrollments_count\";i:3;}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:2:{s:8:\"capacity\";s:7:\"integer\";s:10:\"deleted_at\";s:8:\"datetime\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:8:{i:0;s:4:\"name\";i:1;s:10:\"program_id\";i:2;s:10:\"subject_id\";i:3;s:8:\"tutor_id\";i:4;s:7:\"room_id\";i:5;s:8:\"capacity\";i:6;s:4:\"type\";i:7;s:11:\"description\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}s:16:\"\0*\0forceDeleting\";b:0;}i:3;O:22:\"App\\Models\\SchoolClass\":34:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:14:\"school_classes\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:16:{s:2:\"id\";i:6;s:4:\"name\";s:10:\"Biologi 9A\";s:10:\"program_id\";i:1;s:10:\"subject_id\";i:4;s:8:\"tutor_id\";i:1;s:7:\"room_id\";i:2;s:8:\"capacity\";i:15;s:4:\"type\";s:7:\"reguler\";s:11:\"description\";N;s:10:\"created_by\";N;s:10:\"updated_by\";N;s:10:\"deleted_by\";N;s:10:\"created_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"updated_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"deleted_at\";N;s:24:\"active_enrollments_count\";i:3;}s:11:\"\0*\0original\";a:16:{s:2:\"id\";i:6;s:4:\"name\";s:10:\"Biologi 9A\";s:10:\"program_id\";i:1;s:10:\"subject_id\";i:4;s:8:\"tutor_id\";i:1;s:7:\"room_id\";i:2;s:8:\"capacity\";i:15;s:4:\"type\";s:7:\"reguler\";s:11:\"description\";N;s:10:\"created_by\";N;s:10:\"updated_by\";N;s:10:\"deleted_by\";N;s:10:\"created_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"updated_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"deleted_at\";N;s:24:\"active_enrollments_count\";i:3;}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:2:{s:8:\"capacity\";s:7:\"integer\";s:10:\"deleted_at\";s:8:\"datetime\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:8:{i:0;s:4:\"name\";i:1;s:10:\"program_id\";i:2;s:10:\"subject_id\";i:3;s:8:\"tutor_id\";i:4;s:7:\"room_id\";i:5;s:8:\"capacity\";i:6;s:4:\"type\";i:7;s:11:\"description\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}s:16:\"\0*\0forceDeleting\";b:0;}i:4;O:22:\"App\\Models\\SchoolClass\":34:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:14:\"school_classes\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:16:{s:2:\"id\";i:4;s:4:\"name\";s:10:\"English 7B\";s:10:\"program_id\";i:1;s:10:\"subject_id\";i:6;s:8:\"tutor_id\";i:4;s:7:\"room_id\";i:3;s:8:\"capacity\";i:10;s:4:\"type\";s:7:\"reguler\";s:11:\"description\";N;s:10:\"created_by\";N;s:10:\"updated_by\";N;s:10:\"deleted_by\";N;s:10:\"created_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"updated_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"deleted_at\";N;s:24:\"active_enrollments_count\";i:2;}s:11:\"\0*\0original\";a:16:{s:2:\"id\";i:4;s:4:\"name\";s:10:\"English 7B\";s:10:\"program_id\";i:1;s:10:\"subject_id\";i:6;s:8:\"tutor_id\";i:4;s:7:\"room_id\";i:3;s:8:\"capacity\";i:10;s:4:\"type\";s:7:\"reguler\";s:11:\"description\";N;s:10:\"created_by\";N;s:10:\"updated_by\";N;s:10:\"deleted_by\";N;s:10:\"created_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"updated_at\";s:19:\"2026-09-29 07:21:17\";s:10:\"deleted_at\";N;s:24:\"active_enrollments_count\";i:2;}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:2:{s:8:\"capacity\";s:7:\"integer\";s:10:\"deleted_at\";s:8:\"datetime\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:8:{i:0;s:4:\"name\";i:1;s:10:\"program_id\";i:2;s:10:\"subject_id\";i:3;s:8:\"tutor_id\";i:4;s:7:\"room_id\";i:5;s:8:\"capacity\";i:6;s:4:\"type\";i:7;s:11:\"description\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}s:16:\"\0*\0forceDeleting\";b:0;}}s:28:\"\0*\0escapeWhenCastingToString\";b:0;}}', 1790754226);
INSERT INTO `cache` VALUES ('gamma-one-cache-dashboard:tutor:42', 'a:10:{s:11:\"kelas_aktif\";i:0;s:11:\"total_siswa\";i:0;s:15:\"sesi_minggu_ini\";i:0;s:15:\"honor_bulan_ini\";i:0;s:15:\"jadwal_hari_ini\";O:39:\"Illuminate\\Database\\Eloquent\\Collection\":2:{s:8:\"\0*\0items\";a:0:{}s:28:\"\0*\0escapeWhenCastingToString\";b:0;}s:15:\"perlu_perhatian\";a:0:{}s:14:\"sesi_mendatang\";O:39:\"Illuminate\\Database\\Eloquent\\Collection\":2:{s:8:\"\0*\0items\";a:0:{}s:28:\"\0*\0escapeWhenCastingToString\";b:0;}s:19:\"kehadiran_per_kelas\";O:39:\"Illuminate\\Database\\Eloquent\\Collection\":2:{s:8:\"\0*\0items\";a:0:{}s:28:\"\0*\0escapeWhenCastingToString\";b:0;}s:20:\"rata_nilai_per_kelas\";O:39:\"Illuminate\\Database\\Eloquent\\Collection\":2:{s:8:\"\0*\0items\";a:0:{}s:28:\"\0*\0escapeWhenCastingToString\";b:0;}s:16:\"usulan_pengganti\";O:39:\"Illuminate\\Database\\Eloquent\\Collection\":2:{s:8:\"\0*\0items\";a:0:{}s:28:\"\0*\0escapeWhenCastingToString\";b:0;}}', 1790756922);
INSERT INTO `cache` VALUES ('gamma-one-cache-f1f70ec40aaa556905d4a030501c0ba4', 'i:1;', 1790760204);
INSERT INTO `cache` VALUES ('gamma-one-cache-f1f70ec40aaa556905d4a030501c0ba4:timer', 'i:1790760204;', 1790760204);
INSERT INTO `cache` VALUES ('gamma-one-cache-spatie.permission.cache', 'a:3:{s:5:\"alias\";a:5:{s:1:\"a\";s:2:\"id\";s:1:\"b\";s:19:\"permission_group_id\";s:1:\"c\";s:4:\"name\";s:1:\"d\";s:10:\"guard_name\";s:1:\"r\";s:5:\"roles\";}s:11:\"permissions\";a:99:{i:0;a:5:{s:1:\"a\";i:1;s:1:\"b\";i:1;s:1:\"c\";s:10:\"users.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:1;a:5:{s:1:\"a\";i:2;s:1:\"b\";i:1;s:1:\"c\";s:12:\"users.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:2;a:5:{s:1:\"a\";i:3;s:1:\"b\";i:1;s:1:\"c\";s:12:\"users.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:3;a:5:{s:1:\"a\";i:4;s:1:\"b\";i:1;s:1:\"c\";s:12:\"users.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:4;a:5:{s:1:\"a\";i:5;s:1:\"b\";i:2;s:1:\"c\";s:10:\"roles.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:5;a:5:{s:1:\"a\";i:6;s:1:\"b\";i:2;s:1:\"c\";s:12:\"roles.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:6;a:5:{s:1:\"a\";i:7;s:1:\"b\";i:2;s:1:\"c\";s:12:\"roles.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:7;a:5:{s:1:\"a\";i:8;s:1:\"b\";i:2;s:1:\"c\";s:12:\"roles.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:8;a:5:{s:1:\"a\";i:9;s:1:\"b\";i:2;s:1:\"c\";s:16:\"permissions.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:9;a:5:{s:1:\"a\";i:10;s:1:\"b\";i:2;s:1:\"c\";s:18:\"permissions.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:10;a:5:{s:1:\"a\";i:11;s:1:\"b\";i:2;s:1:\"c\";s:18:\"permissions.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:11;a:5:{s:1:\"a\";i:12;s:1:\"b\";i:2;s:1:\"c\";s:18:\"permissions.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:12;a:5:{s:1:\"a\";i:13;s:1:\"b\";i:2;s:1:\"c\";s:22:\"permission-groups.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:13;a:5:{s:1:\"a\";i:14;s:1:\"b\";i:2;s:1:\"c\";s:24:\"permission-groups.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:14;a:5:{s:1:\"a\";i:15;s:1:\"b\";i:2;s:1:\"c\";s:24:\"permission-groups.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:15;a:5:{s:1:\"a\";i:16;s:1:\"b\";i:2;s:1:\"c\";s:24:\"permission-groups.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:16;a:5:{s:1:\"a\";i:17;s:1:\"b\";i:3;s:1:\"c\";s:10:\"menus.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:17;a:5:{s:1:\"a\";i:18;s:1:\"b\";i:3;s:1:\"c\";s:12:\"menus.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:18;a:5:{s:1:\"a\";i:19;s:1:\"b\";i:3;s:1:\"c\";s:12:\"menus.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:19;a:5:{s:1:\"a\";i:20;s:1:\"b\";i:3;s:1:\"c\";s:12:\"menus.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:20;a:5:{s:1:\"a\";i:21;s:1:\"b\";i:3;s:1:\"c\";s:17:\"app-settings.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:21;a:5:{s:1:\"a\";i:22;s:1:\"b\";i:3;s:1:\"c\";s:19:\"app-settings.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:22;a:5:{s:1:\"a\";i:23;s:1:\"b\";i:3;s:1:\"c\";s:18:\"blamable-logs.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:23;a:5:{s:1:\"a\";i:24;s:1:\"b\";i:4;s:1:\"c\";s:13:\"students.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}i:24;a:5:{s:1:\"a\";i:25;s:1:\"b\";i:4;s:1:\"c\";s:15:\"students.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:25;a:5:{s:1:\"a\";i:26;s:1:\"b\";i:4;s:1:\"c\";s:15:\"students.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:26;a:5:{s:1:\"a\";i:27;s:1:\"b\";i:4;s:1:\"c\";s:15:\"students.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:27;a:5:{s:1:\"a\";i:28;s:1:\"b\";i:4;s:1:\"c\";s:12:\"parents.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:6;}}i:28;a:5:{s:1:\"a\";i:29;s:1:\"b\";i:4;s:1:\"c\";s:14:\"parents.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:29;a:5:{s:1:\"a\";i:30;s:1:\"b\";i:4;s:1:\"c\";s:14:\"parents.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:30;a:5:{s:1:\"a\";i:31;s:1:\"b\";i:4;s:1:\"c\";s:14:\"parents.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:31;a:5:{s:1:\"a\";i:32;s:1:\"b\";i:4;s:1:\"c\";s:11:\"tutors.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:32;a:5:{s:1:\"a\";i:33;s:1:\"b\";i:4;s:1:\"c\";s:13:\"tutors.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:33;a:5:{s:1:\"a\";i:34;s:1:\"b\";i:4;s:1:\"c\";s:13:\"tutors.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:34;a:5:{s:1:\"a\";i:35;s:1:\"b\";i:4;s:1:\"c\";s:13:\"tutors.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:35;a:5:{s:1:\"a\";i:36;s:1:\"b\";i:4;s:1:\"c\";s:13:\"programs.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:36;a:5:{s:1:\"a\";i:37;s:1:\"b\";i:4;s:1:\"c\";s:15:\"programs.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:37;a:5:{s:1:\"a\";i:38;s:1:\"b\";i:4;s:1:\"c\";s:15:\"programs.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:38;a:5:{s:1:\"a\";i:39;s:1:\"b\";i:4;s:1:\"c\";s:15:\"programs.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:39;a:5:{s:1:\"a\";i:40;s:1:\"b\";i:4;s:1:\"c\";s:13:\"subjects.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:40;a:5:{s:1:\"a\";i:41;s:1:\"b\";i:4;s:1:\"c\";s:15:\"subjects.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:41;a:5:{s:1:\"a\";i:42;s:1:\"b\";i:4;s:1:\"c\";s:15:\"subjects.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:42;a:5:{s:1:\"a\";i:43;s:1:\"b\";i:4;s:1:\"c\";s:15:\"subjects.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:43;a:5:{s:1:\"a\";i:44;s:1:\"b\";i:4;s:1:\"c\";s:10:\"rooms.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:44;a:5:{s:1:\"a\";i:45;s:1:\"b\";i:4;s:1:\"c\";s:12:\"rooms.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:45;a:5:{s:1:\"a\";i:46;s:1:\"b\";i:4;s:1:\"c\";s:12:\"rooms.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:46;a:5:{s:1:\"a\";i:47;s:1:\"b\";i:4;s:1:\"c\";s:12:\"rooms.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:47;a:5:{s:1:\"a\";i:48;s:1:\"b\";i:4;s:1:\"c\";s:12:\"classes.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}i:48;a:5:{s:1:\"a\";i:49;s:1:\"b\";i:4;s:1:\"c\";s:14:\"classes.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:49;a:5:{s:1:\"a\";i:50;s:1:\"b\";i:4;s:1:\"c\";s:14:\"classes.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:50;a:5:{s:1:\"a\";i:51;s:1:\"b\";i:4;s:1:\"c\";s:14:\"classes.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:51;a:5:{s:1:\"a\";i:52;s:1:\"b\";i:4;s:1:\"c\";s:16:\"enrollments.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}i:52;a:5:{s:1:\"a\";i:53;s:1:\"b\";i:4;s:1:\"c\";s:18:\"enrollments.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:53;a:5:{s:1:\"a\";i:54;s:1:\"b\";i:4;s:1:\"c\";s:18:\"enrollments.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:54;a:5:{s:1:\"a\";i:55;s:1:\"b\";i:4;s:1:\"c\";s:18:\"enrollments.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:55;a:5:{s:1:\"a\";i:56;s:1:\"b\";i:5;s:1:\"c\";s:14:\"schedules.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}i:56;a:5:{s:1:\"a\";i:57;s:1:\"b\";i:5;s:1:\"c\";s:16:\"schedules.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:57;a:5:{s:1:\"a\";i:58;s:1:\"b\";i:5;s:1:\"c\";s:16:\"schedules.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:58;a:5:{s:1:\"a\";i:59;s:1:\"b\";i:5;s:1:\"c\";s:16:\"schedules.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:59;a:5:{s:1:\"a\";i:60;s:1:\"b\";i:5;s:1:\"c\";s:13:\"sessions.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}i:60;a:5:{s:1:\"a\";i:61;s:1:\"b\";i:5;s:1:\"c\";s:15:\"sessions.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:61;a:5:{s:1:\"a\";i:62;s:1:\"b\";i:5;s:1:\"c\";s:15:\"sessions.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:62;a:5:{s:1:\"a\";i:63;s:1:\"b\";i:5;s:1:\"c\";s:15:\"sessions.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:63;a:5:{s:1:\"a\";i:64;s:1:\"b\";i:6;s:1:\"c\";s:13:\"invoices.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:5:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:5;i:4;i:6;}}i:64;a:5:{s:1:\"a\";i:65;s:1:\"b\";i:6;s:1:\"c\";s:15:\"invoices.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:65;a:5:{s:1:\"a\";i:66;s:1:\"b\";i:6;s:1:\"c\";s:15:\"invoices.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:66;a:5:{s:1:\"a\";i:67;s:1:\"b\";i:6;s:1:\"c\";s:15:\"invoices.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:67;a:5:{s:1:\"a\";i:68;s:1:\"b\";i:6;s:1:\"c\";s:13:\"payments.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:68;a:5:{s:1:\"a\";i:69;s:1:\"b\";i:6;s:1:\"c\";s:15:\"payments.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:69;a:5:{s:1:\"a\";i:70;s:1:\"b\";i:6;s:1:\"c\";s:15:\"payments.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:70;a:5:{s:1:\"a\";i:71;s:1:\"b\";i:6;s:1:\"c\";s:15:\"payments.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:71;a:5:{s:1:\"a\";i:72;s:1:\"b\";i:6;s:1:\"c\";s:13:\"payrolls.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:72;a:5:{s:1:\"a\";i:73;s:1:\"b\";i:7;s:1:\"c\";s:27:\"notification-templates.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:73;a:5:{s:1:\"a\";i:74;s:1:\"b\";i:7;s:1:\"c\";s:29:\"notification-templates.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:74;a:5:{s:1:\"a\";i:75;s:1:\"b\";i:7;s:1:\"c\";s:29:\"notification-templates.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:75;a:5:{s:1:\"a\";i:76;s:1:\"b\";i:7;s:1:\"c\";s:29:\"notification-templates.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:76;a:5:{s:1:\"a\";i:77;s:1:\"b\";i:7;s:1:\"c\";s:18:\"notifications.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:77;a:5:{s:1:\"a\";i:78;s:1:\"b\";i:7;s:1:\"c\";s:20:\"notifications.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:78;a:5:{s:1:\"a\";i:79;s:1:\"b\";i:7;s:1:\"c\";s:20:\"notifications.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:79;a:5:{s:1:\"a\";i:80;s:1:\"b\";i:7;s:1:\"c\";s:20:\"notifications.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:80;a:5:{s:1:\"a\";i:81;s:1:\"b\";i:8;s:1:\"c\";s:16:\"assessments.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:81;a:5:{s:1:\"a\";i:82;s:1:\"b\";i:8;s:1:\"c\";s:18:\"assessments.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:82;a:5:{s:1:\"a\";i:83;s:1:\"b\";i:8;s:1:\"c\";s:18:\"assessments.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:83;a:5:{s:1:\"a\";i:84;s:1:\"b\";i:8;s:1:\"c\";s:18:\"assessments.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:84;a:5:{s:1:\"a\";i:85;s:1:\"b\";i:8;s:1:\"c\";s:14:\"materials.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}i:85;a:5:{s:1:\"a\";i:86;s:1:\"b\";i:8;s:1:\"c\";s:16:\"materials.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:86;a:5:{s:1:\"a\";i:87;s:1:\"b\";i:8;s:1:\"c\";s:16:\"materials.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:87;a:5:{s:1:\"a\";i:88;s:1:\"b\";i:8;s:1:\"c\";s:16:\"materials.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:88;a:5:{s:1:\"a\";i:89;s:1:\"b\";i:8;s:1:\"c\";s:16:\"assignments.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}i:89;a:5:{s:1:\"a\";i:90;s:1:\"b\";i:8;s:1:\"c\";s:18:\"assignments.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:90;a:5:{s:1:\"a\";i:91;s:1:\"b\";i:8;s:1:\"c\";s:18:\"assignments.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:91;a:5:{s:1:\"a\";i:92;s:1:\"b\";i:8;s:1:\"c\";s:18:\"assignments.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:92;a:5:{s:1:\"a\";i:93;s:1:\"b\";i:8;s:1:\"c\";s:16:\"submissions.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}i:93;a:5:{s:1:\"a\";i:94;s:1:\"b\";i:8;s:1:\"c\";s:18:\"submissions.create\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}i:94;a:5:{s:1:\"a\";i:95;s:1:\"b\";i:8;s:1:\"c\";s:18:\"submissions.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:95;a:5:{s:1:\"a\";i:96;s:1:\"b\";i:8;s:1:\"c\";s:18:\"submissions.delete\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:96;a:5:{s:1:\"a\";i:97;s:1:\"b\";i:8;s:1:\"c\";s:11:\"grades.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}i:97;a:5:{s:1:\"a\";i:98;s:1:\"b\";i:8;s:1:\"c\";s:13:\"grades.update\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:4:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;}}i:98;a:5:{s:1:\"a\";i:99;s:1:\"b\";i:8;s:1:\"c\";s:17:\"report-cards.view\";s:1:\"d\";s:3:\"web\";s:1:\"r\";a:6:{i:0;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:4;i:5;i:5;i:6;}}}s:5:\"roles\";a:6:{i:0;a:3:{s:1:\"a\";i:1;s:1:\"c\";s:11:\"super-admin\";s:1:\"d\";s:3:\"web\";}i:1;a:3:{s:1:\"a\";i:2;s:1:\"c\";s:5:\"admin\";s:1:\"d\";s:3:\"web\";}i:2;a:3:{s:1:\"a\";i:3;s:1:\"c\";s:4:\"staf\";s:1:\"d\";s:3:\"web\";}i:3;a:3:{s:1:\"a\";i:4;s:1:\"c\";s:5:\"tutor\";s:1:\"d\";s:3:\"web\";}i:4;a:3:{s:1:\"a\";i:5;s:1:\"c\";s:5:\"siswa\";s:1:\"d\";s:3:\"web\";}i:5;a:3:{s:1:\"a\";i:6;s:1:\"c\";s:9:\"orang_tua\";s:1:\"d\";s:3:\"web\";}}}', 1790814317);

-- ----------------------------
-- Table structure for cache_locks
-- ----------------------------
DROP TABLE IF EXISTS `cache_locks`;
CREATE TABLE `cache_locks`  (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`) USING BTREE,
  INDEX `cache_locks_expiration_index`(`expiration` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cache_locks
-- ----------------------------

-- ----------------------------
-- Table structure for class_sessions
-- ----------------------------
DROP TABLE IF EXISTS `class_sessions`;
CREATE TABLE `class_sessions`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `school_class_id` bigint UNSIGNED NOT NULL,
  `schedule_id` bigint UNSIGNED NULL DEFAULT NULL,
  `session_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `room_id` bigint UNSIGNED NULL DEFAULT NULL,
  `tutor_id` bigint UNSIGNED NULL DEFAULT NULL,
  `substitute_tutor_id` bigint UNSIGNED NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'terjadwal',
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `material_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `tutor_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `class_sessions_schedule_id_foreign`(`schedule_id` ASC) USING BTREE,
  INDEX `class_sessions_room_id_foreign`(`room_id` ASC) USING BTREE,
  INDEX `class_sessions_tutor_id_foreign`(`tutor_id` ASC) USING BTREE,
  INDEX `class_sessions_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `class_sessions_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `class_sessions_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  INDEX `class_sessions_school_class_id_session_date_index`(`school_class_id` ASC, `session_date` ASC) USING BTREE,
  INDEX `class_sessions_session_date_index`(`session_date` ASC) USING BTREE,
  INDEX `class_sessions_substitute_tutor_id_foreign`(`substitute_tutor_id` ASC) USING BTREE,
  CONSTRAINT `class_sessions_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `class_sessions_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `class_sessions_room_id_foreign` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `class_sessions_schedule_id_foreign` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `class_sessions_school_class_id_foreign` FOREIGN KEY (`school_class_id`) REFERENCES `school_classes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `class_sessions_substitute_tutor_id_foreign` FOREIGN KEY (`substitute_tutor_id`) REFERENCES `tutors` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `class_sessions_tutor_id_foreign` FOREIGN KEY (`tutor_id`) REFERENCES `tutors` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `class_sessions_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of class_sessions
-- ----------------------------
INSERT INTO `class_sessions` VALUES (1, 1, 1, '2026-09-27', '10:00:00', '11:30:00', 1, 1, 6, 'terjadwal', 'test buka lagi', NULL, 'hadir', NULL, 1, NULL, '2026-09-29 07:21:18', '2026-09-30 15:23:13', NULL);
INSERT INTO `class_sessions` VALUES (2, 2, 3, '2026-09-29', '10:00:00', '11:30:00', 2, 2, NULL, 'terjadwal', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18', NULL);

-- ----------------------------
-- Table structure for course_settings
-- ----------------------------
DROP TABLE IF EXISTS `course_settings`;
CREATE TABLE `course_settings`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `school_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Gamma One',
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `academic_year` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `semester` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `invoice_due_days` int UNSIGNED NOT NULL DEFAULT 7,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `course_settings_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `course_settings_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `course_settings_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `course_settings_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `course_settings_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `course_settings_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_settings
-- ----------------------------
INSERT INTO `course_settings` VALUES (1, 'Gamma One', NULL, NULL, NULL, NULL, NULL, 7, NULL, 1, 1, NULL, '2026-09-29 07:58:45', '2026-09-29 07:58:45', NULL);

-- ----------------------------
-- Table structure for enrollments
-- ----------------------------
DROP TABLE IF EXISTS `enrollments`;
CREATE TABLE `enrollments`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `student_id` bigint UNSIGNED NOT NULL,
  `school_class_id` bigint UNSIGNED NOT NULL,
  `enrollment_date` date NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'aktif',
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `enrollments_student_id_school_class_id_unique`(`student_id` ASC, `school_class_id` ASC) USING BTREE,
  INDEX `enrollments_school_class_id_foreign`(`school_class_id` ASC) USING BTREE,
  INDEX `enrollments_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `enrollments_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `enrollments_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `enrollments_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `enrollments_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `enrollments_school_class_id_foreign` FOREIGN KEY (`school_class_id`) REFERENCES `school_classes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `enrollments_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `enrollments_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of enrollments
-- ----------------------------
INSERT INTO `enrollments` VALUES (1, 1, 1, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (2, 2, 1, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (3, 3, 1, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (4, 4, 1, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (5, 5, 1, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (6, 6, 1, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (7, 7, 1, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (8, 8, 1, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (9, 9, 2, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (10, 10, 2, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (11, 11, 2, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (12, 12, 2, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (13, 13, 3, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (14, 14, 3, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (15, 15, 3, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (16, 16, 4, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (17, 17, 4, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (18, 1, 5, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (19, 18, 6, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (20, 19, 6, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `enrollments` VALUES (21, 20, 6, '2026-09-29', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);

-- ----------------------------
-- Table structure for failed_jobs
-- ----------------------------
DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE `failed_jobs`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `failed_jobs_uuid_unique`(`uuid` ASC) USING BTREE,
  INDEX `failed_jobs_connection_queue_failed_at_index`(`connection` ASC, `queue` ASC, `failed_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of failed_jobs
-- ----------------------------

-- ----------------------------
-- Table structure for gateway_transactions
-- ----------------------------
DROP TABLE IF EXISTS `gateway_transactions`;
CREATE TABLE `gateway_transactions`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `invoice_id` bigint UNSIGNED NOT NULL,
  `provider` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'midtrans',
  `order_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gross_amount` bigint UNSIGNED NOT NULL,
  `payment_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `transaction_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `snap_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `payload` json NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `gateway_transactions_order_id_unique`(`order_id` ASC) USING BTREE,
  INDEX `gateway_transactions_invoice_id_index`(`invoice_id` ASC) USING BTREE,
  CONSTRAINT `gateway_transactions_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gateway_transactions
-- ----------------------------

-- ----------------------------
-- Table structure for grades
-- ----------------------------
DROP TABLE IF EXISTS `grades`;
CREATE TABLE `grades`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `assessment_id` bigint UNSIGNED NOT NULL,
  `student_id` bigint UNSIGNED NOT NULL,
  `score` decimal(5, 2) NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `graded_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `grades_assessment_id_student_id_unique`(`assessment_id` ASC, `student_id` ASC) USING BTREE,
  INDEX `grades_graded_by_foreign`(`graded_by` ASC) USING BTREE,
  INDEX `grades_student_id_index`(`student_id` ASC) USING BTREE,
  CONSTRAINT `grades_assessment_id_foreign` FOREIGN KEY (`assessment_id`) REFERENCES `assessments` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `grades_graded_by_foreign` FOREIGN KEY (`graded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `grades_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of grades
-- ----------------------------
INSERT INTO `grades` VALUES (1, 1, 1, 85.00, 'Pertahankan!', NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (2, 1, 2, 90.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (3, 1, 3, 78.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (4, 1, 4, 88.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (5, 1, 5, 92.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (6, 1, 6, 75.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (7, 1, 7, 80.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (8, 1, 8, 95.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (9, 2, 1, 88.00, 'Pertahankan!', NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (10, 2, 2, 92.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (11, 2, 3, 75.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (12, 2, 4, 80.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (13, 2, 5, 95.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (14, 2, 6, 85.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (15, 2, 7, 90.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `grades` VALUES (16, 2, 8, 78.00, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18');

-- ----------------------------
-- Table structure for invoices
-- ----------------------------
DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `invoice_no` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_id` bigint UNSIGNED NOT NULL,
  `enrollment_id` bigint UNSIGNED NULL DEFAULT NULL,
  `school_class_id` bigint UNSIGNED NULL DEFAULT NULL,
  `period` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `issue_date` date NOT NULL,
  `due_date` date NOT NULL,
  `amount` bigint UNSIGNED NOT NULL DEFAULT 0,
  `discount` bigint UNSIGNED NOT NULL DEFAULT 0,
  `registration_fee` bigint UNSIGNED NOT NULL DEFAULT 0,
  `total` bigint UNSIGNED NOT NULL DEFAULT 0,
  `paid_amount` bigint UNSIGNED NOT NULL DEFAULT 0,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'belum_bayar',
  `source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `invoices_invoice_no_unique`(`invoice_no` ASC) USING BTREE,
  INDEX `invoices_enrollment_id_foreign`(`enrollment_id` ASC) USING BTREE,
  INDEX `invoices_school_class_id_foreign`(`school_class_id` ASC) USING BTREE,
  INDEX `invoices_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `invoices_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `invoices_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  INDEX `invoices_student_id_status_index`(`student_id` ASC, `status` ASC) USING BTREE,
  INDEX `invoices_status_due_date_index`(`status` ASC, `due_date` ASC) USING BTREE,
  INDEX `invoices_period_index`(`period` ASC) USING BTREE,
  CONSTRAINT `invoices_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `invoices_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `invoices_enrollment_id_foreign` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `invoices_school_class_id_foreign` FOREIGN KEY (`school_class_id`) REFERENCES `school_classes` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `invoices_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `invoices_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of invoices
-- ----------------------------

-- ----------------------------
-- Table structure for job_batches
-- ----------------------------
DROP TABLE IF EXISTS `job_batches`;
CREATE TABLE `job_batches`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `cancelled_at` int NULL DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of job_batches
-- ----------------------------

-- ----------------------------
-- Table structure for jobs
-- ----------------------------
DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` smallint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED NULL DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `jobs_queue_index`(`queue` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jobs
-- ----------------------------
INSERT INTO `jobs` VALUES (1, 'default', '{\"uuid\":\"3b12feca-0b64-4921-99aa-7c0f24b23a2b\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:1;}\",\"batchId\":null},\"createdAt\":1790731310,\"delay\":null}', 0, NULL, 1790731310, 1790731310);
INSERT INTO `jobs` VALUES (2, 'default', '{\"uuid\":\"7f52612c-bc99-468b-8bc4-2c90a508fbaf\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:2;}\",\"batchId\":null},\"createdAt\":1790731310,\"delay\":null}', 0, NULL, 1790731310, 1790731310);
INSERT INTO `jobs` VALUES (3, 'default', '{\"uuid\":\"5320671d-ca09-4b93-b346-f94e55611b89\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:3;}\",\"batchId\":null},\"createdAt\":1790731310,\"delay\":null}', 0, NULL, 1790731310, 1790731310);
INSERT INTO `jobs` VALUES (4, 'default', '{\"uuid\":\"07582523-0402-4fac-b090-7a6a1d0441a2\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:4;}\",\"batchId\":null},\"createdAt\":1790731310,\"delay\":null}', 0, NULL, 1790731310, 1790731310);
INSERT INTO `jobs` VALUES (5, 'default', '{\"uuid\":\"be2b6a98-f35d-4e67-9b5f-e9bfee31c2f4\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:5;}\",\"batchId\":null},\"createdAt\":1790731310,\"delay\":null}', 0, NULL, 1790731310, 1790731310);
INSERT INTO `jobs` VALUES (6, 'default', '{\"uuid\":\"6fbf75f2-d18e-4d4b-92b1-15f5658323a4\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:6;}\",\"batchId\":null},\"createdAt\":1790731310,\"delay\":null}', 0, NULL, 1790731310, 1790731310);
INSERT INTO `jobs` VALUES (7, 'default', '{\"uuid\":\"4983d8d9-973c-4ef7-a2d6-3d2e7f0d0ee5\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:7;}\",\"batchId\":null},\"createdAt\":1790731310,\"delay\":null}', 0, NULL, 1790731310, 1790731310);
INSERT INTO `jobs` VALUES (8, 'default', '{\"uuid\":\"583971e5-8976-4c20-ba73-1a837573da85\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:8;}\",\"batchId\":null},\"createdAt\":1790731310,\"delay\":null}', 0, NULL, 1790731310, 1790731310);
INSERT INTO `jobs` VALUES (9, 'default', '{\"uuid\":\"836e0d69-0bc3-4e55-8037-28b917a2900a\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:9;}\",\"batchId\":null},\"createdAt\":1790732768,\"delay\":null}', 0, NULL, 1790732768, 1790732768);
INSERT INTO `jobs` VALUES (10, 'default', '{\"uuid\":\"964ca345-ee63-418c-8d25-9d1cba125f84\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:10;}\",\"batchId\":null},\"createdAt\":1790754038,\"delay\":null}', 0, NULL, 1790754038, 1790754038);
INSERT INTO `jobs` VALUES (11, 'default', '{\"uuid\":\"42429364-017a-4ecb-9931-0dfa7074fd81\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:11;}\",\"batchId\":null},\"createdAt\":1790754038,\"delay\":null}', 0, NULL, 1790754038, 1790754038);
INSERT INTO `jobs` VALUES (12, 'default', '{\"uuid\":\"bd6259f0-e103-4ef5-9d5e-6fc62a03cdb9\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:12;}\",\"batchId\":null},\"createdAt\":1790754038,\"delay\":null}', 0, NULL, 1790754038, 1790754038);
INSERT INTO `jobs` VALUES (13, 'default', '{\"uuid\":\"1dc71183-6714-4e0b-9b54-c77a72b3df6b\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:13;}\",\"batchId\":null},\"createdAt\":1790754038,\"delay\":null}', 0, NULL, 1790754038, 1790754038);
INSERT INTO `jobs` VALUES (14, 'default', '{\"uuid\":\"1e845fc9-08ae-4a89-bd7d-a8344204d281\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:14;}\",\"batchId\":null},\"createdAt\":1790754038,\"delay\":null}', 0, NULL, 1790754038, 1790754038);
INSERT INTO `jobs` VALUES (15, 'default', '{\"uuid\":\"7f8af171-3e0e-4dcb-a588-8c8f28a79646\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:15;}\",\"batchId\":null},\"createdAt\":1790754038,\"delay\":null}', 0, NULL, 1790754038, 1790754038);
INSERT INTO `jobs` VALUES (16, 'default', '{\"uuid\":\"2532e9ce-a327-421c-980e-57fe582a6781\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:16;}\",\"batchId\":null},\"createdAt\":1790754039,\"delay\":null}', 0, NULL, 1790754039, 1790754039);
INSERT INTO `jobs` VALUES (17, 'default', '{\"uuid\":\"fc3bd87a-3c52-44d2-a115-a4c0ccd7872c\",\"displayName\":\"App\\\\Jobs\\\\SendNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"60,300,900\",\"timeout\":null,\"retryUntil\":null,\"deleteWhenMissingModels\":false,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendNotification\",\"command\":\"O:25:\\\"App\\\\Jobs\\\\SendNotification\\\":1:{s:14:\\\"notificationId\\\";i:17;}\",\"batchId\":null},\"createdAt\":1790754039,\"delay\":null}', 0, NULL, 1790754039, 1790754039);

-- ----------------------------
-- Table structure for materials
-- ----------------------------
DROP TABLE IF EXISTS `materials`;
CREATE TABLE `materials`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `school_class_id` bigint UNSIGNED NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `file_url` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `materials_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `materials_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `materials_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  INDEX `materials_school_class_id_index`(`school_class_id` ASC) USING BTREE,
  CONSTRAINT `materials_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `materials_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `materials_school_class_id_foreign` FOREIGN KEY (`school_class_id`) REFERENCES `school_classes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `materials_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of materials
-- ----------------------------
INSERT INTO `materials` VALUES (1, 1, 'Ringkasan Aljabar Dasar', 'Materi contoh fiktif.', '/images/logo-gamma-one.svg', NULL, NULL, NULL, '2026-09-29 07:21:18', '2026-09-29 07:21:18', NULL);
INSERT INTO `materials` VALUES (2, 1, 'Bangun Datar', NULL, 'http://localhost:8000/storage/uploads/dlFRJAS1azpXJZyg69PcKhyDFdMG2ybsmiu5SiNq.pdf', 1, 1, NULL, '2026-09-29 08:03:40', '2026-09-29 08:03:40', NULL);

-- ----------------------------
-- Table structure for menus
-- ----------------------------
DROP TABLE IF EXISTS `menus`;
CREATE TABLE `menus`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sort_order` int UNSIGNED NOT NULL DEFAULT 0,
  `parent_id` bigint UNSIGNED NULL DEFAULT NULL,
  `permission_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `menus_parent_id_foreign`(`parent_id` ASC) USING BTREE,
  INDEX `menus_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `menus_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `menus_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `menus_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `menus_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `menus_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `menus` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `menus_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of menus
-- ----------------------------
INSERT INTO `menus` VALUES (1, NULL, NULL, NULL, 'Pengaturan', NULL, 'SettingOutlined', 99, NULL, NULL, 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (2, NULL, NULL, NULL, 'Dashboard', '/dashboard', 'DashboardOutlined', 1, NULL, NULL, 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (3, NULL, NULL, NULL, 'Users', '/users', 'TeamOutlined', 1, 1, 'users.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (4, NULL, NULL, NULL, 'Roles', '/roles', 'SafetyCertificateOutlined', 2, 1, 'roles.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (5, NULL, NULL, NULL, 'Permission Groups', '/permission-groups', 'AppstoreOutlined', 3, 1, 'permission-groups.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (6, NULL, NULL, NULL, 'Permissions', '/permissions', 'LockOutlined', 4, 1, 'permissions.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (7, NULL, NULL, NULL, 'Menus', '/menus', 'MenuOutlined', 5, 1, 'menus.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (8, NULL, NULL, NULL, 'Aplikasi', '/app-settings', 'ApartmentOutlined', 6, 1, 'app-settings.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (9, NULL, NULL, NULL, 'Audit Log', '/blamable-logs', 'HistoryOutlined', 7, 1, 'blamable-logs.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (10, NULL, NULL, NULL, 'Data Master', NULL, 'BookOutlined', 10, NULL, NULL, 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (11, NULL, NULL, NULL, 'Programs', '/programs', 'AppstoreAddOutlined', 1, 10, 'programs.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (12, NULL, NULL, NULL, 'Subjects', '/subjects', 'ReadOutlined', 2, 10, 'subjects.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (13, NULL, NULL, NULL, 'Rooms', '/rooms', 'HomeOutlined', 3, 10, 'rooms.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (14, NULL, NULL, NULL, 'Classes', '/classes', 'TeamOutlined', 4, 10, 'classes.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (15, NULL, NULL, NULL, 'Students', '/students', 'UserOutlined', 5, 10, 'students.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (16, NULL, NULL, NULL, 'Parents', '/parents', 'HeartOutlined', 6, 10, 'parents.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (17, NULL, NULL, NULL, 'Tutors', '/tutors', 'SolutionOutlined', 7, 10, 'tutors.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (18, NULL, NULL, NULL, 'Enrollments', '/enrollments', 'FormOutlined', 8, 10, 'enrollments.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (19, NULL, NULL, NULL, 'Penjadwalan', NULL, 'CalendarOutlined', 11, NULL, NULL, 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (20, NULL, NULL, NULL, 'Jadwal', '/schedules', 'ClockCircleOutlined', 1, 19, 'schedules.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (21, NULL, NULL, NULL, 'Sesi & Absensi', '/sessions', 'CheckSquareOutlined', 2, 19, 'sessions.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (22, NULL, NULL, NULL, 'Keuangan', NULL, 'WalletOutlined', 12, NULL, NULL, 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (23, NULL, NULL, NULL, 'Invoices', '/invoices', 'FileTextOutlined', 1, 22, 'invoices.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (24, NULL, NULL, NULL, 'Pembayaran', '/payments', 'DollarOutlined', 2, 22, 'payments.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (25, NULL, NULL, NULL, 'Gaji Tutor', '/payrolls', 'BankOutlined', 3, 22, 'payrolls.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (26, NULL, NULL, NULL, 'Notifikasi', NULL, 'BellOutlined', 13, NULL, NULL, 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (27, NULL, NULL, NULL, 'Template Pesan', '/notification-templates', 'MessageOutlined', 1, 26, 'notification-templates.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (28, NULL, NULL, NULL, 'Log Notifikasi', '/notifications', 'HistoryOutlined', 2, 26, 'notifications.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (29, NULL, NULL, NULL, 'Akademik', NULL, 'TrophyOutlined', 14, NULL, NULL, 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (30, NULL, NULL, NULL, 'Asesmen & Nilai', '/assessments', 'EditOutlined', 1, 29, 'assessments.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (31, NULL, NULL, NULL, 'Materi', '/materials', 'ReadOutlined', 2, 29, 'materials.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (32, NULL, NULL, NULL, 'Tugas', '/assignments', 'FormOutlined', 3, 29, 'assignments.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `menus` VALUES (33, NULL, NULL, NULL, 'Rapor', '/report-cards', 'FileTextOutlined', 4, 29, 'report-cards.view', 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);

-- ----------------------------
-- Table structure for migrations
-- ----------------------------
DROP TABLE IF EXISTS `migrations`;
CREATE TABLE `migrations`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of migrations
-- ----------------------------
INSERT INTO `migrations` VALUES (1, '0001_01_01_000000_create_users_table', 1);
INSERT INTO `migrations` VALUES (2, '0001_01_01_000001_create_cache_table', 1);
INSERT INTO `migrations` VALUES (3, '0001_01_01_000002_create_jobs_table', 1);
INSERT INTO `migrations` VALUES (4, '2026_05_19_044251_create_permission_tables', 1);
INSERT INTO `migrations` VALUES (5, '2026_05_19_044251_create_personal_access_tokens_table', 1);
INSERT INTO `migrations` VALUES (6, '2026_05_19_050000_create_permission_groups_table', 1);
INSERT INTO `migrations` VALUES (7, '2026_05_19_050100_add_permission_group_id_to_permissions_table', 1);
INSERT INTO `migrations` VALUES (8, '2026_05_19_050200_create_menus_table', 1);
INSERT INTO `migrations` VALUES (9, '2026_05_19_130000_create_app_settings_table', 1);
INSERT INTO `migrations` VALUES (10, '2026_05_19_130100_add_avatar_url_to_users_table', 1);
INSERT INTO `migrations` VALUES (11, '2026_05_20_000005_add_softdeletes_and_blamable_columns', 1);
INSERT INTO `migrations` VALUES (12, '2026_09_28_000001_add_phone_to_users_table', 1);
INSERT INTO `migrations` VALUES (13, '2026_09_29_000001_create_master_tables', 1);
INSERT INTO `migrations` VALUES (14, '2026_09_29_000002_create_people_tables', 1);
INSERT INTO `migrations` VALUES (15, '2026_09_29_000003_create_academic_tables', 1);
INSERT INTO `migrations` VALUES (16, '2026_09_30_000001_create_scheduling_tables', 1);
INSERT INTO `migrations` VALUES (17, '2026_10_01_000001_create_finance_tables', 1);
INSERT INTO `migrations` VALUES (18, '2026_10_05_000001_create_notification_tables', 1);
INSERT INTO `migrations` VALUES (19, '2026_10_10_000001_create_academic_tables', 1);
INSERT INTO `migrations` VALUES (20, '2026_10_12_000001_create_course_settings_table', 1);
INSERT INTO `migrations` VALUES (21, '2026_10_12_000002_add_reporting_indexes', 1);
INSERT INTO `migrations` VALUES (22, '2026_10_15_000001_add_session_substitute', 2);

-- ----------------------------
-- Table structure for model_has_permissions
-- ----------------------------
DROP TABLE IF EXISTS `model_has_permissions`;
CREATE TABLE `model_has_permissions`  (
  `permission_id` bigint UNSIGNED NOT NULL,
  `model_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_id` bigint UNSIGNED NOT NULL,
  PRIMARY KEY (`permission_id`, `model_id`, `model_type`) USING BTREE,
  INDEX `model_has_permissions_model_id_model_type_index`(`model_id` ASC, `model_type` ASC) USING BTREE,
  CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of model_has_permissions
-- ----------------------------

-- ----------------------------
-- Table structure for model_has_roles
-- ----------------------------
DROP TABLE IF EXISTS `model_has_roles`;
CREATE TABLE `model_has_roles`  (
  `role_id` bigint UNSIGNED NOT NULL,
  `model_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_id` bigint UNSIGNED NOT NULL,
  PRIMARY KEY (`role_id`, `model_id`, `model_type`) USING BTREE,
  INDEX `model_has_roles_model_id_model_type_index`(`model_id` ASC, `model_type` ASC) USING BTREE,
  CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of model_has_roles
-- ----------------------------
INSERT INTO `model_has_roles` VALUES (1, 'App\\Models\\User', 1);
INSERT INTO `model_has_roles` VALUES (2, 'App\\Models\\User', 2);
INSERT INTO `model_has_roles` VALUES (3, 'App\\Models\\User', 3);
INSERT INTO `model_has_roles` VALUES (4, 'App\\Models\\User', 4);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 5);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 6);
INSERT INTO `model_has_roles` VALUES (4, 'App\\Models\\User', 7);
INSERT INTO `model_has_roles` VALUES (4, 'App\\Models\\User', 8);
INSERT INTO `model_has_roles` VALUES (4, 'App\\Models\\User', 9);
INSERT INTO `model_has_roles` VALUES (4, 'App\\Models\\User', 10);
INSERT INTO `model_has_roles` VALUES (4, 'App\\Models\\User', 11);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 12);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 13);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 14);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 15);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 16);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 17);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 18);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 19);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 20);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 21);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 22);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 23);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 24);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 25);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 26);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 27);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 28);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 29);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 30);
INSERT INTO `model_has_roles` VALUES (5, 'App\\Models\\User', 31);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 32);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 33);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 34);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 35);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 36);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 37);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 38);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 39);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 40);
INSERT INTO `model_has_roles` VALUES (6, 'App\\Models\\User', 41);
INSERT INTO `model_has_roles` VALUES (4, 'App\\Models\\User', 42);

-- ----------------------------
-- Table structure for notification_preferences
-- ----------------------------
DROP TABLE IF EXISTS `notification_preferences`;
CREATE TABLE `notification_preferences`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `wa_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `email_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `notification_preferences_user_id_unique`(`user_id` ASC) USING BTREE,
  CONSTRAINT `notification_preferences_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification_preferences
-- ----------------------------
INSERT INTO `notification_preferences` VALUES (1, 32, 1, 1, '2026-09-29 14:51:46', '2026-09-29 14:51:46');
INSERT INTO `notification_preferences` VALUES (2, 33, 1, 1, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notification_preferences` VALUES (3, 34, 1, 1, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notification_preferences` VALUES (4, 35, 1, 1, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notification_preferences` VALUES (5, 42, 1, 1, '2026-09-30 08:46:08', '2026-09-30 08:46:08');
INSERT INTO `notification_preferences` VALUES (6, 7, 1, 1, '2026-09-30 09:28:15', '2026-09-30 09:28:15');

-- ----------------------------
-- Table structure for notification_templates
-- ----------------------------
DROP TABLE IF EXISTS `notification_templates`;
CREATE TABLE `notification_templates`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `notification_templates_key_unique`(`key` ASC) USING BTREE,
  INDEX `notification_templates_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `notification_templates_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `notification_templates_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `notification_templates_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `notification_templates_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `notification_templates_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification_templates
-- ----------------------------
INSERT INTO `notification_templates` VALUES (1, 'jadwal_h1', 'Pengingat jadwal H-1', 'Halo {nama},\nBesok {tanggal} ada jadwal {kelas} pukul {jam} untuk {siswa}.\n— Gamma One', 1, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `notification_templates` VALUES (2, 'kehadiran_ortu', 'Kehadiran ke orang tua', 'Halo {nama},\n{siswa} tercatat {status} pada {kelas} tanggal {tanggal}.\n— Gamma One', 1, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `notification_templates` VALUES (3, 'tagihan_baru', 'Tagihan baru', 'Halo {nama},\nTagihan {invoice} untuk {siswa} sebesar Rp{nominal}, jatuh tempo {jatuh_tempo}.\n— Gamma One', 1, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `notification_templates` VALUES (4, 'tagihan_jatuh_tempo', 'Pengingat jatuh tempo', 'Halo {nama},\nTagihan {invoice} untuk {siswa} sebesar Rp{nominal} telah jatuh tempo. Segera lunasi.\n— Gamma One', 1, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `notification_templates` VALUES (5, 'pembayaran_lunas', 'Konfirmasi pembayaran', 'Halo {nama},\nPembayaran Rp{nominal} untuk {invoice} diterima. Sisa Rp{sisa}.\n— Gamma One', 1, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `notification_templates` VALUES (6, 'selamat_datang', 'Selamat datang', 'Halo {nama},\nSelamat datang di Gamma One — One Step, One Growth.\n— Gamma One', 1, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `channel` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'wa',
  `template_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `attempts` int UNSIGNED NOT NULL DEFAULT 0,
  `error` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `related_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `related_id` bigint UNSIGNED NULL DEFAULT NULL,
  `needs_follow_up` tinyint(1) NOT NULL DEFAULT 0,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `notifications_related_type_related_id_index`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `notifications_status_index`(`status` ASC) USING BTREE,
  INDEX `notifications_user_id_status_index`(`user_id` ASC, `status` ASC) USING BTREE,
  CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (1, 32, '628230000011', 'ortu1@contoh.local', 'wa', 'jadwal_berubah', 'Halo Hendra Wijaya,\nSesi Matematika 7A untuk Andi Wijaya dijadwal ulang ke 2026-09-27 pukul 10:00. Alasan: mundur 2 jam.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notifications` VALUES (2, 32, '628230000011', 'ortu1@contoh.local', 'wa', 'jadwal_berubah', 'Halo Hendra Wijaya,\nSesi Matematika 7A untuk Bella Putri dijadwal ulang ke 2026-09-27 pukul 10:00. Alasan: mundur 2 jam.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notifications` VALUES (3, 33, '628230000012', 'ortu2@contoh.local', 'wa', 'jadwal_berubah', 'Halo Ratna Sari,\nSesi Matematika 7A untuk Candra Gunawan dijadwal ulang ke 2026-09-27 pukul 10:00. Alasan: mundur 2 jam.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notifications` VALUES (4, 33, '628230000012', 'ortu2@contoh.local', 'wa', 'jadwal_berubah', 'Halo Ratna Sari,\nSesi Matematika 7A untuk Dinda Safitri dijadwal ulang ke 2026-09-27 pukul 10:00. Alasan: mundur 2 jam.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notifications` VALUES (5, 34, '628230000013', 'ortu3@contoh.local', 'wa', 'jadwal_berubah', 'Halo Joko Susilo,\nSesi Matematika 7A untuk Eko Saputra dijadwal ulang ke 2026-09-27 pukul 10:00. Alasan: mundur 2 jam.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notifications` VALUES (6, 34, '628230000013', 'ortu3@contoh.local', 'wa', 'jadwal_berubah', 'Halo Joko Susilo,\nSesi Matematika 7A untuk Fitri Handayani dijadwal ulang ke 2026-09-27 pukul 10:00. Alasan: mundur 2 jam.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notifications` VALUES (7, 35, '628230000014', 'ortu4@contoh.local', 'wa', 'jadwal_berubah', 'Halo Mega Wati,\nSesi Matematika 7A untuk Gilang Ramadhan dijadwal ulang ke 2026-09-27 pukul 10:00. Alasan: mundur 2 jam.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notifications` VALUES (8, 35, '628230000014', 'ortu4@contoh.local', 'wa', 'jadwal_berubah', 'Halo Mega Wati,\nSesi Matematika 7A untuk Hana Kusuma dijadwal ulang ke 2026-09-27 pukul 10:00. Alasan: mundur 2 jam.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 08:21:50', '2026-09-30 08:21:50');
INSERT INTO `notifications` VALUES (9, 42, '628996844000', 'yos@gmail.com', 'wa', 'selamat_datang', 'Halo Yosi AWK,\nSelamat datang di Gamma One — One Step, One Growth.\n— Gamma One', 'pending', 0, NULL, NULL, NULL, 0, NULL, '2026-09-30 08:46:08', '2026-09-30 08:46:08');
INSERT INTO `notifications` VALUES (10, 32, '628230000011', 'ortu1@contoh.local', 'wa', 'kehadiran_ortu', 'Halo Hendra Wijaya,\nAndi Wijaya tercatat hadir pada Matematika 7A tanggal 2026-09-27.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 14:40:38', '2026-09-30 14:40:38');
INSERT INTO `notifications` VALUES (11, 32, '628230000011', 'ortu1@contoh.local', 'wa', 'kehadiran_ortu', 'Halo Hendra Wijaya,\nBella Putri tercatat hadir pada Matematika 7A tanggal 2026-09-27.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 14:40:38', '2026-09-30 14:40:38');
INSERT INTO `notifications` VALUES (12, 33, '628230000012', 'ortu2@contoh.local', 'wa', 'kehadiran_ortu', 'Halo Ratna Sari,\nCandra Gunawan tercatat hadir pada Matematika 7A tanggal 2026-09-27.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 14:40:38', '2026-09-30 14:40:38');
INSERT INTO `notifications` VALUES (13, 33, '628230000012', 'ortu2@contoh.local', 'wa', 'kehadiran_ortu', 'Halo Ratna Sari,\nDinda Safitri tercatat hadir pada Matematika 7A tanggal 2026-09-27.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 14:40:38', '2026-09-30 14:40:38');
INSERT INTO `notifications` VALUES (14, 34, '628230000013', 'ortu3@contoh.local', 'wa', 'kehadiran_ortu', 'Halo Joko Susilo,\nEko Saputra tercatat hadir pada Matematika 7A tanggal 2026-09-27.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 14:40:38', '2026-09-30 14:40:38');
INSERT INTO `notifications` VALUES (15, 34, '628230000013', 'ortu3@contoh.local', 'wa', 'kehadiran_ortu', 'Halo Joko Susilo,\nFitri Handayani tercatat hadir pada Matematika 7A tanggal 2026-09-27.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 14:40:38', '2026-09-30 14:40:38');
INSERT INTO `notifications` VALUES (16, 35, '628230000014', 'ortu4@contoh.local', 'wa', 'kehadiran_ortu', 'Halo Mega Wati,\nGilang Ramadhan tercatat hadir pada Matematika 7A tanggal 2026-09-27.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 14:40:38', '2026-09-30 14:40:38');
INSERT INTO `notifications` VALUES (17, 35, '628230000014', 'ortu4@contoh.local', 'wa', 'kehadiran_ortu', 'Halo Mega Wati,\nHana Kusuma tercatat hadir pada Matematika 7A tanggal 2026-09-27.\n— Gamma One', 'pending', 0, NULL, 'App\\Models\\Session', 1, 0, NULL, '2026-09-30 14:40:39', '2026-09-30 14:40:39');

-- ----------------------------
-- Table structure for parent_student
-- ----------------------------
DROP TABLE IF EXISTS `parent_student`;
CREATE TABLE `parent_student`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `parent_id` bigint UNSIGNED NOT NULL,
  `student_id` bigint UNSIGNED NOT NULL,
  `relationship` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'wali',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `parent_student_parent_id_student_id_unique`(`parent_id` ASC, `student_id` ASC) USING BTREE,
  INDEX `parent_student_student_id_foreign`(`student_id` ASC) USING BTREE,
  CONSTRAINT `parent_student_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `parent_student_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of parent_student
-- ----------------------------
INSERT INTO `parent_student` VALUES (1, 1, 1, 'ayah', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `parent_student` VALUES (2, 1, 2, 'ayah', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `parent_student` VALUES (3, 2, 3, 'ibu', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `parent_student` VALUES (4, 2, 4, 'ibu', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `parent_student` VALUES (5, 3, 5, 'ayah', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `parent_student` VALUES (6, 3, 6, 'ayah', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `parent_student` VALUES (7, 4, 7, 'ibu', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `parent_student` VALUES (8, 4, 8, 'ibu', '2026-09-29 07:21:15', '2026-09-29 07:21:15');
INSERT INTO `parent_student` VALUES (9, 5, 9, 'ayah', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `parent_student` VALUES (10, 5, 10, 'ayah', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `parent_student` VALUES (11, 6, 11, 'ibu', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `parent_student` VALUES (12, 6, 12, 'ibu', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `parent_student` VALUES (13, 7, 13, 'ayah', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `parent_student` VALUES (14, 7, 14, 'ayah', '2026-09-29 07:21:16', '2026-09-29 07:21:16');
INSERT INTO `parent_student` VALUES (15, 8, 15, 'ibu', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `parent_student` VALUES (16, 8, 16, 'ibu', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `parent_student` VALUES (17, 9, 17, 'ayah', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `parent_student` VALUES (18, 9, 18, 'ayah', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `parent_student` VALUES (19, 10, 19, 'ibu', '2026-09-29 07:21:17', '2026-09-29 07:21:17');
INSERT INTO `parent_student` VALUES (20, 10, 20, 'ibu', '2026-09-29 07:21:17', '2026-09-29 07:21:17');

-- ----------------------------
-- Table structure for parents
-- ----------------------------
DROP TABLE IF EXISTS `parents`;
CREATE TABLE `parents`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `parents_user_id_unique`(`user_id` ASC) USING BTREE,
  INDEX `parents_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `parents_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `parents_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `parents_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `parents_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `parents_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `parents_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of parents
-- ----------------------------
INSERT INTO `parents` VALUES (1, 32, 'Hendra Wijaya', '628230000011', NULL, NULL, NULL, NULL, '2026-09-29 07:21:15', '2026-09-29 07:21:15', NULL);
INSERT INTO `parents` VALUES (2, 33, 'Ratna Sari', '628230000012', NULL, NULL, NULL, NULL, '2026-09-29 07:21:15', '2026-09-29 07:21:15', NULL);
INSERT INTO `parents` VALUES (3, 34, 'Joko Susilo', '628230000013', NULL, NULL, NULL, NULL, '2026-09-29 07:21:15', '2026-09-29 07:21:15', NULL);
INSERT INTO `parents` VALUES (4, 35, 'Mega Wati', '628230000014', NULL, NULL, NULL, NULL, '2026-09-29 07:21:15', '2026-09-29 07:21:15', NULL);
INSERT INTO `parents` VALUES (5, 36, 'Yusuf Hidayat', '628230000015', NULL, NULL, NULL, NULL, '2026-09-29 07:21:16', '2026-09-29 07:21:16', NULL);
INSERT INTO `parents` VALUES (6, 37, 'Sri Mulyani', '628230000016', NULL, NULL, NULL, NULL, '2026-09-29 07:21:16', '2026-09-29 07:21:16', NULL);
INSERT INTO `parents` VALUES (7, 38, 'Dedi Kurniawan', '628230000017', NULL, NULL, NULL, NULL, '2026-09-29 07:21:16', '2026-09-29 07:21:16', NULL);
INSERT INTO `parents` VALUES (8, 39, 'Nina Kurnia', '628230000018', NULL, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `parents` VALUES (9, 40, 'Fajar Nugroho', '628230000019', NULL, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `parents` VALUES (10, 41, 'Wulan Purnama', '628230000020', NULL, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);

-- ----------------------------
-- Table structure for password_reset_tokens
-- ----------------------------
DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE `password_reset_tokens`  (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of password_reset_tokens
-- ----------------------------

-- ----------------------------
-- Table structure for payments
-- ----------------------------
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `invoice_id` bigint UNSIGNED NOT NULL,
  `amount` bigint UNSIGNED NOT NULL,
  `method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'tunai',
  `paid_at` date NOT NULL,
  `proof_url` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `payments_reference_unique`(`reference` ASC) USING BTREE,
  INDEX `payments_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `payments_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `payments_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  INDEX `payments_invoice_id_index`(`invoice_id` ASC) USING BTREE,
  INDEX `payments_paid_at_index`(`paid_at` ASC) USING BTREE,
  CONSTRAINT `payments_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `payments_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `payments_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `payments_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of payments
-- ----------------------------

-- ----------------------------
-- Table structure for permission_groups
-- ----------------------------
DROP TABLE IF EXISTS `permission_groups`;
CREATE TABLE `permission_groups`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `permission_groups_name_unique`(`name` ASC) USING BTREE,
  UNIQUE INDEX `permission_groups_slug_unique`(`slug` ASC) USING BTREE,
  INDEX `permission_groups_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `permission_groups_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `permission_groups_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `permission_groups_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `permission_groups_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `permission_groups_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of permission_groups
-- ----------------------------
INSERT INTO `permission_groups` VALUES (1, NULL, NULL, NULL, 'Manajemen Pengguna', 'user-management', NULL, '2026-09-29 07:21:04', '2026-09-29 07:21:04', NULL);
INSERT INTO `permission_groups` VALUES (2, NULL, NULL, NULL, 'Peran & Izin', 'role-permission', NULL, '2026-09-29 07:21:04', '2026-09-29 07:21:04', NULL);
INSERT INTO `permission_groups` VALUES (3, NULL, NULL, NULL, 'Sistem', 'system', NULL, '2026-09-29 07:21:04', '2026-09-29 07:21:04', NULL);
INSERT INTO `permission_groups` VALUES (4, NULL, NULL, NULL, 'Data Master', 'master-data', NULL, '2026-09-29 07:21:04', '2026-09-29 07:21:04', NULL);
INSERT INTO `permission_groups` VALUES (5, NULL, NULL, NULL, 'Penjadwalan & Absensi', 'scheduling', NULL, '2026-09-29 07:21:04', '2026-09-29 07:21:04', NULL);
INSERT INTO `permission_groups` VALUES (6, NULL, NULL, NULL, 'Keuangan', 'finance', NULL, '2026-09-29 07:21:04', '2026-09-29 07:21:04', NULL);
INSERT INTO `permission_groups` VALUES (7, NULL, NULL, NULL, 'Notifikasi', 'notification', NULL, '2026-09-29 07:21:04', '2026-09-29 07:21:04', NULL);
INSERT INTO `permission_groups` VALUES (8, NULL, NULL, NULL, 'Akademik', 'academic', NULL, '2026-09-29 07:21:04', '2026-09-29 07:21:04', NULL);

-- ----------------------------
-- Table structure for permissions
-- ----------------------------
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `permission_group_id` bigint UNSIGNED NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `guard_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `permissions_name_guard_name_unique`(`name` ASC, `guard_name` ASC) USING BTREE,
  INDEX `permissions_permission_group_id_foreign`(`permission_group_id` ASC) USING BTREE,
  CONSTRAINT `permissions_permission_group_id_foreign` FOREIGN KEY (`permission_group_id`) REFERENCES `permission_groups` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of permissions
-- ----------------------------
INSERT INTO `permissions` VALUES (1, 1, 'users.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (2, 1, 'users.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (3, 1, 'users.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (4, 1, 'users.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (5, 2, 'roles.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (6, 2, 'roles.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (7, 2, 'roles.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (8, 2, 'roles.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (9, 2, 'permissions.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (10, 2, 'permissions.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (11, 2, 'permissions.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (12, 2, 'permissions.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (13, 2, 'permission-groups.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (14, 2, 'permission-groups.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (15, 2, 'permission-groups.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (16, 2, 'permission-groups.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (17, 3, 'menus.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (18, 3, 'menus.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (19, 3, 'menus.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (20, 3, 'menus.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (21, 3, 'app-settings.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (22, 3, 'app-settings.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (23, 3, 'blamable-logs.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (24, 4, 'students.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (25, 4, 'students.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (26, 4, 'students.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (27, 4, 'students.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (28, 4, 'parents.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (29, 4, 'parents.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (30, 4, 'parents.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (31, 4, 'parents.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (32, 4, 'tutors.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (33, 4, 'tutors.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (34, 4, 'tutors.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (35, 4, 'tutors.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (36, 4, 'programs.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (37, 4, 'programs.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (38, 4, 'programs.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (39, 4, 'programs.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (40, 4, 'subjects.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (41, 4, 'subjects.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (42, 4, 'subjects.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (43, 4, 'subjects.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (44, 4, 'rooms.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (45, 4, 'rooms.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (46, 4, 'rooms.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (47, 4, 'rooms.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (48, 4, 'classes.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (49, 4, 'classes.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (50, 4, 'classes.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (51, 4, 'classes.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (52, 4, 'enrollments.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (53, 4, 'enrollments.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (54, 4, 'enrollments.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (55, 4, 'enrollments.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (56, 5, 'schedules.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (57, 5, 'schedules.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (58, 5, 'schedules.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (59, 5, 'schedules.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (60, 5, 'sessions.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (61, 5, 'sessions.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (62, 5, 'sessions.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (63, 5, 'sessions.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (64, 6, 'invoices.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (65, 6, 'invoices.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (66, 6, 'invoices.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (67, 6, 'invoices.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (68, 6, 'payments.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (69, 6, 'payments.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (70, 6, 'payments.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (71, 6, 'payments.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (72, 6, 'payrolls.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (73, 7, 'notification-templates.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (74, 7, 'notification-templates.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (75, 7, 'notification-templates.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (76, 7, 'notification-templates.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (77, 7, 'notifications.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (78, 7, 'notifications.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (79, 7, 'notifications.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (80, 7, 'notifications.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (81, 8, 'assessments.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (82, 8, 'assessments.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (83, 8, 'assessments.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (84, 8, 'assessments.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (85, 8, 'materials.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (86, 8, 'materials.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (87, 8, 'materials.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (88, 8, 'materials.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (89, 8, 'assignments.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (90, 8, 'assignments.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (91, 8, 'assignments.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (92, 8, 'assignments.delete', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (93, 8, 'submissions.view', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (94, 8, 'submissions.create', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (95, 8, 'submissions.update', 'web', '2026-09-29 07:21:04', '2026-09-29 07:21:04');
INSERT INTO `permissions` VALUES (96, 8, 'submissions.delete', 'web', '2026-09-29 07:21:05', '2026-09-29 07:21:05');
INSERT INTO `permissions` VALUES (97, 8, 'grades.view', 'web', '2026-09-29 07:21:05', '2026-09-29 07:21:05');
INSERT INTO `permissions` VALUES (98, 8, 'grades.update', 'web', '2026-09-29 07:21:05', '2026-09-29 07:21:05');
INSERT INTO `permissions` VALUES (99, 8, 'report-cards.view', 'web', '2026-09-29 07:21:05', '2026-09-29 07:21:05');

-- ----------------------------
-- Table structure for personal_access_tokens
-- ----------------------------
DROP TABLE IF EXISTS `personal_access_tokens`;
CREATE TABLE `personal_access_tokens`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `personal_access_tokens_token_unique`(`token` ASC) USING BTREE,
  INDEX `personal_access_tokens_tokenable_type_tokenable_id_index`(`tokenable_type` ASC, `tokenable_id` ASC) USING BTREE,
  INDEX `personal_access_tokens_expires_at_index`(`expires_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of personal_access_tokens
-- ----------------------------
INSERT INTO `personal_access_tokens` VALUES (2, 'App\\Models\\User', 1, 'gamma-one-token', 'c964c0784b6a19af4330b98bd1d3536f2b05dc7fa3372bad096764bfb218cf7f', '[\"*\"]', '2026-09-29 09:55:29', '2026-09-29 10:00:12', '2026-09-29 08:00:12', '2026-09-29 09:55:29');
INSERT INTO `personal_access_tokens` VALUES (6, 'App\\Models\\User', 1, 'gamma-one-token', '889c59c9a5f01ecb650fcae39e5436d6c35266eff5c6dfc8d9800a8f6227f08d', '[\"*\"]', '2026-09-29 15:00:41', '2026-09-29 16:49:35', '2026-09-29 14:49:35', '2026-09-29 15:00:41');
INSERT INTO `personal_access_tokens` VALUES (8, 'App\\Models\\User', 13, 'gamma-one-token', '477a926da38c1fd5c79f001e5a62754b55c6da1cbd408ae1bf325b07274a0511', '[\"*\"]', '2026-09-29 14:52:26', '2026-09-29 16:52:21', '2026-09-29 14:52:21', '2026-09-29 14:52:26');
INSERT INTO `personal_access_tokens` VALUES (9, 'App\\Models\\User', 1, 'gamma-one-token', '968950aeaa54024a46baf1f693766f333b609fbb0e407301d16ddcd53458fa92', '[\"*\"]', '2026-09-30 08:03:28', '2026-09-30 09:22:05', '2026-09-30 07:22:05', '2026-09-30 08:03:28');
INSERT INTO `personal_access_tokens` VALUES (16, 'App\\Models\\User', 42, 'gamma-one-token', 'e0b4b7be21f00619d49b30982e28f6bf04b8b5f143b9586afc8b45ffcd5d360b', '[\"*\"]', '2026-09-30 10:44:41', '2026-09-30 11:28:36', '2026-09-30 09:28:36', '2026-09-30 10:44:41');
INSERT INTO `personal_access_tokens` VALUES (18, 'App\\Models\\User', 1, 'gamma-one-token', 'cda6cbd0eb56e0f3713e5307175a3dad8f96f4d8f0c2f25109507f4548618213', '[\"*\"]', '2026-09-30 11:39:18', '2026-09-30 11:47:02', '2026-09-30 09:47:02', '2026-09-30 11:39:18');
INSERT INTO `personal_access_tokens` VALUES (19, 'App\\Models\\User', 1, 'gamma-one-token', 'abb10b9c365b90ccafae5cf502a0fc09bac4208e04fde5f5ab1fb0eb67e70b3f', '[\"*\"]', '2026-09-30 14:29:28', '2026-09-30 14:29:29', '2026-09-30 12:29:29', '2026-09-30 14:29:28');
INSERT INTO `personal_access_tokens` VALUES (20, 'App\\Models\\User', 42, 'gamma-one-token', 'f02398af1c335c1f60eb13d038fde43ba3744e1d6ed9751e457642f22b6850e2', '[\"*\"]', '2026-09-30 14:29:53', '2026-09-30 14:29:56', '2026-09-30 12:29:56', '2026-09-30 14:29:53');
INSERT INTO `personal_access_tokens` VALUES (21, 'App\\Models\\User', 42, 'gamma-one-token', 'ea07718927cfc923a616b88d97c8df6aebb62deecb822fea85938c69ce533f99', '[\"*\"]', '2026-09-30 16:25:15', '2026-09-30 16:38:59', '2026-09-30 14:38:59', '2026-09-30 16:25:15');
INSERT INTO `personal_access_tokens` VALUES (22, 'App\\Models\\User', 1, 'gamma-one-token', '94f85be904ebf20b1f038f069e97ee11f3b6d5911f3b171f73b36b8775b48b60', '[\"*\"]', '2026-09-30 16:22:24', '2026-09-30 16:41:45', '2026-09-30 14:41:45', '2026-09-30 16:22:24');

-- ----------------------------
-- Table structure for programs
-- ----------------------------
DROP TABLE IF EXISTS `programs`;
CREATE TABLE `programs`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `fee` bigint UNSIGNED NOT NULL DEFAULT 0,
  `registration_fee` bigint UNSIGNED NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `programs_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `programs_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `programs_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `programs_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `programs_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `programs_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of programs
-- ----------------------------
INSERT INTO `programs` VALUES (1, 'Reguler SMP', 'Bimbel reguler jenjang SMP.', 350000, 100000, 1, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `programs` VALUES (2, 'Intensif UTBK', 'Persiapan UTBK SNBT.', 750000, 150000, 1, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `programs` VALUES (3, 'Privat SD', 'Les privat jenjang SD.', 500000, 50000, 1, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);

-- ----------------------------
-- Table structure for role_has_permissions
-- ----------------------------
DROP TABLE IF EXISTS `role_has_permissions`;
CREATE TABLE `role_has_permissions`  (
  `permission_id` bigint UNSIGNED NOT NULL,
  `role_id` bigint UNSIGNED NOT NULL,
  PRIMARY KEY (`permission_id`, `role_id`) USING BTREE,
  INDEX `role_has_permissions_role_id_foreign`(`role_id` ASC) USING BTREE,
  CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of role_has_permissions
-- ----------------------------
INSERT INTO `role_has_permissions` VALUES (1, 1);
INSERT INTO `role_has_permissions` VALUES (2, 1);
INSERT INTO `role_has_permissions` VALUES (3, 1);
INSERT INTO `role_has_permissions` VALUES (4, 1);
INSERT INTO `role_has_permissions` VALUES (5, 1);
INSERT INTO `role_has_permissions` VALUES (6, 1);
INSERT INTO `role_has_permissions` VALUES (7, 1);
INSERT INTO `role_has_permissions` VALUES (8, 1);
INSERT INTO `role_has_permissions` VALUES (9, 1);
INSERT INTO `role_has_permissions` VALUES (10, 1);
INSERT INTO `role_has_permissions` VALUES (11, 1);
INSERT INTO `role_has_permissions` VALUES (12, 1);
INSERT INTO `role_has_permissions` VALUES (13, 1);
INSERT INTO `role_has_permissions` VALUES (14, 1);
INSERT INTO `role_has_permissions` VALUES (15, 1);
INSERT INTO `role_has_permissions` VALUES (16, 1);
INSERT INTO `role_has_permissions` VALUES (17, 1);
INSERT INTO `role_has_permissions` VALUES (18, 1);
INSERT INTO `role_has_permissions` VALUES (19, 1);
INSERT INTO `role_has_permissions` VALUES (20, 1);
INSERT INTO `role_has_permissions` VALUES (21, 1);
INSERT INTO `role_has_permissions` VALUES (22, 1);
INSERT INTO `role_has_permissions` VALUES (23, 1);
INSERT INTO `role_has_permissions` VALUES (24, 1);
INSERT INTO `role_has_permissions` VALUES (25, 1);
INSERT INTO `role_has_permissions` VALUES (26, 1);
INSERT INTO `role_has_permissions` VALUES (27, 1);
INSERT INTO `role_has_permissions` VALUES (28, 1);
INSERT INTO `role_has_permissions` VALUES (29, 1);
INSERT INTO `role_has_permissions` VALUES (30, 1);
INSERT INTO `role_has_permissions` VALUES (31, 1);
INSERT INTO `role_has_permissions` VALUES (32, 1);
INSERT INTO `role_has_permissions` VALUES (33, 1);
INSERT INTO `role_has_permissions` VALUES (34, 1);
INSERT INTO `role_has_permissions` VALUES (35, 1);
INSERT INTO `role_has_permissions` VALUES (36, 1);
INSERT INTO `role_has_permissions` VALUES (37, 1);
INSERT INTO `role_has_permissions` VALUES (38, 1);
INSERT INTO `role_has_permissions` VALUES (39, 1);
INSERT INTO `role_has_permissions` VALUES (40, 1);
INSERT INTO `role_has_permissions` VALUES (41, 1);
INSERT INTO `role_has_permissions` VALUES (42, 1);
INSERT INTO `role_has_permissions` VALUES (43, 1);
INSERT INTO `role_has_permissions` VALUES (44, 1);
INSERT INTO `role_has_permissions` VALUES (45, 1);
INSERT INTO `role_has_permissions` VALUES (46, 1);
INSERT INTO `role_has_permissions` VALUES (47, 1);
INSERT INTO `role_has_permissions` VALUES (48, 1);
INSERT INTO `role_has_permissions` VALUES (49, 1);
INSERT INTO `role_has_permissions` VALUES (50, 1);
INSERT INTO `role_has_permissions` VALUES (51, 1);
INSERT INTO `role_has_permissions` VALUES (52, 1);
INSERT INTO `role_has_permissions` VALUES (53, 1);
INSERT INTO `role_has_permissions` VALUES (54, 1);
INSERT INTO `role_has_permissions` VALUES (55, 1);
INSERT INTO `role_has_permissions` VALUES (56, 1);
INSERT INTO `role_has_permissions` VALUES (57, 1);
INSERT INTO `role_has_permissions` VALUES (58, 1);
INSERT INTO `role_has_permissions` VALUES (59, 1);
INSERT INTO `role_has_permissions` VALUES (60, 1);
INSERT INTO `role_has_permissions` VALUES (61, 1);
INSERT INTO `role_has_permissions` VALUES (62, 1);
INSERT INTO `role_has_permissions` VALUES (63, 1);
INSERT INTO `role_has_permissions` VALUES (64, 1);
INSERT INTO `role_has_permissions` VALUES (65, 1);
INSERT INTO `role_has_permissions` VALUES (66, 1);
INSERT INTO `role_has_permissions` VALUES (67, 1);
INSERT INTO `role_has_permissions` VALUES (68, 1);
INSERT INTO `role_has_permissions` VALUES (69, 1);
INSERT INTO `role_has_permissions` VALUES (70, 1);
INSERT INTO `role_has_permissions` VALUES (71, 1);
INSERT INTO `role_has_permissions` VALUES (72, 1);
INSERT INTO `role_has_permissions` VALUES (73, 1);
INSERT INTO `role_has_permissions` VALUES (74, 1);
INSERT INTO `role_has_permissions` VALUES (75, 1);
INSERT INTO `role_has_permissions` VALUES (76, 1);
INSERT INTO `role_has_permissions` VALUES (77, 1);
INSERT INTO `role_has_permissions` VALUES (78, 1);
INSERT INTO `role_has_permissions` VALUES (79, 1);
INSERT INTO `role_has_permissions` VALUES (80, 1);
INSERT INTO `role_has_permissions` VALUES (81, 1);
INSERT INTO `role_has_permissions` VALUES (82, 1);
INSERT INTO `role_has_permissions` VALUES (83, 1);
INSERT INTO `role_has_permissions` VALUES (84, 1);
INSERT INTO `role_has_permissions` VALUES (85, 1);
INSERT INTO `role_has_permissions` VALUES (86, 1);
INSERT INTO `role_has_permissions` VALUES (87, 1);
INSERT INTO `role_has_permissions` VALUES (88, 1);
INSERT INTO `role_has_permissions` VALUES (89, 1);
INSERT INTO `role_has_permissions` VALUES (90, 1);
INSERT INTO `role_has_permissions` VALUES (91, 1);
INSERT INTO `role_has_permissions` VALUES (92, 1);
INSERT INTO `role_has_permissions` VALUES (93, 1);
INSERT INTO `role_has_permissions` VALUES (94, 1);
INSERT INTO `role_has_permissions` VALUES (95, 1);
INSERT INTO `role_has_permissions` VALUES (96, 1);
INSERT INTO `role_has_permissions` VALUES (97, 1);
INSERT INTO `role_has_permissions` VALUES (98, 1);
INSERT INTO `role_has_permissions` VALUES (99, 1);
INSERT INTO `role_has_permissions` VALUES (1, 2);
INSERT INTO `role_has_permissions` VALUES (2, 2);
INSERT INTO `role_has_permissions` VALUES (3, 2);
INSERT INTO `role_has_permissions` VALUES (4, 2);
INSERT INTO `role_has_permissions` VALUES (5, 2);
INSERT INTO `role_has_permissions` VALUES (6, 2);
INSERT INTO `role_has_permissions` VALUES (7, 2);
INSERT INTO `role_has_permissions` VALUES (8, 2);
INSERT INTO `role_has_permissions` VALUES (9, 2);
INSERT INTO `role_has_permissions` VALUES (10, 2);
INSERT INTO `role_has_permissions` VALUES (11, 2);
INSERT INTO `role_has_permissions` VALUES (12, 2);
INSERT INTO `role_has_permissions` VALUES (13, 2);
INSERT INTO `role_has_permissions` VALUES (14, 2);
INSERT INTO `role_has_permissions` VALUES (15, 2);
INSERT INTO `role_has_permissions` VALUES (16, 2);
INSERT INTO `role_has_permissions` VALUES (17, 2);
INSERT INTO `role_has_permissions` VALUES (18, 2);
INSERT INTO `role_has_permissions` VALUES (19, 2);
INSERT INTO `role_has_permissions` VALUES (20, 2);
INSERT INTO `role_has_permissions` VALUES (21, 2);
INSERT INTO `role_has_permissions` VALUES (22, 2);
INSERT INTO `role_has_permissions` VALUES (23, 2);
INSERT INTO `role_has_permissions` VALUES (24, 2);
INSERT INTO `role_has_permissions` VALUES (25, 2);
INSERT INTO `role_has_permissions` VALUES (26, 2);
INSERT INTO `role_has_permissions` VALUES (27, 2);
INSERT INTO `role_has_permissions` VALUES (28, 2);
INSERT INTO `role_has_permissions` VALUES (29, 2);
INSERT INTO `role_has_permissions` VALUES (30, 2);
INSERT INTO `role_has_permissions` VALUES (31, 2);
INSERT INTO `role_has_permissions` VALUES (32, 2);
INSERT INTO `role_has_permissions` VALUES (33, 2);
INSERT INTO `role_has_permissions` VALUES (34, 2);
INSERT INTO `role_has_permissions` VALUES (35, 2);
INSERT INTO `role_has_permissions` VALUES (36, 2);
INSERT INTO `role_has_permissions` VALUES (37, 2);
INSERT INTO `role_has_permissions` VALUES (38, 2);
INSERT INTO `role_has_permissions` VALUES (39, 2);
INSERT INTO `role_has_permissions` VALUES (40, 2);
INSERT INTO `role_has_permissions` VALUES (41, 2);
INSERT INTO `role_has_permissions` VALUES (42, 2);
INSERT INTO `role_has_permissions` VALUES (43, 2);
INSERT INTO `role_has_permissions` VALUES (44, 2);
INSERT INTO `role_has_permissions` VALUES (45, 2);
INSERT INTO `role_has_permissions` VALUES (46, 2);
INSERT INTO `role_has_permissions` VALUES (47, 2);
INSERT INTO `role_has_permissions` VALUES (48, 2);
INSERT INTO `role_has_permissions` VALUES (49, 2);
INSERT INTO `role_has_permissions` VALUES (50, 2);
INSERT INTO `role_has_permissions` VALUES (51, 2);
INSERT INTO `role_has_permissions` VALUES (52, 2);
INSERT INTO `role_has_permissions` VALUES (53, 2);
INSERT INTO `role_has_permissions` VALUES (54, 2);
INSERT INTO `role_has_permissions` VALUES (55, 2);
INSERT INTO `role_has_permissions` VALUES (56, 2);
INSERT INTO `role_has_permissions` VALUES (57, 2);
INSERT INTO `role_has_permissions` VALUES (58, 2);
INSERT INTO `role_has_permissions` VALUES (59, 2);
INSERT INTO `role_has_permissions` VALUES (60, 2);
INSERT INTO `role_has_permissions` VALUES (61, 2);
INSERT INTO `role_has_permissions` VALUES (62, 2);
INSERT INTO `role_has_permissions` VALUES (63, 2);
INSERT INTO `role_has_permissions` VALUES (64, 2);
INSERT INTO `role_has_permissions` VALUES (65, 2);
INSERT INTO `role_has_permissions` VALUES (66, 2);
INSERT INTO `role_has_permissions` VALUES (67, 2);
INSERT INTO `role_has_permissions` VALUES (68, 2);
INSERT INTO `role_has_permissions` VALUES (69, 2);
INSERT INTO `role_has_permissions` VALUES (70, 2);
INSERT INTO `role_has_permissions` VALUES (71, 2);
INSERT INTO `role_has_permissions` VALUES (72, 2);
INSERT INTO `role_has_permissions` VALUES (73, 2);
INSERT INTO `role_has_permissions` VALUES (74, 2);
INSERT INTO `role_has_permissions` VALUES (75, 2);
INSERT INTO `role_has_permissions` VALUES (76, 2);
INSERT INTO `role_has_permissions` VALUES (77, 2);
INSERT INTO `role_has_permissions` VALUES (78, 2);
INSERT INTO `role_has_permissions` VALUES (79, 2);
INSERT INTO `role_has_permissions` VALUES (80, 2);
INSERT INTO `role_has_permissions` VALUES (81, 2);
INSERT INTO `role_has_permissions` VALUES (82, 2);
INSERT INTO `role_has_permissions` VALUES (83, 2);
INSERT INTO `role_has_permissions` VALUES (84, 2);
INSERT INTO `role_has_permissions` VALUES (85, 2);
INSERT INTO `role_has_permissions` VALUES (86, 2);
INSERT INTO `role_has_permissions` VALUES (87, 2);
INSERT INTO `role_has_permissions` VALUES (88, 2);
INSERT INTO `role_has_permissions` VALUES (89, 2);
INSERT INTO `role_has_permissions` VALUES (90, 2);
INSERT INTO `role_has_permissions` VALUES (91, 2);
INSERT INTO `role_has_permissions` VALUES (92, 2);
INSERT INTO `role_has_permissions` VALUES (93, 2);
INSERT INTO `role_has_permissions` VALUES (94, 2);
INSERT INTO `role_has_permissions` VALUES (95, 2);
INSERT INTO `role_has_permissions` VALUES (96, 2);
INSERT INTO `role_has_permissions` VALUES (97, 2);
INSERT INTO `role_has_permissions` VALUES (98, 2);
INSERT INTO `role_has_permissions` VALUES (99, 2);
INSERT INTO `role_has_permissions` VALUES (1, 3);
INSERT INTO `role_has_permissions` VALUES (5, 3);
INSERT INTO `role_has_permissions` VALUES (9, 3);
INSERT INTO `role_has_permissions` VALUES (13, 3);
INSERT INTO `role_has_permissions` VALUES (17, 3);
INSERT INTO `role_has_permissions` VALUES (21, 3);
INSERT INTO `role_has_permissions` VALUES (24, 3);
INSERT INTO `role_has_permissions` VALUES (25, 3);
INSERT INTO `role_has_permissions` VALUES (26, 3);
INSERT INTO `role_has_permissions` VALUES (27, 3);
INSERT INTO `role_has_permissions` VALUES (28, 3);
INSERT INTO `role_has_permissions` VALUES (29, 3);
INSERT INTO `role_has_permissions` VALUES (30, 3);
INSERT INTO `role_has_permissions` VALUES (31, 3);
INSERT INTO `role_has_permissions` VALUES (32, 3);
INSERT INTO `role_has_permissions` VALUES (33, 3);
INSERT INTO `role_has_permissions` VALUES (34, 3);
INSERT INTO `role_has_permissions` VALUES (35, 3);
INSERT INTO `role_has_permissions` VALUES (36, 3);
INSERT INTO `role_has_permissions` VALUES (37, 3);
INSERT INTO `role_has_permissions` VALUES (38, 3);
INSERT INTO `role_has_permissions` VALUES (39, 3);
INSERT INTO `role_has_permissions` VALUES (40, 3);
INSERT INTO `role_has_permissions` VALUES (41, 3);
INSERT INTO `role_has_permissions` VALUES (42, 3);
INSERT INTO `role_has_permissions` VALUES (43, 3);
INSERT INTO `role_has_permissions` VALUES (44, 3);
INSERT INTO `role_has_permissions` VALUES (45, 3);
INSERT INTO `role_has_permissions` VALUES (46, 3);
INSERT INTO `role_has_permissions` VALUES (47, 3);
INSERT INTO `role_has_permissions` VALUES (48, 3);
INSERT INTO `role_has_permissions` VALUES (49, 3);
INSERT INTO `role_has_permissions` VALUES (50, 3);
INSERT INTO `role_has_permissions` VALUES (51, 3);
INSERT INTO `role_has_permissions` VALUES (52, 3);
INSERT INTO `role_has_permissions` VALUES (53, 3);
INSERT INTO `role_has_permissions` VALUES (54, 3);
INSERT INTO `role_has_permissions` VALUES (55, 3);
INSERT INTO `role_has_permissions` VALUES (56, 3);
INSERT INTO `role_has_permissions` VALUES (57, 3);
INSERT INTO `role_has_permissions` VALUES (58, 3);
INSERT INTO `role_has_permissions` VALUES (59, 3);
INSERT INTO `role_has_permissions` VALUES (60, 3);
INSERT INTO `role_has_permissions` VALUES (61, 3);
INSERT INTO `role_has_permissions` VALUES (62, 3);
INSERT INTO `role_has_permissions` VALUES (63, 3);
INSERT INTO `role_has_permissions` VALUES (64, 3);
INSERT INTO `role_has_permissions` VALUES (65, 3);
INSERT INTO `role_has_permissions` VALUES (66, 3);
INSERT INTO `role_has_permissions` VALUES (67, 3);
INSERT INTO `role_has_permissions` VALUES (68, 3);
INSERT INTO `role_has_permissions` VALUES (69, 3);
INSERT INTO `role_has_permissions` VALUES (71, 3);
INSERT INTO `role_has_permissions` VALUES (72, 3);
INSERT INTO `role_has_permissions` VALUES (73, 3);
INSERT INTO `role_has_permissions` VALUES (77, 3);
INSERT INTO `role_has_permissions` VALUES (81, 3);
INSERT INTO `role_has_permissions` VALUES (82, 3);
INSERT INTO `role_has_permissions` VALUES (83, 3);
INSERT INTO `role_has_permissions` VALUES (84, 3);
INSERT INTO `role_has_permissions` VALUES (85, 3);
INSERT INTO `role_has_permissions` VALUES (86, 3);
INSERT INTO `role_has_permissions` VALUES (87, 3);
INSERT INTO `role_has_permissions` VALUES (88, 3);
INSERT INTO `role_has_permissions` VALUES (89, 3);
INSERT INTO `role_has_permissions` VALUES (90, 3);
INSERT INTO `role_has_permissions` VALUES (91, 3);
INSERT INTO `role_has_permissions` VALUES (92, 3);
INSERT INTO `role_has_permissions` VALUES (93, 3);
INSERT INTO `role_has_permissions` VALUES (94, 3);
INSERT INTO `role_has_permissions` VALUES (96, 3);
INSERT INTO `role_has_permissions` VALUES (97, 3);
INSERT INTO `role_has_permissions` VALUES (98, 3);
INSERT INTO `role_has_permissions` VALUES (99, 3);
INSERT INTO `role_has_permissions` VALUES (24, 4);
INSERT INTO `role_has_permissions` VALUES (48, 4);
INSERT INTO `role_has_permissions` VALUES (52, 4);
INSERT INTO `role_has_permissions` VALUES (56, 4);
INSERT INTO `role_has_permissions` VALUES (60, 4);
INSERT INTO `role_has_permissions` VALUES (62, 4);
INSERT INTO `role_has_permissions` VALUES (72, 4);
INSERT INTO `role_has_permissions` VALUES (81, 4);
INSERT INTO `role_has_permissions` VALUES (82, 4);
INSERT INTO `role_has_permissions` VALUES (83, 4);
INSERT INTO `role_has_permissions` VALUES (84, 4);
INSERT INTO `role_has_permissions` VALUES (85, 4);
INSERT INTO `role_has_permissions` VALUES (86, 4);
INSERT INTO `role_has_permissions` VALUES (87, 4);
INSERT INTO `role_has_permissions` VALUES (88, 4);
INSERT INTO `role_has_permissions` VALUES (89, 4);
INSERT INTO `role_has_permissions` VALUES (90, 4);
INSERT INTO `role_has_permissions` VALUES (91, 4);
INSERT INTO `role_has_permissions` VALUES (92, 4);
INSERT INTO `role_has_permissions` VALUES (93, 4);
INSERT INTO `role_has_permissions` VALUES (94, 4);
INSERT INTO `role_has_permissions` VALUES (96, 4);
INSERT INTO `role_has_permissions` VALUES (97, 4);
INSERT INTO `role_has_permissions` VALUES (98, 4);
INSERT INTO `role_has_permissions` VALUES (99, 4);
INSERT INTO `role_has_permissions` VALUES (24, 5);
INSERT INTO `role_has_permissions` VALUES (48, 5);
INSERT INTO `role_has_permissions` VALUES (52, 5);
INSERT INTO `role_has_permissions` VALUES (56, 5);
INSERT INTO `role_has_permissions` VALUES (60, 5);
INSERT INTO `role_has_permissions` VALUES (64, 5);
INSERT INTO `role_has_permissions` VALUES (85, 5);
INSERT INTO `role_has_permissions` VALUES (89, 5);
INSERT INTO `role_has_permissions` VALUES (93, 5);
INSERT INTO `role_has_permissions` VALUES (94, 5);
INSERT INTO `role_has_permissions` VALUES (97, 5);
INSERT INTO `role_has_permissions` VALUES (99, 5);
INSERT INTO `role_has_permissions` VALUES (24, 6);
INSERT INTO `role_has_permissions` VALUES (28, 6);
INSERT INTO `role_has_permissions` VALUES (48, 6);
INSERT INTO `role_has_permissions` VALUES (52, 6);
INSERT INTO `role_has_permissions` VALUES (56, 6);
INSERT INTO `role_has_permissions` VALUES (60, 6);
INSERT INTO `role_has_permissions` VALUES (64, 6);
INSERT INTO `role_has_permissions` VALUES (85, 6);
INSERT INTO `role_has_permissions` VALUES (89, 6);
INSERT INTO `role_has_permissions` VALUES (93, 6);
INSERT INTO `role_has_permissions` VALUES (94, 6);
INSERT INTO `role_has_permissions` VALUES (97, 6);
INSERT INTO `role_has_permissions` VALUES (99, 6);

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `guard_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `roles_name_guard_name_unique`(`name` ASC, `guard_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of roles
-- ----------------------------
INSERT INTO `roles` VALUES (1, 'super-admin', 'web', '2026-09-29 07:21:05', '2026-09-29 07:21:05');
INSERT INTO `roles` VALUES (2, 'admin', 'web', '2026-09-29 07:21:05', '2026-09-29 07:21:05');
INSERT INTO `roles` VALUES (3, 'staf', 'web', '2026-09-29 07:21:05', '2026-09-29 07:21:05');
INSERT INTO `roles` VALUES (4, 'tutor', 'web', '2026-09-29 07:21:05', '2026-09-29 07:21:05');
INSERT INTO `roles` VALUES (5, 'siswa', 'web', '2026-09-29 07:21:05', '2026-09-29 07:21:05');
INSERT INTO `roles` VALUES (6, 'orang_tua', 'web', '2026-09-29 07:21:05', '2026-09-29 07:21:05');

-- ----------------------------
-- Table structure for rooms
-- ----------------------------
DROP TABLE IF EXISTS `rooms`;
CREATE TABLE `rooms`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacity` int UNSIGNED NOT NULL DEFAULT 0,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `rooms_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `rooms_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `rooms_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `rooms_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `rooms_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `rooms_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rooms
-- ----------------------------
INSERT INTO `rooms` VALUES (1, 'Ruang Anggrek', 20, 'Lantai 1', NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `rooms` VALUES (2, 'Ruang Melati', 15, 'Lantai 1', NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `rooms` VALUES (3, 'Ruang Kenanga', 10, 'Lantai 2', NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `rooms` VALUES (4, 'Ruang Cempaka', 8, 'Lantai 2', NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);

-- ----------------------------
-- Table structure for schedules
-- ----------------------------
DROP TABLE IF EXISTS `schedules`;
CREATE TABLE `schedules`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `school_class_id` bigint UNSIGNED NOT NULL,
  `day_of_week` tinyint UNSIGNED NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `room_id` bigint UNSIGNED NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `schedules_room_id_foreign`(`room_id` ASC) USING BTREE,
  INDEX `schedules_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `schedules_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `schedules_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  INDEX `schedules_school_class_id_day_of_week_index`(`school_class_id` ASC, `day_of_week` ASC) USING BTREE,
  CONSTRAINT `schedules_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `schedules_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `schedules_room_id_foreign` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `schedules_school_class_id_foreign` FOREIGN KEY (`school_class_id`) REFERENCES `school_classes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `schedules_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of schedules
-- ----------------------------
INSERT INTO `schedules` VALUES (1, 1, 1, '08:00:00', '09:30:00', 1, 1, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `schedules` VALUES (2, 1, 3, '08:00:00', '09:30:00', 1, 1, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `schedules` VALUES (3, 2, 2, '10:00:00', '11:30:00', 2, 1, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `schedules` VALUES (4, 4, 4, '13:00:00', '14:30:00', 3, 1, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `schedules` VALUES (5, 2, 1, '08:00:00', '09:30:00', 3, 1, 1, 1, NULL, '2026-09-30 08:06:46', '2026-09-30 08:07:06', NULL);

-- ----------------------------
-- Table structure for school_classes
-- ----------------------------
DROP TABLE IF EXISTS `school_classes`;
CREATE TABLE `school_classes`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `program_id` bigint UNSIGNED NOT NULL,
  `subject_id` bigint UNSIGNED NULL DEFAULT NULL,
  `tutor_id` bigint UNSIGNED NULL DEFAULT NULL,
  `room_id` bigint UNSIGNED NULL DEFAULT NULL,
  `capacity` int UNSIGNED NOT NULL DEFAULT 0,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'reguler',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `school_classes_program_id_foreign`(`program_id` ASC) USING BTREE,
  INDEX `school_classes_subject_id_foreign`(`subject_id` ASC) USING BTREE,
  INDEX `school_classes_tutor_id_foreign`(`tutor_id` ASC) USING BTREE,
  INDEX `school_classes_room_id_foreign`(`room_id` ASC) USING BTREE,
  INDEX `school_classes_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `school_classes_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `school_classes_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `school_classes_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `school_classes_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `school_classes_program_id_foreign` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `school_classes_room_id_foreign` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `school_classes_subject_id_foreign` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `school_classes_tutor_id_foreign` FOREIGN KEY (`tutor_id`) REFERENCES `tutors` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `school_classes_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of school_classes
-- ----------------------------
INSERT INTO `school_classes` VALUES (1, 'Matematika 7A', 1, 1, 1, 1, 20, 'reguler', NULL, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `school_classes` VALUES (2, 'Fisika 8A', 1, 2, 2, 2, 15, 'reguler', NULL, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `school_classes` VALUES (3, 'UTBK Camp 1', 2, 1, 3, 1, 20, 'reguler', NULL, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `school_classes` VALUES (4, 'English 7B', 1, 6, 4, 3, 10, 'reguler', NULL, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `school_classes` VALUES (5, 'Privat Andi', 3, 1, 5, 4, 1, 'privat', NULL, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `school_classes` VALUES (6, 'Biologi 9A', 1, 4, 1, 2, 15, 'reguler', NULL, NULL, NULL, NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);

-- ----------------------------
-- Table structure for session_substitute_requests
-- ----------------------------
DROP TABLE IF EXISTS `session_substitute_requests`;
CREATE TABLE `session_substitute_requests`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `session_id` bigint UNSIGNED NOT NULL,
  `original_tutor_id` bigint UNSIGNED NULL DEFAULT NULL,
  `proposed_tutor_id` bigint UNSIGNED NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'diusulkan',
  `requested_by` bigint UNSIGNED NULL DEFAULT NULL,
  `reviewed_by` bigint UNSIGNED NULL DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `session_substitute_requests_original_tutor_id_foreign`(`original_tutor_id` ASC) USING BTREE,
  INDEX `session_substitute_requests_proposed_tutor_id_foreign`(`proposed_tutor_id` ASC) USING BTREE,
  INDEX `session_substitute_requests_requested_by_foreign`(`requested_by` ASC) USING BTREE,
  INDEX `session_substitute_requests_reviewed_by_foreign`(`reviewed_by` ASC) USING BTREE,
  INDEX `session_substitute_requests_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `session_substitute_requests_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `session_substitute_requests_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  INDEX `session_substitute_requests_session_id_status_index`(`session_id` ASC, `status` ASC) USING BTREE,
  CONSTRAINT `session_substitute_requests_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `session_substitute_requests_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `session_substitute_requests_original_tutor_id_foreign` FOREIGN KEY (`original_tutor_id`) REFERENCES `tutors` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `session_substitute_requests_proposed_tutor_id_foreign` FOREIGN KEY (`proposed_tutor_id`) REFERENCES `tutors` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `session_substitute_requests_requested_by_foreign` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `session_substitute_requests_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `session_substitute_requests_session_id_foreign` FOREIGN KEY (`session_id`) REFERENCES `class_sessions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `session_substitute_requests_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of session_substitute_requests
-- ----------------------------
INSERT INTO `session_substitute_requests` VALUES (1, 1, 1, 6, 'capek, pengen libur', 'disetujui', 7, 3, '2026-09-30 09:27:35', NULL, 7, 3, NULL, '2026-09-30 09:03:35', '2026-09-30 09:27:35', NULL);

-- ----------------------------
-- Table structure for sessions
-- ----------------------------
DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `sessions_user_id_index`(`user_id` ASC) USING BTREE,
  INDEX `sessions_last_activity_index`(`last_activity` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sessions
-- ----------------------------
INSERT INTO `sessions` VALUES ('2RLkebbnXQr6OkUxnVGIhlBClKxtRCjBLZcOXza3', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiJsdjN3SmlhRXJ1ZHNrWm5RV2FmUFdLdlV6ZmFOUXNvalZhWThNWlNuIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwXC8ud2VsbC1rbm93blwvYXBwc3BlY2lmaWNcL2NvbS5jaHJvbWUuZGV2dG9vbHMuanNvbiIsInJvdXRlIjpudWxsfSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==', 1790757958);
INSERT INTO `sessions` VALUES ('5msIY2SvK76P9mLqalZjPzbW3B8f2DA53deulEUr', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:157.0) Gecko/20100101 Firefox/157.0', 'eyJfdG9rZW4iOiJFQ05maWdNUU1wUEFZS0pOcGlDbnNsbXVhcnlMNzFISDM1WFdaa293IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwXC9zY2hlZHVsZXMiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=', 1790667011);
INSERT INTO `sessions` VALUES ('8esHpD57piR7wQ8GifQIX7tIxLMgrRjl8FqmAu6p', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:158.0) Gecko/20100101 Firefox/158.0', 'eyJfdG9rZW4iOiJSaUlyd0JEalZHeFgxYVpFcmhkb055S3c1cHFhYlQ5WWNBUnREQWFhIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwXC9yb2xlcyIsInJvdXRlIjpudWxsfSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==', 1790735628);
INSERT INTO `sessions` VALUES ('agf3uamGK5G6DHEpmxkIlgZGB68kV8kRoIst5EIr', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:157.0) Gecko/20100101 Firefox/157.0', 'eyJfdG9rZW4iOiI5M3pvZHFZQWtDSkpENWJqemhQUXNwV0FFeFJVYTB5ZGRZd21NeTFDIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwXC91c2VycyIsInJvdXRlIjpudWxsfSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==', 1790676268);
INSERT INTO `sessions` VALUES ('dq7VwbyJXVnjmB3yhV5NxPbWrcB2OYC14DJDjcuo', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiJsMGZjdkw0dDZwTzd3ZG5xcHRvbXc5YVE5ZG5KS001Zm1XZm5OdVFHIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwXC9zY2hlZHVsZXMiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=', 1790732791);
INSERT INTO `sessions` VALUES ('QyXTt71SBpGMHIlZZiJbqEcykPilCJyYvV6ceo14', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:158.0) Gecko/20100101 Firefox/158.0', 'eyJfdG9rZW4iOiJhNGZzQ2xPblM4aU5MZHVnWWFnbmhiZThFdGk1VWF5TlpDWjRiYkZmIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwXC9lbnJvbGxtZW50cyIsInJvdXRlIjpudWxsfSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==', 1790750335);
INSERT INTO `sessions` VALUES ('wxQKQRyOFjKQ30lJKEZRlsRswUrkYo0oD7IdfUP4', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiJ6MWFKa1V4UG1zYWlPUkZDZDB6a0ZLcXAwTjZKNVUzUTR2Q3EzRjN2IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1790668191);
INSERT INTO `sessions` VALUES ('xBY9iTAIoyzSqH7AYv3IOHJ6aBf4SMQtG0Dsm2bL', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiJWVzNLeXRVa0pRT3RUVFdVUlV2ZHFxRGhzVVkyRjJiSWJENDJhNkk0IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwXC9sb2dpbiIsInJvdXRlIjpudWxsfSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==', 1790742574);

-- ----------------------------
-- Table structure for students
-- ----------------------------
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL,
  `nis` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `birth_date` date NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `school` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'aktif',
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `students_nis_unique`(`nis` ASC) USING BTREE,
  UNIQUE INDEX `students_user_id_unique`(`user_id` ASC) USING BTREE,
  INDEX `students_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `students_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `students_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `students_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `students_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `students_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `students_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of students
-- ----------------------------
INSERT INTO `students` VALUES (1, 12, 'G1001001', 'Andi Wijaya', 'L', NULL, '628220000011', NULL, 'SMPN 2', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:09', '2026-09-29 07:21:09', NULL);
INSERT INTO `students` VALUES (2, 13, 'G1001002', 'Bella Putri', 'P', NULL, '628220000012', NULL, 'SMPN 3', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:09', '2026-09-29 07:21:09', NULL);
INSERT INTO `students` VALUES (3, 14, 'G1001003', 'Candra Gunawan', 'L', NULL, '628220000013', NULL, 'SMPN 4', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:09', '2026-09-29 07:21:09', NULL);
INSERT INTO `students` VALUES (4, 15, 'G1001004', 'Dinda Safitri', 'P', NULL, '628220000014', NULL, 'SMPN 5', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:10', '2026-09-29 07:21:10', NULL);
INSERT INTO `students` VALUES (5, 16, 'G1001005', 'Eko Saputra', 'L', NULL, '628220000015', NULL, 'SMPN 1', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:10', '2026-09-29 07:21:10', NULL);
INSERT INTO `students` VALUES (6, 17, 'G1001006', 'Fitri Handayani', 'P', NULL, '628220000016', NULL, 'SMPN 2', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:10', '2026-09-29 07:21:10', NULL);
INSERT INTO `students` VALUES (7, 18, 'G1001007', 'Gilang Ramadhan', 'L', NULL, '628220000017', NULL, 'SMPN 3', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:10', '2026-09-29 07:21:10', NULL);
INSERT INTO `students` VALUES (8, 19, 'G1001008', 'Hana Kusuma', 'P', NULL, '628220000018', NULL, 'SMPN 4', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:11', '2026-09-29 07:21:11', NULL);
INSERT INTO `students` VALUES (9, 20, 'G1001009', 'Irfan Maulana', 'L', NULL, '628220000019', NULL, 'SMPN 5', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:11', '2026-09-29 07:21:11', NULL);
INSERT INTO `students` VALUES (10, 21, 'G1001010', 'Jihan Aulia', 'P', NULL, '628220000020', NULL, 'SMPN 1', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:11', '2026-09-29 07:21:11', NULL);
INSERT INTO `students` VALUES (11, 22, 'G1001011', 'Kevin Alexander', 'L', NULL, '628220000021', NULL, 'SMPN 2', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:12', '2026-09-29 07:21:12', NULL);
INSERT INTO `students` VALUES (12, 23, 'G1001012', 'Larasati Dewi', 'P', NULL, '628220000022', NULL, 'SMPN 3', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:12', '2026-09-29 07:21:12', NULL);
INSERT INTO `students` VALUES (13, 24, 'G1001013', 'M faisal', 'L', NULL, '628220000023', NULL, 'SMPN 4', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:12', '2026-09-29 07:21:12', NULL);
INSERT INTO `students` VALUES (14, 25, 'G1001014', 'Nadia Zahra', 'P', NULL, '628220000024', NULL, 'SMPN 5', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:12', '2026-09-29 07:21:12', NULL);
INSERT INTO `students` VALUES (15, 26, 'G1001015', 'Oscar Mahendra', 'L', NULL, '628220000025', NULL, 'SMPN 1', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:13', '2026-09-29 07:21:13', NULL);
INSERT INTO `students` VALUES (16, 27, 'G1001016', 'Putri Ayu', 'P', NULL, '628220000026', NULL, 'SMPN 2', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:13', '2026-09-29 07:21:13', NULL);
INSERT INTO `students` VALUES (17, 28, 'G1001017', 'Rizky Febian', 'L', NULL, '628220000027', NULL, 'SMPN 3', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:13', '2026-09-29 07:21:13', NULL);
INSERT INTO `students` VALUES (18, 29, 'G1001018', 'Sarah Amelia', 'P', NULL, '628220000028', NULL, 'SMPN 4', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:14', '2026-09-29 07:21:14', NULL);
INSERT INTO `students` VALUES (19, 30, 'G1001019', 'Taufik Hidayat', 'L', NULL, '628220000029', NULL, 'SMPN 5', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:14', '2026-09-29 07:21:14', NULL);
INSERT INTO `students` VALUES (20, 31, 'G1001020', 'Umi Kalsum', 'P', NULL, '628220000030', NULL, 'SMPN 1', 'aktif', NULL, NULL, NULL, '2026-09-29 07:21:14', '2026-09-29 07:21:14', NULL);

-- ----------------------------
-- Table structure for subject_tutor
-- ----------------------------
DROP TABLE IF EXISTS `subject_tutor`;
CREATE TABLE `subject_tutor`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `subject_id` bigint UNSIGNED NOT NULL,
  `tutor_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `subject_tutor_subject_id_tutor_id_unique`(`subject_id` ASC, `tutor_id` ASC) USING BTREE,
  INDEX `subject_tutor_tutor_id_foreign`(`tutor_id` ASC) USING BTREE,
  CONSTRAINT `subject_tutor_subject_id_foreign` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `subject_tutor_tutor_id_foreign` FOREIGN KEY (`tutor_id`) REFERENCES `tutors` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subject_tutor
-- ----------------------------
INSERT INTO `subject_tutor` VALUES (1, 1, 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `subject_tutor` VALUES (2, 2, 1, '2026-09-29 07:21:07', '2026-09-29 07:21:07');
INSERT INTO `subject_tutor` VALUES (3, 2, 2, '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `subject_tutor` VALUES (4, 3, 2, '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `subject_tutor` VALUES (5, 3, 3, '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `subject_tutor` VALUES (6, 4, 3, '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `subject_tutor` VALUES (7, 4, 4, '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `subject_tutor` VALUES (8, 5, 4, '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `subject_tutor` VALUES (9, 5, 5, '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `subject_tutor` VALUES (10, 6, 5, '2026-09-29 07:21:08', '2026-09-29 07:21:08');
INSERT INTO `subject_tutor` VALUES (11, 1, 6, '2026-09-30 08:45:15', '2026-09-30 08:45:15');
INSERT INTO `subject_tutor` VALUES (12, 1, 3, '2026-09-30 08:50:04', '2026-09-30 08:50:04');

-- ----------------------------
-- Table structure for subjects
-- ----------------------------
DROP TABLE IF EXISTS `subjects`;
CREATE TABLE `subjects`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `subjects_code_unique`(`code` ASC) USING BTREE,
  INDEX `subjects_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `subjects_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `subjects_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `subjects_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `subjects_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `subjects_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subjects
-- ----------------------------
INSERT INTO `subjects` VALUES (1, 'Matematika', NULL, NULL, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `subjects` VALUES (2, 'Fisika', NULL, NULL, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `subjects` VALUES (3, 'Kimia', NULL, NULL, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `subjects` VALUES (4, 'Biologi', NULL, NULL, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `subjects` VALUES (5, 'Bahasa Indonesia', NULL, NULL, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `subjects` VALUES (6, 'Bahasa Inggris', NULL, NULL, NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);

-- ----------------------------
-- Table structure for submissions
-- ----------------------------
DROP TABLE IF EXISTS `submissions`;
CREATE TABLE `submissions`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `assignment_id` bigint UNSIGNED NOT NULL,
  `student_id` bigint UNSIGNED NOT NULL,
  `file_url` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `submitted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `submissions_assignment_id_student_id_unique`(`assignment_id` ASC, `student_id` ASC) USING BTREE,
  INDEX `submissions_student_id_index`(`student_id` ASC) USING BTREE,
  CONSTRAINT `submissions_assignment_id_foreign` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `submissions_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of submissions
-- ----------------------------
INSERT INTO `submissions` VALUES (1, 1, 1, '/images/logo-gamma-one.svg', 'Contoh pengumpulan.', '2026-09-29 07:21:18', '2026-09-29 07:21:18', '2026-09-29 07:21:18');
INSERT INTO `submissions` VALUES (2, 3, 2, 'http://localhost:8000/storage/uploads/kuMf4a9QE6LyC9qFhqby8ScBt8TGilIZJPErjFRJ.png', NULL, '2026-09-30 07:42:41', '2026-09-30 07:42:41', '2026-09-30 07:42:41');

-- ----------------------------
-- Table structure for tutors
-- ----------------------------
DROP TABLE IF EXISTS `tutors`;
CREATE TABLE `tutors`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fee_per_session` bigint UNSIGNED NOT NULL DEFAULT 0,
  `availability` json NULL,
  `bio` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `tutors_user_id_unique`(`user_id` ASC) USING BTREE,
  INDEX `tutors_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `tutors_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `tutors_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `tutors_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `tutors_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `tutors_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `tutors_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tutors
-- ----------------------------
INSERT INTO `tutors` VALUES (1, 7, 'Dewi Lestari', '628210000011', 100000, NULL, 'Tutor contoh fiktif.', NULL, NULL, NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `tutors` VALUES (2, 8, 'Budi Santoso', '628210000012', 100000, NULL, 'Tutor contoh fiktif.', NULL, NULL, NULL, '2026-09-29 07:21:08', '2026-09-29 07:21:08', NULL);
INSERT INTO `tutors` VALUES (3, 9, 'Siti Rahayu', '628210000013', 100000, NULL, 'Tutor contoh fiktif.', NULL, NULL, NULL, '2026-09-29 07:21:08', '2026-09-29 07:21:08', NULL);
INSERT INTO `tutors` VALUES (4, 10, 'Agus Pratama', '628210000014', 100000, NULL, 'Tutor contoh fiktif.', NULL, NULL, NULL, '2026-09-29 07:21:08', '2026-09-29 07:21:08', NULL);
INSERT INTO `tutors` VALUES (5, 11, 'Rina Marlina', '628210000015', 100000, NULL, 'Tutor contoh fiktif.', NULL, NULL, NULL, '2026-09-29 07:21:08', '2026-09-29 07:21:08', NULL);
INSERT INTO `tutors` VALUES (6, 42, 'Yosi AWK', '628996844000', 50000, NULL, 'Biodata', 1, 1, NULL, '2026-09-30 08:45:15', '2026-09-30 10:43:28', NULL);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `created_by` bigint UNSIGNED NULL DEFAULT NULL,
  `updated_by` bigint UNSIGNED NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `users_email_unique`(`email` ASC) USING BTREE,
  UNIQUE INDEX `users_phone_unique`(`phone` ASC) USING BTREE,
  INDEX `users_created_by_foreign`(`created_by` ASC) USING BTREE,
  INDEX `users_updated_by_foreign`(`updated_by` ASC) USING BTREE,
  INDEX `users_deleted_by_foreign`(`deleted_by` ASC) USING BTREE,
  CONSTRAINT `users_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `users_deleted_by_foreign` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `users_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 43 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, NULL, NULL, NULL, 'Super Admin', 'admin@dev.local', '628110000001', NULL, NULL, '$2y$12$j5hy3fWnNjsc2BFkeU/mm.zctpLPmaw4867NKLokCjB9hTQfrFWoW', NULL, '2026-09-29 07:21:05', '2026-09-29 07:21:05', NULL);
INSERT INTO `users` VALUES (2, NULL, NULL, NULL, 'Admin Contoh', 'admin.contoh@dev.local', '628110000002', NULL, NULL, '$2y$12$FQJys5ZMgzVnTn1.Ewyax.m1j5GC49frZqx79RMNhSawcjyp.GAku', NULL, '2026-09-29 07:21:06', '2026-09-29 07:21:06', NULL);
INSERT INTO `users` VALUES (3, NULL, NULL, NULL, 'Staf Contoh', 'staf@dev.local', '628120000003', NULL, NULL, '$2y$12$tCXINeAFF4Nn3MUuhO95Ru.p0EYP3sgnweQUDlfyWaB1Q1P6HmDXe', NULL, '2026-09-29 07:21:06', '2026-09-29 07:21:06', NULL);
INSERT INTO `users` VALUES (4, NULL, NULL, NULL, 'Tutor Contoh', 'tutor@dev.local', '628130000004', NULL, NULL, '$2y$12$DNwsqnA9.3NYMMDDox43weKjnZ8OQ5/bGwtrZ3UKG17VqUujhyfh6', NULL, '2026-09-29 07:21:06', '2026-09-29 07:21:06', NULL);
INSERT INTO `users` VALUES (5, NULL, NULL, NULL, 'Siswa Contoh', 'siswa@dev.local', '628140000005', NULL, NULL, '$2y$12$MoFJu2kf2e2NhQia9Q8HK.wkuaiawVprcDgD9c9l5XGPVJefxAxtm', NULL, '2026-09-29 07:21:06', '2026-09-29 07:21:06', NULL);
INSERT INTO `users` VALUES (6, NULL, NULL, NULL, 'Orang Tua Contoh', 'orangtua@dev.local', '628150000006', NULL, NULL, '$2y$12$4ug6gV3UKJH6hHPZKtBITeiHAfzj/I2B1kQsdeZiIbYMN.vXUKYD6', NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `users` VALUES (7, NULL, NULL, NULL, 'Dewi Lestari', 'tutor1@contoh.local', '628210000011', NULL, NULL, '$2y$12$RNxBjIt.BiihPxzbvvU/BO3vRcFE7uNFEMOEBJF/dZW41rCvdqa7u', NULL, '2026-09-29 07:21:07', '2026-09-29 07:21:07', NULL);
INSERT INTO `users` VALUES (8, NULL, NULL, NULL, 'Budi Santoso', 'tutor2@contoh.local', '628210000012', NULL, NULL, '$2y$12$1k5QRkgoHpUsBIbMxNJ1g.rwbxaSzRekAXoZdSqtbZbknJvlIFyES', NULL, '2026-09-29 07:21:08', '2026-09-29 07:21:08', NULL);
INSERT INTO `users` VALUES (9, NULL, NULL, NULL, 'Siti Rahayu', 'tutor3@contoh.local', '628210000013', NULL, NULL, '$2y$12$w.PzAibmPMLjGNDnoj8TgOEJk20oJ52McE0KOfVlnGVMVarIp2MWm', NULL, '2026-09-29 07:21:08', '2026-09-29 07:21:08', NULL);
INSERT INTO `users` VALUES (10, NULL, NULL, NULL, 'Agus Pratama', 'tutor4@contoh.local', '628210000014', NULL, NULL, '$2y$12$XveRMeu4Fk5rLYWJG3A65ugYd/tA1lzL6UdlNYFNXQ0tKdbkzpiQy', NULL, '2026-09-29 07:21:08', '2026-09-29 07:21:08', NULL);
INSERT INTO `users` VALUES (11, NULL, NULL, NULL, 'Rina Marlina', 'tutor5@contoh.local', '628210000015', NULL, NULL, '$2y$12$EKmdktfNwT2.hyCsA2c9MOeZsi2/WLcNJke6m29KqO414rEnIvMqy', NULL, '2026-09-29 07:21:08', '2026-09-29 07:21:08', NULL);
INSERT INTO `users` VALUES (12, NULL, NULL, NULL, 'Andi Wijaya', 'siswa1@contoh.local', '628220000011', NULL, NULL, '$2y$12$g7kyDEch00hpRdiQBKrXV.KGlWKlnxfOQ2txcmIaGdWdHDWABAto.', NULL, '2026-09-29 07:21:09', '2026-09-29 07:21:09', NULL);
INSERT INTO `users` VALUES (13, NULL, NULL, NULL, 'Bella Putri', 'siswa2@contoh.local', '628220000012', NULL, NULL, '$2y$12$VrSAt6ImhUI.4ajliwMAfeNzKU4s1MgKE3uUG20GQHi2JJ2BZgTcq', NULL, '2026-09-29 07:21:09', '2026-09-29 07:21:09', NULL);
INSERT INTO `users` VALUES (14, NULL, NULL, NULL, 'Candra Gunawan', 'siswa3@contoh.local', '628220000013', NULL, NULL, '$2y$12$gc0nbHkj15LRdkS1k/84QequZCZKD2sfk59OQac5dtHveWnWQkWT2', NULL, '2026-09-29 07:21:09', '2026-09-29 07:21:09', NULL);
INSERT INTO `users` VALUES (15, NULL, NULL, NULL, 'Dinda Safitri', 'siswa4@contoh.local', '628220000014', NULL, NULL, '$2y$12$la8fbNeqMNk800/GirPwiu4V1Vm7kOUkyVwow9aWrxO7L4DEl4jW.', NULL, '2026-09-29 07:21:10', '2026-09-29 07:21:10', NULL);
INSERT INTO `users` VALUES (16, NULL, NULL, NULL, 'Eko Saputra', 'siswa5@contoh.local', '628220000015', NULL, NULL, '$2y$12$/uheGJdxGNNN7j4X3h2hZOzk7L3sEnUZYKmVLGuG7a6q7Km9050Ia', NULL, '2026-09-29 07:21:10', '2026-09-29 07:21:10', NULL);
INSERT INTO `users` VALUES (17, NULL, NULL, NULL, 'Fitri Handayani', 'siswa6@contoh.local', '628220000016', NULL, NULL, '$2y$12$73FvU2e1F18fCp2Ziiq8ReoicSLA/zhzxuB0CMwH/U5OiBrXihfI6', NULL, '2026-09-29 07:21:10', '2026-09-29 07:21:10', NULL);
INSERT INTO `users` VALUES (18, NULL, NULL, NULL, 'Gilang Ramadhan', 'siswa7@contoh.local', '628220000017', NULL, NULL, '$2y$12$LCu7AxmQBqQ3QuVinUJuNOWo.3O2akwTs64oQ8LzWOtyfo7eqLhty', NULL, '2026-09-29 07:21:10', '2026-09-29 07:21:10', NULL);
INSERT INTO `users` VALUES (19, NULL, NULL, NULL, 'Hana Kusuma', 'siswa8@contoh.local', '628220000018', NULL, NULL, '$2y$12$145ASPVmnVt2J3HkMlBf9uHqZRydPvMZBgypRZ0gmTwTvtt3vMu2a', NULL, '2026-09-29 07:21:11', '2026-09-29 07:21:11', NULL);
INSERT INTO `users` VALUES (20, NULL, NULL, NULL, 'Irfan Maulana', 'siswa9@contoh.local', '628220000019', NULL, NULL, '$2y$12$gAHemYPhdQ6/31Hv.wWAW.UThPehkCDimVDnEJeAuCqyR.AIwBx..', NULL, '2026-09-29 07:21:11', '2026-09-29 07:21:11', NULL);
INSERT INTO `users` VALUES (21, NULL, NULL, NULL, 'Jihan Aulia', 'siswa10@contoh.local', '628220000020', NULL, NULL, '$2y$12$HmUD1d9QZVYqjdmHKVCU1ujWmzarXzx..y88M2bxW9q65gukkBvfS', NULL, '2026-09-29 07:21:11', '2026-09-29 07:21:11', NULL);
INSERT INTO `users` VALUES (22, NULL, NULL, NULL, 'Kevin Alexander', 'siswa11@contoh.local', '628220000021', NULL, NULL, '$2y$12$IkAYuGSCQ.3dZJQDkI7Tje5IhrWzLUD3KLH1rZ/3mZ4kC1EVJpRRW', NULL, '2026-09-29 07:21:12', '2026-09-29 07:21:12', NULL);
INSERT INTO `users` VALUES (23, NULL, NULL, NULL, 'Larasati Dewi', 'siswa12@contoh.local', '628220000022', NULL, NULL, '$2y$12$W0ovzpwWy.anIXhhCPQjIu/aGaf7vDXgdhYJy9sXAznzZFkLa1OXm', NULL, '2026-09-29 07:21:12', '2026-09-29 07:21:12', NULL);
INSERT INTO `users` VALUES (24, NULL, NULL, NULL, 'M faisal', 'siswa13@contoh.local', '628220000023', NULL, NULL, '$2y$12$m885GkkxU6FjKTdIq3yrp./RKt96dNxU1Wfj7uunENg05EOjdBaRG', NULL, '2026-09-29 07:21:12', '2026-09-29 07:21:12', NULL);
INSERT INTO `users` VALUES (25, NULL, NULL, NULL, 'Nadia Zahra', 'siswa14@contoh.local', '628220000024', NULL, NULL, '$2y$12$xpoN/26xgHDGz.wBZ50moeVC.Xzos3BF7HS4XKVq2RLs2cWt6oUdm', NULL, '2026-09-29 07:21:12', '2026-09-29 07:21:12', NULL);
INSERT INTO `users` VALUES (26, NULL, NULL, NULL, 'Oscar Mahendra', 'siswa15@contoh.local', '628220000025', NULL, NULL, '$2y$12$PumKR8mgOeOlehl.5uiJ1eQSszgQkcg409FRLvfkNooo7poCxooyC', NULL, '2026-09-29 07:21:13', '2026-09-29 07:21:13', NULL);
INSERT INTO `users` VALUES (27, NULL, NULL, NULL, 'Putri Ayu', 'siswa16@contoh.local', '628220000026', NULL, NULL, '$2y$12$S.DaIjlGMAZvI0VUNrx3HOHQ8hir3G9JNW8vjntQAU2UlS/2PjAPO', NULL, '2026-09-29 07:21:13', '2026-09-29 07:21:13', NULL);
INSERT INTO `users` VALUES (28, NULL, NULL, NULL, 'Rizky Febian', 'siswa17@contoh.local', '628220000027', NULL, NULL, '$2y$12$CmeMdAuhTdmAHI4dyAP4c.wwA0QoquLgBAoUlFt6GTh6cVDYZx.we', NULL, '2026-09-29 07:21:13', '2026-09-29 07:21:13', NULL);
INSERT INTO `users` VALUES (29, NULL, NULL, NULL, 'Sarah Amelia', 'siswa18@contoh.local', '628220000028', NULL, NULL, '$2y$12$ivSZrei5aBfs3DEcZbMLKOoywsbmzHcL8ve2WHharBUFr4m27FS6C', NULL, '2026-09-29 07:21:14', '2026-09-29 07:21:14', NULL);
INSERT INTO `users` VALUES (30, NULL, NULL, NULL, 'Taufik Hidayat', 'siswa19@contoh.local', '628220000029', NULL, NULL, '$2y$12$HsPDhL7WXZ6A4X/uf5eD4On.inlLR1BLOM.T/wmepVxtmQ6MYsA8W', NULL, '2026-09-29 07:21:14', '2026-09-29 07:21:14', NULL);
INSERT INTO `users` VALUES (31, NULL, NULL, NULL, 'Umi Kalsum', 'siswa20@contoh.local', '628220000030', NULL, NULL, '$2y$12$lAihvlkStp1WRbnMnpqjvOaa0uGkldaxbpCKj7/x/LdWrixLuKB4i', NULL, '2026-09-29 07:21:14', '2026-09-29 07:21:14', NULL);
INSERT INTO `users` VALUES (32, NULL, NULL, NULL, 'Hendra Wijaya', 'ortu1@contoh.local', '628230000011', NULL, NULL, '$2y$12$2/h7onE2XyG9no7lm0Ry/edHolne9VyaeeE94TuLwgQcexrGcs4n6', NULL, '2026-09-29 07:21:15', '2026-09-29 07:21:15', NULL);
INSERT INTO `users` VALUES (33, NULL, NULL, NULL, 'Ratna Sari', 'ortu2@contoh.local', '628230000012', NULL, NULL, '$2y$12$MZ/bNjG0t722qVck68HGFO7EMqTujFwYZQPfbVNzzMEKELqJomoyu', NULL, '2026-09-29 07:21:15', '2026-09-29 07:21:15', NULL);
INSERT INTO `users` VALUES (34, NULL, NULL, NULL, 'Joko Susilo', 'ortu3@contoh.local', '628230000013', NULL, NULL, '$2y$12$TCffITPsHWcjWsyR.idmruv6pycJo9FBnSGPm37Hm.x1RZOVN0.iu', NULL, '2026-09-29 07:21:15', '2026-09-29 07:21:15', NULL);
INSERT INTO `users` VALUES (35, NULL, NULL, NULL, 'Mega Wati', 'ortu4@contoh.local', '628230000014', NULL, NULL, '$2y$12$GuqIPofkhEHTsdwUSj.78uy.KUvQXQh0AHieYNO3rgEWj8csBxtOK', NULL, '2026-09-29 07:21:15', '2026-09-29 07:21:15', NULL);
INSERT INTO `users` VALUES (36, NULL, NULL, NULL, 'Yusuf Hidayat', 'ortu5@contoh.local', '628230000015', NULL, NULL, '$2y$12$YCxYjaV2p5HkFlrrLAi2q.UBAl6kS3IHlxlpCmRgQpg5bDSb4MQVS', NULL, '2026-09-29 07:21:16', '2026-09-29 07:21:16', NULL);
INSERT INTO `users` VALUES (37, NULL, NULL, NULL, 'Sri Mulyani', 'ortu6@contoh.local', '628230000016', NULL, NULL, '$2y$12$4lLQ2A8FgmrfduIZrGglW.gqBTS6lWUe7Mb6PO.XwPhwtwwJrito2', NULL, '2026-09-29 07:21:16', '2026-09-29 07:21:16', NULL);
INSERT INTO `users` VALUES (38, NULL, NULL, NULL, 'Dedi Kurniawan', 'ortu7@contoh.local', '628230000017', NULL, NULL, '$2y$12$PaB43yNmn5/xOMRtxJ2p4O8ckVYu6yB36vSLGdhd6LfOboW.BGcw2', NULL, '2026-09-29 07:21:16', '2026-09-29 07:21:16', NULL);
INSERT INTO `users` VALUES (39, NULL, NULL, NULL, 'Nina Kurnia', 'ortu8@contoh.local', '628230000018', NULL, NULL, '$2y$12$s8W65g56WoXpJq5F3jr16.NBaX9RtA4heiREfoMYHl./6LE9uJamu', NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `users` VALUES (40, NULL, NULL, NULL, 'Fajar Nugroho', 'ortu9@contoh.local', '628230000019', NULL, NULL, '$2y$12$7MAgUlV1mKy2WxKKbLRfxONSIHoYNVFr9YZcj/kvPIWA.rUTsCBh6', NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `users` VALUES (41, NULL, NULL, NULL, 'Wulan Purnama', 'ortu10@contoh.local', '628230000020', NULL, NULL, '$2y$12$fXxf6KWiuK8hTg5TFbrfqO1d6H3BYRduGWkw6CI/AIryRjokcILBK', NULL, '2026-09-29 07:21:17', '2026-09-29 07:21:17', NULL);
INSERT INTO `users` VALUES (42, 1, 1, NULL, 'Yosi AWK', 'yos@gmail.com', '628996844000', NULL, NULL, '$2y$12$is7uWzP0a6TZdJ5d1i1fqOdGcLA5m2E3cwWJ2gXW64IcO1yHwiUQu', NULL, '2026-09-30 08:46:08', '2026-09-30 08:46:08', NULL);

SET FOREIGN_KEY_CHECKS = 1;
