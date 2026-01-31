CREATE TABLE `sys_task_attachment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` bigint NOT NULL COMMENT '任务ID',
  `file_name` varchar(255) NOT NULL COMMENT '文件名',
  `file_path` varchar(500) NOT NULL COMMENT '文件路径',
  `extension` varchar(20) DEFAULT NULL COMMENT '扩展名',
  `file_size` bigint NOT NULL COMMENT '文件大小',
  `content_type` varchar(100) DEFAULT NULL COMMENT '文件类型',
  `uploader_id` bigint NOT NULL COMMENT '上传者ID',
  `create_time` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `IX_sys_task_attachment_task_id` (`task_id`),
  KEY `IX_sys_task_attachment_uploader_id` (`uploader_id`),
  CONSTRAINT `FK_sys_task_attachment_sys_task_task_id` FOREIGN KEY (`task_id`) REFERENCES `sys_task` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_sys_task_attachment_sys_user_uploader_id` FOREIGN KEY (`uploader_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='任务附件';
