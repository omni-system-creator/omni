ALTER TABLE contract_main ADD COLUMN partner_id BIGINT NULL;
COMMENT ON COLUMN contract_main.partner_id IS '合作伙伴ID (客户或供应商)';
