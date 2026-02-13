-- Add Chinese comments to all tables and columns (MySQL)

-- api_category
ALTER TABLE `api_category` COMMENT = 'API分类';
ALTER TABLE `api_category` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `api_category` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `api_category` MODIFY COLUMN `ParentId` bigint NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `api_category` MODIFY COLUMN `SortOrder` int NOT NULL COMMENT '排序';
ALTER TABLE `api_category` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `api_category` MODIFY COLUMN `CreatedBy` bigint NULL DEFAULT NULL COMMENT '创建人';
ALTER TABLE `api_category` MODIFY COLUMN `UrlPrefix` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'UrlPrefix';

-- api_definition
ALTER TABLE `api_definition` COMMENT = 'API定义';
ALTER TABLE `api_definition` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `api_definition` MODIFY COLUMN `CategoryId` bigint NOT NULL COMMENT 'CategoryId';
ALTER TABLE `api_definition` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `api_definition` MODIFY COLUMN `Path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '路径';
ALTER TABLE `api_definition` MODIFY COLUMN `Method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Method';
ALTER TABLE `api_definition` MODIFY COLUMN `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述';
ALTER TABLE `api_definition` MODIFY COLUMN `FlowConfig` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'FlowConfig';
ALTER TABLE `api_definition` MODIFY COLUMN `IsPublished` tinyint(1) NOT NULL COMMENT 'IsPublished';
ALTER TABLE `api_definition` MODIFY COLUMN `RequiresAuth` tinyint(1) NOT NULL COMMENT 'RequiresAuth';
ALTER TABLE `api_definition` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `api_definition` MODIFY COLUMN `UpdatedAt` datetime(6) NOT NULL COMMENT '更新时间';
ALTER TABLE `api_definition` MODIFY COLUMN `CreatedBy` bigint NULL DEFAULT NULL COMMENT '创建人';
ALTER TABLE `api_definition` MODIFY COLUMN `UpdatedBy` bigint NULL DEFAULT NULL COMMENT '更新人';
ALTER TABLE `api_definition` MODIFY COLUMN `ManageRoles` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ManageRoles';
ALTER TABLE `api_definition` MODIFY COLUMN `ViewRoles` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ViewRoles';
ALTER TABLE `api_definition` MODIFY COLUMN `CallRoles` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'CallRoles';

-- arch_attachment
ALTER TABLE `arch_attachment` COMMENT = '档案附件';
ALTER TABLE `arch_attachment` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `arch_attachment` MODIFY COLUMN `ArchFileId` bigint NOT NULL COMMENT 'ArchFileId';
ALTER TABLE `arch_attachment` MODIFY COLUMN `FileId` bigint NULL DEFAULT NULL COMMENT '文件ID';
ALTER TABLE `arch_attachment` MODIFY COLUMN `FileName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '文件名';
ALTER TABLE `arch_attachment` MODIFY COLUMN `Extension` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '扩展名';
ALTER TABLE `arch_attachment` MODIFY COLUMN `Size` bigint NOT NULL COMMENT 'Size';
ALTER TABLE `arch_attachment` MODIFY COLUMN `FilePath` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文件路径';
ALTER TABLE `arch_attachment` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';

-- arch_box
ALTER TABLE `arch_box` COMMENT = '档案盒';
ALTER TABLE `arch_box` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `arch_box` MODIFY COLUMN `FondId` bigint NOT NULL COMMENT 'FondId';
ALTER TABLE `arch_box` MODIFY COLUMN `TypeId` bigint NOT NULL COMMENT '类型ID';
ALTER TABLE `arch_box` MODIFY COLUMN `BoxCode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'BoxCode';
ALTER TABLE `arch_box` MODIFY COLUMN `Title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标题';
ALTER TABLE `arch_box` MODIFY COLUMN `Year` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Year';
ALTER TABLE `arch_box` MODIFY COLUMN `RetentionPeriod` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'RetentionPeriod';
ALTER TABLE `arch_box` MODIFY COLUMN `SecurityLevel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'SecurityLevel';
ALTER TABLE `arch_box` MODIFY COLUMN `Location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Location';
ALTER TABLE `arch_box` MODIFY COLUMN `RFID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'RFID';
ALTER TABLE `arch_box` MODIFY COLUMN `FileCount` int NOT NULL COMMENT 'FileCount';
ALTER TABLE `arch_box` MODIFY COLUMN `Remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注';
ALTER TABLE `arch_box` MODIFY COLUMN `Status` int NOT NULL COMMENT '状态';
ALTER TABLE `arch_box` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';

-- arch_file
ALTER TABLE `arch_file` COMMENT = '档案文件';
ALTER TABLE `arch_file` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `arch_file` MODIFY COLUMN `FondId` bigint NOT NULL COMMENT 'FondId';
ALTER TABLE `arch_file` MODIFY COLUMN `TypeId` bigint NOT NULL COMMENT '类型ID';
ALTER TABLE `arch_file` MODIFY COLUMN `BoxId` bigint NULL DEFAULT NULL COMMENT 'BoxId';
ALTER TABLE `arch_file` MODIFY COLUMN `ArchCode` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ArchCode';
ALTER TABLE `arch_file` MODIFY COLUMN `Title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题';
ALTER TABLE `arch_file` MODIFY COLUMN `DocNumber` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'DocNumber';
ALTER TABLE `arch_file` MODIFY COLUMN `Author` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Author';
ALTER TABLE `arch_file` MODIFY COLUMN `FileDate` datetime(6) NULL DEFAULT NULL COMMENT 'FileDate';
ALTER TABLE `arch_file` MODIFY COLUMN `Year` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Year';
ALTER TABLE `arch_file` MODIFY COLUMN `RetentionPeriod` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'RetentionPeriod';
ALTER TABLE `arch_file` MODIFY COLUMN `SecurityLevel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'SecurityLevel';
ALTER TABLE `arch_file` MODIFY COLUMN `PageCount` int NOT NULL COMMENT 'PageCount';
ALTER TABLE `arch_file` MODIFY COLUMN `Status` int NOT NULL COMMENT '状态';
ALTER TABLE `arch_file` MODIFY COLUMN `Keywords` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Keywords';
ALTER TABLE `arch_file` MODIFY COLUMN `Remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注';
ALTER TABLE `arch_file` MODIFY COLUMN `SourceFileId` bigint NULL DEFAULT NULL COMMENT 'SourceFileId';
ALTER TABLE `arch_file` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `arch_file` MODIFY COLUMN `UpdatedAt` datetime(6) NOT NULL COMMENT '更新时间';

-- arch_fond
ALTER TABLE `arch_fond` COMMENT = '全宗';
ALTER TABLE `arch_fond` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `arch_fond` MODIFY COLUMN `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '代码';
ALTER TABLE `arch_fond` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `arch_fond` MODIFY COLUMN `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述';
ALTER TABLE `arch_fond` MODIFY COLUMN `SortOrder` int NOT NULL COMMENT '排序';
ALTER TABLE `arch_fond` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';

-- arch_type
ALTER TABLE `arch_type` COMMENT = '档案分类';
ALTER TABLE `arch_type` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `arch_type` MODIFY COLUMN `ParentId` bigint NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `arch_type` MODIFY COLUMN `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '代码';
ALTER TABLE `arch_type` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `arch_type` MODIFY COLUMN `SortOrder` int NOT NULL COMMENT '排序';

-- bigview_project
ALTER TABLE `bigview_project` COMMENT = '大屏项目';
ALTER TABLE `bigview_project` MODIFY COLUMN `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `bigview_project` MODIFY COLUMN `project_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'project_name';
ALTER TABLE `bigview_project` MODIFY COLUMN `state` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '状态 [-1未发布,1发布]';
ALTER TABLE `bigview_project` MODIFY COLUMN `create_time` datetime(6) NULL DEFAULT NULL COMMENT '创建时间';
ALTER TABLE `bigview_project` MODIFY COLUMN `create_by` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '创建人';
ALTER TABLE `bigview_project` MODIFY COLUMN `is_delete` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否删除';
ALTER TABLE `bigview_project` MODIFY COLUMN `index_image` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'index_image';
ALTER TABLE `bigview_project` MODIFY COLUMN `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '内容';
ALTER TABLE `bigview_project` MODIFY COLUMN `remarks` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注';

-- contract_attachment
ALTER TABLE `contract_attachment` COMMENT = '合同附件';
ALTER TABLE `contract_attachment` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_attachment` MODIFY COLUMN `contract_id` bigint NOT NULL COMMENT 'contract_id';
ALTER TABLE `contract_attachment` MODIFY COLUMN `file_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '文件名';
ALTER TABLE `contract_attachment` MODIFY COLUMN `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文件路径';
ALTER TABLE `contract_attachment` MODIFY COLUMN `size` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'size';
ALTER TABLE `contract_attachment` MODIFY COLUMN `upload_date` datetime(6) NOT NULL COMMENT 'upload_date';

-- contract_contact
ALTER TABLE `contract_contact` COMMENT = '合同联系人';
ALTER TABLE `contract_contact` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_contact` MODIFY COLUMN `contract_id` bigint NOT NULL COMMENT 'contract_id';
ALTER TABLE `contract_contact` MODIFY COLUMN `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `contract_contact` MODIFY COLUMN `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'role';
ALTER TABLE `contract_contact` MODIFY COLUMN `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话';
ALTER TABLE `contract_contact` MODIFY COLUMN `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱';

-- contract_invoice
ALTER TABLE `contract_invoice` COMMENT = '合同发票';
ALTER TABLE `contract_invoice` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_invoice` MODIFY COLUMN `contract_id` bigint NOT NULL COMMENT 'contract_id';
ALTER TABLE `contract_invoice` MODIFY COLUMN `invoice_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'invoice_no';
ALTER TABLE `contract_invoice` MODIFY COLUMN `invoice_date` datetime(6) NOT NULL COMMENT 'invoice_date';
ALTER TABLE `contract_invoice` MODIFY COLUMN `amount` decimal(18, 2) NOT NULL COMMENT 'amount';
ALTER TABLE `contract_invoice` MODIFY COLUMN `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型';
ALTER TABLE `contract_invoice` MODIFY COLUMN `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';
ALTER TABLE `contract_invoice` MODIFY COLUMN `attachment_file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'attachment_file_name';
ALTER TABLE `contract_invoice` MODIFY COLUMN `attachment_file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'attachment_file_path';
ALTER TABLE `contract_invoice` MODIFY COLUMN `direction` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'direction';

-- contract_knowledge_category
ALTER TABLE `contract_knowledge_category` COMMENT = '合同知识分类';
ALTER TABLE `contract_knowledge_category` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_knowledge_category` MODIFY COLUMN `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `contract_knowledge_category` MODIFY COLUMN `parent_id` bigint NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `contract_knowledge_category` MODIFY COLUMN `sort_order` int NOT NULL COMMENT 'sort_order';
ALTER TABLE `contract_knowledge_category` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';

-- contract_knowledge_file
ALTER TABLE `contract_knowledge_file` COMMENT = '合同知识文件';
ALTER TABLE `contract_knowledge_file` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_knowledge_file` MODIFY COLUMN `category_id` bigint NOT NULL COMMENT 'category_id';
ALTER TABLE `contract_knowledge_file` MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `contract_knowledge_file` MODIFY COLUMN `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型';
ALTER TABLE `contract_knowledge_file` MODIFY COLUMN `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文件路径';
ALTER TABLE `contract_knowledge_file` MODIFY COLUMN `size` bigint NOT NULL DEFAULT 0 COMMENT 'size';
ALTER TABLE `contract_knowledge_file` MODIFY COLUMN `uploader` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'uploader';
ALTER TABLE `contract_knowledge_file` MODIFY COLUMN `upload_time` datetime(6) NOT NULL COMMENT 'upload_time';
ALTER TABLE `contract_knowledge_file` MODIFY COLUMN `content_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'content_type';

-- contract_main
ALTER TABLE `contract_main` COMMENT = '合同主表';
ALTER TABLE `contract_main` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_main` MODIFY COLUMN `contract_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'contract_no';
ALTER TABLE `contract_main` MODIFY COLUMN `contract_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'contract_name';
ALTER TABLE `contract_main` MODIFY COLUMN `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型';
ALTER TABLE `contract_main` MODIFY COLUMN `partner_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'partner_name';
ALTER TABLE `contract_main` MODIFY COLUMN `sign_date` datetime(6) NULL DEFAULT NULL COMMENT 'sign_date';
ALTER TABLE `contract_main` MODIFY COLUMN `start_date` datetime(6) NULL DEFAULT NULL COMMENT 'start_date';
ALTER TABLE `contract_main` MODIFY COLUMN `end_date` datetime(6) NULL DEFAULT NULL COMMENT 'end_date';
ALTER TABLE `contract_main` MODIFY COLUMN `manager` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'manager';
ALTER TABLE `contract_main` MODIFY COLUMN `total_amount` decimal(18, 2) NOT NULL COMMENT 'total_amount';
ALTER TABLE `contract_main` MODIFY COLUMN `paid_amount` decimal(18, 2) NOT NULL COMMENT 'paid_amount';
ALTER TABLE `contract_main` MODIFY COLUMN `invoiced_amount` decimal(18, 2) NOT NULL COMMENT 'invoiced_amount';
ALTER TABLE `contract_main` MODIFY COLUMN `progress` int NOT NULL COMMENT 'progress';
ALTER TABLE `contract_main` MODIFY COLUMN `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'currency';
ALTER TABLE `contract_main` MODIFY COLUMN `payment_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'payment_method';
ALTER TABLE `contract_main` MODIFY COLUMN `tax_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'tax_id';
ALTER TABLE `contract_main` MODIFY COLUMN `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';
ALTER TABLE `contract_main` MODIFY COLUMN `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '描述';
ALTER TABLE `contract_main` MODIFY COLUMN `latest_transaction_date` datetime(6) NULL DEFAULT NULL COMMENT 'latest_transaction_date';
ALTER TABLE `contract_main` MODIFY COLUMN `files` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'files';
ALTER TABLE `contract_main` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `contract_main` MODIFY COLUMN `updated_at` datetime(6) NULL DEFAULT NULL COMMENT 'updated_at';
ALTER TABLE `contract_main` MODIFY COLUMN `lifecycle_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'lifecycle_status';
ALTER TABLE `contract_main` MODIFY COLUMN `pricing_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'pricing_type';

-- contract_payment_plan
ALTER TABLE `contract_payment_plan` COMMENT = '合同付款计划';
ALTER TABLE `contract_payment_plan` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_payment_plan` MODIFY COLUMN `contract_id` bigint NOT NULL COMMENT 'contract_id';
ALTER TABLE `contract_payment_plan` MODIFY COLUMN `phase` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'phase';
ALTER TABLE `contract_payment_plan` MODIFY COLUMN `due_date` datetime(6) NULL DEFAULT NULL COMMENT 'due_date';
ALTER TABLE `contract_payment_plan` MODIFY COLUMN `amount` decimal(18, 2) NOT NULL COMMENT 'amount';
ALTER TABLE `contract_payment_plan` MODIFY COLUMN `condition` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'condition';
ALTER TABLE `contract_payment_plan` MODIFY COLUMN `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';

-- contract_payment_record
ALTER TABLE `contract_payment_record` COMMENT = '合同付款记录';
ALTER TABLE `contract_payment_record` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_payment_record` MODIFY COLUMN `contract_id` bigint NOT NULL COMMENT 'contract_id';
ALTER TABLE `contract_payment_record` MODIFY COLUMN `payment_date` datetime(6) NOT NULL COMMENT 'payment_date';
ALTER TABLE `contract_payment_record` MODIFY COLUMN `amount` decimal(18, 2) NOT NULL COMMENT 'amount';
ALTER TABLE `contract_payment_record` MODIFY COLUMN `method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'method';
ALTER TABLE `contract_payment_record` MODIFY COLUMN `operator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'operator';
ALTER TABLE `contract_payment_record` MODIFY COLUMN `remark` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'remark';
ALTER TABLE `contract_payment_record` MODIFY COLUMN `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型';
ALTER TABLE `contract_payment_record` MODIFY COLUMN `voucher_file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'voucher_file_name';
ALTER TABLE `contract_payment_record` MODIFY COLUMN `voucher_file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'voucher_file_path';

-- contract_relation
ALTER TABLE `contract_relation` COMMENT = '合同关联';
ALTER TABLE `contract_relation` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_relation` MODIFY COLUMN `contract_id` bigint NOT NULL COMMENT 'contract_id';
ALTER TABLE `contract_relation` MODIFY COLUMN `related_contract_id` bigint NOT NULL COMMENT 'related_contract_id';
ALTER TABLE `contract_relation` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';

-- contract_stat
ALTER TABLE `contract_stat` COMMENT = '合同统计';
ALTER TABLE `contract_stat` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_stat` MODIFY COLUMN `period_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'period_type';
ALTER TABLE `contract_stat` MODIFY COLUMN `period_key` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'period_key';
ALTER TABLE `contract_stat` MODIFY COLUMN `stat_date` datetime(6) NOT NULL COMMENT 'stat_date';
ALTER TABLE `contract_stat` MODIFY COLUMN `total_contracts` int NOT NULL COMMENT 'total_contracts';
ALTER TABLE `contract_stat` MODIFY COLUMN `total_amount` decimal(18, 2) NOT NULL COMMENT 'total_amount';
ALTER TABLE `contract_stat` MODIFY COLUMN `received_amount` decimal(18, 2) NOT NULL COMMENT 'received_amount';
ALTER TABLE `contract_stat` MODIFY COLUMN `invoiced_amount` decimal(18, 2) NOT NULL COMMENT 'invoiced_amount';
ALTER TABLE `contract_stat` MODIFY COLUMN `pending_invoice_amount` decimal(18, 2) NOT NULL COMMENT 'pending_invoice_amount';
ALTER TABLE `contract_stat` MODIFY COLUMN `sales_count` int NOT NULL COMMENT 'sales_count';
ALTER TABLE `contract_stat` MODIFY COLUMN `purchase_count` int NOT NULL COMMENT 'purchase_count';
ALTER TABLE `contract_stat` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `contract_stat` MODIFY COLUMN `amount_completion_rate` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT 'amount_completion_rate';
ALTER TABLE `contract_stat` MODIFY COLUMN `received_rate` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT 'received_rate';
ALTER TABLE `contract_stat` MODIFY COLUMN `total_contracts_growth` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT 'total_contracts_growth';

-- contract_template
ALTER TABLE `contract_template` COMMENT = '合同模板';
ALTER TABLE `contract_template` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `contract_template` MODIFY COLUMN `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `contract_template` MODIFY COLUMN `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型';
ALTER TABLE `contract_template` MODIFY COLUMN `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '描述';
ALTER TABLE `contract_template` MODIFY COLUMN `file_path` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '文件路径';
ALTER TABLE `contract_template` MODIFY COLUMN `file_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文件名';
ALTER TABLE `contract_template` MODIFY COLUMN `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';
ALTER TABLE `contract_template` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `contract_template` MODIFY COLUMN `updated_at` datetime(6) NULL DEFAULT NULL COMMENT 'updated_at';

-- data_source_connection
ALTER TABLE `data_source_connection` COMMENT = '数据源连接';
ALTER TABLE `data_source_connection` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `data_source_connection` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `data_source_connection` MODIFY COLUMN `Type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型';
ALTER TABLE `data_source_connection` MODIFY COLUMN `Host` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Host';
ALTER TABLE `data_source_connection` MODIFY COLUMN `Port` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Port';
ALTER TABLE `data_source_connection` MODIFY COLUMN `User` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'User';
ALTER TABLE `data_source_connection` MODIFY COLUMN `Password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码';
ALTER TABLE `data_source_connection` MODIFY COLUMN `Database` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Database';
ALTER TABLE `data_source_connection` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `data_source_connection` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';

-- frm_category
ALTER TABLE `frm_category` COMMENT = '表单分类';
ALTER TABLE `frm_category` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `frm_category` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `frm_category` MODIFY COLUMN `ParentId` bigint NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `frm_category` MODIFY COLUMN `SortOrder` int NOT NULL COMMENT '排序';
ALTER TABLE `frm_category` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `frm_category` MODIFY COLUMN `CreatedBy` bigint NULL DEFAULT NULL COMMENT '创建人';

-- frm_data
ALTER TABLE `frm_data` COMMENT = '表单数据';
ALTER TABLE `frm_data` MODIFY COLUMN `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `frm_data` MODIFY COLUMN `form_id` bigint NOT NULL COMMENT 'form_id';
ALTER TABLE `frm_data` MODIFY COLUMN `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'data';
ALTER TABLE `frm_data` MODIFY COLUMN `submitted_at` datetime(6) NOT NULL COMMENT 'submitted_at';
ALTER TABLE `frm_data` MODIFY COLUMN `submitted_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'submitted_by';

-- frm_definition
ALTER TABLE `frm_definition` COMMENT = '表单定义';
ALTER TABLE `frm_definition` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `frm_definition` MODIFY COLUMN `CategoryId` bigint NOT NULL COMMENT 'CategoryId';
ALTER TABLE `frm_definition` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `frm_definition` MODIFY COLUMN `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '代码';
ALTER TABLE `frm_definition` MODIFY COLUMN `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述';
ALTER TABLE `frm_definition` MODIFY COLUMN `FormItems` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'FormItems';
ALTER TABLE `frm_definition` MODIFY COLUMN `IsPublished` tinyint(1) NOT NULL COMMENT 'IsPublished';
ALTER TABLE `frm_definition` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `frm_definition` MODIFY COLUMN `UpdatedAt` datetime(6) NOT NULL COMMENT '更新时间';
ALTER TABLE `frm_definition` MODIFY COLUMN `CreatedBy` bigint NULL DEFAULT NULL COMMENT '创建人';
ALTER TABLE `frm_definition` MODIFY COLUMN `UpdatedBy` bigint NULL DEFAULT NULL COMMENT '更新人';
ALTER TABLE `frm_definition` MODIFY COLUMN `RequiresLogin` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'RequiresLogin';
ALTER TABLE `frm_definition` MODIFY COLUMN `LimitOnePerUser` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'LimitOnePerUser';
ALTER TABLE `frm_definition` MODIFY COLUMN `FillRoleIds` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'FillRoleIds';
ALTER TABLE `frm_definition` MODIFY COLUMN `ManageRoleIds` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ManageRoleIds';
ALTER TABLE `frm_definition` MODIFY COLUMN `ViewRoleIds` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ViewRoleIds';

-- kb_file
ALTER TABLE `kb_file` COMMENT = '知识库文件';
ALTER TABLE `kb_file` MODIFY COLUMN `Id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `kb_file` MODIFY COLUMN `KbId` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT 'KbId';
ALTER TABLE `kb_file` MODIFY COLUMN `Name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `kb_file` MODIFY COLUMN `Size` bigint NOT NULL COMMENT 'Size';
ALTER TABLE `kb_file` MODIFY COLUMN `Extension` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '扩展名';
ALTER TABLE `kb_file` MODIFY COLUMN `Path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '路径';
ALTER TABLE `kb_file` MODIFY COLUMN `Status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态';
ALTER TABLE `kb_file` MODIFY COLUMN `UploadTime` datetime(6) NOT NULL COMMENT 'UploadTime';
ALTER TABLE `kb_file` MODIFY COLUMN `IsFolder` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'IsFolder';
ALTER TABLE `kb_file` MODIFY COLUMN `ParentId` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NULL DEFAULT NULL COMMENT '父级ID';

-- kb_info
ALTER TABLE `kb_info` COMMENT = '知识库信息';
ALTER TABLE `kb_info` MODIFY COLUMN `Id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `kb_info` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `kb_info` MODIFY COLUMN `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述';
ALTER TABLE `kb_info` MODIFY COLUMN `Category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Category';
ALTER TABLE `kb_info` MODIFY COLUMN `Type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型';
ALTER TABLE `kb_info` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `kb_info` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';
ALTER TABLE `kb_info` MODIFY COLUMN `CreatedBy` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NULL DEFAULT NULL COMMENT '创建人';
ALTER TABLE `kb_info` MODIFY COLUMN `SortOrder` int NOT NULL DEFAULT 0 COMMENT '排序';

-- kb_node_source
ALTER TABLE `kb_node_source` COMMENT = '知识库节点源';
ALTER TABLE `kb_node_source` MODIFY COLUMN `Id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `kb_node_source` MODIFY COLUMN `NodeId` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT 'NodeId';
ALTER TABLE `kb_node_source` MODIFY COLUMN `FileId` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT '文件ID';
ALTER TABLE `kb_node_source` MODIFY COLUMN `Page` int NOT NULL COMMENT 'Page';
ALTER TABLE `kb_node_source` MODIFY COLUMN `Description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述';

-- kb_qa_history
ALTER TABLE `kb_qa_history` COMMENT = '知识库问答历史';
ALTER TABLE `kb_qa_history` MODIFY COLUMN `Id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `kb_qa_history` MODIFY COLUMN `KbId` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT 'KbId';
ALTER TABLE `kb_qa_history` MODIFY COLUMN `UserId` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NULL DEFAULT NULL COMMENT '用户ID';
ALTER TABLE `kb_qa_history` MODIFY COLUMN `Question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Question';
ALTER TABLE `kb_qa_history` MODIFY COLUMN `Answer` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'Answer';
ALTER TABLE `kb_qa_history` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `kb_qa_history` MODIFY COLUMN `SourcesJson` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'SourcesJson';

-- page_categories
ALTER TABLE `page_categories` COMMENT = '页面分类';
ALTER TABLE `page_categories` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `page_categories` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `page_categories` MODIFY COLUMN `ParentId` bigint NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `page_categories` MODIFY COLUMN `SortOrder` int NOT NULL COMMENT '排序';

-- page_definitions
ALTER TABLE `page_definitions` COMMENT = '页面定义';
ALTER TABLE `page_definitions` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `page_definitions` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `page_definitions` MODIFY COLUMN `CategoryId` bigint NULL DEFAULT NULL COMMENT 'CategoryId';
ALTER TABLE `page_definitions` MODIFY COLUMN `Code` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '代码';
ALTER TABLE `page_definitions` MODIFY COLUMN `Config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'Config';
ALTER TABLE `page_definitions` MODIFY COLUMN `ApiBindings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'ApiBindings';
ALTER TABLE `page_definitions` MODIFY COLUMN `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述';
ALTER TABLE `page_definitions` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `page_definitions` MODIFY COLUMN `UpdatedAt` datetime(6) NOT NULL COMMENT '更新时间';

-- pdm_ebom_documents
ALTER TABLE `pdm_ebom_documents` COMMENT = 'PDM EBOM文档';
ALTER TABLE `pdm_ebom_documents` MODIFY COLUMN `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `pdm_ebom_documents` MODIFY COLUMN `ebom_item_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ebom_item_id';
ALTER TABLE `pdm_ebom_documents` MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `pdm_ebom_documents` MODIFY COLUMN `path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '路径';
ALTER TABLE `pdm_ebom_documents` MODIFY COLUMN `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '文件类型';
ALTER TABLE `pdm_ebom_documents` MODIFY COLUMN `size` bigint NOT NULL COMMENT 'size';
ALTER TABLE `pdm_ebom_documents` MODIFY COLUMN `uploaded_at` datetime(6) NOT NULL COMMENT 'uploaded_at';
ALTER TABLE `pdm_ebom_documents` MODIFY COLUMN `uploaded_by` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'uploaded_by';

-- pdm_ebom_items
ALTER TABLE `pdm_ebom_items` COMMENT = 'PDM EBOM物料';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'version';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `designer` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'designer';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `spec` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'spec';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'unit';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `is_leaf` tinyint(1) NOT NULL COMMENT 'is_leaf';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `updated_at` datetime(6) NOT NULL COMMENT 'updated_at';
ALTER TABLE `pdm_ebom_items` MODIFY COLUMN `product_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'product_type';

-- pdm_ebom_structure
ALTER TABLE `pdm_ebom_structure` COMMENT = 'PDM EBOM结构';
ALTER TABLE `pdm_ebom_structure` MODIFY COLUMN `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `pdm_ebom_structure` MODIFY COLUMN `parent_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '父级ID';
ALTER TABLE `pdm_ebom_structure` MODIFY COLUMN `child_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'child_id';
ALTER TABLE `pdm_ebom_structure` MODIFY COLUMN `quantity` decimal(65, 30) NOT NULL COMMENT 'quantity';
ALTER TABLE `pdm_ebom_structure` MODIFY COLUMN `sort_order` int NOT NULL COMMENT 'sort_order';
ALTER TABLE `pdm_ebom_structure` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `pdm_ebom_structure` MODIFY COLUMN `child_version` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'child_version';

-- project_attachments
ALTER TABLE `project_attachments` COMMENT = '项目附件';
ALTER TABLE `project_attachments` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `project_attachments` MODIFY COLUMN `taskId` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'taskId';
ALTER TABLE `project_attachments` MODIFY COLUMN `project_code` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'project_code';
ALTER TABLE `project_attachments` MODIFY COLUMN `name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '名称';
ALTER TABLE `project_attachments` MODIFY COLUMN `url` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '链接';
ALTER TABLE `project_attachments` MODIFY COLUMN `type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '类型';
ALTER TABLE `project_attachments` MODIFY COLUMN `uploadDate` datetime(6) NULL DEFAULT NULL COMMENT 'uploadDate';

-- project_info
ALTER TABLE `project_info` COMMENT = '项目信息';
ALTER TABLE `project_info` MODIFY COLUMN `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '代码';
ALTER TABLE `project_info` MODIFY COLUMN `name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '名称';
ALTER TABLE `project_info` MODIFY COLUMN `type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '类型';
ALTER TABLE `project_info` MODIFY COLUMN `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '描述';
ALTER TABLE `project_info` MODIFY COLUMN `manager` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'manager';
ALTER TABLE `project_info` MODIFY COLUMN `planned_start_date` datetime(6) NULL DEFAULT NULL COMMENT 'planned_start_date';
ALTER TABLE `project_info` MODIFY COLUMN `planned_end_date` datetime(6) NULL DEFAULT NULL COMMENT 'planned_end_date';

-- project_members
ALTER TABLE `project_members` COMMENT = '项目成员';
ALTER TABLE `project_members` MODIFY COLUMN `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `project_members` MODIFY COLUMN `project_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'project_code';
ALTER TABLE `project_members` MODIFY COLUMN `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'username';
ALTER TABLE `project_members` MODIFY COLUMN `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'role';
ALTER TABLE `project_members` MODIFY COLUMN `joined_at` datetime(6) NOT NULL COMMENT 'joined_at';

-- project_phases
ALTER TABLE `project_phases` COMMENT = '项目阶段';
ALTER TABLE `project_phases` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `project_phases` MODIFY COLUMN `project_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'project_code';
ALTER TABLE `project_phases` MODIFY COLUMN `name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '名称';
ALTER TABLE `project_phases` MODIFY COLUMN `color` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'color';

-- project_swimlanes
ALTER TABLE `project_swimlanes` COMMENT = '项目泳道';
ALTER TABLE `project_swimlanes` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `project_swimlanes` MODIFY COLUMN `project_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'project_code';
ALTER TABLE `project_swimlanes` MODIFY COLUMN `name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '名称';
ALTER TABLE `project_swimlanes` MODIFY COLUMN `color` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'color';

-- project_task_dependencies
ALTER TABLE `project_task_dependencies` COMMENT = '项目任务依赖';
ALTER TABLE `project_task_dependencies` MODIFY COLUMN `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `project_task_dependencies` MODIFY COLUMN `taskId` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'taskId';
ALTER TABLE `project_task_dependencies` MODIFY COLUMN `dependencyId` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'dependencyId';
ALTER TABLE `project_task_dependencies` MODIFY COLUMN `project_code` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'project_code';
ALTER TABLE `project_task_dependencies` MODIFY COLUMN `type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '类型';
ALTER TABLE `project_task_dependencies` MODIFY COLUMN `sourcePort` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'sourcePort';
ALTER TABLE `project_task_dependencies` MODIFY COLUMN `targetPort` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'targetPort';
ALTER TABLE `project_task_dependencies` MODIFY COLUMN `controlPoints` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'controlPoints';
ALTER TABLE `project_task_dependencies` MODIFY COLUMN `controlPointCount` int NULL DEFAULT NULL COMMENT 'controlPointCount';

-- project_tasks
ALTER TABLE `project_tasks` COMMENT = '项目任务';
ALTER TABLE `project_tasks` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `project_tasks` MODIFY COLUMN `project_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'project_code';
ALTER TABLE `project_tasks` MODIFY COLUMN `name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '名称';
ALTER TABLE `project_tasks` MODIFY COLUMN `phaseId` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'phaseId';
ALTER TABLE `project_tasks` MODIFY COLUMN `swimlaneId` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'swimlaneId';
ALTER TABLE `project_tasks` MODIFY COLUMN `status` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'status';
ALTER TABLE `project_tasks` MODIFY COLUMN `progress` int NOT NULL COMMENT 'progress';
ALTER TABLE `project_tasks` MODIFY COLUMN `owner` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'owner';
ALTER TABLE `project_tasks` MODIFY COLUMN `startDate` datetime(6) NULL DEFAULT NULL COMMENT 'startDate';
ALTER TABLE `project_tasks` MODIFY COLUMN `endDate` datetime(6) NULL DEFAULT NULL COMMENT 'endDate';
ALTER TABLE `project_tasks` MODIFY COLUMN `type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '类型';
ALTER TABLE `project_tasks` MODIFY COLUMN `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '描述';
ALTER TABLE `project_tasks` MODIFY COLUMN `x` float NOT NULL COMMENT 'x';
ALTER TABLE `project_tasks` MODIFY COLUMN `y` float NOT NULL COMMENT 'y';
ALTER TABLE `project_tasks` MODIFY COLUMN `startColor` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'startColor';
ALTER TABLE `project_tasks` MODIFY COLUMN `endColor` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'endColor';
ALTER TABLE `project_tasks` MODIFY COLUMN `width` float NOT NULL COMMENT 'width';

-- sales_bid_analysis
ALTER TABLE `sales_bid_analysis` COMMENT = '标书分析';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `bid_project_id` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'bid_project_id';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `tender_type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'tender_type';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `deadline` datetime(6) NULL DEFAULT NULL COMMENT 'deadline';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `bid_bond` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'bid_bond';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `budget` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'budget';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `qualification` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'qualification';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `updated_at` datetime(6) NOT NULL COMMENT 'updated_at';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `file_name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '文件名';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `file_url` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'file_url';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `agency_name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'agency_name';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `bid_end_time` datetime(6) NULL DEFAULT NULL COMMENT 'bid_end_time';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `bid_start_time` datetime(6) NULL DEFAULT NULL COMMENT 'bid_start_time';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `contact_name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'contact_name';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `contact_phone` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'contact_phone';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `open_bid_time` datetime(6) NULL DEFAULT NULL COMMENT 'open_bid_time';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `tender_start_time` datetime(6) NULL DEFAULT NULL COMMENT 'tender_start_time';
ALTER TABLE `sales_bid_analysis` MODIFY COLUMN `publish_time` datetime(6) NULL DEFAULT NULL COMMENT 'publish_time';

-- sales_bid_analysis_log
ALTER TABLE `sales_bid_analysis_log` COMMENT = '标书分析日志';
ALTER TABLE `sales_bid_analysis_log` MODIFY COLUMN `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sales_bid_analysis_log` MODIFY COLUMN `run_id` bigint NOT NULL COMMENT 'run_id';
ALTER TABLE `sales_bid_analysis_log` MODIFY COLUMN `bid_project_id` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'bid_project_id';
ALTER TABLE `sales_bid_analysis_log` MODIFY COLUMN `message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'message';
ALTER TABLE `sales_bid_analysis_log` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';

-- sales_bid_analysis_run
ALTER TABLE `sales_bid_analysis_run` COMMENT = '标书分析运行';
ALTER TABLE `sales_bid_analysis_run` MODIFY COLUMN `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sales_bid_analysis_run` MODIFY COLUMN `bid_project_id` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'bid_project_id';
ALTER TABLE `sales_bid_analysis_run` MODIFY COLUMN `status` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';
ALTER TABLE `sales_bid_analysis_run` MODIFY COLUMN `started_at` datetime(6) NOT NULL COMMENT 'started_at';
ALTER TABLE `sales_bid_analysis_run` MODIFY COLUMN `finished_at` datetime(6) NULL DEFAULT NULL COMMENT 'finished_at';
ALTER TABLE `sales_bid_analysis_run` MODIFY COLUMN `created_by` bigint NOT NULL COMMENT 'created_by';

-- sales_bid_chapter
ALTER TABLE `sales_bid_chapter` COMMENT = '标书章节';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `analysis_id` bigint NOT NULL COMMENT 'analysis_id';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `parent_id` bigint NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `title` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `chapter_type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'chapter_type';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '内容';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `analysis_result` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'analysis_result';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `risk_level` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'risk_level';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `is_veto` tinyint(1) NOT NULL COMMENT 'is_veto';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `score_weight` decimal(18, 2) NULL DEFAULT NULL COMMENT 'score_weight';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `sort_order` int NOT NULL COMMENT 'sort_order';
ALTER TABLE `sales_bid_chapter` MODIFY COLUMN `extractions_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'extractions_json';

-- sales_bid_project
ALTER TABLE `sales_bid_project` COMMENT = '标书项目';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '代码';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `customer` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'customer';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `region` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'region';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `budget` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'budget';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `bid_time` datetime(6) NULL DEFAULT NULL COMMENT 'bid_time';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `leader` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'leader';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '描述';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `sales_bid_project` MODIFY COLUMN `updated_at` datetime(6) NULL DEFAULT NULL COMMENT 'updated_at';

-- sales_customer
ALTER TABLE `sales_customer` COMMENT = '销售客户';
ALTER TABLE `sales_customer` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `sales_customer` MODIFY COLUMN `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `sales_customer` MODIFY COLUMN `credit_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'credit_code';
ALTER TABLE `sales_customer` MODIFY COLUMN `industry` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'industry';
ALTER TABLE `sales_customer` MODIFY COLUMN `contact` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'contact';
ALTER TABLE `sales_customer` MODIFY COLUMN `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '电话';
ALTER TABLE `sales_customer` MODIFY COLUMN `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '邮箱';
ALTER TABLE `sales_customer` MODIFY COLUMN `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'level';
ALTER TABLE `sales_customer` MODIFY COLUMN `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';
ALTER TABLE `sales_customer` MODIFY COLUMN `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'address';
ALTER TABLE `sales_customer` MODIFY COLUMN `source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'source';
ALTER TABLE `sales_customer` MODIFY COLUMN `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '描述';
ALTER TABLE `sales_customer` MODIFY COLUMN `owner` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'owner';
ALTER TABLE `sales_customer` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `sales_customer` MODIFY COLUMN `updated_at` datetime(6) NULL DEFAULT NULL COMMENT 'updated_at';
ALTER TABLE `sales_customer` MODIFY COLUMN `org_id` bigint NOT NULL DEFAULT 0 COMMENT '组织ID';

-- sales_opportunity
ALTER TABLE `sales_opportunity` COMMENT = '销售商机';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `customer` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'customer';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'customer_id';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `amount` decimal(18, 2) NOT NULL COMMENT 'amount';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `stage` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'stage';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `win_rate` int NOT NULL COMMENT 'win_rate';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `owner` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'owner';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '描述';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `estimated_close_date` datetime(6) NULL DEFAULT NULL COMMENT 'estimated_close_date';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `sales_opportunity` MODIFY COLUMN `updated_at` datetime(6) NULL DEFAULT NULL COMMENT 'updated_at';

-- sales_process_rule
ALTER TABLE `sales_process_rule` COMMENT = '销售流程规则';
ALTER TABLE `sales_process_rule` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `sales_process_rule` MODIFY COLUMN `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题';
ALTER TABLE `sales_process_rule` MODIFY COLUMN `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '内容';
ALTER TABLE `sales_process_rule` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `sales_process_rule` MODIFY COLUMN `org_id` bigint NOT NULL DEFAULT 0 COMMENT '组织ID';

-- sales_product_doc
ALTER TABLE `sales_product_doc` COMMENT = '销售产品文档';
ALTER TABLE `sales_product_doc` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `sales_product_doc` MODIFY COLUMN `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题';
ALTER TABLE `sales_product_doc` MODIFY COLUMN `size` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'size';
ALTER TABLE `sales_product_doc` MODIFY COLUMN `url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '链接';
ALTER TABLE `sales_product_doc` MODIFY COLUMN `upload_date` datetime(6) NOT NULL COMMENT 'upload_date';
ALTER TABLE `sales_product_doc` MODIFY COLUMN `parent_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `sales_product_doc` MODIFY COLUMN `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '类型';
ALTER TABLE `sales_product_doc` MODIFY COLUMN `org_id` bigint NOT NULL DEFAULT 0 COMMENT '组织ID';

-- sales_registrations
ALTER TABLE `sales_registrations` COMMENT = '销售登记';
ALTER TABLE `sales_registrations` MODIFY COLUMN `Id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `sales_registrations` MODIFY COLUMN `ProjectName` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ProjectName';
ALTER TABLE `sales_registrations` MODIFY COLUMN `CustomerName` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'CustomerName';
ALTER TABLE `sales_registrations` MODIFY COLUMN `Contact` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Contact';
ALTER TABLE `sales_registrations` MODIFY COLUMN `Phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话';
ALTER TABLE `sales_registrations` MODIFY COLUMN `Amount` decimal(18, 2) NOT NULL COMMENT 'Amount';
ALTER TABLE `sales_registrations` MODIFY COLUMN `Date` datetime(6) NOT NULL COMMENT 'Date';
ALTER TABLE `sales_registrations` MODIFY COLUMN `Status` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态';
ALTER TABLE `sales_registrations` MODIFY COLUMN `Owner` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Owner';
ALTER TABLE `sales_registrations` MODIFY COLUMN `Remarks` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'Remarks';
ALTER TABLE `sales_registrations` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sales_registrations` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';
ALTER TABLE `sales_registrations` MODIFY COLUMN `OrgId` bigint NOT NULL DEFAULT 0 COMMENT '组织ID';

-- sales_script
ALTER TABLE `sales_script` COMMENT = '销售话术';
ALTER TABLE `sales_script` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `sales_script` MODIFY COLUMN `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题';
ALTER TABLE `sales_script` MODIFY COLUMN `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '内容';
ALTER TABLE `sales_script` MODIFY COLUMN `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'category';
ALTER TABLE `sales_script` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `sales_script` MODIFY COLUMN `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '描述';
ALTER TABLE `sales_script` MODIFY COLUMN `org_id` bigint NOT NULL DEFAULT 0 COMMENT '组织ID';

-- sales_target
ALTER TABLE `sales_target` COMMENT = '销售目标';
ALTER TABLE `sales_target` MODIFY COLUMN `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID';
ALTER TABLE `sales_target` MODIFY COLUMN `period` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'period';
ALTER TABLE `sales_target` MODIFY COLUMN `target_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'target_type';
ALTER TABLE `sales_target` MODIFY COLUMN `target_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'target_id';
ALTER TABLE `sales_target` MODIFY COLUMN `target_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'target_name';
ALTER TABLE `sales_target` MODIFY COLUMN `target_amount` decimal(18, 2) NOT NULL COMMENT 'target_amount';
ALTER TABLE `sales_target` MODIFY COLUMN `completed_amount` decimal(18, 2) NOT NULL COMMENT 'completed_amount';
ALTER TABLE `sales_target` MODIFY COLUMN `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';
ALTER TABLE `sales_target` MODIFY COLUMN `start_date` datetime(6) NOT NULL COMMENT 'start_date';
ALTER TABLE `sales_target` MODIFY COLUMN `end_date` datetime(6) NOT NULL COMMENT 'end_date';
ALTER TABLE `sales_target` MODIFY COLUMN `created_at` datetime(6) NOT NULL COMMENT 'created_at';
ALTER TABLE `sales_target` MODIFY COLUMN `updated_at` datetime(6) NULL DEFAULT NULL COMMENT 'updated_at';

-- sys_ai_generated_content
ALTER TABLE `sys_ai_generated_content` COMMENT = 'AI生成内容';
ALTER TABLE `sys_ai_generated_content` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_ai_generated_content` MODIFY COLUMN `Type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型：greeting (问候语), slogan (标语)';
ALTER TABLE `sys_ai_generated_content` MODIFY COLUMN `Content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '内容';
ALTER TABLE `sys_ai_generated_content` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_ai_generated_content` MODIFY COLUMN `CreatedBy` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人';
ALTER TABLE `sys_ai_generated_content` MODIFY COLUMN `IpAddress` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'IpAddress';

-- sys_anonce
ALTER TABLE `sys_anonce` COMMENT = '系统公告';
ALTER TABLE `sys_anonce` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_anonce` MODIFY COLUMN `Title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '公告标题';
ALTER TABLE `sys_anonce` MODIFY COLUMN `Content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '公告内容';
ALTER TABLE `sys_anonce` MODIFY COLUMN `Type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '公告类型 (关联字典 anonce_type)';
ALTER TABLE `sys_anonce` MODIFY COLUMN `Status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态 (draft:草稿, published:已发布, revoked:已撤回)';
ALTER TABLE `sys_anonce` MODIFY COLUMN `PublishTime` datetime(6) NULL DEFAULT NULL COMMENT '发布时间';
ALTER TABLE `sys_anonce` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_anonce` MODIFY COLUMN `UpdatedAt` datetime(6) NOT NULL COMMENT '更新时间';
ALTER TABLE `sys_anonce` MODIFY COLUMN `CreatedBy` bigint NULL DEFAULT NULL COMMENT '创建人ID';
ALTER TABLE `sys_anonce` MODIFY COLUMN `UpdatedBy` bigint NULL DEFAULT NULL COMMENT '更新人ID';
ALTER TABLE `sys_anonce` MODIFY COLUMN `Priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '优先级 (high, normal, low)';

-- sys_audit_log
ALTER TABLE `sys_audit_log` COMMENT = '审计日志';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `UserId` bigint NULL DEFAULT NULL COMMENT '用户ID';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `UserName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'UserName';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `Action` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Action';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `Route` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Route';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `Method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Method';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `IpAddress` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'IpAddress';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `UserAgent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'UserAgent';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `Parameters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'Parameters';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `IsSuccess` tinyint(1) NOT NULL COMMENT 'IsSuccess';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `ErrorMessage` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'ErrorMessage';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `ExecutionDuration` bigint NOT NULL COMMENT 'ExecutionDuration';
ALTER TABLE `sys_audit_log` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';

-- sys_chat_conversation
ALTER TABLE `sys_chat_conversation` COMMENT = '聊天会话';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `ConversationKey` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ConversationKey';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `Type` int NOT NULL COMMENT '0=Private, 1=Group, 2=System, 3=App';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `User1Id` bigint NULL DEFAULT NULL COMMENT 'User1Id';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `User2Id` bigint NULL DEFAULT NULL COMMENT 'User2Id';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `RelatedId` bigint NULL DEFAULT NULL COMMENT '关联ID。 对于群组(Type=1)，此处存GroupId。 对于系统/应用(Type=2/3)，如果模块有ID则存ID；如果只有字符串代码(如 \"workflow\")，则此处存null，通过 ConversationKey 区分。';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '名称';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `Avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `LastMessageContent` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'LastMessageContent';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `LastMessageType` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'LastMessageType';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `LastMessageTime` datetime(6) NOT NULL COMMENT 'LastMessageTime';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_chat_conversation` MODIFY COLUMN `UpdatedAt` datetime(6) NOT NULL COMMENT '更新时间';

-- sys_chat_message
ALTER TABLE `sys_chat_message` COMMENT = '聊天消息';
ALTER TABLE `sys_chat_message` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_chat_message` MODIFY COLUMN `ConversationKey` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ConversationKey';
ALTER TABLE `sys_chat_message` MODIFY COLUMN `SenderConnectionId` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SenderConnectionId';
ALTER TABLE `sys_chat_message` MODIFY COLUMN `SenderUserId` bigint NULL DEFAULT NULL COMMENT 'SenderUserId';
ALTER TABLE `sys_chat_message` MODIFY COLUMN `SenderUserName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'SenderUserName';
ALTER TABLE `sys_chat_message` MODIFY COLUMN `Type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型';
ALTER TABLE `sys_chat_message` MODIFY COLUMN `Content` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '内容';
ALTER TABLE `sys_chat_message` MODIFY COLUMN `FileName` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '文件名';
ALTER TABLE `sys_chat_message` MODIFY COLUMN `FileSize` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '文件大小';
ALTER TABLE `sys_chat_message` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';

-- sys_config
ALTER TABLE `sys_config` COMMENT = '系统配置';
ALTER TABLE `sys_config` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_config` MODIFY COLUMN `Category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Category';
ALTER TABLE `sys_config` MODIFY COLUMN `Key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Key';
ALTER TABLE `sys_config` MODIFY COLUMN `Value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Value';
ALTER TABLE `sys_config` MODIFY COLUMN `Description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述';
ALTER TABLE `sys_config` MODIFY COLUMN `IsSystem` tinyint(1) NOT NULL COMMENT 'IsSystem';
ALTER TABLE `sys_config` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_config` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';
ALTER TABLE `sys_config` MODIFY COLUMN `IsOverridable` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'IsOverridable';
ALTER TABLE `sys_config` MODIFY COLUMN `OrgId` bigint NULL DEFAULT NULL COMMENT '组织ID';
ALTER TABLE `sys_config` MODIFY COLUMN `Type` int NOT NULL DEFAULT 0 COMMENT '类型';

-- sys_dept
ALTER TABLE `sys_dept` COMMENT = '部门';
ALTER TABLE `sys_dept` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_dept` MODIFY COLUMN `ParentId` bigint NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `sys_dept` MODIFY COLUMN `Name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `sys_dept` MODIFY COLUMN `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '代码';
ALTER TABLE `sys_dept` MODIFY COLUMN `Leader` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Leader';
ALTER TABLE `sys_dept` MODIFY COLUMN `Phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话';
ALTER TABLE `sys_dept` MODIFY COLUMN `Email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱';
ALTER TABLE `sys_dept` MODIFY COLUMN `SortOrder` int NOT NULL COMMENT '排序';
ALTER TABLE `sys_dept` MODIFY COLUMN `IsActive` tinyint(1) NOT NULL COMMENT 'IsActive';
ALTER TABLE `sys_dept` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_dept` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';
ALTER TABLE `sys_dept` MODIFY COLUMN `Type` int NOT NULL DEFAULT 0 COMMENT '类型';
ALTER TABLE `sys_dept` MODIFY COLUMN `X` double NULL DEFAULT NULL COMMENT 'X';
ALTER TABLE `sys_dept` MODIFY COLUMN `Y` double NULL DEFAULT NULL COMMENT 'Y';

-- sys_dict_category
ALTER TABLE `sys_dict_category` COMMENT = '字典分类';
ALTER TABLE `sys_dict_category` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_dict_category` MODIFY COLUMN `parent_id` bigint NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `sys_dict_category` MODIFY COLUMN `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `sys_dict_category` MODIFY COLUMN `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '代码';
ALTER TABLE `sys_dict_category` MODIFY COLUMN `sort` int NOT NULL COMMENT 'sort';
ALTER TABLE `sys_dict_category` MODIFY COLUMN `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'remark';
ALTER TABLE `sys_dict_category` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_dict_category` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';

-- sys_dict_data
ALTER TABLE `sys_dict_data` COMMENT = '字典数据';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `dict_type_id` bigint NOT NULL COMMENT 'dict_type_id';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'label';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'value';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `sort` int NOT NULL COMMENT 'sort';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `is_default` tinyint(1) NOT NULL COMMENT 'is_default';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'css_class';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'list_class';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'remark';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_dict_data` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';

-- sys_dict_type
ALTER TABLE `sys_dict_type` COMMENT = '字典类型';
ALTER TABLE `sys_dict_type` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_dict_type` MODIFY COLUMN `category_id` bigint NULL DEFAULT NULL COMMENT 'category_id';
ALTER TABLE `sys_dict_type` MODIFY COLUMN `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `sys_dict_type` MODIFY COLUMN `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '代码';
ALTER TABLE `sys_dict_type` MODIFY COLUMN `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'status';
ALTER TABLE `sys_dict_type` MODIFY COLUMN `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'remark';
ALTER TABLE `sys_dict_type` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_dict_type` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';

-- sys_file
ALTER TABLE `sys_file` COMMENT = '系统文件';
ALTER TABLE `sys_file` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_file` MODIFY COLUMN `Name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `sys_file` MODIFY COLUMN `Extension` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '扩展名';
ALTER TABLE `sys_file` MODIFY COLUMN `Size` bigint NOT NULL COMMENT 'Size';
ALTER TABLE `sys_file` MODIFY COLUMN `IsFolder` tinyint(1) NOT NULL COMMENT 'IsFolder';
ALTER TABLE `sys_file` MODIFY COLUMN `FilePath` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文件路径';
ALTER TABLE `sys_file` MODIFY COLUMN `ContentType` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ContentType';
ALTER TABLE `sys_file` MODIFY COLUMN `ParentId` bigint NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `sys_file` MODIFY COLUMN `OwnerId` bigint NOT NULL COMMENT 'OwnerId';
ALTER TABLE `sys_file` MODIFY COLUMN `DeptId` bigint NULL DEFAULT NULL COMMENT '部门ID';
ALTER TABLE `sys_file` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_file` MODIFY COLUMN `UpdatedAt` datetime(6) NOT NULL COMMENT '更新时间';
ALTER TABLE `sys_file` MODIFY COLUMN `IsPublic` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'IsPublic';

-- sys_file_share
ALTER TABLE `sys_file_share` COMMENT = '文件分享';
ALTER TABLE `sys_file_share` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_file_share` MODIFY COLUMN `FileId` bigint NOT NULL COMMENT '文件ID';
ALTER TABLE `sys_file_share` MODIFY COLUMN `SharedByUserId` bigint NOT NULL COMMENT 'SharedByUserId';
ALTER TABLE `sys_file_share` MODIFY COLUMN `SharedToUserId` bigint NULL DEFAULT NULL COMMENT 'SharedToUserId';
ALTER TABLE `sys_file_share` MODIFY COLUMN `Permission` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Permission';
ALTER TABLE `sys_file_share` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_file_share` MODIFY COLUMN `ExpirationTime` datetime(6) NULL DEFAULT NULL COMMENT 'ExpirationTime';
ALTER TABLE `sys_file_share` MODIFY COLUMN `Token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '令牌';

-- sys_org_registration
ALTER TABLE `sys_org_registration` COMMENT = '组织注册';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `OrgName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'OrgName';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `OrgShortName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'OrgShortName';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `OrgAbbr` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'OrgAbbr';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `LicenseCode` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'LicenseCode';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `LicenseFileUrl` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'LicenseFileUrl';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `AuthLetterFileUrl` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'AuthLetterFileUrl';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `ContactName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ContactName';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `ContactPhone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ContactPhone';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `ContactEmail` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ContactEmail';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `AdminUsername` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'AdminUsername';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `AdminPassword` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'AdminPassword';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `Status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `RejectReason` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'RejectReason';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_org_registration` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';

-- sys_permission
ALTER TABLE `sys_permission` COMMENT = '权限';
ALTER TABLE `sys_permission` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_permission` MODIFY COLUMN `ParentId` bigint NULL DEFAULT NULL COMMENT '父级ID';
ALTER TABLE `sys_permission` MODIFY COLUMN `Name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `sys_permission` MODIFY COLUMN `Code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '代码';
ALTER TABLE `sys_permission` MODIFY COLUMN `Type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型';
ALTER TABLE `sys_permission` MODIFY COLUMN `Path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '路径';
ALTER TABLE `sys_permission` MODIFY COLUMN `Component` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件';
ALTER TABLE `sys_permission` MODIFY COLUMN `Query` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Query';
ALTER TABLE `sys_permission` MODIFY COLUMN `Icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图标';
ALTER TABLE `sys_permission` MODIFY COLUMN `SortOrder` int NOT NULL COMMENT '排序';
ALTER TABLE `sys_permission` MODIFY COLUMN `IsVisible` tinyint(1) NOT NULL COMMENT 'IsVisible';
ALTER TABLE `sys_permission` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_permission` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';

-- sys_post
ALTER TABLE `sys_post` COMMENT = '岗位';
ALTER TABLE `sys_post` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_post` MODIFY COLUMN `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '代码';
ALTER TABLE `sys_post` MODIFY COLUMN `Name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `sys_post` MODIFY COLUMN `SortOrder` int NOT NULL COMMENT '排序';
ALTER TABLE `sys_post` MODIFY COLUMN `IsActive` tinyint(1) NOT NULL COMMENT 'IsActive';
ALTER TABLE `sys_post` MODIFY COLUMN `Remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注';
ALTER TABLE `sys_post` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_post` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';
ALTER TABLE `sys_post` MODIFY COLUMN `DeptId` bigint NULL DEFAULT NULL COMMENT '部门ID';

-- sys_role
ALTER TABLE `sys_role` COMMENT = '角色';
ALTER TABLE `sys_role` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_role` MODIFY COLUMN `Name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称';
ALTER TABLE `sys_role` MODIFY COLUMN `Code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '代码';
ALTER TABLE `sys_role` MODIFY COLUMN `Description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述';
ALTER TABLE `sys_role` MODIFY COLUMN `IsSystem` tinyint(1) NOT NULL COMMENT 'IsSystem';
ALTER TABLE `sys_role` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_role` MODIFY COLUMN `UpdatedAt` datetime(6) NULL DEFAULT NULL COMMENT '更新时间';
ALTER TABLE `sys_role` MODIFY COLUMN `DeptId` bigint NULL DEFAULT NULL COMMENT '部门ID';

-- sys_role_inheritance
ALTER TABLE `sys_role_inheritance` COMMENT = '角色继承';
ALTER TABLE `sys_role_inheritance` MODIFY COLUMN `ParentRoleId` bigint NOT NULL COMMENT 'ParentRoleId';
ALTER TABLE `sys_role_inheritance` MODIFY COLUMN `ChildRoleId` bigint NOT NULL COMMENT 'ChildRoleId';

-- sys_role_permission
ALTER TABLE `sys_role_permission` COMMENT = '角色权限';
ALTER TABLE `sys_role_permission` MODIFY COLUMN `RoleId` bigint NOT NULL COMMENT '角色ID';
ALTER TABLE `sys_role_permission` MODIFY COLUMN `PermissionId` bigint NOT NULL COMMENT 'PermissionId';
ALTER TABLE `sys_role_permission` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';

-- sys_user
ALTER TABLE `sys_user` COMMENT = '用户';
ALTER TABLE `sys_user` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_user` MODIFY COLUMN `Username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Username';
ALTER TABLE `sys_user` MODIFY COLUMN `Password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码';
ALTER TABLE `sys_user` MODIFY COLUMN `Nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Nickname';
ALTER TABLE `sys_user` MODIFY COLUMN `Email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱';
ALTER TABLE `sys_user` MODIFY COLUMN `Phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话';
ALTER TABLE `sys_user` MODIFY COLUMN `IsActive` tinyint(1) NOT NULL COMMENT 'IsActive';
ALTER TABLE `sys_user` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';
ALTER TABLE `sys_user` MODIFY COLUMN `LastLoginAt` datetime(6) NULL DEFAULT NULL COMMENT 'LastLoginAt';
ALTER TABLE `sys_user` MODIFY COLUMN `Avatar` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '头像';
ALTER TABLE `sys_user` MODIFY COLUMN `DeptId` bigint NULL DEFAULT NULL COMMENT '部门ID';
ALTER TABLE `sys_user` MODIFY COLUMN `Status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '状态';
ALTER TABLE `sys_user` MODIFY COLUMN `CurrentOrgId` bigint NULL DEFAULT NULL COMMENT 'CurrentOrgId';

-- sys_user_post
ALTER TABLE `sys_user_post` COMMENT = '用户岗位';
ALTER TABLE `sys_user_post` MODIFY COLUMN `UserId` bigint NOT NULL COMMENT '用户ID';
ALTER TABLE `sys_user_post` MODIFY COLUMN `PostId` bigint NOT NULL COMMENT '岗位ID';
ALTER TABLE `sys_user_post` MODIFY COLUMN `DeptId` bigint NOT NULL DEFAULT 0 COMMENT '部门ID';

-- sys_user_role
ALTER TABLE `sys_user_role` COMMENT = '用户角色';
ALTER TABLE `sys_user_role` MODIFY COLUMN `UserId` bigint NOT NULL COMMENT '用户ID';
ALTER TABLE `sys_user_role` MODIFY COLUMN `RoleId` bigint NOT NULL COMMENT '角色ID';
ALTER TABLE `sys_user_role` MODIFY COLUMN `CreatedAt` datetime(6) NOT NULL COMMENT '创建时间';

-- sys_db_migration
ALTER TABLE `sys_db_migration` COMMENT = '数据库迁移记录';
ALTER TABLE `sys_db_migration` MODIFY COLUMN `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID';
ALTER TABLE `sys_db_migration` MODIFY COLUMN `FileName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '迁移文件名';
ALTER TABLE `sys_db_migration` MODIFY COLUMN `ExecutedAt` datetime NOT NULL COMMENT '执行时间';
ALTER TABLE `sys_db_migration` MODIFY COLUMN `Status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'success' COMMENT '状态';
ALTER TABLE `sys_db_migration` MODIFY COLUMN `ErrorMessage` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '错误信息';

