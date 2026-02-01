-- Add FinanceInvoice Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[finance_invoice]') AND type in (N'U'))
BEGIN
CREATE TABLE [finance_invoice] (
  [Id] bigint NOT NULL IDENTITY(1,1),
  [invoice_no] nvarchar(50) NOT NULL,
  [invoice_code] nvarchar(50) NULL,
  [purchaser_name] nvarchar(200) NOT NULL,
  [purchaser_tax_id] nvarchar(50) NULL,
  [seller_name] nvarchar(200) NOT NULL,
  [seller_tax_id] nvarchar(50) NULL,
  [direction] nvarchar(20) NOT NULL DEFAULT 'input',
  [type] nvarchar(50) NOT NULL,
  [amount] decimal(18,2) NOT NULL DEFAULT 0.00,
  [tax_amount] decimal(18,2) NOT NULL DEFAULT 0.00,
  [total_amount] decimal(18,2) NOT NULL DEFAULT 0.00,
  [invoice_date] datetime2 NOT NULL,
  [status] nvarchar(20) NOT NULL DEFAULT 'draft',
  [remark] nvarchar(500) NULL,
  [org_id] bigint NULL,
  [created_at] datetime2 NOT NULL DEFAULT GETDATE(),
  [updated_at] datetime2 NULL,
  [created_by] nvarchar(50) NULL,
  [contract_id] bigint NULL,
  [apar_id] bigint NULL,
  CONSTRAINT [PK_finance_invoice] PRIMARY KEY ([Id])
);

CREATE INDEX [IX_finance_invoice_org_id] ON [finance_invoice] ([org_id]);
CREATE INDEX [IX_finance_invoice_contract_id] ON [finance_invoice] ([contract_id]);
CREATE INDEX [IX_finance_invoice_apar_id] ON [finance_invoice] ([apar_id]);

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'发票管理表', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'发票号码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'invoice_no';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'发票代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'invoice_code';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'购方名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'purchaser_name';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'购方税号', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'purchaser_tax_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'销方名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'seller_name';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'销方税号', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'seller_tax_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'方向: input(进项)/output(销项)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'direction';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'发票类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'type';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'金额(不含税)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'amount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'税额', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'tax_amount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'价税合计', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'total_amount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'开票日期', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'invoice_date';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'status';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'备注', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'remark';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'org_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'created_by';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'关联合同ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'contract_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'关联应收应付ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_invoice', @level2type = N'COLUMN', @level2name = N'apar_id';
END

-- Add Dictionary Types
IF NOT EXISTS (SELECT * FROM [sys_dict_type] WHERE [code] = 'finance_invoice_type')
BEGIN
INSERT INTO [sys_dict_type] ([name], [code], [remark], [status], [CreatedAt]) VALUES
(N'发票类型', 'finance_invoice_type', N'财务发票类型', 'normal', GETDATE());
END

IF NOT EXISTS (SELECT * FROM [sys_dict_type] WHERE [code] = 'finance_invoice_status')
BEGIN
INSERT INTO [sys_dict_type] ([name], [code], [remark], [status], [CreatedAt]) VALUES
(N'发票状态', 'finance_invoice_status', N'财务发票状态', 'normal', GETDATE());
END

-- Add Dictionary Data
DECLARE @dict_id_type bigint;
SELECT @dict_id_type = [id] FROM [sys_dict_type] WHERE [code] = 'finance_invoice_type';
DELETE FROM [sys_dict_data] WHERE [dict_type_id] = @dict_id_type;

INSERT INTO [sys_dict_data] ([dict_type_id], [label], [value], [sort], [status], [CreatedAt]) VALUES
(@dict_id_type, N'增值税专用发票', 'vat_spec', 1, 'normal', GETDATE()),
(@dict_id_type, N'增值税普通发票', 'vat_normal', 2, 'normal', GETDATE()),
(@dict_id_type, N'增值税电子专用发票', 'vat_spec_e', 3, 'normal', GETDATE()),
(@dict_id_type, N'增值税电子普通发票', 'vat_normal_e', 4, 'normal', GETDATE());

DECLARE @dict_id_status bigint;
SELECT @dict_id_status = [id] FROM [sys_dict_type] WHERE [code] = 'finance_invoice_status';
DELETE FROM [sys_dict_data] WHERE [dict_type_id] = @dict_id_status;

INSERT INTO [sys_dict_data] ([dict_type_id], [label], [value], [sort], [status], [CreatedAt]) VALUES
(@dict_id_status, N'草稿', 'draft', 1, 'normal', GETDATE()),
(@dict_id_status, N'已开票', 'issued', 2, 'normal', GETDATE()),
(@dict_id_status, N'已作废', 'void', 3, 'normal', GETDATE()),
(@dict_id_status, N'已收票', 'received', 4, 'normal', GETDATE()),
(@dict_id_status, N'已验真', 'verified', 5, 'normal', GETDATE()),
(@dict_id_status, N'已入账', 'booked', 6, 'normal', GETDATE());
