-- Remove duplicate system configs, keeping the one with the highest ID (latest)
DELETE t1 
FROM sys_config t1 
JOIN sys_config t2 
ON t1.[Key] = t2.[Key] 
AND t1.OrgId = t2.OrgId 
AND t1.Id < t2.Id 
WHERE t1.OrgId IS NOT NULL;
GO
