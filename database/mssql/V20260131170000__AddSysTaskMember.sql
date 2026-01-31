CREATE TABLE [sys_task_member] (
  [id] bigint IDENTITY(1,1) NOT NULL,
  [task_id] bigint NOT NULL,
  [user_id] bigint NOT NULL,
  [join_time] datetime2(6) NOT NULL,
  CONSTRAINT [PK_sys_task_member] PRIMARY KEY ([id]),
  CONSTRAINT [FK_sys_task_member_sys_task_task_id] FOREIGN KEY ([task_id]) REFERENCES [sys_task] ([Id]) ON DELETE CASCADE,
  CONSTRAINT [FK_sys_task_member_sys_user_user_id] FOREIGN KEY ([user_id]) REFERENCES [sys_user] ([Id]) ON DELETE NO ACTION -- Avoid multiple cascade paths
);
GO

CREATE INDEX [IX_sys_task_member_task_id] ON [sys_task_member] ([task_id]);
GO
CREATE INDEX [IX_sys_task_member_user_id] ON [sys_task_member] ([user_id]);
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'任务成员表', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_member';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_member', @level2type = N'COLUMN', @level2name = N'id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'任务ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_member', @level2type = N'COLUMN', @level2name = N'task_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_member', @level2type = N'COLUMN', @level2name = N'user_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'加入时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task_member', @level2type = N'COLUMN', @level2name = N'join_time';
GO
