ALTER TABLE "sys_user" ADD COLUMN "SuperiorId" bigint NULL;
COMMENT ON COLUMN "sys_user"."SuperiorId" IS '上级用户ID';
ALTER TABLE "sys_user" ADD CONSTRAINT "FK_sys_user_sys_user_SuperiorId" FOREIGN KEY ("SuperiorId") REFERENCES "sys_user" ("Id");
