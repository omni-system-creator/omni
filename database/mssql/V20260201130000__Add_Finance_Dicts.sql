-- MSSQL Script to add finance dictionary data

DECLARE @categoryId bigint;
DECLARE @typeId_bill_type bigint;
DECLARE @typeId_bill_status bigint;
DECLARE @typeId_direction bigint;

-- 1. Ensure Category '财务管理' (Finance Management) exists
IF NOT EXISTS (SELECT 1 FROM sys_dict_category WHERE code = 'finance_mgmt')
BEGIN
    INSERT INTO sys_dict_category (name, code, Sort, CreatedAt)
    VALUES (N'财务管理', 'finance_mgmt', 20, GETDATE());
END

SELECT TOP 1 @categoryId = Id FROM sys_dict_category WHERE code = 'finance_mgmt';

-- 2. Ensure Types

-- finance_bill_type
IF NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'finance_bill_type')
BEGIN
    INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
    VALUES (@categoryId, N'账款类型', 'finance_bill_type', 'normal', GETDATE());
END
SELECT TOP 1 @typeId_bill_type = Id FROM sys_dict_type WHERE code = 'finance_bill_type';

-- finance_bill_status
IF NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'finance_bill_status')
BEGIN
    INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
    VALUES (@categoryId, N'账款状态', 'finance_bill_status', 'normal', GETDATE());
END
SELECT TOP 1 @typeId_bill_status = Id FROM sys_dict_type WHERE code = 'finance_bill_status';

-- finance_direction
IF NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'finance_direction')
BEGIN
    INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
    VALUES (@categoryId, N'财务方向', 'finance_direction', 'normal', GETDATE());
END
SELECT TOP 1 @typeId_direction = Id FROM sys_dict_type WHERE code = 'finance_direction';

-- 3. Ensure Data

-- Bill Type
IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_type AND value = 'AP')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_bill_type, N'应付账款 (AP)', 'AP', 1, 'normal', 'warning', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_type AND value = 'AR')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_bill_type, N'应收账款 (AR)', 'AR', 2, 'normal', 'success', GETDATE(), 0);
END

-- Bill Status
IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_status AND value = '0')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_bill_status, N'待处理', '0', 1, 'normal', 'default', GETDATE(), 1);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_status AND value = '1')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_bill_status, N'已审核', '1', 2, 'normal', 'processing', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_status AND value = '2')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_bill_status, N'部分结算', '2', 3, 'normal', 'warning', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_status AND value = '3')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_bill_status, N'已完成', '3', 4, 'normal', 'success', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_bill_status AND value = '4')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_bill_status, N'已取消', '4', 5, 'normal', 'error', GETDATE(), 0);
END

-- Direction
IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_direction AND value = 'income')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_direction, N'收入/应收', 'income', 1, 'normal', 'success', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_direction AND value = 'expense')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_direction, N'支出/应付', 'expense', 2, 'normal', 'warning', GETDATE(), 0);
END
