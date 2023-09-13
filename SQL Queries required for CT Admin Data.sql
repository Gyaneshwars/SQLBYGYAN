USE Estimates

DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2023-08-22 00:00:00.000'
SET @todate='2023-08-30 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#CTAdminData') IS NOT NULL DROP TABLE #CTAdminData
SELECT DISTINCT ct.collectionEntityId,ct.relatedcompanyid,ct.enddate,ct.PriorityID,p.priorityName,ct.collectionStageStatusId,usr.employeeNumber,usr.firstName+' '+usr.lastName AS EmpName,
ct.userId,ct.collectionEntityToProcessId,ct.collectionEntityTypeId,cet.collectionEntityTypeName,ct.collectionstageId,ct.insertedDate,ct.startDate INTO #CTAdminData 
FROM            WorkflowArchive_Estimates.dbo.CommonTracker_vw ct (NOLOCK)
INNER JOIN      WorkflowArchive_Estimates.[dbo].[Priority_tbl] p (NOLOCK) ON p.priorityId = ct.PriorityID
INNER JOIN      CTAdminRepTables.dbo.user_tbl usr (NOLOCK) ON ct.userId = usr.userid
INNER JOIN      Workflow_Estimates.[dbo].[CollectionEntityType_tbl] cet (NOLOCK) ON cet.collectionEntityTypeId=ct.collectionEntityTypeId
WHERE           ct.collectionStageId IN (2,155) AND relatedcompanyid IS NOT NULL
AND             ct.collectionProcessId = 64 AND ct.collectionStageStatusId IN (4) AND ct.PriorityID IN (1,3,9,10,14,15,20,30,33,35)
AND             ct.enddate BETWEEN @frdate AND  @todate AND ct.userId NOT IN (907321171)

---SELECT * FROM #CTAdminData

SELECT collectionEntityToProcessId,collectionEntityId,collectionEntityTypeName,relatedCompanyId,collectionEntityTypeId,collectionstageId,collectionstageStatusId,insertedDate,
startDate,enddate,PriorityID FROM #CTAdminData

SELECT * FROM #CTAdminData
