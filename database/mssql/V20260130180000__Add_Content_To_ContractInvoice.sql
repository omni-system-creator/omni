ALTER TABLE [contract_invoice] ADD [content] NVARCHAR(MAX) NULL;
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'识别内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'content';
