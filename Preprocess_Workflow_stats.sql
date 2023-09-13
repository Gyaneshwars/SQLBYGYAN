DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2022-01-01 00:00:00.000'
SET @toDate = '2022-12-31 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#PPflowstats') IS NOT NULL DROP TABLE #PPflowstats
SELECT DISTINCT ct.collectionEntityId AS VersionId,RD.lastUpdatedDateUTC as Filingdate,ct.insertedDate,ct.startDate,ct.enddate,ct.PriorityID,p.priorityName,
css.collectionStageStatusName,ct.collectionStageStatusId,ct.collectionStageId,ctu.employeeNumber AS EmpId INTO #PPflowstats 
FROM            WorkflowArchive_Estimates.dbo.CommonTracker_vw ct
INNER JOIN      WorkflowArchive_Estimates.[dbo].[Priority_tbl] p (NOLOCK) ON p.priorityId = ct.PriorityID
INNER JOIN      CTAdminRepTables.dbo.user_tbl ctu (NOLOCK) ON ct.userId = ctu.userId
INNER JOIN      ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK) ON RD.versionId = ct.collectionEntityId
INNER JOIN      Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON ct.collectionStageStatusId = css.collectionStageStatusId
WHERE           ct.collectionProcessId IN (64)
AND             ct.collectionStageId IN (1,160,210) ------------------------------------------------------------AND ct.collectionStageStatusId IN (1,2,3,4,5)
AND             RD.lastUpdatedDateUTC >= @frDate AND RD.lastUpdatedDateUTC <= @toDate ---------------------------------------AND ct.userId NOT IN (907321171)

---To Get The Total records
SELECT DISTINCT *,DATEDIFF(HOUR,Filingdate,insertedDate) AS FD_to_insert_time_hrs,DATEDIFF(HOUR,insertedDate,enddate) AS insert_to_end_time_hrs FROM #PPflowstats --where collectionStageStatusId = 4

---To Get The stats count
SELECT collectionStageStatusName,collectionStageStatusId,collectionStageId,COUNT(VersionId) AS version_count FROM #PPflowstats
GROUP BY collectionStageStatusName,collectionStageStatusId,collectionStageId
