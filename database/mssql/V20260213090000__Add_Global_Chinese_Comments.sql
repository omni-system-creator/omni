-- Add Chinese Comments to All Tables
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_category]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'API分类', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_category';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[api_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_category', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID(N'[dbo].[api_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'名称', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_category', @level2type=N'COLUMN', @level2name=N'Name';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID(N'[dbo].[api_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'排序', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_category', @level2type=N'COLUMN', @level2name=N'SortOrder';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[api_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_category', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID(N'[dbo].[api_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建人', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_category', @level2type=N'COLUMN', @level2name=N'CreatedBy';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID(N'[dbo].[api_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'父级ID', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_category', @level2type=N'COLUMN', @level2name=N'ParentId';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UrlPrefix' AND [object_id] = OBJECT_ID(N'[dbo].[api_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'URL前缀', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_category', @level2type=N'COLUMN', @level2name=N'UrlPrefix';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_definition]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'API定义', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_definition';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[api_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_definition', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID(N'[dbo].[api_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'名称', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_definition', @level2type=N'COLUMN', @level2name=N'Name';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[api_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_definition', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID(N'[dbo].[api_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建人', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_definition', @level2type=N'COLUMN', @level2name=N'CreatedBy';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[api_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_definition', @level2type=N'COLUMN', @level2name=N'UpdatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedBy' AND [object_id] = OBJECT_ID(N'[dbo].[api_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'更新人', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_definition', @level2type=N'COLUMN', @level2name=N'UpdatedBy';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID(N'[dbo].[api_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'描述', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_definition', @level2type=N'COLUMN', @level2name=N'Description';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Path' AND [object_id] = OBJECT_ID(N'[dbo].[api_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'路径', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_definition', @level2type=N'COLUMN', @level2name=N'Path';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[api_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Method' AND [object_id] = OBJECT_ID(N'[dbo].[api_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'请求方法', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'api_definition', @level2type=N'COLUMN', @level2name=N'Method';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_attachment]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'档案附件', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_attachment';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_attachment]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[arch_attachment]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_attachment', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_attachment]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[arch_attachment]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_attachment', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_attachment]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Size' AND [object_id] = OBJECT_ID(N'[dbo].[arch_attachment]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'大小', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_attachment', @level2type=N'COLUMN', @level2name=N'Size';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_box]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'档案盒', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_box';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_box]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[arch_box]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_box', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_box]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[arch_box]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_box', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_box]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Remark' AND [object_id] = OBJECT_ID(N'[dbo].[arch_box]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'备注', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_box', @level2type=N'COLUMN', @level2name=N'Remark';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_box]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID(N'[dbo].[arch_box]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'状态', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_box', @level2type=N'COLUMN', @level2name=N'Status';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_box]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Title' AND [object_id] = OBJECT_ID(N'[dbo].[arch_box]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'标题', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_box', @level2type=N'COLUMN', @level2name=N'Title';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_file]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'档案文件', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_file';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[arch_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_file', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[arch_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_file', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[arch_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_file', @level2type=N'COLUMN', @level2name=N'UpdatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Remark' AND [object_id] = OBJECT_ID(N'[dbo].[arch_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'备注', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_file', @level2type=N'COLUMN', @level2name=N'Remark';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID(N'[dbo].[arch_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'状态', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_file', @level2type=N'COLUMN', @level2name=N'Status';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Title' AND [object_id] = OBJECT_ID(N'[dbo].[arch_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'标题', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_file', @level2type=N'COLUMN', @level2name=N'Title';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_fond]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'全宗', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_fond';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_fond]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[arch_fond]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_fond', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_fond]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID(N'[dbo].[arch_fond]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'名称', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_fond', @level2type=N'COLUMN', @level2name=N'Name';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_fond]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID(N'[dbo].[arch_fond]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'编码', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_fond', @level2type=N'COLUMN', @level2name=N'Code';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_fond]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID(N'[dbo].[arch_fond]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'排序', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_fond', @level2type=N'COLUMN', @level2name=N'SortOrder';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_fond]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[arch_fond]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_fond', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_fond]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID(N'[dbo].[arch_fond]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'描述', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_fond', @level2type=N'COLUMN', @level2name=N'Description';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_type]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'档案类型', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_type';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_type]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[arch_type]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_type', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_type]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID(N'[dbo].[arch_type]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'名称', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_type', @level2type=N'COLUMN', @level2name=N'Name';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_type]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID(N'[dbo].[arch_type]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'编码', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_type', @level2type=N'COLUMN', @level2name=N'Code';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_type]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID(N'[dbo].[arch_type]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'排序', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_type', @level2type=N'COLUMN', @level2name=N'SortOrder';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[arch_type]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID(N'[dbo].[arch_type]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'父级ID', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'arch_type', @level2type=N'COLUMN', @level2name=N'ParentId';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[bigview_project]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'大屏项目', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'bigview_project';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_attachment]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同附件', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_attachment';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_attachment]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_attachment]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_attachment', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_contact]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同联系人', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_contact';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_contact]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_contact]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_contact', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_invoice]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同发票', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_invoice';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_invoice]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_invoice]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_invoice', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_knowledge_category]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同知识分类', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_knowledge_category';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_knowledge_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_knowledge_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_knowledge_category', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_knowledge_file]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同知识文件', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_knowledge_file';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_knowledge_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_knowledge_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_knowledge_file', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_main]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同主表', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_main';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_main]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_main]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_main', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_payment_plan]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同付款计划', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_payment_plan';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_payment_plan]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_payment_plan]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_payment_plan', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_payment_record]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同付款记录', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_payment_record';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_payment_record]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_payment_record]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_payment_record', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_relation]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同关联', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_relation';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_relation]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_relation]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_relation', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_stat]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同统计', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_stat';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_stat]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_stat]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_stat', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_template]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'合同模板', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_template';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[contract_template]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[contract_template]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'contract_template', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[data_source_connection]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'数据源连接', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'data_source_connection';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[data_source_connection]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[data_source_connection]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'data_source_connection', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[data_source_connection]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID(N'[dbo].[data_source_connection]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'名称', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'data_source_connection', @level2type=N'COLUMN', @level2name=N'Name';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[data_source_connection]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[data_source_connection]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'data_source_connection', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[data_source_connection]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[data_source_connection]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'data_source_connection', @level2type=N'COLUMN', @level2name=N'UpdatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[data_source_connection]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID(N'[dbo].[data_source_connection]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'类型', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'data_source_connection', @level2type=N'COLUMN', @level2name=N'Type';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[data_source_connection]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Password' AND [object_id] = OBJECT_ID(N'[dbo].[data_source_connection]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'密码', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'data_source_connection', @level2type=N'COLUMN', @level2name=N'Password';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_category]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'表单分类', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_category';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[frm_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_category', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID(N'[dbo].[frm_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'名称', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_category', @level2type=N'COLUMN', @level2name=N'Name';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID(N'[dbo].[frm_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'排序', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_category', @level2type=N'COLUMN', @level2name=N'SortOrder';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[frm_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_category', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID(N'[dbo].[frm_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建人', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_category', @level2type=N'COLUMN', @level2name=N'CreatedBy';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_category]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID(N'[dbo].[frm_category]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'父级ID', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_category', @level2type=N'COLUMN', @level2name=N'ParentId';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_data]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'表单数据', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_data';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_definition]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'表单定义', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_definition';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[frm_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_definition', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID(N'[dbo].[frm_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'名称', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_definition', @level2type=N'COLUMN', @level2name=N'Name';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID(N'[dbo].[frm_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'编码', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_definition', @level2type=N'COLUMN', @level2name=N'Code';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[frm_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_definition', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID(N'[dbo].[frm_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建人', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_definition', @level2type=N'COLUMN', @level2name=N'CreatedBy';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[frm_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_definition', @level2type=N'COLUMN', @level2name=N'UpdatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedBy' AND [object_id] = OBJECT_ID(N'[dbo].[frm_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'更新人', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_definition', @level2type=N'COLUMN', @level2name=N'UpdatedBy';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[frm_definition]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID(N'[dbo].[frm_definition]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'描述', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'frm_definition', @level2type=N'COLUMN', @level2name=N'Description';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_file]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'知识库文件', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_file';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[kb_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_file', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID(N'[dbo].[kb_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'名称', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_file', @level2type=N'COLUMN', @level2name=N'Name';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID(N'[dbo].[kb_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'状态', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_file', @level2type=N'COLUMN', @level2name=N'Status';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID(N'[dbo].[kb_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'父级ID', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_file', @level2type=N'COLUMN', @level2name=N'ParentId';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Path' AND [object_id] = OBJECT_ID(N'[dbo].[kb_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'路径', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_file', @level2type=N'COLUMN', @level2name=N'Path';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_file]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Size' AND [object_id] = OBJECT_ID(N'[dbo].[kb_file]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'大小', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_file', @level2type=N'COLUMN', @level2name=N'Size';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_info]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'知识库信息', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_info';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_info]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[kb_info]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_info', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_info]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID(N'[dbo].[kb_info]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'名称', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_info', @level2type=N'COLUMN', @level2name=N'Name';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_info]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID(N'[dbo].[kb_info]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'排序', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_info', @level2type=N'COLUMN', @level2name=N'SortOrder';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_info]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[kb_info]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_info', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_info]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID(N'[dbo].[kb_info]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建人', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_info', @level2type=N'COLUMN', @level2name=N'CreatedBy';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_info]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[kb_info]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_info', @level2type=N'COLUMN', @level2name=N'UpdatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_info]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID(N'[dbo].[kb_info]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'描述', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_info', @level2type=N'COLUMN', @level2name=N'Description';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_info]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID(N'[dbo].[kb_info]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'类型', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_info', @level2type=N'COLUMN', @level2name=N'Type';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_info]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Category' AND [object_id] = OBJECT_ID(N'[dbo].[kb_info]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'分类', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_info', @level2type=N'COLUMN', @level2name=N'Category';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_node_source]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'知识库节点源', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_node_source';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_node_source]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[kb_node_source]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_node_source', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_node_source]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID(N'[dbo].[kb_node_source]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'描述', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_node_source', @level2type=N'COLUMN', @level2name=N'Description';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_qa_history]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'知识库问答历史', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_qa_history';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_qa_history]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID(N'[dbo].[kb_qa_history]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'主键', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_qa_history', @level2type=N'COLUMN', @level2name=N'Id';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_qa_history]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID(N'[dbo].[kb_qa_history]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_qa_history', @level2type=N'COLUMN', @level2name=N'CreatedAt';
END

IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID(N'[dbo].[kb_qa_history]') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UserId' AND [object_id] = OBJECT_ID(N'[dbo].[kb_qa_history]')))
BEGIN
    EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'用户ID', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'kb_qa_history', @level2type=N'COLUMN', @level2name=N'UserId';
END
