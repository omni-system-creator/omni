CREATE TABLE [sys_task_process] (
  [id] bigint IDENTITY(1,1) NOT NULL,
  [task_id] bigint NOT NULL,
  [operator_id] bigint NOT NULL,
  [action] nvarchar(50) NOT NULL DEFAULT 'process',
  [comment] nvarchar(max) NULL,
  [create_time] datetime2(6) NOT NULL DEFAULT SYSDATETIME(),
  [attachment_ids] nvarchar(500) NULL,
  CONSTRAINT [PK_sys_task_process] PRIMARY KEY ([id]),
  CONSTRAINT [FK_sys_task_process_sys_task_task_id] FOREIGN KEY ([task_id]) REFERENCES [sys_task] ([Id]) ON DELETE CASCADE,
  CONSTRAINT [FK_sys_task_process_sys_user_operator_id] FOREIGN KEY ([operator_id]) REFERENCES [sys_user] ([Id]) ON DELETE NO ACTION -- Avoid multiple cascade paths
);
GO

CREATE INDEX [IX_sys_task_process_task_id] ON [sys_task_process] ([task_id]);
GO
CREATE INDEX [IX_sys_task_process_operator_id] ON [sys_task_process] ([operator_id]);
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'任务处理记录', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_process';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'任务ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_process', @level2type = N'COLUMN', @level2name = N'task_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'操作人ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_process', @level2type = N'COLUMN', @level2name = N'operator_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'操作类型', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_process', @level2type = N'COLUMN', @level2name = N'action';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'处理意见', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_process', @level2type = N'COLUMN', @level2name = N'comment';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_process', @level2type = N'COLUMN', @level2name = N'create_time';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'附件ID列表', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_process', @level2type = N'COLUMN', @level2name = N'attachment_ids';
GO
