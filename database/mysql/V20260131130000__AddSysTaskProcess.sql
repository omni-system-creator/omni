CREATE TABLE `sys_task_process` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` bigint NOT NULL COMMENT '任务ID',
  `operator_id` bigint NOT NULL COMMENT '操作人ID',
  `action` varchar(50) NOT NULL DEFAULT 'process' COMMENT '操作类型',
  `comment` longtext COMMENT '处理意见',
  `create_time` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间',
  `attachment_ids` varchar(500) DEFAULT NULL COMMENT '附件ID列表',
  PRIMARY KEY (`id`),
  KEY `IX_sys_task_process_task_id` (`task_id`),
  KEY `IX_sys_task_process_operator_id` (`operator_id`),
  CONSTRAINT `FK_sys_task_process_sys_task_task_id` FOREIGN KEY (`task_id`) REFERENCES `sys_task` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_sys_task_process_sys_user_operator_id` FOREIGN KEY (`operator_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='任务处理记录';
