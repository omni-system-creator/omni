-- Add SortOrder to SystemConfig
ALTER TABLE "sys_config" ADD COLUMN "SortOrder" INT NOT NULL DEFAULT 0;

COMMENT ON COLUMN "sys_config"."SortOrder" IS '排序号';
