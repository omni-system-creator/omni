-- PostgreSQL Script to add contract dictionary data

-- Modify is_default column
ALTER TABLE "sys_dict_data" ALTER COLUMN "is_default" SET NOT NULL;
ALTER TABLE "sys_dict_data" ALTER COLUMN "is_default" SET DEFAULT 0;

DO $$
DECLARE
    v_categoryId bigint;
    v_typeId_direction bigint;
    v_typeId_pricing bigint;
    v_typeId_lifecycle bigint;
    v_typeId_performance bigint;
BEGIN
    -- 1. Ensure Category '合同管理' (Contract Management) exists
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_category" WHERE "code" = 'contract_mgmt') THEN
        INSERT INTO "sys_dict_category" ("name", "code", "sort", "CreatedAt")
        VALUES ('合同管理', 'contract_mgmt', 10, NOW());
    END IF;
    
    SELECT "Id" INTO v_categoryId FROM "sys_dict_category" WHERE "code" = 'contract_mgmt' LIMIT 1;

    -- 2. Ensure Types
    -- contract_direction
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_type" WHERE "code" = 'contract_direction') THEN
        INSERT INTO "sys_dict_type" ("category_id", "name", "code", "status", "CreatedAt")
        VALUES (v_categoryId, '收付方向', 'contract_direction', 'normal', NOW());
    END IF;
    SELECT "Id" INTO v_typeId_direction FROM "sys_dict_type" WHERE "code" = 'contract_direction' LIMIT 1;

    -- contract_pricing_type
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_type" WHERE "code" = 'contract_pricing_type') THEN
        INSERT INTO "sys_dict_type" ("category_id", "name", "code", "status", "CreatedAt")
        VALUES (v_categoryId, '总价类型', 'contract_pricing_type', 'normal', NOW());
    END IF;
    SELECT "Id" INTO v_typeId_pricing FROM "sys_dict_type" WHERE "code" = 'contract_pricing_type' LIMIT 1;

    -- contract_status
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_type" WHERE "code" = 'contract_status') THEN
        INSERT INTO "sys_dict_type" ("category_id", "name", "code", "status", "CreatedAt")
        VALUES (v_categoryId, '合同状态', 'contract_status', 'normal', NOW());
    END IF;
    SELECT "Id" INTO v_typeId_lifecycle FROM "sys_dict_type" WHERE "code" = 'contract_status' LIMIT 1;

    -- contract_performance_status
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_type" WHERE "code" = 'contract_performance_status') THEN
        INSERT INTO "sys_dict_type" ("category_id", "name", "code", "status", "CreatedAt")
        VALUES (v_categoryId, '履约状态', 'contract_performance_status', 'normal', NOW());
    END IF;
    SELECT "Id" INTO v_typeId_performance FROM "sys_dict_type" WHERE "code" = 'contract_performance_status' LIMIT 1;


    -- 3. Ensure Data
    
    -- Direction
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_direction AND "value" = 'sales') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_direction, '收款合同', 'sales', 1, 'normal', 'blue', NOW(), 0);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_direction AND "value" = 'purchase') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_direction, '付款合同', 'purchase', 2, 'normal', 'orange', NOW(), 0);
    END IF;

    -- Pricing
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_pricing AND "value" = 'fixed') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_pricing, '固定总价合同', 'fixed', 1, 'normal', 'cyan', NOW(), 0);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_pricing AND "value" = 'non_fixed') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_pricing, '无固定总价合同', 'non_fixed', 2, 'normal', 'purple', NOW(), 0);
    END IF;

    -- Lifecycle
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_lifecycle AND "value" = 'draft') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_lifecycle, '草稿', 'draft', 1, 'normal', 'default', NOW(), 0);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_lifecycle AND "value" = 'approving') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_lifecycle, '审批中', 'approving', 2, 'normal', 'processing', NOW(), 0);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_lifecycle AND "value" = 'signed') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_lifecycle, '已签订', 'signed', 3, 'normal', 'success', NOW(), 0);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_lifecycle AND "value" = 'canceled') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_lifecycle, '已作废', 'canceled', 4, 'normal', 'error', NOW(), 0);
    END IF;

    -- Performance
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_performance AND "value" = 'executing') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_performance, '履约中', 'executing', 1, 'normal', 'processing', NOW(), 0);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_performance AND "value" = 'completed') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_performance, '已履约', 'completed', 2, 'normal', 'success', NOW(), 0);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_performance AND "value" = 'abnormal') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_performance, '异常', 'abnormal', 3, 'normal', 'error', NOW(), 0);
    END IF;

END $$;
