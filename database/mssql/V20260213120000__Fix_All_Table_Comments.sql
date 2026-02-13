-- Add Chinese comments to all tables and columns (MSSQL)

-- api_category
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_category') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'API分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'API分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('api_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('api_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID('api_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'ParentId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'ParentId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID('api_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'SortOrder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'SortOrder';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('api_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID('api_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'CreatedBy';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'CreatedBy';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UrlPrefix' AND [object_id] = OBJECT_ID('api_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'UrlPrefix', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'UrlPrefix';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'UrlPrefix', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_category', @level2type = N'COLUMN', @level2name = N'UrlPrefix';

-- api_definition
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'API定义', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'API定义', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CategoryId' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CategoryId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'CategoryId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'CategoryId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'CategoryId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Path' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'Path';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'Path';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Method' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Method', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'Method';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Method', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'Method';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'Description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'Description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FlowConfig' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'FlowConfig', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'FlowConfig';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'FlowConfig', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'FlowConfig';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsPublished' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsPublished', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'IsPublished';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsPublished', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'IsPublished';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'RequiresAuth' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'RequiresAuth', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'RequiresAuth';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'RequiresAuth', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'RequiresAuth';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'CreatedBy';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'CreatedBy';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedBy' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'UpdatedBy';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'UpdatedBy';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ManageRoles' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ManageRoles', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'ManageRoles';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ManageRoles', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'ManageRoles';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ViewRoles' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ViewRoles', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'ViewRoles';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ViewRoles', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'ViewRoles';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('api_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CallRoles' AND [object_id] = OBJECT_ID('api_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CallRoles', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'CallRoles';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'CallRoles', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'api_definition', @level2type = N'COLUMN', @level2name = N'CallRoles';

-- arch_attachment
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_attachment') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'档案附件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'档案附件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('arch_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ArchFileId' AND [object_id] = OBJECT_ID('arch_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ArchFileId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'ArchFileId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ArchFileId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'ArchFileId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FileId' AND [object_id] = OBJECT_ID('arch_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'FileId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'FileId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FileName' AND [object_id] = OBJECT_ID('arch_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'FileName';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'FileName';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Extension' AND [object_id] = OBJECT_ID('arch_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'扩展名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'Extension';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'扩展名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'Extension';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Size' AND [object_id] = OBJECT_ID('arch_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'Size';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'Size';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FilePath' AND [object_id] = OBJECT_ID('arch_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'FilePath';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'FilePath';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('arch_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_attachment', @level2type = N'COLUMN', @level2name = N'CreatedAt';

-- arch_box
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'档案盒', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'档案盒', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FondId' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'FondId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'FondId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'FondId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'FondId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'TypeId' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'TypeId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'TypeId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'BoxCode' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'BoxCode', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'BoxCode';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'BoxCode', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'BoxCode';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Title' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Title';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Title';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Year' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Year';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Year';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'RetentionPeriod' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'RetentionPeriod', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'RetentionPeriod';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'RetentionPeriod', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'RetentionPeriod';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SecurityLevel' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SecurityLevel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'SecurityLevel';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'SecurityLevel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'SecurityLevel';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Location' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Location', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Location';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Location', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Location';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'RFID' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'RFID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'RFID';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'RFID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'RFID';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FileCount' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'FileCount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'FileCount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'FileCount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'FileCount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Remark' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'备注', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Remark';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'备注', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Remark';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'Status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_box') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('arch_box')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_box', @level2type = N'COLUMN', @level2name = N'CreatedAt';

-- arch_file
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'档案文件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'档案文件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FondId' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'FondId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'FondId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'FondId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'FondId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'TypeId' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'TypeId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'TypeId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'BoxId' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'BoxId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'BoxId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'BoxId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'BoxId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ArchCode' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ArchCode', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'ArchCode';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ArchCode', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'ArchCode';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Title' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Title';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Title';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'DocNumber' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'DocNumber', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'DocNumber';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'DocNumber', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'DocNumber';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Author' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Author', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Author';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Author', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Author';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FileDate' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'FileDate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'FileDate';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'FileDate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'FileDate';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Year' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Year';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Year';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'RetentionPeriod' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'RetentionPeriod', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'RetentionPeriod';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'RetentionPeriod', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'RetentionPeriod';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SecurityLevel' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SecurityLevel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'SecurityLevel';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'SecurityLevel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'SecurityLevel';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'PageCount' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'PageCount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'PageCount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'PageCount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'PageCount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Keywords' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Keywords', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Keywords';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Keywords', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Keywords';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Remark' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'备注', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Remark';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'备注', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'Remark';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SourceFileId' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SourceFileId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'SourceFileId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'SourceFileId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'SourceFileId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('arch_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_file', @level2type = N'COLUMN', @level2name = N'UpdatedAt';

-- arch_fond
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_fond') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'全宗', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'全宗', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_fond') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('arch_fond')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_fond') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID('arch_fond')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'Code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'Code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_fond') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('arch_fond')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_fond') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID('arch_fond')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'Description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'Description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_fond') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID('arch_fond')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'SortOrder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'SortOrder';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_fond') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('arch_fond')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_fond', @level2type = N'COLUMN', @level2name = N'CreatedAt';

-- arch_type
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_type') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'档案分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'档案分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('arch_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID('arch_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type', @level2type = N'COLUMN', @level2name = N'ParentId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type', @level2type = N'COLUMN', @level2name = N'ParentId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID('arch_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type', @level2type = N'COLUMN', @level2name = N'Code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type', @level2type = N'COLUMN', @level2name = N'Code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('arch_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('arch_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID('arch_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type', @level2type = N'COLUMN', @level2name = N'SortOrder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'arch_type', @level2type = N'COLUMN', @level2name = N'SortOrder';

-- bigview_project
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('bigview_project') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'大屏项目', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'大屏项目', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('bigview_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('bigview_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('bigview_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'project_name' AND [object_id] = OBJECT_ID('bigview_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'project_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'project_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'project_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'project_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('bigview_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'state' AND [object_id] = OBJECT_ID('bigview_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态 [-1未发布,1发布]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'state';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'状态 [-1未发布,1发布]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'state';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('bigview_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'create_time' AND [object_id] = OBJECT_ID('bigview_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'create_time';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'create_time';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('bigview_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'create_by' AND [object_id] = OBJECT_ID('bigview_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'create_by';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'create_by';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('bigview_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'is_delete' AND [object_id] = OBJECT_ID('bigview_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'是否删除', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'is_delete';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'是否删除', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'is_delete';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('bigview_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'index_image' AND [object_id] = OBJECT_ID('bigview_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'index_image', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'index_image';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'index_image', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'index_image';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('bigview_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'content' AND [object_id] = OBJECT_ID('bigview_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'content';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'content';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('bigview_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'remarks' AND [object_id] = OBJECT_ID('bigview_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'备注', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'remarks';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'备注', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'bigview_project', @level2type = N'COLUMN', @level2name = N'remarks';

-- contract_attachment
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_attachment') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同附件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同附件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contract_id' AND [object_id] = OBJECT_ID('contract_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'contract_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'contract_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'file_name' AND [object_id] = OBJECT_ID('contract_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'file_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'file_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'file_path' AND [object_id] = OBJECT_ID('contract_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'file_path';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'file_path';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'size' AND [object_id] = OBJECT_ID('contract_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'size';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'size';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_attachment') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'upload_date' AND [object_id] = OBJECT_ID('contract_attachment')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'upload_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'upload_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'upload_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_attachment', @level2type = N'COLUMN', @level2name = N'upload_date';

-- contract_contact
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_contact') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同联系人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同联系人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_contact') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_contact')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_contact') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contract_id' AND [object_id] = OBJECT_ID('contract_contact')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'contract_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'contract_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_contact') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('contract_contact')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_contact') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'role' AND [object_id] = OBJECT_ID('contract_contact')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'role', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'role';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'role', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'role';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_contact') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'phone' AND [object_id] = OBJECT_ID('contract_contact')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'电话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'phone';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'电话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'phone';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_contact') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'email' AND [object_id] = OBJECT_ID('contract_contact')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'邮箱', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'email';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'邮箱', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_contact', @level2type = N'COLUMN', @level2name = N'email';

-- contract_invoice
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同发票', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同发票', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_invoice')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contract_id' AND [object_id] = OBJECT_ID('contract_invoice')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'contract_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'contract_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'invoice_no' AND [object_id] = OBJECT_ID('contract_invoice')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'invoice_no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'invoice_no';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'invoice_no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'invoice_no';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'invoice_date' AND [object_id] = OBJECT_ID('contract_invoice')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'invoice_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'invoice_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'invoice_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'invoice_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'amount' AND [object_id] = OBJECT_ID('contract_invoice')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('contract_invoice')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('contract_invoice')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'attachment_file_name' AND [object_id] = OBJECT_ID('contract_invoice')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'attachment_file_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'attachment_file_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'attachment_file_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'attachment_file_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'attachment_file_path' AND [object_id] = OBJECT_ID('contract_invoice')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'attachment_file_path', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'attachment_file_path';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'attachment_file_path', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'attachment_file_path';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_invoice') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'direction' AND [object_id] = OBJECT_ID('contract_invoice')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'direction', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'direction';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'direction', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_invoice', @level2type = N'COLUMN', @level2name = N'direction';

-- contract_knowledge_category
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_category') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同知识分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同知识分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_knowledge_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('contract_knowledge_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'parent_id' AND [object_id] = OBJECT_ID('contract_knowledge_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category', @level2type = N'COLUMN', @level2name = N'parent_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category', @level2type = N'COLUMN', @level2name = N'parent_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'sort_order' AND [object_id] = OBJECT_ID('contract_knowledge_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'sort_order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category', @level2type = N'COLUMN', @level2name = N'sort_order';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'sort_order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category', @level2type = N'COLUMN', @level2name = N'sort_order';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('contract_knowledge_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_category', @level2type = N'COLUMN', @level2name = N'created_at';

-- contract_knowledge_file
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_file') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同知识文件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同知识文件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_knowledge_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'category_id' AND [object_id] = OBJECT_ID('contract_knowledge_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'category_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'category_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'category_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'category_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('contract_knowledge_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('contract_knowledge_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'file_path' AND [object_id] = OBJECT_ID('contract_knowledge_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'file_path';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'file_path';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'size' AND [object_id] = OBJECT_ID('contract_knowledge_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'size';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'size';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'uploader' AND [object_id] = OBJECT_ID('contract_knowledge_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'uploader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'uploader';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'uploader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'uploader';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'upload_time' AND [object_id] = OBJECT_ID('contract_knowledge_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'upload_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'upload_time';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'upload_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'upload_time';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_knowledge_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'content_type' AND [object_id] = OBJECT_ID('contract_knowledge_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'content_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'content_type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'content_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_knowledge_file', @level2type = N'COLUMN', @level2name = N'content_type';

-- contract_main
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同主表', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同主表', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contract_no' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contract_no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'contract_no';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contract_no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'contract_no';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contract_name' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contract_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'contract_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contract_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'contract_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'partner_name' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'partner_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'partner_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'partner_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'partner_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'sign_date' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'sign_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'sign_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'sign_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'sign_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'start_date' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'start_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'start_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'start_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'start_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'end_date' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'end_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'end_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'end_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'end_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'manager' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'manager', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'manager';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'manager', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'manager';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'total_amount' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'total_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'total_amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'total_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'total_amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'paid_amount' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'paid_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'paid_amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'paid_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'paid_amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'invoiced_amount' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'invoiced_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'invoiced_amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'invoiced_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'invoiced_amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'progress' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'progress', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'progress';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'progress', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'progress';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'currency' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'currency', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'currency';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'currency', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'currency';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'payment_method' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'payment_method', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'payment_method';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'payment_method', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'payment_method';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'tax_id' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'tax_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'tax_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'tax_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'tax_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'description' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'latest_transaction_date' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'latest_transaction_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'latest_transaction_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'latest_transaction_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'latest_transaction_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'files' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'files', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'files';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'files', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'files';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'updated_at' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'updated_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'updated_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'lifecycle_status' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'lifecycle_status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'lifecycle_status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'lifecycle_status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'lifecycle_status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_main') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'pricing_type' AND [object_id] = OBJECT_ID('contract_main')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'pricing_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'pricing_type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'pricing_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_main', @level2type = N'COLUMN', @level2name = N'pricing_type';

-- contract_payment_plan
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_plan') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同付款计划', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同付款计划', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_plan') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_payment_plan')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_plan') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contract_id' AND [object_id] = OBJECT_ID('contract_payment_plan')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'contract_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'contract_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_plan') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'phase' AND [object_id] = OBJECT_ID('contract_payment_plan')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'phase', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'phase';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'phase', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'phase';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_plan') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'due_date' AND [object_id] = OBJECT_ID('contract_payment_plan')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'due_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'due_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'due_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'due_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_plan') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'amount' AND [object_id] = OBJECT_ID('contract_payment_plan')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_plan') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'condition' AND [object_id] = OBJECT_ID('contract_payment_plan')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'condition', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'condition';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'condition', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'condition';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_plan') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('contract_payment_plan')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_plan', @level2type = N'COLUMN', @level2name = N'status';

-- contract_payment_record
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同付款记录', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同付款记录', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_payment_record')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contract_id' AND [object_id] = OBJECT_ID('contract_payment_record')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'contract_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'contract_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'payment_date' AND [object_id] = OBJECT_ID('contract_payment_record')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'payment_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'payment_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'payment_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'payment_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'amount' AND [object_id] = OBJECT_ID('contract_payment_record')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'method' AND [object_id] = OBJECT_ID('contract_payment_record')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'method', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'method';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'method', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'method';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'operator' AND [object_id] = OBJECT_ID('contract_payment_record')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'operator', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'operator';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'operator', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'operator';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'remark' AND [object_id] = OBJECT_ID('contract_payment_record')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'remark', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'remark';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'remark', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'remark';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('contract_payment_record')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'voucher_file_name' AND [object_id] = OBJECT_ID('contract_payment_record')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'voucher_file_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'voucher_file_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'voucher_file_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'voucher_file_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_payment_record') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'voucher_file_path' AND [object_id] = OBJECT_ID('contract_payment_record')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'voucher_file_path', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'voucher_file_path';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'voucher_file_path', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_payment_record', @level2type = N'COLUMN', @level2name = N'voucher_file_path';

-- contract_relation
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_relation') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同关联', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_relation';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同关联', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_relation';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_relation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_relation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_relation', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_relation', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_relation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contract_id' AND [object_id] = OBJECT_ID('contract_relation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_relation', @level2type = N'COLUMN', @level2name = N'contract_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_relation', @level2type = N'COLUMN', @level2name = N'contract_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_relation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'related_contract_id' AND [object_id] = OBJECT_ID('contract_relation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'related_contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_relation', @level2type = N'COLUMN', @level2name = N'related_contract_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'related_contract_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_relation', @level2type = N'COLUMN', @level2name = N'related_contract_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_relation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('contract_relation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_relation', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_relation', @level2type = N'COLUMN', @level2name = N'created_at';

-- contract_stat
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同统计', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同统计', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'period_type' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'period_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'period_type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'period_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'period_type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'period_key' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'period_key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'period_key';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'period_key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'period_key';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'stat_date' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'stat_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'stat_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'stat_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'stat_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'total_contracts' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'total_contracts', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'total_contracts';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'total_contracts', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'total_contracts';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'total_amount' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'total_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'total_amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'total_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'total_amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'received_amount' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'received_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'received_amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'received_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'received_amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'invoiced_amount' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'invoiced_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'invoiced_amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'invoiced_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'invoiced_amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'pending_invoice_amount' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'pending_invoice_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'pending_invoice_amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'pending_invoice_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'pending_invoice_amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'sales_count' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'sales_count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'sales_count';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'sales_count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'sales_count';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'purchase_count' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'purchase_count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'purchase_count';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'purchase_count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'purchase_count';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'amount_completion_rate' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'amount_completion_rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'amount_completion_rate';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'amount_completion_rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'amount_completion_rate';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'received_rate' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'received_rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'received_rate';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'received_rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'received_rate';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_stat') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'total_contracts_growth' AND [object_id] = OBJECT_ID('contract_stat')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'total_contracts_growth', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'total_contracts_growth';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'total_contracts_growth', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_stat', @level2type = N'COLUMN', @level2name = N'total_contracts_growth';

-- contract_template
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_template') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'合同模板', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'合同模板', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_template') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('contract_template')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_template') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('contract_template')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_template') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('contract_template')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_template') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'description' AND [object_id] = OBJECT_ID('contract_template')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_template') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'file_path' AND [object_id] = OBJECT_ID('contract_template')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'file_path';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'file_path';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_template') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'file_name' AND [object_id] = OBJECT_ID('contract_template')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'file_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'file_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_template') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('contract_template')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_template') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('contract_template')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('contract_template') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'updated_at' AND [object_id] = OBJECT_ID('contract_template')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'updated_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'contract_template', @level2type = N'COLUMN', @level2name = N'updated_at';

-- data_source_connection
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'数据源连接', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'数据源连接', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('data_source_connection')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('data_source_connection')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID('data_source_connection')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Host' AND [object_id] = OBJECT_ID('data_source_connection')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Host', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Host';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Host', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Host';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Port' AND [object_id] = OBJECT_ID('data_source_connection')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Port', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Port';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Port', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Port';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'User' AND [object_id] = OBJECT_ID('data_source_connection')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'User', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'User';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'User', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'User';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Password' AND [object_id] = OBJECT_ID('data_source_connection')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'密码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Password';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'密码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Password';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Database' AND [object_id] = OBJECT_ID('data_source_connection')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Database', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Database';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Database', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'Database';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('data_source_connection')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('data_source_connection') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('data_source_connection')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'data_source_connection', @level2type = N'COLUMN', @level2name = N'UpdatedAt';

-- frm_category
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_category') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'表单分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'表单分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('frm_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('frm_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID('frm_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'ParentId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'ParentId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID('frm_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'SortOrder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'SortOrder';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('frm_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID('frm_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'CreatedBy';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_category', @level2type = N'COLUMN', @level2name = N'CreatedBy';

-- frm_data
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_data') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'表单数据', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'表单数据', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('frm_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'form_id' AND [object_id] = OBJECT_ID('frm_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'form_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data', @level2type = N'COLUMN', @level2name = N'form_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'form_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data', @level2type = N'COLUMN', @level2name = N'form_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'data' AND [object_id] = OBJECT_ID('frm_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'data', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data', @level2type = N'COLUMN', @level2name = N'data';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'data', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data', @level2type = N'COLUMN', @level2name = N'data';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'submitted_at' AND [object_id] = OBJECT_ID('frm_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'submitted_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data', @level2type = N'COLUMN', @level2name = N'submitted_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'submitted_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data', @level2type = N'COLUMN', @level2name = N'submitted_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'submitted_by' AND [object_id] = OBJECT_ID('frm_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'submitted_by', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data', @level2type = N'COLUMN', @level2name = N'submitted_by';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'submitted_by', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_data', @level2type = N'COLUMN', @level2name = N'submitted_by';

-- frm_definition
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'表单定义', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'表单定义', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CategoryId' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CategoryId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'CategoryId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'CategoryId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'CategoryId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'Code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'Code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'Description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'Description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FormItems' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'FormItems', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'FormItems';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'FormItems', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'FormItems';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsPublished' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsPublished', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'IsPublished';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsPublished', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'IsPublished';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'CreatedBy';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'CreatedBy';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedBy' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'UpdatedBy';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'UpdatedBy';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'RequiresLogin' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'RequiresLogin', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'RequiresLogin';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'RequiresLogin', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'RequiresLogin';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'LimitOnePerUser' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'LimitOnePerUser', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'LimitOnePerUser';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'LimitOnePerUser', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'LimitOnePerUser';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FillRoleIds' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'FillRoleIds', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'FillRoleIds';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'FillRoleIds', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'FillRoleIds';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ManageRoleIds' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ManageRoleIds', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'ManageRoleIds';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ManageRoleIds', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'ManageRoleIds';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('frm_definition') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ViewRoleIds' AND [object_id] = OBJECT_ID('frm_definition')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ViewRoleIds', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'ViewRoleIds';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ViewRoleIds', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'frm_definition', @level2type = N'COLUMN', @level2name = N'ViewRoleIds';

-- kb_file
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'知识库文件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'知识库文件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('kb_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'KbId' AND [object_id] = OBJECT_ID('kb_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'KbId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'KbId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'KbId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'KbId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('kb_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Size' AND [object_id] = OBJECT_ID('kb_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Size';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Size';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Extension' AND [object_id] = OBJECT_ID('kb_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'扩展名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Extension';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'扩展名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Extension';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Path' AND [object_id] = OBJECT_ID('kb_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Path';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Path';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID('kb_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'Status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UploadTime' AND [object_id] = OBJECT_ID('kb_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'UploadTime', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'UploadTime';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'UploadTime', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'UploadTime';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsFolder' AND [object_id] = OBJECT_ID('kb_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsFolder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'IsFolder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsFolder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'IsFolder';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID('kb_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'ParentId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_file', @level2type = N'COLUMN', @level2name = N'ParentId';

-- kb_info
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_info') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'知识库信息', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'知识库信息', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('kb_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('kb_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID('kb_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'Description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'Description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Category' AND [object_id] = OBJECT_ID('kb_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Category', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'Category';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Category', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'Category';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID('kb_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'Type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'Type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('kb_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('kb_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID('kb_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'CreatedBy';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'CreatedBy';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID('kb_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'SortOrder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_info', @level2type = N'COLUMN', @level2name = N'SortOrder';

-- kb_node_source
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_node_source') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'知识库节点源', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'知识库节点源', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_node_source') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('kb_node_source')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_node_source') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'NodeId' AND [object_id] = OBJECT_ID('kb_node_source')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'NodeId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source', @level2type = N'COLUMN', @level2name = N'NodeId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'NodeId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source', @level2type = N'COLUMN', @level2name = N'NodeId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_node_source') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FileId' AND [object_id] = OBJECT_ID('kb_node_source')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source', @level2type = N'COLUMN', @level2name = N'FileId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source', @level2type = N'COLUMN', @level2name = N'FileId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_node_source') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Page' AND [object_id] = OBJECT_ID('kb_node_source')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Page', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source', @level2type = N'COLUMN', @level2name = N'Page';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Page', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source', @level2type = N'COLUMN', @level2name = N'Page';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_node_source') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID('kb_node_source')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source', @level2type = N'COLUMN', @level2name = N'Description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_node_source', @level2type = N'COLUMN', @level2name = N'Description';

-- kb_qa_history
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_qa_history') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'知识库问答历史', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'知识库问答历史', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_qa_history') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('kb_qa_history')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_qa_history') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'KbId' AND [object_id] = OBJECT_ID('kb_qa_history')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'KbId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'KbId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'KbId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'KbId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_qa_history') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UserId' AND [object_id] = OBJECT_ID('kb_qa_history')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'UserId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'UserId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_qa_history') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Question' AND [object_id] = OBJECT_ID('kb_qa_history')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Question', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'Question';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Question', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'Question';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_qa_history') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Answer' AND [object_id] = OBJECT_ID('kb_qa_history')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Answer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'Answer';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Answer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'Answer';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_qa_history') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('kb_qa_history')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('kb_qa_history') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SourcesJson' AND [object_id] = OBJECT_ID('kb_qa_history')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SourcesJson', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'SourcesJson';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'SourcesJson', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'kb_qa_history', @level2type = N'COLUMN', @level2name = N'SourcesJson';

-- page_categories
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_categories') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'页面分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_categories';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'页面分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_categories';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_categories') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('page_categories')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_categories', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_categories', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_categories') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('page_categories')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_categories', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_categories', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_categories') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID('page_categories')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_categories', @level2type = N'COLUMN', @level2name = N'ParentId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_categories', @level2type = N'COLUMN', @level2name = N'ParentId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_categories') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID('page_categories')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_categories', @level2type = N'COLUMN', @level2name = N'SortOrder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_categories', @level2type = N'COLUMN', @level2name = N'SortOrder';

-- page_definitions
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_definitions') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'页面定义', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'页面定义', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_definitions') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('page_definitions')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_definitions') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('page_definitions')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_definitions') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CategoryId' AND [object_id] = OBJECT_ID('page_definitions')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CategoryId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'CategoryId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'CategoryId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'CategoryId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_definitions') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID('page_definitions')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'Code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'Code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_definitions') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Config' AND [object_id] = OBJECT_ID('page_definitions')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Config', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'Config';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Config', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'Config';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_definitions') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ApiBindings' AND [object_id] = OBJECT_ID('page_definitions')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ApiBindings', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'ApiBindings';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ApiBindings', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'ApiBindings';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_definitions') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID('page_definitions')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'Description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'Description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_definitions') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('page_definitions')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('page_definitions') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('page_definitions')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'page_definitions', @level2type = N'COLUMN', @level2name = N'UpdatedAt';

-- pdm_ebom_documents
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_documents') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'PDM EBOM文档', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'PDM EBOM文档', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_documents') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('pdm_ebom_documents')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_documents') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ebom_item_id' AND [object_id] = OBJECT_ID('pdm_ebom_documents')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ebom_item_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'ebom_item_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ebom_item_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'ebom_item_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_documents') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('pdm_ebom_documents')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_documents') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'path' AND [object_id] = OBJECT_ID('pdm_ebom_documents')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'path';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'path';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_documents') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'file_type' AND [object_id] = OBJECT_ID('pdm_ebom_documents')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'file_type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'file_type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_documents') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'size' AND [object_id] = OBJECT_ID('pdm_ebom_documents')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'size';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'size';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_documents') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'uploaded_at' AND [object_id] = OBJECT_ID('pdm_ebom_documents')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'uploaded_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'uploaded_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'uploaded_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'uploaded_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_documents') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'uploaded_by' AND [object_id] = OBJECT_ID('pdm_ebom_documents')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'uploaded_by', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'uploaded_by';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'uploaded_by', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_documents', @level2type = N'COLUMN', @level2name = N'uploaded_by';

-- pdm_ebom_items
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'PDM EBOM物料', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'PDM EBOM物料', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'version' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'version', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'version';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'version', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'version';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'designer' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'designer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'designer';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'designer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'designer';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'spec' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'spec', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'spec';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'spec', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'spec';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'unit' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'unit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'unit';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'unit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'unit';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'is_leaf' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'is_leaf', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'is_leaf';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'is_leaf', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'is_leaf';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'updated_at' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'updated_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'updated_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_items') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'product_type' AND [object_id] = OBJECT_ID('pdm_ebom_items')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'product_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'product_type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'product_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_items', @level2type = N'COLUMN', @level2name = N'product_type';

-- pdm_ebom_structure
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_structure') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'PDM EBOM结构', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'PDM EBOM结构', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_structure') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('pdm_ebom_structure')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_structure') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'parent_id' AND [object_id] = OBJECT_ID('pdm_ebom_structure')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'parent_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'parent_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_structure') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'child_id' AND [object_id] = OBJECT_ID('pdm_ebom_structure')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'child_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'child_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'child_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'child_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_structure') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'quantity' AND [object_id] = OBJECT_ID('pdm_ebom_structure')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'quantity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'quantity';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'quantity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'quantity';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_structure') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'sort_order' AND [object_id] = OBJECT_ID('pdm_ebom_structure')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'sort_order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'sort_order';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'sort_order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'sort_order';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_structure') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('pdm_ebom_structure')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('pdm_ebom_structure') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'child_version' AND [object_id] = OBJECT_ID('pdm_ebom_structure')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'child_version', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'child_version';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'child_version', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pdm_ebom_structure', @level2type = N'COLUMN', @level2name = N'child_version';

-- project_attachments
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_attachments') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'项目附件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'项目附件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_attachments') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('project_attachments')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_attachments') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'taskId' AND [object_id] = OBJECT_ID('project_attachments')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'taskId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'taskId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'taskId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'taskId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_attachments') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'project_code' AND [object_id] = OBJECT_ID('project_attachments')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'project_code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'project_code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_attachments') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('project_attachments')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_attachments') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'url' AND [object_id] = OBJECT_ID('project_attachments')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'链接', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'url';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'链接', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'url';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_attachments') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('project_attachments')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_attachments') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'uploadDate' AND [object_id] = OBJECT_ID('project_attachments')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'uploadDate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'uploadDate';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'uploadDate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_attachments', @level2type = N'COLUMN', @level2name = N'uploadDate';

-- project_info
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_info') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'项目信息', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'项目信息', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'code' AND [object_id] = OBJECT_ID('project_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('project_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('project_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'description' AND [object_id] = OBJECT_ID('project_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'manager' AND [object_id] = OBJECT_ID('project_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'manager', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'manager';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'manager', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'manager';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'planned_start_date' AND [object_id] = OBJECT_ID('project_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'planned_start_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'planned_start_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'planned_start_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'planned_start_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_info') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'planned_end_date' AND [object_id] = OBJECT_ID('project_info')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'planned_end_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'planned_end_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'planned_end_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_info', @level2type = N'COLUMN', @level2name = N'planned_end_date';

-- project_members
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_members') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'项目成员', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'项目成员', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_members') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('project_members')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_members') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'project_code' AND [object_id] = OBJECT_ID('project_members')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members', @level2type = N'COLUMN', @level2name = N'project_code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members', @level2type = N'COLUMN', @level2name = N'project_code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_members') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'username' AND [object_id] = OBJECT_ID('project_members')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'username', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members', @level2type = N'COLUMN', @level2name = N'username';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'username', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members', @level2type = N'COLUMN', @level2name = N'username';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_members') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'role' AND [object_id] = OBJECT_ID('project_members')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'role', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members', @level2type = N'COLUMN', @level2name = N'role';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'role', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members', @level2type = N'COLUMN', @level2name = N'role';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_members') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'joined_at' AND [object_id] = OBJECT_ID('project_members')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'joined_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members', @level2type = N'COLUMN', @level2name = N'joined_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'joined_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_members', @level2type = N'COLUMN', @level2name = N'joined_at';

-- project_phases
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_phases') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'项目阶段', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_phases';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'项目阶段', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_phases';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_phases') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('project_phases')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_phases', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_phases', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_phases') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'project_code' AND [object_id] = OBJECT_ID('project_phases')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_phases', @level2type = N'COLUMN', @level2name = N'project_code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_phases', @level2type = N'COLUMN', @level2name = N'project_code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_phases') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('project_phases')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_phases', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_phases', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_phases') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'color' AND [object_id] = OBJECT_ID('project_phases')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'color', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_phases', @level2type = N'COLUMN', @level2name = N'color';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'color', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_phases', @level2type = N'COLUMN', @level2name = N'color';

-- project_swimlanes
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_swimlanes') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'项目泳道', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_swimlanes';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'项目泳道', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_swimlanes';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_swimlanes') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('project_swimlanes')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_swimlanes', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_swimlanes', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_swimlanes') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'project_code' AND [object_id] = OBJECT_ID('project_swimlanes')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_swimlanes', @level2type = N'COLUMN', @level2name = N'project_code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_swimlanes', @level2type = N'COLUMN', @level2name = N'project_code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_swimlanes') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('project_swimlanes')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_swimlanes', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_swimlanes', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_swimlanes') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'color' AND [object_id] = OBJECT_ID('project_swimlanes')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'color', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_swimlanes', @level2type = N'COLUMN', @level2name = N'color';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'color', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_swimlanes', @level2type = N'COLUMN', @level2name = N'color';

-- project_task_dependencies
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_task_dependencies') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'项目任务依赖', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'项目任务依赖', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_task_dependencies') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('project_task_dependencies')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_task_dependencies') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'taskId' AND [object_id] = OBJECT_ID('project_task_dependencies')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'taskId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'taskId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'taskId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'taskId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_task_dependencies') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'dependencyId' AND [object_id] = OBJECT_ID('project_task_dependencies')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'dependencyId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'dependencyId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'dependencyId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'dependencyId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_task_dependencies') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'project_code' AND [object_id] = OBJECT_ID('project_task_dependencies')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'project_code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'project_code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_task_dependencies') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('project_task_dependencies')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_task_dependencies') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'sourcePort' AND [object_id] = OBJECT_ID('project_task_dependencies')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'sourcePort', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'sourcePort';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'sourcePort', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'sourcePort';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_task_dependencies') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'targetPort' AND [object_id] = OBJECT_ID('project_task_dependencies')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'targetPort', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'targetPort';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'targetPort', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'targetPort';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_task_dependencies') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'controlPoints' AND [object_id] = OBJECT_ID('project_task_dependencies')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'controlPoints', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'controlPoints';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'controlPoints', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'controlPoints';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_task_dependencies') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'controlPointCount' AND [object_id] = OBJECT_ID('project_task_dependencies')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'controlPointCount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'controlPointCount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'controlPointCount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_task_dependencies', @level2type = N'COLUMN', @level2name = N'controlPointCount';

-- project_tasks
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'项目任务', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'项目任务', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'project_code' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'project_code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'project_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'project_code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'phaseId' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'phaseId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'phaseId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'phaseId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'phaseId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'swimlaneId' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'swimlaneId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'swimlaneId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'swimlaneId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'swimlaneId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'progress' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'progress', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'progress';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'progress', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'progress';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'owner' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'owner', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'owner';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'owner', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'owner';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'startDate' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'startDate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'startDate';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'startDate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'startDate';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'endDate' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'endDate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'endDate';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'endDate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'endDate';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'description' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'x' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'x', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'x';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'x', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'x';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'y' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'y', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'y';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'y', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'y';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'startColor' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'startColor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'startColor';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'startColor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'startColor';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'endColor' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'endColor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'endColor';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'endColor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'endColor';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('project_tasks') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'width' AND [object_id] = OBJECT_ID('project_tasks')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'width', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'width';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'width', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'project_tasks', @level2type = N'COLUMN', @level2name = N'width';

-- sales_bid_analysis
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标书分析', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标书分析', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'bid_project_id' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'bid_project_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'bid_project_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'bid_project_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'bid_project_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'tender_type' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'tender_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'tender_type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'tender_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'tender_type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'deadline' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'deadline', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'deadline';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'deadline', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'deadline';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'bid_bond' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'bid_bond', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'bid_bond';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'bid_bond', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'bid_bond';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'budget' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'budget', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'budget';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'budget', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'budget';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'qualification' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'qualification', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'qualification';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'qualification', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'qualification';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'updated_at' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'updated_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'updated_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'file_name' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'file_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'file_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'file_url' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'file_url', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'file_url';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'file_url', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'file_url';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'agency_name' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'agency_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'agency_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'agency_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'agency_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'bid_end_time' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'bid_end_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'bid_end_time';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'bid_end_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'bid_end_time';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'bid_start_time' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'bid_start_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'bid_start_time';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'bid_start_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'bid_start_time';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contact_name' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contact_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'contact_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contact_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'contact_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contact_phone' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contact_phone', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'contact_phone';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contact_phone', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'contact_phone';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'open_bid_time' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'open_bid_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'open_bid_time';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'open_bid_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'open_bid_time';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'tender_start_time' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'tender_start_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'tender_start_time';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'tender_start_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'tender_start_time';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'publish_time' AND [object_id] = OBJECT_ID('sales_bid_analysis')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'publish_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'publish_time';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'publish_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis', @level2type = N'COLUMN', @level2name = N'publish_time';

-- sales_bid_analysis_log
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_log') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标书分析日志', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标书分析日志', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_bid_analysis_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'run_id' AND [object_id] = OBJECT_ID('sales_bid_analysis_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'run_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log', @level2type = N'COLUMN', @level2name = N'run_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'run_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log', @level2type = N'COLUMN', @level2name = N'run_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'bid_project_id' AND [object_id] = OBJECT_ID('sales_bid_analysis_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'bid_project_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log', @level2type = N'COLUMN', @level2name = N'bid_project_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'bid_project_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log', @level2type = N'COLUMN', @level2name = N'bid_project_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'message' AND [object_id] = OBJECT_ID('sales_bid_analysis_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'message', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log', @level2type = N'COLUMN', @level2name = N'message';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'message', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log', @level2type = N'COLUMN', @level2name = N'message';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('sales_bid_analysis_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_log', @level2type = N'COLUMN', @level2name = N'created_at';

-- sales_bid_analysis_run
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_run') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标书分析运行', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标书分析运行', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_run') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_bid_analysis_run')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_run') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'bid_project_id' AND [object_id] = OBJECT_ID('sales_bid_analysis_run')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'bid_project_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'bid_project_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'bid_project_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'bid_project_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_run') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('sales_bid_analysis_run')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_run') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'started_at' AND [object_id] = OBJECT_ID('sales_bid_analysis_run')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'started_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'started_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'started_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'started_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_run') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'finished_at' AND [object_id] = OBJECT_ID('sales_bid_analysis_run')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'finished_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'finished_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'finished_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'finished_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_analysis_run') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_by' AND [object_id] = OBJECT_ID('sales_bid_analysis_run')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_by', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'created_by';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_by', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_analysis_run', @level2type = N'COLUMN', @level2name = N'created_by';

-- sales_bid_chapter
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标书章节', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标书章节', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'analysis_id' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'analysis_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'analysis_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'analysis_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'analysis_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'parent_id' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'parent_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'parent_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'title' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'title';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'title';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'chapter_type' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'chapter_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'chapter_type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'chapter_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'chapter_type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'content' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'content';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'content';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'analysis_result' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'analysis_result', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'analysis_result';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'analysis_result', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'analysis_result';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'risk_level' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'risk_level', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'risk_level';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'risk_level', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'risk_level';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'is_veto' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'is_veto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'is_veto';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'is_veto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'is_veto';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'score_weight' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'score_weight', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'score_weight';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'score_weight', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'score_weight';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'sort_order' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'sort_order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'sort_order';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'sort_order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'sort_order';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_chapter') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'extractions_json' AND [object_id] = OBJECT_ID('sales_bid_chapter')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'extractions_json', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'extractions_json';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'extractions_json', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_chapter', @level2type = N'COLUMN', @level2name = N'extractions_json';

-- sales_bid_project
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标书项目', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标书项目', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'code' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'customer' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'customer';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'customer';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'region' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'region', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'region';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'region', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'region';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'budget' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'budget', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'budget';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'budget', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'budget';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'bid_time' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'bid_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'bid_time';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'bid_time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'bid_time';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'leader' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'leader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'leader';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'leader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'leader';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'description' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_bid_project') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'updated_at' AND [object_id] = OBJECT_ID('sales_bid_project')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'updated_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_bid_project', @level2type = N'COLUMN', @level2name = N'updated_at';

-- sales_customer
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'销售客户', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'销售客户', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'credit_code' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'credit_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'credit_code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'credit_code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'credit_code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'industry' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'industry', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'industry';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'industry', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'industry';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'contact' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'contact', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'contact';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'contact', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'contact';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'phone' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'电话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'phone';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'电话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'phone';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'email' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'邮箱', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'email';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'邮箱', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'email';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'level' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'level', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'level';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'level', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'level';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'address' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'address', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'address';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'address', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'address';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'source' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'source', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'source';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'source', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'source';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'description' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'owner' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'owner', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'owner';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'owner', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'owner';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'updated_at' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'updated_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'updated_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_customer') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'org_id' AND [object_id] = OBJECT_ID('sales_customer')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'org_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_customer', @level2type = N'COLUMN', @level2name = N'org_id';

-- sales_opportunity
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'销售商机', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'销售商机', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'title' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'title';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'title';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'customer' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'customer';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'customer';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'customer_id' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'customer_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'customer_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'customer_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'customer_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'amount' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'stage' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'stage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'stage';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'stage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'stage';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'win_rate' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'win_rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'win_rate';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'win_rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'win_rate';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'owner' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'owner', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'owner';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'owner', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'owner';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'description' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'estimated_close_date' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'estimated_close_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'estimated_close_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'estimated_close_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'estimated_close_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_opportunity') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'updated_at' AND [object_id] = OBJECT_ID('sales_opportunity')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'updated_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_opportunity', @level2type = N'COLUMN', @level2name = N'updated_at';

-- sales_process_rule
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_process_rule') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'销售流程规则', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'销售流程规则', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_process_rule') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_process_rule')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_process_rule') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'title' AND [object_id] = OBJECT_ID('sales_process_rule')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule', @level2type = N'COLUMN', @level2name = N'title';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule', @level2type = N'COLUMN', @level2name = N'title';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_process_rule') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'content' AND [object_id] = OBJECT_ID('sales_process_rule')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule', @level2type = N'COLUMN', @level2name = N'content';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule', @level2type = N'COLUMN', @level2name = N'content';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_process_rule') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('sales_process_rule')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_process_rule') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'org_id' AND [object_id] = OBJECT_ID('sales_process_rule')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule', @level2type = N'COLUMN', @level2name = N'org_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_process_rule', @level2type = N'COLUMN', @level2name = N'org_id';

-- sales_product_doc
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_product_doc') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'销售产品文档', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'销售产品文档', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_product_doc') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_product_doc')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_product_doc') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'title' AND [object_id] = OBJECT_ID('sales_product_doc')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'title';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'title';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_product_doc') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'size' AND [object_id] = OBJECT_ID('sales_product_doc')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'size';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'size';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_product_doc') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'url' AND [object_id] = OBJECT_ID('sales_product_doc')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'链接', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'url';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'链接', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'url';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_product_doc') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'upload_date' AND [object_id] = OBJECT_ID('sales_product_doc')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'upload_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'upload_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'upload_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'upload_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_product_doc') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'parent_id' AND [object_id] = OBJECT_ID('sales_product_doc')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'parent_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'parent_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_product_doc') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'type' AND [object_id] = OBJECT_ID('sales_product_doc')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_product_doc') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'org_id' AND [object_id] = OBJECT_ID('sales_product_doc')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'org_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_product_doc', @level2type = N'COLUMN', @level2name = N'org_id';

-- sales_registrations
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'销售登记', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'销售登记', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ProjectName' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ProjectName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'ProjectName';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ProjectName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'ProjectName';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CustomerName' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CustomerName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'CustomerName';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'CustomerName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'CustomerName';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Contact' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Contact', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Contact';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Contact', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Contact';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Phone' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'电话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Phone';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'电话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Phone';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Amount' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Date' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Owner' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Owner', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Owner';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Owner', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Owner';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Remarks' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Remarks', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Remarks';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Remarks', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'Remarks';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_registrations') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'OrgId' AND [object_id] = OBJECT_ID('sales_registrations')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'OrgId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_registrations', @level2type = N'COLUMN', @level2name = N'OrgId';

-- sales_script
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_script') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'销售话术', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'销售话术', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_script') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_script')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_script') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'title' AND [object_id] = OBJECT_ID('sales_script')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'title';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'title';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_script') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'content' AND [object_id] = OBJECT_ID('sales_script')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'content';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'content';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_script') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'category' AND [object_id] = OBJECT_ID('sales_script')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'category', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'category';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'category', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'category';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_script') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('sales_script')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_script') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'description' AND [object_id] = OBJECT_ID('sales_script')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_script') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'org_id' AND [object_id] = OBJECT_ID('sales_script')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'org_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_script', @level2type = N'COLUMN', @level2name = N'org_id';

-- sales_target
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'销售目标', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'销售目标', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'id' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'period' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'period', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'period';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'period', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'period';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'target_type' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'target_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'target_type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'target_type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'target_type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'target_id' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'target_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'target_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'target_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'target_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'target_name' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'target_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'target_name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'target_name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'target_name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'target_amount' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'target_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'target_amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'target_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'target_amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'completed_amount' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'completed_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'completed_amount';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'completed_amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'completed_amount';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'start_date' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'start_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'start_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'start_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'start_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'end_date' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'end_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'end_date';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'end_date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'end_date';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'created_at' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'created_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'created_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'created_at';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sales_target') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'updated_at' AND [object_id] = OBJECT_ID('sales_target')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'updated_at';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'updated_at', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sales_target', @level2type = N'COLUMN', @level2name = N'updated_at';

-- sys_ai_generated_content
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_ai_generated_content') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'AI生成内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'AI生成内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_ai_generated_content') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_ai_generated_content')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_ai_generated_content') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID('sys_ai_generated_content')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型：greeting (问候语), slogan (标语)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'Type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型：greeting (问候语), slogan (标语)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'Type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_ai_generated_content') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Content' AND [object_id] = OBJECT_ID('sys_ai_generated_content')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'Content';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'Content';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_ai_generated_content') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_ai_generated_content')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_ai_generated_content') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID('sys_ai_generated_content')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'CreatedBy';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建人', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'CreatedBy';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_ai_generated_content') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IpAddress' AND [object_id] = OBJECT_ID('sys_ai_generated_content')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IpAddress', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'IpAddress';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IpAddress', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_ai_generated_content', @level2type = N'COLUMN', @level2name = N'IpAddress';

-- sys_anonce
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'系统公告', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'系统公告', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Title' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'公告标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Title';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'公告标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Title';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Content' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'公告内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Content';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'公告内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Content';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'公告类型 (关联字典 anonce_type)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'公告类型 (关联字典 anonce_type)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态 (draft:草稿, published:已发布, revoked:已撤回)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'状态 (draft:草稿, published:已发布, revoked:已撤回)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'PublishTime' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'发布时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'PublishTime';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'发布时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'PublishTime';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedBy' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建人ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'CreatedBy';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建人ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'CreatedBy';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedBy' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新人ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'UpdatedBy';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新人ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'UpdatedBy';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_anonce') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Priority' AND [object_id] = OBJECT_ID('sys_anonce')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'优先级 (high, normal, low)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Priority';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'优先级 (high, normal, low)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_anonce', @level2type = N'COLUMN', @level2name = N'Priority';

-- sys_audit_log
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'审计日志', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'审计日志', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UserId' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'UserId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'UserId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UserName' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'UserName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'UserName';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'UserName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'UserName';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Action' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Action', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'Action';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Action', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'Action';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Route' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Route', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'Route';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Route', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'Route';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Method' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Method', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'Method';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Method', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'Method';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IpAddress' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IpAddress', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'IpAddress';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IpAddress', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'IpAddress';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UserAgent' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'UserAgent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'UserAgent';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'UserAgent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'UserAgent';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Parameters' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Parameters', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'Parameters';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Parameters', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'Parameters';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsSuccess' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsSuccess', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'IsSuccess';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsSuccess', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'IsSuccess';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ErrorMessage' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ErrorMessage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'ErrorMessage';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ErrorMessage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'ErrorMessage';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ExecutionDuration' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ExecutionDuration', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'ExecutionDuration';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ExecutionDuration', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'ExecutionDuration';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_audit_log') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_audit_log')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_audit_log', @level2type = N'COLUMN', @level2name = N'CreatedAt';

-- sys_chat_conversation
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'聊天会话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'聊天会话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ConversationKey' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ConversationKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'ConversationKey';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ConversationKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'ConversationKey';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'0=Private, 1=Group, 2=System, 3=App', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'Type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'0=Private, 1=Group, 2=System, 3=App', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'Type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'User1Id' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'User1Id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'User1Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'User1Id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'User1Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'User2Id' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'User2Id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'User2Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'User2Id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'User2Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'RelatedId' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'关联ID。 对于群组(Type=1)，此处存GroupId。 对于系统/应用(Type=2/3)，如果模块有ID则存ID；如果只有字符串代码(如 \"workflow\")，则此处存null，通过 ConversationKey 区分。', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'RelatedId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'关联ID。 对于群组(Type=1)，此处存GroupId。 对于系统/应用(Type=2/3)，如果模块有ID则存ID；如果只有字符串代码(如 \"workflow\")，则此处存null，通过 ConversationKey 区分。', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'RelatedId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Avatar' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'头像', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'Avatar';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'头像', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'Avatar';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'LastMessageContent' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'LastMessageContent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'LastMessageContent';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'LastMessageContent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'LastMessageContent';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'LastMessageType' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'LastMessageType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'LastMessageType';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'LastMessageType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'LastMessageType';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'LastMessageTime' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'LastMessageTime', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'LastMessageTime';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'LastMessageTime', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'LastMessageTime';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_conversation') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_chat_conversation')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_conversation', @level2type = N'COLUMN', @level2name = N'UpdatedAt';

-- sys_chat_message
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'聊天消息', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'聊天消息', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_chat_message')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ConversationKey' AND [object_id] = OBJECT_ID('sys_chat_message')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ConversationKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'ConversationKey';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ConversationKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'ConversationKey';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SenderConnectionId' AND [object_id] = OBJECT_ID('sys_chat_message')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SenderConnectionId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'SenderConnectionId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'SenderConnectionId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'SenderConnectionId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SenderUserId' AND [object_id] = OBJECT_ID('sys_chat_message')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SenderUserId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'SenderUserId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'SenderUserId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'SenderUserId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SenderUserName' AND [object_id] = OBJECT_ID('sys_chat_message')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SenderUserName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'SenderUserName';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'SenderUserName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'SenderUserName';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID('sys_chat_message')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'Type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'Type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Content' AND [object_id] = OBJECT_ID('sys_chat_message')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'Content';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'内容', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'Content';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FileName' AND [object_id] = OBJECT_ID('sys_chat_message')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'FileName';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'FileName';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FileSize' AND [object_id] = OBJECT_ID('sys_chat_message')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件大小', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'FileSize';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件大小', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'FileSize';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_chat_message') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_chat_message')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_chat_message', @level2type = N'COLUMN', @level2name = N'CreatedAt';

-- sys_config
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'系统配置', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'系统配置', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Category' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Category', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Category';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Category', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Category';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Key' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Key';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Key';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Value' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Value';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Value';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsSystem' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsSystem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'IsSystem';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsSystem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'IsSystem';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsOverridable' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsOverridable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'IsOverridable';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsOverridable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'IsOverridable';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'OrgId' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'OrgId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'OrgId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_config') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID('sys_config')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'Type';

-- sys_dept
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'部门', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'部门', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'ParentId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'ParentId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Leader' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Leader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Leader';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Leader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Leader';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Phone' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'电话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Phone';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'电话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Phone';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Email' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'邮箱', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Email';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'邮箱', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Email';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'SortOrder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'SortOrder';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsActive' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsActive', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'IsActive';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsActive', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'IsActive';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'X' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'X', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'X';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'X', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'X';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dept') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Y' AND [object_id] = OBJECT_ID('sys_dept')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Y', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Y';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Y', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dept', @level2type = N'COLUMN', @level2name = N'Y';

-- sys_dict_category
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_category') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'字典分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'字典分类', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_dict_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'parent_id' AND [object_id] = OBJECT_ID('sys_dict_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'parent_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'parent_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('sys_dict_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'code' AND [object_id] = OBJECT_ID('sys_dict_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'sort' AND [object_id] = OBJECT_ID('sys_dict_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'sort', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'sort';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'sort', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'sort';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'remark' AND [object_id] = OBJECT_ID('sys_dict_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'remark', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'remark';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'remark', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'remark';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_dict_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_category') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_dict_category')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_category', @level2type = N'COLUMN', @level2name = N'UpdatedAt';

-- sys_dict_data
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'字典数据', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'字典数据', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'dict_type_id' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'dict_type_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'dict_type_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'dict_type_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'dict_type_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'label' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'label', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'label';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'label', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'label';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'value' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'value';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'value';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'sort' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'sort', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'sort';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'sort', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'sort';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'is_default' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'is_default', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'is_default';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'is_default', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'is_default';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'css_class' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'css_class', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'css_class';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'css_class', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'css_class';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'list_class' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'list_class', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'list_class';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'list_class', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'list_class';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'remark' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'remark', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'remark';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'remark', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'remark';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_data') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_dict_data')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_data', @level2type = N'COLUMN', @level2name = N'UpdatedAt';

-- sys_dict_type
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_type') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'字典类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'字典类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_dict_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'category_id' AND [object_id] = OBJECT_ID('sys_dict_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'category_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'category_id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'category_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'category_id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'name' AND [object_id] = OBJECT_ID('sys_dict_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'code' AND [object_id] = OBJECT_ID('sys_dict_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'status' AND [object_id] = OBJECT_ID('sys_dict_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'remark' AND [object_id] = OBJECT_ID('sys_dict_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'remark', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'remark';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'remark', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'remark';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_dict_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_dict_type') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_dict_type')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_dict_type', @level2type = N'COLUMN', @level2name = N'UpdatedAt';

-- sys_file
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'系统文件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'系统文件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Extension' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'扩展名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'Extension';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'扩展名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'Extension';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Size' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'Size';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'Size';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsFolder' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsFolder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'IsFolder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsFolder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'IsFolder';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FilePath' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'FilePath';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'FilePath';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ContentType' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ContentType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'ContentType';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ContentType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'ContentType';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'ParentId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'ParentId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'OwnerId' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'OwnerId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'OwnerId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'OwnerId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'OwnerId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'DeptId' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'部门ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'DeptId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'部门ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'DeptId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsPublic' AND [object_id] = OBJECT_ID('sys_file')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsPublic', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'IsPublic';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsPublic', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file', @level2type = N'COLUMN', @level2name = N'IsPublic';

-- sys_file_share
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file_share') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件分享', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件分享', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file_share') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_file_share')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file_share') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FileId' AND [object_id] = OBJECT_ID('sys_file_share')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'FileId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'文件ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'FileId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file_share') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SharedByUserId' AND [object_id] = OBJECT_ID('sys_file_share')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SharedByUserId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'SharedByUserId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'SharedByUserId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'SharedByUserId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file_share') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SharedToUserId' AND [object_id] = OBJECT_ID('sys_file_share')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SharedToUserId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'SharedToUserId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'SharedToUserId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'SharedToUserId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file_share') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Permission' AND [object_id] = OBJECT_ID('sys_file_share')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Permission', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'Permission';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Permission', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'Permission';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file_share') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_file_share')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file_share') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ExpirationTime' AND [object_id] = OBJECT_ID('sys_file_share')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ExpirationTime', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'ExpirationTime';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ExpirationTime', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'ExpirationTime';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_file_share') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Token' AND [object_id] = OBJECT_ID('sys_file_share')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'令牌', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'Token';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'令牌', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_file_share', @level2type = N'COLUMN', @level2name = N'Token';

-- sys_org_registration
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组织注册', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'组织注册', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'OrgName' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'OrgName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'OrgName';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'OrgName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'OrgName';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'OrgShortName' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'OrgShortName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'OrgShortName';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'OrgShortName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'OrgShortName';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'OrgAbbr' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'OrgAbbr', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'OrgAbbr';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'OrgAbbr', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'OrgAbbr';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'LicenseCode' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'LicenseCode', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'LicenseCode';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'LicenseCode', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'LicenseCode';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'LicenseFileUrl' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'LicenseFileUrl', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'LicenseFileUrl';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'LicenseFileUrl', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'LicenseFileUrl';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'AuthLetterFileUrl' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'AuthLetterFileUrl', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'AuthLetterFileUrl';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'AuthLetterFileUrl', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'AuthLetterFileUrl';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ContactName' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ContactName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'ContactName';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ContactName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'ContactName';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ContactPhone' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ContactPhone', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'ContactPhone';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ContactPhone', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'ContactPhone';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ContactEmail' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ContactEmail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'ContactEmail';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ContactEmail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'ContactEmail';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'AdminUsername' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'AdminUsername', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'AdminUsername';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'AdminUsername', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'AdminUsername';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'AdminPassword' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'AdminPassword', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'AdminPassword';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'AdminPassword', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'AdminPassword';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'Status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'Status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'RejectReason' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'RejectReason', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'RejectReason';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'RejectReason', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'RejectReason';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_org_registration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_org_registration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_org_registration', @level2type = N'COLUMN', @level2name = N'UpdatedAt';

-- sys_permission
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'权限', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'权限', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentId' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'ParentId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'父级ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'ParentId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Type' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Type';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Type';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Path' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Path';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Path';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Component' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Component';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'组件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Component';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Query' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Query', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Query';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Query', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Query';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Icon' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'图标', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Icon';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'图标', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'Icon';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'SortOrder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'SortOrder';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsVisible' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsVisible', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'IsVisible';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsVisible', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'IsVisible';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_permission', @level2type = N'COLUMN', @level2name = N'UpdatedAt';

-- sys_post
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_post') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'岗位', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'岗位', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID('sys_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'Code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'Code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('sys_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'SortOrder' AND [object_id] = OBJECT_ID('sys_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'SortOrder';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'排序', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'SortOrder';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsActive' AND [object_id] = OBJECT_ID('sys_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsActive', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'IsActive';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsActive', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'IsActive';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Remark' AND [object_id] = OBJECT_ID('sys_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'备注', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'Remark';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'备注', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'Remark';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'DeptId' AND [object_id] = OBJECT_ID('sys_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'部门ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'DeptId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'部门ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_post', @level2type = N'COLUMN', @level2name = N'DeptId';

-- sys_role
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'角色', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'角色', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Name' AND [object_id] = OBJECT_ID('sys_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'Name';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'名称', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'Name';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Code' AND [object_id] = OBJECT_ID('sys_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'Code';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'代码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'Code';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Description' AND [object_id] = OBJECT_ID('sys_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'Description';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'Description';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsSystem' AND [object_id] = OBJECT_ID('sys_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsSystem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'IsSystem';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsSystem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'IsSystem';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UpdatedAt' AND [object_id] = OBJECT_ID('sys_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'DeptId' AND [object_id] = OBJECT_ID('sys_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'部门ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'DeptId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'部门ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role', @level2type = N'COLUMN', @level2name = N'DeptId';

-- sys_role_inheritance
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role_inheritance') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'角色继承', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_inheritance';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'角色继承', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_inheritance';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role_inheritance') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ParentRoleId' AND [object_id] = OBJECT_ID('sys_role_inheritance')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ParentRoleId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_inheritance', @level2type = N'COLUMN', @level2name = N'ParentRoleId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ParentRoleId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_inheritance', @level2type = N'COLUMN', @level2name = N'ParentRoleId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role_inheritance') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ChildRoleId' AND [object_id] = OBJECT_ID('sys_role_inheritance')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ChildRoleId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_inheritance', @level2type = N'COLUMN', @level2name = N'ChildRoleId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'ChildRoleId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_inheritance', @level2type = N'COLUMN', @level2name = N'ChildRoleId';

-- sys_role_permission
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role_permission') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'角色权限', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_permission';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'角色权限', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_permission';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'RoleId' AND [object_id] = OBJECT_ID('sys_role_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'角色ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_permission', @level2type = N'COLUMN', @level2name = N'RoleId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'角色ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_permission', @level2type = N'COLUMN', @level2name = N'RoleId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'PermissionId' AND [object_id] = OBJECT_ID('sys_role_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'PermissionId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_permission', @level2type = N'COLUMN', @level2name = N'PermissionId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'PermissionId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_permission', @level2type = N'COLUMN', @level2name = N'PermissionId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_role_permission') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_role_permission')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_permission', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_role_permission', @level2type = N'COLUMN', @level2name = N'CreatedAt';

-- sys_user
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'用户', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'用户', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Username' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Username', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Username';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Username', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Username';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Password' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'密码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Password';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'密码', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Password';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Nickname' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Nickname', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Nickname';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'Nickname', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Nickname';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Email' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'邮箱', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Email';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'邮箱', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Email';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Phone' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'电话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Phone';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'电话', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Phone';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'IsActive' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'IsActive', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'IsActive';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'IsActive', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'IsActive';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'CreatedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'LastLoginAt' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'LastLoginAt', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'LastLoginAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'LastLoginAt', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'LastLoginAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Avatar' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'头像', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Avatar';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'头像', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Avatar';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'DeptId' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'部门ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'DeptId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'部门ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'DeptId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'Status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CurrentOrgId' AND [object_id] = OBJECT_ID('sys_user')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CurrentOrgId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'CurrentOrgId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'CurrentOrgId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'CurrentOrgId';

-- sys_user_post
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user_post') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'用户岗位', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_post';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'用户岗位', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_post';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UserId' AND [object_id] = OBJECT_ID('sys_user_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_post', @level2type = N'COLUMN', @level2name = N'UserId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_post', @level2type = N'COLUMN', @level2name = N'UserId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'PostId' AND [object_id] = OBJECT_ID('sys_user_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'岗位ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_post', @level2type = N'COLUMN', @level2name = N'PostId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'岗位ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_post', @level2type = N'COLUMN', @level2name = N'PostId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user_post') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'DeptId' AND [object_id] = OBJECT_ID('sys_user_post')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'部门ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_post', @level2type = N'COLUMN', @level2name = N'DeptId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'部门ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_post', @level2type = N'COLUMN', @level2name = N'DeptId';

-- sys_user_role
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user_role') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'用户角色', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_role';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'用户角色', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_role';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'UserId' AND [object_id] = OBJECT_ID('sys_user_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_role', @level2type = N'COLUMN', @level2name = N'UserId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_role', @level2type = N'COLUMN', @level2name = N'UserId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'RoleId' AND [object_id] = OBJECT_ID('sys_user_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'角色ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_role', @level2type = N'COLUMN', @level2name = N'RoleId';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'角色ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_role', @level2type = N'COLUMN', @level2name = N'RoleId';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_user_role') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'CreatedAt' AND [object_id] = OBJECT_ID('sys_user_role')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_role', @level2type = N'COLUMN', @level2name = N'CreatedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_role', @level2type = N'COLUMN', @level2name = N'CreatedAt';

-- sys_db_migration
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_db_migration') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'数据库迁移记录', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'数据库迁移记录', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_db_migration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Id' AND [object_id] = OBJECT_ID('sys_db_migration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration', @level2type = N'COLUMN', @level2name = N'Id';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration', @level2type = N'COLUMN', @level2name = N'Id';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_db_migration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'FileName' AND [object_id] = OBJECT_ID('sys_db_migration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'迁移文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration', @level2type = N'COLUMN', @level2name = N'FileName';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'迁移文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration', @level2type = N'COLUMN', @level2name = N'FileName';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_db_migration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ExecutedAt' AND [object_id] = OBJECT_ID('sys_db_migration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'执行时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration', @level2type = N'COLUMN', @level2name = N'ExecutedAt';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'执行时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration', @level2type = N'COLUMN', @level2name = N'ExecutedAt';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_db_migration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'Status' AND [object_id] = OBJECT_ID('sys_db_migration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration', @level2type = N'COLUMN', @level2name = N'Status';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'状态', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration', @level2type = N'COLUMN', @level2name = N'Status';
IF NOT EXISTS (SELECT NULL FROM sys.extended_properties WHERE [major_id] = OBJECT_ID('sys_db_migration') AND [name] = N'MS_Description' AND [minor_id] = (SELECT [column_id] FROM sys.columns WHERE [name] = 'ErrorMessage' AND [object_id] = OBJECT_ID('sys_db_migration')))
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'错误信息', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration', @level2type = N'COLUMN', @level2name = N'ErrorMessage';
ELSE
    EXEC sp_updateextendedproperty @name = N'MS_Description', @value = N'错误信息', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_db_migration', @level2type = N'COLUMN', @level2name = N'ErrorMessage';

