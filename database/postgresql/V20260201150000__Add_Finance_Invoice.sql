-- Add FinanceInvoice Table
CREATE TABLE IF NOT EXISTS "finance_invoice" (
  "Id" BIGSERIAL PRIMARY KEY,
  "invoice_no" varchar(50) NOT NULL,
  "invoice_code" varchar(50) DEFAULT NULL,
  "purchaser_name" varchar(200) NOT NULL,
  "purchaser_tax_id" varchar(50) DEFAULT NULL,
  "seller_name" varchar(200) NOT NULL,
  "seller_tax_id" varchar(50) DEFAULT NULL,
  "direction" varchar(20) NOT NULL DEFAULT 'input',
  "type" varchar(50) NOT NULL,
  "amount" decimal(18,2) NOT NULL DEFAULT 0.00,
  "tax_amount" decimal(18,2) NOT NULL DEFAULT 0.00,
  "total_amount" decimal(18,2) NOT NULL DEFAULT 0.00,
  "invoice_date" timestamp NOT NULL,
  "status" varchar(20) NOT NULL DEFAULT 'draft',
  "remark" varchar(500) DEFAULT NULL,
  "org_id" bigint DEFAULT NULL,
  "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp DEFAULT NULL,
  "created_by" varchar(50) DEFAULT NULL,
  "contract_id" bigint DEFAULT NULL,
  "apar_id" bigint DEFAULT NULL
);

COMMENT ON TABLE "finance_invoice" IS '发票管理表';
COMMENT ON COLUMN "finance_invoice"."invoice_no" IS '发票号码';
COMMENT ON COLUMN "finance_invoice"."invoice_code" IS '发票代码';
COMMENT ON COLUMN "finance_invoice"."purchaser_name" IS '购方名称';
COMMENT ON COLUMN "finance_invoice"."purchaser_tax_id" IS '购方税号';
COMMENT ON COLUMN "finance_invoice"."seller_name" IS '销方名称';
COMMENT ON COLUMN "finance_invoice"."seller_tax_id" IS '销方税号';
COMMENT ON COLUMN "finance_invoice"."direction" IS '方向: input(进项)/output(销项)';
COMMENT ON COLUMN "finance_invoice"."type" IS '发票类型';
COMMENT ON COLUMN "finance_invoice"."amount" IS '金额(不含税)';
COMMENT ON COLUMN "finance_invoice"."tax_amount" IS '税额';
COMMENT ON COLUMN "finance_invoice"."total_amount" IS '价税合计';
COMMENT ON COLUMN "finance_invoice"."invoice_date" IS '开票日期';
COMMENT ON COLUMN "finance_invoice"."status" IS '状态';
COMMENT ON COLUMN "finance_invoice"."remark" IS '备注';
COMMENT ON COLUMN "finance_invoice"."org_id" IS '组织ID';
COMMENT ON COLUMN "finance_invoice"."created_by" IS '创建人';
COMMENT ON COLUMN "finance_invoice"."contract_id" IS '关联合同ID';
COMMENT ON COLUMN "finance_invoice"."apar_id" IS '关联应收应付ID';

CREATE INDEX IF NOT EXISTS "IX_finance_invoice_org_id" ON "finance_invoice" ("org_id");
CREATE INDEX IF NOT EXISTS "IX_finance_invoice_contract_id" ON "finance_invoice" ("contract_id");
CREATE INDEX IF NOT EXISTS "IX_finance_invoice_apar_id" ON "finance_invoice" ("apar_id");

-- Add Dictionary Types
INSERT INTO "sys_dict_type" ("name", "code", "remark", "status", "CreatedAt") VALUES
('发票类型', 'finance_invoice_type', '财务发票类型', 'normal', NOW()),
('发票状态', 'finance_invoice_status', '财务发票状态', 'normal', NOW())
ON CONFLICT ("code") DO NOTHING;

-- Add Dictionary Data
DO $$
DECLARE
    dict_id_type bigint;
    dict_id_status bigint;
BEGIN
    SELECT "id" INTO dict_id_type FROM "sys_dict_type" WHERE "code" = 'finance_invoice_type';
    
    DELETE FROM "sys_dict_data" WHERE "dict_type_id" = dict_id_type;

    INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "CreatedAt") VALUES
    (dict_id_type, '增值税专用发票', 'vat_spec', 1, 'normal', NOW()),
    (dict_id_type, '增值税普通发票', 'vat_normal', 2, 'normal', NOW()),
    (dict_id_type, '增值税电子专用发票', 'vat_spec_e', 3, 'normal', NOW()),
    (dict_id_type, '增值税电子普通发票', 'vat_normal_e', 4, 'normal', NOW());

    SELECT "id" INTO dict_id_status FROM "sys_dict_type" WHERE "code" = 'finance_invoice_status';

    DELETE FROM "sys_dict_data" WHERE "dict_type_id" = dict_id_status;

    INSERT INTO "sys_dict_data" ("dict_type_id", "label", "value", "sort", "status", "CreatedAt") VALUES
    (dict_id_status, '草稿', 'draft', 1, 'normal', NOW()),
    (dict_id_status, '已开票', 'issued', 2, 'normal', NOW()),
    (dict_id_status, '已作废', 'void', 3, 'normal', NOW()),
    (dict_id_status, '已收票', 'received', 4, 'normal', NOW()),
    (dict_id_status, '已验真', 'verified', 5, 'normal', NOW()),
    (dict_id_status, '已入账', 'booked', 6, 'normal', NOW());
END $$;
