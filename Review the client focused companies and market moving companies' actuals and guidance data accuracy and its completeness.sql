
IF OBJECT_ID ('TEMPDB..#AGVERSIONS') IS NOT NULL DROP TABLE #AGVERSIONS
SELECT DISTINCT ct.collectionEntityId,relatedcompanyid,ct.enddate as CollectionDate,ct.PriorityID,p.priorityName,ct.collectionStageStatusId,usr.employeeNumber, ct.userId INTO #AGVERSIONS 
FROM            WorkflowArchive_Estimates.dbo.CommonTracker_vw ct
INNER JOIN      WorkflowArchive_Estimates.[dbo].[Priority_tbl] p ON p.priorityId = ct.PriorityID
INNER JOIN      CTAdminRepTables.dbo.user_tbl usr (NOLOCK)ON ct.userId = usr.userid
WHERE           ct.collectionStageId IN (2,155) AND relatedcompanyid IS NOT NULL
AND             ct.collectionProcessId = 64 AND ct.collectionStageStatusId IN (4) AND ct.PriorityID IN (1,3,9,10,14,15,20,30,33,35)
AND             ct.enddate BETWEEN GETDATE() -7 AND  GETDATE() +1 AND ct.userId NOT IN (907321171)
AND             ct.relatedCompanyId in (592007691,45511302,878688)  ----Provide the client focused companies and market moving companies id's here


SELECT TOP 1 percent * FROM #AGVERSIONS ORDER BY NEWID()
