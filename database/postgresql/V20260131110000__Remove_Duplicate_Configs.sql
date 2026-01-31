-- Remove duplicate system configs, keeping the one with the highest ID (latest)
DELETE FROM sys_config t1
USING sys_config t2
WHERE t1."Key" = t2."Key"
AND t1."OrgId" = t2."OrgId"
AND t1."Id" < t2."Id"
AND t1."OrgId" IS NOT NULL;
