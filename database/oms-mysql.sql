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

 Date: 04/01/2026 21:23:37
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
INSERT INTO `__efmigrationshistory` VALUES ('20251222092851_Initial', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251223040110_AddDataSourceConnection', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251224161620_AddPermissionQuery', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251225025233_AddBigViewProject', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251225041239_UpdateBigViewProjectStateLength', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251226031009_AddForms', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251226034533_AddFormResult', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251226035639_UpdateFormItemsToLongText', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251226035906_RenameFormResultTable', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251226041042_AddFormRequiresLogin', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251226074152_AddFormLimitOnePerUser', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251226125757_AddFormPermissions', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251227050330_AddInterfaceEntities', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251227054736_AddUrlPrefixToInterfaceCategory', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251227060156_AddInterfaceRoles', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251227060405_RenameExecuteToCallRoles', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251228094057_AddPageTables', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251228134646_AddContractEntities', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251228135843_UpdateContractStats', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251228141345_AddContractDetails', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251228153824_AddContentTypeToKnowledgeFile', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20251228154949_ChangeKnowledgeFileSizeToLong', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20260101030353_RenameProjectFlowToProject', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20260104124733_UpdateSalesSchema', '9.0.0');
INSERT INTO `__efmigrationshistory` VALUES ('20260104130149_AddDictEntities', '9.0.0');

-- ----------------------------
-- Table structure for api_category
-- ----------------------------
DROP TABLE IF EXISTS `api_category`;
CREATE TABLE `api_category`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ParentId` bigint NULL DEFAULT NULL,
  `SortOrder` int NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `CreatedBy` bigint NULL DEFAULT NULL,
  `UrlPrefix` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_api_category_ParentId`(`ParentId` ASC) USING BTREE,
  CONSTRAINT `FK_api_category_api_category_ParentId` FOREIGN KEY (`ParentId`) REFERENCES `api_category` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of api_category
-- ----------------------------
INSERT INTO `api_category` VALUES (1, '生产类', NULL, 1, '2025-12-27 13:38:00.131361', 0, '/mes/made');
INSERT INTO `api_category` VALUES (2, '销售类', NULL, 2, '2025-12-27 13:38:18.442605', 0, '/sales');

-- ----------------------------
-- Table structure for api_definition
-- ----------------------------
DROP TABLE IF EXISTS `api_definition`;
CREATE TABLE `api_definition`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `CategoryId` bigint NOT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `FlowConfig` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `IsPublished` tinyint(1) NOT NULL,
  `RequiresAuth` tinyint(1) NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NOT NULL,
  `CreatedBy` bigint NULL DEFAULT NULL,
  `UpdatedBy` bigint NULL DEFAULT NULL,
  `ManageRoles` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `ViewRoles` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `CallRoles` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_api_definition_CategoryId`(`CategoryId` ASC) USING BTREE,
  CONSTRAINT `FK_api_definition_api_category_CategoryId` FOREIGN KEY (`CategoryId`) REFERENCES `api_category` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of api_definition
-- ----------------------------
INSERT INTO `api_definition` VALUES (1, 1, '今日生产计划', 'plans', 'GET', '', '{\"nodes\":[{\"id\":\"req_1\",\"type\":\"request\",\"x\":-436.40625,\"y\":93.16665649414062,\"label\":\"接收请求\",\"data\":{\"method\":\"GET\"}},{\"id\":\"res_1\",\"type\":\"response\",\"x\":838.59375,\"y\":93.16665649414062,\"label\":\"发送响应\",\"data\":{\"contentType\":\"json\",\"joinMode\":\"all\",\"paramMode\":\"custom\",\"script\":\"return context.code_1;\"}},{\"id\":\"db_1\",\"type\":\"database\",\"x\":-100.3125,\"y\":93.16665649414062,\"label\":\"数据操作\",\"data\":{\"sourceId\":\"db1\",\"opType\":\"select\",\"sql\":\"SELECT * FROM testdb.test1;\",\"joinMode\":\"all\"}},{\"id\":\"api_1\",\"type\":\"api\",\"x\":230.1875,\"y\":93.16665649414062,\"label\":\"外部接口\",\"data\":{\"url\":\"https://www.baidu.com\",\"joinMode\":\"all\",\"paramMode\":\"custom\",\"headers\":[],\"params\":[]}},{\"id\":\"code_1\",\"type\":\"script\",\"x\":550.1875,\"y\":93.16665649414062,\"label\":\"脚本逻辑\",\"data\":{\"script\":\"var rows = context.dbResult;\\nvar total = 0;\\nfor(var i=0; i<rows.length; i++) {\\n   total += rows[i].age;\\n}\\nreturn { totalAmount: total };\",\"joinMode\":\"all\",\"language\":\"JavaScript\"}},{\"id\":\"api_2\",\"type\":\"api\",\"x\":230.1875,\"y\":-74.90245521359329,\"label\":\"外部接口\",\"data\":{\"method\":\"GET\",\"paramMode\":\"custom\",\"headers\":[],\"params\":[],\"joinMode\":\"all\",\"url\":\"https://www.qq.com\"}}],\"edges\":[{\"id\":\"9b571afa-6f39-4650-8362-38b0702d9ee9\",\"sourceId\":\"req_1\",\"targetId\":\"db_1\"},{\"id\":\"57e2bf06-1d3e-4dc6-b097-1fee2f246079\",\"sourceId\":\"db_1\",\"targetId\":\"api_1\"},{\"id\":\"4faee183-e196-4d61-bd37-c75adb60f4fd\",\"sourceId\":\"api_1\",\"targetId\":\"code_1\"},{\"id\":\"029ee7af-2282-43bb-acad-90b7a2097d06\",\"sourceId\":\"code_1\",\"targetId\":\"res_1\"},{\"id\":\"2f925ad5-4285-4517-b1a3-debb1db3d3c2\",\"sourceId\":\"db_1\",\"targetId\":\"api_2\"}]}', 0, 0, '2025-12-27 13:39:11.467822', '2025-12-29 10:13:07.696764', 0, 0, '', '', '');
INSERT INTO `api_definition` VALUES (2, 2, '最近12个月销量趋势', 'currentyear/trend', 'GET', '', NULL, 0, 0, '2025-12-27 14:29:58.129609', '2025-12-27 14:29:58.129667', 0, NULL, '', '', '');

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
-- Table structure for bigview_project
-- ----------------------------
DROP TABLE IF EXISTS `bigview_project`;
CREATE TABLE `bigview_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `project_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `state` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `create_by` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `is_delete` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `index_image` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `remarks` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bigview_project
-- ----------------------------
INSERT INTO `bigview_project` VALUES (1, '测试项目', '-1', '2025-12-25 12:16:15.799692', '0', '0', '/uploads/bigview/1.png', '\"{\\n  \\u0022editCanvasConfig\\u0022: {\\n    \\u0022projectName\\u0022: \\u0022\\u6D4B\\u8BD5\\u9879\\u76EE\\u0022,\\n    \\u0022width\\u0022: 1920,\\n    \\u0022height\\u0022: 1080,\\n    \\u0022filterShow\\u0022: false,\\n    \\u0022hueRotate\\u0022: 0,\\n    \\u0022saturate\\u0022: 1,\\n    \\u0022contrast\\u0022: 1,\\n    \\u0022brightness\\u0022: 1,\\n    \\u0022opacity\\u0022: 1,\\n    \\u0022rotateZ\\u0022: 0,\\n    \\u0022rotateX\\u0022: 0,\\n    \\u0022rotateY\\u0022: 0,\\n    \\u0022skewX\\u0022: 0,\\n    \\u0022skewY\\u0022: 0,\\n    \\u0022blendMode\\u0022: \\u0022normal\\u0022,\\n    \\u0022background\\u0022: null,\\n    \\u0022backgroundImage\\u0022: null,\\n    \\u0022selectColor\\u0022: true,\\n    \\u0022chartThemeColor\\u0022: \\u0022dark\\u0022,\\n    \\u0022chartCustomThemeColorInfo\\u0022: null,\\n    \\u0022chartThemeSetting\\u0022: {\\n      \\u0022title\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022textStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#BFBFBF\\u0022,\\n          \\u0022fontSize\\u0022: 18\\n        },\\n        \\u0022subtextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#A2A2A2\\u0022,\\n          \\u0022fontSize\\u0022: 14\\n        }\\n      },\\n      \\u0022xAxis\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022name\\u0022: \\u0022\\u0022,\\n        \\u0022nameGap\\u0022: 15,\\n        \\u0022nameTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 12\\n        },\\n        \\u0022inverse\\u0022: false,\\n        \\u0022axisLabel\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022fontSize\\u0022: 12,\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022rotate\\u0022: 0\\n        },\\n        \\u0022position\\u0022: \\u0022bottom\\u0022,\\n        \\u0022axisLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022width\\u0022: 1\\n          },\\n          \\u0022onZero\\u0022: true\\n        },\\n        \\u0022axisTick\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022length\\u0022: 5\\n        },\\n        \\u0022splitLine\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#484753\\u0022,\\n            \\u0022width\\u0022: 1,\\n            \\u0022type\\u0022: \\u0022solid\\u0022\\n          }\\n        },\\n        \\u0022min\\u0022: null,\\n        \\u0022max\\u0022: null\\n      },\\n      \\u0022yAxis\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022name\\u0022: \\u0022\\u0022,\\n        \\u0022nameGap\\u0022: 15,\\n        \\u0022max\\u0022: null,\\n        \\u0022min\\u0022: null,\\n        \\u0022nameTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 12\\n        },\\n        \\u0022inverse\\u0022: false,\\n        \\u0022axisLabel\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022fontSize\\u0022: 12,\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022rotate\\u0022: 0\\n        },\\n        \\u0022position\\u0022: \\u0022left\\u0022,\\n        \\u0022axisLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022width\\u0022: 1\\n          },\\n          \\u0022onZero\\u0022: true\\n        },\\n        \\u0022axisTick\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022length\\u0022: 5\\n        },\\n        \\u0022splitLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#484753\\u0022,\\n            \\u0022width\\u0022: 1,\\n            \\u0022type\\u0022: \\u0022solid\\u0022\\n          }\\n        }\\n      },\\n      \\u0022legend\\u0022: {\\n        \\u0022show\\u0022: false,\\n        \\u0022type\\u0022: \\u0022scroll\\u0022,\\n        \\u0022x\\u0022: \\u0022center\\u0022,\\n        \\u0022y\\u0022: \\u0022top\\u0022,\\n        \\u0022icon\\u0022: \\u0022circle\\u0022,\\n        \\u0022orient\\u0022: \\u0022horizontal\\u0022,\\n        \\u0022textStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 18\\n        },\\n        \\u0022itemHeight\\u0022: 15,\\n        \\u0022itemWidth\\u0022: 15,\\n        \\u0022pageTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022\\n        }\\n      },\\n      \\u0022grid\\u0022: {\\n        \\u0022show\\u0022: false,\\n        \\u0022left\\u0022: \\u002210%\\u0022,\\n        \\u0022top\\u0022: \\u002260\\u0022,\\n        \\u0022right\\u0022: \\u002210%\\u0022,\\n        \\u0022bottom\\u0022: \\u002260\\u0022\\n      },\\n      \\u0022dataset\\u0022: null,\\n      \\u0022renderer\\u0022: \\u0022svg\\u0022\\n    },\\n    \\u0022previewScaleType\\u0022: \\u0022fit\\u0022,\\n    \\u0022previewTheme\\u0022: \\u0022dark\\u0022\\n  },\\n  \\u0022componentList\\u0022: [\\n    {\\n      \\u0022id\\u0022: \\u0022id_127dubdy2hvk00\\u0022,\\n      \\u0022isGroup\\u0022: false,\\n      \\u0022attr\\u0022: {\\n        \\u0022x\\u0022: 532,\\n        \\u0022y\\u0022: 317,\\n        \\u0022w\\u0022: 500,\\n        \\u0022h\\u0022: 300,\\n        \\u0022offsetX\\u0022: 0,\\n        \\u0022offsetY\\u0022: 0,\\n        \\u0022zIndex\\u0022: -1\\n      },\\n      \\u0022styles\\u0022: {\\n        \\u0022filterShow\\u0022: false,\\n        \\u0022hueRotate\\u0022: 0,\\n        \\u0022saturate\\u0022: 1,\\n        \\u0022contrast\\u0022: 1,\\n        \\u0022brightness\\u0022: 1,\\n        \\u0022opacity\\u0022: 1,\\n        \\u0022rotateZ\\u0022: 0,\\n        \\u0022rotateX\\u0022: 0,\\n        \\u0022rotateY\\u0022: 0,\\n        \\u0022skewX\\u0022: 0,\\n        \\u0022skewY\\u0022: 0,\\n        \\u0022blendMode\\u0022: \\u0022normal\\u0022,\\n        \\u0022animations\\u0022: []\\n      },\\n      \\u0022preview\\u0022: {\\n        \\u0022overFlowHidden\\u0022: false\\n      },\\n      \\u0022status\\u0022: {\\n        \\u0022lock\\u0022: false,\\n        \\u0022hide\\u0022: false\\n      },\\n      \\u0022request\\u0022: {\\n        \\u0022requestDataType\\u0022: 0,\\n        \\u0022requestHttpType\\u0022: \\u0022get\\u0022,\\n        \\u0022requestUrl\\u0022: \\u0022\\u0022,\\n        \\u0022requestInterval\\u0022: null,\\n        \\u0022requestIntervalUnit\\u0022: \\u0022second\\u0022,\\n        \\u0022requestContentType\\u0022: 0,\\n        \\u0022requestParamsBodyType\\u0022: \\u0022none\\u0022,\\n        \\u0022requestSQLContent\\u0022: {\\n          \\u0022sql\\u0022: \\u0022select * from  where\\u0022,\\n          \\u0022id\\u0022: \\u0022\\u0022,\\n          \\u0022key\\u0022: \\u0022\\u0022,\\n          \\u0022aux\\u0022: {},\\n          \\u0022fileds\\u0022: []\\n        },\\n        \\u0022requestParams\\u0022: {\\n          \\u0022Body\\u0022: {\\n            \\u0022form-data\\u0022: {},\\n            \\u0022x-www-form-urlencoded\\u0022: {},\\n            \\u0022json\\u0022: \\u0022\\u0022,\\n            \\u0022xml\\u0022: \\u0022\\u0022\\n          },\\n          \\u0022Header\\u0022: {},\\n          \\u0022Params\\u0022: {}\\n        }\\n      },\\n      \\u0022filter\\u0022: null,\\n      \\u0022events\\u0022: {\\n        \\u0022baseEvent\\u0022: {\\n          \\u0022click\\u0022: null,\\n          \\u0022dblclick\\u0022: null,\\n          \\u0022change\\u0022: null,\\n          \\u0022mouseenter\\u0022: null,\\n          \\u0022mouseleave\\u0022: null\\n        },\\n        \\u0022advancedEvents\\u0022: {\\n          \\u0022vnodeMounted\\u0022: null,\\n          \\u0022vnodeBeforeMount\\u0022: null\\n        },\\n        \\u0022interactEvents\\u0022: []\\n      },\\n      \\u0022key\\u0022: \\u0022BarCommon\\u0022,\\n      \\u0022chartConfig\\u0022: {\\n        \\u0022key\\u0022: \\u0022BarCommon\\u0022,\\n        \\u0022chartKey\\u0022: \\u0022VBarCommon\\u0022,\\n        \\u0022conKey\\u0022: \\u0022VCBarCommon\\u0022,\\n        \\u0022title\\u0022: \\u0022\\u67F1\\u72B6\\u56FE\\u0022,\\n        \\u0022category\\u0022: \\u0022Bars\\u0022,\\n        \\u0022categoryName\\u0022: \\u0022\\u67F1\\u72B6\\u56FE\\u0022,\\n        \\u0022package\\u0022: \\u0022Charts\\u0022,\\n        \\u0022chartFrame\\u0022: \\u0022echarts\\u0022,\\n        \\u0022image\\u0022: \\u0022bar_x.png\\u0022\\n      },\\n      \\u0022option\\u0022: {\\n        \\u0022legend\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022type\\u0022: \\u0022scroll\\u0022,\\n          \\u0022x\\u0022: \\u0022center\\u0022,\\n          \\u0022y\\u0022: \\u0022top\\u0022,\\n          \\u0022icon\\u0022: \\u0022circle\\u0022,\\n          \\u0022orient\\u0022: \\u0022horizontal\\u0022,\\n          \\u0022textStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 18\\n          },\\n          \\u0022itemHeight\\u0022: 15,\\n          \\u0022itemWidth\\u0022: 15,\\n          \\u0022pageTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022\\n          }\\n        },\\n        \\u0022xAxis\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022name\\u0022: \\u0022\\u0022,\\n          \\u0022nameGap\\u0022: 15,\\n          \\u0022nameTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 12\\n          },\\n          \\u0022inverse\\u0022: false,\\n          \\u0022axisLabel\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022fontSize\\u0022: 12,\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022rotate\\u0022: 0\\n          },\\n          \\u0022position\\u0022: \\u0022bottom\\u0022,\\n          \\u0022axisLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n              \\u0022width\\u0022: 1\\n            },\\n            \\u0022onZero\\u0022: true\\n          },\\n          \\u0022axisTick\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022length\\u0022: 5\\n          },\\n          \\u0022splitLine\\u0022: {\\n            \\u0022show\\u0022: false,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#484753\\u0022,\\n              \\u0022width\\u0022: 1,\\n              \\u0022type\\u0022: \\u0022solid\\u0022\\n            }\\n          },\\n          \\u0022min\\u0022: null,\\n          \\u0022max\\u0022: null,\\n          \\u0022type\\u0022: \\u0022category\\u0022\\n        },\\n        \\u0022yAxis\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022name\\u0022: \\u0022\\u0022,\\n          \\u0022nameGap\\u0022: 15,\\n          \\u0022max\\u0022: null,\\n          \\u0022min\\u0022: null,\\n          \\u0022nameTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 12\\n          },\\n          \\u0022inverse\\u0022: false,\\n          \\u0022axisLabel\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022fontSize\\u0022: 12,\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022rotate\\u0022: 0\\n          },\\n          \\u0022position\\u0022: \\u0022left\\u0022,\\n          \\u0022axisLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n              \\u0022width\\u0022: 1\\n            },\\n            \\u0022onZero\\u0022: true\\n          },\\n          \\u0022axisTick\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022length\\u0022: 5\\n          },\\n          \\u0022splitLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#484753\\u0022,\\n              \\u0022width\\u0022: 1,\\n              \\u0022type\\u0022: \\u0022solid\\u0022\\n            }\\n          },\\n          \\u0022type\\u0022: \\u0022value\\u0022\\n        },\\n        \\u0022grid\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022left\\u0022: \\u002210%\\u0022,\\n          \\u0022top\\u0022: \\u002260\\u0022,\\n          \\u0022right\\u0022: \\u002210%\\u0022,\\n          \\u0022bottom\\u0022: \\u002260\\u0022\\n        },\\n        \\u0022tooltip\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022trigger\\u0022: \\u0022axis\\u0022,\\n          \\u0022axisPointer\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022type\\u0022: \\u0022shadow\\u0022\\n          }\\n        },\\n        \\u0022dataZoom\\u0022: [\\n          {\\n            \\u0022show\\u0022: true,\\n            \\u0022type\\u0022: \\u0022inside\\u0022,\\n            \\u0022disabled\\u0022: false,\\n            \\u0022realtime\\u0022: true,\\n            \\u0022start\\u0022: 0,\\n            \\u0022end\\u0022: 100,\\n            \\u0022xAxisIndex\\u0022: [\\n              0,\\n              1\\n            ]\\n          }\\n        ],\\n        \\u0022dataset\\u0022: {\\n          \\u0022dimensions\\u0022: [\\n            \\u0022product\\u0022,\\n            \\u0022data1\\u0022,\\n            \\u0022data2\\u0022\\n          ],\\n          \\u0022source\\u0022: [\\n            {\\n              \\u0022product\\u0022: \\u0022Mon\\u0022,\\n              \\u0022data1\\u0022: 120,\\n              \\u0022data2\\u0022: 130\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Tue\\u0022,\\n              \\u0022data1\\u0022: 200,\\n              \\u0022data2\\u0022: 130\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Wed\\u0022,\\n              \\u0022data1\\u0022: 150,\\n              \\u0022data2\\u0022: 312\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Thu\\u0022,\\n              \\u0022data1\\u0022: 80,\\n              \\u0022data2\\u0022: 268\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Fri\\u0022,\\n              \\u0022data1\\u0022: 70,\\n              \\u0022data2\\u0022: 155\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Sat\\u0022,\\n              \\u0022data1\\u0022: 110,\\n              \\u0022data2\\u0022: 117\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Sun\\u0022,\\n              \\u0022data1\\u0022: 130,\\n              \\u0022data2\\u0022: 160\\n            }\\n          ]\\n        },\\n        \\u0022series\\u0022: [\\n          {\\n            \\u0022type\\u0022: \\u0022bar\\u0022,\\n            \\u0022barWidth\\u0022: 15,\\n            \\u0022label\\u0022: {\\n              \\u0022show\\u0022: true,\\n              \\u0022position\\u0022: \\u0022top\\u0022,\\n              \\u0022color\\u0022: \\u0022#fff\\u0022,\\n              \\u0022fontSize\\u0022: 12\\n            },\\n            \\u0022itemStyle\\u0022: {\\n              \\u0022color\\u0022: null,\\n              \\u0022borderRadius\\u0022: 2\\n            }\\n          },\\n          {\\n            \\u0022type\\u0022: \\u0022bar\\u0022,\\n            \\u0022barWidth\\u0022: 15,\\n            \\u0022label\\u0022: {\\n              \\u0022show\\u0022: true,\\n              \\u0022position\\u0022: \\u0022top\\u0022,\\n              \\u0022color\\u0022: \\u0022#fff\\u0022,\\n              \\u0022fontSize\\u0022: 12\\n            },\\n            \\u0022itemStyle\\u0022: {\\n              \\u0022color\\u0022: null,\\n              \\u0022borderRadius\\u0022: 2\\n            }\\n          }\\n        ],\\n        \\u0022backgroundColor\\u0022: \\u0022rgba(0,0,0,0)\\u0022\\n      }\\n    }\\n  ],\\n  \\u0022requestGlobalConfig\\u0022: {\\n    \\u0022requestDataPond\\u0022: [],\\n    \\u0022requestOriginUrl\\u0022: \\u0022\\u0022,\\n    \\u0022requestInterval\\u0022: 30,\\n    \\u0022requestIntervalUnit\\u0022: \\u0022second\\u0022,\\n    \\u0022requestParams\\u0022: {\\n      \\u0022Body\\u0022: {\\n        \\u0022form-data\\u0022: {},\\n        \\u0022x-www-form-urlencoded\\u0022: {},\\n        \\u0022json\\u0022: \\u0022\\u0022,\\n        \\u0022xml\\u0022: \\u0022\\u0022\\n      },\\n      \\u0022Header\\u0022: {},\\n      \\u0022Params\\u0022: {}\\n    }\\n  }\\n}\"', NULL);
INSERT INTO `bigview_project` VALUES (2, '测试项目 副本', '0', '2025-12-25 18:27:57.613943', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (3, '测试项目 副本', '0', '2025-12-25 18:28:02.393102', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (4, 'id_25pyol0n8y6800', '0', '2025-12-25 18:28:06.335791', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (5, '测试项目 副本', '0', '2025-12-25 18:41:29.352097', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (6, '测试项目 副本', '0', '2025-12-25 18:44:04.107422', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (7, '测试项目 副本', '0', '2025-12-25 18:44:15.217955', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (8, '测试项目 副本', '0', '2025-12-25 18:45:00.534124', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (9, '测试项目 副本', '0', '2025-12-25 18:46:40.273607', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (10, '测试项目 副本', '0', '2025-12-25 18:47:48.427636', '0', '1', NULL, '\"{\\n  \\u0022editCanvasConfig\\u0022: {\\n    \\u0022projectName\\u0022: \\u0022\\u6D4B\\u8BD5\\u9879\\u76EE\\u0022,\\n    \\u0022width\\u0022: 1920,\\n    \\u0022height\\u0022: 1080,\\n    \\u0022filterShow\\u0022: false,\\n    \\u0022hueRotate\\u0022: 0,\\n    \\u0022saturate\\u0022: 1,\\n    \\u0022contrast\\u0022: 1,\\n    \\u0022brightness\\u0022: 1,\\n    \\u0022opacity\\u0022: 1,\\n    \\u0022rotateZ\\u0022: 0,\\n    \\u0022rotateX\\u0022: 0,\\n    \\u0022rotateY\\u0022: 0,\\n    \\u0022skewX\\u0022: 0,\\n    \\u0022skewY\\u0022: 0,\\n    \\u0022blendMode\\u0022: \\u0022normal\\u0022,\\n    \\u0022background\\u0022: null,\\n    \\u0022backgroundImage\\u0022: null,\\n    \\u0022selectColor\\u0022: true,\\n    \\u0022chartThemeColor\\u0022: \\u0022dark\\u0022,\\n    \\u0022chartCustomThemeColorInfo\\u0022: null,\\n    \\u0022chartThemeSetting\\u0022: {\\n      \\u0022title\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022textStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#BFBFBF\\u0022,\\n          \\u0022fontSize\\u0022: 18\\n        },\\n        \\u0022subtextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#A2A2A2\\u0022,\\n          \\u0022fontSize\\u0022: 14\\n        }\\n      },\\n      \\u0022xAxis\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022name\\u0022: \\u0022\\u0022,\\n        \\u0022nameGap\\u0022: 15,\\n        \\u0022nameTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 12\\n        },\\n        \\u0022inverse\\u0022: false,\\n        \\u0022axisLabel\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022fontSize\\u0022: 12,\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022rotate\\u0022: 0\\n        },\\n        \\u0022position\\u0022: \\u0022bottom\\u0022,\\n        \\u0022axisLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022width\\u0022: 1\\n          },\\n          \\u0022onZero\\u0022: true\\n        },\\n        \\u0022axisTick\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022length\\u0022: 5\\n        },\\n        \\u0022splitLine\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#484753\\u0022,\\n            \\u0022width\\u0022: 1,\\n            \\u0022type\\u0022: \\u0022solid\\u0022\\n          }\\n        },\\n        \\u0022min\\u0022: null,\\n        \\u0022max\\u0022: null\\n      },\\n      \\u0022yAxis\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022name\\u0022: \\u0022\\u0022,\\n        \\u0022nameGap\\u0022: 15,\\n        \\u0022max\\u0022: null,\\n        \\u0022min\\u0022: null,\\n        \\u0022nameTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 12\\n        },\\n        \\u0022inverse\\u0022: false,\\n        \\u0022axisLabel\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022fontSize\\u0022: 12,\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022rotate\\u0022: 0\\n        },\\n        \\u0022position\\u0022: \\u0022left\\u0022,\\n        \\u0022axisLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022width\\u0022: 1\\n          },\\n          \\u0022onZero\\u0022: true\\n        },\\n        \\u0022axisTick\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022length\\u0022: 5\\n        },\\n        \\u0022splitLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#484753\\u0022,\\n            \\u0022width\\u0022: 1,\\n            \\u0022type\\u0022: \\u0022solid\\u0022\\n          }\\n        }\\n      },\\n      \\u0022legend\\u0022: {\\n        \\u0022show\\u0022: false,\\n        \\u0022type\\u0022: \\u0022scroll\\u0022,\\n        \\u0022x\\u0022: \\u0022center\\u0022,\\n        \\u0022y\\u0022: \\u0022top\\u0022,\\n        \\u0022icon\\u0022: \\u0022circle\\u0022,\\n        \\u0022orient\\u0022: \\u0022horizontal\\u0022,\\n        \\u0022textStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 18\\n        },\\n        \\u0022itemHeight\\u0022: 15,\\n        \\u0022itemWidth\\u0022: 15,\\n        \\u0022pageTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022\\n        }\\n      },\\n      \\u0022grid\\u0022: {\\n        \\u0022show\\u0022: false,\\n        \\u0022left\\u0022: \\u002210%\\u0022,\\n        \\u0022top\\u0022: \\u002260\\u0022,\\n        \\u0022right\\u0022: \\u002210%\\u0022,\\n        \\u0022bottom\\u0022: \\u002260\\u0022\\n      },\\n      \\u0022dataset\\u0022: null,\\n      \\u0022renderer\\u0022: \\u0022svg\\u0022\\n    },\\n    \\u0022previewScaleType\\u0022: \\u0022fit\\u0022,\\n    \\u0022previewTheme\\u0022: \\u0022dark\\u0022\\n  },\\n  \\u0022componentList\\u0022: [\\n    {\\n      \\u0022id\\u0022: \\u0022id_127dubdy2hvk00\\u0022,\\n      \\u0022isGroup\\u0022: false,\\n      \\u0022attr\\u0022: {\\n        \\u0022x\\u0022: 532,\\n        \\u0022y\\u0022: 317,\\n        \\u0022w\\u0022: 500,\\n        \\u0022h\\u0022: 300,\\n        \\u0022offsetX\\u0022: 0,\\n        \\u0022offsetY\\u0022: 0,\\n        \\u0022zIndex\\u0022: -1\\n      },\\n      \\u0022styles\\u0022: {\\n        \\u0022filterShow\\u0022: false,\\n        \\u0022hueRotate\\u0022: 0,\\n        \\u0022saturate\\u0022: 1,\\n        \\u0022contrast\\u0022: 1,\\n        \\u0022brightness\\u0022: 1,\\n        \\u0022opacity\\u0022: 1,\\n        \\u0022rotateZ\\u0022: 0,\\n        \\u0022rotateX\\u0022: 0,\\n        \\u0022rotateY\\u0022: 0,\\n        \\u0022skewX\\u0022: 0,\\n        \\u0022skewY\\u0022: 0,\\n        \\u0022blendMode\\u0022: \\u0022normal\\u0022,\\n        \\u0022animations\\u0022: []\\n      },\\n      \\u0022preview\\u0022: {\\n        \\u0022overFlowHidden\\u0022: false\\n      },\\n      \\u0022status\\u0022: {\\n        \\u0022lock\\u0022: false,\\n        \\u0022hide\\u0022: false\\n      },\\n      \\u0022request\\u0022: {\\n        \\u0022requestDataType\\u0022: 0,\\n        \\u0022requestHttpType\\u0022: \\u0022get\\u0022,\\n        \\u0022requestUrl\\u0022: \\u0022\\u0022,\\n        \\u0022requestInterval\\u0022: null,\\n        \\u0022requestIntervalUnit\\u0022: \\u0022second\\u0022,\\n        \\u0022requestContentType\\u0022: 0,\\n        \\u0022requestParamsBodyType\\u0022: \\u0022none\\u0022,\\n        \\u0022requestSQLContent\\u0022: {\\n          \\u0022sql\\u0022: \\u0022select * from  where\\u0022,\\n          \\u0022id\\u0022: \\u0022\\u0022,\\n          \\u0022key\\u0022: \\u0022\\u0022,\\n          \\u0022aux\\u0022: {},\\n          \\u0022fileds\\u0022: []\\n        },\\n        \\u0022requestParams\\u0022: {\\n          \\u0022Body\\u0022: {\\n            \\u0022form-data\\u0022: {},\\n            \\u0022x-www-form-urlencoded\\u0022: {},\\n            \\u0022json\\u0022: \\u0022\\u0022,\\n            \\u0022xml\\u0022: \\u0022\\u0022\\n          },\\n          \\u0022Header\\u0022: {},\\n          \\u0022Params\\u0022: {}\\n        }\\n      },\\n      \\u0022filter\\u0022: null,\\n      \\u0022events\\u0022: {\\n        \\u0022baseEvent\\u0022: {\\n          \\u0022click\\u0022: null,\\n          \\u0022dblclick\\u0022: null,\\n          \\u0022change\\u0022: null,\\n          \\u0022mouseenter\\u0022: null,\\n          \\u0022mouseleave\\u0022: null\\n        },\\n        \\u0022advancedEvents\\u0022: {\\n          \\u0022vnodeMounted\\u0022: null,\\n          \\u0022vnodeBeforeMount\\u0022: null\\n        },\\n        \\u0022interactEvents\\u0022: []\\n      },\\n      \\u0022key\\u0022: \\u0022BarCommon\\u0022,\\n      \\u0022chartConfig\\u0022: {\\n        \\u0022key\\u0022: \\u0022BarCommon\\u0022,\\n        \\u0022chartKey\\u0022: \\u0022VBarCommon\\u0022,\\n        \\u0022conKey\\u0022: \\u0022VCBarCommon\\u0022,\\n        \\u0022title\\u0022: \\u0022\\u67F1\\u72B6\\u56FE\\u0022,\\n        \\u0022category\\u0022: \\u0022Bars\\u0022,\\n        \\u0022categoryName\\u0022: \\u0022\\u67F1\\u72B6\\u56FE\\u0022,\\n        \\u0022package\\u0022: \\u0022Charts\\u0022,\\n        \\u0022chartFrame\\u0022: \\u0022echarts\\u0022,\\n        \\u0022image\\u0022: \\u0022bar_x.png\\u0022\\n      },\\n      \\u0022option\\u0022: {\\n        \\u0022legend\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022type\\u0022: \\u0022scroll\\u0022,\\n          \\u0022x\\u0022: \\u0022center\\u0022,\\n          \\u0022y\\u0022: \\u0022top\\u0022,\\n          \\u0022icon\\u0022: \\u0022circle\\u0022,\\n          \\u0022orient\\u0022: \\u0022horizontal\\u0022,\\n          \\u0022textStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 18\\n          },\\n          \\u0022itemHeight\\u0022: 15,\\n          \\u0022itemWidth\\u0022: 15,\\n          \\u0022pageTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022\\n          }\\n        },\\n        \\u0022xAxis\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022name\\u0022: \\u0022\\u0022,\\n          \\u0022nameGap\\u0022: 15,\\n          \\u0022nameTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 12\\n          },\\n          \\u0022inverse\\u0022: false,\\n          \\u0022axisLabel\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022fontSize\\u0022: 12,\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022rotate\\u0022: 0\\n          },\\n          \\u0022position\\u0022: \\u0022bottom\\u0022,\\n          \\u0022axisLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n              \\u0022width\\u0022: 1\\n            },\\n            \\u0022onZero\\u0022: true\\n          },\\n          \\u0022axisTick\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022length\\u0022: 5\\n          },\\n          \\u0022splitLine\\u0022: {\\n            \\u0022show\\u0022: false,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#484753\\u0022,\\n              \\u0022width\\u0022: 1,\\n              \\u0022type\\u0022: \\u0022solid\\u0022\\n            }\\n          },\\n          \\u0022min\\u0022: null,\\n          \\u0022max\\u0022: null,\\n          \\u0022type\\u0022: \\u0022category\\u0022\\n        },\\n        \\u0022yAxis\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022name\\u0022: \\u0022\\u0022,\\n          \\u0022nameGap\\u0022: 15,\\n          \\u0022max\\u0022: null,\\n          \\u0022min\\u0022: null,\\n          \\u0022nameTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 12\\n          },\\n          \\u0022inverse\\u0022: false,\\n          \\u0022axisLabel\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022fontSize\\u0022: 12,\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022rotate\\u0022: 0\\n          },\\n          \\u0022position\\u0022: \\u0022left\\u0022,\\n          \\u0022axisLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n              \\u0022width\\u0022: 1\\n            },\\n            \\u0022onZero\\u0022: true\\n          },\\n          \\u0022axisTick\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022length\\u0022: 5\\n          },\\n          \\u0022splitLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#484753\\u0022,\\n              \\u0022width\\u0022: 1,\\n              \\u0022type\\u0022: \\u0022solid\\u0022\\n            }\\n          },\\n          \\u0022type\\u0022: \\u0022value\\u0022\\n        },\\n        \\u0022grid\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022left\\u0022: \\u002210%\\u0022,\\n          \\u0022top\\u0022: \\u002260\\u0022,\\n          \\u0022right\\u0022: \\u002210%\\u0022,\\n          \\u0022bottom\\u0022: \\u002260\\u0022\\n        },\\n        \\u0022tooltip\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022trigger\\u0022: \\u0022axis\\u0022,\\n          \\u0022axisPointer\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022type\\u0022: \\u0022shadow\\u0022\\n          }\\n        },\\n        \\u0022dataZoom\\u0022: [\\n          {\\n            \\u0022show\\u0022: true,\\n            \\u0022type\\u0022: \\u0022inside\\u0022,\\n            \\u0022disabled\\u0022: false,\\n            \\u0022realtime\\u0022: true,\\n            \\u0022start\\u0022: 0,\\n            \\u0022end\\u0022: 100,\\n            \\u0022xAxisIndex\\u0022: [\\n              0,\\n              1\\n            ]\\n          }\\n        ],\\n        \\u0022dataset\\u0022: {\\n          \\u0022dimensions\\u0022: [\\n            \\u0022product\\u0022,\\n            \\u0022data1\\u0022,\\n            \\u0022data2\\u0022\\n          ],\\n          \\u0022source\\u0022: [\\n            {\\n              \\u0022product\\u0022: \\u0022Mon\\u0022,\\n              \\u0022data1\\u0022: 120,\\n              \\u0022data2\\u0022: 130\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Tue\\u0022,\\n              \\u0022data1\\u0022: 200,\\n              \\u0022data2\\u0022: 130\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Wed\\u0022,\\n              \\u0022data1\\u0022: 150,\\n              \\u0022data2\\u0022: 312\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Thu\\u0022,\\n              \\u0022data1\\u0022: 80,\\n              \\u0022data2\\u0022: 268\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Fri\\u0022,\\n              \\u0022data1\\u0022: 70,\\n              \\u0022data2\\u0022: 155\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Sat\\u0022,\\n              \\u0022data1\\u0022: 110,\\n              \\u0022data2\\u0022: 117\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Sun\\u0022,\\n              \\u0022data1\\u0022: 130,\\n              \\u0022data2\\u0022: 160\\n            }\\n          ]\\n        },\\n        \\u0022series\\u0022: [\\n          {\\n            \\u0022type\\u0022: \\u0022bar\\u0022,\\n            \\u0022barWidth\\u0022: 15,\\n            \\u0022label\\u0022: {\\n              \\u0022show\\u0022: true,\\n              \\u0022position\\u0022: \\u0022top\\u0022,\\n              \\u0022color\\u0022: \\u0022#fff\\u0022,\\n              \\u0022fontSize\\u0022: 12\\n            },\\n            \\u0022itemStyle\\u0022: {\\n              \\u0022color\\u0022: null,\\n              \\u0022borderRadius\\u0022: 2\\n            }\\n          },\\n          {\\n            \\u0022type\\u0022: \\u0022bar\\u0022,\\n            \\u0022barWidth\\u0022: 15,\\n            \\u0022label\\u0022: {\\n              \\u0022show\\u0022: true,\\n              \\u0022position\\u0022: \\u0022top\\u0022,\\n              \\u0022color\\u0022: \\u0022#fff\\u0022,\\n              \\u0022fontSize\\u0022: 12\\n            },\\n            \\u0022itemStyle\\u0022: {\\n              \\u0022color\\u0022: null,\\n              \\u0022borderRadius\\u0022: 2\\n            }\\n          }\\n        ],\\n        \\u0022backgroundColor\\u0022: \\u0022rgba(0,0,0,0)\\u0022\\n      }\\n    }\\n  ],\\n  \\u0022requestGlobalConfig\\u0022: {\\n    \\u0022requestDataPond\\u0022: [],\\n    \\u0022requestOriginUrl\\u0022: \\u0022\\u0022,\\n    \\u0022requestInterval\\u0022: 30,\\n    \\u0022requestIntervalUnit\\u0022: \\u0022second\\u0022,\\n    \\u0022requestParams\\u0022: {\\n      \\u0022Body\\u0022: {\\n        \\u0022form-data\\u0022: {},\\n        \\u0022x-www-form-urlencoded\\u0022: {},\\n        \\u0022json\\u0022: \\u0022\\u0022,\\n        \\u0022xml\\u0022: \\u0022\\u0022\\n      },\\n      \\u0022Header\\u0022: {},\\n      \\u0022Params\\u0022: {}\\n    }\\n  }\\n}\"', NULL);
INSERT INTO `bigview_project` VALUES (11, '测试项目 副本', '0', '2025-12-25 18:49:50.271859', '0', '1', '/uploads/bigview/1.png', '\"{\\n  \\u0022editCanvasConfig\\u0022: {\\n    \\u0022projectName\\u0022: \\u0022\\u6D4B\\u8BD5\\u9879\\u76EE\\u0022,\\n    \\u0022width\\u0022: 1920,\\n    \\u0022height\\u0022: 1080,\\n    \\u0022filterShow\\u0022: false,\\n    \\u0022hueRotate\\u0022: 0,\\n    \\u0022saturate\\u0022: 1,\\n    \\u0022contrast\\u0022: 1,\\n    \\u0022brightness\\u0022: 1,\\n    \\u0022opacity\\u0022: 1,\\n    \\u0022rotateZ\\u0022: 0,\\n    \\u0022rotateX\\u0022: 0,\\n    \\u0022rotateY\\u0022: 0,\\n    \\u0022skewX\\u0022: 0,\\n    \\u0022skewY\\u0022: 0,\\n    \\u0022blendMode\\u0022: \\u0022normal\\u0022,\\n    \\u0022background\\u0022: null,\\n    \\u0022backgroundImage\\u0022: null,\\n    \\u0022selectColor\\u0022: true,\\n    \\u0022chartThemeColor\\u0022: \\u0022dark\\u0022,\\n    \\u0022chartCustomThemeColorInfo\\u0022: null,\\n    \\u0022chartThemeSetting\\u0022: {\\n      \\u0022title\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022textStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#BFBFBF\\u0022,\\n          \\u0022fontSize\\u0022: 18\\n        },\\n        \\u0022subtextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#A2A2A2\\u0022,\\n          \\u0022fontSize\\u0022: 14\\n        }\\n      },\\n      \\u0022xAxis\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022name\\u0022: \\u0022\\u0022,\\n        \\u0022nameGap\\u0022: 15,\\n        \\u0022nameTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 12\\n        },\\n        \\u0022inverse\\u0022: false,\\n        \\u0022axisLabel\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022fontSize\\u0022: 12,\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022rotate\\u0022: 0\\n        },\\n        \\u0022position\\u0022: \\u0022bottom\\u0022,\\n        \\u0022axisLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022width\\u0022: 1\\n          },\\n          \\u0022onZero\\u0022: true\\n        },\\n        \\u0022axisTick\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022length\\u0022: 5\\n        },\\n        \\u0022splitLine\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#484753\\u0022,\\n            \\u0022width\\u0022: 1,\\n            \\u0022type\\u0022: \\u0022solid\\u0022\\n          }\\n        },\\n        \\u0022min\\u0022: null,\\n        \\u0022max\\u0022: null\\n      },\\n      \\u0022yAxis\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022name\\u0022: \\u0022\\u0022,\\n        \\u0022nameGap\\u0022: 15,\\n        \\u0022max\\u0022: null,\\n        \\u0022min\\u0022: null,\\n        \\u0022nameTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 12\\n        },\\n        \\u0022inverse\\u0022: false,\\n        \\u0022axisLabel\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022fontSize\\u0022: 12,\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022rotate\\u0022: 0\\n        },\\n        \\u0022position\\u0022: \\u0022left\\u0022,\\n        \\u0022axisLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022width\\u0022: 1\\n          },\\n          \\u0022onZero\\u0022: true\\n        },\\n        \\u0022axisTick\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022length\\u0022: 5\\n        },\\n        \\u0022splitLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#484753\\u0022,\\n            \\u0022width\\u0022: 1,\\n            \\u0022type\\u0022: \\u0022solid\\u0022\\n          }\\n        }\\n      },\\n      \\u0022legend\\u0022: {\\n        \\u0022show\\u0022: false,\\n        \\u0022type\\u0022: \\u0022scroll\\u0022,\\n        \\u0022x\\u0022: \\u0022center\\u0022,\\n        \\u0022y\\u0022: \\u0022top\\u0022,\\n        \\u0022icon\\u0022: \\u0022circle\\u0022,\\n        \\u0022orient\\u0022: \\u0022horizontal\\u0022,\\n        \\u0022textStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 18\\n        },\\n        \\u0022itemHeight\\u0022: 15,\\n        \\u0022itemWidth\\u0022: 15,\\n        \\u0022pageTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022\\n        }\\n      },\\n      \\u0022grid\\u0022: {\\n        \\u0022show\\u0022: false,\\n        \\u0022left\\u0022: \\u002210%\\u0022,\\n        \\u0022top\\u0022: \\u002260\\u0022,\\n        \\u0022right\\u0022: \\u002210%\\u0022,\\n        \\u0022bottom\\u0022: \\u002260\\u0022\\n      },\\n      \\u0022dataset\\u0022: null,\\n      \\u0022renderer\\u0022: \\u0022svg\\u0022\\n    },\\n    \\u0022previewScaleType\\u0022: \\u0022fit\\u0022,\\n    \\u0022previewTheme\\u0022: \\u0022dark\\u0022\\n  },\\n  \\u0022componentList\\u0022: [\\n    {\\n      \\u0022id\\u0022: \\u0022id_127dubdy2hvk00\\u0022,\\n      \\u0022isGroup\\u0022: false,\\n      \\u0022attr\\u0022: {\\n        \\u0022x\\u0022: 532,\\n        \\u0022y\\u0022: 317,\\n        \\u0022w\\u0022: 500,\\n        \\u0022h\\u0022: 300,\\n        \\u0022offsetX\\u0022: 0,\\n        \\u0022offsetY\\u0022: 0,\\n        \\u0022zIndex\\u0022: -1\\n      },\\n      \\u0022styles\\u0022: {\\n        \\u0022filterShow\\u0022: false,\\n        \\u0022hueRotate\\u0022: 0,\\n        \\u0022saturate\\u0022: 1,\\n        \\u0022contrast\\u0022: 1,\\n        \\u0022brightness\\u0022: 1,\\n        \\u0022opacity\\u0022: 1,\\n        \\u0022rotateZ\\u0022: 0,\\n        \\u0022rotateX\\u0022: 0,\\n        \\u0022rotateY\\u0022: 0,\\n        \\u0022skewX\\u0022: 0,\\n        \\u0022skewY\\u0022: 0,\\n        \\u0022blendMode\\u0022: \\u0022normal\\u0022,\\n        \\u0022animations\\u0022: []\\n      },\\n      \\u0022preview\\u0022: {\\n        \\u0022overFlowHidden\\u0022: false\\n      },\\n      \\u0022status\\u0022: {\\n        \\u0022lock\\u0022: false,\\n        \\u0022hide\\u0022: false\\n      },\\n      \\u0022request\\u0022: {\\n        \\u0022requestDataType\\u0022: 0,\\n        \\u0022requestHttpType\\u0022: \\u0022get\\u0022,\\n        \\u0022requestUrl\\u0022: \\u0022\\u0022,\\n        \\u0022requestInterval\\u0022: null,\\n        \\u0022requestIntervalUnit\\u0022: \\u0022second\\u0022,\\n        \\u0022requestContentType\\u0022: 0,\\n        \\u0022requestParamsBodyType\\u0022: \\u0022none\\u0022,\\n        \\u0022requestSQLContent\\u0022: {\\n          \\u0022sql\\u0022: \\u0022select * from  where\\u0022,\\n          \\u0022id\\u0022: \\u0022\\u0022,\\n          \\u0022key\\u0022: \\u0022\\u0022,\\n          \\u0022aux\\u0022: {},\\n          \\u0022fileds\\u0022: []\\n        },\\n        \\u0022requestParams\\u0022: {\\n          \\u0022Body\\u0022: {\\n            \\u0022form-data\\u0022: {},\\n            \\u0022x-www-form-urlencoded\\u0022: {},\\n            \\u0022json\\u0022: \\u0022\\u0022,\\n            \\u0022xml\\u0022: \\u0022\\u0022\\n          },\\n          \\u0022Header\\u0022: {},\\n          \\u0022Params\\u0022: {}\\n        }\\n      },\\n      \\u0022filter\\u0022: null,\\n      \\u0022events\\u0022: {\\n        \\u0022baseEvent\\u0022: {\\n          \\u0022click\\u0022: null,\\n          \\u0022dblclick\\u0022: null,\\n          \\u0022change\\u0022: null,\\n          \\u0022mouseenter\\u0022: null,\\n          \\u0022mouseleave\\u0022: null\\n        },\\n        \\u0022advancedEvents\\u0022: {\\n          \\u0022vnodeMounted\\u0022: null,\\n          \\u0022vnodeBeforeMount\\u0022: null\\n        },\\n        \\u0022interactEvents\\u0022: []\\n      },\\n      \\u0022key\\u0022: \\u0022BarCommon\\u0022,\\n      \\u0022chartConfig\\u0022: {\\n        \\u0022key\\u0022: \\u0022BarCommon\\u0022,\\n        \\u0022chartKey\\u0022: \\u0022VBarCommon\\u0022,\\n        \\u0022conKey\\u0022: \\u0022VCBarCommon\\u0022,\\n        \\u0022title\\u0022: \\u0022\\u67F1\\u72B6\\u56FE\\u0022,\\n        \\u0022category\\u0022: \\u0022Bars\\u0022,\\n        \\u0022categoryName\\u0022: \\u0022\\u67F1\\u72B6\\u56FE\\u0022,\\n        \\u0022package\\u0022: \\u0022Charts\\u0022,\\n        \\u0022chartFrame\\u0022: \\u0022echarts\\u0022,\\n        \\u0022image\\u0022: \\u0022bar_x.png\\u0022\\n      },\\n      \\u0022option\\u0022: {\\n        \\u0022legend\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022type\\u0022: \\u0022scroll\\u0022,\\n          \\u0022x\\u0022: \\u0022center\\u0022,\\n          \\u0022y\\u0022: \\u0022top\\u0022,\\n          \\u0022icon\\u0022: \\u0022circle\\u0022,\\n          \\u0022orient\\u0022: \\u0022horizontal\\u0022,\\n          \\u0022textStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 18\\n          },\\n          \\u0022itemHeight\\u0022: 15,\\n          \\u0022itemWidth\\u0022: 15,\\n          \\u0022pageTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022\\n          }\\n        },\\n        \\u0022xAxis\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022name\\u0022: \\u0022\\u0022,\\n          \\u0022nameGap\\u0022: 15,\\n          \\u0022nameTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 12\\n          },\\n          \\u0022inverse\\u0022: false,\\n          \\u0022axisLabel\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022fontSize\\u0022: 12,\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022rotate\\u0022: 0\\n          },\\n          \\u0022position\\u0022: \\u0022bottom\\u0022,\\n          \\u0022axisLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n              \\u0022width\\u0022: 1\\n            },\\n            \\u0022onZero\\u0022: true\\n          },\\n          \\u0022axisTick\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022length\\u0022: 5\\n          },\\n          \\u0022splitLine\\u0022: {\\n            \\u0022show\\u0022: false,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#484753\\u0022,\\n              \\u0022width\\u0022: 1,\\n              \\u0022type\\u0022: \\u0022solid\\u0022\\n            }\\n          },\\n          \\u0022min\\u0022: null,\\n          \\u0022max\\u0022: null,\\n          \\u0022type\\u0022: \\u0022category\\u0022\\n        },\\n        \\u0022yAxis\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022name\\u0022: \\u0022\\u0022,\\n          \\u0022nameGap\\u0022: 15,\\n          \\u0022max\\u0022: null,\\n          \\u0022min\\u0022: null,\\n          \\u0022nameTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 12\\n          },\\n          \\u0022inverse\\u0022: false,\\n          \\u0022axisLabel\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022fontSize\\u0022: 12,\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022rotate\\u0022: 0\\n          },\\n          \\u0022position\\u0022: \\u0022left\\u0022,\\n          \\u0022axisLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n              \\u0022width\\u0022: 1\\n            },\\n            \\u0022onZero\\u0022: true\\n          },\\n          \\u0022axisTick\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022length\\u0022: 5\\n          },\\n          \\u0022splitLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#484753\\u0022,\\n              \\u0022width\\u0022: 1,\\n              \\u0022type\\u0022: \\u0022solid\\u0022\\n            }\\n          },\\n          \\u0022type\\u0022: \\u0022value\\u0022\\n        },\\n        \\u0022grid\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022left\\u0022: \\u002210%\\u0022,\\n          \\u0022top\\u0022: \\u002260\\u0022,\\n          \\u0022right\\u0022: \\u002210%\\u0022,\\n          \\u0022bottom\\u0022: \\u002260\\u0022\\n        },\\n        \\u0022tooltip\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022trigger\\u0022: \\u0022axis\\u0022,\\n          \\u0022axisPointer\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022type\\u0022: \\u0022shadow\\u0022\\n          }\\n        },\\n        \\u0022dataZoom\\u0022: [\\n          {\\n            \\u0022show\\u0022: true,\\n            \\u0022type\\u0022: \\u0022inside\\u0022,\\n            \\u0022disabled\\u0022: false,\\n            \\u0022realtime\\u0022: true,\\n            \\u0022start\\u0022: 0,\\n            \\u0022end\\u0022: 100,\\n            \\u0022xAxisIndex\\u0022: [\\n              0,\\n              1\\n            ]\\n          }\\n        ],\\n        \\u0022dataset\\u0022: {\\n          \\u0022dimensions\\u0022: [\\n            \\u0022product\\u0022,\\n            \\u0022data1\\u0022,\\n            \\u0022data2\\u0022\\n          ],\\n          \\u0022source\\u0022: [\\n            {\\n              \\u0022product\\u0022: \\u0022Mon\\u0022,\\n              \\u0022data1\\u0022: 120,\\n              \\u0022data2\\u0022: 130\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Tue\\u0022,\\n              \\u0022data1\\u0022: 200,\\n              \\u0022data2\\u0022: 130\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Wed\\u0022,\\n              \\u0022data1\\u0022: 150,\\n              \\u0022data2\\u0022: 312\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Thu\\u0022,\\n              \\u0022data1\\u0022: 80,\\n              \\u0022data2\\u0022: 268\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Fri\\u0022,\\n              \\u0022data1\\u0022: 70,\\n              \\u0022data2\\u0022: 155\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Sat\\u0022,\\n              \\u0022data1\\u0022: 110,\\n              \\u0022data2\\u0022: 117\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Sun\\u0022,\\n              \\u0022data1\\u0022: 130,\\n              \\u0022data2\\u0022: 160\\n            }\\n          ]\\n        },\\n        \\u0022series\\u0022: [\\n          {\\n            \\u0022type\\u0022: \\u0022bar\\u0022,\\n            \\u0022barWidth\\u0022: 15,\\n            \\u0022label\\u0022: {\\n              \\u0022show\\u0022: true,\\n              \\u0022position\\u0022: \\u0022top\\u0022,\\n              \\u0022color\\u0022: \\u0022#fff\\u0022,\\n              \\u0022fontSize\\u0022: 12\\n            },\\n            \\u0022itemStyle\\u0022: {\\n              \\u0022color\\u0022: null,\\n              \\u0022borderRadius\\u0022: 2\\n            }\\n          },\\n          {\\n            \\u0022type\\u0022: \\u0022bar\\u0022,\\n            \\u0022barWidth\\u0022: 15,\\n            \\u0022label\\u0022: {\\n              \\u0022show\\u0022: true,\\n              \\u0022position\\u0022: \\u0022top\\u0022,\\n              \\u0022color\\u0022: \\u0022#fff\\u0022,\\n              \\u0022fontSize\\u0022: 12\\n            },\\n            \\u0022itemStyle\\u0022: {\\n              \\u0022color\\u0022: null,\\n              \\u0022borderRadius\\u0022: 2\\n            }\\n          }\\n        ],\\n        \\u0022backgroundColor\\u0022: \\u0022rgba(0,0,0,0)\\u0022\\n      }\\n    }\\n  ],\\n  \\u0022requestGlobalConfig\\u0022: {\\n    \\u0022requestDataPond\\u0022: [],\\n    \\u0022requestOriginUrl\\u0022: \\u0022\\u0022,\\n    \\u0022requestInterval\\u0022: 30,\\n    \\u0022requestIntervalUnit\\u0022: \\u0022second\\u0022,\\n    \\u0022requestParams\\u0022: {\\n      \\u0022Body\\u0022: {\\n        \\u0022form-data\\u0022: {},\\n        \\u0022x-www-form-urlencoded\\u0022: {},\\n        \\u0022json\\u0022: \\u0022\\u0022,\\n        \\u0022xml\\u0022: \\u0022\\u0022\\n      },\\n      \\u0022Header\\u0022: {},\\n      \\u0022Params\\u0022: {}\\n    }\\n  }\\n}\"', NULL);
INSERT INTO `bigview_project` VALUES (12, '测试项目 副本', '0', '2025-12-25 18:53:48.181901', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (13, '测试项目 副本', '0', '2025-12-25 18:54:04.210012', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (14, '测试项目 副本', '0', '2025-12-25 18:54:34.270367', '0', '1', NULL, NULL, NULL);
INSERT INTO `bigview_project` VALUES (15, '测试项目 副本', '0', '2025-12-25 18:58:48.662649', '0', '0', '/uploads/bigview/15.png', '\"{\\n  \\u0022editCanvasConfig\\u0022: {\\n    \\u0022projectName\\u0022: \\u0022\\u6D4B\\u8BD5\\u9879\\u76EE\\u526F\\u672C\\u0022,\\n    \\u0022width\\u0022: 1920,\\n    \\u0022height\\u0022: 1080,\\n    \\u0022filterShow\\u0022: false,\\n    \\u0022hueRotate\\u0022: 0,\\n    \\u0022saturate\\u0022: 1,\\n    \\u0022contrast\\u0022: 1,\\n    \\u0022brightness\\u0022: 1,\\n    \\u0022opacity\\u0022: 1,\\n    \\u0022rotateZ\\u0022: 0,\\n    \\u0022rotateX\\u0022: 0,\\n    \\u0022rotateY\\u0022: 0,\\n    \\u0022skewX\\u0022: 0,\\n    \\u0022skewY\\u0022: 0,\\n    \\u0022blendMode\\u0022: \\u0022normal\\u0022,\\n    \\u0022background\\u0022: null,\\n    \\u0022backgroundImage\\u0022: null,\\n    \\u0022selectColor\\u0022: true,\\n    \\u0022chartThemeColor\\u0022: \\u0022dark\\u0022,\\n    \\u0022chartCustomThemeColorInfo\\u0022: null,\\n    \\u0022chartThemeSetting\\u0022: {\\n      \\u0022title\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022textStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#BFBFBF\\u0022,\\n          \\u0022fontSize\\u0022: 18\\n        },\\n        \\u0022subtextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#A2A2A2\\u0022,\\n          \\u0022fontSize\\u0022: 14\\n        }\\n      },\\n      \\u0022xAxis\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022name\\u0022: \\u0022\\u0022,\\n        \\u0022nameGap\\u0022: 15,\\n        \\u0022nameTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 12\\n        },\\n        \\u0022inverse\\u0022: false,\\n        \\u0022axisLabel\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022fontSize\\u0022: 12,\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022rotate\\u0022: 0\\n        },\\n        \\u0022position\\u0022: \\u0022bottom\\u0022,\\n        \\u0022axisLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022width\\u0022: 1\\n          },\\n          \\u0022onZero\\u0022: true\\n        },\\n        \\u0022axisTick\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022length\\u0022: 5\\n        },\\n        \\u0022splitLine\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#484753\\u0022,\\n            \\u0022width\\u0022: 1,\\n            \\u0022type\\u0022: \\u0022solid\\u0022\\n          }\\n        },\\n        \\u0022min\\u0022: null,\\n        \\u0022max\\u0022: null\\n      },\\n      \\u0022yAxis\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022name\\u0022: \\u0022\\u0022,\\n        \\u0022nameGap\\u0022: 15,\\n        \\u0022max\\u0022: null,\\n        \\u0022min\\u0022: null,\\n        \\u0022nameTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 12\\n        },\\n        \\u0022inverse\\u0022: false,\\n        \\u0022axisLabel\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022fontSize\\u0022: 12,\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022rotate\\u0022: 0\\n        },\\n        \\u0022position\\u0022: \\u0022left\\u0022,\\n        \\u0022axisLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022width\\u0022: 1\\n          },\\n          \\u0022onZero\\u0022: true\\n        },\\n        \\u0022axisTick\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022length\\u0022: 5\\n        },\\n        \\u0022splitLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#484753\\u0022,\\n            \\u0022width\\u0022: 1,\\n            \\u0022type\\u0022: \\u0022solid\\u0022\\n          }\\n        }\\n      },\\n      \\u0022legend\\u0022: {\\n        \\u0022show\\u0022: false,\\n        \\u0022type\\u0022: \\u0022scroll\\u0022,\\n        \\u0022x\\u0022: \\u0022center\\u0022,\\n        \\u0022y\\u0022: \\u0022top\\u0022,\\n        \\u0022icon\\u0022: \\u0022circle\\u0022,\\n        \\u0022orient\\u0022: \\u0022horizontal\\u0022,\\n        \\u0022textStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 18\\n        },\\n        \\u0022itemHeight\\u0022: 15,\\n        \\u0022itemWidth\\u0022: 15,\\n        \\u0022pageTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022\\n        }\\n      },\\n      \\u0022grid\\u0022: {\\n        \\u0022show\\u0022: false,\\n        \\u0022left\\u0022: \\u002210%\\u0022,\\n        \\u0022top\\u0022: \\u002260\\u0022,\\n        \\u0022right\\u0022: \\u002210%\\u0022,\\n        \\u0022bottom\\u0022: \\u002260\\u0022\\n      },\\n      \\u0022dataset\\u0022: null,\\n      \\u0022renderer\\u0022: \\u0022svg\\u0022\\n    },\\n    \\u0022previewScaleType\\u0022: \\u0022fit\\u0022,\\n    \\u0022previewTheme\\u0022: \\u0022dark\\u0022\\n  },\\n  \\u0022componentList\\u0022: [\\n    {\\n      \\u0022id\\u0022: \\u0022id_127dubdy2hvk00\\u0022,\\n      \\u0022isGroup\\u0022: false,\\n      \\u0022attr\\u0022: {\\n        \\u0022x\\u0022: 498,\\n        \\u0022y\\u0022: 229,\\n        \\u0022w\\u0022: 1193,\\n        \\u0022h\\u0022: 622,\\n        \\u0022offsetX\\u0022: 0,\\n        \\u0022offsetY\\u0022: 0,\\n        \\u0022zIndex\\u0022: -1\\n      },\\n      \\u0022styles\\u0022: {\\n        \\u0022filterShow\\u0022: false,\\n        \\u0022hueRotate\\u0022: 0,\\n        \\u0022saturate\\u0022: 1,\\n        \\u0022contrast\\u0022: 1,\\n        \\u0022brightness\\u0022: 1,\\n        \\u0022opacity\\u0022: 1,\\n        \\u0022rotateZ\\u0022: 0,\\n        \\u0022rotateX\\u0022: 0,\\n        \\u0022rotateY\\u0022: 0,\\n        \\u0022skewX\\u0022: 0,\\n        \\u0022skewY\\u0022: 0,\\n        \\u0022blendMode\\u0022: \\u0022normal\\u0022,\\n        \\u0022animations\\u0022: []\\n      },\\n      \\u0022preview\\u0022: {\\n        \\u0022overFlowHidden\\u0022: false\\n      },\\n      \\u0022status\\u0022: {\\n        \\u0022lock\\u0022: false,\\n        \\u0022hide\\u0022: false\\n      },\\n      \\u0022request\\u0022: {\\n        \\u0022requestDataType\\u0022: 0,\\n        \\u0022requestHttpType\\u0022: \\u0022get\\u0022,\\n        \\u0022requestUrl\\u0022: \\u0022\\u0022,\\n        \\u0022requestInterval\\u0022: null,\\n        \\u0022requestIntervalUnit\\u0022: \\u0022second\\u0022,\\n        \\u0022requestContentType\\u0022: 0,\\n        \\u0022requestParamsBodyType\\u0022: \\u0022none\\u0022,\\n        \\u0022requestSQLContent\\u0022: {\\n          \\u0022sql\\u0022: \\u0022select * from  where\\u0022,\\n          \\u0022id\\u0022: \\u0022\\u0022,\\n          \\u0022key\\u0022: \\u0022\\u0022,\\n          \\u0022aux\\u0022: {},\\n          \\u0022fileds\\u0022: []\\n        },\\n        \\u0022requestParams\\u0022: {\\n          \\u0022Body\\u0022: {\\n            \\u0022form-data\\u0022: {},\\n            \\u0022x-www-form-urlencoded\\u0022: {},\\n            \\u0022json\\u0022: \\u0022\\u0022,\\n            \\u0022xml\\u0022: \\u0022\\u0022\\n          },\\n          \\u0022Header\\u0022: {},\\n          \\u0022Params\\u0022: {}\\n        }\\n      },\\n      \\u0022filter\\u0022: null,\\n      \\u0022events\\u0022: {\\n        \\u0022baseEvent\\u0022: {\\n          \\u0022click\\u0022: null,\\n          \\u0022dblclick\\u0022: null,\\n          \\u0022change\\u0022: null,\\n          \\u0022mouseenter\\u0022: null,\\n          \\u0022mouseleave\\u0022: null\\n        },\\n        \\u0022advancedEvents\\u0022: {\\n          \\u0022vnodeMounted\\u0022: null,\\n          \\u0022vnodeBeforeMount\\u0022: null\\n        },\\n        \\u0022interactEvents\\u0022: []\\n      },\\n      \\u0022key\\u0022: \\u0022BarCommon\\u0022,\\n      \\u0022chartConfig\\u0022: {\\n        \\u0022key\\u0022: \\u0022BarCommon\\u0022,\\n        \\u0022chartKey\\u0022: \\u0022VBarCommon\\u0022,\\n        \\u0022conKey\\u0022: \\u0022VCBarCommon\\u0022,\\n        \\u0022title\\u0022: \\u0022\\u67F1\\u72B6\\u56FE\\u0022,\\n        \\u0022category\\u0022: \\u0022Bars\\u0022,\\n        \\u0022categoryName\\u0022: \\u0022\\u67F1\\u72B6\\u56FE\\u0022,\\n        \\u0022package\\u0022: \\u0022Charts\\u0022,\\n        \\u0022chartFrame\\u0022: \\u0022echarts\\u0022,\\n        \\u0022image\\u0022: \\u0022bar_x.png\\u0022\\n      },\\n      \\u0022option\\u0022: {\\n        \\u0022legend\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022type\\u0022: \\u0022scroll\\u0022,\\n          \\u0022x\\u0022: \\u0022center\\u0022,\\n          \\u0022y\\u0022: \\u0022top\\u0022,\\n          \\u0022icon\\u0022: \\u0022circle\\u0022,\\n          \\u0022orient\\u0022: \\u0022horizontal\\u0022,\\n          \\u0022textStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 18\\n          },\\n          \\u0022itemHeight\\u0022: 15,\\n          \\u0022itemWidth\\u0022: 15,\\n          \\u0022pageTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022\\n          }\\n        },\\n        \\u0022xAxis\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022name\\u0022: \\u0022\\u0022,\\n          \\u0022nameGap\\u0022: 15,\\n          \\u0022nameTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 12\\n          },\\n          \\u0022inverse\\u0022: false,\\n          \\u0022axisLabel\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022fontSize\\u0022: 12,\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022rotate\\u0022: 0\\n          },\\n          \\u0022position\\u0022: \\u0022bottom\\u0022,\\n          \\u0022axisLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n              \\u0022width\\u0022: 1\\n            },\\n            \\u0022onZero\\u0022: true\\n          },\\n          \\u0022axisTick\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022length\\u0022: 5\\n          },\\n          \\u0022splitLine\\u0022: {\\n            \\u0022show\\u0022: false,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#484753\\u0022,\\n              \\u0022width\\u0022: 1,\\n              \\u0022type\\u0022: \\u0022solid\\u0022\\n            }\\n          },\\n          \\u0022min\\u0022: null,\\n          \\u0022max\\u0022: null,\\n          \\u0022type\\u0022: \\u0022category\\u0022\\n        },\\n        \\u0022yAxis\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022name\\u0022: \\u0022\\u0022,\\n          \\u0022nameGap\\u0022: 15,\\n          \\u0022max\\u0022: null,\\n          \\u0022min\\u0022: null,\\n          \\u0022nameTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 12\\n          },\\n          \\u0022inverse\\u0022: false,\\n          \\u0022axisLabel\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022fontSize\\u0022: 12,\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022rotate\\u0022: 0\\n          },\\n          \\u0022position\\u0022: \\u0022left\\u0022,\\n          \\u0022axisLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n              \\u0022width\\u0022: 1\\n            },\\n            \\u0022onZero\\u0022: true\\n          },\\n          \\u0022axisTick\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022length\\u0022: 5\\n          },\\n          \\u0022splitLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#484753\\u0022,\\n              \\u0022width\\u0022: 1,\\n              \\u0022type\\u0022: \\u0022solid\\u0022\\n            }\\n          },\\n          \\u0022type\\u0022: \\u0022value\\u0022\\n        },\\n        \\u0022grid\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022left\\u0022: \\u002210%\\u0022,\\n          \\u0022top\\u0022: \\u002260\\u0022,\\n          \\u0022right\\u0022: \\u002210%\\u0022,\\n          \\u0022bottom\\u0022: \\u002260\\u0022\\n        },\\n        \\u0022tooltip\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022trigger\\u0022: \\u0022axis\\u0022,\\n          \\u0022axisPointer\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022type\\u0022: \\u0022shadow\\u0022\\n          }\\n        },\\n        \\u0022dataZoom\\u0022: [\\n          {\\n            \\u0022show\\u0022: true,\\n            \\u0022type\\u0022: \\u0022inside\\u0022,\\n            \\u0022disabled\\u0022: false,\\n            \\u0022realtime\\u0022: true,\\n            \\u0022start\\u0022: 0,\\n            \\u0022end\\u0022: 100,\\n            \\u0022xAxisIndex\\u0022: [\\n              0,\\n              1\\n            ]\\n          }\\n        ],\\n        \\u0022dataset\\u0022: {\\n          \\u0022dimensions\\u0022: [\\n            \\u0022product\\u0022,\\n            \\u0022data1\\u0022,\\n            \\u0022data2\\u0022\\n          ],\\n          \\u0022source\\u0022: [\\n            {\\n              \\u0022product\\u0022: \\u0022Mon\\u0022,\\n              \\u0022data1\\u0022: 120,\\n              \\u0022data2\\u0022: 130\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Tue\\u0022,\\n              \\u0022data1\\u0022: 200,\\n              \\u0022data2\\u0022: 130\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Wed\\u0022,\\n              \\u0022data1\\u0022: 150,\\n              \\u0022data2\\u0022: 312\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Thu\\u0022,\\n              \\u0022data1\\u0022: 80,\\n              \\u0022data2\\u0022: 268\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Fri\\u0022,\\n              \\u0022data1\\u0022: 70,\\n              \\u0022data2\\u0022: 155\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Sat\\u0022,\\n              \\u0022data1\\u0022: 110,\\n              \\u0022data2\\u0022: 117\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Sun\\u0022,\\n              \\u0022data1\\u0022: 130,\\n              \\u0022data2\\u0022: 160\\n            }\\n          ]\\n        },\\n        \\u0022series\\u0022: [\\n          {\\n            \\u0022type\\u0022: \\u0022bar\\u0022,\\n            \\u0022barWidth\\u0022: 15,\\n            \\u0022label\\u0022: {\\n              \\u0022show\\u0022: true,\\n              \\u0022position\\u0022: \\u0022top\\u0022,\\n              \\u0022color\\u0022: \\u0022#fff\\u0022,\\n              \\u0022fontSize\\u0022: 12\\n            },\\n            \\u0022itemStyle\\u0022: {\\n              \\u0022color\\u0022: null,\\n              \\u0022borderRadius\\u0022: 2\\n            }\\n          },\\n          {\\n            \\u0022type\\u0022: \\u0022bar\\u0022,\\n            \\u0022barWidth\\u0022: 15,\\n            \\u0022label\\u0022: {\\n              \\u0022show\\u0022: true,\\n              \\u0022position\\u0022: \\u0022top\\u0022,\\n              \\u0022color\\u0022: \\u0022#fff\\u0022,\\n              \\u0022fontSize\\u0022: 12\\n            },\\n            \\u0022itemStyle\\u0022: {\\n              \\u0022color\\u0022: null,\\n              \\u0022borderRadius\\u0022: 2\\n            }\\n          }\\n        ],\\n        \\u0022backgroundColor\\u0022: \\u0022rgba(0,0,0,0)\\u0022\\n      }\\n    }\\n  ],\\n  \\u0022requestGlobalConfig\\u0022: {\\n    \\u0022requestDataPond\\u0022: [],\\n    \\u0022requestOriginUrl\\u0022: \\u0022\\u0022,\\n    \\u0022requestInterval\\u0022: 30,\\n    \\u0022requestIntervalUnit\\u0022: \\u0022second\\u0022,\\n    \\u0022requestParams\\u0022: {\\n      \\u0022Body\\u0022: {\\n        \\u0022form-data\\u0022: {},\\n        \\u0022x-www-form-urlencoded\\u0022: {},\\n        \\u0022json\\u0022: \\u0022\\u0022,\\n        \\u0022xml\\u0022: \\u0022\\u0022\\n      },\\n      \\u0022Header\\u0022: {},\\n      \\u0022Params\\u0022: {}\\n    }\\n  }\\n}\"', NULL);
INSERT INTO `bigview_project` VALUES (16, '测试项目 副本 副本', '0', '2025-12-26 09:03:44.548381', '0', '0', '/uploads/bigview/15.png', '\"{\\n  \\u0022editCanvasConfig\\u0022: {\\n    \\u0022projectName\\u0022: \\u0022\\u6D4B\\u8BD5\\u9879\\u76EE\\u526F\\u672C\\u0022,\\n    \\u0022width\\u0022: 1920,\\n    \\u0022height\\u0022: 1080,\\n    \\u0022filterShow\\u0022: false,\\n    \\u0022hueRotate\\u0022: 0,\\n    \\u0022saturate\\u0022: 1,\\n    \\u0022contrast\\u0022: 1,\\n    \\u0022brightness\\u0022: 1,\\n    \\u0022opacity\\u0022: 1,\\n    \\u0022rotateZ\\u0022: 0,\\n    \\u0022rotateX\\u0022: 0,\\n    \\u0022rotateY\\u0022: 0,\\n    \\u0022skewX\\u0022: 0,\\n    \\u0022skewY\\u0022: 0,\\n    \\u0022blendMode\\u0022: \\u0022normal\\u0022,\\n    \\u0022background\\u0022: null,\\n    \\u0022backgroundImage\\u0022: null,\\n    \\u0022selectColor\\u0022: true,\\n    \\u0022chartThemeColor\\u0022: \\u0022dark\\u0022,\\n    \\u0022chartCustomThemeColorInfo\\u0022: null,\\n    \\u0022chartThemeSetting\\u0022: {\\n      \\u0022title\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022textStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#BFBFBF\\u0022,\\n          \\u0022fontSize\\u0022: 18\\n        },\\n        \\u0022subtextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#A2A2A2\\u0022,\\n          \\u0022fontSize\\u0022: 14\\n        }\\n      },\\n      \\u0022xAxis\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022name\\u0022: \\u0022\\u0022,\\n        \\u0022nameGap\\u0022: 15,\\n        \\u0022nameTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 12\\n        },\\n        \\u0022inverse\\u0022: false,\\n        \\u0022axisLabel\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022fontSize\\u0022: 12,\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022rotate\\u0022: 0\\n        },\\n        \\u0022position\\u0022: \\u0022bottom\\u0022,\\n        \\u0022axisLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022width\\u0022: 1\\n          },\\n          \\u0022onZero\\u0022: true\\n        },\\n        \\u0022axisTick\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022length\\u0022: 5\\n        },\\n        \\u0022splitLine\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#484753\\u0022,\\n            \\u0022width\\u0022: 1,\\n            \\u0022type\\u0022: \\u0022solid\\u0022\\n          }\\n        },\\n        \\u0022min\\u0022: null,\\n        \\u0022max\\u0022: null\\n      },\\n      \\u0022yAxis\\u0022: {\\n        \\u0022show\\u0022: true,\\n        \\u0022name\\u0022: \\u0022\\u0022,\\n        \\u0022nameGap\\u0022: 15,\\n        \\u0022max\\u0022: null,\\n        \\u0022min\\u0022: null,\\n        \\u0022nameTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 12\\n        },\\n        \\u0022inverse\\u0022: false,\\n        \\u0022axisLabel\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022fontSize\\u0022: 12,\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022rotate\\u0022: 0\\n        },\\n        \\u0022position\\u0022: \\u0022left\\u0022,\\n        \\u0022axisLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022width\\u0022: 1\\n          },\\n          \\u0022onZero\\u0022: true\\n        },\\n        \\u0022axisTick\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022length\\u0022: 5\\n        },\\n        \\u0022splitLine\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022lineStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#484753\\u0022,\\n            \\u0022width\\u0022: 1,\\n            \\u0022type\\u0022: \\u0022solid\\u0022\\n          }\\n        }\\n      },\\n      \\u0022legend\\u0022: {\\n        \\u0022show\\u0022: false,\\n        \\u0022type\\u0022: \\u0022scroll\\u0022,\\n        \\u0022x\\u0022: \\u0022center\\u0022,\\n        \\u0022y\\u0022: \\u0022top\\u0022,\\n        \\u0022icon\\u0022: \\u0022circle\\u0022,\\n        \\u0022orient\\u0022: \\u0022horizontal\\u0022,\\n        \\u0022textStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n          \\u0022fontSize\\u0022: 18\\n        },\\n        \\u0022itemHeight\\u0022: 15,\\n        \\u0022itemWidth\\u0022: 15,\\n        \\u0022pageTextStyle\\u0022: {\\n          \\u0022color\\u0022: \\u0022#B9B8CE\\u0022\\n        }\\n      },\\n      \\u0022grid\\u0022: {\\n        \\u0022show\\u0022: false,\\n        \\u0022left\\u0022: \\u002210%\\u0022,\\n        \\u0022top\\u0022: \\u002260\\u0022,\\n        \\u0022right\\u0022: \\u002210%\\u0022,\\n        \\u0022bottom\\u0022: \\u002260\\u0022\\n      },\\n      \\u0022dataset\\u0022: null,\\n      \\u0022renderer\\u0022: \\u0022svg\\u0022\\n    },\\n    \\u0022previewScaleType\\u0022: \\u0022fit\\u0022,\\n    \\u0022previewTheme\\u0022: \\u0022dark\\u0022\\n  },\\n  \\u0022componentList\\u0022: [\\n    {\\n      \\u0022id\\u0022: \\u0022id_127dubdy2hvk00\\u0022,\\n      \\u0022isGroup\\u0022: false,\\n      \\u0022attr\\u0022: {\\n        \\u0022x\\u0022: 498,\\n        \\u0022y\\u0022: 229,\\n        \\u0022w\\u0022: 1193,\\n        \\u0022h\\u0022: 622,\\n        \\u0022offsetX\\u0022: 0,\\n        \\u0022offsetY\\u0022: 0,\\n        \\u0022zIndex\\u0022: -1\\n      },\\n      \\u0022styles\\u0022: {\\n        \\u0022filterShow\\u0022: false,\\n        \\u0022hueRotate\\u0022: 0,\\n        \\u0022saturate\\u0022: 1,\\n        \\u0022contrast\\u0022: 1,\\n        \\u0022brightness\\u0022: 1,\\n        \\u0022opacity\\u0022: 1,\\n        \\u0022rotateZ\\u0022: 0,\\n        \\u0022rotateX\\u0022: 0,\\n        \\u0022rotateY\\u0022: 0,\\n        \\u0022skewX\\u0022: 0,\\n        \\u0022skewY\\u0022: 0,\\n        \\u0022blendMode\\u0022: \\u0022normal\\u0022,\\n        \\u0022animations\\u0022: []\\n      },\\n      \\u0022preview\\u0022: {\\n        \\u0022overFlowHidden\\u0022: false\\n      },\\n      \\u0022status\\u0022: {\\n        \\u0022lock\\u0022: false,\\n        \\u0022hide\\u0022: false\\n      },\\n      \\u0022request\\u0022: {\\n        \\u0022requestDataType\\u0022: 0,\\n        \\u0022requestHttpType\\u0022: \\u0022get\\u0022,\\n        \\u0022requestUrl\\u0022: \\u0022\\u0022,\\n        \\u0022requestInterval\\u0022: null,\\n        \\u0022requestIntervalUnit\\u0022: \\u0022second\\u0022,\\n        \\u0022requestContentType\\u0022: 0,\\n        \\u0022requestParamsBodyType\\u0022: \\u0022none\\u0022,\\n        \\u0022requestSQLContent\\u0022: {\\n          \\u0022sql\\u0022: \\u0022select * from  where\\u0022,\\n          \\u0022id\\u0022: \\u0022\\u0022,\\n          \\u0022key\\u0022: \\u0022\\u0022,\\n          \\u0022aux\\u0022: {},\\n          \\u0022fileds\\u0022: []\\n        },\\n        \\u0022requestParams\\u0022: {\\n          \\u0022Body\\u0022: {\\n            \\u0022form-data\\u0022: {},\\n            \\u0022x-www-form-urlencoded\\u0022: {},\\n            \\u0022json\\u0022: \\u0022\\u0022,\\n            \\u0022xml\\u0022: \\u0022\\u0022\\n          },\\n          \\u0022Header\\u0022: {},\\n          \\u0022Params\\u0022: {}\\n        }\\n      },\\n      \\u0022filter\\u0022: null,\\n      \\u0022events\\u0022: {\\n        \\u0022baseEvent\\u0022: {\\n          \\u0022click\\u0022: null,\\n          \\u0022dblclick\\u0022: null,\\n          \\u0022change\\u0022: null,\\n          \\u0022mouseenter\\u0022: null,\\n          \\u0022mouseleave\\u0022: null\\n        },\\n        \\u0022advancedEvents\\u0022: {\\n          \\u0022vnodeMounted\\u0022: null,\\n          \\u0022vnodeBeforeMount\\u0022: null\\n        },\\n        \\u0022interactEvents\\u0022: []\\n      },\\n      \\u0022key\\u0022: \\u0022BarCommon\\u0022,\\n      \\u0022chartConfig\\u0022: {\\n        \\u0022key\\u0022: \\u0022BarCommon\\u0022,\\n        \\u0022chartKey\\u0022: \\u0022VBarCommon\\u0022,\\n        \\u0022conKey\\u0022: \\u0022VCBarCommon\\u0022,\\n        \\u0022title\\u0022: \\u0022\\u67F1\\u72B6\\u56FE\\u0022,\\n        \\u0022category\\u0022: \\u0022Bars\\u0022,\\n        \\u0022categoryName\\u0022: \\u0022\\u67F1\\u72B6\\u56FE\\u0022,\\n        \\u0022package\\u0022: \\u0022Charts\\u0022,\\n        \\u0022chartFrame\\u0022: \\u0022echarts\\u0022,\\n        \\u0022image\\u0022: \\u0022bar_x.png\\u0022\\n      },\\n      \\u0022option\\u0022: {\\n        \\u0022legend\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022type\\u0022: \\u0022scroll\\u0022,\\n          \\u0022x\\u0022: \\u0022center\\u0022,\\n          \\u0022y\\u0022: \\u0022top\\u0022,\\n          \\u0022icon\\u0022: \\u0022circle\\u0022,\\n          \\u0022orient\\u0022: \\u0022horizontal\\u0022,\\n          \\u0022textStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 18\\n          },\\n          \\u0022itemHeight\\u0022: 15,\\n          \\u0022itemWidth\\u0022: 15,\\n          \\u0022pageTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022\\n          }\\n        },\\n        \\u0022xAxis\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022name\\u0022: \\u0022\\u0022,\\n          \\u0022nameGap\\u0022: 15,\\n          \\u0022nameTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 12\\n          },\\n          \\u0022inverse\\u0022: false,\\n          \\u0022axisLabel\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022fontSize\\u0022: 12,\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022rotate\\u0022: 0\\n          },\\n          \\u0022position\\u0022: \\u0022bottom\\u0022,\\n          \\u0022axisLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n              \\u0022width\\u0022: 1\\n            },\\n            \\u0022onZero\\u0022: true\\n          },\\n          \\u0022axisTick\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022length\\u0022: 5\\n          },\\n          \\u0022splitLine\\u0022: {\\n            \\u0022show\\u0022: false,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#484753\\u0022,\\n              \\u0022width\\u0022: 1,\\n              \\u0022type\\u0022: \\u0022solid\\u0022\\n            }\\n          },\\n          \\u0022min\\u0022: null,\\n          \\u0022max\\u0022: null,\\n          \\u0022type\\u0022: \\u0022category\\u0022\\n        },\\n        \\u0022yAxis\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022name\\u0022: \\u0022\\u0022,\\n          \\u0022nameGap\\u0022: 15,\\n          \\u0022max\\u0022: null,\\n          \\u0022min\\u0022: null,\\n          \\u0022nameTextStyle\\u0022: {\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022fontSize\\u0022: 12\\n          },\\n          \\u0022inverse\\u0022: false,\\n          \\u0022axisLabel\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022fontSize\\u0022: 12,\\n            \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n            \\u0022rotate\\u0022: 0\\n          },\\n          \\u0022position\\u0022: \\u0022left\\u0022,\\n          \\u0022axisLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#B9B8CE\\u0022,\\n              \\u0022width\\u0022: 1\\n            },\\n            \\u0022onZero\\u0022: true\\n          },\\n          \\u0022axisTick\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022length\\u0022: 5\\n          },\\n          \\u0022splitLine\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022lineStyle\\u0022: {\\n              \\u0022color\\u0022: \\u0022#484753\\u0022,\\n              \\u0022width\\u0022: 1,\\n              \\u0022type\\u0022: \\u0022solid\\u0022\\n            }\\n          },\\n          \\u0022type\\u0022: \\u0022value\\u0022\\n        },\\n        \\u0022grid\\u0022: {\\n          \\u0022show\\u0022: false,\\n          \\u0022left\\u0022: \\u002210%\\u0022,\\n          \\u0022top\\u0022: \\u002260\\u0022,\\n          \\u0022right\\u0022: \\u002210%\\u0022,\\n          \\u0022bottom\\u0022: \\u002260\\u0022\\n        },\\n        \\u0022tooltip\\u0022: {\\n          \\u0022show\\u0022: true,\\n          \\u0022trigger\\u0022: \\u0022axis\\u0022,\\n          \\u0022axisPointer\\u0022: {\\n            \\u0022show\\u0022: true,\\n            \\u0022type\\u0022: \\u0022shadow\\u0022\\n          }\\n        },\\n        \\u0022dataZoom\\u0022: [\\n          {\\n            \\u0022show\\u0022: true,\\n            \\u0022type\\u0022: \\u0022inside\\u0022,\\n            \\u0022disabled\\u0022: false,\\n            \\u0022realtime\\u0022: true,\\n            \\u0022start\\u0022: 0,\\n            \\u0022end\\u0022: 100,\\n            \\u0022xAxisIndex\\u0022: [\\n              0,\\n              1\\n            ]\\n          }\\n        ],\\n        \\u0022dataset\\u0022: {\\n          \\u0022dimensions\\u0022: [\\n            \\u0022product\\u0022,\\n            \\u0022data1\\u0022,\\n            \\u0022data2\\u0022\\n          ],\\n          \\u0022source\\u0022: [\\n            {\\n              \\u0022product\\u0022: \\u0022Mon\\u0022,\\n              \\u0022data1\\u0022: 120,\\n              \\u0022data2\\u0022: 130\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Tue\\u0022,\\n              \\u0022data1\\u0022: 200,\\n              \\u0022data2\\u0022: 130\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Wed\\u0022,\\n              \\u0022data1\\u0022: 150,\\n              \\u0022data2\\u0022: 312\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Thu\\u0022,\\n              \\u0022data1\\u0022: 80,\\n              \\u0022data2\\u0022: 268\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Fri\\u0022,\\n              \\u0022data1\\u0022: 70,\\n              \\u0022data2\\u0022: 155\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Sat\\u0022,\\n              \\u0022data1\\u0022: 110,\\n              \\u0022data2\\u0022: 117\\n            },\\n            {\\n              \\u0022product\\u0022: \\u0022Sun\\u0022,\\n              \\u0022data1\\u0022: 130,\\n              \\u0022data2\\u0022: 160\\n            }\\n          ]\\n        },\\n        \\u0022series\\u0022: [\\n          {\\n            \\u0022type\\u0022: \\u0022bar\\u0022,\\n            \\u0022barWidth\\u0022: 15,\\n            \\u0022label\\u0022: {\\n              \\u0022show\\u0022: true,\\n              \\u0022position\\u0022: \\u0022top\\u0022,\\n              \\u0022color\\u0022: \\u0022#fff\\u0022,\\n              \\u0022fontSize\\u0022: 12\\n            },\\n            \\u0022itemStyle\\u0022: {\\n              \\u0022color\\u0022: null,\\n              \\u0022borderRadius\\u0022: 2\\n            }\\n          },\\n          {\\n            \\u0022type\\u0022: \\u0022bar\\u0022,\\n            \\u0022barWidth\\u0022: 15,\\n            \\u0022label\\u0022: {\\n              \\u0022show\\u0022: true,\\n              \\u0022position\\u0022: \\u0022top\\u0022,\\n              \\u0022color\\u0022: \\u0022#fff\\u0022,\\n              \\u0022fontSize\\u0022: 12\\n            },\\n            \\u0022itemStyle\\u0022: {\\n              \\u0022color\\u0022: null,\\n              \\u0022borderRadius\\u0022: 2\\n            }\\n          }\\n        ],\\n        \\u0022backgroundColor\\u0022: \\u0022rgba(0,0,0,0)\\u0022\\n      }\\n    }\\n  ],\\n  \\u0022requestGlobalConfig\\u0022: {\\n    \\u0022requestDataPond\\u0022: [],\\n    \\u0022requestOriginUrl\\u0022: \\u0022\\u0022,\\n    \\u0022requestInterval\\u0022: 30,\\n    \\u0022requestIntervalUnit\\u0022: \\u0022second\\u0022,\\n    \\u0022requestParams\\u0022: {\\n      \\u0022Body\\u0022: {\\n        \\u0022form-data\\u0022: {},\\n        \\u0022x-www-form-urlencoded\\u0022: {},\\n        \\u0022json\\u0022: \\u0022\\u0022,\\n        \\u0022xml\\u0022: \\u0022\\u0022\\n      },\\n      \\u0022Header\\u0022: {},\\n      \\u0022Params\\u0022: {}\\n    }\\n  }\\n}\"', NULL);

-- ----------------------------
-- Table structure for contract_attachment
-- ----------------------------
DROP TABLE IF EXISTS `contract_attachment`;
CREATE TABLE `contract_attachment`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL,
  `file_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `size` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `upload_date` datetime(6) NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_contract_attachment_contract_id`(`contract_id` ASC) USING BTREE,
  CONSTRAINT `FK_contract_attachment_contract_main_contract_id` FOREIGN KEY (`contract_id`) REFERENCES `contract_main` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of contract_attachment
-- ----------------------------
INSERT INTO `contract_attachment` VALUES (1, 1, '合同扫描件.pdf', '/uploads/contracts/scan_20251205.pdf', '2.5 MB', '2025-12-05 00:00:00.000000');
INSERT INTO `contract_attachment` VALUES (2, 1, '技术协议.docx', '/uploads/contracts/tech_20251205.docx', '1.2 MB', '2025-12-05 00:00:00.000000');
INSERT INTO `contract_attachment` VALUES (3, 1, '补充协议一.pdf', '/uploads/contracts/supp_20251215.pdf', '0.8 MB', '2025-12-15 00:00:00.000000');

-- ----------------------------
-- Table structure for contract_contact
-- ----------------------------
DROP TABLE IF EXISTS `contract_contact`;
CREATE TABLE `contract_contact`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_contract_contact_contract_id`(`contract_id` ASC) USING BTREE,
  CONSTRAINT `FK_contract_contact_contract_main_contract_id` FOREIGN KEY (`contract_id`) REFERENCES `contract_main` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of contract_contact
-- ----------------------------
INSERT INTO `contract_contact` VALUES (1, 1, '李四', '客户项目经理', '13800138000', 'lisi@yytech.com');
INSERT INTO `contract_contact` VALUES (2, 1, '王五', '财务对接人', '13900139000', 'wangwu@yytech.com');

-- ----------------------------
-- Table structure for contract_invoice
-- ----------------------------
DROP TABLE IF EXISTS `contract_invoice`;
CREATE TABLE `contract_invoice`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL,
  `invoice_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `invoice_date` datetime(6) NOT NULL,
  `amount` decimal(18, 2) NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_contract_invoice_contract_id`(`contract_id` ASC) USING BTREE,
  CONSTRAINT `FK_contract_invoice_contract_main_contract_id` FOREIGN KEY (`contract_id`) REFERENCES `contract_main` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of contract_invoice
-- ----------------------------
INSERT INTO `contract_invoice` VALUES (1, 1, 'FP20251210001', '2025-12-10 00:00:00.000000', 20000.00, '增值税专用发票', 'issued');

-- ----------------------------
-- Table structure for contract_knowledge_category
-- ----------------------------
DROP TABLE IF EXISTS `contract_knowledge_category`;
CREATE TABLE `contract_knowledge_category`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `parent_id` bigint NULL DEFAULT NULL,
  `sort_order` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of contract_knowledge_category
-- ----------------------------
INSERT INTO `contract_knowledge_category` VALUES (2, '法律法规', NULL, 1, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (3, '公司制度', NULL, 2, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (4, '合同范本', NULL, 3, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (5, '风险案例', NULL, 4, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (6, '民法典', 2, 1, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (7, '招标投标法', 2, 2, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (8, '建筑法', 2, 3, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (9, '合同管理制度', 3, 1, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (10, '印章使用规范', 3, 2, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (11, '采购类', 4, 1, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (12, '销售类', 4, 2, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (13, '租赁类', 4, 3, '2025-12-28 21:59:24.534003');
INSERT INTO `contract_knowledge_category` VALUES (14, '测试', 15, 5, '2025-12-28 23:06:14.803225');
INSERT INTO `contract_knowledge_category` VALUES (15, '111', 5, 1, '2025-12-28 23:06:30.250010');

-- ----------------------------
-- Table structure for contract_knowledge_file
-- ----------------------------
DROP TABLE IF EXISTS `contract_knowledge_file`;
CREATE TABLE `contract_knowledge_file`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `size` bigint NOT NULL DEFAULT 0,
  `uploader` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `upload_time` datetime(6) NOT NULL,
  `content_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of contract_knowledge_file
-- ----------------------------
INSERT INTO `contract_knowledge_file` VALUES (1, 6, '中华人民共和国民法典.pdf', 'pdf', NULL, 0, '系统管理员', '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_knowledge_file` VALUES (2, 9, '合同审查要点指南.docx', 'doc', NULL, 0, '法务部', '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_knowledge_file` VALUES (3, 9, '2023年度合同台账模板.xlsx', 'xls', NULL, 0, '财务部', '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_knowledge_file` VALUES (4, 5, '常见合同风险提示.txt', 'txt', NULL, 0, '风控部', '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_knowledge_file` VALUES (5, 8, '建设工程施工合同(示范文本)1.docx', 'doc', NULL, 0, '工程部', '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_knowledge_file` VALUES (6, 2, '前端学习计划.docx', 'doc', '/uploads/knowledge/前端学习计划.docx', 0, '当前用户', '2025-12-28 23:25:29.141016', NULL);
INSERT INTO `contract_knowledge_file` VALUES (10, 8, '前端学习计划.docx', 'doc', '/uploads/knowledge/法律法规/建筑法/前端学习计划.docx', 21119, 'admin', '2025-12-28 23:52:09.789025', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
INSERT INTO `contract_knowledge_file` VALUES (11, 8, '9.机关档案管理规定.doc', 'doc', '/uploads/knowledge/法律法规/建筑法/9.机关档案管理规定.doc', 281088, 'admin', '2025-12-29 00:24:33.034304', 'application/msword');

-- ----------------------------
-- Table structure for contract_main
-- ----------------------------
DROP TABLE IF EXISTS `contract_main`;
CREATE TABLE `contract_main`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `contract_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `contract_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `partner_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sign_date` datetime(6) NULL DEFAULT NULL,
  `start_date` datetime(6) NULL DEFAULT NULL,
  `end_date` datetime(6) NULL DEFAULT NULL,
  `manager` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `total_amount` decimal(18, 2) NOT NULL,
  `paid_amount` decimal(18, 2) NOT NULL,
  `invoiced_amount` decimal(18, 2) NOT NULL,
  `progress` int NOT NULL,
  `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `payment_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `tax_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `latest_transaction_date` datetime(6) NULL DEFAULT NULL,
  `files` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of contract_main
-- ----------------------------
INSERT INTO `contract_main` VALUES (1, 'XS2025122001', '企业云服务年度订阅', 'sales', 'YY科技股份有限公司', '2025-12-05 00:00:00.000000', NULL, NULL, 'Sales Manager', 50000.00, 20000.00, 0.00, 0, 'CNY', NULL, NULL, 'completed', '按季度付款', '2025-12-10 00:00:00.000000', NULL, '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_main` VALUES (2, 'XS2025121503', 'CRM系统维护服务', 'sales', 'BB网络科技有限公司', '2025-12-15 00:00:00.000000', NULL, NULL, 'Sales Manager', 12000.00, 0.00, 0.00, 0, 'CNY', NULL, NULL, 'executing', '首付款未到', NULL, NULL, '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_main` VALUES (3, 'XS2025112009', '数据中心扩容硬件销售', 'sales', 'CC数据中心', '2025-11-20 00:00:00.000000', NULL, NULL, 'Sales Manager', 450000.00, 450000.00, 0.00, 0, 'CNY', NULL, NULL, 'completed', '已全额到账', '2025-11-25 00:00:00.000000', NULL, '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_main` VALUES (4, 'CG2025120101', '智慧城市二期项目采购合同', 'purchase', 'XX市政集团', '2025-12-01 00:00:00.000000', NULL, NULL, 'Purchase Manager', 1200000.00, 400000.00, 0.00, 0, 'CNY', NULL, NULL, 'executing', '预付款已付', '2025-12-05 00:00:00.000000', NULL, '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_main` VALUES (5, 'CG2025121008', '办公设备采购协议', 'purchase', 'AA贸易公司', '2025-12-10 00:00:00.000000', NULL, NULL, 'Purchase Manager', 120000.00, 12000.00, 0.00, 0, 'CNY', NULL, NULL, 'executing', '定金已付', '2025-12-11 00:00:00.000000', NULL, '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_main` VALUES (6, 'CG2025111505', '服务器集群采购', 'purchase', 'Dell供应商', '2025-11-15 00:00:00.000000', NULL, NULL, 'Purchase Manager', 500000.00, 500000.00, 0.00, 0, 'CNY', NULL, NULL, 'completed', '设备已验收', '2025-11-20 00:00:00.000000', NULL, '2025-12-28 21:59:24.534003', NULL);
INSERT INTO `contract_main` VALUES (7, 'CNT-20251228224522', '综合信息管理系统开发服务合同', 'sales', 'cust001', '2025-12-28 00:00:00.000000', NULL, NULL, '张三', 1000000.00, 0.00, 0.00, 0, 'CNY', 'bank', '', 'executing', '', NULL, '[]', '2025-12-28 22:45:22.542600', NULL);

-- ----------------------------
-- Table structure for contract_payment_plan
-- ----------------------------
DROP TABLE IF EXISTS `contract_payment_plan`;
CREATE TABLE `contract_payment_plan`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL,
  `phase` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `due_date` datetime(6) NULL DEFAULT NULL,
  `amount` decimal(18, 2) NOT NULL,
  `condition` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_contract_payment_plan_contract_id`(`contract_id` ASC) USING BTREE,
  CONSTRAINT `FK_contract_payment_plan_contract_main_contract_id` FOREIGN KEY (`contract_id`) REFERENCES `contract_main` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of contract_payment_plan
-- ----------------------------
INSERT INTO `contract_payment_plan` VALUES (1, 1, '第一期', '2025-12-10 00:00:00.000000', 20000.00, '合同签订后5个工作日', 'paid');
INSERT INTO `contract_payment_plan` VALUES (2, 1, '第二期', '2026-03-10 00:00:00.000000', 15000.00, '项目中期验收', 'pending');
INSERT INTO `contract_payment_plan` VALUES (3, 1, '第三期', '2026-06-10 00:00:00.000000', 15000.00, '项目终验', 'pending');

-- ----------------------------
-- Table structure for contract_payment_record
-- ----------------------------
DROP TABLE IF EXISTS `contract_payment_record`;
CREATE TABLE `contract_payment_record`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL,
  `payment_date` datetime(6) NOT NULL,
  `amount` decimal(18, 2) NOT NULL,
  `method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `operator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `remark` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_contract_payment_record_contract_id`(`contract_id` ASC) USING BTREE,
  CONSTRAINT `FK_contract_payment_record_contract_main_contract_id` FOREIGN KEY (`contract_id`) REFERENCES `contract_main` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of contract_payment_record
-- ----------------------------
INSERT INTO `contract_payment_record` VALUES (1, 1, '2025-12-10 00:00:00.000000', 20000.00, '银行转账', '张三', '首付款');

-- ----------------------------
-- Table structure for contract_stat
-- ----------------------------
DROP TABLE IF EXISTS `contract_stat`;
CREATE TABLE `contract_stat`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `period_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `period_key` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `stat_date` datetime(6) NOT NULL,
  `total_contracts` int NOT NULL,
  `total_amount` decimal(18, 2) NOT NULL,
  `received_amount` decimal(18, 2) NOT NULL,
  `invoiced_amount` decimal(18, 2) NOT NULL,
  `pending_invoice_amount` decimal(18, 2) NOT NULL,
  `sales_count` int NOT NULL,
  `purchase_count` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `amount_completion_rate` decimal(5, 2) NOT NULL DEFAULT 0.00,
  `received_rate` decimal(5, 2) NOT NULL DEFAULT 0.00,
  `total_contracts_growth` decimal(5, 2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of contract_stat
-- ----------------------------
INSERT INTO `contract_stat` VALUES (1, 'Year', '', '2025-12-28 21:59:24.534003', 158, 25800000.00, 18500000.00, 12005000.00, 450000.00, 0, 0, '2025-12-28 21:59:24.534003', 78.00, 71.70, 12.50);
INSERT INTO `contract_stat` VALUES (2, 'Quarter', '', '2025-12-28 21:59:24.534003', 45, 8500000.00, 5000000.00, 4000000.00, 150000.00, 0, 0, '2025-12-28 21:59:24.534003', 60.00, 58.80, 5.20);
INSERT INTO `contract_stat` VALUES (3, 'Month', '', '2025-12-28 21:59:24.534003', 12, 2500000.00, 800000.00, 700000.00, 50000.00, 0, 0, '2025-12-28 21:59:24.534003', 30.00, 32.00, 2.00);

-- ----------------------------
-- Table structure for contract_template
-- ----------------------------
DROP TABLE IF EXISTS `contract_template`;
CREATE TABLE `contract_template`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `file_path` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `file_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of contract_template
-- ----------------------------
INSERT INTO `contract_template` VALUES (1, '标准产品销售合同', 'sales', '适用于一般标准产品的销售业务', NULL, 'standard_sales_contract_v1.docx', 'active', '2025-12-28 21:59:24.534003', '2025-12-28 21:59:24.534003');
INSERT INTO `contract_template` VALUES (2, '原材料采购框架协议', 'purchase', '适用于长期原材料采购合作', NULL, 'material_purchase_agreement.pdf', 'active', '2025-12-28 21:59:24.534003', '2025-12-28 21:59:24.534003');
INSERT INTO `contract_template` VALUES (3, '技术服务合同', 'service', '适用于软件开发及技术支持服务', NULL, 'tech_service_contract.docx', 'active', '2025-12-28 21:59:24.534003', '2025-12-28 21:59:24.534003');
INSERT INTO `contract_template` VALUES (4, '员工劳动合同（标准版）', 'labor', '全职员工标准劳动合同', NULL, 'employee_labor_contract.docx', 'active', '2025-12-28 21:59:24.534003', '2025-12-28 21:59:24.534003');

-- ----------------------------
-- Table structure for data_source_connection
-- ----------------------------
DROP TABLE IF EXISTS `data_source_connection`;
CREATE TABLE `data_source_connection`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Host` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Port` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `User` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Database` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of data_source_connection
-- ----------------------------
INSERT INTO `data_source_connection` VALUES (1, '测试1', 'mysql', '112.74.21.57', '3306', 'testdb', '75TdDjmtMTBWrYDm', 'testdb', '2025-12-23 12:24:11.311183', '2025-12-23 15:03:18.209988');
INSERT INTO `data_source_connection` VALUES (2, '测试2', 'mysql', '112.74.21.57', '3306', 'testdb2', 'fMbetdPkY2jcYXmp', 'testdb2', '2025-12-23 15:02:00.648900', NULL);

-- ----------------------------
-- Table structure for frm_category
-- ----------------------------
DROP TABLE IF EXISTS `frm_category`;
CREATE TABLE `frm_category`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ParentId` bigint NULL DEFAULT NULL,
  `SortOrder` int NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `CreatedBy` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_frm_category_ParentId`(`ParentId` ASC) USING BTREE,
  CONSTRAINT `FK_frm_category_frm_category_ParentId` FOREIGN KEY (`ParentId`) REFERENCES `frm_category` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of frm_category
-- ----------------------------
INSERT INTO `frm_category` VALUES (1, '测试', NULL, 1, '2025-12-26 11:15:42.106897', 1);
INSERT INTO `frm_category` VALUES (2, '测试2', NULL, 2, '2025-12-26 11:16:11.502720', 1);
INSERT INTO `frm_category` VALUES (3, '子类1', 1, 1, '2025-12-26 11:17:24.624397', 1);
INSERT INTO `frm_category` VALUES (4, '子类2', 1, 2, '2025-12-26 11:17:35.769536', 1);
INSERT INTO `frm_category` VALUES (5, '销售类', 2, 1, '2025-12-26 11:17:46.573287', 1);

-- ----------------------------
-- Table structure for frm_data
-- ----------------------------
DROP TABLE IF EXISTS `frm_data`;
CREATE TABLE `frm_data`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `form_id` bigint NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `submitted_at` datetime(6) NOT NULL,
  `submitted_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of frm_data
-- ----------------------------
INSERT INTO `frm_data` VALUES (4, 1, '{\"1766720161571_1\":\"abcd\",\"1766720186970_1\":[{\"1766720186971_2\":\"11\",\"1766720190508_4\":\"12\",\"1766720186971_3\":\"13\"},{\"1766720186971_2\":\"21\",\"1766720190508_4\":\"22\",\"1766720186971_3\":\"23\"}],\"1766720195038_5\":\"33333\"}', '2025-12-26 19:58:37.503810', 'admin');

-- ----------------------------
-- Table structure for frm_definition
-- ----------------------------
DROP TABLE IF EXISTS `frm_definition`;
CREATE TABLE `frm_definition`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `CategoryId` bigint NOT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `FormItems` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `IsPublished` tinyint(1) NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NOT NULL,
  `CreatedBy` bigint NULL DEFAULT NULL,
  `UpdatedBy` bigint NULL DEFAULT NULL,
  `RequiresLogin` tinyint(1) NOT NULL DEFAULT 0,
  `LimitOnePerUser` tinyint(1) NOT NULL DEFAULT 0,
  `FillRoleIds` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `ManageRoleIds` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `ViewRoleIds` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_frm_definition_CategoryId`(`CategoryId` ASC) USING BTREE,
  CONSTRAINT `FK_frm_definition_frm_category_CategoryId` FOREIGN KEY (`CategoryId`) REFERENCES `frm_category` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of frm_definition
-- ----------------------------
INSERT INTO `frm_definition` VALUES (1, 4, '测试', NULL, '测试表单', '[{\"type\":\"input\",\"label\":\"单行文本1\",\"field\":\"input_1766720161571\",\"required\":true,\"placeholder\":\"\",\"span\":24,\"showLabel\":true,\"hidden\":false,\"id\":\"1766720161571_1\",\"columns\":[]},{\"type\":\"subtable\",\"label\":\"子表1\",\"field\":\"subtable_1766720186970\",\"required\":false,\"span\":24,\"columns\":[{\"label\":\"列1\",\"field\":\"col_1\",\"type\":\"input\",\"widthType\":\"px\",\"id\":\"1766720186971_2\"},{\"type\":\"input\",\"label\":\"单行文本2\",\"field\":\"input_1766720190508\",\"required\":false,\"placeholder\":\"\",\"span\":24,\"showLabel\":true,\"hidden\":false,\"id\":\"1766720190508_4\",\"widthType\":\"px\"},{\"label\":\"列2\",\"field\":\"col_2\",\"type\":\"input\",\"widthType\":\"px\",\"id\":\"1766720186971_3\"}],\"showRowNumber\":true,\"showSummary\":false,\"showLabel\":true,\"hidden\":false,\"id\":\"1766720186970_1\"},{\"type\":\"input\",\"label\":\"单行文本3\",\"field\":\"input_1766720195038\",\"required\":false,\"placeholder\":\"\",\"span\":24,\"showLabel\":true,\"hidden\":false,\"id\":\"1766720195038_5\",\"columns\":[]}]', 1, '2025-12-26 11:19:46.632341', '2025-12-26 22:00:20.746319', 1, 1, 1, 1, '2', '1,3', '1,3');

-- ----------------------------
-- Table structure for page_categories
-- ----------------------------
DROP TABLE IF EXISTS `page_categories`;
CREATE TABLE `page_categories`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ParentId` bigint NULL DEFAULT NULL,
  `SortOrder` int NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_page_categories_ParentId`(`ParentId` ASC) USING BTREE,
  CONSTRAINT `FK_page_categories_page_categories_ParentId` FOREIGN KEY (`ParentId`) REFERENCES `page_categories` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of page_categories
-- ----------------------------
INSERT INTO `page_categories` VALUES (1, '测试', 2, 2);
INSERT INTO `page_categories` VALUES (2, '人事管理', NULL, 2);
INSERT INTO `page_categories` VALUES (3, '招聘管理', 2, 1);

-- ----------------------------
-- Table structure for page_definitions
-- ----------------------------
DROP TABLE IF EXISTS `page_definitions`;
CREATE TABLE `page_definitions`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `CategoryId` bigint NULL DEFAULT NULL,
  `Code` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `Config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `ApiBindings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_page_definitions_CategoryId`(`CategoryId` ASC) USING BTREE,
  CONSTRAINT `FK_page_definitions_page_categories_CategoryId` FOREIGN KEY (`CategoryId`) REFERENCES `page_categories` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of page_definitions
-- ----------------------------
INSERT INTO `page_definitions` VALUES (1, '招聘需求列表', 3, 'import { ref, reactive, onMounted } from \'vue\';\nimport { message } from \'ant-design-vue\';\n\n// 查询条件\nconst query = reactive({\n  keyword: \'\',\n  status: undefined,\n  page: 1,\n  pageSize: 10\n});\n\n// 分页配置\nconst pagination = reactive({\n  current: 1,\n  pageSize: 10,\n  total: 0,\n  showSizeChanger: true,\n  pageSizeOptions: [\'10\', \'20\', \'50\', \'100\'],\n  showTotal: (total) => `共 ${total} 条数据`\n});\n\n// 表格数据\nconst tableData = ref([]);\nconst loading = ref(false);\n\n// 方法\nconst handleSearch = () => {\n  loading.value = true;\n  message.info(\'执行查询: \' + JSON.stringify(query));\n  // 模拟API调用\n  setTimeout(() => {\n    // 模拟总数\n    const total = 100;\n    pagination.total = total;\n    \n    tableData.value = Array.from({ length: query.pageSize }).map((_, i) => ({\n      id: (query.page - 1) * query.pageSize + i + 1,\n      name: \'测试数据 \' + ((query.page - 1) * query.pageSize + i + 1),\n      status: i % 2 === 0 ? \'启用\' : \'禁用\',\n      createTime: \'2023-12-\' + (i + 1).toString().padStart(2, \'0\')\n    }));\n    loading.value = false;\n  }, 500);\n};\n\nconst handleTableChange = (pag) => {\n  pagination.current = pag.current;\n  pagination.pageSize = pag.pageSize;\n  query.page = pag.current;\n  query.pageSize = pag.pageSize;\n  handleSearch();\n};\n\nconst handleReset = () => {\n  query.keyword = \'\';\n  query.status = undefined;\n  query.page = 1;\n  handleSearch();\n};\n\nconst handleAdd = () => {\n  message.success(\'点击新增\');\n};\n\nconst handleEdit = () => {\n  message.success(\'点击修改\');\n};\n\nconst handleBatchDelete = () => {\n  message.error(\'点击批量删除\');\n};\n\nconst handleImport = () => {\n  message.success(\'点击导入\');\n};\n\nconst handleExport = () => {\n  message.success(\'点击导出\');\n};\n\nconst handleRefresh = () => {\n  handleSearch();\n};\n\nonMounted(() => {\n  handleSearch();\n});', '{\"root\":{\"id\":\"root\",\"type\":\"div\",\"props\":{},\"style\":{\"padding\":\"24px\",\"height\":\"100%\",\"display\":\"flex\",\"flexDirection\":\"column\",\"background\":\"#f0f2f5\"},\"events\":{},\"children\":[{\"id\":\"comp_1z0edrarb\",\"type\":\"ACard\",\"props\":{\"bordered\":false},\"style\":{\"marginBottom\":\"16px\",\"flexShrink\":\"0\"},\"events\":{},\"children\":[{\"id\":\"comp_l2mworood\",\"type\":\"AForm\",\"props\":{\"layout\":\"inline\"},\"style\":{\"marginBottom\":\"16px\"},\"events\":{},\"children\":[{\"id\":\"comp_5kgkrkj58\",\"type\":\"AFormItem\",\"props\":{\"label\":\"关键词\"},\"style\":{},\"events\":{},\"children\":[{\"id\":\"comp_0ko9d18l0\",\"type\":\"AInput\",\"props\":{\"placeholder\":\"请输入搜索关键词\",\"allowClear\":true},\"model\":\"query.keyword\",\"style\":{\"width\":\"200px\"},\"children\":[],\"events\":{}}]},{\"id\":\"comp_fq1x2qafs\",\"type\":\"AFormItem\",\"props\":{\"label\":\"状态\"},\"style\":{},\"events\":{},\"children\":[{\"id\":\"comp_4s8jtlfdr\",\"type\":\"ASelect\",\"props\":{\"placeholder\":\"请选择状态\",\"allowClear\":true,\"options\":[{\"label\":\"启用\",\"value\":\"1\"},{\"label\":\"禁用\",\"value\":\"0\"}]},\"model\":\"query.status\",\"style\":{\"width\":\"150px\"},\"children\":[],\"events\":{}}]},{\"id\":\"comp_yo17tzc9a\",\"type\":\"AFormItem\",\"props\":{},\"style\":{},\"events\":{},\"children\":[{\"id\":\"comp_iskef4hn6\",\"type\":\"ASpace\",\"props\":{},\"style\":{},\"events\":{},\"children\":[{\"id\":\"comp_e8lh3ebf6\",\"type\":\"AButton\",\"props\":{\"type\":\"primary\"},\"text\":\"查询\",\"events\":{\"click\":\"handleSearch\"},\"style\":{},\"children\":[]},{\"id\":\"comp_g6n3s2fmp\",\"type\":\"AButton\",\"props\":{},\"text\":\"重置\",\"events\":{\"click\":\"handleReset\"},\"style\":{},\"children\":[]}]}]}]},{\"id\":\"comp_ragn9bons\",\"type\":\"ASpace\",\"props\":{},\"style\":{\"width\":\"100%\",\"justifyContent\":\"space-between\"},\"events\":{},\"children\":[{\"id\":\"comp_z41j5665c\",\"type\":\"ASpace\",\"props\":{},\"style\":{},\"events\":{},\"children\":[{\"id\":\"comp_h7tg998rc\",\"type\":\"AButton\",\"props\":{\"type\":\"primary\"},\"text\":\"新增\",\"events\":{\"click\":\"handleAdd\"},\"style\":{},\"children\":[]},{\"id\":\"comp_zqjz3bdmo\",\"type\":\"AButton\",\"props\":{},\"text\":\"修改\",\"events\":{\"click\":\"handleEdit\"},\"style\":{},\"children\":[]},{\"id\":\"comp_69vrb654d\",\"type\":\"AButton\",\"props\":{\"danger\":true},\"text\":\"批量删除\",\"events\":{\"click\":\"handleBatchDelete\"},\"style\":{},\"children\":[]},{\"id\":\"comp_eatmh2mz5\",\"type\":\"AButton\",\"props\":{},\"text\":\"导入\",\"events\":{\"click\":\"handleImport\"},\"style\":{},\"children\":[]},{\"id\":\"comp_bik3e2icz\",\"type\":\"AButton\",\"props\":{},\"text\":\"导出\",\"events\":{\"click\":\"handleExport\"},\"style\":{},\"children\":[]}]},{\"id\":\"comp_8mihoyzt8\",\"type\":\"ASpace\",\"props\":{},\"style\":{},\"events\":{},\"children\":[{\"id\":\"comp_028w63q90\",\"type\":\"AButton\",\"props\":{},\"text\":\"刷新\",\"events\":{\"click\":\"handleRefresh\"},\"style\":{},\"children\":[]}]}]}]},{\"id\":\"comp_zbcnq48v9\",\"type\":\"ACard\",\"props\":{\"bordered\":false,\"bodyStyle\":{\"padding\":\"0\",\"flex\":\"1\",\"display\":\"flex\",\"flexDirection\":\"column\",\"overflow\":\"hidden\"}},\"style\":{\"flex\":\"1\",\"overflow\":\"hidden\",\"display\":\"flex\",\"flexDirection\":\"column\"},\"events\":{},\"children\":[{\"id\":\"comp_2n2srde9y\",\"type\":\"ATable\",\"props\":{\"columns\":[{\"title\":\"ID\",\"dataIndex\":\"id\",\"width\":80},{\"title\":\"名称\",\"dataIndex\":\"name\"},{\"title\":\"状态\",\"dataIndex\":\"status\"},{\"title\":\"创建时间\",\"dataIndex\":\"createTime\"},{\"title\":\"操作\",\"key\":\"action\",\"width\":200,\"fixed\":\"right\"}],\"dataSource\":[],\"scroll\":{\"y\":\"calc(100vh - 250px)\"},\"pagination\":{\"position\":[\"bottomRight\"],\"showSizeChanger\":true,\"showQuickJumper\":true,\"pageSize\":10,\"pageSizeOptions\":[\"10\",\"20\",\"50\",\"100\"],\"total\":100},\"rowSelection\":{\"type\":\"checkbox\"},\"rowKey\":\"id\"},\"model\":\"tableData\",\"style\":{\"flex\":\"1\"},\"events\":{\"change\":\"handleTableChange\"},\"children\":[]}]}]},\"script\":\"import { ref, reactive, onMounted } from \'vue\';\\nimport { message } from \'ant-design-vue\';\\n\\n// 查询条件\\nconst query = reactive({\\n  keyword: \'\',\\n  status: undefined,\\n  page: 1,\\n  pageSize: 10\\n});\\n\\n// 分页配置\\nconst pagination = reactive({\\n  current: 1,\\n  pageSize: 10,\\n  total: 0,\\n  showSizeChanger: true,\\n  pageSizeOptions: [\'10\', \'20\', \'50\', \'100\'],\\n  showTotal: (total) => `共 ${total} 条数据`\\n});\\n\\n// 表格数据\\nconst tableData = ref([]);\\nconst loading = ref(false);\\n\\n// 方法\\nconst handleSearch = () => {\\n  loading.value = true;\\n  message.info(\'执行查询: \' + JSON.stringify(query));\\n  // 模拟API调用\\n  setTimeout(() => {\\n    // 模拟总数\\n    const total = 100;\\n    pagination.total = total;\\n    \\n    tableData.value = Array.from({ length: query.pageSize }).map((_, i) => ({\\n      id: (query.page - 1) * query.pageSize + i + 1,\\n      name: \'测试数据 \' + ((query.page - 1) * query.pageSize + i + 1),\\n      status: i % 2 === 0 ? \'启用\' : \'禁用\',\\n      createTime: \'2023-12-\' + (i + 1).toString().padStart(2, \'0\')\\n    }));\\n    loading.value = false;\\n  }, 500);\\n};\\n\\nconst handleTableChange = (pag) => {\\n  pagination.current = pag.current;\\n  pagination.pageSize = pag.pageSize;\\n  query.page = pag.current;\\n  query.pageSize = pag.pageSize;\\n  handleSearch();\\n};\\n\\nconst handleReset = () => {\\n  query.keyword = \'\';\\n  query.status = undefined;\\n  query.page = 1;\\n  handleSearch();\\n};\\n\\nconst handleAdd = () => {\\n  message.success(\'点击新增\');\\n};\\n\\nconst handleEdit = () => {\\n  message.success(\'点击修改\');\\n};\\n\\nconst handleBatchDelete = () => {\\n  message.error(\'点击批量删除\');\\n};\\n\\nconst handleImport = () => {\\n  message.success(\'点击导入\');\\n};\\n\\nconst handleExport = () => {\\n  message.success(\'点击导出\');\\n};\\n\\nconst handleRefresh = () => {\\n  handleSearch();\\n};\\n\\nonMounted(() => {\\n  handleSearch();\\n});\",\"css\":\"\"}', '[]', '招聘需求列表页', '2025-12-28 17:49:54.074864', '2025-12-28 21:25:33.040162');

-- ----------------------------
-- Table structure for project_attachments
-- ----------------------------
DROP TABLE IF EXISTS `project_attachments`;
CREATE TABLE `project_attachments`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `taskId` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `project_code` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `url` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `uploadDate` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of project_attachments
-- ----------------------------
INSERT INTO `project_attachments` VALUES ('a1', 't1_1', 'PRJ-2024-001', '项目章程.pdf', '#', 'pdf', '2023-12-23 00:00:00.000000');
INSERT INTO `project_attachments` VALUES ('a1767202033775', 't1766980097523', 'crrc-2025', '基于数据分析平台接口开发技术研究技术条件20251231.docx', '/pm/project/crrc-2025/t1766980097523/%E5%9F%BA%E4%BA%8E%E6%95%B0%E6%8D%AE%E5%88%86%E6%9E%90%E5%B9%B3%E5%8F%B0%E6%8E%A5%E5%8F%A3%E5%BC%80%E5%8F%91%E6%8A%80%E6%9C%AF%E7%A0%94%E7%A9%B6%E6%8A%80%E6%9C%AF%E6%9D%A1%E4%BB%B620251231.docx', 'file', '2025-12-28 00:00:00.000000');
INSERT INTO `project_attachments` VALUES ('a1767493382440', 't1767493010615', 'crrc-2025', '工作流疑问(1).docx', '/pm/project/crrc-2025/t1767493010615/%E5%B7%A5%E4%BD%9C%E6%B5%81%E7%96%91%E9%97%AE(1).docx', 'file', '2026-01-02 00:00:00.000000');
INSERT INTO `project_attachments` VALUES ('a2', 't1_1', 'PRJ-2024-001', '需求规格说明书_v1.0.docx', '#', 'doc', '2023-12-26 00:00:00.000000');
INSERT INTO `project_attachments` VALUES ('a3', 't1_2', 'PRJ-2024-001', '总体方案汇报.pptx', '#', 'ppt', '2024-01-10 00:00:00.000000');

-- ----------------------------
-- Table structure for project_info
-- ----------------------------
DROP TABLE IF EXISTS `project_info`;
CREATE TABLE `project_info`  (
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `manager` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `planned_start_date` datetime(6) NULL DEFAULT NULL,
  `planned_end_date` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of project_info
-- ----------------------------
INSERT INTO `project_info` VALUES ('1111', '地铁车辆设计项目', NULL, NULL, '张三', '2026-01-04 00:00:00.000000', '2026-01-31 00:00:00.000000');
INSERT INTO `project_info` VALUES ('crrc-2025', '多维数据分析平台2025', '通用', '', '', '2025-10-31 00:00:00.000000', NULL);
INSERT INTO `project_info` VALUES ('PRJ-2024-001', '地铁车辆设计项目', '车辆工程', '地铁车辆全生命周期设计项目', '张三', '2023-12-22 00:00:00.000000', '2024-12-21 00:00:00.000000');
INSERT INTO `project_info` VALUES ('xxxx', '地铁车辆设计项目_copy', NULL, NULL, '张三', '2026-01-08 00:00:00.000000', NULL);
INSERT INTO `project_info` VALUES ('yyyy', '地铁车辆设计项目_copy', NULL, NULL, '张三', '2026-01-10 00:00:00.000000', '2026-02-06 00:00:00.000000');

-- ----------------------------
-- Table structure for project_phases
-- ----------------------------
DROP TABLE IF EXISTS `project_phases`;
CREATE TABLE `project_phases`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `project_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `color` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`id`, `project_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of project_phases
-- ----------------------------
INSERT INTO `project_phases` VALUES ('p1', '1111', '概念设计阶段', '#E3F2FD');
INSERT INTO `project_phases` VALUES ('p1', 'crrc-2025', '2026-01', '#E3F2FD');
INSERT INTO `project_phases` VALUES ('p1', 'PRJ-2024-001', '概念设计阶段', '#E3F2FD');
INSERT INTO `project_phases` VALUES ('p1', 'xxxx', '概念设计阶段', '#E3F2FD');
INSERT INTO `project_phases` VALUES ('p1', 'yyyy', '概念设计阶段', '#E3F2FD');
INSERT INTO `project_phases` VALUES ('p1766984086654', 'crrc-2025', '2026-02', '#e1feef');
INSERT INTO `project_phases` VALUES ('p1766984103220', 'crrc-2025', '2026-03', '#F5F5F5');
INSERT INTO `project_phases` VALUES ('p1766984110676', 'crrc-2025', '2026-04', '#F5F5F5');
INSERT INTO `project_phases` VALUES ('p1766984123106', 'crrc-2025', '2026-05', '#F5F5F5');
INSERT INTO `project_phases` VALUES ('p1766984133676', 'crrc-2025', '2026-06', '#F5F5F5');
INSERT INTO `project_phases` VALUES ('p2', '1111', '方案设计阶段', '#E8F5E9');
INSERT INTO `project_phases` VALUES ('p2', 'PRJ-2024-001', '方案设计阶段', '#E8F5E9');
INSERT INTO `project_phases` VALUES ('p2', 'xxxx', '方案设计阶段', '#E8F5E9');
INSERT INTO `project_phases` VALUES ('p2', 'yyyy', '方案设计阶段', '#E8F5E9');
INSERT INTO `project_phases` VALUES ('p3', '1111', '详细设计阶段', '#FFF3E0');
INSERT INTO `project_phases` VALUES ('p3', 'PRJ-2024-001', '详细设计阶段', '#FFF3E0');
INSERT INTO `project_phases` VALUES ('p3', 'xxxx', '详细设计阶段', '#FFF3E0');
INSERT INTO `project_phases` VALUES ('p3', 'yyyy', '详细设计阶段', '#FFF3E0');
INSERT INTO `project_phases` VALUES ('p4', '1111', '设计验证阶段', '#F3E5F5');
INSERT INTO `project_phases` VALUES ('p4', 'PRJ-2024-001', '设计验证阶段', '#F3E5F5');
INSERT INTO `project_phases` VALUES ('p4', 'xxxx', '设计验证阶段', '#F3E5F5');
INSERT INTO `project_phases` VALUES ('p4', 'yyyy', '设计验证阶段', '#F3E5F5');

-- ----------------------------
-- Table structure for project_swimlanes
-- ----------------------------
DROP TABLE IF EXISTS `project_swimlanes`;
CREATE TABLE `project_swimlanes`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `project_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `color` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`id`, `project_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of project_swimlanes
-- ----------------------------
INSERT INTO `project_swimlanes` VALUES ('sl1', '1111', '项目管理', '#F5F5F5');
INSERT INTO `project_swimlanes` VALUES ('sl1', 'crrc-2025', '任务', '#3d4a8a');
INSERT INTO `project_swimlanes` VALUES ('sl1', 'PRJ-2024-001', '项目管理', '#F5F5F5');
INSERT INTO `project_swimlanes` VALUES ('sl1', 'xxxx', '项目管理', '#F5F5F5');
INSERT INTO `project_swimlanes` VALUES ('sl1', 'yyyy', '项目管理', '#F5F5F5');
INSERT INTO `project_swimlanes` VALUES ('sl1767086258904', 'crrc-2025', 'bug', '#ffcccc');
INSERT INTO `project_swimlanes` VALUES ('sl1767144942000', 'crrc-2025', '后端', '#46eca4');
INSERT INTO `project_swimlanes` VALUES ('sl1767144988697', 'crrc-2025', '前端', '#b8f3ff');
INSERT INTO `project_swimlanes` VALUES ('sl1767146103244', 'crrc-2025', '大屏', '#62bcba');
INSERT INTO `project_swimlanes` VALUES ('sl2', '1111', '机械设计专业', '#E1F5FE');
INSERT INTO `project_swimlanes` VALUES ('sl2', 'PRJ-2024-001', '机械设计专业', '#E1F5FE');
INSERT INTO `project_swimlanes` VALUES ('sl2', 'xxxx', '机械设计专业', '#E1F5FE');
INSERT INTO `project_swimlanes` VALUES ('sl2', 'yyyy', '机械设计专业', '#E1F5FE');
INSERT INTO `project_swimlanes` VALUES ('sl3', '1111', '电气设计专业', '#FFF3E0');
INSERT INTO `project_swimlanes` VALUES ('sl3', 'PRJ-2024-001', '电气设计专业', '#FFF3E0');
INSERT INTO `project_swimlanes` VALUES ('sl3', 'xxxx', '电气设计专业', '#FFF3E0');
INSERT INTO `project_swimlanes` VALUES ('sl3', 'yyyy', '电气设计专业', '#FFF3E0');
INSERT INTO `project_swimlanes` VALUES ('sl4', '1111', '软件与控制专业', '#E8F5E9');
INSERT INTO `project_swimlanes` VALUES ('sl4', 'PRJ-2024-001', '软件与控制专业', '#E8F5E9');
INSERT INTO `project_swimlanes` VALUES ('sl4', 'xxxx', '软件与控制专业', '#E8F5E9');
INSERT INTO `project_swimlanes` VALUES ('sl4', 'yyyy', '软件与控制专业', '#E8F5E9');
INSERT INTO `project_swimlanes` VALUES ('sl5', '1111', '工业设计专业', '#F3E5F5');
INSERT INTO `project_swimlanes` VALUES ('sl5', 'PRJ-2024-001', '工业设计专业', '#F3E5F5');
INSERT INTO `project_swimlanes` VALUES ('sl5', 'xxxx', '工业设计专业', '#F3E5F5');
INSERT INTO `project_swimlanes` VALUES ('sl5', 'yyyy', '工业设计专业', '#F3E5F5');
INSERT INTO `project_swimlanes` VALUES ('sl6', '1111', '系统集成与验证', '#EFEBE9');
INSERT INTO `project_swimlanes` VALUES ('sl6', 'PRJ-2024-001', '系统集成与验证', '#EFEBE9');
INSERT INTO `project_swimlanes` VALUES ('sl6', 'xxxx', '系统集成与验证', '#EFEBE9');
INSERT INTO `project_swimlanes` VALUES ('sl6', 'yyyy', '系统集成与验证', '#EFEBE9');
INSERT INTO `project_swimlanes` VALUES ('sl7', '1111', '质量管理', '#FFEBEE');
INSERT INTO `project_swimlanes` VALUES ('sl7', 'PRJ-2024-001', '质量管理', '#FFEBEE');
INSERT INTO `project_swimlanes` VALUES ('sl7', 'xxxx', '质量管理', '#FFEBEE');
INSERT INTO `project_swimlanes` VALUES ('sl7', 'yyyy', '质量管理', '#FFEBEE');

-- ----------------------------
-- Table structure for project_task_dependencies
-- ----------------------------
DROP TABLE IF EXISTS `project_task_dependencies`;
CREATE TABLE `project_task_dependencies`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `taskId` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `dependencyId` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `project_code` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `sourcePort` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `targetPort` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `controlPoints` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `controlPointCount` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6325 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of project_task_dependencies
-- ----------------------------
INSERT INTO `project_task_dependencies` VALUES (4450, 't1_2', 't1_1', 'PRJ-2024-001', 'curve', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4451, 't1_3', 't1_2', 'PRJ-2024-001', 'polyline', 'top', 'bottom', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4452, 't2_1', 't1_3', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4453, 't2_10', 't1_3', 'PRJ-2024-001', 'curve', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4454, 't2_2', 't1_3', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4455, 't2_3', 't1_3', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4456, 't2_4', 't1_3', 'PRJ-2024-001', 'curve', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4457, 't2_5', 't1_3', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4458, 't2_6', 't1_3', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4459, 't2_7', 't1_3', 'PRJ-2024-001', 'curve', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4460, 't2_8', 't1_3', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4461, 't2_9', 't1_3', 'PRJ-2024-001', 'curve', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4462, 't3_1', 't2_1', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4463, 't3_10', 't2_1', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4464, 't3_10', 't2_4', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4465, 't3_11', 't3_1', 'PRJ-2024-001', 'curve', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4466, 't3_11', 't3_4', 'PRJ-2024-001', 'curve', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4467, 't3_2', 't2_2', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4468, 't3_3', 't2_10', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4469, 't3_4', 't2_4', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4470, 't3_5', 't2_6', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4471, 't3_6', 't2_6', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4472, 't3_7', 't2_8', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4473, 't3_8', 't2_8', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4474, 't3_9', 't2_7', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4475, 't4_1', 't3_1', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4476, 't4_1', 't3_4', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4477, 't4_2', 't4_1', 'PRJ-2024-001', 'curve', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4478, 't4_3', 't4_1', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4479, 't4_4', 't4_3', 'PRJ-2024-001', 'curve', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4480, 't4_5', 't4_4', 'PRJ-2024-001', 'curve', 'left', 'right', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (4481, 't4_6', 't4_5', 'PRJ-2024-001', 'curve', 'top', 'bottom', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6220, 't1_3', 't1_2', 'xxxx', 'polyline', 'top', 'bottom', '[{\"x\":0,\"y\":-20},{\"x\":0.44141975308605197,\"y\":-329.5020987654323},{\"x\":155,\"y\":-450}]', NULL);
INSERT INTO `project_task_dependencies` VALUES (6221, 't1765987308084', 't2_9', 'xxxx', 'polyline', 'left', 'right', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6222, 't2_1', 't1_3', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6223, 't2_10', 't1_3', 'xxxx', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6224, 't2_2', 't1_3', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6225, 't2_3', 't1_3', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6226, 't2_4', 't1_3', 'xxxx', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6227, 't2_5', 't1_3', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6228, 't2_6', 't1_3', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6229, 't2_7', 't1_3', 'xxxx', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6230, 't2_8', 't1_3', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6231, 't2_9', 't1_3', 'xxxx', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6232, 't3_10', 't2_1', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6233, 't3_10', 't2_4', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6234, 't3_11', 't3_1', 'xxxx', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6235, 't3_11', 't3_4', 'xxxx', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6236, 't3_3', 't2_10', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6237, 't4_1', 't3_1', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6238, 't4_1', 't3_4', 'xxxx', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6239, 't4_5', 't4_4', 'xxxx', 'polyline', 'left', 'right', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6240, 't4_6', 't4_5', 'xxxx', 'polyline', 'top', 'bottom', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6262, 't1_3', 't1_2', '1111', 'polyline', 'top', 'bottom', '[{\"x\":0,\"y\":-20},{\"x\":0.44141975308605197,\"y\":-329.5020987654323},{\"x\":155,\"y\":-450}]', NULL);
INSERT INTO `project_task_dependencies` VALUES (6263, 't1765987308084', 't2_9', '1111', 'polyline', 'left', 'right', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6264, 't2_1', 't1_3', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6265, 't2_10', 't1_3', '1111', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6266, 't2_2', 't1_3', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6267, 't2_3', 't1_3', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6268, 't2_4', 't1_3', '1111', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6269, 't2_5', 't1_3', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6270, 't2_6', 't1_3', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6271, 't2_7', 't1_3', '1111', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6272, 't2_8', 't1_3', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6273, 't2_9', 't1_3', '1111', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6274, 't3_10', 't2_1', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6275, 't3_10', 't2_4', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6276, 't3_11', 't3_1', '1111', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6277, 't3_11', 't3_4', '1111', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6278, 't3_3', 't2_10', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6279, 't4_1', 't3_1', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6280, 't4_1', 't3_4', '1111', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6281, 't4_5', 't4_4', '1111', 'polyline', 'left', 'right', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6282, 't4_6', 't4_5', '1111', 'polyline', 'top', 'bottom', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6304, 't1_3', 't1_2', 'yyyy', 'polyline', 'top', 'bottom', '[{\"x\":0,\"y\":-20},{\"x\":0.44141975308605197,\"y\":-329.5020987654323},{\"x\":155,\"y\":-450}]', NULL);
INSERT INTO `project_task_dependencies` VALUES (6305, 't1765987308084', 't2_9', 'yyyy', 'polyline', 'left', 'right', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6306, 't2_1', 't1_3', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6307, 't2_10', 't1_3', 'yyyy', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6308, 't2_2', 't1_3', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6309, 't2_3', 't1_3', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6310, 't2_4', 't1_3', 'yyyy', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6311, 't2_5', 't1_3', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6312, 't2_6', 't1_3', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6313, 't2_7', 't1_3', 'yyyy', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6314, 't2_8', 't1_3', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6315, 't2_9', 't1_3', 'yyyy', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6316, 't3_10', 't2_1', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6317, 't3_10', 't2_4', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6318, 't3_11', 't3_1', 'yyyy', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6319, 't3_11', 't3_4', 'yyyy', 'polyline', 'bottom', 'top', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6320, 't3_3', 't2_10', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6321, 't4_1', 't3_1', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6322, 't4_1', 't3_4', 'yyyy', 'polyline', 'right', 'left', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6323, 't4_5', 't4_4', 'yyyy', 'polyline', 'left', 'right', NULL, 0);
INSERT INTO `project_task_dependencies` VALUES (6324, 't4_6', 't4_5', 'yyyy', 'polyline', 'top', 'bottom', NULL, 0);

-- ----------------------------
-- Table structure for project_tasks
-- ----------------------------
DROP TABLE IF EXISTS `project_tasks`;
CREATE TABLE `project_tasks`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `project_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `phaseId` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `swimlaneId` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `status` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `progress` int NOT NULL,
  `owner` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `startDate` datetime(6) NULL DEFAULT NULL,
  `endDate` datetime(6) NULL DEFAULT NULL,
  `type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `startColor` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `endColor` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `width` float NOT NULL,
  PRIMARY KEY (`id`, `project_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of project_tasks
-- ----------------------------
INSERT INTO `project_tasks` VALUES ('t1_1', '1111', '项目启动与需求分析', 'p1', 'sl1', 'completed', 100, '项目经理', '2023-12-30 00:00:00.000000', '2024-01-08 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_1', 'PRJ-2024-001', '项目启动与需求分析', 'p1', 'sl1', 'completed', 100, '项目经理', '2023-12-22 00:00:00.000000', '2024-01-01 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_1', 'xxxx', '项目启动与需求分析', 'p1', 'sl1', 'completed', 100, '项目经理', '2023-12-30 00:00:00.000000', '2024-01-08 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_1', 'yyyy', '项目启动与需求分析', 'p1', 'sl1', 'completed', 100, '项目经理', '2024-01-05 00:00:00.000000', '2024-01-14 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_2', '1111', '总体方案设计', 'p1', 'sl6', 'completed', 100, '总工', '2024-01-09 00:00:00.000000', '2024-01-23 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_2', 'PRJ-2024-001', '总体方案设计', 'p1', 'sl6', 'completed', 100, '总工', '2024-01-01 00:00:00.000000', '2024-01-09 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_2', 'xxxx', '总体方案设计', 'p1', 'sl6', 'completed', 100, '总工', '2024-01-09 00:00:00.000000', '2024-01-23 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_2', 'yyyy', '总体方案设计', 'p1', 'sl6', 'completed', 100, '总工', '2024-01-15 00:00:00.000000', '2024-01-29 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_3', '1111', '概念评审与冻结', 'p1', 'sl1', 'completed', 100, '项目经理', '2024-01-18 00:00:00.000000', '2024-01-25 00:00:00.000000', 'milestone', NULL, 174.203, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_3', 'PRJ-2024-001', '概念评审与冻结', 'p1', 'sl1', 'completed', 64, '项目经理', '2024-01-15 00:00:00.000000', '2024-01-19 00:00:00.000000', 'milestone', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_3', 'xxxx', '概念评审与冻结', 'p1', 'sl1', 'completed', 100, '项目经理', '2024-01-18 00:00:00.000000', '2024-01-25 00:00:00.000000', 'milestone', NULL, 174.203, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1_3', 'yyyy', '概念评审与冻结', 'p1', 'sl1', 'completed', 100, '项目经理', '2024-01-24 00:00:00.000000', '2024-01-31 00:00:00.000000', 'milestone', NULL, 174.203, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1765987308084', '1111', '新任务', 'p1', 'sl7', 'in_progress', 45, '我', '2025-12-09 00:00:00.000000', '2025-12-16 00:00:00.000000', 'task', NULL, 68, 13, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1765987308084', 'xxxx', '新任务', 'p1', 'sl7', 'in_progress', 45, '我', '2025-12-09 00:00:00.000000', '2025-12-16 00:00:00.000000', 'task', NULL, 68, 13, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1765987308084', 'yyyy', '新任务', 'p1', 'sl7', 'in_progress', 45, '我', '2025-12-15 00:00:00.000000', '2025-12-22 00:00:00.000000', 'task', NULL, 68, 13, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1766980097523', 'crrc-2025', '项目需求-需求文件', 'p1', 'sl1', 'completed', 100, '饶荣', '2025-11-01 00:00:00.000000', '2025-11-06 00:00:00.000000', 'task', '', 60, 15, '#ffffff', '#B3E5FC', 140);
INSERT INTO `project_tasks` VALUES ('t1767059425440', 'crrc-2025', '文件数据自定义裁剪', 'p1', 'sl1767146103244', 'pending', 0, '范新悦', '2025-10-26 00:00:00.000000', '2025-10-31 00:00:00.000000', 'task', '修改自定义高级地图', 104.622, 23.2085, '#F3E5F5', '#ECA9F8FF', 144.514);
INSERT INTO `project_tasks` VALUES ('t1767059614944', 'crrc-2025', '数据展示由后端生成图片', 'p1766984086654', 'sl1767146103244', 'pending', 0, '黄亮', '2025-11-02 00:00:00.000000', '2025-11-06 00:00:00.000000', 'task', '', 93.6673, 23.2085, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767059627136', 'crrc-2025', '算子添加自定义配置项', 'p1766984133676', 'sl1767144942000', 'pending', 0, '', '2025-10-30 00:00:00.000000', '2025-11-05 00:00:00.000000', 'task', '', 43.5673, 22.988, '#ffffff', '#B3E5FC', 140);
INSERT INTO `project_tasks` VALUES ('t1767059628865', 'crrc-2025', '新增回收站机制', 'p1766984103220', 'sl1767144988697', 'pending', 9, '黄亮', '2025-11-02 00:00:00.000000', '2025-11-05 00:00:00.000000', 'task', '', 62.5774, 21.954, '#FFEBEE', '#EF5350', 140);
INSERT INTO `project_tasks` VALUES ('t1767059630624', 'crrc-2025', '报告模版在线编辑', 'p1', 'sl1767144988697', 'pending', 0, '黄亮', '2025-11-02 00:00:00.000000', '2025-11-06 00:00:00.000000', 'task', '', 106.879, 21.954, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767059645544', 'crrc-2025', '车辆数据溯源', 'p1', 'sl1767144942000', 'pending', 0, '待定', '2025-11-01 00:00:00.000000', '2025-11-05 00:00:00.000000', 'task', '各种数据和车辆之间的关系', 277.685, 22.988, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767059647128', 'crrc-2025', '提供快速获取结果数据API接口', 'p1766984110676', 'sl1767144942000', 'pending', 0, '王子恒', '2025-10-31 00:00:00.000000', '2025-11-05 00:00:00.000000', 'task', '', 32.0539, 22.988, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767086268029', 'crrc-2025', '文件保存节点保存csv格式为doris存储格式', 'p1766984086654', 'sl1767144942000', 'pending', 15, '待定', '2026-02-16 00:00:00.000000', '2026-02-22 00:00:00.000000', 'task', '', 23.6673, 22.988, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767086305845', 'crrc-2025', '文件保存节点没有保存tdms文件代码', 'p1766984086654', 'sl1767144942000', 'pending', 0, '待定', '2025-11-10 00:00:00.000000', '2025-11-15 00:00:00.000000', 'task', '', 201.045, 22.988, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767086331997', 'crrc-2025', 'AI助手优化代码报错(token too lager for edit)', 'p1', 'sl1767086258904', 'pending', 0, '待定', '2025-11-19 00:00:00.000000', '2025-11-25 00:00:00.000000', 'task', '', 60, 25.6625, NULL, NULL, 186.879);
INSERT INTO `project_tasks` VALUES ('t1767086356700', 'crrc-2025', '在线debug失败', 'p1', 'sl1767086258904', 'pending', 0, '待定', '2025-11-15 00:00:00.000000', '2025-11-20 00:00:00.000000', 'task', '', 277.685, 25.6625, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767086385356', 'crrc-2025', '提供文件保存方法', 'p1', 'sl1767144942000', 'pending', 0, '待定', '2025-11-07 00:00:00.000000', '2025-11-11 00:00:00.000000', 'task', '通过文件保存方法自定义保存文件(文件类型未知)', 57.685, 22.988, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767086575965', 'crrc-2025', '高级图表支持工作流文件保存节点的文件', 'p1766984103220', 'sl1767146103244', 'pending', 0, '黄亮', '2025-11-07 00:00:00.000000', '2025-11-12 00:00:00.000000', 'task', '工作流添加tdms数据', 49.5235, 23.2085, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767147161314', 'crrc-2025', '算子添加自定义配置项', 'p1766984086654', 'sl1767144988697', 'pending', 0, '黄亮', '2025-12-10 00:00:00.000000', '2025-12-13 00:00:00.000000', 'task', '', 93.6673, 21.954, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767147346473', 'crrc-2025', '车辆数据溯源', 'p1766984110676', 'sl1767144988697', 'pending', 0, '黄亮', '2025-12-10 00:00:00.000000', '2025-12-12 00:00:00.000000', 'task', '', 70, 21.954, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767493010615', 'crrc-2025', '错误日志只有一个No match found，报错信息较为抽象', 'p1766984086654', 'sl1767086258904', 'pending', 0, '待定', '2026-01-03 00:00:00.000000', '2026-01-05 00:00:00.000000', 'task', '错误日志只有一个No match found，报错信息较为抽象\n在某些语句报错时，直接没有日志。现在算子如下，可以看到是运行异常的状态\n', 23.6673, 25.6625, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767493098019', 'crrc-2025', '当执行完流程实例后，就没有左侧的抽屉了', 'p1766984086654', 'sl1767086258904', 'pending', 0, '待定', '2026-01-02 00:00:00.000000', '2026-01-02 00:00:00.000000', 'task', '当执行完流程实例后，就没有左侧的抽屉了。但是这个设计器界面是和编辑界面是一致的，运行完却不能编辑了，会产生割裂感，要么把这个勾勾叉叉都放到实例中，要么开放编辑权限，方便继续运行', 201.045, 25.6625, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767493462405', 'crrc-2025', '不能在main函数名的同一行加注释', 'p1766984103220', 'sl1767086258904', 'pending', 0, '待定', '2026-01-02 00:00:00.000000', '2026-01-02 00:00:00.000000', 'task', NULL, 49.5235, 25.6625, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767493793444', 'crrc-2025', '在输入是list的情况下，代码中仍然使用dict的方式获取数据：', 'p1766984110676', 'sl1767086258904', 'pending', 0, '待定', '2026-01-02 00:00:00.000000', '2026-01-02 00:00:00.000000', 'task', '本应该报错的，实际上没有任何报错【bug】', 0, 25.6625, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t1767493942360', 'crrc-2025', '只有当右击标签页-重新加载的时候才会正常显示（不过勾勾叉叉都消失了）', 'p1766984123106', 'sl1767086258904', 'pending', 0, '待定', '2026-01-02 00:00:00.000000', '2026-01-02 00:00:00.000000', 'task', '用起来太不方便【待优化】', 0, 25.6625, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_1', '1111', '车体方案设计', 'p2', 'sl2', 'completed', 100, '张工', '2024-01-30 00:00:00.000000', '2024-02-18 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_1', 'PRJ-2024-001', '车体方案设计', 'p2', 'sl2', 'completed', 100, '张工', '2024-01-23 00:00:00.000000', '2024-02-11 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_1', 'xxxx', '车体方案设计', 'p2', 'sl2', 'completed', 100, '张工', '2024-01-30 00:00:00.000000', '2024-02-18 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_1', 'yyyy', '车体方案设计', 'p2', 'sl2', 'completed', 100, '张工', '2024-02-05 00:00:00.000000', '2024-02-24 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_10', '1111', '内饰方案设计', 'p2', 'sl5', 'in_progress', 60, '郑工', '2024-02-13 00:00:00.000000', '2024-03-08 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_10', 'PRJ-2024-001', '内饰方案设计', 'p2', 'sl5', 'in_progress', 60, '郑工', '2024-02-05 00:00:00.000000', '2024-02-29 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_10', 'xxxx', '内饰方案设计', 'p2', 'sl5', 'in_progress', 60, '郑工', '2024-02-13 00:00:00.000000', '2024-03-08 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_10', 'yyyy', '内饰方案设计', 'p2', 'sl5', 'in_progress', 60, '郑工', '2024-02-19 00:00:00.000000', '2024-03-14 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_2', '1111', '转向架方案', 'p2', 'sl2', 'completed', 100, '陈工', '2024-01-30 00:00:00.000000', '2026-01-31 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_2', 'PRJ-2024-001', '转向架方案', 'p2', 'sl2', 'completed', 100, '陈工', '2024-01-22 00:00:00.000000', '2024-02-15 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_2', 'xxxx', '转向架方案', 'p2', 'sl2', 'completed', 100, '陈工', '2024-01-30 00:00:00.000000', '2026-01-31 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_2', 'yyyy', '转向架方案', 'p2', 'sl2', 'completed', 100, '陈工', '2024-02-05 00:00:00.000000', '2026-02-06 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_3', '1111', '连接装置设计', 'p2', 'sl2', 'completed', 100, '王工', '2024-02-03 00:00:00.000000', '2024-02-18 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_3', 'PRJ-2024-001', '连接装置设计', 'p2', 'sl2', 'completed', 100, '王工', '2024-01-26 00:00:00.000000', '2024-02-10 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_3', 'xxxx', '连接装置设计', 'p2', 'sl2', 'completed', 100, '王工', '2024-02-03 00:00:00.000000', '2024-02-18 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_3', 'yyyy', '连接装置设计', 'p2', 'sl2', 'completed', 100, '王工', '2024-02-09 00:00:00.000000', '2024-02-24 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_4', '1111', '牵引系统方案', 'p2', 'sl3', 'in_progress', 80, '李工', '2024-01-30 00:00:00.000000', '2024-02-26 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_4', 'PRJ-2024-001', '牵引系统方案', 'p2', 'sl3', 'in_progress', 80, '李工', '2024-01-22 00:00:00.000000', '2024-02-18 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_4', 'xxxx', '牵引系统方案', 'p2', 'sl3', 'in_progress', 80, '李工', '2024-01-30 00:00:00.000000', '2024-02-26 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_4', 'yyyy', '牵引系统方案', 'p2', 'sl3', 'in_progress', 80, '李工', '2024-02-05 00:00:00.000000', '2024-03-03 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_5', '1111', '辅助供电系统', 'p2', 'sl3', 'in_progress', 70, '周工', '2024-02-03 00:00:00.000000', '2024-02-23 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_5', 'PRJ-2024-001', '辅助供电系统', 'p2', 'sl3', 'in_progress', 70, '周工', '2024-01-26 00:00:00.000000', '2024-02-15 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_5', 'xxxx', '辅助供电系统', 'p2', 'sl3', 'in_progress', 70, '周工', '2024-02-03 00:00:00.000000', '2024-02-23 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_5', 'yyyy', '辅助供电系统', 'p2', 'sl3', 'in_progress', 70, '周工', '2024-02-09 00:00:00.000000', '2024-02-29 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_6', '1111', '车载电气布置', 'p2', 'sl3', 'pending', 0, '吴工', '2024-02-08 00:00:00.000000', '2024-02-28 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_6', 'PRJ-2024-001', '车载电气布置', 'p2', 'sl3', 'pending', 0, '吴工', '2024-01-31 00:00:00.000000', '2024-02-20 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_6', 'xxxx', '车载电气布置', 'p2', 'sl3', 'pending', 0, '吴工', '2024-02-08 00:00:00.000000', '2024-02-28 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_6', 'yyyy', '车载电气布置', 'p2', 'sl3', 'pending', 0, '吴工', '2024-02-14 00:00:00.000000', '2024-03-05 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_7', '1111', '网络控制系统方案', 'p2', 'sl4', 'in_progress', 50, '赵工', '2024-01-30 00:00:00.000000', '2024-02-26 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_7', 'PRJ-2024-001', '网络控制系统方案', 'p2', 'sl4', 'in_progress', 50, '赵工', '2024-01-22 00:00:00.000000', '2024-02-18 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_7', 'xxxx', '网络控制系统方案', 'p2', 'sl4', 'in_progress', 50, '赵工', '2024-01-30 00:00:00.000000', '2024-02-26 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_7', 'yyyy', '网络控制系统方案', 'p2', 'sl4', 'in_progress', 50, '赵工', '2024-02-05 00:00:00.000000', '2024-03-03 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_8', '1111', '车载软件框架', 'p2', 'sl4', 'pending', 0, '钱工', '2024-02-08 00:00:00.000000', '2024-03-03 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_8', 'PRJ-2024-001', '车载软件框架', 'p2', 'sl4', 'pending', 0, '钱工', '2024-01-31 00:00:00.000000', '2024-02-24 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_8', 'xxxx', '车载软件框架', 'p2', 'sl4', 'pending', 0, '钱工', '2024-02-08 00:00:00.000000', '2024-03-03 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_8', 'yyyy', '车载软件框架', 'p2', 'sl4', 'pending', 0, '钱工', '2024-02-14 00:00:00.000000', '2024-03-09 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_9', '1111', '外观造型设计', 'p2', 'sl5', 'completed', 100, '孙工', '2024-01-30 00:00:00.000000', '2024-02-18 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_9', 'PRJ-2024-001', '外观造型设计', 'p2', 'sl5', 'completed', 100, '孙工', '2024-01-22 00:00:00.000000', '2024-02-10 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_9', 'xxxx', '外观造型设计', 'p2', 'sl5', 'completed', 100, '孙工', '2024-01-30 00:00:00.000000', '2024-02-18 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t2_9', 'yyyy', '外观造型设计', 'p2', 'sl5', 'completed', 100, '孙工', '2024-02-05 00:00:00.000000', '2024-02-24 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_1', '1111', '车体详细设计', 'p3', 'sl2', 'pending', 0, '张工', '2024-02-28 00:00:00.000000', '2024-04-28 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_1', 'PRJ-2024-001', '车体详细设计', 'p3', 'sl2', 'pending', 0, '张工', '2024-02-20 00:00:00.000000', '2024-04-20 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_1', 'xxxx', '车体详细设计', 'p3', 'sl2', 'pending', 0, '张工', '2024-02-28 00:00:00.000000', '2024-04-28 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_1', 'yyyy', '车体详细设计', 'p3', 'sl2', 'pending', 0, '张工', '2024-03-05 00:00:00.000000', '2024-05-04 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_10', '1111', '机电接口设计', 'p3', 'sl6', 'pending', 0, '总工', '2024-02-28 00:00:00.000000', '2024-03-30 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_10', 'PRJ-2024-001', '机电接口设计', 'p3', 'sl6', 'pending', 0, '总工', '2024-02-20 00:00:00.000000', '2024-03-22 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_10', 'xxxx', '机电接口设计', 'p3', 'sl6', 'pending', 0, '总工', '2024-02-28 00:00:00.000000', '2024-03-30 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_10', 'yyyy', '机电接口设计', 'p3', 'sl6', 'pending', 0, '总工', '2024-03-05 00:00:00.000000', '2024-04-05 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_11', '1111', 'BOM清单编制', 'p3', 'sl6', 'pending', 0, '管理员', '2024-04-29 00:00:00.000000', '2024-05-28 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_11', 'PRJ-2024-001', 'BOM清单编制', 'p3', 'sl6', 'pending', 0, '管理员', '2024-04-21 00:00:00.000000', '2024-05-20 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_11', 'xxxx', 'BOM清单编制', 'p3', 'sl6', 'pending', 0, '管理员', '2024-04-29 00:00:00.000000', '2024-05-28 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_11', 'yyyy', 'BOM清单编制', 'p3', 'sl6', 'pending', 0, '管理员', '2024-05-05 00:00:00.000000', '2024-06-03 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_2', '1111', '转向架详细设计转向架详细设计转向架详细设计转向架详细设计转向架详细设计', 'p3', 'sl2', 'pending', 0, '陈工', '2024-02-28 00:00:00.000000', '2024-05-13 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_2', 'PRJ-2024-001', '转向架详细设计', 'p3', 'sl2', 'pending', 0, '陈工', '2024-02-20 00:00:00.000000', '2024-05-05 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_2', 'xxxx', '转向架详细设计转向架详细设计转向架详细设计转向架详细设计转向架详细设计', 'p3', 'sl2', 'pending', 0, '陈工', '2024-02-28 00:00:00.000000', '2024-05-13 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_2', 'yyyy', '转向架详细设计转向架详细设计转向架详细设计转向架详细设计转向架详细设计', 'p3', 'sl2', 'pending', 0, '陈工', '2024-03-05 00:00:00.000000', '2024-05-19 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_3', '1111', '内装详细设计', 'p3', 'sl2', 'pending', 0, '郑工', '2024-03-13 00:00:00.000000', '2024-04-29 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_3', 'PRJ-2024-001', '内装详细设计', 'p3', 'sl2', 'pending', 0, '郑工', '2024-03-05 00:00:00.000000', '2024-04-21 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_3', 'xxxx', '内装详细设计', 'p3', 'sl2', 'pending', 0, '郑工', '2024-03-13 00:00:00.000000', '2024-04-29 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_3', 'yyyy', '内装详细设计', 'p3', 'sl2', 'pending', 0, '郑工', '2024-03-19 00:00:00.000000', '2024-05-05 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_4', '1111', '电气原理设计', 'p3', 'sl3', 'pending', 0, '李工', '2024-02-28 00:00:00.000000', '2024-04-13 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_4', 'PRJ-2024-001', '电气原理设计', 'p3', 'sl3', 'pending', 0, '李工', '2024-02-20 00:00:00.000000', '2024-04-05 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_4', 'xxxx', '电气原理设计', 'p3', 'sl3', 'pending', 0, '李工', '2024-02-28 00:00:00.000000', '2024-04-13 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_4', 'yyyy', '电气原理设计', 'p3', 'sl3', 'pending', 0, '李工', '2024-03-05 00:00:00.000000', '2024-04-19 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_5', '1111', '线束设计', 'p3', 'sl3', 'pending', 0, '吴工', '2024-03-13 00:00:00.000000', '2024-04-29 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_5', 'PRJ-2024-001', '线束设计', 'p3', 'sl3', 'pending', 0, '吴工', '2024-03-05 00:00:00.000000', '2024-04-21 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_5', 'xxxx', '线束设计', 'p3', 'sl3', 'pending', 0, '吴工', '2024-03-13 00:00:00.000000', '2024-04-29 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_5', 'yyyy', '线束设计', 'p3', 'sl3', 'pending', 0, '吴工', '2024-03-19 00:00:00.000000', '2024-05-05 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_6', '1111', '电气柜详细设计', 'p3', 'sl3', 'pending', 0, '周工', '2024-03-08 00:00:00.000000', '2024-04-28 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_6', 'PRJ-2024-001', '电气柜详细设计', 'p3', 'sl3', 'pending', 0, '周工', '2024-02-29 00:00:00.000000', '2024-04-20 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_6', 'xxxx', '电气柜详细设计', 'p3', 'sl3', 'pending', 0, '周工', '2024-03-08 00:00:00.000000', '2024-04-28 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_6', 'yyyy', '电气柜详细设计', 'p3', 'sl3', 'pending', 0, '周工', '2024-03-14 00:00:00.000000', '2024-05-04 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_7', '1111', '软件模块设计', 'p3', 'sl4', 'pending', 0, '钱工', '2024-03-08 00:00:00.000000', '2024-05-18 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_7', 'PRJ-2024-001', '软件模块设计', 'p3', 'sl4', 'pending', 0, '钱工', '2024-02-29 00:00:00.000000', '2024-05-10 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_7', 'xxxx', '软件模块设计', 'p3', 'sl4', 'pending', 0, '钱工', '2024-03-08 00:00:00.000000', '2024-05-18 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_7', 'yyyy', '软件模块设计', 'p3', 'sl4', 'pending', 0, '钱工', '2024-03-14 00:00:00.000000', '2024-05-24 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_8', '1111', 'HMI界面设计', 'p3', 'sl4', 'pending', 0, '孙工', '2024-03-13 00:00:00.000000', '2024-04-29 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_8', 'PRJ-2024-001', 'HMI界面设计', 'p3', 'sl4', 'pending', 0, '孙工', '2024-03-05 00:00:00.000000', '2024-04-21 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_8', 'xxxx', 'HMI界面设计', 'p3', 'sl4', 'pending', 0, '孙工', '2024-03-13 00:00:00.000000', '2024-04-29 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_8', 'yyyy', 'HMI界面设计', 'p3', 'sl4', 'pending', 0, '孙工', '2024-03-19 00:00:00.000000', '2024-05-05 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_9', '1111', '通信协议实现', 'p3', 'sl4', 'pending', 0, '赵工', '2024-03-03 00:00:00.000000', '2024-04-18 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_9', 'PRJ-2024-001', '通信协议实现', 'p3', 'sl4', 'pending', 0, '赵工', '2024-02-24 00:00:00.000000', '2024-04-10 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_9', 'xxxx', '通信协议实现', 'p3', 'sl4', 'pending', 0, '赵工', '2024-03-03 00:00:00.000000', '2024-04-18 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t3_9', 'yyyy', '通信协议实现', 'p3', 'sl4', 'pending', 0, '赵工', '2024-03-09 00:00:00.000000', '2024-04-24 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_1', '1111', '仿真分析验证', 'p4', 'sl6', 'pending', 0, '仿真组', '2024-05-30 00:00:00.000000', '2024-06-29 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_1', 'PRJ-2024-001', '仿真分析验证', 'p4', 'sl6', 'pending', 0, '仿真组', '2024-05-22 00:00:00.000000', '2024-06-21 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_1', 'xxxx', '仿真分析验证', 'p4', 'sl6', 'pending', 0, '仿真组', '2024-05-30 00:00:00.000000', '2024-06-29 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_1', 'yyyy', '仿真分析验证', 'p4', 'sl6', 'pending', 0, '仿真组', '2024-06-05 00:00:00.000000', '2024-07-05 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_2', '1111', '设计评审', 'p4', 'sl7', 'pending', 0, '质量部', '2024-07-03 00:00:00.000000', '2024-07-08 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_2', 'PRJ-2024-001', '设计评审', 'p4', 'sl7', 'pending', 0, '质量部', '2024-06-25 00:00:00.000000', '2024-06-30 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_2', 'xxxx', '设计评审', 'p4', 'sl7', 'pending', 0, '质量部', '2024-07-03 00:00:00.000000', '2024-07-08 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_2', 'yyyy', '设计评审', 'p4', 'sl7', 'pending', 0, '质量部', '2024-07-09 00:00:00.000000', '2024-07-14 00:00:00.000000', 'task', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_3', '1111', '试验大纲编制', 'p4', 'sl6', 'pending', 0, '测试组', '2024-06-13 00:00:00.000000', '2024-06-28 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_3', 'PRJ-2024-001', '试验大纲编制', 'p4', 'sl6', 'pending', 0, '测试组', '2024-06-05 00:00:00.000000', '2024-06-20 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_3', 'xxxx', '试验大纲编制', 'p4', 'sl6', 'pending', 0, '测试组', '2024-06-13 00:00:00.000000', '2024-06-28 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_3', 'yyyy', '试验大纲编制', 'p4', 'sl6', 'pending', 0, '测试组', '2024-06-19 00:00:00.000000', '2024-07-04 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_4', '1111', '原型车试验', 'p4', 'sl6', 'pending', 0, '测试组', '2024-07-13 00:00:00.000000', '2024-08-28 00:00:00.000000', 'task', NULL, 362.487, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_4', 'PRJ-2024-001', '原型车试验', 'p4', 'sl6', 'pending', 0, '测试组', '2024-07-05 00:00:00.000000', '2024-08-20 00:00:00.000000', 'task', NULL, 325, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_4', 'xxxx', '原型车试验', 'p4', 'sl6', 'pending', 0, '测试组', '2024-07-13 00:00:00.000000', '2024-08-28 00:00:00.000000', 'task', NULL, 362.487, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_4', 'yyyy', '原型车试验', 'p4', 'sl6', 'pending', 0, '测试组', '2024-07-19 00:00:00.000000', '2024-09-03 00:00:00.000000', 'task', NULL, 362.487, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_5', '1111', '问题整改', 'p4', 'sl7', 'pending', 0, '各专业', '2024-08-30 00:00:00.000000', '2024-09-13 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_5', 'PRJ-2024-001', '问题整改', 'p4', 'sl7', 'pending', 0, '各专业', '2024-08-22 00:00:00.000000', '2024-09-05 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_5', 'xxxx', '问题整改', 'p4', 'sl7', 'pending', 0, '各专业', '2024-08-30 00:00:00.000000', '2024-09-13 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_5', 'yyyy', '问题整改', 'p4', 'sl7', 'pending', 0, '各专业', '2024-09-05 00:00:00.000000', '2024-09-19 00:00:00.000000', 'task', NULL, 170, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_6', '1111', '设计冻结', 'p4', 'sl1', 'pending', 0, '项目经理', '2024-09-18 00:00:00.000000', '2024-09-18 00:00:00.000000', 'milestone', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_6', 'PRJ-2024-001', '设计冻结', 'p4', 'sl1', 'pending', 0, '项目经理', '2024-09-10 00:00:00.000000', '2024-09-10 00:00:00.000000', 'milestone', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_6', 'xxxx', '设计冻结', 'p4', 'sl1', 'pending', 0, '项目经理', '2024-09-18 00:00:00.000000', '2024-09-18 00:00:00.000000', 'milestone', NULL, 15, 15, NULL, NULL, 140);
INSERT INTO `project_tasks` VALUES ('t4_6', 'yyyy', '设计冻结', 'p4', 'sl1', 'pending', 0, '项目经理', '2024-09-24 00:00:00.000000', '2024-09-24 00:00:00.000000', 'milestone', NULL, 15, 15, NULL, NULL, 140);

-- ----------------------------
-- Table structure for sales_customer
-- ----------------------------
DROP TABLE IF EXISTS `sales_customer`;
CREATE TABLE `sales_customer`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `industry` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `contact` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `owner` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sales_customer
-- ----------------------------
INSERT INTO `sales_customer` VALUES ('1ee23a0aa1a2457a9118bf60a3446871', '北京云端网络技术部', '云计算', '王工', '13700137000', 'wang@cloudnet.bj', 'A', 'high_intent', '北京市海淀区中关村', '展会', '技术负责人非常认可我们的架构', 'admin', '2025-12-30 20:48:21.933347', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_customer` VALUES ('64d6340e89dd4b8ebcda58259b789c4f', '上海未来智造有限公司', '智能制造', '李经理', '13900139000', 'li@futuremfg.com', 'B', 'existing', '上海市浦东新区张江高科', '老客户推荐', '已购买一期产品，目前在谈二期扩容', 'admin', '2025-12-25 20:48:21.933347', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_customer` VALUES ('f5d7e5e5fedb488dac443c97a275fd21', '杭州金兰科技有限公司', 'IT/互联网', '张总', '13800138000', 'zhang@jinlan.com', 'A', 'potential', '浙江省杭州市西湖区科技园', '网络推广', '对ERP系统有强烈需求，预计下月启动招标', 'admin', '2026-01-04 20:48:21.933347', '2026-01-04 20:48:21.933347');

-- ----------------------------
-- Table structure for sales_opportunity
-- ----------------------------
DROP TABLE IF EXISTS `sales_opportunity`;
CREATE TABLE `sales_opportunity`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `customer` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `amount` decimal(65, 30) NOT NULL,
  `stage` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `win_rate` int NOT NULL,
  `owner` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `estimated_close_date` datetime(6) NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sales_opportunity
-- ----------------------------
INSERT INTO `sales_opportunity` VALUES ('25d705ccf64b4c5fb46e770baf507522', '未来智造一期项目增补', '上海未来智造有限公司', '64d6340e89dd4b8ebcda58259b789c4f', 80000.000000000000000000000000000000, 'won', 100, 'admin', '增补许可授权', '2026-01-02 20:48:21.933347', '2025-12-30 20:48:21.933347', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_opportunity` VALUES ('385458562fd44e72841f9c0f666ce9a0', '未来智造CRM升级服务', '上海未来智造有限公司', '64d6340e89dd4b8ebcda58259b789c4f', 200000.000000000000000000000000000000, 'proposal', 50, 'admin', '需定制开发部分功能模块', '2026-03-04 20:48:21.933347', '2026-01-04 20:48:21.933347', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_opportunity` VALUES ('76e2661f2923457cbf63f39c348007c3', '金兰科技数据中台咨询', '杭州金兰科技有限公司', 'f5d7e5e5fedb488dac443c97a275fd21', 150000.000000000000000000000000000000, 'initial', 20, 'admin', '初步意向沟通', '2026-04-04 20:48:21.933347', '2026-01-04 20:48:21.933347', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_opportunity` VALUES ('f9be29934173427a844ec33f1a8e1448', '金兰科技ERP系统采购项目', '杭州金兰科技有限公司', 'f5d7e5e5fedb488dac443c97a275fd21', 500000.000000000000000000000000000000, 'negotiation', 80, 'admin', '竞争对手只有一家，我方优势明显', '2026-02-04 20:48:21.933347', '2026-01-04 20:48:21.933347', '2026-01-04 20:48:21.933347');

-- ----------------------------
-- Table structure for sales_process_rule
-- ----------------------------
DROP TABLE IF EXISTS `sales_process_rule`;
CREATE TABLE `sales_process_rule`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sales_process_rule
-- ----------------------------
INSERT INTO `sales_process_rule` VALUES ('59c9a479870040e484e3dc5076243bed', '商机报备与保护制度', '1. 所有新接触客户必须在24小时内录入CRM系统，否则视为公共资源。\n2. 报备有效期为3个月，期间其他销售人员不得跟进。\n3. 若3个月内无实质性进展（阶段未推进），系统将自动释放至公海池。\n4. 跨区域撞单情况，以系统最早录入时间为准。', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_process_rule` VALUES ('796b4323847e4032862c49a434d63e97', '客户接待标准流程', '1. 预约：确认客户来访人数、职位、关注点，提前预定会议室。\n2. 接待：前台登记，引导至会议室，提供茶水（矿泉水/茶/咖啡）。\n3. 演示：连接投影仪，准备好演示环境，演示时长控制在30分钟内。\n4. 送别：送至电梯口或公司门口，并在当天发送感谢短信/邮件。', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_process_rule` VALUES ('def3b01c3d2f4c9c92b366c275c3cf8b', '合同审批及盖章规范', '1. 标准合同（金额<50万）：销售经理审批 -> 财务审批 -> 法务备案 -> 用印。\n2. 非标合同或金额>=50万：销售总监审批 -> 财务总监审批 -> 法务总监审批 -> 总经理审批 -> 用印。\n3. 所有合同必须附带技术协议附件。\n4. 严禁先盖章后签字。', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_process_rule` VALUES ('f047edd100c742bcab7408229039774a', '销售提成发放细则', '1. 提成计算基数：以实际回款金额为准（不含税）。\n2. 发放节点：回款次月发放50%，项目验收后发放剩余50%。\n3. 离职员工未结提成：已回款部分按正常比例发放，未回款部分不再计提。\n4. 季度销售冠军额外奖励1%提成点。', '2026-01-04 20:48:21.933347');

-- ----------------------------
-- Table structure for sales_product_doc
-- ----------------------------
DROP TABLE IF EXISTS `sales_product_doc`;
CREATE TABLE `sales_product_doc`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `size` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `upload_date` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sales_product_doc
-- ----------------------------
INSERT INTO `sales_product_doc` VALUES ('5d69efe6604b467ba2025396c16f5f14', 'OMS系统客户成功案例集锦.pdf', '8.4 MB', '/files/docs/success_cases.pdf', '2025-12-20 20:48:21.933347');
INSERT INTO `sales_product_doc` VALUES ('6d581a4617004de595e5dffbe32b4a13', 'OMS智能管理系统_产品白皮书_v3.0.pdf', '5.2 MB', '/files/docs/oms_whitepaper_v3.pdf', '2025-12-05 20:48:21.933347');
INSERT INTO `sales_product_doc` VALUES ('89e48c6ee98641fbad1530f3ef30e826', '系统操作手册(管理员版).docx', '3.2 MB', '/files/docs/manual_admin.docx', '2025-11-05 20:48:21.933347');
INSERT INTO `sales_product_doc` VALUES ('8eafa22f609e4c3c800bc66cc680ac03', 'SaaS版报价单及服务清单_2024Q1.xlsx', '45 KB', '/files/docs/price_list_2024q1.xlsx', '2025-12-30 20:48:21.933347');
INSERT INTO `sales_product_doc` VALUES ('a415a11eae2c4ad28e4adfc726485c65', '企业数字化转型解决方案(制造业版).pptx', '15.8 MB', '/files/docs/solution_manufacturing.pptx', '2025-12-15 20:48:21.933347');

-- ----------------------------
-- Table structure for sales_script
-- ----------------------------
DROP TABLE IF EXISTS `sales_script`;
CREATE TABLE `sales_script`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sales_script
-- ----------------------------
INSERT INTO `sales_script` VALUES ('259d889848ed432384a5e87f7c045cd6', '产品核心优势介绍（30秒电梯演讲）', '我们的OMS系统有三大核心优势：第一是全流程一体化，打通了从CRM到ERP再到财务的全链路；第二是高度可配置，90%的业务变更无需写代码；第三是极致的用户体验，界面简洁易用，员工上手无需培训。这能直接为您解决数据孤岛和系统维护成本高的问题。', '产品介绍', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_script` VALUES ('80a2f3d2f7b74490960a2e7433297cf4', '邀约客户考察话术', '为了让您更直观地了解系统如何落地，诚挚邀请您下周二来我们公司参观考察。届时我们的技术总监会亲自为您演示最新版本，并且您可以和我们的产品团队直接交流您的定制化需求。您看上午10点还是下午2点比较方便？', '客户邀约', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_script` VALUES ('a65d2081f7844f439f326e0d10c6452b', '通用电话开场白', '您好，我是[公司名]的销售顾问[姓名]，打扰您两分钟。我们公司专注于为企业提供数字化转型解决方案，近期我们服务了[知名同行企业]，帮助他们提升了30%的运营效率。想请教一下贵公司在信息化管理方面目前主要关注哪些领域呢？', '初次接触', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_script` VALUES ('fca4d42742d3462daadbc543e2385cf0', '竞品对比回应（针对某友商）', '友商在财务软件领域确实很知名，但在业务运营（OMS）这块，我们的架构更灵活，更贴合当下互联网+的业务模式。例如在多渠道订单归集和复杂的库存调度策略上，我们是原生支持的，而他们可能需要大量的二次开发。', '竞品分析', '2026-01-04 20:48:21.933347');
INSERT INTO `sales_script` VALUES ('fd86fbc73dbd4352aae3d48aad3b4e8f', '价格异议处理话术', '非常理解您对预算的考量。不过，单纯看价格可能不够全面，我们更建议看投入产出比（ROI）。我们的系统虽然初期投入稍高，但由于采用了自动化流程，预计每年能为您节省人工成本约50万元，系统上线半年即可收回成本。我们可以为您做一个详细的ROI分析报告。', '异议处理', '2026-01-04 20:48:21.933347');

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
) ENGINE = InnoDB AUTO_INCREMENT = 920 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `sys_audit_log` VALUES (102, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1030, '2025-12-22 17:31:47.897633');
INSERT INTO `sys_audit_log` VALUES (103, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/46', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 270, '2025-12-22 17:32:45.119532');
INSERT INTO `sys_audit_log` VALUES (104, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 183, '2025-12-22 17:37:25.301291');
INSERT INTO `sys_audit_log` VALUES (105, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 920, '2025-12-22 18:56:37.018712');
INSERT INTO `sys_audit_log` VALUES (106, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 647, '2025-12-22 19:05:46.378031');
INSERT INTO `sys_audit_log` VALUES (107, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 546, '2025-12-22 19:20:42.265821');
INSERT INTO `sys_audit_log` VALUES (108, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/214', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 224, '2025-12-22 19:20:52.803327');
INSERT INTO `sys_audit_log` VALUES (109, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/214', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 210, '2025-12-22 19:21:04.984337');
INSERT INTO `sys_audit_log` VALUES (110, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 313, '2025-12-22 19:22:50.755211');
INSERT INTO `sys_audit_log` VALUES (111, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 318, '2025-12-22 19:23:40.123949');
INSERT INTO `sys_audit_log` VALUES (112, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/216', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 201, '2025-12-22 19:23:48.451646');
INSERT INTO `sys_audit_log` VALUES (113, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/215', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 198, '2025-12-22 19:23:53.111851');
INSERT INTO `sys_audit_log` VALUES (114, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 305, '2025-12-22 19:24:48.814778');
INSERT INTO `sys_audit_log` VALUES (115, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 294, '2025-12-22 19:25:29.416128');
INSERT INTO `sys_audit_log` VALUES (116, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/218', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 197, '2025-12-22 19:25:38.540043');
INSERT INTO `sys_audit_log` VALUES (117, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 207, '2025-12-22 19:28:22.708057');
INSERT INTO `sys_audit_log` VALUES (118, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 682, '2025-12-22 19:28:37.213686');
INSERT INTO `sys_audit_log` VALUES (119, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 484, '2025-12-22 19:45:52.973249');
INSERT INTO `sys_audit_log` VALUES (120, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 480, '2025-12-22 19:48:19.160210');
INSERT INTO `sys_audit_log` VALUES (121, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 154, '2025-12-22 20:04:17.546911');
INSERT INTO `sys_audit_log` VALUES (122, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 984, '2025-12-22 21:28:19.715336');
INSERT INTO `sys_audit_log` VALUES (123, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 495, '2025-12-22 21:36:44.309956');
INSERT INTO `sys_audit_log` VALUES (124, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/219', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 183, '2025-12-22 21:36:51.254407');
INSERT INTO `sys_audit_log` VALUES (125, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 219, '2025-12-22 21:37:46.194036');
INSERT INTO `sys_audit_log` VALUES (126, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 839, '2025-12-22 21:38:08.170395');
INSERT INTO `sys_audit_log` VALUES (127, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', NULL, 1, NULL, 148, '2025-12-22 21:50:52.457469');
INSERT INTO `sys_audit_log` VALUES (128, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/48', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 2368, '2025-12-22 21:58:42.568314');
INSERT INTO `sys_audit_log` VALUES (129, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/42', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1970, '2025-12-22 21:58:55.651235');
INSERT INTO `sys_audit_log` VALUES (130, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/39', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 2957, '2025-12-22 21:59:06.525304');
INSERT INTO `sys_audit_log` VALUES (131, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/31', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1962, '2025-12-22 21:59:25.062743');
INSERT INTO `sys_audit_log` VALUES (132, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/214', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 3465, '2025-12-22 21:59:41.176681');
INSERT INTO `sys_audit_log` VALUES (133, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/46', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 3744, '2025-12-22 21:59:59.770763');
INSERT INTO `sys_audit_log` VALUES (134, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 4587, '2025-12-22 22:02:48.951552');
INSERT INTO `sys_audit_log` VALUES (135, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/221', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 2798, '2025-12-22 22:03:05.977867');
INSERT INTO `sys_audit_log` VALUES (136, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 2284, '2025-12-22 22:04:48.097898');
INSERT INTO `sys_audit_log` VALUES (137, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/222', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 3815, '2025-12-22 22:05:06.232268');
INSERT INTO `sys_audit_log` VALUES (138, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 353, '2025-12-22 22:07:36.484989');
INSERT INTO `sys_audit_log` VALUES (139, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 228, '2025-12-22 22:08:38.876974');
INSERT INTO `sys_audit_log` VALUES (140, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 283, '2025-12-22 22:09:13.710271');
INSERT INTO `sys_audit_log` VALUES (141, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 225, '2025-12-22 22:09:41.131149');
INSERT INTO `sys_audit_log` VALUES (142, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 227, '2025-12-22 22:10:18.499220');
INSERT INTO `sys_audit_log` VALUES (143, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/227', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 169, '2025-12-22 22:10:27.153955');
INSERT INTO `sys_audit_log` VALUES (144, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 246, '2025-12-22 22:11:42.010439');
INSERT INTO `sys_audit_log` VALUES (145, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/228', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 162, '2025-12-22 22:11:48.104496');
INSERT INTO `sys_audit_log` VALUES (146, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/228', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 250, '2025-12-22 22:11:57.061396');
INSERT INTO `sys_audit_log` VALUES (147, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/222', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 233, '2025-12-22 22:12:04.621550');
INSERT INTO `sys_audit_log` VALUES (148, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 580, '2025-12-22 22:12:24.847603');
INSERT INTO `sys_audit_log` VALUES (149, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 232, '2025-12-22 22:13:07.566616');
INSERT INTO `sys_audit_log` VALUES (150, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 507, '2025-12-22 22:13:50.334474');
INSERT INTO `sys_audit_log` VALUES (151, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/229', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 145, '2025-12-22 22:32:54.658660');
INSERT INTO `sys_audit_log` VALUES (152, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/222', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 147, '2025-12-22 22:32:59.841615');
INSERT INTO `sys_audit_log` VALUES (153, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 239, '2025-12-22 22:48:28.748630');
INSERT INTO `sys_audit_log` VALUES (154, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 233, '2025-12-22 22:48:59.233746');
INSERT INTO `sys_audit_log` VALUES (155, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 228, '2025-12-22 22:49:43.564816');
INSERT INTO `sys_audit_log` VALUES (156, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 223, '2025-12-22 22:50:39.105742');
INSERT INTO `sys_audit_log` VALUES (157, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 230, '2025-12-22 22:51:30.103626');
INSERT INTO `sys_audit_log` VALUES (158, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 236, '2025-12-22 22:52:04.983085');
INSERT INTO `sys_audit_log` VALUES (159, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 225, '2025-12-22 22:53:36.391253');
INSERT INTO `sys_audit_log` VALUES (160, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 513, '2025-12-22 23:01:13.749070');
INSERT INTO `sys_audit_log` VALUES (161, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/232', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 166, '2025-12-22 23:03:58.630905');
INSERT INTO `sys_audit_log` VALUES (162, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/232', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 156, '2025-12-22 23:04:50.317165');
INSERT INTO `sys_audit_log` VALUES (163, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/235', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 157, '2025-12-22 23:05:52.170731');
INSERT INTO `sys_audit_log` VALUES (164, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/236', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 153, '2025-12-22 23:06:49.398391');
INSERT INTO `sys_audit_log` VALUES (165, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/234', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 160, '2025-12-22 23:07:29.085639');
INSERT INTO `sys_audit_log` VALUES (166, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 232, '2025-12-22 23:08:55.842561');
INSERT INTO `sys_audit_log` VALUES (167, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/237', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 152, '2025-12-22 23:09:18.418785');
INSERT INTO `sys_audit_log` VALUES (168, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/230', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 164, '2025-12-22 23:09:28.501951');
INSERT INTO `sys_audit_log` VALUES (169, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/231', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 160, '2025-12-22 23:09:34.628599');
INSERT INTO `sys_audit_log` VALUES (170, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/232', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 154, '2025-12-22 23:09:40.750013');
INSERT INTO `sys_audit_log` VALUES (171, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/233', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 191, '2025-12-22 23:09:47.058950');
INSERT INTO `sys_audit_log` VALUES (172, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/234', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 164, '2025-12-22 23:09:52.664929');
INSERT INTO `sys_audit_log` VALUES (173, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/235', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 163, '2025-12-22 23:09:58.353350');
INSERT INTO `sys_audit_log` VALUES (174, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/236', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 163, '2025-12-22 23:10:04.743428');
INSERT INTO `sys_audit_log` VALUES (175, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 571, '2025-12-22 23:10:18.078969');
INSERT INTO `sys_audit_log` VALUES (176, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/235', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 221, '2025-12-22 23:11:12.562980');
INSERT INTO `sys_audit_log` VALUES (177, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/235', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 175, '2025-12-22 23:11:43.485386');
INSERT INTO `sys_audit_log` VALUES (178, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/234', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 179, '2025-12-22 23:12:24.590530');
INSERT INTO `sys_audit_log` VALUES (179, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/234', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 152, '2025-12-22 23:12:55.929315');
INSERT INTO `sys_audit_log` VALUES (180, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36', NULL, 1, NULL, 173, '2025-12-23 08:55:20.768171');
INSERT INTO `sys_audit_log` VALUES (181, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 10; FGD-AL00 Build/HUAWEIFGD-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/517 MicroMessenger/8.0.66.2980(0x2800423B) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 181, '2025-12-23 09:01:09.707200');
INSERT INTO `sys_audit_log` VALUES (182, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.66(0x18004236) NetType/WIFI Language/zh_CN', NULL, 1, NULL, 28, '2025-12-23 09:01:55.397796');
INSERT INTO `sys_audit_log` VALUES (183, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', NULL, 1, NULL, 223, '2025-12-23 09:07:28.611023');
INSERT INTO `sys_audit_log` VALUES (184, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; M2004J7AC Build/SP1A.210812.016; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4458 MicroMessenger/8.0.66.2980(0x2800423E) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 1, NULL, 252, '2025-12-23 09:29:04.849815');
INSERT INTO `sys_audit_log` VALUES (185, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36', NULL, 1, NULL, 25, '2025-12-23 09:30:55.734392');
INSERT INTO `sys_audit_log` VALUES (186, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 15; 23127PN0CC Build/AQ3A.240627.003; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20250904 MMWEBID/5878 MicroMessenger/8.0.65.2960(0x28004156) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 1, NULL, 229, '2025-12-23 09:49:41.045885');
INSERT INTO `sys_audit_log` VALUES (187, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 36, '2025-12-23 09:50:36.389702');
INSERT INTO `sys_audit_log` VALUES (188, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', NULL, 1, NULL, 28, '2025-12-23 09:54:19.451203');
INSERT INTO `sys_audit_log` VALUES (189, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 229, '2025-12-23 10:01:02.565480');
INSERT INTO `sys_audit_log` VALUES (190, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 14; 22041211AC Build/UP1A.231005.007; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/1690 MicroMessenger/8.0.66.2980(0x2800423B) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 1, NULL, 219, '2025-12-23 10:07:14.576949');
INSERT INTO `sys_audit_log` VALUES (191, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', NULL, 1, NULL, 24, '2025-12-23 10:09:37.287346');
INSERT INTO `sys_audit_log` VALUES (192, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', NULL, 1, NULL, 30, '2025-12-23 10:11:58.599323');
INSERT INTO `sys_audit_log` VALUES (193, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 1, NULL, 210, '2025-12-23 10:15:32.985290');
INSERT INTO `sys_audit_log` VALUES (194, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (X11; Windows) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.5790.168 Safari/537.36 HeyTapBrowser/40.10.8.1', NULL, 0, '用户名或密码错误', 192, '2025-12-23 10:20:40.375533');
INSERT INTO `sys_audit_log` VALUES (195, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (X11; Windows) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.5790.168 Safari/537.36 HeyTapBrowser/40.10.8.1', NULL, 1, NULL, 26, '2025-12-23 10:20:49.920573');
INSERT INTO `sys_audit_log` VALUES (196, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 1, NULL, 151, '2025-12-23 10:50:13.457241');
INSERT INTO `sys_audit_log` VALUES (197, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 0, '用户名或密码错误', 980, '2025-12-23 10:50:33.287881');
INSERT INTO `sys_audit_log` VALUES (198, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 453, '2025-12-23 10:50:46.435674');
INSERT INTO `sys_audit_log` VALUES (199, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 183, '2025-12-23 10:51:47.807932');
INSERT INTO `sys_audit_log` VALUES (200, NULL, 'adminadmin123', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 0, '用户名或密码错误', 13, '2025-12-23 10:52:48.950868');
INSERT INTO `sys_audit_log` VALUES (201, NULL, 'adminadmin123', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 0, '用户名或密码错误', 13, '2025-12-23 10:52:53.088221');
INSERT INTO `sys_audit_log` VALUES (202, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 0, '用户名或密码错误', 91, '2025-12-23 10:53:05.950745');
INSERT INTO `sys_audit_log` VALUES (203, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 0, '用户名或密码错误', 129, '2025-12-23 10:54:56.796314');
INSERT INTO `sys_audit_log` VALUES (204, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 183, '2025-12-23 10:55:00.913332');
INSERT INTO `sys_audit_log` VALUES (205, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 0, '用户名或密码错误', 14, '2025-12-23 10:55:42.875272');
INSERT INTO `sys_audit_log` VALUES (206, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 1, NULL, 29, '2025-12-23 10:55:49.056831');
INSERT INTO `sys_audit_log` VALUES (207, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', NULL, 1, NULL, 29, '2025-12-23 11:01:00.403267');
INSERT INTO `sys_audit_log` VALUES (208, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 26, '2025-12-23 11:01:38.968798');
INSERT INTO `sys_audit_log` VALUES (209, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 13; 21091116AC Build/TP1A.220624.014; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/6475 MicroMessenger/8.0.66.2980(0x2800423B) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 1, NULL, 27, '2025-12-23 11:38:48.503936');
INSERT INTO `sys_audit_log` VALUES (210, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 1, NULL, 29, '2025-12-23 11:44:41.836931');
INSERT INTO `sys_audit_log` VALUES (211, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 26, '2025-12-23 11:51:10.697691');
INSERT INTO `sys_audit_log` VALUES (212, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1259, '2025-12-23 12:13:33.794123');
INSERT INTO `sys_audit_log` VALUES (213, 1, NULL, 'omsapi.Controllers.DataSourceController.TestConnection (omsapi)', '/api/DataSource/test', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 305, '2025-12-23 12:24:09.244880');
INSERT INTO `sys_audit_log` VALUES (214, 1, NULL, 'omsapi.Controllers.DataSourceController.Create (omsapi)', '/api/DataSource', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 254, '2025-12-23 12:24:11.562047');
INSERT INTO `sys_audit_log` VALUES (215, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Phone; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile MicroMessenger/8.0.13.44(0xf3800d2c) Weixin NetType/4G Language/zh_CN MMWEBID/6352 MMWEBSDK/202511100006 XWEB/1140363', NULL, 1, NULL, 157, '2025-12-23 12:45:25.206875');
INSERT INTO `sys_audit_log` VALUES (216, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/6', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Phone; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile MicroMessenger/8.0.13.44(0xf3800d2c) Weixin NetType/4G Language/zh_CN MMWEBID/6352 MMWEBSDK/202511100006 XWEB/1140363', NULL, 1, NULL, 58, '2025-12-23 12:45:41.148911');
INSERT INTO `sys_audit_log` VALUES (217, 1, NULL, 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Phone; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile MicroMessenger/8.0.13.44(0xf3800d2c) Weixin NetType/4G Language/zh_CN MMWEBID/6352 MMWEBSDK/202511100006 XWEB/1140363', NULL, 1, NULL, 114, '2025-12-23 12:45:41.379490');
INSERT INTO `sys_audit_log` VALUES (218, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Phone; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile MicroMessenger/8.0.13.44(0xf3800d2c) Weixin NetType/4G Language/zh_CN MMWEBID/6352 MMWEBSDK/202511100006 XWEB/1140363', NULL, 1, NULL, 28, '2025-12-23 12:45:42.769416');
INSERT INTO `sys_audit_log` VALUES (219, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Phone; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile MicroMessenger/8.0.13.44(0xf3800d2c) Weixin NetType/4G Language/zh_CN MMWEBID/6352 MMWEBSDK/202511100006 XWEB/1140363', NULL, 1, NULL, 29, '2025-12-23 12:45:43.445346');
INSERT INTO `sys_audit_log` VALUES (220, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Phone; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile MicroMessenger/8.0.13.44(0xf3800d2c) Weixin NetType/4G Language/zh_CN MMWEBID/6352 MMWEBSDK/202511100006 XWEB/1140363', NULL, 1, NULL, 29, '2025-12-23 12:45:44.296883');
INSERT INTO `sys_audit_log` VALUES (221, 1, NULL, 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/6', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Phone; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile MicroMessenger/8.0.13.44(0xf3800d2c) Weixin NetType/4G Language/zh_CN MMWEBID/6352 MMWEBSDK/202511100006 XWEB/1140363', NULL, 1, NULL, 28, '2025-12-23 12:45:44.960021');
INSERT INTO `sys_audit_log` VALUES (222, 1, NULL, 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Phone; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile MicroMessenger/8.0.13.44(0xf3800d2c) Weixin NetType/4G Language/zh_CN MMWEBID/6352 MMWEBSDK/202511100006 XWEB/1140363', NULL, 1, NULL, 67, '2025-12-23 12:45:45.118315');
INSERT INTO `sys_audit_log` VALUES (223, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.62(0x18003e3a) NetType/4G Language/zh_CN', NULL, 0, '用户名或密码错误', 161, '2025-12-23 12:54:56.999693');
INSERT INTO `sys_audit_log` VALUES (224, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.62(0x18003e3a) NetType/4G Language/zh_CN', NULL, 1, NULL, 29, '2025-12-23 12:55:01.258971');
INSERT INTO `sys_audit_log` VALUES (225, NULL, NULL, 'omsapi.Controllers.DataSourceController.CreateDatabase (omsapi)', '/api/DataSource/1/databases', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.26100.7462', NULL, 1, NULL, 606, '2025-12-23 13:14:45.806897');
INSERT INTO `sys_audit_log` VALUES (226, 1, NULL, 'omsapi.Controllers.DataSourceController.CreateDatabase (omsapi)', '/api/DataSource/1/databases', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 770, '2025-12-23 13:16:23.874726');
INSERT INTO `sys_audit_log` VALUES (227, 1, NULL, 'omsapi.Controllers.DataSourceController.CreateTable (omsapi)', '/api/DataSource/1/databases/testdb/tables', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 216, '2025-12-23 13:23:44.603253');
INSERT INTO `sys_audit_log` VALUES (228, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 238, '2025-12-23 13:23:48.007175');
INSERT INTO `sys_audit_log` VALUES (229, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 432, '2025-12-23 13:25:59.866785');
INSERT INTO `sys_audit_log` VALUES (230, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 218, '2025-12-23 13:27:28.347645');
INSERT INTO `sys_audit_log` VALUES (231, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 214, '2025-12-23 13:27:38.341271');
INSERT INTO `sys_audit_log` VALUES (232, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 231, '2025-12-23 13:32:41.641098');
INSERT INTO `sys_audit_log` VALUES (233, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 211, '2025-12-23 13:35:30.790601');
INSERT INTO `sys_audit_log` VALUES (234, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 254, '2025-12-23 13:42:02.758504');
INSERT INTO `sys_audit_log` VALUES (235, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 232, '2025-12-23 13:44:50.988383');
INSERT INTO `sys_audit_log` VALUES (236, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 233, '2025-12-23 13:45:11.179657');
INSERT INTO `sys_audit_log` VALUES (237, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 229, '2025-12-23 13:45:44.735079');
INSERT INTO `sys_audit_log` VALUES (238, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 471, '2025-12-23 13:49:28.453528');
INSERT INTO `sys_audit_log` VALUES (239, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 289, '2025-12-23 13:50:36.504063');
INSERT INTO `sys_audit_log` VALUES (240, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 508, '2025-12-23 13:55:21.847308');
INSERT INTO `sys_audit_log` VALUES (241, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 513, '2025-12-23 13:58:55.233335');
INSERT INTO `sys_audit_log` VALUES (242, 1, NULL, 'omsapi.Controllers.DataSourceController.AddColumn (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/columns', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 819, '2025-12-23 14:00:09.325974');
INSERT INTO `sys_audit_log` VALUES (243, 1, NULL, 'omsapi.Controllers.DataSourceController.ModifyColumn (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/columns/age', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 244, '2025-12-23 14:00:23.032307');
INSERT INTO `sys_audit_log` VALUES (244, 1, NULL, 'omsapi.Controllers.DataSourceController.ModifyColumn (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/columns/age', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 321, '2025-12-23 14:00:32.118031');
INSERT INTO `sys_audit_log` VALUES (245, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 558, '2025-12-23 14:00:49.981128');
INSERT INTO `sys_audit_log` VALUES (246, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 155, '2025-12-23 14:01:41.178466');
INSERT INTO `sys_audit_log` VALUES (247, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 333, '2025-12-23 14:02:19.646866');
INSERT INTO `sys_audit_log` VALUES (248, 1, NULL, 'omsapi.Controllers.DataSourceController.InsertRow (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data/insert', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 198, '2025-12-23 14:02:33.903063');
INSERT INTO `sys_audit_log` VALUES (249, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 335, '2025-12-23 14:02:34.819969');
INSERT INTO `sys_audit_log` VALUES (250, 1, NULL, 'omsapi.Controllers.DataSourceController.InsertRow (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data/insert', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 193, '2025-12-23 14:02:56.778357');
INSERT INTO `sys_audit_log` VALUES (251, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 334, '2025-12-23 14:02:57.709849');
INSERT INTO `sys_audit_log` VALUES (252, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 332, '2025-12-23 14:03:00.241176');
INSERT INTO `sys_audit_log` VALUES (253, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 339, '2025-12-23 14:03:02.237408');
INSERT INTO `sys_audit_log` VALUES (254, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 334, '2025-12-23 14:03:03.994570');
INSERT INTO `sys_audit_log` VALUES (255, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 341, '2025-12-23 14:03:05.744481');
INSERT INTO `sys_audit_log` VALUES (256, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 386, '2025-12-23 14:03:07.220209');
INSERT INTO `sys_audit_log` VALUES (257, 1, NULL, 'omsapi.Controllers.DataSourceController.DeleteRow (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data/delete', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 204, '2025-12-23 14:03:33.108320');
INSERT INTO `sys_audit_log` VALUES (258, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 336, '2025-12-23 14:03:33.734957');
INSERT INTO `sys_audit_log` VALUES (259, NULL, NULL, 'omsapi.Controllers.DataSourceController.InsertRow (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data/insert', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 195, '2025-12-23 14:03:51.156814');
INSERT INTO `sys_audit_log` VALUES (260, NULL, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 344, '2025-12-23 14:03:51.784198');
INSERT INTO `sys_audit_log` VALUES (261, NULL, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 391, '2025-12-23 14:04:35.796243');
INSERT INTO `sys_audit_log` VALUES (262, NULL, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 330, '2025-12-23 14:04:57.589940');
INSERT INTO `sys_audit_log` VALUES (263, NULL, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 551, '2025-12-23 14:17:52.052663');
INSERT INTO `sys_audit_log` VALUES (264, NULL, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 315, '2025-12-23 14:18:02.637051');
INSERT INTO `sys_audit_log` VALUES (265, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 922, '2025-12-23 14:29:18.064496');
INSERT INTO `sys_audit_log` VALUES (266, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 514, '2025-12-23 14:29:38.126099');
INSERT INTO `sys_audit_log` VALUES (267, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 307, '2025-12-23 14:31:08.016967');
INSERT INTO `sys_audit_log` VALUES (268, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 426, '2025-12-23 14:36:48.676696');
INSERT INTO `sys_audit_log` VALUES (269, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 93, '2025-12-23 14:37:06.673783');
INSERT INTO `sys_audit_log` VALUES (270, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 529, '2025-12-23 15:00:36.046621');
INSERT INTO `sys_audit_log` VALUES (271, 1, NULL, 'omsapi.Controllers.DataSourceController.InsertRow (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data/insert', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 173, '2025-12-23 15:00:47.005747');
INSERT INTO `sys_audit_log` VALUES (272, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 299, '2025-12-23 15:00:47.907002');
INSERT INTO `sys_audit_log` VALUES (273, 1, NULL, 'omsapi.Controllers.DataSourceController.CreateDatabase (omsapi)', '/api/DataSource/1/databases', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 193, '2025-12-23 15:01:02.300107');
INSERT INTO `sys_audit_log` VALUES (274, 1, NULL, 'omsapi.Controllers.DataSourceController.TestConnection (omsapi)', '/api/DataSource/test', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 263, '2025-12-23 15:01:58.724233');
INSERT INTO `sys_audit_log` VALUES (275, 1, NULL, 'omsapi.Controllers.DataSourceController.Create (omsapi)', '/api/DataSource', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 184, '2025-12-23 15:02:00.830677');
INSERT INTO `sys_audit_log` VALUES (276, 1, NULL, 'omsapi.Controllers.DataSourceController.TestConnection (omsapi)', '/api/DataSource/test', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 190, '2025-12-23 15:02:24.001020');
INSERT INTO `sys_audit_log` VALUES (277, 1, NULL, 'omsapi.Controllers.DataSourceController.Update (omsapi)', '/api/DataSource/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 191, '2025-12-23 15:02:29.073747');
INSERT INTO `sys_audit_log` VALUES (278, 1, NULL, 'omsapi.Controllers.DataSourceController.TestConnection (omsapi)', '/api/DataSource/test', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 38, '2025-12-23 15:02:52.391581');
INSERT INTO `sys_audit_log` VALUES (279, 1, NULL, 'omsapi.Controllers.DataSourceController.Update (omsapi)', '/api/DataSource/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 177, '2025-12-23 15:02:54.387507');
INSERT INTO `sys_audit_log` VALUES (280, 1, NULL, 'omsapi.Controllers.DataSourceController.Update (omsapi)', '/api/DataSource/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 176, '2025-12-23 15:03:08.296201');
INSERT INTO `sys_audit_log` VALUES (281, 1, NULL, 'omsapi.Controllers.DataSourceController.Update (omsapi)', '/api/DataSource/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 182, '2025-12-23 15:03:18.306834');
INSERT INTO `sys_audit_log` VALUES (282, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 516, '2025-12-23 15:19:09.502099');
INSERT INTO `sys_audit_log` VALUES (283, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 532, '2025-12-23 15:39:03.501281');
INSERT INTO `sys_audit_log` VALUES (284, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 732, '2025-12-23 15:50:12.138092');
INSERT INTO `sys_audit_log` VALUES (285, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 624, '2025-12-23 15:57:49.767147');
INSERT INTO `sys_audit_log` VALUES (286, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 526, '2025-12-23 16:11:09.167843');
INSERT INTO `sys_audit_log` VALUES (287, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 322, '2025-12-23 16:12:31.712379');
INSERT INTO `sys_audit_log` VALUES (288, 1, NULL, 'omsapi.Controllers.DataSourceController.CreateTable (omsapi)', '/api/DataSource/2/databases/testdb2/tables', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 245, '2025-12-23 16:13:22.198078');
INSERT INTO `sys_audit_log` VALUES (289, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/2/databases/testdb2/tables/test11/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 508, '2025-12-23 16:13:25.214896');
INSERT INTO `sys_audit_log` VALUES (290, NULL, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 575, '2025-12-23 16:20:01.203020');
INSERT INTO `sys_audit_log` VALUES (291, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 457, '2025-12-23 16:22:02.501296');
INSERT INTO `sys_audit_log` VALUES (292, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/2/databases/testdb2/tables/test11/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 474, '2025-12-23 16:24:16.261430');
INSERT INTO `sys_audit_log` VALUES (293, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 520, '2025-12-23 16:24:33.537698');
INSERT INTO `sys_audit_log` VALUES (294, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 549, '2025-12-23 16:37:54.623336');
INSERT INTO `sys_audit_log` VALUES (295, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 657, '2025-12-23 16:52:44.435633');
INSERT INTO `sys_audit_log` VALUES (296, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 NetType/WIFI MicroMessenger/7.0.20.1781(0x6700143B) WindowsWechat(0x63090c33) XWEB/14185 Flue', NULL, 1, NULL, 167, '2025-12-23 17:09:55.751658');
INSERT INTO `sys_audit_log` VALUES (297, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; CLS-AL00 Build/HUAWEICLS-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420087 MMWEBSDK/20251006 MMWEBID/9019 MicroMessenger/8.0.66.2980(0x2800423B) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 0, '用户名或密码错误', 223, '2025-12-23 19:08:32.555136');
INSERT INTO `sys_audit_log` VALUES (298, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; CLS-AL00 Build/HUAWEICLS-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420087 MMWEBSDK/20251006 MMWEBID/9019 MicroMessenger/8.0.66.2980(0x2800423B) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 0, '用户名或密码错误', 15, '2025-12-23 19:08:35.152745');
INSERT INTO `sys_audit_log` VALUES (299, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; CLS-AL00 Build/HUAWEICLS-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420087 MMWEBSDK/20251006 MMWEBID/9019 MicroMessenger/8.0.66.2980(0x2800423B) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 1, NULL, 26, '2025-12-23 19:08:51.240229');
INSERT INTO `sys_audit_log` VALUES (300, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.66(0x18004236) NetType/4G Language/zh_CN', NULL, 1, NULL, 198, '2025-12-23 20:18:39.405480');
INSERT INTO `sys_audit_log` VALUES (301, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 205, '2025-12-23 20:51:48.558329');
INSERT INTO `sys_audit_log` VALUES (302, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 10; SPN-AL00 Build/HUAWEISPN-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/2102 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 64, '2025-12-23 20:55:29.461256');
INSERT INTO `sys_audit_log` VALUES (303, NULL, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.66(0x18004236) NetType/WIFI Language/zh_CN', NULL, 0, '用户名或密码错误', 138, '2025-12-23 21:20:19.935563');
INSERT INTO `sys_audit_log` VALUES (304, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.66(0x18004236) NetType/WIFI Language/zh_CN', NULL, 1, NULL, 29, '2025-12-23 21:20:34.904997');
INSERT INTO `sys_audit_log` VALUES (305, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; ELS-AN00 Build/HUAWEIELS-AN00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/97.0.4692.98 Mobile Safari/537.36 T7/15.37 BDOS/1.0 (HarmonyOS 3.0.0) SP-engine/3.55.0 bd_dvt/0 baiduboxapp/15.40.0.10 (Baidu; P1 12) NABar/1.0', NULL, 1, NULL, 223, '2025-12-23 21:38:49.522603');
INSERT INTO `sys_audit_log` VALUES (306, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.60(0x18003c32) NetType/4G Language/zh_CN', NULL, 1, NULL, 199, '2025-12-23 22:46:00.848759');
INSERT INTO `sys_audit_log` VALUES (307, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', NULL, 1, NULL, 245, '2025-12-24 08:31:34.834330');
INSERT INTO `sys_audit_log` VALUES (308, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 226, '2025-12-24 08:41:14.093631');
INSERT INTO `sys_audit_log` VALUES (309, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 30, '2025-12-24 08:45:04.422091');
INSERT INTO `sys_audit_log` VALUES (310, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 168, '2025-12-24 10:12:38.770411');
INSERT INTO `sys_audit_log` VALUES (311, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 226, '2025-12-24 12:05:27.735784');
INSERT INTO `sys_audit_log` VALUES (312, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 202, '2025-12-24 12:11:39.622570');
INSERT INTO `sys_audit_log` VALUES (313, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 27, '2025-12-24 12:13:30.167246');
INSERT INTO `sys_audit_log` VALUES (314, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 249, '2025-12-24 12:22:51.007960');
INSERT INTO `sys_audit_log` VALUES (315, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 209, '2025-12-24 13:01:08.831038');
INSERT INTO `sys_audit_log` VALUES (316, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 934, '2025-12-24 13:09:22.503765');
INSERT INTO `sys_audit_log` VALUES (317, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 197, '2025-12-24 13:10:52.963088');
INSERT INTO `sys_audit_log` VALUES (318, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 28, '2025-12-24 13:13:45.248108');
INSERT INTO `sys_audit_log` VALUES (319, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 260, '2025-12-24 13:29:01.995576');
INSERT INTO `sys_audit_log` VALUES (320, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 60, '2025-12-24 13:33:17.559538');
INSERT INTO `sys_audit_log` VALUES (321, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 34, '2025-12-24 13:33:49.689133');
INSERT INTO `sys_audit_log` VALUES (322, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 163, '2025-12-24 16:03:39.695271');
INSERT INTO `sys_audit_log` VALUES (323, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 30, '2025-12-24 16:04:59.084938');
INSERT INTO `sys_audit_log` VALUES (324, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 159, '2025-12-24 16:23:11.091604');
INSERT INTO `sys_audit_log` VALUES (325, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 25, '2025-12-24 16:26:47.563774');
INSERT INTO `sys_audit_log` VALUES (326, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 25, '2025-12-24 16:27:34.339754');
INSERT INTO `sys_audit_log` VALUES (327, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 53, '2025-12-24 17:01:57.240443');
INSERT INTO `sys_audit_log` VALUES (328, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 849, '2025-12-24 17:34:48.752577');
INSERT INTO `sys_audit_log` VALUES (329, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 790, '2025-12-24 17:35:24.722962');
INSERT INTO `sys_audit_log` VALUES (330, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/238', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 198, '2025-12-24 17:36:10.077601');
INSERT INTO `sys_audit_log` VALUES (331, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 226, '2025-12-24 19:44:25.567952');
INSERT INTO `sys_audit_log` VALUES (332, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; ANA-TN00 Build/HUAWEIANA-TN00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/7439 MicroMessenger/8.0.66.2980(0x2800423E) WeChat/arm64 Weixin NetType/5G Language/zh_CN ABI/arm64', NULL, 1, NULL, 28, '2025-12-24 19:47:48.651899');
INSERT INTO `sys_audit_log` VALUES (333, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 148, '2025-12-24 19:54:13.549910');
INSERT INTO `sys_audit_log` VALUES (334, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 NetType/WIFI MicroMessenger/7.0.20.1781(0x6700143B) WindowsWechat(0x63090c37) XWEB/14185 Flue', NULL, 1, NULL, 188, '2025-12-24 20:06:59.692640');
INSERT INTO `sys_audit_log` VALUES (335, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 643, '2025-12-24 20:48:16.212911');
INSERT INTO `sys_audit_log` VALUES (336, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 282, '2025-12-24 22:41:31.023741');
INSERT INTO `sys_audit_log` VALUES (337, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 224, '2025-12-24 23:37:14.658975');
INSERT INTO `sys_audit_log` VALUES (338, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/238', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 38, '2025-12-25 00:05:53.458787');
INSERT INTO `sys_audit_log` VALUES (339, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/238', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 323, '2025-12-25 00:11:16.760685');
INSERT INTO `sys_audit_log` VALUES (340, 1, NULL, 'omsapi.Controllers.PermissionController.Update (omsapi)', '/api/permission/238', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 368, '2025-12-25 00:20:00.835900');
INSERT INTO `sys_audit_log` VALUES (341, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 641, '2025-12-25 00:36:48.290122');
INSERT INTO `sys_audit_log` VALUES (342, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 143, '2025-12-25 00:51:13.962711');
INSERT INTO `sys_audit_log` VALUES (343, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 313, '2025-12-25 00:51:31.806755');
INSERT INTO `sys_audit_log` VALUES (344, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 724, '2025-12-25 00:52:44.867782');
INSERT INTO `sys_audit_log` VALUES (345, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1442, '2025-12-25 09:22:06.584660');
INSERT INTO `sys_audit_log` VALUES (346, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 346, '2025-12-25 10:44:54.699491');
INSERT INTO `sys_audit_log` VALUES (347, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 86, '2025-12-25 11:39:07.355823');
INSERT INTO `sys_audit_log` VALUES (348, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 275, '2025-12-25 11:42:24.942846');
INSERT INTO `sys_audit_log` VALUES (349, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/2/databases/testdb2/tables/test11/data', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 74, '2025-12-25 11:42:36.913081');
INSERT INTO `sys_audit_log` VALUES (350, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 275, '2025-12-25 12:16:15.973967');
INSERT INTO `sys_audit_log` VALUES (351, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 43, '2025-12-25 14:07:52.548236');
INSERT INTO `sys_audit_log` VALUES (352, NULL, NULL, 'omsapi.Controllers.BigViewCommonController.Upload (omsapi)', '/api/bigview/upload', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 13, '2025-12-25 14:15:29.080910');
INSERT INTO `sys_audit_log` VALUES (353, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 62, '2025-12-25 14:15:29.522157');
INSERT INTO `sys_audit_log` VALUES (354, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 38, '2025-12-25 14:15:29.752132');
INSERT INTO `sys_audit_log` VALUES (355, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 28, '2025-12-25 14:17:32.378987');
INSERT INTO `sys_audit_log` VALUES (356, NULL, NULL, 'omsapi.Controllers.BigViewCommonController.Upload (omsapi)', '/api/bigview/upload', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 10, '2025-12-25 14:17:34.441757');
INSERT INTO `sys_audit_log` VALUES (357, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 31, '2025-12-25 14:17:34.637346');
INSERT INTO `sys_audit_log` VALUES (358, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 39, '2025-12-25 14:17:35.785251');
INSERT INTO `sys_audit_log` VALUES (359, NULL, NULL, 'omsapi.Controllers.BigViewCommonController.Upload (omsapi)', '/api/bigview/upload', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 16, '2025-12-25 14:17:36.110683');
INSERT INTO `sys_audit_log` VALUES (360, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 29, '2025-12-25 14:17:36.346323');
INSERT INTO `sys_audit_log` VALUES (361, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 14, '2025-12-25 14:17:36.554236');
INSERT INTO `sys_audit_log` VALUES (362, NULL, NULL, 'omsapi.Controllers.BigViewCommonController.Upload (omsapi)', '/api/bigview/upload', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 16, '2025-12-25 14:21:14.084168');
INSERT INTO `sys_audit_log` VALUES (363, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 56, '2025-12-25 14:21:14.596187');
INSERT INTO `sys_audit_log` VALUES (364, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 38, '2025-12-25 14:21:14.833046');
INSERT INTO `sys_audit_log` VALUES (365, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 292, '2025-12-25 15:08:56.164420');
INSERT INTO `sys_audit_log` VALUES (366, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 233, '2025-12-25 15:49:17.319600');
INSERT INTO `sys_audit_log` VALUES (367, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 31, '2025-12-25 15:49:44.499337');
INSERT INTO `sys_audit_log` VALUES (368, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 347, '2025-12-25 16:37:19.642899');
INSERT INTO `sys_audit_log` VALUES (369, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 27, '2025-12-25 18:27:32.136426');
INSERT INTO `sys_audit_log` VALUES (370, NULL, NULL, 'omsapi.Controllers.BigViewCommonController.Upload (omsapi)', '/api/bigview/upload', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 14, '2025-12-25 18:27:51.736967');
INSERT INTO `sys_audit_log` VALUES (371, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 13, '2025-12-25 18:27:51.830409');
INSERT INTO `sys_audit_log` VALUES (372, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 35, '2025-12-25 18:27:51.946608');
INSERT INTO `sys_audit_log` VALUES (373, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 43, '2025-12-25 18:27:57.642387');
INSERT INTO `sys_audit_log` VALUES (374, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 40, '2025-12-25 18:28:02.420185');
INSERT INTO `sys_audit_log` VALUES (375, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 41, '2025-12-25 18:28:06.364619');
INSERT INTO `sys_audit_log` VALUES (376, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=4', 1, NULL, 15, '2025-12-25 18:28:46.068237');
INSERT INTO `sys_audit_log` VALUES (377, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=4', 1, NULL, 13, '2025-12-25 18:29:02.329129');
INSERT INTO `sys_audit_log` VALUES (378, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=4', 1, NULL, 13, '2025-12-25 18:29:22.647281');
INSERT INTO `sys_audit_log` VALUES (379, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=4', 1, NULL, 94, '2025-12-25 18:40:25.156802');
INSERT INTO `sys_audit_log` VALUES (380, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=3', 1, NULL, 25, '2025-12-25 18:40:39.457736');
INSERT INTO `sys_audit_log` VALUES (381, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=2', 1, NULL, 26, '2025-12-25 18:40:46.837481');
INSERT INTO `sys_audit_log` VALUES (382, NULL, NULL, 'omsapi.Controllers.BigViewCommonController.Upload (omsapi)', '/api/bigview/upload', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 24, '2025-12-25 18:40:53.867922');
INSERT INTO `sys_audit_log` VALUES (383, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 18, '2025-12-25 18:40:54.006682');
INSERT INTO `sys_audit_log` VALUES (384, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 14, '2025-12-25 18:40:54.106243');
INSERT INTO `sys_audit_log` VALUES (385, NULL, NULL, 'omsapi.Controllers.BigViewCommonController.Upload (omsapi)', '/api/bigview/upload', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 17, '2025-12-25 18:41:00.478273');
INSERT INTO `sys_audit_log` VALUES (386, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 12, '2025-12-25 18:41:00.582826');
INSERT INTO `sys_audit_log` VALUES (387, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 19, '2025-12-25 18:41:00.685440');
INSERT INTO `sys_audit_log` VALUES (388, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 41, '2025-12-25 18:41:29.378784');
INSERT INTO `sys_audit_log` VALUES (389, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 704, '2025-12-25 18:43:46.311058');
INSERT INTO `sys_audit_log` VALUES (390, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=5', 1, NULL, 24, '2025-12-25 18:44:00.615914');
INSERT INTO `sys_audit_log` VALUES (391, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 34, '2025-12-25 18:44:04.130276');
INSERT INTO `sys_audit_log` VALUES (392, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 35, '2025-12-25 18:44:15.242150');
INSERT INTO `sys_audit_log` VALUES (393, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=7', 1, NULL, 24, '2025-12-25 18:44:53.231458');
INSERT INTO `sys_audit_log` VALUES (394, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=6', 1, NULL, 23, '2025-12-25 18:44:57.326380');
INSERT INTO `sys_audit_log` VALUES (395, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 35, '2025-12-25 18:45:00.558133');
INSERT INTO `sys_audit_log` VALUES (396, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 42, '2025-12-25 18:46:40.301399');
INSERT INTO `sys_audit_log` VALUES (397, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=9', 1, NULL, 24, '2025-12-25 18:47:40.903079');
INSERT INTO `sys_audit_log` VALUES (398, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=8', 1, NULL, 24, '2025-12-25 18:47:45.325721');
INSERT INTO `sys_audit_log` VALUES (399, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 36, '2025-12-25 18:47:48.453076');
INSERT INTO `sys_audit_log` VALUES (400, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 36, '2025-12-25 18:47:48.675780');
INSERT INTO `sys_audit_log` VALUES (401, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=10', 1, NULL, 24, '2025-12-25 18:49:46.747428');
INSERT INTO `sys_audit_log` VALUES (402, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 38, '2025-12-25 18:49:50.298045');
INSERT INTO `sys_audit_log` VALUES (403, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 35, '2025-12-25 18:49:50.523784');
INSERT INTO `sys_audit_log` VALUES (404, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=11', 1, NULL, 101, '2025-12-25 18:49:56.366007');
INSERT INTO `sys_audit_log` VALUES (405, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 156, '2025-12-25 18:53:48.326974');
INSERT INTO `sys_audit_log` VALUES (406, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=12', 1, NULL, 59, '2025-12-25 18:54:01.410094');
INSERT INTO `sys_audit_log` VALUES (407, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 33, '2025-12-25 18:54:04.231986');
INSERT INTO `sys_audit_log` VALUES (408, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=13', 1, NULL, 23, '2025-12-25 18:54:31.355358');
INSERT INTO `sys_audit_log` VALUES (409, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 37, '2025-12-25 18:54:34.295731');
INSERT INTO `sys_audit_log` VALUES (410, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Delete (omsapi)', '/api/bigview/project/delete', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?ids=14', 1, NULL, 25, '2025-12-25 18:55:08.517570');
INSERT INTO `sys_audit_log` VALUES (411, NULL, NULL, 'omsapi.Controllers.BigViewCommonController.Upload (omsapi)', '/api/bigview/upload', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 12, '2025-12-25 18:55:15.720430');
INSERT INTO `sys_audit_log` VALUES (412, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 15, '2025-12-25 18:55:15.819325');
INSERT INTO `sys_audit_log` VALUES (413, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 11, '2025-12-25 18:55:15.905810');
INSERT INTO `sys_audit_log` VALUES (414, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 31, '2025-12-25 18:58:48.684156');
INSERT INTO `sys_audit_log` VALUES (415, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 32, '2025-12-25 18:58:48.798208');
INSERT INTO `sys_audit_log` VALUES (416, NULL, NULL, 'omsapi.Controllers.BigViewCommonController.Upload (omsapi)', '/api/bigview/upload', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 9, '2025-12-25 18:59:32.871449');
INSERT INTO `sys_audit_log` VALUES (417, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 24, '2025-12-25 18:59:32.999796');
INSERT INTO `sys_audit_log` VALUES (418, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 31, '2025-12-25 18:59:33.101648');
INSERT INTO `sys_audit_log` VALUES (419, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 350, '2025-12-25 19:46:47.688049');
INSERT INTO `sys_audit_log` VALUES (420, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 30, '2025-12-25 19:50:49.159448');
INSERT INTO `sys_audit_log` VALUES (421, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 115, '2025-12-25 19:52:17.996958');
INSERT INTO `sys_audit_log` VALUES (422, 1, NULL, 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 50, '2025-12-25 19:54:40.675351');
INSERT INTO `sys_audit_log` VALUES (423, 1, NULL, 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 204, '2025-12-25 19:54:54.849815');
INSERT INTO `sys_audit_log` VALUES (424, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', NULL, 1, NULL, 181, '2025-12-25 22:19:08.214762');
INSERT INTO `sys_audit_log` VALUES (425, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.66(0x18004237) NetType/4G Language/zh_CN', NULL, 1, NULL, 195, '2025-12-26 07:56:00.230291');
INSERT INTO `sys_audit_log` VALUES (426, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 2390, '2025-12-26 09:03:07.920275');
INSERT INTO `sys_audit_log` VALUES (427, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Create (omsapi)', '/api/bigview/project/create', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 38, '2025-12-26 09:03:44.574202');
INSERT INTO `sys_audit_log` VALUES (428, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 37, '2025-12-26 09:03:44.698206');
INSERT INTO `sys_audit_log` VALUES (429, 1, NULL, 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 723, '2025-12-26 10:15:14.381569');
INSERT INTO `sys_audit_log` VALUES (430, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 168, '2025-12-26 10:19:29.774154');
INSERT INTO `sys_audit_log` VALUES (431, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 25, '2025-12-26 10:19:46.413200');
INSERT INTO `sys_audit_log` VALUES (432, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 26, '2025-12-26 10:20:21.164293');
INSERT INTO `sys_audit_log` VALUES (433, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 188, '2025-12-26 10:55:02.998103');
INSERT INTO `sys_audit_log` VALUES (434, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.66(0x18004237) NetType/4G Language/zh_CN', NULL, 1, NULL, 26, '2025-12-26 10:55:22.765098');
INSERT INTO `sys_audit_log` VALUES (435, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 310, '2025-12-26 10:59:34.853136');
INSERT INTO `sys_audit_log` VALUES (436, 1, NULL, 'omsapi.Controllers.FormController.CreateCategory (omsapi)', '/api/form/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 617, '2025-12-26 11:15:42.720582');
INSERT INTO `sys_audit_log` VALUES (437, 1, NULL, 'omsapi.Controllers.FormController.CreateCategory (omsapi)', '/api/form/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 192, '2025-12-26 11:16:11.695085');
INSERT INTO `sys_audit_log` VALUES (438, 1, NULL, 'omsapi.Controllers.FormController.CreateCategory (omsapi)', '/api/form/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 245, '2025-12-26 11:17:24.871492');
INSERT INTO `sys_audit_log` VALUES (439, 1, NULL, 'omsapi.Controllers.FormController.CreateCategory (omsapi)', '/api/form/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 193, '2025-12-26 11:17:35.962823');
INSERT INTO `sys_audit_log` VALUES (440, 1, NULL, 'omsapi.Controllers.FormController.CreateCategory (omsapi)', '/api/form/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 195, '2025-12-26 11:17:46.769001');
INSERT INTO `sys_audit_log` VALUES (441, 1, NULL, 'omsapi.Controllers.FormController.CreateForm (omsapi)', '/api/form/definitions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 280, '2025-12-26 11:19:46.903776');
INSERT INTO `sys_audit_log` VALUES (442, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 381, '2025-12-26 11:28:52.747552');
INSERT INTO `sys_audit_log` VALUES (443, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 205, '2025-12-26 11:29:43.125441');
INSERT INTO `sys_audit_log` VALUES (444, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 198, '2025-12-26 11:29:56.314314');
INSERT INTO `sys_audit_log` VALUES (445, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 209, '2025-12-26 11:32:09.141431');
INSERT INTO `sys_audit_log` VALUES (446, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 213, '2025-12-26 11:32:29.058321');
INSERT INTO `sys_audit_log` VALUES (447, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 454, '2025-12-26 11:36:04.650182');
INSERT INTO `sys_audit_log` VALUES (448, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 227, '2025-12-26 11:36:16.502941');
INSERT INTO `sys_audit_log` VALUES (449, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 200, '2025-12-26 11:36:38.987337');
INSERT INTO `sys_audit_log` VALUES (450, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 207, '2025-12-26 11:36:53.436464');
INSERT INTO `sys_audit_log` VALUES (451, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 371, '2025-12-26 11:47:01.243557');
INSERT INTO `sys_audit_log` VALUES (452, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 182, '2025-12-26 11:47:04.015653');
INSERT INTO `sys_audit_log` VALUES (453, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 156, '2025-12-26 12:09:10.574538');
INSERT INTO `sys_audit_log` VALUES (454, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 26, '2025-12-26 12:09:45.601734');
INSERT INTO `sys_audit_log` VALUES (455, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 478, '2025-12-26 12:12:54.685151');
INSERT INTO `sys_audit_log` VALUES (456, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 208, '2025-12-26 12:13:38.403665');
INSERT INTO `sys_audit_log` VALUES (457, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 241, '2025-12-26 12:13:52.703991');
INSERT INTO `sys_audit_log` VALUES (458, 1, NULL, 'omsapi.Controllers.FormController.SubmitForm (omsapi)', '/api/form/submit', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 307, '2025-12-26 12:14:03.174822');
INSERT INTO `sys_audit_log` VALUES (459, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 199, '2025-12-26 12:15:30.985657');
INSERT INTO `sys_audit_log` VALUES (460, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 559, '2025-12-26 12:46:20.688363');
INSERT INTO `sys_audit_log` VALUES (461, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 26, '2025-12-26 12:47:42.760968');
INSERT INTO `sys_audit_log` VALUES (462, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 44, '2025-12-26 12:55:58.264162');
INSERT INTO `sys_audit_log` VALUES (463, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; HarmonyOS; JAD-AL80; HMSCore 6.15.4.332; GMSCore 22.12.56) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.196 HuaweiBrowser/16.0.11.301 Mobile Safari/537.36', NULL, 1, NULL, 27, '2025-12-26 12:56:35.687416');
INSERT INTO `sys_audit_log` VALUES (464, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 243, '2025-12-26 14:45:09.239118');
INSERT INTO `sys_audit_log` VALUES (465, NULL, NULL, 'omsapi.Controllers.BigViewCommonController.Upload (omsapi)', '/api/bigview/upload', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 10, '2025-12-26 14:49:42.977388');
INSERT INTO `sys_audit_log` VALUES (466, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 24, '2025-12-26 14:49:43.094401');
INSERT INTO `sys_audit_log` VALUES (467, NULL, NULL, 'omsapi.Controllers.BigViewProjectController.Update (omsapi)', '/api/bigview/project/update', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 13, '2025-12-26 14:49:43.178988');
INSERT INTO `sys_audit_log` VALUES (468, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 287, '2025-12-26 14:59:03.867432');
INSERT INTO `sys_audit_log` VALUES (469, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 60, '2025-12-26 15:03:42.228261');
INSERT INTO `sys_audit_log` VALUES (470, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 613, '2025-12-26 15:08:42.178701');
INSERT INTO `sys_audit_log` VALUES (471, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 197, '2025-12-26 15:11:24.413805');
INSERT INTO `sys_audit_log` VALUES (472, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 188, '2025-12-26 15:11:45.896681');
INSERT INTO `sys_audit_log` VALUES (473, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 193, '2025-12-26 15:16:58.814008');
INSERT INTO `sys_audit_log` VALUES (474, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 30, '2025-12-26 15:17:30.119781');
INSERT INTO `sys_audit_log` VALUES (475, 1, NULL, 'omsapi.Controllers.FormController.SubmitForm (omsapi)', '/api/form/submit', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 470, '2025-12-26 15:34:08.344773');
INSERT INTO `sys_audit_log` VALUES (476, 1, NULL, 'omsapi.Controllers.FormController.SubmitForm (omsapi)', '/api/form/submit', 'POST', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 278, '2025-12-26 15:34:22.986932');
INSERT INTO `sys_audit_log` VALUES (477, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 518, '2025-12-26 15:55:31.916527');
INSERT INTO `sys_audit_log` VALUES (478, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 29, '2025-12-26 19:20:06.978247');
INSERT INTO `sys_audit_log` VALUES (479, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 855, '2025-12-26 19:29:38.799909');
INSERT INTO `sys_audit_log` VALUES (480, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 278, '2025-12-26 19:30:17.457682');
INSERT INTO `sys_audit_log` VALUES (481, 1, NULL, 'omsapi.Controllers.FormController.SubmitForm (omsapi)', '/api/form/submit', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 395, '2025-12-26 19:36:45.223232');
INSERT INTO `sys_audit_log` VALUES (482, 1, NULL, 'omsapi.Controllers.FormController.SubmitForm (omsapi)', '/api/form/submit', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 599, '2025-12-26 19:58:37.895820');
INSERT INTO `sys_audit_log` VALUES (483, 1, NULL, 'omsapi.Controllers.UserController.Create (omsapi)', '/api/user', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 242, '2025-12-26 21:22:47.598747');
INSERT INTO `sys_audit_log` VALUES (484, 1, NULL, 'omsapi.Controllers.RoleController.Create (omsapi)', '/api/role', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 20, '2025-12-26 21:23:22.255905');
INSERT INTO `sys_audit_log` VALUES (485, 1, NULL, 'omsapi.Controllers.RoleController.Create (omsapi)', '/api/role', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 103, '2025-12-26 21:24:13.287352');
INSERT INTO `sys_audit_log` VALUES (486, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 55, '2025-12-26 21:26:39.571568');
INSERT INTO `sys_audit_log` VALUES (487, 1, 'admin', 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/3/permissions', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 106, '2025-12-26 21:28:25.627146');
INSERT INTO `sys_audit_log` VALUES (488, 1, 'admin', 'omsapi.Controllers.RoleController.Update (omsapi)', '/api/role/1', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 68, '2025-12-26 21:28:38.780378');
INSERT INTO `sys_audit_log` VALUES (489, 4, 'superadmin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 30, '2025-12-26 21:30:06.449411');
INSERT INTO `sys_audit_log` VALUES (490, 4, 'superadmin', 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/2/permissions', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 66, '2025-12-26 21:30:48.399463');
INSERT INTO `sys_audit_log` VALUES (491, 1, NULL, 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 510, '2025-12-26 21:31:30.180281');
INSERT INTO `sys_audit_log` VALUES (492, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 564, '2025-12-26 21:36:50.680532');
INSERT INTO `sys_audit_log` VALUES (493, NULL, 'superadmin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 0, '用户名或密码错误', 94, '2025-12-26 21:37:04.784857');
INSERT INTO `sys_audit_log` VALUES (494, 4, 'superadmin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 192, '2025-12-26 21:37:49.765698');
INSERT INTO `sys_audit_log` VALUES (495, 4, 'superadmin', 'omsapi.Controllers.UserController.UploadAvatar (omsapi)', '/api/user/avatar', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 249, '2025-12-26 21:38:08.626496');
INSERT INTO `sys_audit_log` VALUES (496, 4, 'superadmin', 'omsapi.Controllers.UserController.UpdateProfile (omsapi)', '/api/user/profile', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 193, '2025-12-26 21:38:18.960195');
INSERT INTO `sys_audit_log` VALUES (497, 4, 'superadmin', 'omsapi.Controllers.UserController.ResetPassword (omsapi)', '/api/user/2/reset-password', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 849, '2025-12-26 21:41:27.002572');
INSERT INTO `sys_audit_log` VALUES (498, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 367, '2025-12-26 21:41:42.460238');
INSERT INTO `sys_audit_log` VALUES (499, 2, 'test', 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 172, '2025-12-26 21:42:03.686200');
INSERT INTO `sys_audit_log` VALUES (500, 2, 'test', 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 168, '2025-12-26 21:42:10.479910');
INSERT INTO `sys_audit_log` VALUES (501, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 220, '2025-12-26 21:55:00.104725');
INSERT INTO `sys_audit_log` VALUES (502, 1, 'admin', 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 337, '2025-12-26 21:55:41.773880');
INSERT INTO `sys_audit_log` VALUES (503, 1, 'admin', 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/3/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 742, '2025-12-26 21:56:00.195213');
INSERT INTO `sys_audit_log` VALUES (504, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 192, '2025-12-26 21:56:36.756762');
INSERT INTO `sys_audit_log` VALUES (505, 2, 'test', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1176, '2025-12-26 21:57:52.543147');
INSERT INTO `sys_audit_log` VALUES (506, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36', NULL, 1, NULL, 397, '2025-12-26 21:58:43.429454');
INSERT INTO `sys_audit_log` VALUES (507, 1, 'admin', 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36', NULL, 1, NULL, 392, '2025-12-26 21:59:37.144147');
INSERT INTO `sys_audit_log` VALUES (508, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 398, '2025-12-26 22:00:03.019992');
INSERT INTO `sys_audit_log` VALUES (509, 1, 'admin', 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 306, '2025-12-26 22:00:15.316474');
INSERT INTO `sys_audit_log` VALUES (510, 1, 'admin', 'omsapi.Controllers.FormController.UpdateForm (omsapi)', '/api/form/definitions/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 298, '2025-12-26 22:00:20.848323');
INSERT INTO `sys_audit_log` VALUES (511, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 612, '2025-12-26 22:12:36.111839');
INSERT INTO `sys_audit_log` VALUES (512, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/7', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 64, '2025-12-26 22:13:18.739579');
INSERT INTO `sys_audit_log` VALUES (513, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 53, '2025-12-26 22:17:33.500691');
INSERT INTO `sys_audit_log` VALUES (514, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 16; 25098PN5AC Build/BP2A.250605.031.A3; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/9969 MicroMessenger/8.0.66.2980(0x2800423E) WeChat/arm64 Weixin NetType/WIFI Language/zh_CN ABI/arm64', NULL, 1, NULL, 49, '2025-12-26 22:18:30.722796');
INSERT INTO `sys_audit_log` VALUES (515, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/7', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-26 22:21:06.542942');
INSERT INTO `sys_audit_log` VALUES (516, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.2 Safari/605.1.15', NULL, 1, NULL, 49, '2025-12-26 23:20:11.074800');
INSERT INTO `sys_audit_log` VALUES (517, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 191, '2025-12-27 01:05:30.408942');
INSERT INTO `sys_audit_log` VALUES (518, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/11', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:05:54.410457');
INSERT INTO `sys_audit_log` VALUES (519, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/11', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 27, '2025-12-27 01:06:16.497467');
INSERT INTO `sys_audit_log` VALUES (520, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/11', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:06:23.514216');
INSERT INTO `sys_audit_log` VALUES (521, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/7', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 27, '2025-12-27 01:07:29.292290');
INSERT INTO `sys_audit_log` VALUES (522, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/11', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:07:45.895253');
INSERT INTO `sys_audit_log` VALUES (523, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/6', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:07:48.231857');
INSERT INTO `sys_audit_log` VALUES (524, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 63, '2025-12-27 01:07:48.385334');
INSERT INTO `sys_audit_log` VALUES (525, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:07:50.423706');
INSERT INTO `sys_audit_log` VALUES (526, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/6', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:07:51.752778');
INSERT INTO `sys_audit_log` VALUES (527, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/6', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:08:03.499252');
INSERT INTO `sys_audit_log` VALUES (528, 1, 'admin', 'omsapi.Controllers.DeptController.DeleteDept (omsapi)', '/api/dept/6', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 65, '2025-12-27 01:09:04.086911');
INSERT INTO `sys_audit_log` VALUES (529, 1, 'admin', 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 34, '2025-12-27 01:09:21.063542');
INSERT INTO `sys_audit_log` VALUES (530, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 24, '2025-12-27 01:09:27.083531');
INSERT INTO `sys_audit_log` VALUES (531, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 63, '2025-12-27 01:09:27.229863');
INSERT INTO `sys_audit_log` VALUES (532, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/4', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 23, '2025-12-27 01:09:27.928913');
INSERT INTO `sys_audit_log` VALUES (533, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/12', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 24, '2025-12-27 01:09:42.210928');
INSERT INTO `sys_audit_log` VALUES (534, 1, 'admin', 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 24, '2025-12-27 01:09:57.338760');
INSERT INTO `sys_audit_log` VALUES (535, 1, 'admin', 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:10:20.815043');
INSERT INTO `sys_audit_log` VALUES (536, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 32, '2025-12-27 01:10:24.374459');
INSERT INTO `sys_audit_log` VALUES (537, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 57, '2025-12-27 01:10:24.517396');
INSERT INTO `sys_audit_log` VALUES (538, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 24, '2025-12-27 01:10:38.856267');
INSERT INTO `sys_audit_log` VALUES (539, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 24, '2025-12-27 01:10:41.744539');
INSERT INTO `sys_audit_log` VALUES (540, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 48, '2025-12-27 01:10:41.871672');
INSERT INTO `sys_audit_log` VALUES (541, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 24, '2025-12-27 01:10:42.824525');
INSERT INTO `sys_audit_log` VALUES (542, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 55, '2025-12-27 01:10:42.966701');
INSERT INTO `sys_audit_log` VALUES (543, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/1', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:10:43.486686');
INSERT INTO `sys_audit_log` VALUES (544, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 50, '2025-12-27 01:10:43.614652');
INSERT INTO `sys_audit_log` VALUES (545, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 27, '2025-12-27 01:11:11.011490');
INSERT INTO `sys_audit_log` VALUES (546, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/1', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 23, '2025-12-27 01:11:12.176325');
INSERT INTO `sys_audit_log` VALUES (547, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 24, '2025-12-27 01:14:08.491610');
INSERT INTO `sys_audit_log` VALUES (548, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/1', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 24, '2025-12-27 01:16:51.278890');
INSERT INTO `sys_audit_log` VALUES (549, 1, 'admin', 'omsapi.Controllers.DeptController.DeleteDept (omsapi)', '/api/dept/4', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 13, '2025-12-27 01:16:58.992709');
INSERT INTO `sys_audit_log` VALUES (550, 1, 'admin', 'omsapi.Controllers.DeptController.DeleteDept (omsapi)', '/api/dept/4', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 12, '2025-12-27 01:17:09.600118');
INSERT INTO `sys_audit_log` VALUES (551, 1, 'admin', 'omsapi.Controllers.UserController.Delete (omsapi)', '/api/user/3', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 107, '2025-12-27 01:17:18.961569');
INSERT INTO `sys_audit_log` VALUES (553, 1, 'admin', 'omsapi.Controllers.PostController.Delete (omsapi)', '/api/post/1', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 78, '2025-12-27 01:17:36.657545');
INSERT INTO `sys_audit_log` VALUES (555, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 29, '2025-12-27 01:17:47.851191');
INSERT INTO `sys_audit_log` VALUES (556, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 59, '2025-12-27 01:17:47.997553');
INSERT INTO `sys_audit_log` VALUES (557, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:17:48.696913');
INSERT INTO `sys_audit_log` VALUES (558, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 31, '2025-12-27 01:17:50.127291');
INSERT INTO `sys_audit_log` VALUES (559, 1, 'admin', 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 31, '2025-12-27 01:19:47.350577');
INSERT INTO `sys_audit_log` VALUES (560, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 30, '2025-12-27 01:19:53.270914');
INSERT INTO `sys_audit_log` VALUES (561, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 76, '2025-12-27 01:19:53.428659');
INSERT INTO `sys_audit_log` VALUES (562, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/15', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 30, '2025-12-27 01:19:55.893813');
INSERT INTO `sys_audit_log` VALUES (563, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 63, '2025-12-27 01:19:56.036983');
INSERT INTO `sys_audit_log` VALUES (564, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/14', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:19:57.635294');
INSERT INTO `sys_audit_log` VALUES (565, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 74, '2025-12-27 01:19:57.790798');
INSERT INTO `sys_audit_log` VALUES (566, 1, 'admin', 'omsapi.Controllers.DeptController.DeleteDept (omsapi)', '/api/dept/11', 'DELETE', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 30, '2025-12-27 01:20:05.512723');
INSERT INTO `sys_audit_log` VALUES (567, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/14', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 29, '2025-12-27 01:20:12.142916');
INSERT INTO `sys_audit_log` VALUES (568, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 77, '2025-12-27 01:20:12.304783');
INSERT INTO `sys_audit_log` VALUES (569, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/15', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 29, '2025-12-27 01:20:14.387215');
INSERT INTO `sys_audit_log` VALUES (570, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/15', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 29, '2025-12-27 01:20:19.537059');
INSERT INTO `sys_audit_log` VALUES (571, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 30, '2025-12-27 01:20:29.636389');
INSERT INTO `sys_audit_log` VALUES (572, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:20:35.881118');
INSERT INTO `sys_audit_log` VALUES (573, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 29, '2025-12-27 01:20:37.915093');
INSERT INTO `sys_audit_log` VALUES (574, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/1', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 32, '2025-12-27 01:20:41.163348');
INSERT INTO `sys_audit_log` VALUES (575, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/15', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 32, '2025-12-27 01:21:01.307910');
INSERT INTO `sys_audit_log` VALUES (576, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 54, '2025-12-27 01:21:01.529796');
INSERT INTO `sys_audit_log` VALUES (577, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 29, '2025-12-27 01:21:10.559774');
INSERT INTO `sys_audit_log` VALUES (578, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/14', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 30, '2025-12-27 01:21:13.152184');
INSERT INTO `sys_audit_log` VALUES (579, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/15', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:21:20.924327');
INSERT INTO `sys_audit_log` VALUES (580, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/13', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:21:23.553055');
INSERT INTO `sys_audit_log` VALUES (581, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/12', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 29, '2025-12-27 01:21:26.417157');
INSERT INTO `sys_audit_log` VALUES (582, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/4', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 29, '2025-12-27 01:21:30.919380');
INSERT INTO `sys_audit_log` VALUES (583, 1, 'admin', 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:22:05.994736');
INSERT INTO `sys_audit_log` VALUES (584, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/16', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 29, '2025-12-27 01:22:12.346793');
INSERT INTO `sys_audit_log` VALUES (585, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 47, '2025-12-27 01:22:12.471543');
INSERT INTO `sys_audit_log` VALUES (586, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:22:21.706654');
INSERT INTO `sys_audit_log` VALUES (587, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:22:23.280627');
INSERT INTO `sys_audit_log` VALUES (589, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:26:01.965628');
INSERT INTO `sys_audit_log` VALUES (590, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/16', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 27, '2025-12-27 01:27:11.476981');
INSERT INTO `sys_audit_log` VALUES (591, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/4', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:27:21.311193');
INSERT INTO `sys_audit_log` VALUES (593, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:27:58.607642');
INSERT INTO `sys_audit_log` VALUES (594, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/4', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:28:13.745593');
INSERT INTO `sys_audit_log` VALUES (595, 1, 'admin', 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:28:42.905053');
INSERT INTO `sys_audit_log` VALUES (596, 1, 'admin', 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:29:20.423236');
INSERT INTO `sys_audit_log` VALUES (597, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/18', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:29:26.549783');
INSERT INTO `sys_audit_log` VALUES (598, 1, 'admin', 'omsapi.Controllers.DeptController.CreateDept (omsapi)', '/api/dept', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:29:38.129511');
INSERT INTO `sys_audit_log` VALUES (599, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/1', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:29:45.318085');
INSERT INTO `sys_audit_log` VALUES (600, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/17', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:29:48.421121');
INSERT INTO `sys_audit_log` VALUES (601, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateStructure (omsapi)', '/api/dept/structure', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 45, '2025-12-27 01:29:48.545729');
INSERT INTO `sys_audit_log` VALUES (602, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/18', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:29:50.886555');
INSERT INTO `sys_audit_log` VALUES (603, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/19', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:29:55.042028');
INSERT INTO `sys_audit_log` VALUES (604, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/17', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:30:03.683793');
INSERT INTO `sys_audit_log` VALUES (605, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/16', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 27, '2025-12-27 01:30:28.512007');
INSERT INTO `sys_audit_log` VALUES (606, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/4', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:30:45.657361');
INSERT INTO `sys_audit_log` VALUES (607, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/19', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:30:49.785653');
INSERT INTO `sys_audit_log` VALUES (608, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:30:56.810364');
INSERT INTO `sys_audit_log` VALUES (609, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/16', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:30:59.686118');
INSERT INTO `sys_audit_log` VALUES (610, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/15', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:31:08.971585');
INSERT INTO `sys_audit_log` VALUES (611, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/13', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:31:11.255252');
INSERT INTO `sys_audit_log` VALUES (612, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/12', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:31:14.323670');
INSERT INTO `sys_audit_log` VALUES (613, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:31:18.637904');
INSERT INTO `sys_audit_log` VALUES (614, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/3', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:31:21.275194');
INSERT INTO `sys_audit_log` VALUES (615, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:31:23.446822');
INSERT INTO `sys_audit_log` VALUES (616, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/4', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:31:35.949283');
INSERT INTO `sys_audit_log` VALUES (617, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/19', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:31:37.578569');
INSERT INTO `sys_audit_log` VALUES (618, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/8', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:31:40.293781');
INSERT INTO `sys_audit_log` VALUES (619, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/16', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 29, '2025-12-27 01:31:42.981126');
INSERT INTO `sys_audit_log` VALUES (620, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/17', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:31:46.689405');
INSERT INTO `sys_audit_log` VALUES (621, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/18', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 26, '2025-12-27 01:31:51.100065');
INSERT INTO `sys_audit_log` VALUES (622, 1, 'admin', 'omsapi.Controllers.DeptController.UpdateDept (omsapi)', '/api/dept/19', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 25, '2025-12-27 01:31:55.907119');
INSERT INTO `sys_audit_log` VALUES (623, 1, 'admin', 'omsapi.Controllers.PostController.Create (omsapi)', '/api/post', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 55, '2025-12-27 01:36:13.673211');
INSERT INTO `sys_audit_log` VALUES (624, 1, 'admin', 'omsapi.Controllers.PostController.Update (omsapi)', '/api/post/2', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 32, '2025-12-27 01:37:28.534518');
INSERT INTO `sys_audit_log` VALUES (625, 1, 'admin', 'omsapi.Controllers.PostController.Update (omsapi)', '/api/post/2', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 28, '2025-12-27 01:37:47.481045');
INSERT INTO `sys_audit_log` VALUES (626, 1, 'admin', 'omsapi.Controllers.PostController.Create (omsapi)', '/api/post', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.4.300', NULL, 1, NULL, 40, '2025-12-27 01:38:03.649955');
INSERT INTO `sys_audit_log` VALUES (627, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.196 Safari/537.36', NULL, 1, NULL, 255, '2025-12-27 09:00:48.592694');
INSERT INTO `sys_audit_log` VALUES (628, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.66(0x18004237) NetType/4G Language/zh_CN', NULL, 1, NULL, 173, '2025-12-27 09:16:55.465438');
INSERT INTO `sys_audit_log` VALUES (629, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 50, '2025-12-27 09:17:01.323659');
INSERT INTO `sys_audit_log` VALUES (630, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; HarmonyOS; ELS-AN00; HMSCore 6.15.4.322) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.196 HuaweiBrowser/16.0.11.301 Mobile Safari/537.36', NULL, 1, NULL, 188, '2025-12-27 09:30:34.527418');
INSERT INTO `sys_audit_log` VALUES (631, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.66(0x18004237) NetType/WIFI Language/zh_CN', NULL, 1, NULL, 215, '2025-12-27 09:44:33.956760');
INSERT INTO `sys_audit_log` VALUES (632, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/143.0.0.0', NULL, 1, NULL, 249, '2025-12-27 10:15:10.529693');
INSERT INTO `sys_audit_log` VALUES (633, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 589, '2025-12-27 12:03:06.060128');
INSERT INTO `sys_audit_log` VALUES (634, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 49, '2025-12-27 12:04:05.428908');
INSERT INTO `sys_audit_log` VALUES (635, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1010, '2025-12-27 12:10:19.869182');
INSERT INTO `sys_audit_log` VALUES (636, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 7318, '2025-12-27 12:17:26.273794');
INSERT INTO `sys_audit_log` VALUES (637, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Dalvik/2.1.0 (Linux; U; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80)', NULL, 1, NULL, 267, '2025-12-27 12:47:30.572576');
INSERT INTO `sys_audit_log` VALUES (638, 1, 'admin', 'omsapi.Controllers.InterfaceController.CreateCategory (omsapi)', '/api/interface/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 502, '2025-12-27 13:38:00.632401');
INSERT INTO `sys_audit_log` VALUES (639, 1, 'admin', 'omsapi.Controllers.InterfaceController.CreateCategory (omsapi)', '/api/interface/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 210, '2025-12-27 13:38:18.653444');
INSERT INTO `sys_audit_log` VALUES (640, 1, 'admin', 'omsapi.Controllers.InterfaceController.CreateInterface (omsapi)', '/api/interface', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 308, '2025-12-27 13:39:11.772806');
INSERT INTO `sys_audit_log` VALUES (641, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=true', 1, NULL, 230, '2025-12-27 13:39:21.802375');
INSERT INTO `sys_audit_log` VALUES (642, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateCategory (omsapi)', '/api/interface/categories/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 337, '2025-12-27 13:50:42.410906');
INSERT INTO `sys_audit_log` VALUES (643, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateCategory (omsapi)', '/api/interface/categories/2', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 192, '2025-12-27 13:50:51.049921');
INSERT INTO `sys_audit_log` VALUES (644, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 284, '2025-12-27 13:52:40.166033');
INSERT INTO `sys_audit_log` VALUES (645, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateCategory (omsapi)', '/api/interface/categories/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 439, '2025-12-27 13:56:39.152005');
INSERT INTO `sys_audit_log` VALUES (646, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateCategory (omsapi)', '/api/interface/categories/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 377, '2025-12-27 13:59:52.638868');
INSERT INTO `sys_audit_log` VALUES (647, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 618, '2025-12-27 14:08:52.475275');
INSERT INTO `sys_audit_log` VALUES (648, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 0, 'Cannot modify a published interface. Please take it offline first.', 101, '2025-12-27 14:13:52.528487');
INSERT INTO `sys_audit_log` VALUES (649, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 0, 'Cannot modify a published interface. Please take it offline first.', 97, '2025-12-27 14:15:36.667278');
INSERT INTO `sys_audit_log` VALUES (650, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 0, '已发布接口禁止修改，请先下线后再进行操作。', 440, '2025-12-27 14:17:09.329363');
INSERT INTO `sys_audit_log` VALUES (651, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=false', 1, NULL, 211, '2025-12-27 14:20:26.123007');
INSERT INTO `sys_audit_log` VALUES (652, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 191, '2025-12-27 14:21:23.255548');
INSERT INTO `sys_audit_log` VALUES (653, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=true', 1, NULL, 182, '2025-12-27 14:21:37.233890');
INSERT INTO `sys_audit_log` VALUES (654, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=false', 1, NULL, 189, '2025-12-27 14:23:35.914742');
INSERT INTO `sys_audit_log` VALUES (655, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=true', 1, NULL, 182, '2025-12-27 14:23:49.435422');
INSERT INTO `sys_audit_log` VALUES (656, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=false', 1, NULL, 185, '2025-12-27 14:27:37.326317');
INSERT INTO `sys_audit_log` VALUES (657, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=true', 1, NULL, 180, '2025-12-27 14:27:48.264716');
INSERT INTO `sys_audit_log` VALUES (658, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=false', 1, NULL, 179, '2025-12-27 14:27:52.335287');
INSERT INTO `sys_audit_log` VALUES (659, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 178, '2025-12-27 14:27:58.204664');
INSERT INTO `sys_audit_log` VALUES (660, 1, 'admin', 'omsapi.Controllers.InterfaceController.CreateInterface (omsapi)', '/api/interface', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 198, '2025-12-27 14:29:58.325457');
INSERT INTO `sys_audit_log` VALUES (661, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 180, '2025-12-27 14:30:34.829584');
INSERT INTO `sys_audit_log` VALUES (662, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 182, '2025-12-27 14:30:39.808901');
INSERT INTO `sys_audit_log` VALUES (663, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=true', 1, NULL, 179, '2025-12-27 14:30:51.046411');
INSERT INTO `sys_audit_log` VALUES (664, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=false', 1, NULL, 184, '2025-12-27 14:30:56.890682');
INSERT INTO `sys_audit_log` VALUES (665, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 179, '2025-12-27 14:31:22.918272');
INSERT INTO `sys_audit_log` VALUES (666, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 31, '2025-12-27 14:45:20.963480');
INSERT INTO `sys_audit_log` VALUES (667, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 63, '2025-12-27 14:59:46.932432');
INSERT INTO `sys_audit_log` VALUES (668, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 84, '2025-12-27 15:04:04.289495');
INSERT INTO `sys_audit_log` VALUES (669, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 0, '2025-12-27 15:07:59.470161');
INSERT INTO `sys_audit_log` VALUES (670, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 9, '2025-12-27 15:11:17.975763');
INSERT INTO `sys_audit_log` VALUES (671, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1, '2025-12-27 15:11:53.192742');
INSERT INTO `sys_audit_log` VALUES (672, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 78, '2025-12-27 15:18:01.603785');
INSERT INTO `sys_audit_log` VALUES (673, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 0, '2025-12-27 15:18:58.765599');
INSERT INTO `sys_audit_log` VALUES (674, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1, '2025-12-27 15:20:19.725547');
INSERT INTO `sys_audit_log` VALUES (675, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 0, '2025-12-27 15:20:33.635830');
INSERT INTO `sys_audit_log` VALUES (676, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1, '2025-12-27 15:22:29.391927');
INSERT INTO `sys_audit_log` VALUES (677, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1, '2025-12-27 15:24:31.543416');
INSERT INTO `sys_audit_log` VALUES (678, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 285, '2025-12-27 15:27:48.886787');
INSERT INTO `sys_audit_log` VALUES (679, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 231, '2025-12-27 15:30:59.920064');
INSERT INTO `sys_audit_log` VALUES (680, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 217, '2025-12-27 15:31:28.997332');
INSERT INTO `sys_audit_log` VALUES (681, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 215, '2025-12-27 15:33:03.781686');
INSERT INTO `sys_audit_log` VALUES (682, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 208, '2025-12-27 15:34:23.590217');
INSERT INTO `sys_audit_log` VALUES (683, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 213, '2025-12-27 15:34:33.519388');
INSERT INTO `sys_audit_log` VALUES (684, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 172, '2025-12-27 15:34:40.040687');
INSERT INTO `sys_audit_log` VALUES (685, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 224, '2025-12-27 15:35:39.943979');
INSERT INTO `sys_audit_log` VALUES (686, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 122, '2025-12-27 15:35:54.635281');
INSERT INTO `sys_audit_log` VALUES (687, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 103, '2025-12-27 15:36:47.120273');
INSERT INTO `sys_audit_log` VALUES (688, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 175, '2025-12-27 15:40:07.054338');
INSERT INTO `sys_audit_log` VALUES (689, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 165, '2025-12-27 15:40:26.363953');
INSERT INTO `sys_audit_log` VALUES (690, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 285, '2025-12-27 15:41:23.561910');
INSERT INTO `sys_audit_log` VALUES (691, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 110, '2025-12-27 15:41:28.076295');
INSERT INTO `sys_audit_log` VALUES (692, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 112, '2025-12-27 15:41:40.405698');
INSERT INTO `sys_audit_log` VALUES (693, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 115, '2025-12-27 15:43:24.485562');
INSERT INTO `sys_audit_log` VALUES (694, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 639, '2025-12-27 15:46:20.361412');
INSERT INTO `sys_audit_log` VALUES (695, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 249, '2025-12-27 15:47:31.874548');
INSERT INTO `sys_audit_log` VALUES (696, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 15; PGT-AN00 Build/HONORPGT-AN00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/3037 MicroMessenger/8.0.66.2980(0x2800423E) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 191, '2025-12-27 15:54:52.475214');
INSERT INTO `sys_audit_log` VALUES (697, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 656, '2025-12-27 15:58:27.572660');
INSERT INTO `sys_audit_log` VALUES (698, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 905, '2025-12-27 15:58:37.418098');
INSERT INTO `sys_audit_log` VALUES (699, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 164, '2025-12-27 15:58:51.167419');
INSERT INTO `sys_audit_log` VALUES (700, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 392, '2025-12-27 15:58:58.386591');
INSERT INTO `sys_audit_log` VALUES (701, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 191, '2025-12-27 15:59:13.979200');
INSERT INTO `sys_audit_log` VALUES (702, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 885, '2025-12-27 16:08:16.792708');
INSERT INTO `sys_audit_log` VALUES (703, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 748, '2025-12-27 16:12:01.707055');
INSERT INTO `sys_audit_log` VALUES (704, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 349, '2025-12-27 16:15:45.457446');
INSERT INTO `sys_audit_log` VALUES (705, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=true', 1, NULL, 241, '2025-12-27 16:15:51.784048');
INSERT INTO `sys_audit_log` VALUES (706, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=false', 1, NULL, 204, '2025-12-27 16:19:29.852099');
INSERT INTO `sys_audit_log` VALUES (707, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 387, '2025-12-27 16:19:42.071552');
INSERT INTO `sys_audit_log` VALUES (708, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 144, '2025-12-27 16:19:50.867316');
INSERT INTO `sys_audit_log` VALUES (709, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 314, '2025-12-27 16:21:37.763050');
INSERT INTO `sys_audit_log` VALUES (710, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 306, '2025-12-27 16:22:53.387536');
INSERT INTO `sys_audit_log` VALUES (711, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 807, '2025-12-27 16:25:09.288658');
INSERT INTO `sys_audit_log` VALUES (712, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 828, '2025-12-27 16:26:44.849606');
INSERT INTO `sys_audit_log` VALUES (713, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 362, '2025-12-27 16:28:09.805142');
INSERT INTO `sys_audit_log` VALUES (714, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 160, '2025-12-27 16:28:33.444296');
INSERT INTO `sys_audit_log` VALUES (715, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 693, '2025-12-27 17:09:35.122486');
INSERT INTO `sys_audit_log` VALUES (716, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 452, '2025-12-27 17:19:14.561984');
INSERT INTO `sys_audit_log` VALUES (717, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 51, '2025-12-27 17:19:49.512942');
INSERT INTO `sys_audit_log` VALUES (718, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 427, '2025-12-27 17:21:44.469909');
INSERT INTO `sys_audit_log` VALUES (719, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 52, '2025-12-27 17:26:16.575977');
INSERT INTO `sys_audit_log` VALUES (720, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 33, '2025-12-27 17:26:30.788342');
INSERT INTO `sys_audit_log` VALUES (721, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 33, '2025-12-27 17:27:03.989289');
INSERT INTO `sys_audit_log` VALUES (722, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 29, '2025-12-27 17:27:36.092220');
INSERT INTO `sys_audit_log` VALUES (723, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 58, '2025-12-27 17:28:30.839676');
INSERT INTO `sys_audit_log` VALUES (724, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 29, '2025-12-27 17:29:30.682873');
INSERT INTO `sys_audit_log` VALUES (725, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 52, '2025-12-27 17:33:58.899446');
INSERT INTO `sys_audit_log` VALUES (726, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; JAD-AL80 Build/HUAWEIJAD-AL80; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/4480 MicroMessenger/8.0.66.2980(0x28004234) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 213, '2025-12-27 17:44:54.360909');
INSERT INTO `sys_audit_log` VALUES (727, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 264, '2025-12-27 19:42:44.372190');
INSERT INTO `sys_audit_log` VALUES (728, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1393, '2025-12-27 19:47:13.466372');
INSERT INTO `sys_audit_log` VALUES (729, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 54, '2025-12-27 20:25:08.547170');
INSERT INTO `sys_audit_log` VALUES (730, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1616, '2025-12-27 21:06:32.245195');
INSERT INTO `sys_audit_log` VALUES (731, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 375, '2025-12-27 21:09:26.409394');
INSERT INTO `sys_audit_log` VALUES (732, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 316, '2025-12-27 21:11:09.087370');
INSERT INTO `sys_audit_log` VALUES (733, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 360, '2025-12-27 21:17:55.563119');
INSERT INTO `sys_audit_log` VALUES (734, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 325, '2025-12-27 21:27:02.791219');
INSERT INTO `sys_audit_log` VALUES (735, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 199, '2025-12-27 21:27:36.372827');
INSERT INTO `sys_audit_log` VALUES (736, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 321, '2025-12-27 21:27:39.617603');
INSERT INTO `sys_audit_log` VALUES (737, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 943, '2025-12-27 21:31:08.909229');
INSERT INTO `sys_audit_log` VALUES (738, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 905, '2025-12-27 21:36:28.240300');
INSERT INTO `sys_audit_log` VALUES (739, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 659, '2025-12-27 21:45:03.927139');
INSERT INTO `sys_audit_log` VALUES (740, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 241, '2025-12-27 21:46:23.581795');
INSERT INTO `sys_audit_log` VALUES (741, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 193, '2025-12-27 21:46:55.101516');
INSERT INTO `sys_audit_log` VALUES (742, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1226, '2025-12-27 21:48:10.581013');
INSERT INTO `sys_audit_log` VALUES (743, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 470, '2025-12-27 21:55:09.862694');
INSERT INTO `sys_audit_log` VALUES (744, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 559, '2025-12-27 21:55:12.957771');
INSERT INTO `sys_audit_log` VALUES (745, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1156, '2025-12-27 21:58:11.111235');
INSERT INTO `sys_audit_log` VALUES (746, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 310, '2025-12-27 21:58:25.213219');
INSERT INTO `sys_audit_log` VALUES (747, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=true', 1, NULL, 257, '2025-12-27 21:59:01.052198');
INSERT INTO `sys_audit_log` VALUES (748, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=false', 1, NULL, 499, '2025-12-27 22:01:31.789261');
INSERT INTO `sys_audit_log` VALUES (749, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 206, '2025-12-27 22:01:53.464032');
INSERT INTO `sys_audit_log` VALUES (750, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 249, '2025-12-27 22:02:01.149024');
INSERT INTO `sys_audit_log` VALUES (751, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 244, '2025-12-27 22:02:13.882754');
INSERT INTO `sys_audit_log` VALUES (752, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=true', 1, NULL, 199, '2025-12-27 22:02:27.844545');
INSERT INTO `sys_audit_log` VALUES (753, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=false', 1, NULL, 215, '2025-12-27 22:02:48.843672');
INSERT INTO `sys_audit_log` VALUES (754, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1038, '2025-12-27 22:14:31.298414');
INSERT INTO `sys_audit_log` VALUES (755, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 295, '2025-12-27 22:14:43.450328');
INSERT INTO `sys_audit_log` VALUES (756, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=true', 1, NULL, 235, '2025-12-27 22:14:53.808773');
INSERT INTO `sys_audit_log` VALUES (757, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=false', 1, NULL, 188, '2025-12-27 22:15:07.646256');
INSERT INTO `sys_audit_log` VALUES (758, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 477, '2025-12-27 22:30:13.841860');
INSERT INTO `sys_audit_log` VALUES (759, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 195, '2025-12-27 22:32:46.649532');
INSERT INTO `sys_audit_log` VALUES (760, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 192, '2025-12-27 22:33:09.809460');
INSERT INTO `sys_audit_log` VALUES (761, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 487, '2025-12-27 22:33:16.570832');
INSERT INTO `sys_audit_log` VALUES (762, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 190, '2025-12-27 22:33:41.688930');
INSERT INTO `sys_audit_log` VALUES (763, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 221, '2025-12-27 22:33:52.737537');
INSERT INTO `sys_audit_log` VALUES (764, 1, 'admin', 'omsapi.Controllers.InterfaceController.UpdateInterface (omsapi)', '/api/interface/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 388, '2025-12-27 22:37:57.645460');
INSERT INTO `sys_audit_log` VALUES (765, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 404, '2025-12-27 22:52:14.997394');
INSERT INTO `sys_audit_log` VALUES (766, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 459, '2025-12-27 22:52:25.029407');
INSERT INTO `sys_audit_log` VALUES (767, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1325, '2025-12-27 22:56:09.531591');
INSERT INTO `sys_audit_log` VALUES (768, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 291, '2025-12-27 22:56:52.623673');
INSERT INTO `sys_audit_log` VALUES (769, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 573, '2025-12-27 22:57:56.677702');
INSERT INTO `sys_audit_log` VALUES (770, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1162, '2025-12-28 14:09:48.187282');
INSERT INTO `sys_audit_log` VALUES (771, 1, 'admin', 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 289, '2025-12-28 14:10:47.814236');
INSERT INTO `sys_audit_log` VALUES (772, 1, 'admin', 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/3/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 773, '2025-12-28 14:11:05.061264');
INSERT INTO `sys_audit_log` VALUES (773, 1, 'admin', 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 267, '2025-12-28 14:11:33.541560');
INSERT INTO `sys_audit_log` VALUES (774, 1, 'admin', 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/1/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 592, '2025-12-28 14:11:53.967436');
INSERT INTO `sys_audit_log` VALUES (775, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 727, '2025-12-28 16:23:34.988604');
INSERT INTO `sys_audit_log` VALUES (776, 1, 'admin', 'omsapi.Controllers.PageController.CreateCategory (omsapi)', '/api/page/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 470, '2025-12-28 17:49:01.046290');
INSERT INTO `sys_audit_log` VALUES (777, 1, 'admin', 'omsapi.Controllers.PageController.CreateCategory (omsapi)', '/api/page/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 177, '2025-12-28 17:49:22.170203');
INSERT INTO `sys_audit_log` VALUES (778, 1, 'admin', 'omsapi.Controllers.PageController.CreateCategory (omsapi)', '/api/page/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 169, '2025-12-28 17:49:36.912557');
INSERT INTO `sys_audit_log` VALUES (779, 1, 'admin', 'omsapi.Controllers.PageController.CreatePage (omsapi)', '/api/page', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 244, '2025-12-28 17:49:54.316061');
INSERT INTO `sys_audit_log` VALUES (780, 1, 'admin', 'omsapi.Controllers.PageController.UpdatePage (omsapi)', '/api/page/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 181, '2025-12-28 17:54:26.789820');
INSERT INTO `sys_audit_log` VALUES (781, 1, 'admin', 'omsapi.Controllers.PageController.UpdatePage (omsapi)', '/api/page/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 157, '2025-12-28 17:55:04.035280');
INSERT INTO `sys_audit_log` VALUES (782, 1, 'admin', 'omsapi.Controllers.PageController.UpdatePage (omsapi)', '/api/page/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 155, '2025-12-28 17:56:31.125964');
INSERT INTO `sys_audit_log` VALUES (783, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 484, '2025-12-28 18:22:28.268808');
INSERT INTO `sys_audit_log` VALUES (784, 1, 'admin', 'omsapi.Controllers.PageController.UpdatePage (omsapi)', '/api/page/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 180, '2025-12-28 18:25:37.866478');
INSERT INTO `sys_audit_log` VALUES (785, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 702, '2025-12-28 20:58:44.088788');
INSERT INTO `sys_audit_log` VALUES (786, 1, 'admin', 'omsapi.Controllers.PageController.UpdatePage (omsapi)', '/api/page/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 388, '2025-12-28 21:06:45.382802');
INSERT INTO `sys_audit_log` VALUES (787, 1, 'admin', 'omsapi.Controllers.PageController.UpdatePage (omsapi)', '/api/page/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 163, '2025-12-28 21:11:19.464734');
INSERT INTO `sys_audit_log` VALUES (788, 1, 'admin', 'omsapi.Controllers.PageController.UpdateCategory (omsapi)', '/api/page/categories/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 133, '2025-12-28 21:12:31.196740');
INSERT INTO `sys_audit_log` VALUES (789, 1, 'admin', 'omsapi.Controllers.PageController.UpdateCategory (omsapi)', '/api/page/categories/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 77, '2025-12-28 21:12:42.864840');
INSERT INTO `sys_audit_log` VALUES (790, 1, 'admin', 'omsapi.Controllers.PageController.UpdateCategory (omsapi)', '/api/page/categories/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 155, '2025-12-28 21:13:16.111823');
INSERT INTO `sys_audit_log` VALUES (791, 1, 'admin', 'omsapi.Controllers.PageController.UpdateCategory (omsapi)', '/api/page/categories/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 450, '2025-12-28 21:18:08.698856');
INSERT INTO `sys_audit_log` VALUES (792, 1, 'admin', 'omsapi.Controllers.PageController.UpdateCategory (omsapi)', '/api/page/categories/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 341, '2025-12-28 21:18:14.456925');
INSERT INTO `sys_audit_log` VALUES (793, 1, 'admin', 'omsapi.Controllers.PageController.UpdatePage (omsapi)', '/api/page/1', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 191, '2025-12-28 21:25:33.145950');
INSERT INTO `sys_audit_log` VALUES (794, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 410, '2025-12-28 21:31:13.810002');
INSERT INTO `sys_audit_log` VALUES (795, 1, 'admin', 'omsapi.Controllers.ContractController.CreateContract (omsapi)', '/api/contract', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 180, '2025-12-28 22:45:22.724870');
INSERT INTO `sys_audit_log` VALUES (796, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 661, '2025-12-28 22:52:34.225530');
INSERT INTO `sys_audit_log` VALUES (797, 1, 'admin', 'omsapi.Controllers.ContractController.CreateKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 463, '2025-12-28 23:06:15.267781');
INSERT INTO `sys_audit_log` VALUES (798, 1, 'admin', 'omsapi.Controllers.ContractController.CreateKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 238, '2025-12-28 23:06:30.488883');
INSERT INTO `sys_audit_log` VALUES (799, 1, 'admin', 'omsapi.Controllers.ContractController.UpdateKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories/15', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 172, '2025-12-28 23:20:28.938678');
INSERT INTO `sys_audit_log` VALUES (800, 1, 'admin', 'omsapi.Controllers.ContractController.UpdateKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories/15', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 76, '2025-12-28 23:20:45.101536');
INSERT INTO `sys_audit_log` VALUES (801, 1, 'admin', 'omsapi.Controllers.ContractController.UpdateKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories/15', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 450, '2025-12-28 23:22:54.835528');
INSERT INTO `sys_audit_log` VALUES (802, 1, 'admin', 'omsapi.Controllers.ContractController.UpdateKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories/14', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 210, '2025-12-28 23:23:04.388450');
INSERT INTO `sys_audit_log` VALUES (803, 1, 'admin', 'omsapi.Controllers.ContractController.UpdateKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories/2', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 176, '2025-12-28 23:24:30.201247');
INSERT INTO `sys_audit_log` VALUES (804, 1, 'admin', 'omsapi.Controllers.ContractController.UpdateKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories/3', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 193, '2025-12-28 23:24:37.000151');
INSERT INTO `sys_audit_log` VALUES (805, 1, 'admin', 'omsapi.Controllers.ContractController.UpdateKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories/4', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 178, '2025-12-28 23:24:41.359432');
INSERT INTO `sys_audit_log` VALUES (806, 1, 'admin', 'omsapi.Controllers.ContractController.UpdateKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories/5', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 172, '2025-12-28 23:24:46.366003');
INSERT INTO `sys_audit_log` VALUES (807, 1, 'admin', 'omsapi.Controllers.ContractController.DeleteKnowledgeCategory (omsapi)', '/api/contract/knowledge/categories/1', 'DELETE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 193, '2025-12-28 23:24:53.710060');
INSERT INTO `sys_audit_log` VALUES (808, 1, 'admin', 'omsapi.Controllers.ContractController.UploadKnowledgeFile (omsapi)', '/api/contract/knowledge/files', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 200, '2025-12-28 23:25:29.339837');
INSERT INTO `sys_audit_log` VALUES (809, 1, 'admin', 'omsapi.Controllers.ContractController.UploadKnowledgeFile (omsapi)', '/api/contract/knowledge/files', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 563, '2025-12-28 23:31:26.559795');
INSERT INTO `sys_audit_log` VALUES (810, 1, 'admin', 'omsapi.Controllers.ContractController.UpdateKnowledgeFile (omsapi)', '/api/contract/knowledge/files/7', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 321, '2025-12-28 23:41:15.261703');
INSERT INTO `sys_audit_log` VALUES (811, 1, 'admin', 'omsapi.Controllers.ContractController.DeleteKnowledgeFile (omsapi)', '/api/contract/knowledge/files/7', 'DELETE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 195, '2025-12-28 23:42:23.389899');
INSERT INTO `sys_audit_log` VALUES (812, 1, 'admin', 'omsapi.Controllers.ContractController.UploadKnowledgeFile (omsapi)', '/api/contract/knowledge/files', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 627, '2025-12-28 23:45:56.310090');
INSERT INTO `sys_audit_log` VALUES (813, 1, 'admin', 'omsapi.Controllers.ContractController.DeleteKnowledgeFile (omsapi)', '/api/contract/knowledge/files/8', 'DELETE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 320, '2025-12-28 23:46:26.054059');
INSERT INTO `sys_audit_log` VALUES (814, 1, 'admin', 'omsapi.Controllers.ContractController.UpdateKnowledgeFile (omsapi)', '/api/contract/knowledge/files/5', 'PUT', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 162, '2025-12-28 23:46:36.205586');
INSERT INTO `sys_audit_log` VALUES (815, 1, 'admin', 'omsapi.Controllers.ContractController.UploadKnowledgeFile (omsapi)', '/api/contract/knowledge/files', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 319, '2025-12-28 23:46:45.021217');
INSERT INTO `sys_audit_log` VALUES (816, 1, 'admin', 'omsapi.Controllers.ContractController.DeleteKnowledgeFile (omsapi)', '/api/contract/knowledge/files/9', 'DELETE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 498, '2025-12-28 23:51:58.881985');
INSERT INTO `sys_audit_log` VALUES (817, 1, 'admin', 'omsapi.Controllers.ContractController.UploadKnowledgeFile (omsapi)', '/api/contract/knowledge/files', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 428, '2025-12-28 23:52:09.988912');
INSERT INTO `sys_audit_log` VALUES (818, 1, 'admin', 'omsapi.Controllers.ContractController.UploadKnowledgeFile (omsapi)', '/api/contract/knowledge/files', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 357, '2025-12-29 00:24:33.208750');
INSERT INTO `sys_audit_log` VALUES (819, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 308, '2025-12-29 09:47:50.112993');
INSERT INTO `sys_audit_log` VALUES (820, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=true', 1, NULL, 100, '2025-12-29 10:12:54.052400');
INSERT INTO `sys_audit_log` VALUES (821, 1, 'admin', 'omsapi.Controllers.InterfaceController.PublishInterface (omsapi)', '/api/interface/1/publish', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '?isPublished=false', 1, NULL, 29, '2025-12-29 10:13:07.712658');
INSERT INTO `sys_audit_log` VALUES (822, 1, 'admin', 'omsapi.Controllers.InterfaceController.DebugFlow (omsapi)', '/api/interface/debug-flow', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 236, '2025-12-29 10:14:03.015889');
INSERT INTO `sys_audit_log` VALUES (823, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 381, '2025-12-29 11:42:41.512832');
INSERT INTO `sys_audit_log` VALUES (824, 1, 'admin', 'omsapi.Controllers.DataSourceController.GetTableData (omsapi)', '/api/DataSource/1/databases/testdb/tables/test1/data', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 110, '2025-12-29 11:50:14.914668');
INSERT INTO `sys_audit_log` VALUES (825, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 299, '2025-12-29 15:29:37.312581');
INSERT INTO `sys_audit_log` VALUES (826, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 195, '2025-12-29 16:22:32.726879');
INSERT INTO `sys_audit_log` VALUES (827, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 874, '2025-12-29 17:21:52.542543');
INSERT INTO `sys_audit_log` VALUES (828, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.64(0x18004034) NetType/4G Language/zh_CN', NULL, 1, NULL, 159, '2025-12-29 18:48:54.225030');
INSERT INTO `sys_audit_log` VALUES (829, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.6261.95 Safari/537.36', NULL, 1, NULL, 214, '2025-12-29 22:59:18.626040');
INSERT INTO `sys_audit_log` VALUES (830, 1, 'admin', 'omsapi.Controllers.UserController.UpdateProfile (omsapi)', '/api/user/profile', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.6261.95 Safari/537.36', NULL, 1, NULL, 27, '2025-12-29 23:13:32.777841');
INSERT INTO `sys_audit_log` VALUES (831, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 NetType/WIFI MicroMessenger/7.0.20.1781(0x6700143B) WindowsWechat(0x63090c37) XWEB/14185 Flue', NULL, 1, NULL, 215, '2025-12-30 09:56:35.687897');
INSERT INTO `sys_audit_log` VALUES (832, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 242, '2025-12-30 18:37:32.527779');
INSERT INTO `sys_audit_log` VALUES (833, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 242, '2025-12-31 09:32:33.613986');
INSERT INTO `sys_audit_log` VALUES (834, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 NetType/WIFI MicroMessenger/7.0.20.1781(0x6700143B) WindowsWechat(0x63090a13) UnifiedPCWindowsWechat(0xf254151e) XWEB/17127 Flue', NULL, 1, NULL, 51, '2025-12-31 09:33:41.414397');
INSERT INTO `sys_audit_log` VALUES (835, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; CET-AL00 Build/HUAWEICET-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/5590 MicroMessenger/8.0.66.2980(0x28004252) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 197, '2025-12-31 11:22:51.218613');
INSERT INTO `sys_audit_log` VALUES (836, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Linux; Android 12; CET-AL00 Build/HUAWEICET-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.173 Mobile Safari/537.36 XWEB/1420113 MMWEBSDK/20251006 MMWEBID/5590 MicroMessenger/8.0.66.2980(0x28004252) WeChat/arm64 Weixin NetType/4G Language/zh_CN ABI/arm64', NULL, 1, NULL, 48, '2025-12-31 11:22:51.449627');
INSERT INTO `sys_audit_log` VALUES (837, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 935, '2026-01-01 10:39:36.545984');
INSERT INTO `sys_audit_log` VALUES (838, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 563, '2026-01-01 12:32:02.914724');
INSERT INTO `sys_audit_log` VALUES (839, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', NULL, 1, NULL, 265, '2026-01-01 19:12:05.801684');
INSERT INTO `sys_audit_log` VALUES (840, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 872, '2026-01-01 20:34:35.843464');
INSERT INTO `sys_audit_log` VALUES (841, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 492, '2026-01-01 21:59:59.853287');
INSERT INTO `sys_audit_log` VALUES (842, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 177, '2026-01-02 21:32:04.770738');
INSERT INTO `sys_audit_log` VALUES (843, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 899, '2026-01-02 21:59:08.235400');
INSERT INTO `sys_audit_log` VALUES (844, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 769, '2026-01-04 09:36:28.997933');
INSERT INTO `sys_audit_log` VALUES (845, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 727, '2026-01-04 14:41:08.628144');
INSERT INTO `sys_audit_log` VALUES (846, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 975, '2026-01-04 14:54:42.087402');
INSERT INTO `sys_audit_log` VALUES (847, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 850, '2026-01-04 14:55:02.591158');
INSERT INTO `sys_audit_log` VALUES (848, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 755, '2026-01-04 14:55:40.915255');
INSERT INTO `sys_audit_log` VALUES (849, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 732, '2026-01-04 14:57:45.781773');
INSERT INTO `sys_audit_log` VALUES (850, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1063, '2026-01-04 16:01:54.044107');
INSERT INTO `sys_audit_log` VALUES (851, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 341, '2026-01-04 16:15:25.007387');
INSERT INTO `sys_audit_log` VALUES (852, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 268, '2026-01-04 16:17:01.526832');
INSERT INTO `sys_audit_log` VALUES (853, 1, 'admin', 'omsapi.Controllers.UserController.Create (omsapi)', '/api/user', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 136, '2026-01-04 16:19:18.808086');
INSERT INTO `sys_audit_log` VALUES (854, 1, 'admin', 'omsapi.Controllers.RoleController.Create (omsapi)', '/api/role', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 100, '2026-01-04 16:19:45.463439');
INSERT INTO `sys_audit_log` VALUES (855, 1, 'admin', 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/4/permissions', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 81, '2026-01-04 16:20:13.786735');
INSERT INTO `sys_audit_log` VALUES (856, 1, 'admin', 'omsapi.Controllers.UserController.Update (omsapi)', '/api/user/5', 'PUT', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 393, '2026-01-04 16:45:58.169328');
INSERT INTO `sys_audit_log` VALUES (857, 1, 'admin', 'omsapi.Controllers.UserController.Create (omsapi)', '/api/user', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 101, '2026-01-04 16:46:32.047869');
INSERT INTO `sys_audit_log` VALUES (858, 1, 'admin', 'omsapi.Controllers.UserController.Create (omsapi)', '/api/user', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 71, '2026-01-04 16:47:03.320673');
INSERT INTO `sys_audit_log` VALUES (859, 1, 'admin', 'omsapi.Controllers.UserController.Create (omsapi)', '/api/user', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 66, '2026-01-04 16:47:42.611486');
INSERT INTO `sys_audit_log` VALUES (860, 1, 'admin', 'omsapi.Controllers.UserController.Create (omsapi)', '/api/user', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 79, '2026-01-04 16:48:04.100740');
INSERT INTO `sys_audit_log` VALUES (861, 7, 'rr', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 112, '2026-01-04 16:48:32.256679');
INSERT INTO `sys_audit_log` VALUES (862, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 715, '2026-01-04 17:00:57.975619');
INSERT INTO `sys_audit_log` VALUES (863, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1998, '2026-01-04 18:13:29.083854');
INSERT INTO `sys_audit_log` VALUES (864, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 810, '2026-01-04 18:13:30.635518');
INSERT INTO `sys_audit_log` VALUES (865, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 731, '2026-01-04 18:13:37.275852');
INSERT INTO `sys_audit_log` VALUES (866, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 735, '2026-01-04 18:13:41.515012');
INSERT INTO `sys_audit_log` VALUES (867, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 733, '2026-01-04 18:13:47.715033');
INSERT INTO `sys_audit_log` VALUES (868, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 722, '2026-01-04 18:13:57.331917');
INSERT INTO `sys_audit_log` VALUES (869, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 727, '2026-01-04 18:14:00.947055');
INSERT INTO `sys_audit_log` VALUES (870, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1452, '2026-01-04 18:16:24.680479');
INSERT INTO `sys_audit_log` VALUES (871, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1066, '2026-01-04 18:19:56.776057');
INSERT INTO `sys_audit_log` VALUES (872, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1907, '2026-01-04 18:19:57.620580');
INSERT INTO `sys_audit_log` VALUES (873, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 805, '2026-01-04 18:20:00.397177');
INSERT INTO `sys_audit_log` VALUES (874, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 784, '2026-01-04 18:20:02.993337');
INSERT INTO `sys_audit_log` VALUES (875, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 803, '2026-01-04 18:20:07.030522');
INSERT INTO `sys_audit_log` VALUES (876, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1254, '2026-01-04 18:20:07.938829');
INSERT INTO `sys_audit_log` VALUES (877, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1243, '2026-01-04 18:40:39.759296');
INSERT INTO `sys_audit_log` VALUES (878, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 871, '2026-01-04 18:40:42.077592');
INSERT INTO `sys_audit_log` VALUES (879, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 929, '2026-01-04 18:40:59.331483');
INSERT INTO `sys_audit_log` VALUES (880, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 786, '2026-01-04 18:41:13.074889');
INSERT INTO `sys_audit_log` VALUES (881, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 677, '2026-01-04 18:41:21.754150');
INSERT INTO `sys_audit_log` VALUES (882, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 702, '2026-01-04 18:41:23.946344');
INSERT INTO `sys_audit_log` VALUES (883, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 856, '2026-01-04 18:41:54.956499');
INSERT INTO `sys_audit_log` VALUES (884, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 853, '2026-01-04 18:41:57.453149');
INSERT INTO `sys_audit_log` VALUES (885, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 848, '2026-01-04 18:42:59.056623');
INSERT INTO `sys_audit_log` VALUES (886, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 844, '2026-01-04 18:43:22.319907');
INSERT INTO `sys_audit_log` VALUES (887, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 764, '2026-01-04 18:45:24.906574');
INSERT INTO `sys_audit_log` VALUES (888, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 685, '2026-01-04 18:45:29.502436');
INSERT INTO `sys_audit_log` VALUES (889, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 915, '2026-01-04 19:06:22.935527');
INSERT INTO `sys_audit_log` VALUES (890, 1, 'admin', 'Login', '/api/auth/login', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 895, '2026-01-04 19:14:09.453835');
INSERT INTO `sys_audit_log` VALUES (891, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 158, '2026-01-04 19:17:50.580038');
INSERT INTO `sys_audit_log` VALUES (892, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 185, '2026-01-04 19:17:50.636598');
INSERT INTO `sys_audit_log` VALUES (893, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 112, '2026-01-04 19:18:07.898312');
INSERT INTO `sys_audit_log` VALUES (894, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 114, '2026-01-04 19:18:07.973359');
INSERT INTO `sys_audit_log` VALUES (895, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 97, '2026-01-04 19:18:10.213912');
INSERT INTO `sys_audit_log` VALUES (896, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 99, '2026-01-04 19:18:10.294651');
INSERT INTO `sys_audit_log` VALUES (897, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 104, '2026-01-04 19:18:16.847902');
INSERT INTO `sys_audit_log` VALUES (898, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 112, '2026-01-04 19:18:16.922678');
INSERT INTO `sys_audit_log` VALUES (899, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 101, '2026-01-04 19:18:30.124164');
INSERT INTO `sys_audit_log` VALUES (900, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '::ffff:172.17.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 105, '2026-01-04 19:18:30.188984');
INSERT INTO `sys_audit_log` VALUES (901, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1059, '2026-01-04 19:22:21.518750');
INSERT INTO `sys_audit_log` VALUES (902, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 877, '2026-01-04 19:22:25.448909');
INSERT INTO `sys_audit_log` VALUES (903, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 805, '2026-01-04 19:22:34.866343');
INSERT INTO `sys_audit_log` VALUES (904, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 942, '2026-01-04 19:22:37.051157');
INSERT INTO `sys_audit_log` VALUES (905, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 862, '2026-01-04 19:25:07.224378');
INSERT INTO `sys_audit_log` VALUES (906, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 806, '2026-01-04 19:25:29.149104');
INSERT INTO `sys_audit_log` VALUES (907, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 891, '2026-01-04 19:25:40.675952');
INSERT INTO `sys_audit_log` VALUES (908, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 941, '2026-01-04 19:27:10.941527');
INSERT INTO `sys_audit_log` VALUES (909, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 878, '2026-01-04 19:27:37.772477');
INSERT INTO `sys_audit_log` VALUES (910, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 928, '2026-01-04 19:27:45.675202');
INSERT INTO `sys_audit_log` VALUES (911, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 877, '2026-01-04 19:27:49.377498');
INSERT INTO `sys_audit_log` VALUES (912, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 1056, '2026-01-04 19:39:43.884447');
INSERT INTO `sys_audit_log` VALUES (913, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 870, '2026-01-04 19:41:04.964307');
INSERT INTO `sys_audit_log` VALUES (914, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 764, '2026-01-04 19:41:12.628551');
INSERT INTO `sys_audit_log` VALUES (915, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 701, '2026-01-04 19:42:12.217275');
INSERT INTO `sys_audit_log` VALUES (916, 1, 'admin', 'omsapi.Controllers.ProjectController.SaveProject (omsapi)', '/api/project', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 750, '2026-01-04 19:42:41.566809');
INSERT INTO `sys_audit_log` VALUES (917, 1, 'admin', 'Login', '/api/auth/login', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 809, '2026-01-04 21:17:23.631614');
INSERT INTO `sys_audit_log` VALUES (918, 1, 'admin', 'omsapi.Controllers.PermissionController.Create (omsapi)', '/api/permission', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 299, '2026-01-04 21:18:35.713892');
INSERT INTO `sys_audit_log` VALUES (919, 1, 'admin', 'omsapi.Controllers.RoleController.AssignPermissions (omsapi)', '/api/role/3/permissions', 'POST', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', NULL, 1, NULL, 826, '2026-01-04 21:19:03.570352');

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
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (1, 8, '招标采购处', '', '', '', '', 0, 1, '2025-12-21 15:02:15.810127', '2025-12-27 01:29:45.304602', 3, 684.159816780738, 401.3466613003879);
INSERT INTO `sys_dept` VALUES (3, 8, '其他职能部门', '', '', '', '', 2, 1, '2025-12-21 15:15:42.957169', '2025-12-27 01:31:21.260779', 3, 1092.124737001896, 401.3466613003879);
INSERT INTO `sys_dept` VALUES (4, 3, 'XX子部门', '', '', '', '', 1, 0, '2025-12-21 15:15:57.732852', '2025-12-27 01:31:35.935769', 3, 1092.124737001896, 529.2120735097611);
INSERT INTO `sys_dept` VALUES (5, 8, '煤炭销售处', '', '', '', '', 1, 1, '2025-12-21 15:16:11.156509', '2025-12-27 01:31:23.433532', 3, 888.3211188784084, 401.3466613003879);
INSERT INTO `sys_dept` VALUES (7, NULL, '永泰能源集团', '', '', '', '', 1, 1, '2025-12-21 17:46:07.260401', '2025-12-27 01:07:29.277121', 1, NULL, NULL);
INSERT INTO `sys_dept` VALUES (8, 7, '煤炭采购销售中心', '', '', '', '', 4, 1, '2025-12-21 17:48:18.106421', '2025-12-27 01:31:40.279713', 2, 990.8907345884176, 220);
INSERT INTO `sys_dept` VALUES (12, 7, '监察审计部', '', '', '', '', 0, 1, '2025-12-27 01:09:21.030387', '2025-12-27 01:31:14.309736', 3, 112.55670049581012, 220);
INSERT INTO `sys_dept` VALUES (13, 7, '生产技术部', '', '', '', '', 1, 1, '2025-12-27 01:09:57.314821', '2025-12-27 01:31:11.239939', 3, 332.1675253718576, 220);
INSERT INTO `sys_dept` VALUES (14, 7, '财务管理部', '', '', '', '', 3, 1, '2025-12-27 01:10:20.786693', '2025-12-27 01:21:13.136252', 3, 758, 220);
INSERT INTO `sys_dept` VALUES (15, 7, '经营管理部', '', '', '', '', 2, 1, '2025-12-27 01:19:47.318708', '2025-12-27 01:31:08.957750', 3, 548.4226801983241, 220);
INSERT INTO `sys_dept` VALUES (16, 7, '二级单位：海则滩煤矿', '', '', '', '', 5, 1, '2025-12-27 01:22:05.966004', '2025-12-27 01:31:42.967108', 2, 1280.1005152231146, 220);
INSERT INTO `sys_dept` VALUES (17, 16, 'XX科室', '', '', '', '', 0, 1, '2025-12-27 01:28:42.879539', '2025-12-27 01:31:46.675732', 3, 1288.540289243329, 401.3466613003879);
INSERT INTO `sys_dept` VALUES (18, 16, 'XX区队', '', '', '', '', 1, 1, '2025-12-27 01:29:20.397411', '2025-12-27 01:31:51.085331', 3, 1488.280915982194, 401.3466613003879);
INSERT INTO `sys_dept` VALUES (19, 18, 'XX班组', '', '', '', '', 0, 1, '2025-12-27 01:29:38.104220', '2025-12-27 01:31:55.893569', 3, 1488.280915982194, 529.2120735097611);

-- ----------------------------
-- Table structure for sys_dict_category
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_category`;
CREATE TABLE `sys_dict_category`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` bigint NULL DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sort` int NOT NULL,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `IX_sys_dict_category_parent_id`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `FK_sys_dict_category_sys_dict_category_parent_id` FOREIGN KEY (`parent_id`) REFERENCES `sys_dict_category` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_category
-- ----------------------------
INSERT INTO `sys_dict_category` VALUES (1, NULL, '系统通用', 'sys_common', 1, '系统通用的字典数据', '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');
INSERT INTO `sys_dict_category` VALUES (2, NULL, '业务模块', 'biz_module', 2, '业务模块相关的字典数据', '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `dict_type_id` bigint NOT NULL,
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sort` int NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_default` tinyint(1) NOT NULL,
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_sys_dict_data_dict_type_id_value`(`dict_type_id` ASC, `value` ASC) USING BTREE,
  CONSTRAINT `FK_sys_dict_data_sys_dict_type_dict_type_id` FOREIGN KEY (`dict_type_id`) REFERENCES `sys_dict_type` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '正常', '1', 1, 'normal', 1, NULL, NULL, NULL, '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');
INSERT INTO `sys_dict_data` VALUES (2, 1, '停用', '0', 2, 'normal', 0, NULL, NULL, NULL, '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');
INSERT INTO `sys_dict_data` VALUES (3, 2, '男', '1', 1, 'normal', 1, NULL, NULL, NULL, '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');
INSERT INTO `sys_dict_data` VALUES (4, 2, '女', '2', 2, 'normal', 0, NULL, NULL, NULL, '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');
INSERT INTO `sys_dict_data` VALUES (5, 2, '未知', '0', 3, 'normal', 0, NULL, NULL, NULL, '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');
INSERT INTO `sys_dict_data` VALUES (6, 3, '重点客户', 'A', 1, 'normal', 0, NULL, NULL, NULL, '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');
INSERT INTO `sys_dict_data` VALUES (7, 3, '普通客户', 'B', 2, 'normal', 1, NULL, NULL, NULL, '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');
INSERT INTO `sys_dict_data` VALUES (8, 3, '低价值客户', 'C', 3, 'normal', 0, NULL, NULL, NULL, '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint NULL DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_sys_dict_type_code`(`code` ASC) USING BTREE,
  INDEX `IX_sys_dict_type_category_id`(`category_id` ASC) USING BTREE,
  CONSTRAINT `FK_sys_dict_type_sys_dict_category_category_id` FOREIGN KEY (`category_id`) REFERENCES `sys_dict_category` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, 1, '用户状态', 'sys_user_status', 'normal', '系统用户的状态', '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');
INSERT INTO `sys_dict_type` VALUES (2, 1, '用户性别', 'sys_user_gender', 'normal', '用户的性别', '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');
INSERT INTO `sys_dict_type` VALUES (3, 2, '客户等级', 'crm_customer_level', 'normal', 'CRM客户等级分类', '2026-01-04 21:10:46.164598', '2026-01-04 21:10:46.164598');

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
  CONSTRAINT `FK_sys_file_sys_dept_DeptId` FOREIGN KEY (`DeptId`) REFERENCES `sys_dept` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_sys_file_sys_file_ParentId` FOREIGN KEY (`ParentId`) REFERENCES `sys_file` (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_sys_file_sys_user_OwnerId` FOREIGN KEY (`OwnerId`) REFERENCES `sys_user` (`Id`) ON DELETE CASCADE ON UPDATE RESTRICT
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
  `Query` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `SortOrder` int NOT NULL,
  `IsVisible` tinyint(1) NOT NULL,
  `CreatedAt` datetime(6) NOT NULL,
  `UpdatedAt` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  UNIQUE INDEX `IX_sys_permission_Code`(`Code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 245 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_permission
-- ----------------------------
INSERT INTO `sys_permission` VALUES (1, NULL, '首页', 'HomeView', 'MENU', '/', 'views/HomeView.vue', NULL, 'ant-design:desktop-outlined', 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350342');
INSERT INTO `sys_permission` VALUES (2, NULL, '个人中心', 'personal', 'MENU', '/personal', 'Layout', NULL, 'ant-design:user-outlined', 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350453');
INSERT INTO `sys_permission` VALUES (3, 2, '任务事项', 'PersonalTodo', 'MENU', '/personal/todo', 'views/personal/TodoList.vue', NULL, NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350454');
INSERT INTO `sys_permission` VALUES (4, 2, '组织结构', 'PersonalOrganization', 'MENU', '/personal/organization', 'views/personal/Organization.vue', NULL, NULL, 50, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350457');
INSERT INTO `sys_permission` VALUES (5, 2, '消息中心', 'PersonalMessages', 'MENU', '/personal/messages', 'views/personal/Messages.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350456');
INSERT INTO `sys_permission` VALUES (6, 2, '文件网盘', 'PersonalDrive', 'MENU', '/personal/drive', 'views/personal/Drive.vue', NULL, NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350456');
INSERT INTO `sys_permission` VALUES (7, 2, '账号信息', 'PersonalAccount', 'MENU', '/personal/account', 'views/personal/Account.vue', NULL, NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350456');
INSERT INTO `sys_permission` VALUES (8, NULL, '合同管理', 'contract', 'MENU', '/contract', 'Layout', NULL, 'ant-design:file-text-outlined', 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350457');
INSERT INTO `sys_permission` VALUES (9, 8, '合同列表', 'ContractTrack', 'MENU', '/contract/track', 'views/contract/ContractTrack.vue', NULL, NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350457');
INSERT INTO `sys_permission` VALUES (10, 8, '合同模板', 'ContractTemplate', 'MENU', '/contract/template', 'views/contract/ContractTemplate.vue', NULL, NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350460');
INSERT INTO `sys_permission` VALUES (11, 8, '合同统计', 'ContractStats', 'MENU', '/contract/stats', 'views/contract/ContractStats.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350461');
INSERT INTO `sys_permission` VALUES (12, 8, '合同知识库', 'ContractKnowledge', 'MENU', '/contract/knowledge', 'views/contract/ContractKnowledge.vue', NULL, NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350461');
INSERT INTO `sys_permission` VALUES (13, NULL, '项目管理', 'project', 'MENU', '/project', 'Layout', NULL, 'ant-design:project-outlined', 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350462');
INSERT INTO `sys_permission` VALUES (14, 13, '项目列表', 'ProjectList', 'MENU', '/project/list', 'views/project/ProjectList.vue', NULL, NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350462');
INSERT INTO `sys_permission` VALUES (15, 13, '项目立项', 'ProjectInitiation', 'MENU', '/project/initiation', 'views/project/ProjectInitiation.vue', NULL, NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350464');
INSERT INTO `sys_permission` VALUES (16, 13, '项目模板', 'ProjectTemplate', 'MENU', '/project/template', 'views/project/ProjectTemplate.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350465');
INSERT INTO `sys_permission` VALUES (17, NULL, '财务管理', 'finance', 'MENU', '/finance', 'Layout', NULL, 'ant-design:pay-circle-outlined', 50, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350465');
INSERT INTO `sys_permission` VALUES (18, 17, '应收应付', 'FinanceApAr', 'MENU', '/finance/ap-ar', 'views/finance/apar/Index.vue', NULL, NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350466');
INSERT INTO `sys_permission` VALUES (19, 17, '发票管理', 'FinanceInvoice', 'MENU', '/finance/invoice', 'views/finance/invoice/Index.vue', NULL, NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350466');
INSERT INTO `sys_permission` VALUES (20, 17, '财务报表', 'FinanceReport', 'MENU', '/finance/report', 'views/finance/report/Index.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350467');
INSERT INTO `sys_permission` VALUES (21, NULL, '销售管理', 'sales', 'MENU', '/sales', 'Layout', NULL, 'ant-design:shopping-cart-outlined', 60, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350468');
INSERT INTO `sys_permission` VALUES (22, 21, '商机管理', 'SalesOpportunity', 'MENU', '/sales/opportunity', 'views/sales/Opportunity.vue', NULL, NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350468');
INSERT INTO `sys_permission` VALUES (23, 21, '客户管理', 'SalesCustomer', 'MENU', '/sales/customer', 'views/sales/Customer.vue', NULL, NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350469');
INSERT INTO `sys_permission` VALUES (24, 21, '销售资料', 'SalesMaterials', 'MENU', '/sales/materials', 'views/sales/Materials.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350469');
INSERT INTO `sys_permission` VALUES (25, 21, '销售目标', 'SalesTargets', 'MENU', '/sales/targets', 'views/sales/Targets.vue', NULL, NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350470');
INSERT INTO `sys_permission` VALUES (26, NULL, '采购管理', 'procurement', 'MENU', '/procurement', 'Layout', NULL, 'ant-design:shopping-outlined', 70, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350471');
INSERT INTO `sys_permission` VALUES (27, 26, '采购需求', 'ProcurementRequest', 'MENU', '/procurement/request', 'views/procurement/Request.vue', NULL, NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350471');
INSERT INTO `sys_permission` VALUES (28, 26, '采购订单', 'ProcurementOrder', 'MENU', '/procurement/order', 'views/procurement/Order.vue', NULL, NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350472');
INSERT INTO `sys_permission` VALUES (29, 26, '供应商管理', 'ProcurementSupplier', 'MENU', '/procurement/supplier', 'views/procurement/Supplier.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350473');
INSERT INTO `sys_permission` VALUES (30, 26, '历史采购', 'ProcurementHistory', 'MENU', '/procurement/history', 'views/procurement/History.vue', NULL, NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350474');
INSERT INTO `sys_permission` VALUES (31, NULL, '仓库管理', 'inventory', 'MENU', '/inventory', 'Layout', NULL, 'ant-design:shop-outlined', 500, 1, '2025-12-21 13:18:20.719546', '2025-12-22 21:59:23.943002');
INSERT INTO `sys_permission` VALUES (32, 31, '仓库基础', 'InventoryWarehouse', 'MENU', '/inventory/warehouse', 'views/inventory/Warehouse.vue', NULL, NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350475');
INSERT INTO `sys_permission` VALUES (33, 31, '库存物品', 'InventoryProduct', 'MENU', '/inventory/product-info', 'views/inventory/ProductInfo.vue', NULL, NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350476');
INSERT INTO `sys_permission` VALUES (34, 31, '出入库管理', 'InventoryInOut', 'MENU', '/inventory/in-out', 'views/inventory/InOut.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350477');
INSERT INTO `sys_permission` VALUES (35, 31, '库内作业', 'InventoryInternal', 'MENU', '/inventory/internal', 'views/inventory/InternalOps.vue', NULL, NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350477');
INSERT INTO `sys_permission` VALUES (36, 31, '库存盘点', 'InventoryStocktaking', 'MENU', '/inventory/stocktaking', 'views/inventory/Stocktaking.vue', NULL, NULL, 50, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350478');
INSERT INTO `sys_permission` VALUES (37, 31, '库存跟踪', 'InventoryTrack', 'MENU', '/inventory/track', 'views/inventory/InventoryTrack.vue', NULL, NULL, 60, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350479');
INSERT INTO `sys_permission` VALUES (38, 31, '库存分析', 'InventoryAnalysis', 'MENU', '/inventory/analysis', 'views/inventory/Analysis.vue', NULL, NULL, 70, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350480');
INSERT INTO `sys_permission` VALUES (39, NULL, '流程管理', 'bpm', 'MENU', '/bpm', 'Layout', NULL, 'ant-design:apartment-outlined', 600, 1, '2025-12-21 13:18:20.719546', '2025-12-22 21:59:05.481170');
INSERT INTO `sys_permission` VALUES (40, 39, '发起流程', 'StartWorkflow', 'MENU', '/bpm/start', 'views/bpm/StartWorkflow.vue', NULL, NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350482');
INSERT INTO `sys_permission` VALUES (41, 39, '流程设计', 'WorkflowDesign', 'MENU', '/bpm/workflow-design', 'views/bpm/WorkflowDesign.vue', NULL, NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350483');
INSERT INTO `sys_permission` VALUES (42, NULL, '数据分析', 'bi', 'MENU', '/bi', 'Layout', NULL, 'ant-design:bar-chart-outlined', 700, 1, '2025-12-21 13:18:20.719546', '2025-12-22 21:58:54.671121');
INSERT INTO `sys_permission` VALUES (43, 42, '经营仪表盘', 'BiDashboard', 'MENU', '/bi/dashboard', 'views/bi/BiDashboard.vue', NULL, NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350485');
INSERT INTO `sys_permission` VALUES (44, 42, '销售分析', 'BiSales', 'MENU', '/bi/sales', 'views/bi/BiSales.vue', NULL, NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350510');
INSERT INTO `sys_permission` VALUES (45, 42, '财务分析', 'BiFinance', 'MENU', '/bi/finance', 'views/bi/BiFinance.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350511');
INSERT INTO `sys_permission` VALUES (46, NULL, '档案管理', 'archive', 'MENU', '/archive', 'Layout', NULL, 'ant-design:book-outlined', 300, 1, '2025-12-22 15:47:30.000000', '2025-12-22 21:59:56.800395');
INSERT INTO `sys_permission` VALUES (48, NULL, '数据管理', 'data', 'MENU', '/data', 'Layout', NULL, 'ant-design:database-outlined', 800, 1, '2025-12-21 13:18:20.719546', '2025-12-22 21:58:41.434184');
INSERT INTO `sys_permission` VALUES (49, 48, '数据源管理', 'DataSource', 'MENU', '/data/source', 'views/data/DataSource/Index.vue', NULL, NULL, 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350515');
INSERT INTO `sys_permission` VALUES (50, 48, '外部接口管理', 'DataInterface', 'MENU', '/data/interface', 'views/data/DataInterface.vue', NULL, NULL, 20, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350516');
INSERT INTO `sys_permission` VALUES (51, 48, '接口发布管理', 'InterfacePublish', 'MENU', '/data/interface-publish', 'views/data/InterfacePublish/Index.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350518');
INSERT INTO `sys_permission` VALUES (52, 48, 'ETL管理', 'ETL', 'MENU', '/data/etl', 'views/data/ETL/Index.vue', NULL, NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350519');
INSERT INTO `sys_permission` VALUES (53, NULL, '系统管理', 'system', 'MENU', '/system', 'Layout', NULL, 'ant-design:setting-outlined', 990, 1, '2025-12-21 13:18:20.719546', '2025-12-21 17:14:36.614535');
INSERT INTO `sys_permission` VALUES (54, 53, '用户管理', 'SysUser', 'MENU', '/system/user', 'views/system/SysUser.vue', NULL, NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350530');
INSERT INTO `sys_permission` VALUES (55, 53, '角色管理', 'SysRole', 'MENU', '/system/role', 'views/system/SysRole.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350523');
INSERT INTO `sys_permission` VALUES (56, 53, '权限管理', 'SysPermission', 'MENU', '/system/permission', 'views/system/SysPermission.vue', NULL, NULL, 50, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350541');
INSERT INTO `sys_permission` VALUES (57, 53, '组织结构', 'SysOrg', 'MENU', '/system/org', 'views/system/SysOrg.vue', NULL, '', 10, 1, '2025-12-21 13:18:20.719546', '2025-12-21 23:29:08.051313');
INSERT INTO `sys_permission` VALUES (58, 53, '系统配置', 'SysConfig', 'MENU', '/system/config', 'views/system/SysConfig.vue', NULL, NULL, 60, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350542');
INSERT INTO `sys_permission` VALUES (59, 53, '数据安全', 'SysSecurity', 'MENU', '/system/security', 'views/system/SysSecurity.vue', NULL, NULL, 70, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350544');
INSERT INTO `sys_permission` VALUES (60, 53, '系统集成', 'SysIntegration', 'MENU', '/system/integration', 'views/system/SysIntegration.vue', NULL, NULL, 80, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350545');
INSERT INTO `sys_permission` VALUES (61, 54, '新增用户', 'system:user:add', 'BUTTON', NULL, NULL, NULL, NULL, 40, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350535');
INSERT INTO `sys_permission` VALUES (62, 54, '编辑用户', 'system:user:edit', 'BUTTON', NULL, NULL, NULL, NULL, 30, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350534');
INSERT INTO `sys_permission` VALUES (63, 54, '删除用户', 'system:user:delete', 'BUTTON', NULL, NULL, NULL, NULL, 20, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350533');
INSERT INTO `sys_permission` VALUES (64, 54, '重置密码', 'system:user:reset_pwd', 'BUTTON', NULL, NULL, NULL, NULL, 10, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350531');
INSERT INTO `sys_permission` VALUES (65, 55, '新增角色', 'system:role:add', 'BUTTON', NULL, NULL, NULL, NULL, 40, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350529');
INSERT INTO `sys_permission` VALUES (66, 55, '编辑角色', 'system:role:edit', 'BUTTON', NULL, NULL, NULL, NULL, 30, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350527');
INSERT INTO `sys_permission` VALUES (67, 55, '删除角色', 'system:role:delete', 'BUTTON', NULL, NULL, NULL, NULL, 20, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350526');
INSERT INTO `sys_permission` VALUES (68, 55, '分配权限', 'system:role:assign_perm', 'BUTTON', NULL, NULL, NULL, NULL, 10, 0, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350525');
INSERT INTO `sys_permission` VALUES (69, 9, '新建合同', 'contract:add', 'BUTTON', '', '', NULL, '', 10, 1, '2025-12-21 13:58:37.299112', '2025-12-21 15:51:09.350460');
INSERT INTO `sys_permission` VALUES (70, 53, '岗位管理', 'SysPost', 'MENU', '/system/post', 'views/system/SysPost.vue', NULL, '', 20, 1, '2025-12-21 15:24:31.385994', '2025-12-21 15:51:09.350522');
INSERT INTO `sys_permission` VALUES (71, NULL, '帮助中心', 'help', 'MENU', '/help', 'Layout', NULL, 'ant-design:file-text-outlined', 980, 1, '2025-12-21 17:14:11.323821', '2025-12-21 17:14:29.695189');
INSERT INTO `sys_permission` VALUES (72, 71, '用户手册', 'HelpManual', 'MENU', '/help/manual', 'views/help/HelpManual.vue', NULL, '', 1, 1, '2025-12-21 17:15:26.332443', NULL);
INSERT INTO `sys_permission` VALUES (73, 71, '运维手册', 'AdminManual', 'MENU', '/help/admin', 'views/help/AdminManual.vue', NULL, '', 2, 1, '2025-12-21 17:21:08.199435', NULL);
INSERT INTO `sys_permission` VALUES (102, 47, '全宗查看', 'archive:fond:view', 'BUTTON', NULL, NULL, NULL, NULL, 1, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (103, 47, '全宗新增', 'archive:fond:add', 'BUTTON', NULL, NULL, NULL, NULL, 2, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (104, 47, '全宗编辑', 'archive:fond:edit', 'BUTTON', NULL, NULL, NULL, NULL, 3, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (105, 47, '全宗删除', 'archive:fond:delete', 'BUTTON', NULL, NULL, NULL, NULL, 4, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (106, 47, '分类查看', 'archive:type:view', 'BUTTON', NULL, NULL, NULL, NULL, 5, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (107, 47, '分类新增', 'archive:type:add', 'BUTTON', NULL, NULL, NULL, NULL, 6, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (108, 47, '档案查看', 'archive:file:view', 'BUTTON', NULL, NULL, NULL, NULL, 7, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (109, 47, '档案新增', 'archive:file:add', 'BUTTON', NULL, NULL, NULL, NULL, 8, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (110, 47, '档案编辑', 'archive:file:edit', 'BUTTON', NULL, NULL, NULL, NULL, 9, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (111, 47, '档案删除', 'archive:file:delete', 'BUTTON', NULL, NULL, NULL, NULL, 10, 0, '2025-12-22 15:47:30.000000', NULL);
INSERT INTO `sys_permission` VALUES (201, 46, '电子档案', 'archive:electronic', 'MENU', '/archive/electronic', 'views/archive/electronic/Index.vue', NULL, NULL, 2, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (202, 46, '实物档案', 'archive:paper', 'MENU', '/archive/paper', 'views/archive/paper/Index.vue', NULL, NULL, 3, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (203, 46, '库房管理', 'archive:warehouse', 'MENU', '/archive/warehouse', 'views/archive/warehouse/Index.vue', NULL, NULL, 5, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (204, 46, '安全设置', 'archive:security', 'MENU', '/archive/security', 'views/archive/security/Index.vue', NULL, NULL, 6, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (205, 46, '借阅管理', 'archive:borrow', 'MENU', '/archive/borrow', 'views/archive/borrow/Index.vue', NULL, NULL, 4, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (210, 46, '统计分析', 'archive:analysis', 'MENU', '/archive/analysis', 'views/archive/analysis/Index.vue', NULL, NULL, 7, 1, '2025-12-22 17:15:35.000000', NULL);
INSERT INTO `sys_permission` VALUES (211, 13, '项目统计', 'ProjectStatistics', 'MENU', '/project/statistics', 'views/project/ProjectStatistics.vue', NULL, NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350465');
INSERT INTO `sys_permission` VALUES (212, 39, '流程监控', 'WorkflowMonitor', 'MENU', '/bpm/workflow-monitor', 'views/bpm/WorkflowMonitor.vue', NULL, NULL, 30, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350482');
INSERT INTO `sys_permission` VALUES (213, 39, '流程统计', 'WorkflowStatistics', 'MENU', '/bpm/workflow-statistics', 'views/bpm/WorkflowStatistics.vue', NULL, NULL, 40, 1, '2025-12-21 13:18:20.719546', '2025-12-21 15:51:09.350483');
INSERT INTO `sys_permission` VALUES (214, NULL, '资产管理', 'assets', 'MENU', '/assets', 'Layout', NULL, 'ant-design:inbox-outlined', 400, 1, '2025-12-22 19:20:41.958963', '2025-12-22 21:59:38.548024');
INSERT INTO `sys_permission` VALUES (215, 214, '固定资产', 'FixedAssets', 'MENU', '/assets/fixed-assets', 'views/assets/FixedAssets.vue', NULL, '', 10, 1, '2025-12-22 19:22:50.550256', '2025-12-22 19:23:53.011495');
INSERT INTO `sys_permission` VALUES (216, 214, '办公耗材', 'OfficeSupplies', 'MENU', '/assets/office-supplies', 'views/assets/OfficeSupplies.vue', NULL, '', 20, 1, '2025-12-22 19:23:39.920427', '2025-12-22 19:23:48.350114');
INSERT INTO `sys_permission` VALUES (217, 214, '流动资产', 'CurrentAssets', 'MENU', '/assets/current-assets', 'views/assets/CurrentAssets.vue', NULL, '', 30, 1, '2025-12-22 19:24:48.608986', NULL);
INSERT INTO `sys_permission` VALUES (218, 214, '资产统计', 'AssetsStatistics', 'MENU', '/assets/assets-statistics', 'views/assets/AssetsStatistics.vue', NULL, '', 40, 1, '2025-12-22 19:25:29.218888', '2025-12-22 19:25:38.441027');
INSERT INTO `sys_permission` VALUES (219, NULL, '开发测试', 'devtest', 'MENU', '/devtest', 'Layout', NULL, 'ant-design:code-outlined', 900, 1, '2025-12-22 21:36:43.897835', '2025-12-22 21:36:51.167403');
INSERT INTO `sys_permission` VALUES (220, 219, '三维测试', 'devtest-3d', 'MENU', '/devtest/3d', 'views/3d/Demo.vue', NULL, '', 1, 1, '2025-12-22 21:37:46.049299', NULL);
INSERT INTO `sys_permission` VALUES (221, NULL, '综合管理', 'Integrated', 'MENU', '/integrated', 'Layout', NULL, 'ant-design:mac-command-outlined', 200, 1, '2025-12-22 22:02:46.376401', '2025-12-22 22:03:03.919927');
INSERT INTO `sys_permission` VALUES (222, 221, '能耗管理', 'integrated:energy', 'MENU', '/integrated/energy', 'views/integrated/energy/Index.vue', NULL, '', 50, 1, '2025-12-22 22:04:46.559836', '2025-12-22 22:32:59.768419');
INSERT INTO `sys_permission` VALUES (223, NULL, '人力资源', 'hr', 'MENU', '/hr', 'Layout', NULL, 'fa:user-md', 100, 1, '2025-12-22 22:07:36.290249', NULL);
INSERT INTO `sys_permission` VALUES (224, 223, '员工管理', 'hr:employees', 'MENU', '/hr/employees', 'views/hr/employees/Index.vue', NULL, '', 10, 1, '2025-12-22 22:08:38.725012', NULL);
INSERT INTO `sys_permission` VALUES (225, 223, '招聘管理', 'hr:jobs', 'MENU', '/hr/jobs', 'views/hr/jobs/Index.vue', NULL, '', 20, 1, '2025-12-22 22:09:13.524985', NULL);
INSERT INTO `sys_permission` VALUES (226, 223, '培训管理', 'hr:trainning', 'MENU', '/hr/trainning', 'views/hr/trainning/Index.vue', NULL, '', 30, 1, '2025-12-22 22:09:40.983230', NULL);
INSERT INTO `sys_permission` VALUES (227, 223, '薪酬管理', 'hr:salary', 'MENU', '/hr/salary', 'views/hr/salary/Index.vue', NULL, '', 40, 1, '2025-12-22 22:10:18.348402', '2025-12-22 22:10:27.061795');
INSERT INTO `sys_permission` VALUES (228, 221, '车辆管理', 'integrated:vehicles', 'MENU', '/hr/vehicles', 'views/integrated/vehicles/Index.vue', NULL, '', 20, 1, '2025-12-22 22:11:41.850896', '2025-12-22 22:11:56.968036');
INSERT INTO `sys_permission` VALUES (229, 221, '会议室管理', 'integrated:meetrooms', 'MENU', '/integrated/meetrooms', 'views/integrated/meetrooms/Index.vue', NULL, '', 40, 1, '2025-12-22 22:13:07.411244', '2025-12-22 22:32:54.586956');
INSERT INTO `sys_permission` VALUES (230, 237, '董事长驾驶舱', 'dashboard:chairman', 'MENU', '/dashboard/chairman', 'views/dashboard/chairman/Index.vue', NULL, '', 100, 1, '2025-12-22 22:48:28.586789', '2025-12-22 23:09:28.418741');
INSERT INTO `sys_permission` VALUES (231, 237, '总经理驾驶舱', 'dashboardgm', 'MENU', '/dashboard/gm', 'views/dashboard/gm/Index.vue', NULL, '', 101, 1, '2025-12-22 22:48:59.076337', '2025-12-22 23:09:34.549612');
INSERT INTO `sys_permission` VALUES (232, 237, '销冠工作台', 'dashboard:sales', 'MENU', '/dashboard/sales', 'views/dashboard/sales/Index.vue', NULL, '', 102, 1, '2025-12-22 22:49:43.412054', '2025-12-22 23:09:40.670795');
INSERT INTO `sys_permission` VALUES (233, 237, '采购部驾驶舱', 'dashboard:procurements', 'MENU', '/dashboard/procurements', 'views/dashboard/procurements/Index.vue', NULL, '', 103, 1, '2025-12-22 22:50:38.958455', '2025-12-22 23:09:46.977542');
INSERT INTO `sys_permission` VALUES (234, 237, '产品运营视角', 'dashboard:production', 'MENU', '/dashboard/production', 'views/dashboard/production/Index.vue', NULL, '', 104, 1, '2025-12-22 22:51:29.948433', '2025-12-22 23:12:55.852199');
INSERT INTO `sys_permission` VALUES (235, 237, '研发项目工作', 'dashboard:dev', 'MENU', '/dashboard/dev', 'views/dashboard/dev/Index.vue', NULL, '', 105, 1, '2025-12-22 22:52:04.830281', '2025-12-22 23:11:43.394522');
INSERT INTO `sys_permission` VALUES (236, 237, '运维工程师看板', 'dashboard:engineer', 'MENU', '/dashboard/engineer', 'views/dashboard/engineer/Index.vue', NULL, '', 106, 1, '2025-12-22 22:53:36.241092', '2025-12-22 23:10:04.665801');
INSERT INTO `sys_permission` VALUES (237, NULL, '工作台演示', 'dashboard', 'MENU', '/dashboard', 'Layout', NULL, 'ant-design:dashboard-outlined', 25, 1, '2025-12-22 23:08:55.687978', '2025-12-22 23:09:18.342738');
INSERT INTO `sys_permission` VALUES (238, 42, '大屏设计', 'bi:design', 'MENU', '/bi/design', 'views/iframe/Index.vue', 'url=/bigview', '', 40, 1, '2025-12-24 17:01:57.205670', '2025-12-25 00:20:00.578028');
INSERT INTO `sys_permission` VALUES (239, 42, '大屏设计2', 'bi:design:1', 'MENU', '/bi/design', 'views/iframe/Index.vue', 'url=/bigview&id=1', '', 50, 1, '2025-12-25 00:51:31.583107', NULL);
INSERT INTO `sys_permission` VALUES (240, 48, '表单设计', 'DataForm', 'MENU', '/data/forms', 'views/data/Forms/Index.vue', '', '', 50, 1, '2025-12-25 19:54:40.641835', NULL);
INSERT INTO `sys_permission` VALUES (241, 240, '新建表单', 'form:create', 'BUTTON', '', '', '', '', 1, 1, '2025-12-26 21:55:41.548372', NULL);
INSERT INTO `sys_permission` VALUES (242, 48, '页面设计', 'DataPages', 'MENU', '/data/pages', 'views/data/Pages/Index.vue', '', '', 60, 1, '2025-12-28 14:10:47.618833', NULL);
INSERT INTO `sys_permission` VALUES (243, 242, '新建页面', 'page:create', 'BUTTON', '', '', '', '', 10, 1, '2025-12-28 14:11:33.364671', NULL);
INSERT INTO `sys_permission` VALUES (244, 53, '数据字典', 'SysDict', 'MENU', '/system/dict', 'views/dict/Index.vue', '', '', 55, 1, '2026-01-04 21:18:35.513801', NULL);

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (2, 'GMA', '主管领导', 1, 1, NULL, '2025-12-21 17:56:23.229837', '2025-12-27 01:37:47.466103', 1);
INSERT INTO `sys_post` VALUES (3, 'ZX001', '中心领导', 0, 1, NULL, '2025-12-27 01:36:13.638663', NULL, 8);
INSERT INTO `sys_post` VALUES (4, 'ZX002', '分管领导', 0, 1, NULL, '2025-12-27 01:38:03.623255', NULL, 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'SuperAdmin', '系统最高权限', 1, '2024-01-01 00:00:00.000000', '2025-12-26 21:28:38.725631', NULL);
INSERT INTO `sys_role` VALUES (2, '测试角色', 'TestUser', '', 0, '2025-12-21 13:34:16.829274', '2025-12-21 16:41:45.800604', 7);
INSERT INTO `sys_role` VALUES (3, '管理员', 'Admin', '', 1, '2025-12-26 21:24:13.196386', NULL, 7);
INSERT INTO `sys_role` VALUES (4, '普通用户', 'USERS', '', 0, '2026-01-04 16:19:45.384732', NULL, 7);

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
INSERT INTO `sys_role_inheritance` VALUES (1, 3);

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
INSERT INTO `sys_role_permission` VALUES (1, 1, '2025-12-28 14:11:53.620283');
INSERT INTO `sys_role_permission` VALUES (1, 2, '2025-12-28 14:11:53.620394');
INSERT INTO `sys_role_permission` VALUES (1, 3, '2025-12-28 14:11:53.620430');
INSERT INTO `sys_role_permission` VALUES (1, 4, '2025-12-28 14:11:53.620461');
INSERT INTO `sys_role_permission` VALUES (1, 5, '2025-12-28 14:11:53.620495');
INSERT INTO `sys_role_permission` VALUES (1, 6, '2025-12-28 14:11:53.620525');
INSERT INTO `sys_role_permission` VALUES (1, 7, '2025-12-28 14:11:53.620559');
INSERT INTO `sys_role_permission` VALUES (1, 8, '2025-12-28 14:11:53.620590');
INSERT INTO `sys_role_permission` VALUES (1, 9, '2025-12-28 14:11:53.620620');
INSERT INTO `sys_role_permission` VALUES (1, 10, '2025-12-28 14:11:53.620651');
INSERT INTO `sys_role_permission` VALUES (1, 11, '2025-12-28 14:11:53.620684');
INSERT INTO `sys_role_permission` VALUES (1, 12, '2025-12-28 14:11:53.620716');
INSERT INTO `sys_role_permission` VALUES (1, 13, '2025-12-28 14:11:53.620751');
INSERT INTO `sys_role_permission` VALUES (1, 14, '2025-12-28 14:11:53.620786');
INSERT INTO `sys_role_permission` VALUES (1, 15, '2025-12-28 14:11:53.620816');
INSERT INTO `sys_role_permission` VALUES (1, 16, '2025-12-28 14:11:53.620848');
INSERT INTO `sys_role_permission` VALUES (1, 17, '2025-12-28 14:11:53.620876');
INSERT INTO `sys_role_permission` VALUES (1, 18, '2025-12-28 14:11:53.620906');
INSERT INTO `sys_role_permission` VALUES (1, 19, '2025-12-28 14:11:53.620939');
INSERT INTO `sys_role_permission` VALUES (1, 20, '2025-12-28 14:11:53.620968');
INSERT INTO `sys_role_permission` VALUES (1, 21, '2025-12-28 14:11:53.620999');
INSERT INTO `sys_role_permission` VALUES (1, 22, '2025-12-28 14:11:53.621028');
INSERT INTO `sys_role_permission` VALUES (1, 23, '2025-12-28 14:11:53.621056');
INSERT INTO `sys_role_permission` VALUES (1, 24, '2025-12-28 14:11:53.621085');
INSERT INTO `sys_role_permission` VALUES (1, 25, '2025-12-28 14:11:53.621113');
INSERT INTO `sys_role_permission` VALUES (1, 26, '2025-12-28 14:11:53.621141');
INSERT INTO `sys_role_permission` VALUES (1, 27, '2025-12-28 14:11:53.621172');
INSERT INTO `sys_role_permission` VALUES (1, 28, '2025-12-28 14:11:53.621202');
INSERT INTO `sys_role_permission` VALUES (1, 29, '2025-12-28 14:11:53.621280');
INSERT INTO `sys_role_permission` VALUES (1, 30, '2025-12-28 14:11:53.621329');
INSERT INTO `sys_role_permission` VALUES (1, 31, '2025-12-28 14:11:53.622322');
INSERT INTO `sys_role_permission` VALUES (1, 32, '2025-12-28 14:11:53.622405');
INSERT INTO `sys_role_permission` VALUES (1, 33, '2025-12-28 14:11:53.622437');
INSERT INTO `sys_role_permission` VALUES (1, 34, '2025-12-28 14:11:53.622466');
INSERT INTO `sys_role_permission` VALUES (1, 35, '2025-12-28 14:11:53.622493');
INSERT INTO `sys_role_permission` VALUES (1, 36, '2025-12-28 14:11:53.622519');
INSERT INTO `sys_role_permission` VALUES (1, 37, '2025-12-28 14:11:53.622547');
INSERT INTO `sys_role_permission` VALUES (1, 38, '2025-12-28 14:11:53.622573');
INSERT INTO `sys_role_permission` VALUES (1, 39, '2025-12-28 14:11:53.622612');
INSERT INTO `sys_role_permission` VALUES (1, 40, '2025-12-28 14:11:53.622639');
INSERT INTO `sys_role_permission` VALUES (1, 41, '2025-12-28 14:11:53.622665');
INSERT INTO `sys_role_permission` VALUES (1, 42, '2025-12-28 14:11:53.622692');
INSERT INTO `sys_role_permission` VALUES (1, 43, '2025-12-28 14:11:53.622719');
INSERT INTO `sys_role_permission` VALUES (1, 44, '2025-12-28 14:11:53.622747');
INSERT INTO `sys_role_permission` VALUES (1, 45, '2025-12-28 14:11:53.622774');
INSERT INTO `sys_role_permission` VALUES (1, 46, '2025-12-28 14:11:53.622802');
INSERT INTO `sys_role_permission` VALUES (1, 47, '2025-12-28 14:11:53.622832');
INSERT INTO `sys_role_permission` VALUES (1, 48, '2025-12-28 14:11:53.622859');
INSERT INTO `sys_role_permission` VALUES (1, 49, '2025-12-28 14:11:53.622937');
INSERT INTO `sys_role_permission` VALUES (1, 50, '2025-12-28 14:11:53.622967');
INSERT INTO `sys_role_permission` VALUES (1, 51, '2025-12-28 14:11:53.623001');
INSERT INTO `sys_role_permission` VALUES (1, 52, '2025-12-28 14:11:53.623029');
INSERT INTO `sys_role_permission` VALUES (1, 53, '2025-12-28 14:11:53.623056');
INSERT INTO `sys_role_permission` VALUES (1, 54, '2025-12-28 14:11:53.623084');
INSERT INTO `sys_role_permission` VALUES (1, 55, '2025-12-28 14:11:53.623113');
INSERT INTO `sys_role_permission` VALUES (1, 56, '2025-12-28 14:11:53.623140');
INSERT INTO `sys_role_permission` VALUES (1, 57, '2025-12-28 14:11:53.623170');
INSERT INTO `sys_role_permission` VALUES (1, 58, '2025-12-28 14:11:53.623198');
INSERT INTO `sys_role_permission` VALUES (1, 59, '2025-12-28 14:11:53.623230');
INSERT INTO `sys_role_permission` VALUES (1, 60, '2025-12-28 14:11:53.623260');
INSERT INTO `sys_role_permission` VALUES (1, 61, '2025-12-28 14:11:53.623290');
INSERT INTO `sys_role_permission` VALUES (1, 62, '2025-12-28 14:11:53.623322');
INSERT INTO `sys_role_permission` VALUES (1, 63, '2025-12-28 14:11:53.623352');
INSERT INTO `sys_role_permission` VALUES (1, 64, '2025-12-28 14:11:53.623390');
INSERT INTO `sys_role_permission` VALUES (1, 65, '2025-12-28 14:11:53.623419');
INSERT INTO `sys_role_permission` VALUES (1, 66, '2025-12-28 14:11:53.623446');
INSERT INTO `sys_role_permission` VALUES (1, 67, '2025-12-28 14:11:53.623475');
INSERT INTO `sys_role_permission` VALUES (1, 68, '2025-12-28 14:11:53.623506');
INSERT INTO `sys_role_permission` VALUES (1, 69, '2025-12-28 14:11:53.623533');
INSERT INTO `sys_role_permission` VALUES (1, 70, '2025-12-28 14:11:53.623561');
INSERT INTO `sys_role_permission` VALUES (1, 71, '2025-12-28 14:11:53.623590');
INSERT INTO `sys_role_permission` VALUES (1, 72, '2025-12-28 14:11:53.623619');
INSERT INTO `sys_role_permission` VALUES (1, 73, '2025-12-28 14:11:53.623651');
INSERT INTO `sys_role_permission` VALUES (1, 74, '2025-12-28 14:11:53.623683');
INSERT INTO `sys_role_permission` VALUES (1, 102, '2025-12-28 14:11:53.623715');
INSERT INTO `sys_role_permission` VALUES (1, 103, '2025-12-28 14:11:53.623752');
INSERT INTO `sys_role_permission` VALUES (1, 104, '2025-12-28 14:11:53.623788');
INSERT INTO `sys_role_permission` VALUES (1, 105, '2025-12-28 14:11:53.623821');
INSERT INTO `sys_role_permission` VALUES (1, 106, '2025-12-28 14:11:53.623854');
INSERT INTO `sys_role_permission` VALUES (1, 107, '2025-12-28 14:11:53.623886');
INSERT INTO `sys_role_permission` VALUES (1, 108, '2025-12-28 14:11:53.623916');
INSERT INTO `sys_role_permission` VALUES (1, 109, '2025-12-28 14:11:53.623945');
INSERT INTO `sys_role_permission` VALUES (1, 110, '2025-12-28 14:11:53.624303');
INSERT INTO `sys_role_permission` VALUES (1, 111, '2025-12-28 14:11:53.624346');
INSERT INTO `sys_role_permission` VALUES (1, 201, '2025-12-28 14:11:53.624376');
INSERT INTO `sys_role_permission` VALUES (1, 202, '2025-12-28 14:11:53.624404');
INSERT INTO `sys_role_permission` VALUES (1, 203, '2025-12-28 14:11:53.624432');
INSERT INTO `sys_role_permission` VALUES (1, 204, '2025-12-28 14:11:53.624458');
INSERT INTO `sys_role_permission` VALUES (1, 205, '2025-12-28 14:11:53.624493');
INSERT INTO `sys_role_permission` VALUES (1, 206, '2025-12-28 14:11:53.624519');
INSERT INTO `sys_role_permission` VALUES (1, 207, '2025-12-28 14:11:53.624575');
INSERT INTO `sys_role_permission` VALUES (1, 208, '2025-12-28 14:11:53.624603');
INSERT INTO `sys_role_permission` VALUES (1, 209, '2025-12-28 14:11:53.624633');
INSERT INTO `sys_role_permission` VALUES (1, 210, '2025-12-28 14:11:53.624661');
INSERT INTO `sys_role_permission` VALUES (1, 211, '2025-12-28 14:11:53.624686');
INSERT INTO `sys_role_permission` VALUES (1, 212, '2025-12-28 14:11:53.624711');
INSERT INTO `sys_role_permission` VALUES (1, 213, '2025-12-28 14:11:53.624737');
INSERT INTO `sys_role_permission` VALUES (1, 214, '2025-12-28 14:11:53.624765');
INSERT INTO `sys_role_permission` VALUES (1, 215, '2025-12-28 14:11:53.624791');
INSERT INTO `sys_role_permission` VALUES (1, 216, '2025-12-28 14:11:53.624818');
INSERT INTO `sys_role_permission` VALUES (1, 217, '2025-12-28 14:11:53.624864');
INSERT INTO `sys_role_permission` VALUES (1, 218, '2025-12-28 14:11:53.624892');
INSERT INTO `sys_role_permission` VALUES (1, 219, '2025-12-28 14:11:53.624918');
INSERT INTO `sys_role_permission` VALUES (1, 220, '2025-12-28 14:11:53.624944');
INSERT INTO `sys_role_permission` VALUES (1, 221, '2025-12-28 14:11:53.624975');
INSERT INTO `sys_role_permission` VALUES (1, 222, '2025-12-28 14:11:53.625001');
INSERT INTO `sys_role_permission` VALUES (1, 223, '2025-12-28 14:11:53.625027');
INSERT INTO `sys_role_permission` VALUES (1, 224, '2025-12-28 14:11:53.625052');
INSERT INTO `sys_role_permission` VALUES (1, 225, '2025-12-28 14:11:53.625078');
INSERT INTO `sys_role_permission` VALUES (1, 226, '2025-12-28 14:11:53.625104');
INSERT INTO `sys_role_permission` VALUES (1, 227, '2025-12-28 14:11:53.625129');
INSERT INTO `sys_role_permission` VALUES (1, 228, '2025-12-28 14:11:53.625156');
INSERT INTO `sys_role_permission` VALUES (1, 229, '2025-12-28 14:11:53.625182');
INSERT INTO `sys_role_permission` VALUES (1, 230, '2025-12-28 14:11:53.625209');
INSERT INTO `sys_role_permission` VALUES (1, 231, '2025-12-28 14:11:53.625234');
INSERT INTO `sys_role_permission` VALUES (1, 232, '2025-12-28 14:11:53.625260');
INSERT INTO `sys_role_permission` VALUES (1, 233, '2025-12-28 14:11:53.625286');
INSERT INTO `sys_role_permission` VALUES (1, 234, '2025-12-28 14:11:53.625316');
INSERT INTO `sys_role_permission` VALUES (1, 235, '2025-12-28 14:11:53.625342');
INSERT INTO `sys_role_permission` VALUES (1, 236, '2025-12-28 14:11:53.625367');
INSERT INTO `sys_role_permission` VALUES (1, 237, '2025-12-28 14:11:53.625393');
INSERT INTO `sys_role_permission` VALUES (1, 238, '2025-12-28 14:11:53.625419');
INSERT INTO `sys_role_permission` VALUES (1, 239, '2025-12-28 14:11:53.625444');
INSERT INTO `sys_role_permission` VALUES (1, 240, '2025-12-28 14:11:53.625469');
INSERT INTO `sys_role_permission` VALUES (1, 241, '2025-12-28 14:11:53.625493');
INSERT INTO `sys_role_permission` VALUES (1, 242, '2025-12-28 14:11:53.625517');
INSERT INTO `sys_role_permission` VALUES (1, 243, '2025-12-28 14:11:53.625541');
INSERT INTO `sys_role_permission` VALUES (2, 1, '2025-12-26 21:30:48.363705');
INSERT INTO `sys_role_permission` VALUES (2, 2, '2025-12-26 21:30:48.364320');
INSERT INTO `sys_role_permission` VALUES (2, 3, '2025-12-26 21:30:48.364355');
INSERT INTO `sys_role_permission` VALUES (2, 4, '2025-12-26 21:30:48.364374');
INSERT INTO `sys_role_permission` VALUES (2, 5, '2025-12-26 21:30:48.364386');
INSERT INTO `sys_role_permission` VALUES (2, 6, '2025-12-26 21:30:48.364395');
INSERT INTO `sys_role_permission` VALUES (2, 7, '2025-12-26 21:30:48.364404');
INSERT INTO `sys_role_permission` VALUES (2, 48, '2025-12-26 21:30:48.364424');
INSERT INTO `sys_role_permission` VALUES (2, 240, '2025-12-26 21:30:48.364413');
INSERT INTO `sys_role_permission` VALUES (3, 1, '2026-01-04 21:19:03.086346');
INSERT INTO `sys_role_permission` VALUES (3, 2, '2026-01-04 21:19:03.088844');
INSERT INTO `sys_role_permission` VALUES (3, 3, '2026-01-04 21:19:03.088971');
INSERT INTO `sys_role_permission` VALUES (3, 4, '2026-01-04 21:19:03.088995');
INSERT INTO `sys_role_permission` VALUES (3, 5, '2026-01-04 21:19:03.089022');
INSERT INTO `sys_role_permission` VALUES (3, 6, '2026-01-04 21:19:03.089047');
INSERT INTO `sys_role_permission` VALUES (3, 7, '2026-01-04 21:19:03.089081');
INSERT INTO `sys_role_permission` VALUES (3, 8, '2026-01-04 21:19:03.089140');
INSERT INTO `sys_role_permission` VALUES (3, 9, '2026-01-04 21:19:03.089169');
INSERT INTO `sys_role_permission` VALUES (3, 10, '2026-01-04 21:19:03.089196');
INSERT INTO `sys_role_permission` VALUES (3, 11, '2026-01-04 21:19:03.089225');
INSERT INTO `sys_role_permission` VALUES (3, 12, '2026-01-04 21:19:03.089250');
INSERT INTO `sys_role_permission` VALUES (3, 13, '2026-01-04 21:19:03.089275');
INSERT INTO `sys_role_permission` VALUES (3, 14, '2026-01-04 21:19:03.089306');
INSERT INTO `sys_role_permission` VALUES (3, 15, '2026-01-04 21:19:03.089347');
INSERT INTO `sys_role_permission` VALUES (3, 16, '2026-01-04 21:19:03.089369');
INSERT INTO `sys_role_permission` VALUES (3, 17, '2026-01-04 21:19:03.089391');
INSERT INTO `sys_role_permission` VALUES (3, 18, '2026-01-04 21:19:03.089411');
INSERT INTO `sys_role_permission` VALUES (3, 19, '2026-01-04 21:19:03.089432');
INSERT INTO `sys_role_permission` VALUES (3, 20, '2026-01-04 21:19:03.089454');
INSERT INTO `sys_role_permission` VALUES (3, 21, '2026-01-04 21:19:03.089474');
INSERT INTO `sys_role_permission` VALUES (3, 22, '2026-01-04 21:19:03.089495');
INSERT INTO `sys_role_permission` VALUES (3, 23, '2026-01-04 21:19:03.089515');
INSERT INTO `sys_role_permission` VALUES (3, 24, '2026-01-04 21:19:03.089537');
INSERT INTO `sys_role_permission` VALUES (3, 25, '2026-01-04 21:19:03.089559');
INSERT INTO `sys_role_permission` VALUES (3, 26, '2026-01-04 21:19:03.089580');
INSERT INTO `sys_role_permission` VALUES (3, 27, '2026-01-04 21:19:03.089604');
INSERT INTO `sys_role_permission` VALUES (3, 28, '2026-01-04 21:19:03.089621');
INSERT INTO `sys_role_permission` VALUES (3, 29, '2026-01-04 21:19:03.089662');
INSERT INTO `sys_role_permission` VALUES (3, 30, '2026-01-04 21:19:03.089692');
INSERT INTO `sys_role_permission` VALUES (3, 31, '2026-01-04 21:19:03.089715');
INSERT INTO `sys_role_permission` VALUES (3, 32, '2026-01-04 21:19:03.089749');
INSERT INTO `sys_role_permission` VALUES (3, 33, '2026-01-04 21:19:03.089785');
INSERT INTO `sys_role_permission` VALUES (3, 34, '2026-01-04 21:19:03.089818');
INSERT INTO `sys_role_permission` VALUES (3, 35, '2026-01-04 21:19:03.089861');
INSERT INTO `sys_role_permission` VALUES (3, 36, '2026-01-04 21:19:03.089892');
INSERT INTO `sys_role_permission` VALUES (3, 37, '2026-01-04 21:19:03.089923');
INSERT INTO `sys_role_permission` VALUES (3, 38, '2026-01-04 21:19:03.089957');
INSERT INTO `sys_role_permission` VALUES (3, 39, '2026-01-04 21:19:03.089990');
INSERT INTO `sys_role_permission` VALUES (3, 40, '2026-01-04 21:19:03.090019');
INSERT INTO `sys_role_permission` VALUES (3, 41, '2026-01-04 21:19:03.090049');
INSERT INTO `sys_role_permission` VALUES (3, 42, '2026-01-04 21:19:03.090078');
INSERT INTO `sys_role_permission` VALUES (3, 43, '2026-01-04 21:19:03.090107');
INSERT INTO `sys_role_permission` VALUES (3, 44, '2026-01-04 21:19:03.090138');
INSERT INTO `sys_role_permission` VALUES (3, 45, '2026-01-04 21:19:03.090168');
INSERT INTO `sys_role_permission` VALUES (3, 46, '2026-01-04 21:19:03.090197');
INSERT INTO `sys_role_permission` VALUES (3, 48, '2026-01-04 21:19:03.090235');
INSERT INTO `sys_role_permission` VALUES (3, 49, '2026-01-04 21:19:03.090266');
INSERT INTO `sys_role_permission` VALUES (3, 50, '2026-01-04 21:19:03.090318');
INSERT INTO `sys_role_permission` VALUES (3, 51, '2026-01-04 21:19:03.090346');
INSERT INTO `sys_role_permission` VALUES (3, 52, '2026-01-04 21:19:03.090374');
INSERT INTO `sys_role_permission` VALUES (3, 53, '2026-01-04 21:19:03.090397');
INSERT INTO `sys_role_permission` VALUES (3, 54, '2026-01-04 21:19:03.090420');
INSERT INTO `sys_role_permission` VALUES (3, 55, '2026-01-04 21:19:03.090525');
INSERT INTO `sys_role_permission` VALUES (3, 56, '2026-01-04 21:19:03.090551');
INSERT INTO `sys_role_permission` VALUES (3, 57, '2026-01-04 21:19:03.090574');
INSERT INTO `sys_role_permission` VALUES (3, 58, '2026-01-04 21:19:03.090597');
INSERT INTO `sys_role_permission` VALUES (3, 59, '2026-01-04 21:19:03.090619');
INSERT INTO `sys_role_permission` VALUES (3, 60, '2026-01-04 21:19:03.090646');
INSERT INTO `sys_role_permission` VALUES (3, 61, '2026-01-04 21:19:03.090670');
INSERT INTO `sys_role_permission` VALUES (3, 62, '2026-01-04 21:19:03.090693');
INSERT INTO `sys_role_permission` VALUES (3, 63, '2026-01-04 21:19:03.090715');
INSERT INTO `sys_role_permission` VALUES (3, 64, '2026-01-04 21:19:03.090737');
INSERT INTO `sys_role_permission` VALUES (3, 65, '2026-01-04 21:19:03.090759');
INSERT INTO `sys_role_permission` VALUES (3, 66, '2026-01-04 21:19:03.090780');
INSERT INTO `sys_role_permission` VALUES (3, 67, '2026-01-04 21:19:03.090803');
INSERT INTO `sys_role_permission` VALUES (3, 68, '2026-01-04 21:19:03.090825');
INSERT INTO `sys_role_permission` VALUES (3, 69, '2026-01-04 21:19:03.090853');
INSERT INTO `sys_role_permission` VALUES (3, 70, '2026-01-04 21:19:03.090882');
INSERT INTO `sys_role_permission` VALUES (3, 71, '2026-01-04 21:19:03.090911');
INSERT INTO `sys_role_permission` VALUES (3, 72, '2026-01-04 21:19:03.090942');
INSERT INTO `sys_role_permission` VALUES (3, 73, '2026-01-04 21:19:03.090976');
INSERT INTO `sys_role_permission` VALUES (3, 201, '2026-01-04 21:19:03.091006');
INSERT INTO `sys_role_permission` VALUES (3, 202, '2026-01-04 21:19:03.091036');
INSERT INTO `sys_role_permission` VALUES (3, 203, '2026-01-04 21:19:03.091066');
INSERT INTO `sys_role_permission` VALUES (3, 204, '2026-01-04 21:19:03.091095');
INSERT INTO `sys_role_permission` VALUES (3, 205, '2026-01-04 21:19:03.091159');
INSERT INTO `sys_role_permission` VALUES (3, 210, '2026-01-04 21:19:03.091190');
INSERT INTO `sys_role_permission` VALUES (3, 211, '2026-01-04 21:19:03.091220');
INSERT INTO `sys_role_permission` VALUES (3, 212, '2026-01-04 21:19:03.091249');
INSERT INTO `sys_role_permission` VALUES (3, 213, '2026-01-04 21:19:03.091277');
INSERT INTO `sys_role_permission` VALUES (3, 214, '2026-01-04 21:19:03.091306');
INSERT INTO `sys_role_permission` VALUES (3, 215, '2026-01-04 21:19:03.091335');
INSERT INTO `sys_role_permission` VALUES (3, 216, '2026-01-04 21:19:03.091368');
INSERT INTO `sys_role_permission` VALUES (3, 217, '2026-01-04 21:19:03.091397');
INSERT INTO `sys_role_permission` VALUES (3, 218, '2026-01-04 21:19:03.091427');
INSERT INTO `sys_role_permission` VALUES (3, 219, '2026-01-04 21:19:03.091455');
INSERT INTO `sys_role_permission` VALUES (3, 220, '2026-01-04 21:19:03.091483');
INSERT INTO `sys_role_permission` VALUES (3, 221, '2026-01-04 21:19:03.091506');
INSERT INTO `sys_role_permission` VALUES (3, 222, '2026-01-04 21:19:03.091528');
INSERT INTO `sys_role_permission` VALUES (3, 223, '2026-01-04 21:19:03.091557');
INSERT INTO `sys_role_permission` VALUES (3, 224, '2026-01-04 21:19:03.091579');
INSERT INTO `sys_role_permission` VALUES (3, 225, '2026-01-04 21:19:03.091601');
INSERT INTO `sys_role_permission` VALUES (3, 226, '2026-01-04 21:19:03.091623');
INSERT INTO `sys_role_permission` VALUES (3, 227, '2026-01-04 21:19:03.091645');
INSERT INTO `sys_role_permission` VALUES (3, 228, '2026-01-04 21:19:03.091667');
INSERT INTO `sys_role_permission` VALUES (3, 229, '2026-01-04 21:19:03.091689');
INSERT INTO `sys_role_permission` VALUES (3, 230, '2026-01-04 21:19:03.091711');
INSERT INTO `sys_role_permission` VALUES (3, 231, '2026-01-04 21:19:03.091733');
INSERT INTO `sys_role_permission` VALUES (3, 232, '2026-01-04 21:19:03.091756');
INSERT INTO `sys_role_permission` VALUES (3, 233, '2026-01-04 21:19:03.091781');
INSERT INTO `sys_role_permission` VALUES (3, 234, '2026-01-04 21:19:03.091872');
INSERT INTO `sys_role_permission` VALUES (3, 235, '2026-01-04 21:19:03.091891');
INSERT INTO `sys_role_permission` VALUES (3, 236, '2026-01-04 21:19:03.091910');
INSERT INTO `sys_role_permission` VALUES (3, 237, '2026-01-04 21:19:03.091929');
INSERT INTO `sys_role_permission` VALUES (3, 238, '2026-01-04 21:19:03.091946');
INSERT INTO `sys_role_permission` VALUES (3, 239, '2026-01-04 21:19:03.091964');
INSERT INTO `sys_role_permission` VALUES (3, 240, '2026-01-04 21:19:03.091983');
INSERT INTO `sys_role_permission` VALUES (3, 241, '2026-01-04 21:19:03.092002');
INSERT INTO `sys_role_permission` VALUES (3, 242, '2026-01-04 21:19:03.092021');
INSERT INTO `sys_role_permission` VALUES (3, 244, '2026-01-04 21:19:03.092040');
INSERT INTO `sys_role_permission` VALUES (4, 1, '2026-01-04 16:20:13.747943');
INSERT INTO `sys_role_permission` VALUES (4, 2, '2026-01-04 16:20:13.755748');
INSERT INTO `sys_role_permission` VALUES (4, 3, '2026-01-04 16:20:13.755837');
INSERT INTO `sys_role_permission` VALUES (4, 4, '2026-01-04 16:20:13.755871');
INSERT INTO `sys_role_permission` VALUES (4, 5, '2026-01-04 16:20:13.755861');
INSERT INTO `sys_role_permission` VALUES (4, 6, '2026-01-04 16:20:13.755867');
INSERT INTO `sys_role_permission` VALUES (4, 7, '2026-01-04 16:20:13.755854');
INSERT INTO `sys_role_permission` VALUES (4, 13, '2026-01-04 16:20:13.755922');
INSERT INTO `sys_role_permission` VALUES (4, 14, '2026-01-04 16:20:13.755927');
INSERT INTO `sys_role_permission` VALUES (4, 15, '2026-01-04 16:20:13.755942');
INSERT INTO `sys_role_permission` VALUES (4, 16, '2026-01-04 16:20:13.755948');
INSERT INTO `sys_role_permission` VALUES (4, 211, '2026-01-04 16:20:13.755952');
INSERT INTO `sys_role_permission` VALUES (4, 230, '2026-01-04 16:20:13.755885');
INSERT INTO `sys_role_permission` VALUES (4, 231, '2026-01-04 16:20:13.755889');
INSERT INTO `sys_role_permission` VALUES (4, 232, '2026-01-04 16:20:13.755896');
INSERT INTO `sys_role_permission` VALUES (4, 233, '2026-01-04 16:20:13.755900');
INSERT INTO `sys_role_permission` VALUES (4, 234, '2026-01-04 16:20:13.755904');
INSERT INTO `sys_role_permission` VALUES (4, 235, '2026-01-04 16:20:13.755912');
INSERT INTO `sys_role_permission` VALUES (4, 236, '2026-01-04 16:20:13.755917');
INSERT INTO `sys_role_permission` VALUES (4, 237, '2026-01-04 16:20:13.755878');

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
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', NULL, NULL, NULL, 1, '2024-01-01 00:00:00.000000', '2026-01-04 21:17:23.085847', '/uploads/avatars/1_09f7e7b6-b435-4c3d-b58b-952aa2e8a1cb.jpg', 7, 'business');
INSERT INTO `sys_user` VALUES (2, 'test', 'ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae', '测试用户', 'test@jinlan.info', '13333333333', 1, '2025-12-21 13:34:02.083370', '2025-12-26 21:57:51.860311', NULL, 1, NULL);
INSERT INTO `sys_user` VALUES (4, 'superadmin', '54c51096a4299686282a734e240cf3e5382b709e40077f32633f86a74b72c39e', '超级管理员', 'raorong@jinlan.info', '13551252357', 1, '2025-12-26 21:22:47.372200', '2025-12-26 21:37:49.670183', '/uploads/avatars/4_43dfd44a-15b4-4a43-b1f1-c53b9182a90d.jpg', 7, 'online');
INSERT INTO `sys_user` VALUES (5, 'hl', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '黄亮', '', '', 1, '2026-01-04 16:19:18.691068', NULL, NULL, 7, 'online');
INSERT INTO `sys_user` VALUES (6, 'wzh', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '王子恒', NULL, NULL, 1, '2026-01-04 16:46:31.972521', NULL, NULL, 7, 'online');
INSERT INTO `sys_user` VALUES (7, 'rr', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '饶荣', NULL, NULL, 1, '2026-01-04 16:47:03.262534', '2026-01-04 16:48:32.164669', NULL, 7, 'online');
INSERT INTO `sys_user` VALUES (8, 'fxy', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '范新悦', NULL, NULL, 1, '2026-01-04 16:47:42.557470', NULL, NULL, 7, 'online');
INSERT INTO `sys_user` VALUES (9, 'ljf', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '李俊锋', NULL, NULL, 1, '2026-01-04 16:48:04.037904', NULL, NULL, 7, 'online');

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
INSERT INTO `sys_user_role` VALUES (1, 3, '2025-12-21 18:06:14.190891');
INSERT INTO `sys_user_role` VALUES (2, 2, '2025-12-21 17:58:48.113620');
INSERT INTO `sys_user_role` VALUES (4, 1, '2025-12-26 21:22:47.532953');
INSERT INTO `sys_user_role` VALUES (5, 4, '2026-01-04 16:45:57.976050');
INSERT INTO `sys_user_role` VALUES (6, 4, '2026-01-04 16:46:32.021583');
INSERT INTO `sys_user_role` VALUES (7, 4, '2026-01-04 16:47:03.294699');
INSERT INTO `sys_user_role` VALUES (8, 4, '2026-01-04 16:47:42.586647');
INSERT INTO `sys_user_role` VALUES (9, 4, '2026-01-04 16:48:04.071436');

SET FOREIGN_KEY_CHECKS = 1;
