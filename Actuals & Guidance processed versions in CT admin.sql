--Review the client focused companies and market moving companies' actuals and guidance data accuracy and its completeness
IF OBJECT_ID ('TEMPDB..#CTAversion') IS NOT NULL DROP TABLE #CTAversion
SELECT DISTINCT ct.collectionEntityId as VersionId,relatedcompanyid as CompanyId,ct.enddate as CollectionDate,ct.PriorityID,p.priorityName,ct.collectionStageStatusId,ctu.employeeNumber as EmpId INTO #CTAversion 
FROM            WorkflowArchive_Estimates.dbo.CommonTracker_vw ct
INNER JOIN      WorkflowArchive_Estimates.[dbo].[Priority_tbl] p ON p.priorityId = ct.PriorityID
INNER JOIN      CTAdminRepTables.dbo.user_tbl ctu on ct.userId = ctu.userId
WHERE           ct.collectionStageId IN (2,155) AND relatedcompanyid IS NOT NULL
AND             ct.collectionProcessId = 64 AND ct.collectionStageStatusId in (4) AND ct.PriorityID IN (1,3,9,10,14,15,20,30,33,35)
AND             ct.enddate BETWEEN getdate() -7 AND  getdate() +1 AND ct.userId NOT IN (907321171)
--AND             ct.relatedCompanyId in ()  ----Provide the client focused companies and market moving companies id's here


SELECT top 20 * FROM #CTAversion order by newid()-----newid()

--select * from WorkflowArchive_Estimates.[dbo].[Priority_tbl] where priorityName like 'Oil & Gas Estimates'

--SELECT * from #AGVERSIONS 
--OD collectionProcessId = 1062
--SELECT * from CTAdminRepTables.dbo.user_tbl

--SELECT * from WorkflowArchive_Estimates.dbo.CommonTracker_vw
--SELECT * from WorkflowArchive_Estimates.[dbo].[CollectionEntityToProcess_tbl]
--SELECT * from WorkflowArchive_Estimates.[dbo].[CollectionEntityToCollectionEntity_tbl]
--SELECT * from WorkflowArchive_Estimates.[dbo].[CollectionEntityToCollectionStage_tbl]
--SELECT * from WorkflowArchive_Estimates.[dbo].[CollectionEntityType_tbl]
--SELECT * from WorkflowArchive_Estimates.[dbo].[CollectionProcessToCollectionEntityType_tbl]
--SELECT * from WorkflowArchive_Estimates.[dbo].[CollectionCommentTypeCategory_tbl]
--SELECT * from WorkflowArchive_Estimates.[dbo].[CompanyInfoMaster] where ticker in ('GOOgl')
--SELECT * from WorkflowArchive_Estimates.[dbo].[Industries]
--SELECT * from WorkflowArchive_Estimates.[dbo].[CollectionStage_tbl]