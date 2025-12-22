/*
 Navicat Premium Dump SQL

 Source Server         : 112.74.21.57
 Source Server Type    : MySQL
 Source Server Version : 80036 (8.0.36)
 Source Host           : 112.74.21.57:3306
 Source Schema         : oms

 Target Server Type    : MySQL
 Target Server Version : 80036 (8.0.36)
 File Encoding         : 65001

 Date: 22/12/2025 17:25:44
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for __efmigrationshistory
-- ----------------------------
DROP TABLE IF EXISTS `__efmigrationshistory`;
CREATE TABLE `__efmigrationshistory`  (
  `MigrationId` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ProductVersion` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`MigrationId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of __efmigrationshistory
-- ----------------------------

-- ----------------------------
-- Table structure for arch_attachment
-- ----------------------------
DROP TABLE IF EXISTS `arch_attachment`;
CREATE TABLE `arch_attachment`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `ArchFileId` bigint NOT NULL,
  `FileId` bigint NULL DEFAULT NULL,
  `FileName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Extension` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Size` bigint NOT NULL,
  `FilePath` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_arch_attachment_ArchFileId`(`ArchFileId` ASC) USING BTREE,
  INDEX `IX_arch_attachment_FileId`(`FileId` ASC) USING BTREE,
  CONSTRAINT `FK_arch_attachment_arch_file_ArchFileId` FOREIGN KEY (`ArchFileId`) REFERENCES `arch_file` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FK_arch_attachment_sys_file_FileId` FOREIGN KEY (`FileId`) REFERENCES `sys_file` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of arch_attachment
-- ----------------------------

-- ----------------------------
-- Table structure for arch_box
-- ----------------------------
DROP TABLE IF EXISTS `arch_box`;
CREATE TABLE `arch_box`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `FondId` bigint NOT NULL,
  `TypeId` bigint NOT NULL,
  `BoxCode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Year` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `RetentionPeriod` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `SecurityLevel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `RFID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `FileCount` int NOT NULL,
  `Remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Status` int NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_arch_box_BoxCode`(`BoxCode` ASC) USING BTREE,
  INDEX `IX_arch_box_FondId`(`FondId` ASC) USING BTREE,
  INDEX `IX_arch_box_TypeId`(`TypeId` ASC) USING BTREE,
  CONSTRAINT `FK_arch_box_arch_fond_FondId` FOREIGN KEY (`FondId`) REFERENCES `arch_fond` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FK_arch_box_arch_type_TypeId` FOREIGN KEY (`TypeId`) REFERENCES `arch_type` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of arch_box
-- ----------------------------

-- ----------------------------
-- Table structure for arch_file
-- ----------------------------
DROP TABLE IF EXISTS `arch_file`;
CREATE TABLE `arch_file`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `FondId` bigint NOT NULL,
  `TypeId` bigint NOT NULL,
  `BoxId` bigint NULL DEFAULT NULL,
  `ArchCode` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `DocNumber` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Author` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `FileDate` datetime(6) NULL DEFAULT NULL,
  `Year` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `RetentionPeriod` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `SecurityLevel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `PageCount` int NOT NULL,
  `Status` int NOT NULL,
  `Keywords` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `SourceFileId` bigint NULL DEFAULT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_arch_file_ArchCode`(`ArchCode` ASC) USING BTREE,
  INDEX `IX_arch_file_BoxId`(`BoxId` ASC) USING BTREE,
  INDEX `IX_arch_file_FondId`(`FondId` ASC) USING BTREE,
  INDEX `IX_arch_file_TypeId`(`TypeId` ASC) USING BTREE,
  CONSTRAINT `FK_arch_file_arch_box_BoxId` FOREIGN KEY (`BoxId`) REFERENCES `arch_box` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_arch_file_arch_fond_FondId` FOREIGN KEY (`FondId`) REFERENCES `arch_fond` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FK_arch_file_arch_type_TypeId` FOREIGN KEY (`TypeId`) REFERENCES `arch_type` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of arch_file
-- ----------------------------

-- ----------------------------
-- Table structure for arch_fond
-- ----------------------------
DROP TABLE IF EXISTS `arch_fond`;
CREATE TABLE `arch_fond`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `SortOrder` int NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_arch_fond_Code`(`Code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of arch_fond
-- ----------------------------
INSERT INTO `arch_fond` VALUES (1, '111', '111', '', 0, '2025-12-22 15:22:20.498410');

-- ----------------------------
-- Table structure for arch_type
-- ----------------------------
DROP TABLE IF EXISTS `arch_type`;
CREATE TABLE `arch_type`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `ParentId` bigint NULL DEFAULT NULL,
  `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `SortOrder` int NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_arch_type_Code`(`Code` ASC) USING BTREE,
  INDEX `IX_arch_type_ParentId`(`ParentId` ASC) USING BTREE,
  CONSTRAINT `FK_arch_type_arch_type_ParentId` FOREIGN KEY (`ParentId`) REFERENCES `arch_type` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of arch_type
-- ----------------------------

-- ----------------------------
-- Table structure for sys_audit_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_audit_log`;
CREATE TABLE `sys_audit_log`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `UserId` bigint NULL DEFAULT NULL,
  `UserName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Action` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Route` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `IpAddress` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `UserAgent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Parameters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `IsSuccess` tinyint(1) NOT NULL,
  `ErrorMessage` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `ExecutionDuration` bigint NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 102 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_audit_log
-- ----------------------------
INSERT INTO `sys_audit_log` VALUES (1, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 2483, '2025-12-21 11:56:29.626300');
INSERT INTO `sys_audit_log` VALUES (2, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 236, '2025-12-21 11:56:58.631302');
INSERT INTO `sys_audit_log` VALUES (3, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 296, '2025-12-21 11:58:57.719667');
INSERT INTO `sys_audit_log` VALUES (4, 1, NULL, 'omsapi.Controllers.UserController.Create (omsapi)', '/api/user', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 581, '2025-12-21 13:34:02.557240');
INSERT INTO `sys_audit_log` VALUES (5, 1, NULL, 'omsapi.Controllers.RoleController.Create (omsapi)', '/api/role', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 352, '2025-12-21 13:34:17.070037');
INSERT INTO `sys_audit_log` VALUES (6, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/2/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 980, '2025-12-21 13:38:55.627283');
INSERT INTO `sys_audit_log` VALUES (7, 1, NULL, 'omsapi.Controllers.UserController.Update (omsapi)', '/api/user/2', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 544, '2025-12-21 13:39:32.030477');
INSERT INTO `sys_audit_log` VALUES (8, 1, NULL, 'omsapi.Controllers.UserController.Create (omsapi)', '/api/user', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 582, '2025-12-21 13:42:00.684260');
INSERT INTO `sys_audit_log` VALUES (9, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 230, '2025-12-21 13:42:17.776042');
INSERT INTO `sys_audit_log` VALUES (10, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 203, '2025-12-21 13:44:13.161464');
INSERT INTO `sys_audit_log` VALUES (11, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 203, '2025-12-21 13:44:25.320891');
INSERT INTO `sys_audit_log` VALUES (12, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 330, '2025-12-21 13:46:04.761594');
INSERT INTO `sys_audit_log` VALUES (13, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 204, '2025-12-21 13:46:23.356143');
INSERT INTO `sys_audit_log` VALUES (14, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 204, '2025-12-21 13:46:32.311564');
INSERT INTO `sys_audit_log` VALUES (15, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 204, '2025-12-21 13:48:06.210837');
INSERT INTO `sys_audit_log` VALUES (16, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 206, '2025-12-21 13:48:17.142514');
INSERT INTO `sys_audit_log` VALUES (17, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 202, '2025-12-21 13:49:31.014315');
INSERT INTO `sys_audit_log` VALUES (18, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 212, '2025-12-21 13:49:44.958996');
INSERT INTO `sys_audit_log` VALUES (19, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 178, '2025-12-21 13:51:27.255951');
INSERT INTO `sys_audit_log` VALUES (20, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 208, '2025-12-21 13:51:37.880973');
INSERT INTO `sys_audit_log` VALUES (21, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 169, '2025-12-21 13:54:07.766042');
INSERT INTO `sys_audit_log` VALUES (22, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 404, '2025-12-21 13:58:37.614267');
INSERT INTO `sys_audit_log` VALUES (23, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/69', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 311, '2025-12-21 14:03:43.714124');
INSERT INTO `sys_audit_log` VALUES (24, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/69', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 189, '2025-12-21 14:03:48.803533');
INSERT INTO `sys_audit_log` VALUES (25, 1, NULL, 'omsapi.Controllers.PermissionController.BatchUpdateStructure (omsapi)', '/api/permission/batch-structure', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 977, '2025-12-21 14:12:47.459868');
INSERT INTO `sys_audit_log` VALUES (26, 1, NULL, 'omsapi.Controllers.PermissionController.BatchUpdateStructure (omsapi)', '/api/permission/batch-structure', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 549, '2025-12-21 14:14:35.784716');
INSERT INTO `sys_audit_log` VALUES (27, 1, NULL, 'omsapi.Controllers.PermissionController.BatchUpdateStructure (omsapi)', '/api/permission/batch-structure', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 432, '2025-12-21 14:14:56.196529');
INSERT INTO `sys_audit_log` VALUES (28, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/8', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 220, '2025-12-21 14:21:59.721672');
INSERT INTO `sys_audit_log` VALUES (29, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/8', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 206, '2025-12-21 14:22:09.368652');
INSERT INTO `sys_audit_log` VALUES (30, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 411, '2025-12-21 15:02:16.221237');
INSERT INTO `sys_audit_log` VALUES (31, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 181, '2025-12-21 15:02:36.389153');
INSERT INTO `sys_audit_log` VALUES (32, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 342, '2025-12-21 15:15:43.300641');
INSERT INTO `sys_audit_log` VALUES (33, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 191, '2025-12-21 15:15:57.924919');
INSERT INTO `sys_audit_log` VALUES (34, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 180, '2025-12-21 15:16:11.337521');
INSERT INTO `sys_audit_log` VALUES (35, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 176, '2025-12-21 15:16:20.673738');
INSERT INTO `sys_audit_log` VALUES (36, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 422, '2025-12-21 15:24:31.716794');
INSERT INTO `sys_audit_log` VALUES (37, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 223, '2025-12-21 15:24:50.125717');
INSERT INTO `sys_audit_log` VALUES (38, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 775, '2025-12-21 15:25:05.012848');
INSERT INTO `sys_audit_log` VALUES (39, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 209, '2025-12-21 15:25:23.545938');
INSERT INTO `sys_audit_log` VALUES (40, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 918, '2025-12-21 15:33:21.918433');
INSERT INTO `sys_audit_log` VALUES (41, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 554, '2025-12-21 15:39:25.696157');
INSERT INTO `sys_audit_log` VALUES (42, 1, NULL, 'omsapi.Controllers.PermissionController.BatchUpdateStructure (omsapi)', '/api/permission/batch-structure', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 684, '2025-12-21 15:51:09.849180');
INSERT INTO `sys_audit_log` VALUES (43, 1, NULL, 'omsapi.Controllers.RoleController.Update (omsapi)', '/api/role/2', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 644, '2025-12-21 16:40:38.531970');
INSERT INTO `sys_audit_log` VALUES (44, 1, NULL, 'omsapi.Controllers.RoleController.Update (omsapi)', '/api/role/2', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 473, '2025-12-21 16:40:52.168871');
INSERT INTO `sys_audit_log` VALUES (45, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 233, '2025-12-21 16:41:20.811794');
INSERT INTO `sys_audit_log` VALUES (46, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 179, '2025-12-21 16:41:31.862965');
INSERT INTO `sys_audit_log` VALUES (47, 1, NULL, 'omsapi.Controllers.RoleController.Update (omsapi)', '/api/role/2', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 422, '2025-12-21 16:41:46.135155');
INSERT INTO `sys_audit_log` VALUES (48, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 179, '2025-12-21 16:42:00.860777');
INSERT INTO `sys_audit_log` VALUES (49, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 183, '2025-12-21 16:42:12.352368');
INSERT INTO `sys_audit_log` VALUES (50, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 321, '2025-12-21 17:14:11.540821');
INSERT INTO `sys_audit_log` VALUES (51, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/71', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 198, '2025-12-21 17:14:29.789402');
INSERT INTO `sys_audit_log` VALUES (52, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/53', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 181, '2025-12-21 17:14:36.706257');
INSERT INTO `sys_audit_log` VALUES (53, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 272, '2025-12-21 17:15:26.515748');
INSERT INTO `sys_audit_log` VALUES (54, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 622, '2025-12-21 17:17:45.290899');
INSERT INTO `sys_audit_log` VALUES (55, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 275, '2025-12-21 17:21:08.383539');
INSERT INTO `sys_audit_log` VALUES (56, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 528, '2025-12-21 17:21:22.525622');
INSERT INTO `sys_audit_log` VALUES (57, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 443, '2025-12-21 17:46:07.703991');
INSERT INTO `sys_audit_log` VALUES (58, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 376, '2025-12-21 17:48:18.481940');
INSERT INTO `sys_audit_log` VALUES (59, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 201, '2025-12-21 17:48:25.954603');
INSERT INTO `sys_audit_log` VALUES (60, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 186, '2025-12-21 17:48:36.898298');
INSERT INTO `sys_audit_log` VALUES (61, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 181, '2025-12-21 17:48:43.801392');
INSERT INTO `sys_audit_log` VALUES (62, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/6', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 173, '2025-12-21 17:48:49.462020');
INSERT INTO `sys_audit_log` VALUES (63, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 177, '2025-12-21 17:51:16.827471');
INSERT INTO `sys_audit_log` VALUES (64, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 171, '2025-12-21 17:51:21.767688');
INSERT INTO `sys_audit_log` VALUES (65, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 177, '2025-12-21 17:51:25.975803');
INSERT INTO `sys_audit_log` VALUES (66, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/6', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 178, '2025-12-21 17:51:30.184883');
INSERT INTO `sys_audit_log` VALUES (67, 1, NULL, 'omsapi.Controllers.UserController.Update (omsapi)', '/api/user/3', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 512, '2025-12-21 17:55:16.577573');
INSERT INTO `sys_audit_log` VALUES (68, 1, NULL, 'omsapi.Controllers.UserController.Update (omsapi)', '/api/user/2', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 448, '2025-12-21 17:55:27.582711');
INSERT INTO `sys_audit_log` VALUES (69, 1, NULL, 'omsapi.Controllers.PostController.Create (omsapi)', '/api/post', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 326, '2025-12-21 17:56:02.502602');
INSERT INTO `sys_audit_log` VALUES (70, 1, NULL, 'omsapi.Controllers.PostController.Create (omsapi)', '/api/post', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 272, '2025-12-21 17:56:23.410867');
INSERT INTO `sys_audit_log` VALUES (71, 1, NULL, 'omsapi.Controllers.UserController.Update (omsapi)', '/api/user/2', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 473, '2025-12-21 17:58:48.365846');
INSERT INTO `sys_audit_log` VALUES (72, 1, NULL, 'omsapi.Controllers.UserController.Update (omsapi)', '/api/user/3', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 448, '2025-12-21 17:58:59.247365');
INSERT INTO `sys_audit_log` VALUES (73, 1, NULL, 'omsapi.Controllers.PostController.Update (omsapi)', '/api/post/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 192, '2025-12-21 17:59:09.463022');
INSERT INTO `sys_audit_log` VALUES (74, 1, NULL, 'omsapi.Controllers.UserController.Update (omsapi)', '/api/user/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 459, '2025-12-21 18:06:14.423361');
INSERT INTO `sys_audit_log` VALUES (75, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 660, '2025-12-21 21:16:49.752134');
INSERT INTO `sys_audit_log` VALUES (76, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 519, '2025-12-21 22:07:52.112356');
INSERT INTO `sys_audit_log` VALUES (77, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 178, '2025-12-21 22:07:59.356954');
INSERT INTO `sys_audit_log` VALUES (78, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 176, '2025-12-21 22:12:21.211304');
INSERT INTO `sys_audit_log` VALUES (79, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 172, '2025-12-21 22:12:27.040798');
INSERT INTO `sys_audit_log` VALUES (80, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 174, '2025-12-21 22:14:15.383035');
INSERT INTO `sys_audit_log` VALUES (81, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 173, '2025-12-21 22:14:23.409345');
INSERT INTO `sys_audit_log` VALUES (82, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 297, '2025-12-21 22:20:51.892265');
INSERT INTO `sys_audit_log` VALUES (83, 1, NULL, 'omsapi.Controllers.DeptController.DeleteDept (omsapi)', '/api/dept/9', 'DELETE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 409, '2025-12-21 22:20:58.184067');
INSERT INTO `sys_audit_log` VALUES (84, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 193, '2025-12-21 22:22:27.865967');
INSERT INTO `sys_audit_log` VALUES (85, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/10', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 239, '2025-12-21 22:22:33.273217');
INSERT INTO `sys_audit_log` VALUES (86, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/10', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 190, '2025-12-21 22:22:41.492858');
INSERT INTO `sys_audit_log` VALUES (87, 1, NULL, 'omsapi.Controllers.DeptController.DeleteDept (omsapi)', '/api/dept/10', 'DELETE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 184, '2025-12-21 22:22:44.865209');
INSERT INTO `sys_audit_log` VALUES (88, 1, NULL, 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 177, '2025-12-21 22:23:27.405392');
INSERT INTO `sys_audit_log` VALUES (89, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/11', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 384, '2025-12-21 22:45:11.487581');
INSERT INTO `sys_audit_log` VALUES (90, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/11', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 169, '2025-12-21 22:45:26.191280');
INSERT INTO `sys_audit_log` VALUES (91, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 181, '2025-12-21 22:45:30.545669');
INSERT INTO `sys_audit_log` VALUES (92, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 469, '2025-12-21 23:21:10.631091');
INSERT INTO `sys_audit_log` VALUES (93, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/57', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 278, '2025-12-21 23:29:08.215496');
INSERT INTO `sys_audit_log` VALUES (94, 1, NULL, 'omsapi.Controllers.UserController.UpdateProfile (omsapi)', '/api/user/profile', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 364, '2025-12-21 23:40:42.878565');
INSERT INTO `sys_audit_log` VALUES (95, 1, NULL, 'omsapi.Controllers.UserController.UpdateProfile (omsapi)', '/api/user/profile', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 370, '2025-12-21 23:44:29.181568');
INSERT INTO `sys_audit_log` VALUES (96, 1, NULL, 'omsapi.Controllers.SystemConfigController.Update (omsapi)', '/api/systemconfig/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 216, '2025-12-21 23:49:03.321833');
INSERT INTO `sys_audit_log` VALUES (97, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.26100.7462', NULL, 0, '用户名或密码错误', 233, '2025-12-22 17:17:01.715191');
INSERT INTO `sys_audit_log` VALUES (98, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.26100.7462', NULL, 0, '用户名或密码错误', 148, '2025-12-22 17:17:19.355841');
INSERT INTO `sys_audit_log` VALUES (99, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.26100.7462', NULL, 0, '用户名或密码错误', 84, '2025-12-22 17:18:37.453697');
INSERT INTO `sys_audit_log` VALUES (100, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.26100.7462', NULL, 0, '用户名或密码错误', 83, '2025-12-22 17:18:59.485387');
INSERT INTO `sys_audit_log` VALUES (101, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.26100.7462', NULL, 0, '用户名或密码错误', 83, '2025-12-22 17:19:14.274537');

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `IsSystem` tinyint(1) NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_sys_config_Key`(`Key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, 'Basic', 'SystemName', '综合信息管理系统', '系统名称', 1, '2024-01-01 00:00:00.000000', '2025-12-21 23:49:03.231374');
INSERT INTO `sys_config` VALUES (2, 'Basic', 'SystemLogo', '/logo.svg', '系统Logo路径', 1, '2024-01-01 00:00:00.000000', NULL);
INSERT INTO `sys_config` VALUES (3, 'Basic', 'Copyright', '©2025 Created by jinlan.info', '底部版权信息', 1, '2024-01-01 00:00:00.000000', NULL);
INSERT INTO `sys_config` VALUES (4, 'Security', 'PasswordMinLength', '6', '密码最小长度', 1, '2024-01-01 00:00:00.000000', NULL);
INSERT INTO `sys_config` VALUES (5, 'Security', 'SessionTimeout', '30', '会话超时时间(分钟)', 1, '2024-01-01 00:00:00.000000', NULL);

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `ParentId` bigint NULL DEFAULT NULL,
  `Name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Leader` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `SortOrder` int NOT NULL,
  `IsActive` tinyint(1) NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NULL DEFAULT NULL,
  `Type` int NOT NULL DEFAULT 0,
  `X` double NULL DEFAULT NULL,
  `Y` double NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_sys_dept_ParentId`(`ParentId` ASC) USING BTREE,
  CONSTRAINT `FK_sys_dept_sys_dept_ParentId` FOREIGN KEY (`ParentId`) REFERENCES `sys_dept` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (1, 8, '总经办', '', '', '', '', 1, 1, '2025-12-21 15:02:15.810127', '2025-12-21 17:51:16.738415', 3, NULL, NULL);
INSERT INTO `sys_dept` VALUES (3, 8, '研发部', '', '', '', '', 2, 1, '2025-12-21 15:15:42.957169', '2025-12-21 17:51:21.680856', 3, NULL, NULL);
INSERT INTO `sys_dept` VALUES (4, 3, '前端开发部', '', '', '', '', 1, 1, '2025-12-21 15:15:57.732852', NULL, 3, NULL, NULL);
INSERT INTO `sys_dept` VALUES (5, 8, '销售部', '', '', '', '', 3, 1, '2025-12-21 15:16:11.156509', '2025-12-21 17:51:25.887155', 3, NULL, NULL);
INSERT INTO `sys_dept` VALUES (6, 8, '采购部', '', '', '', '', 4, 1, '2025-12-21 15:16:20.496914', '2025-12-21 17:51:30.097197', 3, NULL, NULL);
INSERT INTO `sys_dept` VALUES (7, NULL, '某某信息集团', '', '', '', '', 1, 1, '2025-12-21 17:46:07.260401', NULL, 1, NULL, NULL);
INSERT INTO `sys_dept` VALUES (8, 7, 'XX科技公司', '', '', '', '', 1, 1, '2025-12-21 17:48:18.106421', '2025-12-21 22:45:30.467713', 2, 420, 220);
INSERT INTO `sys_dept` VALUES (11, 7, 'XX加工厂', '', '张三', '', '', 0, 1, '2025-12-21 22:23:27.228311', '2025-12-21 22:45:26.109234', 2, 210, 220);

-- ----------------------------
-- Table structure for sys_file
-- ----------------------------
DROP TABLE IF EXISTS `sys_file`;
CREATE TABLE `sys_file`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Extension` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Size` bigint NOT NULL,
  `IsFolder` tinyint(1) NOT NULL,
  `FilePath` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `ContentType` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `ParentId` bigint NULL DEFAULT NULL,
  `OwnerId` bigint NOT NULL,
  `DeptId` bigint NULL DEFAULT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NOT NULL,
  `IsPublic` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_sys_file_OwnerId`(`OwnerId` ASC) USING BTREE,
  INDEX `IX_sys_file_ParentId`(`ParentId` ASC) USING BTREE,
  INDEX `IX_sys_file_DeptId`(`DeptId` ASC) USING BTREE,
  CONSTRAINT `FK_sys_file_sys_file_ParentId` FOREIGN KEY (`ParentId`) REFERENCES `sys_file` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_sys_file_sys_user_OwnerId` FOREIGN KEY (`OwnerId`) REFERENCES `sys_user` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FK_sys_file_sys_dept_DeptId` FOREIGN KEY (`DeptId`) REFERENCES `sys_dept` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_file
-- ----------------------------
INSERT INTO `sys_file` VALUES (1, '项目资料', NULL, 0, 1, NULL, NULL, NULL, 1, NULL, '2025-12-22 11:07:33.849901', '2025-12-22 11:07:33.850150', 0);
INSERT INTO `sys_file` VALUES (2, '测试项目', NULL, 0, 1, NULL, NULL, 1, 1, NULL, '2025-12-22 11:07:45.660080', '2025-12-22 11:07:45.660080', 0);
INSERT INTO `sys_file` VALUES (3, 'project-PRJ-2024-001-2025-12-21.png', '.png', 257719, 0, 'uploads/drive/admin/项目资料/测试项目/project-PRJ-2024-001-2025-12-21.png', 'image/png', 2, 1, NULL, '2025-12-22 11:07:59.912744', '2025-12-22 11:07:59.912745', 0);
INSERT INTO `sys_file` VALUES (4, 'VUE学习资料', NULL, 0, 1, NULL, NULL, NULL, 1, 4, '2025-12-22 11:40:24.133571', '2025-12-22 11:40:24.133663', 1);
INSERT INTO `sys_file` VALUES (5, '前端技能测评题.docx', '.docx', 16324, 0, 'uploads/drive/admin/VUE学习资料/前端技能测评题 (1).docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 4, 1, 4, '2025-12-22 11:45:33.184072', '2025-12-22 11:45:33.184171', 1);
INSERT INTO `sys_file` VALUES (6, '前端学习计划.docx', '.docx', 21119, 0, 'uploads/drive/admin/VUE学习资料/前端学习计划.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 4, 1, 4, '2025-12-22 11:45:40.058755', '2025-12-22 11:45:40.058758', 1);

-- ----------------------------
-- Table structure for sys_file_share
-- ----------------------------
DROP TABLE IF EXISTS `sys_file_share`;
CREATE TABLE `sys_file_share`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `FileId` bigint NOT NULL,
  `SharedByUserId` bigint NOT NULL,
  `SharedToUserId` bigint NULL DEFAULT NULL,
  `Permission` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `ExpirationTime` datetime(6) NULL DEFAULT NULL,
  `Token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_sys_file_share_FileId`(`FileId` ASC) USING BTREE,
  INDEX `IX_sys_file_share_SharedByUserId`(`SharedByUserId` ASC) USING BTREE,
  INDEX `IX_sys_file_share_SharedToUserId`(`SharedToUserId` ASC) USING BTREE,
  CONSTRAINT `FK_sys_file_share_sys_file_FileId` FOREIGN KEY (`FileId`) REFERENCES `sys_file` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FK_sys_file_share_sys_user_SharedByUserId` FOREIGN KEY (`SharedByUserId`) REFERENCES `sys_user` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_file_share
-- ----------------------------

-- ----------------------------
-- Table structure for sys_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `ParentId` bigint NULL DEFAULT NULL,
  `Name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Component` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `SortOrder` int NOT NULL,
  `IsVisible` tinyint(1) NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_sys_permission_Code`(`Code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 211 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_permission
-- ----------------------------
INSERT INTO `sys_permission` VALUES (1, NULL, '首页', 'HomeView', 'MENU', '/', 'views/HomeView.vue', 'ant-design:desktop-outlined', 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350342');
INSERT INTO `sys_permission` VALUES (2, NULL, '个人中心', 'personal', 'MENU', '/personal', 'Layout', 'ant-design:user-outlined', 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350453');
INSERT INTO `sys_permission` VALUES (3, 2, '任务事项', 'PersonalTodo', 'MENU', '/personal/todo', 'views/personal/TodoList.vue', NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350454');
INSERT INTO `sys_permission` VALUES (4, 2, '组织结构', 'PersonalOrganization', 'MENU', '/personal/organization', 'views/personal/Organization.vue', NULL, 50, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350457');
INSERT INTO `sys_permission` VALUES (5, 2, '消息中心', 'PersonalMessages', 'MENU', '/personal/messages', 'views/personal/Messages.vue', NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350456');
INSERT INTO `sys_permission` VALUES (6, 2, '文件网盘', 'PersonalDrive', 'MENU', '/personal/drive', 'views/personal/Drive.vue', NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350456');
INSERT INTO `sys_permission` VALUES (7, 2, '账号信息', 'PersonalAccount', 'MENU', '/personal/account', 'views/personal/Account.vue', NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350456');
INSERT INTO `sys_permission` VALUES (8, NULL, '合同管理', 'contract', 'MENU', '/contract', 'Layout', 'ant-design:file-text-outlined', 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350457');
INSERT INTO `sys_permission` VALUES (9, 8, '合同列表', 'ContractTrack', 'MENU', '/contract/track', 'views/contract/ContractTrack.vue', NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350457');
INSERT INTO `sys_permission` VALUES (10, 8, '合同模板', 'ContractTemplate', 'MENU', '/contract/template', 'views/contract/ContractTemplate.vue', NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350460');
INSERT INTO `sys_permission` VALUES (11, 8, '合同统计', 'ContractStats', 'MENU', '/contract/stats', 'views/contract/ContractStats.vue', NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350461');
INSERT INTO `sys_permission` VALUES (12, 8, '合同知识库', 'ContractKnowledge', 'MENU', '/contract/knowledge', 'views/contract/ContractKnowledge.vue', NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350461');
INSERT INTO `sys_permission` VALUES (13, NULL, '项目管理', 'project', 'MENU', '/project', 'Layout', 'ant-design:project-outlined', 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350462');
INSERT INTO `sys_permission` VALUES (14, 13, '项目统筹', 'ProjectList', 'MENU', '/project/list', 'views/project/ProjectList.vue', NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350462');
INSERT INTO `sys_permission` VALUES (15, 13, '文档协同', 'ProjectDoc', 'MENU', '/project/doc', 'views/project/ProjectDoc.vue', NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350464');
INSERT INTO `sys_permission` VALUES (16, 13, '成本控制', 'ProjectCost', 'MENU', '/project/cost', 'views/project/ProjectCost.vue', NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350465');
INSERT INTO `sys_permission` VALUES (17, NULL, '财务管理', 'finance', 'MENU', '/finance', 'Layout', 'ant-design:pay-circle-outlined', 50, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350465');
INSERT INTO `sys_permission` VALUES (18, 17, '应收应付', 'FinanceApAr', 'MENU', '/finance/ap-ar', 'views/finance/FinanceApAr.vue', NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350466');
INSERT INTO `sys_permission` VALUES (19, 17, '发票管理', 'FinanceInvoice', 'MENU', '/finance/invoice', 'views/finance/FinanceInvoice.vue', NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350466');
INSERT INTO `sys_permission` VALUES (20, 17, '财务报表', 'FinanceReport', 'MENU', '/finance/report', 'views/finance/FinanceReport.vue', NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350467');
INSERT INTO `sys_permission` VALUES (21, NULL, '销售管理', 'sales', 'MENU', '/sales', 'Layout', 'ant-design:shopping-cart-outlined', 60, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350468');
INSERT INTO `sys_permission` VALUES (22, 21, '商机管理', 'SalesOpportunity', 'MENU', '/sales/opportunity', 'views/sales/Opportunity.vue', NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350468');
INSERT INTO `sys_permission` VALUES (23, 21, '客户管理', 'SalesCustomer', 'MENU', '/sales/customer', 'views/sales/Customer.vue', NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350469');
INSERT INTO `sys_permission` VALUES (24, 21, '销售资料', 'SalesMaterials', 'MENU', '/sales/materials', 'views/sales/Materials.vue', NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350469');
INSERT INTO `sys_permission` VALUES (25, 21, '销售目标', 'SalesTargets', 'MENU', '/sales/targets', 'views/sales/Targets.vue', NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350470');
INSERT INTO `sys_permission` VALUES (26, NULL, '采购管理', 'procurement', 'MENU', '/procurement', 'Layout', 'ant-design:shopping-outlined', 70, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350471');
INSERT INTO `sys_permission` VALUES (27, 26, '采购需求', 'ProcurementRequest', 'MENU', '/procurement/request', 'views/procurement/Request.vue', NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350471');
INSERT INTO `sys_permission` VALUES (28, 26, '采购订单', 'ProcurementOrder', 'MENU', '/procurement/order', 'views/procurement/Order.vue', NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350472');
INSERT INTO `sys_permission` VALUES (29, 26, '供应商管理', 'ProcurementSupplier', 'MENU', '/procurement/supplier', 'views/procurement/Supplier.vue', NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350473');
INSERT INTO `sys_permission` VALUES (30, 26, '历史采购', 'ProcurementHistory', 'MENU', '/procurement/history', 'views/procurement/History.vue', NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350474');
INSERT INTO `sys_permission` VALUES (31, NULL, '库存管理', 'inventory', 'MENU', '/inventory', 'Layout', 'ant-design:shop-outlined', 80, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350474');
INSERT INTO `sys_permission` VALUES (32, 31, '仓库基础', 'InventoryWarehouse', 'MENU', '/inventory/warehouse', 'views/inventory/Warehouse.vue', NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350475');
INSERT INTO `sys_permission` VALUES (33, 31, '库存物品', 'InventoryProduct', 'MENU', '/inventory/product-info', 'views/inventory/ProductInfo.vue', NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350476');
INSERT INTO `sys_permission` VALUES (34, 31, '出入库管理', 'InventoryInOut', 'MENU', '/inventory/in-out', 'views/inventory/InOut.vue', NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350477');
INSERT INTO `sys_permission` VALUES (35, 31, '库内作业', 'InventoryInternal', 'MENU', '/inventory/internal', 'views/inventory/InternalOps.vue', NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350477');
INSERT INTO `sys_permission` VALUES (36, 31, '库存盘点', 'InventoryStocktaking', 'MENU', '/inventory/stocktaking', 'views/inventory/Stocktaking.vue', NULL, 50, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350478');
INSERT INTO `sys_permission` VALUES (37, 31, '库存跟踪', 'InventoryTrack', 'MENU', '/inventory/track', 'views/inventory/InventoryTrack.vue', NULL, 60, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350479');
INSERT INTO `sys_permission` VALUES (38, 31, '库存分析', 'InventoryAnalysis', 'MENU', '/inventory/analysis', 'views/inventory/Analysis.vue', NULL, 70, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350480');
INSERT INTO `sys_permission` VALUES (39, NULL, '流程管理', 'bpm', 'MENU', '/bpm', 'Layout', 'ant-design:apartment-outlined', 90, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350481');
INSERT INTO `sys_permission` VALUES (40, 39, '审批流程', 'BpmWorkflow', 'MENU', '/bpm/workflow', 'views/bpm/BpmWorkflow.vue', NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350482');
INSERT INTO `sys_permission` VALUES (41, 39, '任务自动化', 'BpmTask', 'MENU', '/bpm/task', 'views/bpm/BpmTask.vue', NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350483');
INSERT INTO `sys_permission` VALUES (42, NULL, '数据分析', 'bi', 'MENU', '/bi', 'Layout', 'ant-design:bar-chart-outlined', 100, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350484');
INSERT INTO `sys_permission` VALUES (43, 42, '经营仪表盘', 'BiDashboard', 'MENU', '/bi/dashboard', 'views/bi/BiDashboard.vue', NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350485');
INSERT INTO `sys_permission` VALUES (44, 42, '销售分析', 'BiSales', 'MENU', '/bi/sales', 'views/bi/BiSales.vue', NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350510');
INSERT INTO `sys_permission` VALUES (45, 42, '财务分析', 'BiFinance', 'MENU', '/bi/finance', 'views/bi/BiFinance.vue', NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350511');
INSERT INTO `sys_permission` VALUES (46, NULL, '档案管理', 'archive', 'MENU', '/archive', 'Layout', 'BankOutlined', 50, 1, '2025-12-22 15:47:30.000000', '2025-12-21 15:51:09.350512');
INSERT INTO `sys_permission` VALUES (47, 46, '档案查询', 'archive:query', 'MENU', 'query', 'views/archive/ArchiveQuery.vue', 'FileSearchOutlined', 1, 1, '2025-12-22 15:47:30.000000', '2025-12-21 15:51:09.350513');
INSERT INTO `sys_permission` VALUES (48, NULL, '数据管理', 'data', 'MENU', '/data', 'Layout', 'ant-design:database-outlined', 120, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350514');
INSERT INTO `sys_permission` VALUES (49, 48, '数据源管理', 'DataSource', 'MENU', '/data/source', 'views/data/DataSource.vue', NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350515');
INSERT INTO `sys_permission` VALUES (50, 48, '外部接口管理', 'DataInterface', 'MENU', '/data/interface', 'views/data/DataInterface.vue', NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350516');
INSERT INTO `sys_permission` VALUES (51, 48, '接口发布管理', 'InterfacePublish', 'MENU', '/data/interface-publish', 'views/data/InterfacePublish/Index.vue', NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350518');
INSERT INTO `sys_permission` VALUES (52, 48, 'ETL管理', 'ETL', 'MENU', '/data/etl', 'views/data/ETL/Index.vue', NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350519');
INSERT INTO `sys_permission` VALUES (53, NULL, '系统管理', 'system', 'MENU', '/system', 'Layout', 'ant-design:setting-outlined', 990, 1, '2025-12-21 13:18:20.719546', '2025-12-21 17:14:36.614535');
INSERT INTO `sys_permission` VALUES (54, 53, '用户管理', 'SysUser', 'MENU', '/system/user', 'views/system/SysUser.vue', NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350530');
INSERT INTO `sys_permission` VALUES (55, 53, '角色管理', 'SysRole', 'MENU', '/system/role', 'views/system/SysRole.vue', NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350523');
INSERT INTO `sys_permission` VALUES (56, 53, '权限管理', 'SysPermission', 'MENU', '/system/permission', 'views/system/SysPermission.vue', NULL, 50, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350541');
INSERT INTO `sys_permission` VALUES (57, 53, '组织结构', 'SysOrg', 'MENU', '/system/org', 'views/system/SysOrg.vue', '', 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 23:29:08.051313');
INSERT INTO `sys_permission` VALUES (58, 53, '系统配置', 'SysConfig', 'MENU', '/system/config', 'views/system/SysConfig.vue', NULL, 60, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350542');
INSERT INTO `sys_permission` VALUES (59, 53, '数据安全', 'SysSecurity', 'MENU', '/system/security', 'views/system/SysSecurity.vue', NULL, 70, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350544');
INSERT INTO `sys_permission` VALUES (60, 53, '系统集成', 'SysIntegration', 'MENU', '/system/integration', 'views/system/SysIntegration.vue', NULL, 80, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350545');
INSERT INTO `sys_permission` VALUES (61, 54, '新增用户', 'system:user:add', 'BUTTON', NULL, NULL, NULL, 40, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350535');
INSERT INTO `sys_permission` VALUES (62, 54, '编辑用户', 'system:user:edit', 'BUTTON', NULL, NULL, NULL, 30, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350534');
INSERT INTO `sys_permission` VALUES (63, 54, '删除用户', 'system:user:delete', 'BUTTON', NULL, NULL, NULL, 20, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350533');
INSERT INTO `sys_permission` VALUES (64, 54, '重置密码', 'system:user:reset_pwd', 'BUTTON', NULL, NULL, NULL, 10, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350531');
INSERT INTO `sys_permission` VALUES (65, 55, '新增角色', 'system:role:add', 'BUTTON', NULL, NULL, NULL, 40, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350529');
INSERT INTO `sys_permission` VALUES (66, 55, '编辑角色', 'system:role:edit', 'BUTTON', NULL, NULL, NULL, 30, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350527');
INSERT INTO `sys_permission` VALUES (67, 55, '删除角色', 'system:role:delete', 'BUTTON', NULL, NULL, NULL, 20, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350526');
INSERT INTO `sys_permission` VALUES (68, 55, '分配权限', 'system:role:assign_perm', 'BUTTON', NULL, NULL, NULL, 10, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350525');
INSERT INTO `sys_permission` VALUES (69, 9, '新建合同', 'contract:add', 'BUTTON', '', '', '', 10, 1, '2025-12-21 13:58:37.299112', '2025-12-21 15:51:09.350460');
INSERT INTO `sys_permission` VALUES (70, 53, '岗位管理', 'SysPost', 'MENU', '/system/post', 'views/system/SysPost.vue', '', 20, 1, '2025-12-21 15:24:31.385994', '2025-12-21 15:51:09.350522');
INSERT INTO `sys_permission` VALUES (71, NULL, '帮助中心', 'help', 'MENU', '/help', 'Layout', 'ant-design:file-text-outlined', 980, 1, '2025-12-21 17:14:11.323821', '2025-12-21 17:14:29.695189');
INSERT INTO `sys_permission` VALUES (72, 71, '用户手册', 'HelpManual', 'MENU', '/help/manual', 'views/help/HelpManual.vue', '', 1, 1, '2025-12-21 17:15:26.332443', NULL);
INSERT INTO `sys_permission` VALUES (73, 71, '运维手册', 'AdminManual', 'MENU', '/help/admin', 'views/help/AdminManual.vue', '', 2, 1, '2025-12-21 17:21:08.199435', NULL);
INSERT INTO `sys_permission` VALUES (102, 47, '全宗查看', 'archive:fond:view', 'BUTTON', NULL, NULL, NULL, 1, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (103, 47, '全宗新增', 'archive:fond:add', 'BUTTON', NULL, NULL, NULL, 2, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (104, 47, '全宗编辑', 'archive:fond:edit', 'BUTTON', NULL, NULL, NULL, 3, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (105, 47, '全宗删除', 'archive:fond:delete', 'BUTTON', NULL, NULL, NULL, 4, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (106, 47, '分类查看', 'archive:type:view', 'BUTTON', NULL, NULL, NULL, 5, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (107, 47, '分类新增', 'archive:type:add', 'BUTTON', NULL, NULL, NULL, 6, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (108, 47, '档案查看', 'archive:file:view', 'BUTTON', NULL, NULL, NULL, 7, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (109, 47, '档案新增', 'archive:file:add', 'BUTTON', NULL, NULL, NULL, 8, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (110, 47, '档案编辑', 'archive:file:edit', 'BUTTON', NULL, NULL, NULL, 9, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (111, 47, '档案删除', 'archive:file:delete', 'BUTTON', NULL, NULL, NULL, 10, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (201, 46, '电子档案', 'archive:electronic', 'MENU', 'electronic', 'views/archive/ElectronicArchive.vue', 'FileOutlined', 2, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (202, 46, '实物档案', 'archive:paper', 'MENU', 'paper', 'views/archive/PaperArchive.vue', 'FileTextOutlined', 3, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (203, 46, '库房管理', 'archive:warehouse', 'MENU', 'warehouse', 'views/archive/Warehouse.vue', 'BankOutlined', 5, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (204, 46, '密级设置', 'archive:security', 'MENU', 'security', 'views/archive/SecurityLevel.vue', 'LockOutlined', 6, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (205, 46, '借阅申请', 'borrow:apply', 'MENU', 'borrow-apply', 'views/archive/borrow/ApplyList.vue', 'AuditOutlined', 7, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (206, 46, '审批管理', 'borrow:approve', 'MENU', 'borrow-approve', 'views/archive/borrow/ApproveList.vue', 'SolutionOutlined', 8, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (207, 46, '借阅记录', 'borrow:record', 'MENU', 'borrow-record', 'views/archive/borrow/BorrowRecord.vue', 'HistoryOutlined', 9, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (208, 46, '水印设置', 'watermark:setting', 'MENU', 'watermark-setting', 'views/archive/watermark/WatermarkSetting.vue', 'ToolOutlined', 10, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (209, 46, '水印日志', 'watermark:log', 'MENU', 'watermark-log', 'views/archive/watermark/WatermarkLog.vue', 'FileProtectOutlined', 11, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (210, 46, '统计分析', 'analysis:usage', 'MENU', 'analysis-usage', 'views/archive/analysis/UsageAnalysis.vue', 'BarChartOutlined', 12, 1, '2025-12-22 17:15:35.000000', NULL);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `SortOrder` int NOT NULL,
  `IsActive` tinyint(1) NOT NULL,
  `Remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NULL DEFAULT NULL,
  `DeptId` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_sys_post_Code`(`Code` ASC) USING BTREE,
  INDEX `IX_sys_post_DeptId`(`DeptId` ASC) USING BTREE,
  CONSTRAINT `FK_sys_post_sys_dept_DeptId` FOREIGN KEY (`DeptId`) REFERENCES `sys_dept` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'FEDEV', '前端开发工程师', 1, 1, NULL, '2025-12-21 17:56:02.274200', '2025-12-21 17:59:09.370354', 4);
INSERT INTO `sys_post` VALUES (2, 'GMA', '总经理助理', 1, 1, NULL, '2025-12-21 17:56:23.229837', NULL, 1);

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `IsSystem` tinyint(1) NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NULL DEFAULT NULL,
  `DeptId` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_sys_role_Code`(`Code` ASC) USING BTREE,
  INDEX `IX_sys_role_DeptId`(`DeptId` ASC) USING BTREE,
  CONSTRAINT `FK_sys_role_sys_dept_DeptId` FOREIGN KEY (`DeptId`) REFERENCES `sys_dept` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'ADMIN', '系统最高权限', 1, '2024-01-01 00:00:00.000000', NULL, NULL);
INSERT INTO `sys_role` VALUES (2, '测试角色', 'TEST', '', 0, '2025-12-21 13:34:16.829274', '2025-12-21 16:41:45.800604', 3);

-- ----------------------------
-- Table structure for sys_role_inheritance
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_inheritance`;
CREATE TABLE `sys_role_inheritance`  (
  `ParentRoleId` bigint NOT NULL,
  `ChildRoleId` bigint NOT NULL,
  PRIMARY KEY (`ParentRoleId`, `ChildRoleId`) USING BTREE,
  INDEX `IX_sys_role_inheritance_ChildRoleId`(`ChildRoleId` ASC) USING BTREE,
  CONSTRAINT `FK_sys_role_inheritance_sys_role_ChildRoleId` FOREIGN KEY (`ChildRoleId`) REFERENCES `sys_role` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_sys_role_inheritance_sys_role_ParentRoleId` FOREIGN KEY (`ParentRoleId`) REFERENCES `sys_role` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_inheritance
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`  (
  `RoleId` bigint NOT NULL,
  `PermissionId` bigint NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  PRIMARY KEY (`RoleId`, `PermissionId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_permission
-- ----------------------------
INSERT INTO `sys_role_permission` VALUES (1, 1, '2025-12-21 17:21:22.230169');
INSERT INTO `sys_role_permission` VALUES (1, 2, '2025-12-21 17:21:22.230240');
INSERT INTO `sys_role_permission` VALUES (1, 3, '2025-12-21 17:21:22.230256');
INSERT INTO `sys_role_permission` VALUES (1, 4, '2025-12-21 17:21:22.230270');
INSERT INTO `sys_role_permission` VALUES (1, 5, '2025-12-21 17:21:22.230283');
INSERT INTO `sys_role_permission` VALUES (1, 6, '2025-12-21 17:21:22.230295');
INSERT INTO `sys_role_permission` VALUES (1, 7, '2025-12-21 17:21:22.230308');
INSERT INTO `sys_role_permission` VALUES (1, 8, '2025-12-21 17:21:22.230322');
INSERT INTO `sys_role_permission` VALUES (1, 9, '2025-12-21 17:21:22.230337');
INSERT INTO `sys_role_permission` VALUES (1, 10, '2025-12-21 17:21:22.230352');
INSERT INTO `sys_role_permission` VALUES (1, 11, '2025-12-21 17:21:22.230436');
INSERT INTO `sys_role_permission` VALUES (1, 12, '2025-12-21 17:21:22.230454');
INSERT INTO `sys_role_permission` VALUES (1, 13, '2025-12-21 17:21:22.230469');
INSERT INTO `sys_role_permission` VALUES (1, 14, '2025-12-21 17:21:22.230492');
INSERT INTO `sys_role_permission` VALUES (1, 15, '2025-12-21 17:21:22.230508');
INSERT INTO `sys_role_permission` VALUES (1, 16, '2025-12-21 17:21:22.230525');
INSERT INTO `sys_role_permission` VALUES (1, 17, '2025-12-21 17:21:22.230541');
INSERT INTO `sys_role_permission` VALUES (1, 18, '2025-12-21 17:21:22.230555');
INSERT INTO `sys_role_permission` VALUES (1, 19, '2025-12-21 17:21:22.230571');
INSERT INTO `sys_role_permission` VALUES (1, 20, '2025-12-21 17:21:22.230584');
INSERT INTO `sys_role_permission` VALUES (1, 21, '2025-12-21 17:21:22.230649');
INSERT INTO `sys_role_permission` VALUES (1, 22, '2025-12-21 17:21:22.230681');
INSERT INTO `sys_role_permission` VALUES (1, 23, '2025-12-21 17:21:22.230697');
INSERT INTO `sys_role_permission` VALUES (1, 24, '2025-12-21 17:21:22.230711');
INSERT INTO `sys_role_permission` VALUES (1, 25, '2025-12-21 17:21:22.230726');
INSERT INTO `sys_role_permission` VALUES (1, 26, '2025-12-21 17:21:22.230740');
INSERT INTO `sys_role_permission` VALUES (1, 27, '2025-12-21 17:21:22.230757');
INSERT INTO `sys_role_permission` VALUES (1, 28, '2025-12-21 17:21:22.230771');
INSERT INTO `sys_role_permission` VALUES (1, 29, '2025-12-21 17:21:22.230812');
INSERT INTO `sys_role_permission` VALUES (1, 30, '2025-12-21 17:21:22.230881');
INSERT INTO `sys_role_permission` VALUES (1, 31, '2025-12-21 17:21:22.230897');
INSERT INTO `sys_role_permission` VALUES (1, 32, '2025-12-21 17:21:22.230909');
INSERT INTO `sys_role_permission` VALUES (1, 33, '2025-12-21 17:21:22.230921');
INSERT INTO `sys_role_permission` VALUES (1, 34, '2025-12-21 17:21:22.230974');
INSERT INTO `sys_role_permission` VALUES (1, 35, '2025-12-21 17:21:22.230991');
INSERT INTO `sys_role_permission` VALUES (1, 36, '2025-12-21 17:21:22.231003');
INSERT INTO `sys_role_permission` VALUES (1, 37, '2025-12-21 17:21:22.231015');
INSERT INTO `sys_role_permission` VALUES (1, 38, '2025-12-21 17:21:22.231027');
INSERT INTO `sys_role_permission` VALUES (1, 39, '2025-12-21 17:21:22.231065');
INSERT INTO `sys_role_permission` VALUES (1, 40, '2025-12-21 17:21:22.231078');
INSERT INTO `sys_role_permission` VALUES (1, 41, '2025-12-21 17:21:22.231090');
INSERT INTO `sys_role_permission` VALUES (1, 42, '2025-12-21 17:21:22.231102');
INSERT INTO `sys_role_permission` VALUES (1, 43, '2025-12-21 17:21:22.231195');
INSERT INTO `sys_role_permission` VALUES (1, 44, '2025-12-21 17:21:22.231211');
INSERT INTO `sys_role_permission` VALUES (1, 45, '2025-12-21 17:21:22.231225');
INSERT INTO `sys_role_permission` VALUES (1, 46, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 47, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 48, '2025-12-21 17:21:22.231263');
INSERT INTO `sys_role_permission` VALUES (1, 49, '2025-12-21 17:21:22.231276');
INSERT INTO `sys_role_permission` VALUES (1, 50, '2025-12-21 17:21:22.231289');
INSERT INTO `sys_role_permission` VALUES (1, 51, '2025-12-21 17:21:22.231302');
INSERT INTO `sys_role_permission` VALUES (1, 52, '2025-12-21 17:21:22.231314');
INSERT INTO `sys_role_permission` VALUES (1, 53, '2025-12-21 17:21:22.231327');
INSERT INTO `sys_role_permission` VALUES (1, 54, '2025-12-21 17:21:22.231340');
INSERT INTO `sys_role_permission` VALUES (1, 55, '2025-12-21 17:21:22.231362');
INSERT INTO `sys_role_permission` VALUES (1, 56, '2025-12-21 17:21:22.231376');
INSERT INTO `sys_role_permission` VALUES (1, 57, '2025-12-21 17:21:22.231389');
INSERT INTO `sys_role_permission` VALUES (1, 58, '2025-12-21 17:21:22.231401');
INSERT INTO `sys_role_permission` VALUES (1, 59, '2025-12-21 17:21:22.231414');
INSERT INTO `sys_role_permission` VALUES (1, 60, '2025-12-21 17:21:22.231427');
INSERT INTO `sys_role_permission` VALUES (1, 61, '2025-12-21 17:21:22.231440');
INSERT INTO `sys_role_permission` VALUES (1, 62, '2025-12-21 17:21:22.231453');
INSERT INTO `sys_role_permission` VALUES (1, 63, '2025-12-21 17:21:22.231466');
INSERT INTO `sys_role_permission` VALUES (1, 64, '2025-12-21 17:21:22.231479');
INSERT INTO `sys_role_permission` VALUES (1, 65, '2025-12-21 17:21:22.231492');
INSERT INTO `sys_role_permission` VALUES (1, 66, '2025-12-21 17:21:22.231506');
INSERT INTO `sys_role_permission` VALUES (1, 67, '2025-12-21 17:21:22.231519');
INSERT INTO `sys_role_permission` VALUES (1, 68, '2025-12-21 17:21:22.231581');
INSERT INTO `sys_role_permission` VALUES (1, 69, '2025-12-21 17:21:22.231597');
INSERT INTO `sys_role_permission` VALUES (1, 70, '2025-12-21 17:21:22.231611');
INSERT INTO `sys_role_permission` VALUES (1, 71, '2025-12-21 17:21:22.231623');
INSERT INTO `sys_role_permission` VALUES (1, 72, '2025-12-21 17:21:22.231636');
INSERT INTO `sys_role_permission` VALUES (1, 73, '2025-12-21 17:21:22.231649');
INSERT INTO `sys_role_permission` VALUES (1, 74, '2025-12-22 17:15:35.000000');
INSERT INTO `sys_role_permission` VALUES (1, 102, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 103, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 104, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 105, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 106, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 107, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 108, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 109, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 110, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 111, '2025-12-22 15:47:30.000000');
INSERT INTO `sys_role_permission` VALUES (1, 201, '2025-12-22 17:15:35.000000');
INSERT INTO `sys_role_permission` VALUES (1, 202, '2025-12-22 17:15:35.000000');
INSERT INTO `sys_role_permission` VALUES (1, 203, '2025-12-22 17:15:35.000000');
INSERT INTO `sys_role_permission` VALUES (1, 204, '2025-12-22 17:15:35.000000');
INSERT INTO `sys_role_permission` VALUES (1, 205, '2025-12-22 17:15:35.000000');
INSERT INTO `sys_role_permission` VALUES (1, 206, '2025-12-22 17:15:35.000000');
INSERT INTO `sys_role_permission` VALUES (1, 207, '2025-12-22 17:15:36.000000');
INSERT INTO `sys_role_permission` VALUES (1, 208, '2025-12-22 17:15:36.000000');
INSERT INTO `sys_role_permission` VALUES (1, 209, '2025-12-22 17:15:36.000000');
INSERT INTO `sys_role_permission` VALUES (1, 210, '2025-12-22 17:15:36.000000');
INSERT INTO `sys_role_permission` VALUES (2, 1, '2025-12-21 13:38:55.209209');
INSERT INTO `sys_role_permission` VALUES (2, 2, '2025-12-21 13:38:55.232660');
INSERT INTO `sys_role_permission` VALUES (2, 3, '2025-12-21 13:38:55.233562');
INSERT INTO `sys_role_permission` VALUES (2, 4, '2025-12-21 13:38:55.233607');
INSERT INTO `sys_role_permission` VALUES (2, 5, '2025-12-21 13:38:55.233640');
INSERT INTO `sys_role_permission` VALUES (2, 6, '2025-12-21 13:38:55.233669');
INSERT INTO `sys_role_permission` VALUES (2, 7, '2025-12-21 13:38:55.233697');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `LastLoginAt` datetime(6) NULL DEFAULT NULL,
  `Avatar` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `DeptId` bigint NULL DEFAULT NULL,
  `Status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_sys_user_Username`(`Username` ASC) USING BTREE,
  INDEX `IX_sys_user_DeptId`(`DeptId` ASC) USING BTREE,
  CONSTRAINT `FK_sys_user_sys_dept_DeptId` FOREIGN KEY (`DeptId`) REFERENCES `sys_dept` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', NULL, NULL, NULL, 1, '2024-01-01 00:00:00.000000', '2025-12-21 23:21:10.524768', '/uploads/avatars/1_09f7e7b6-b435-4c3d-b58b-952aa2e8a1cb.jpg', 7, 'out');
INSERT INTO `sys_user` VALUES (2, 'test', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '测试用户', 'test@jinlan.info', '13333333333', 1, '2025-12-21 13:34:02.083370', '2025-12-21 16:42:00.770346', NULL, 1, NULL);
INSERT INTO `sys_user` VALUES (3, 'test1', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '测试用户1', 'raorong@jinlan.info', '13333333333', 1, '2025-12-21 13:42:00.211431', NULL, NULL, 4, NULL);

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `UserId` bigint NOT NULL,
  `PostId` bigint NOT NULL,
  `DeptId` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`UserId`, `PostId`, `DeptId`) USING BTREE,
  INDEX `IX_sys_user_post_PostId`(`PostId` ASC) USING BTREE,
  INDEX `IX_sys_user_post_DeptId`(`DeptId` ASC) USING BTREE,
  CONSTRAINT `FK_sys_user_post_sys_dept_DeptId` FOREIGN KEY (`DeptId`) REFERENCES `sys_dept` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FK_sys_user_post_sys_post_PostId` FOREIGN KEY (`PostId`) REFERENCES `sys_post` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FK_sys_user_post_sys_user_UserId` FOREIGN KEY (`UserId`) REFERENCES `sys_user` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES (3, 1, 4);
INSERT INTO `sys_user_post` VALUES (2, 2, 1);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `UserId` bigint NOT NULL,
  `RoleId` bigint NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  PRIMARY KEY (`UserId`, `RoleId`) USING BTREE,
  INDEX `IX_sys_user_role_RoleId`(`RoleId` ASC) USING BTREE,
  CONSTRAINT `FK_sys_user_role_sys_role_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `sys_role` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FK_sys_user_role_sys_user_UserId` FOREIGN KEY (`UserId`) REFERENCES `sys_user` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1, '2025-12-21 18:06:14.190891');
INSERT INTO `sys_user_role` VALUES (2, 2, '2025-12-21 17:58:48.113620');
INSERT INTO `sys_user_role` VALUES (3, 2, '2025-12-21 17:58:59.021823');

SET FOREIGN_KEY_CHECKS = 1;
