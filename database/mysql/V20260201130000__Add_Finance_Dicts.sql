-- MySQL Script to add finance dictionary data

-- 1. Ensure Category '财务管理' (Finance Management) exists
INSERT INTO sys_dict_category (name, code, Sort, CreatedAt)
SELECT '财务管理', 'finance_mgmt', 20, NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_category WHERE code = 'finance_mgmt');

SELECT @categoryId := Id FROM sys_dict_category WHERE code = 'finance_mgmt';

-- 2. Ensure Types

-- finance_bill_type
INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
SELECT @categoryId, '账款类型', 'finance_bill_type', 'normal', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'finance_bill_type');

SELECT @typeId_bill_type := Id FROM sys_dict_type WHERE code = 'finance_bill_type';

-- finance_bill_status
INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
SELECT @categoryId, '账款状态', 'finance_bill_status', 'normal', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'finance_bill_status');

SELECT @typeId_bill_status := Id FROM sys_dict_type WHERE code = 'finance_bill_status';

-- finance_direction
INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
SELECT @categoryId, '财务方向', 'finance_direction', 'normal', NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'finance_direction');

SELECT @typeId_direction := Id FROM sys_dict_type WHERE code = 'finance_direction';

-- 3. Ensure Data

-- Bill Type
INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
SELECT @typeId_bill_type, '应付账款 (AP)', 'AP', 1, 'normal', 'warning', NOW(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_type AND value = 'AP');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
SELECT @typeId_bill_type, '应收账款 (AR)', 'AR', 2, 'normal', 'success', NOW(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_type AND value = 'AR');

-- Bill Status
INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
SELECT @typeId_bill_status, '待处理', '0', 1, 'normal', 'default', NOW(), 1
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_status AND value = '0');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
SELECT @typeId_bill_status, '已审核', '1', 2, 'normal', 'processing', NOW(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_status AND value = '1');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
SELECT @typeId_bill_status, '部分结算', '2', 3, 'normal', 'warning', NOW(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_status AND value = '2');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
SELECT @typeId_bill_status, '已完成', '3', 4, 'normal', 'success', NOW(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_status AND value = '3');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
SELECT @typeId_bill_status, '已取消', '4', 5, 'normal', 'error', NOW(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_status AND value = '4');

-- Direction
INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
SELECT @typeId_direction, '收入/应收', 'income', 1, 'normal', 'success', NOW(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_direction AND value = 'income');

INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
SELECT @typeId_direction, '支出/应付', 'expense', 2, 'normal', 'warning', NOW(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_direction AND value = 'expense');
