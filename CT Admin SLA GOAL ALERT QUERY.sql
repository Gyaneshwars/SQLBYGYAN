USE WorkflowArchive_Estimates
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2023-09-01 00:00:00.000'
SET @toDate = '2023-09-12 23:59:59.999'
IF OBJECT_ID('TEMPDB..#SLA') IS NOT NULL DROP TABLE #SLA
SELECT DISTINCT CT.collectionentityid AS VersionID,CT.relatedCompanyId AS CompanyId,CONVERT(VARCHAR(16),CT.insertedDate,120) AS ProcessInsertedDate,
FORMAT(CONVERT(datetime, CT.stageInsertedDate), 'yyyy-MM-dd hh:mm:ss tt') AS StageInsertedDate,CT.PriorityID,CT.collectionstageStatusId,CT.collectionstageId, 
DATEDIFF(HOUR,FORMAT(CONVERT(datetime, CT.stageInsertedDate), 'yyyy-MM-dd hh:mm:ss tt'),FORMAT(CONVERT(datetime, GETDATE()), 'yyyy-MM-dd hh:mm:ss tt')) AS SLA_CROSS_TIME_HR INTO #SLA 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CT
WHERE CT.collectionstageStatusId IN (1,3) AND CT.collectionProcessId=64 
AND CT.stageInsertedDate > = @frDate AND CT.stageInsertedDate <= @toDate


SELECT * FROM #SLA ORDER BY collectionstageId













