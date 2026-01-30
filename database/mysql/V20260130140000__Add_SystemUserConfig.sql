CREATE TABLE IF NOT EXISTS `sys_user_config` (
  `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `UserId` bigint NOT NULL COMMENT '用户ID',
  `OrgId` bigint NOT NULL COMMENT '组织ID',
  `Key` varchar(100) NOT NULL COMMENT '配置键',
  `Value` longtext COMMENT '配置值(JSON)',
  `Description` longtext COMMENT '描述',
  `CreatedAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间',
  `UpdatedAt` datetime(6) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `IX_sys_user_config_UserId_OrgId_Key` (`UserId`,`OrgId`,`Key`),
  KEY `IX_sys_user_config_OrgId` (`OrgId`),
  CONSTRAINT `FK_sys_user_config_sys_dept_OrgId` FOREIGN KEY (`OrgId`) REFERENCES `sys_dept` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `FK_sys_user_config_sys_user_UserId` FOREIGN KEY (`UserId`) REFERENCES `sys_user` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户个性化配置表';
