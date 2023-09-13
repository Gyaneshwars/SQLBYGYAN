-----SQL Query Developer---Gnaneshwar Sravane
USE Estimates

DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2015-01-01 00:00:00.000'
SET @todate='2023-12-31 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#CTAdminData') IS NOT NULL DROP TABLE #CTAdminData
SELECT DISTINCT ct.collectionEntityId,ct.relatedcompanyid,ct.enddate,ct.PriorityID,ct.collectionStageStatusId,ct.collectionEntityToProcessId,ct.collectionEntityTypeId,
cet.collectionEntityTypeName,ct.collectionstageId,ct.insertedDate,ct.startDate,ct.stageInsertedDate,cpc.collectionProcessId INTO #CTAdminData 
FROM            WorkflowArchive_Estimates.dbo.CommonTracker_vw ct (NOLOCK)
INNER JOIN      Workflow_Estimates.[dbo].[CollectionProcessToCollectionStage_tbl] cpc (NOLOCK) ON cpc.collectionstageId =ct.collectionstageId
INNER JOIN      Workflow_Estimates.[dbo].[CollectionEntityType_tbl] cet (NOLOCK) ON cet.collectionEntityTypeId=ct.collectionEntityTypeId
INNER JOIN      [Workflow_Estimates].[dbo].[CollectionProcess_tbl] cp (NOLOCK) ON cp.collectionProcessId =cpc.collectionProcessId
LEFT JOIN       Estimates.dbo.EstimateDetail_tbl ed (NOLOCK) ON ct.relatedCompanyId=ed.companyId
WHERE           ed.effectiveDate>= @frDate AND ed.effectiveDate <=@toDate AND cp.collectionProcessGroupId IN (13) AND cpc.collectionProcessId IN (374,364) AND ct.collectionEntityTypeId IN (2,9,41,51,50) AND ct.collectionstageStatusId IN (1,2,3)


---SELECT * FROM #CTAdminData


---Feed Process (End-to-End)
SELECT DISTINCT collectionEntityToProcessId,collectionEntityId,collectionEntityTypeName AS EntityType,relatedCompanyId AS CompanyId,collectionEntityTypeId,collectionstageId,collectionstageStatusId,
insertedDate AS ProcessInsertedDate,stageInsertedDate,startDate,enddate,PriorityID 
FROM #CTAdminData 
WHERE collectionProcessId IN (374) AND collectionEntityTypeId IN (2,9,51,50) AND collectionstageStatusId IN (1,2,3) --AND collectionstageId IN (77)
ORDER BY collectionEntityToProcessId


---Split Process in Estimates
SELECT DISTINCT collectionEntityToProcessId,collectionEntityId,collectionEntityTypeName AS EntityType,relatedCompanyId AS CompanyId,collectionEntityTypeId,collectionstageId,collectionstageStatusId,
insertedDate AS ProcessInsertedDate,stageInsertedDate,startDate,enddate,PriorityID 
FROM #CTAdminData 
WHERE collectionProcessId IN (364) AND collectionEntityTypeId IN (41) AND collectionstageStatusId IN (1,2) ---AND collectionstageId IN (66)
