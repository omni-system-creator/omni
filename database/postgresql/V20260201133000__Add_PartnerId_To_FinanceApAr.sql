ALTER TABLE finance_apar ADD COLUMN partner_id VARCHAR(50) NULL;
COMMENT ON COLUMN finance_apar.partner_id IS '往来单位ID (Customer/Supplier ID)';
