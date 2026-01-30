-- MSSQL Script to add contract dictionary data

-- Modify is_default column (MSSQL does not support AFTER for column position)
ALTER TABLE sys_dict_data ALTER COLUMN is_default tinyint NOT NULL;

IF NOT EXISTS (SELECT * FROM sys_objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_sys_dict_data_is_default]') AND type = 'D')
BEGIN
    ALTER TABLE sys_dict_data ADD CONSTRAINT DF_sys_dict_data_is_default DEFAULT 0 FOR is_default;
END
GO

DECLARE @categoryId bigint;
DECLARE @typeId_direction bigint;
DECLARE @typeId_pricing bigint;
DECLARE @typeId_lifecycle bigint;
DECLARE @typeId_performance bigint;

-- 1. Ensure Category '合同管理' (Contract Management) exists
IF NOT EXISTS (SELECT 1 FROM sys_dict_category WHERE code = 'contract_mgmt')
BEGIN
    INSERT INTO sys_dict_category (name, code, Sort, CreatedAt)
    VALUES (N'合同管理', 'contract_mgmt', 10, GETDATE());
END

SELECT TOP 1 @categoryId = Id FROM sys_dict_category WHERE code = 'contract_mgmt';

-- 2. Ensure Types
-- contract_direction
IF NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'contract_direction')
BEGIN
    INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
    VALUES (@categoryId, N'收付方向', 'contract_direction', 'normal', GETDATE());
END
SELECT TOP 1 @typeId_direction = Id FROM sys_dict_type WHERE code = 'contract_direction';

-- contract_pricing_type
IF NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'contract_pricing_type')
BEGIN
    INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
    VALUES (@categoryId, N'总价类型', 'contract_pricing_type', 'normal', GETDATE());
END
SELECT TOP 1 @typeId_pricing = Id FROM sys_dict_type WHERE code = 'contract_pricing_type';

-- contract_status
IF NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'contract_status')
BEGIN
    INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
    VALUES (@categoryId, N'合同状态', 'contract_status', 'normal', GETDATE());
END
SELECT TOP 1 @typeId_lifecycle = Id FROM sys_dict_type WHERE code = 'contract_status';

-- contract_performance_status
IF NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE code = 'contract_performance_status')
BEGIN
    INSERT INTO sys_dict_type (category_id, name, code, status, CreatedAt)
    VALUES (@categoryId, N'履约状态', 'contract_performance_status', 'normal', GETDATE());
END
SELECT TOP 1 @typeId_performance = Id FROM sys_dict_type WHERE code = 'contract_performance_status';


-- 3. Ensure Data

-- Direction
IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_direction AND value = 'sales')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_direction, N'收款合同', 'sales', 1, 'normal', 'blue', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_direction AND value = 'purchase')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_direction, N'付款合同', 'purchase', 2, 'normal', 'orange', GETDATE(), 0);
END

-- Pricing
IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_pricing AND value = 'fixed')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_pricing, N'固定总价合同', 'fixed', 1, 'normal', 'cyan', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_pricing AND value = 'non_fixed')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_pricing, N'无固定总价合同', 'non_fixed', 2, 'normal', 'purple', GETDATE(), 0);
END

-- Lifecycle
IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_lifecycle AND value = 'draft')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_lifecycle, N'草稿', 'draft', 1, 'normal', 'default', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_lifecycle AND value = 'approving')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_lifecycle, N'审批中', 'approving', 2, 'normal', 'processing', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_lifecycle AND value = 'signed')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_lifecycle, N'已签订', 'signed', 3, 'normal', 'success', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_lifecycle AND value = 'canceled')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_lifecycle, N'已作废', 'canceled', 4, 'normal', 'error', GETDATE(), 0);
END

-- Performance
IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_performance AND value = 'executing')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_performance, N'履约中', 'executing', 1, 'normal', 'processing', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_performance AND value = 'completed')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_performance, N'已履约', 'completed', 2, 'normal', 'success', GETDATE(), 0);
END

IF NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type_id = @typeId_performance AND value = 'abnormal')
BEGIN
    INSERT INTO sys_dict_data (dict_type_id, label, value, Sort, status, list_class, CreatedAt, is_default)
    VALUES (@typeId_performance, N'异常', 'abnormal', 3, 'normal', 'error', GETDATE(), 0);
END
