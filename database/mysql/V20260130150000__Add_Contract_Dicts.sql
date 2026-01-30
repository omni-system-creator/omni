ALTER TABLE `sys_dict_data` MODIFY COLUMN `is_default` tinyint(1) NOT NULL DEFAULT 0 AFTER `status`;
-- 1. Ensure Category '合同管理' (Contract Management) exists
INSERT INTO sys_dict_category (name, code, Sort, CreatedAt)
SELECT '合同管理', 'contract_mgmt', 10, NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_category WHERE code = 'contract_mgmt');

SET @categoryId = (SELECT Id FROM sys_dict_category WHERE code = 'contract_mgmt' LIMIT 1);

-- 2. Ensure Types
-- contract_direction
INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
SELECT @categoryId, '收付方向', 'contract_direction', 'normal', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'contract_direction');

SET @typeId_direction = (SELECT Id FROM sys_dict_type WHERE code = 'contract_direction' LIMIT 1);

-- contract_pricing_type
INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
SELECT @categoryId, '总价类型', 'contract_pricing_type', 'normal', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'contract_pricing_type');

SET @typeId_pricing = (SELECT Id FROM sys_dict_type WHERE code = 'contract_pricing_type' LIMIT 1);

-- contract_status
INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
SELECT @categoryId, '合同状态', 'contract_status', 'normal', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'contract_status');

SET @typeId_lifecycle = (SELECT Id FROM sys_dict_type WHERE code = 'contract_status' LIMIT 1);

-- contract_performance_status
INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
SELECT @categoryId, '履约状态', 'contract_performance_status', 'normal', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'contract_performance_status');

SET @typeId_performance = (SELECT Id FROM sys_dict_type WHERE code = 'contract_performance_status' LIMIT 1);

-- 3. Ensure Data
-- Direction
INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_direction, '收款合同', 'sales', 1, 'normal', 'blue', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_direction AND value = 'sales');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_direction, '付款合同', 'purchase', 2, 'normal', 'orange', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_direction AND value = 'purchase');

-- Pricing
INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_pricing, '固定总价合同', 'fixed', 1, 'normal', 'cyan', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_pricing AND value = 'fixed');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_pricing, '无固定总价合同', 'non_fixed', 2, 'normal', 'purple', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_pricing AND value = 'non_fixed');

-- Lifecycle
INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_lifecycle, '草稿', 'draft', 1, 'normal', 'default', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_lifecycle AND value = 'draft');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_lifecycle, '审批中', 'approving', 2, 'normal', 'processing', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_lifecycle AND value = 'approving');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_lifecycle, '已签订', 'signed', 3, 'normal', 'success', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_lifecycle AND value = 'signed');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_lifecycle, '已作废', 'canceled', 4, 'normal', 'error', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_lifecycle AND value = 'canceled');

-- Performance
INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_performance, '履约中', 'executing', 1, 'normal', 'processing', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_performance AND value = 'executing');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_performance, '已履约', 'completed', 2, 'normal', 'success', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_performance AND value = 'completed');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt)
SELECT @typeId_performance, '异常', 'abnormal', 3, 'normal', 'error', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_performance AND value = 'abnormal');
