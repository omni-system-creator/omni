ALTER TABLE "contract_invoice" ADD COLUMN "content" TEXT NULL;
COMMENT ON COLUMN "contract_invoice"."content" IS '识别内容';
