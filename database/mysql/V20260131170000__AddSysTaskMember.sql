CREATE TABLE `sys_task_member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `task_id` bigint NOT NULL COMMENT '任务ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `join_time` datetime(6) NOT NULL COMMENT '加入时间',
  PRIMARY KEY (`id`),
  KEY `IX_sys_task_member_task_id` (`task_id`),
  KEY `IX_sys_task_member_user_id` (`user_id`),
  CONSTRAINT `FK_sys_task_member_sys_task_task_id` FOREIGN KEY (`task_id`) REFERENCES `sys_task` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_sys_task_member_sys_user_user_id` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='任务成员表';
