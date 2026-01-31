ALTER TABLE `sys_user` ADD COLUMN `SuperiorId` bigint NULL COMMENT '上级用户ID';
ALTER TABLE `sys_user` ADD CONSTRAINT `FK_sys_user_sys_user_SuperiorId` FOREIGN KEY (`SuperiorId`) REFERENCES `sys_user` (`Id`);
