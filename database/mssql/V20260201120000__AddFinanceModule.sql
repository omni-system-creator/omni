-- Add FinanceSubject Table
CREATE TABLE [finance_subject] (
    [Id] bigint NOT NULL IDENTITY,
    [code] nvarchar(50) NOT NULL,
    [name] nvarchar(100) NOT NULL,
    [parent_id] bigint NULL,
    [direction] nvarchar(20) NOT NULL DEFAULT 'income',
    [description] nvarchar(200) NULL,
    [is_system] bit NOT NULL DEFAULT 0,
    [is_active] bit NOT NULL DEFAULT 1,
    [org_id] bigint NULL,
    [created_at] datetime2 NOT NULL DEFAULT GETDATE(),
    [updated_at] datetime2 NULL,
    CONSTRAINT [PK_finance_subject] PRIMARY KEY ([Id])
);
CREATE INDEX [IX_finance_subject_parent_id] ON [finance_subject] ([parent_id]);
CREATE INDEX [IX_finance_subject_org_id] ON [finance_subject] ([org_id]);

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'财务科目表', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_subject';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'科目编码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_subject', @level2type = N'COLUMN', @level2name = N'code';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'科目名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_subject', @level2type = N'COLUMN', @level2name = N'name';

-- Add FinanceApAr Table
CREATE TABLE [finance_apar] (
    [Id] bigint NOT NULL IDENTITY,
    [bill_no] nvarchar(50) NOT NULL,
    [type] nvarchar(10) NOT NULL DEFAULT 'AR',
    [subject_id] bigint NULL,
    [amount] decimal(18,2) NOT NULL,
    [due_date] datetime2 NOT NULL,
    [partner_name] nvarchar(200) NOT NULL,
    [status] int NOT NULL DEFAULT 0,
    [source_type] nvarchar(20) NULL DEFAULT 'Manual',
    [source_id] bigint NULL,
    [source_sub_id] bigint NULL,
    [description] nvarchar(500) NULL,
    [org_id] bigint NULL,
    [created_at] datetime2 NOT NULL DEFAULT GETDATE(),
    [updated_at] datetime2 NULL,
    [created_by] nvarchar(50) NULL,
    CONSTRAINT [PK_finance_apar] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_finance_apar_subject] FOREIGN KEY ([subject_id]) REFERENCES [finance_subject] ([Id])
);
CREATE INDEX [IX_finance_apar_subject_id] ON [finance_apar] ([subject_id]);
CREATE INDEX [IX_finance_apar_org_id] ON [finance_apar] ([org_id]);

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'应收应付账款表', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'finance_apar';

-- Add FinanceAttachment Table
CREATE TABLE [finance_attachment] (
    [Id] bigint NOT NULL IDENTITY,
    [target_type] nvarchar(50) NOT NULL,
    [target_id] bigint NOT NULL,
    [file_name] nvarchar(200) NOT NULL,
    [file_path] nvarchar(500) NULL,
    [size] nvarchar(20) NULL,
    [content_type] nvarchar(100) NULL,
    [upload_date] datetime2 NOT NULL DEFAULT GETDATE(),
    [uploader] nvarchar(50) NULL,
    CONSTRAINT [PK_finance_attachment] PRIMARY KEY ([Id])
);
CREATE INDEX [IX_finance_attachment_target] ON [finance_attachment] ([target_type], [target_id]);

-- Seed Initial Finance Subjects
INSERT INTO [finance_subject] ([code], [name], [direction], [is_system], [description], [created_at]) VALUES
('1001', N'合同款', 'income', 0, N'合同销售回款', GETDATE()),
('2001', N'合同付款', 'expense', 0, N'合同采购付款', GETDATE()),
('1002', N'其他收入', 'income', 0, N'非主营业务收入', GETDATE()),
('2002', N'日常报销', 'expense', 0, N'日常费用报销', GETDATE());
