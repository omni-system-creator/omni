-- Add FinanceInvoice Table
CREATE TABLE IF NOT EXISTS `finance_invoice` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `invoice_no` varchar(50) NOT NULL COMMENT '发票号码',
  `invoice_code` varchar(50) DEFAULT NULL COMMENT '发票代码',
  `purchaser_name` varchar(200) NOT NULL COMMENT '购方名称',
  `purchaser_tax_id` varchar(50) DEFAULT NULL COMMENT '购方税号',
  `seller_name` varchar(200) NOT NULL COMMENT '销方名称',
  `seller_tax_id` varchar(50) DEFAULT NULL COMMENT '销方税号',
  `direction` varchar(20) NOT NULL DEFAULT 'input' COMMENT '方向: input(进项)/output(销项)',
  `type` varchar(50) NOT NULL COMMENT '发票类型',
  `amount` decimal(18,2) NOT NULL DEFAULT '0.00' COMMENT '金额(不含税)',
  `tax_amount` decimal(18,2) NOT NULL DEFAULT '0.00' COMMENT '税额',
  `total_amount` decimal(18,2) NOT NULL DEFAULT '0.00' COMMENT '价税合计',
  `invoice_date` datetime NOT NULL COMMENT '开票日期',
  `status` varchar(20) NOT NULL DEFAULT 'draft' COMMENT '状态',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `org_id` bigint DEFAULT NULL COMMENT '组织ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `contract_id` bigint DEFAULT NULL COMMENT '关联合同ID',
  `apar_id` bigint DEFAULT NULL COMMENT '关联应收应付ID',
  PRIMARY KEY (`Id`),
  KEY `IX_finance_invoice_org_id` (`org_id`),
  KEY `IX_finance_invoice_contract_id` (`contract_id`),
  KEY `IX_finance_invoice_apar_id` (`apar_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='发票管理表';

-- Add Dictionary Types
INSERT IGNORE INTO `sys_dict_type` (`name`, `code`, `remark`, `status`, `CreatedAt`) VALUES
('发票类型', 'finance_invoice_type', '财务发票类型', 'normal', NOW()),
('发票状态', 'finance_invoice_status', '财务发票状态', 'normal', NOW());

-- Add Dictionary Data for Invoice Type
SET @dict_id_type = (SELECT `id` FROM `sys_dict_type` WHERE `code` = 'finance_invoice_type');
DELETE FROM `sys_dict_data` WHERE `dict_type_id` = @dict_id_type;
INSERT INTO `sys_dict_data` (`dict_type_id`, `label`, `value`, `sort`, `status`, `CreatedAt`) VALUES
(@dict_id_type, '增值税专用发票', 'vat_spec', 1, 'normal', NOW()),
(@dict_id_type, '增值税普通发票', 'vat_normal', 2, 'normal', NOW()),
(@dict_id_type, '增值税电子专用发票', 'vat_spec_e', 3, 'normal', NOW()),
(@dict_id_type, '增值税电子普通发票', 'vat_normal_e', 4, 'normal', NOW());

-- Add Dictionary Data for Invoice Status
SET @dict_id_status = (SELECT `id` FROM `sys_dict_type` WHERE `code` = 'finance_invoice_status');
DELETE FROM `sys_dict_data` WHERE `dict_type_id` = @dict_id_status;
INSERT INTO `sys_dict_data` (`dict_type_id`, `label`, `value`, `sort`, `status`, `CreatedAt`) VALUES
(@dict_id_status, '草稿', 'draft', 1, 'normal', NOW()),
(@dict_id_status, '已开票', 'issued', 2, 'normal', NOW()),
(@dict_id_status, '已作废', 'void', 3, 'normal', NOW()),
(@dict_id_status, '已收票', 'received', 4, 'normal', NOW()),
(@dict_id_status, '已验真', 'verified', 5, 'normal', NOW()),
(@dict_id_status, '已入账', 'booked', 6, 'normal', NOW());
