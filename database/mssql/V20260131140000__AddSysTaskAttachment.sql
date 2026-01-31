CREATE TABLE [sys_task_attachment] (
  [id] bigint IDENTITY(1,1) NOT NULL,
  [task_id] bigint NOT NULL,
  [file_name] nvarchar(255) NOT NULL,
  [file_path] nvarchar(500) NOT NULL,
  [extension] nvarchar(20) NULL,
  [file_size] bigint NOT NULL,
  [content_type] nvarchar(100) NULL,
  [uploader_id] bigint NOT NULL,
  [create_time] datetime2(6) NOT NULL DEFAULT SYSDATETIME(),
  CONSTRAINT [PK_sys_task_attachment] PRIMARY KEY ([id]),
  CONSTRAINT [FK_sys_task_attachment_sys_task_task_id] FOREIGN KEY ([task_id]) REFERENCES [sys_task] ([Id]) ON DELETE CASCADE,
  CONSTRAINT [FK_sys_task_attachment_sys_user_uploader_id] FOREIGN KEY ([uploader_id]) REFERENCES [sys_user] ([Id]) ON DELETE NO ACTION -- Avoid multiple cascade paths
);
GO

CREATE INDEX [IX_sys_task_attachment_task_id] ON [sys_task_attachment] ([task_id]);
GO
CREATE INDEX [IX_sys_task_attachment_uploader_id] ON [sys_task_attachment] ([uploader_id]);
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'任务附件', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_attachment';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'任务ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_attachment', @level2type = N'COLUMN', @level2name = N'task_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_attachment', @level2type = N'COLUMN', @level2name = N'file_name';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件路径', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_attachment', @level2type = N'COLUMN', @level2name = N'file_path';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'扩展名', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_attachment', @level2type = N'COLUMN', @level2name = N'extension';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件大小', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_attachment', @level2type = N'COLUMN', @level2name = N'file_size';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'文件类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_attachment', @level2type = N'COLUMN', @level2name = N'content_type';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'上传者ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_attachment', @level2type = N'COLUMN', @level2name = N'uploader_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_attachment', @level2type = N'COLUMN', @level2name = N'create_time';
GO
