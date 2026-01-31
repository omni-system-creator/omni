CREATE TABLE [sys_task] (
  [Id] bigint IDENTITY(1,1) NOT NULL,
  [title] nvarchar(200) NOT NULL,
  [type] nvarchar(50) NOT NULL DEFAULT 'task',
  [priority] nvarchar(20) NOT NULL DEFAULT 'medium',
  [description] nvarchar(max) NULL,
  [creator_id] bigint NOT NULL,
  [assignee_id] bigint NOT NULL,
  [create_time] datetime2(6) NOT NULL DEFAULT SYSDATETIME(),
  [deadline] datetime2(6) NULL,
  [finish_time] datetime2(6) NULL,
  [status] nvarchar(50) NOT NULL DEFAULT 'pending',
  [org_id] bigint NOT NULL DEFAULT 0,
  CONSTRAINT [PK_sys_task] PRIMARY KEY ([Id]),
  CONSTRAINT [FK_sys_task_sys_user_creator_id] FOREIGN KEY ([creator_id]) REFERENCES [sys_user] ([Id]) ON DELETE CASCADE,
  CONSTRAINT [FK_sys_task_sys_user_assignee_id] FOREIGN KEY ([assignee_id]) REFERENCES [sys_user] ([Id]) ON DELETE NO ACTION -- Avoid multiple cascade paths
);
GO

CREATE INDEX [IX_sys_task_creator_id] ON [sys_task] ([creator_id]);
GO
CREATE INDEX [IX_sys_task_assignee_id] ON [sys_task] ([assignee_id]);
GO
CREATE INDEX [IX_sys_task_org_id] ON [sys_task] ([org_id]);
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'个人待办任务表', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'任务标题', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'title';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'类型：task, approval, notice', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'type';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'优先级：high, medium, low', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'priority';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'任务描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'description';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建人ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'creator_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'执行人ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'assignee_id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'create_time';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'截止时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'deadline';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'完成时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'finish_time';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'状态：pending, completed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'status';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'org_id';
GO
