ALTER TABLE finance_apar ADD partner_id NVARCHAR(50) NULL;
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'往来单位ID (Customer/Supplier ID)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_apar', @level2type = N'COLUMN', @level2name = N'partner_id';
GO
