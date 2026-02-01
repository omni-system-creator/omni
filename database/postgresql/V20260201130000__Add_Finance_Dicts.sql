-- PostgreSQL Script to add finance dictionary data

DO $$
DECLARE
    v_categoryId bigint;
    v_typeId_bill_type bigint;
    v_typeId_bill_status bigint;
    v_typeId_direction bigint;
BEGIN

    -- 1. Ensure Category '财务管理' (Finance Management) exists
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_category" WHERE "code" = 'finance_mgmt') THEN
        INSERT INTO "sys_dict_category" ("name", "code", "Sort", "CreatedAt")
        VALUES ('财务管理', 'finance_mgmt', 20, NOW())
        RETURNING "Id" INTO v_categoryId;
    ELSE
        SELECT "Id" INTO v_categoryId FROM "sys_dict_category" WHERE "code" = 'finance_mgmt';
    END IF;

    -- 2. Ensure Types

    -- finance_bill_type
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_type" WHERE "code" = 'finance_bill_type') THEN
        INSERT INTO "sys_dict_type" ("category_id", "name", "code", "status", "CreatedAt")
        VALUES (v_categoryId, '账款类型', 'finance_bill_type', 'normal', NOW())
        RETURNING "Id" INTO v_typeId_bill_type;
    ELSE
        SELECT "Id" INTO v_typeId_bill_type FROM "sys_dict_type" WHERE "code" = 'finance_bill_type';
    END IF;

    -- finance_bill_status
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_type" WHERE "code" = 'finance_bill_status') THEN
        INSERT INTO "sys_dict_type" ("category_id", "name", "code", "status", "CreatedAt")
        VALUES (v_categoryId, '账款状态', 'finance_bill_status', 'normal', NOW())
        RETURNING "Id" INTO v_typeId_bill_status;
    ELSE
        SELECT "Id" INTO v_typeId_bill_status FROM "sys_dict_type" WHERE "code" = 'finance_bill_status';
    END IF;

    -- finance_direction
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_type" WHERE "code" = 'finance_direction') THEN
        INSERT INTO "sys_dict_type" ("category_id", "name", "code", "status", "CreatedAt")
        VALUES (v_categoryId, '财务方向', 'finance_direction', 'normal', NOW())
        RETURNING "Id" INTO v_typeId_direction;
    ELSE
        SELECT "Id" INTO v_typeId_direction FROM "sys_dict_type" WHERE "code" = 'finance_direction';
    END IF;

    -- 3. Ensure Data

    -- Bill Type
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_bill_type AND "value" = 'AP') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "Sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_bill_type, '应付账款 (AP)', 'AP', 1, 'normal', 'warning', NOW(), false);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_bill_type AND "value" = 'AR') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "Sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_bill_type, '应收账款 (AR)', 'AR', 2, 'normal', 'success', NOW(), false);
    END IF;

    -- Bill Status
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_bill_status AND "value" = '0') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "Sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_bill_status, '待处理', '0', 1, 'normal', 'default', NOW(), true);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_bill_status AND "value" = '1') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "Sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_bill_status, '已审核', '1', 2, 'normal', 'processing', NOW(), false);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_bill_status AND "value" = '2') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "Sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_bill_status, '部分结算', '2', 3, 'normal', 'warning', NOW(), false);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_bill_status AND "value" = '3') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "Sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_bill_status, '已完成', '3', 4, 'normal', 'success', NOW(), false);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_bill_status AND "value" = '4') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "Sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_bill_status, '已取消', '4', 5, 'normal', 'error', NOW(), false);
    END IF;

    -- Direction
    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_direction AND "value" = 'income') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "Sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_direction, '收入/应收', 'income', 1, 'normal', 'success', NOW(), false);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "sys_dict_data" WHERE "dict_type_id" = v_typeId_direction AND "value" = 'expense') THEN
        INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "Sort", "status", "list_class", "CreatedAt", "is_default")
        VALUES (v_typeId_direction, '支出/应付', 'expense', 2, 'normal', 'warning', NOW(), false);
    END IF;

END $$;
