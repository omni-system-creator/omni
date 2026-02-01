-- Add FinanceSubject Table
CREATE TABLE `finance_subject` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL COMMENT '科目编码',
  `name` varchar(100) NOT NULL COMMENT '科目名称',
  `parent_id` bigint DEFAULT NULL COMMENT '父级科目ID',
  `direction` varchar(20) NOT NULL DEFAULT 'income' COMMENT '方向: income/expense',
  `description` varchar(200) DEFAULT NULL COMMENT '描述',
  `is_system` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否系统科目',
  `is_active` bit(1) NOT NULL DEFAULT b'1' COMMENT '是否启用',
  `org_id` bigint DEFAULT NULL COMMENT '组织ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `IX_finance_subject_parent_id` (`parent_id`),
  KEY `IX_finance_subject_org_id` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='财务科目表';

-- Add FinanceApAr Table
CREATE TABLE `finance_apar` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `bill_no` varchar(50) NOT NULL COMMENT '单据编号',
  `type` varchar(10) NOT NULL DEFAULT 'AR' COMMENT '类型: AR/AP',
  `subject_id` bigint DEFAULT NULL COMMENT '科目ID',
  `amount` decimal(18,2) NOT NULL COMMENT '金额',
  `due_date` datetime NOT NULL COMMENT '应收/应付日期',
  `partner_name` varchar(200) NOT NULL COMMENT '往来单位名称',
  `status` int NOT NULL DEFAULT '0' COMMENT '状态: 0=待处理, 1=部分, 2=完成, 3=逾期, 4=作废',
  `source_type` varchar(20) DEFAULT 'Manual' COMMENT '来源类型: Contract/Manual',
  `source_id` bigint DEFAULT NULL COMMENT '来源ID (ContractId)',
  `source_sub_id` bigint DEFAULT NULL COMMENT '来源子ID (PaymentPlanId)',
  `description` varchar(500) DEFAULT NULL COMMENT '备注',
  `org_id` bigint DEFAULT NULL COMMENT '组织ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  PRIMARY KEY (`Id`),
  KEY `IX_finance_apar_subject_id` (`subject_id`),
  KEY `IX_finance_apar_org_id` (`org_id`),
  CONSTRAINT `FK_finance_apar_subject` FOREIGN KEY (`subject_id`) REFERENCES `finance_subject` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='应收应付账款表';

-- Add FinanceAttachment Table
CREATE TABLE `finance_attachment` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `target_type` varchar(50) NOT NULL COMMENT '目标类型: ApAr/Invoice',
  `target_id` bigint NOT NULL COMMENT '目标ID',
  `file_name` varchar(200) NOT NULL COMMENT '文件名',
  `file_path` varchar(500) DEFAULT NULL COMMENT '文件路径',
  `size` varchar(20) DEFAULT NULL COMMENT '文件大小',
  `content_type` varchar(100) DEFAULT NULL COMMENT '文件类型',
  `upload_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `uploader` varchar(50) DEFAULT NULL COMMENT '上传人',
  PRIMARY KEY (`Id`),
  KEY `IX_finance_attachment_target` (`target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='财务附件表';

-- Seed Initial Finance Subjects
INSERT INTO `finance_subject` (`code`, `name`, `direction`, `is_system`, `description`, `created_at`) VALUES
('1001', '合同款', 'income', 0, '合同销售回款', NOW()),
('2001', '合同付款', 'expense', 0, '合同采购付款', NOW()),
('1002', '其他收入', 'income', 0, '非主营业务收入', NOW()),
('2002', '日常报销', 'expense', 0, '日常费用报销', NOW());
