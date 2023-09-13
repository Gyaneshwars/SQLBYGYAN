USE Estimates

DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2023-08-29 00:00:00.000'
SET @todate='2023-08-30 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#CTAdminData') IS NOT NULL DROP TABLE #CTAdminData
SELECT DISTINCT ct.collectionEntityId,ct.relatedcompanyid,cm.CompanyName,ct.enddate,ct.PriorityID,p.priorityName,ct.collectionStageStatusId,usr.employeeNumber,usr.firstName+' '+usr.lastName AS UserName,
ct.userId,ed.effectiveDate,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),ct.stageInsertedDate,ct.issueSourceId,ct.collectionEntityToProcessId,ct.collectionEntityTypeId,
cet.collectionEntityTypeName,CTI.IndustryName,DATEDIFF(MINUTE,CT.startDate,CT.endDate) AS Duration_in_Min,cm.internationalFlag,ct.collectionEntityToCollectionStageId,
ct.sortOrder,cm.Country,css.collectionStageStatusName,cs.collectionStageName,cp.collectionProcessName,vf.Description,v.formatID,ist.issueSourceName,l.languageName,
ct.relatedPersonId,ct.collectionstageId,ct.insertedDate,ct.startDate,COUNT(DISTINCT(dbo.formatperiodid_fn(ed.estimateperiodid))) AS No_of_PEO,
COUNT(dbo.dataitemname_fn(ednd.dataitemid)) AS No_of_datapoints INTO #CTAdminData 
FROM            WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct (NOLOCK)
INNER JOIN      Estimates.[dbo].estimatedetail_tbl ed (NOLOCK) ON ct.collectionEntityId = ed.versionid AND ct.relatedcompanyid = ed.companyid
INNER JOIN      Estimates.[dbo].[EstFull_vw] ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
INNER JOIN      CompanyMaster.[dbo].CompanyInfoMaster cm (NOLOCK) ON cm.CIQCompanyId=ed.companyid
INNER JOIN      Estimates.[dbo].EstimatePeriod_tbl ep (NOLOCK) ON ep.estimatePeriodId=ed.estimatePeriodId
INNER JOIN      WorkflowArchive_Estimates.[dbo].[Priority_tbl] p (NOLOCK) ON p.priorityId = ct.PriorityID
INNER JOIN      CTAdminRepTables.[dbo].user_tbl usr (NOLOCK) ON ct.userId = usr.userid
INNER JOIN      Workflow_Estimates.[dbo].[CollectionEntityType_tbl] cet (NOLOCK) ON cet.collectionEntityTypeId=ct.collectionEntityTypeId
INNER JOIN		Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cm.IndustryID = CTI.IndustryId
INNER JOIN      DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId=ed.versionid
INNER JOIN      DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID=v.formatID
INNER JOIN      Workflow_Estimates.[dbo].[IssueSource_tbl] ist (NOLOCK) ON ist.issueSourceId=ct.issueSourceId 
INNER JOIN      Workflow_Estimates.[dbo].[CollectionProcess_tbl] cp (NOLOCK) ON cp.collectionProcessId=ct.collectionProcessId 
INNER JOIN      Workflow_Estimates.[dbo].[CollectionStage_tbl] cs (NOLOCK) ON cs.collectionStageId=ct.collectionstageId
INNER JOIN      Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=ct.collectionstageStatusId
INNER JOIN      Workflow_Estimates.[dbo].[CollectionStageComment_tbl] csc (NOLOCK) ON csc.collectionEntityToCollectionStageID=ct.collectionEntityToCollectionStageId
INNER JOIN      ComparisonData.[dbo].ResearchDocument_tbl Rd (NOLOCK) ON  Rd.versionId= ct.collectionEntityId
INNER JOIN      Comparisondata.[dbo].Language_tbl l (NOLOCK) ON l.languageId=rd.languageId
WHERE           ct.collectionEntityId IS NOT NULL
AND             ct.collectionProcessId = 64 AND ct.collectionStageStatusId IN (4,5)
AND             ct.endDate>=@frdate AND ct.endDate<=@todate AND ct.userId NOT IN (907321171)
AND             usr.employeeNumber IN (216017,718029,411017)   ----Please provide empId here
AND             vf.Description LIKE '%Excel%'
GROUP BY        ct.collectionEntityId,ct.relatedcompanyid,cm.CompanyName,ct.enddate,ct.PriorityID,p.priorityName,ct.collectionStageStatusId,usr.employeeNumber,usr.firstName+' '+usr.lastName,
ct.userId,ed.effectiveDate,ed.researchcontributorid,ct.stageInsertedDate,ct.issueSourceId,ct.collectionEntityToProcessId,ct.collectionEntityTypeId,
cet.collectionEntityTypeName,CTI.IndustryName,cm.internationalFlag,ct.collectionEntityToCollectionStageId,
ct.sortOrder,cm.Country,css.collectionStageStatusName,cs.collectionStageName,cp.collectionProcessName,
vf.Description,v.formatID,ist.issueSourceName,l.languageName,ct.relatedPersonId,ct.collectionstageId,ct.insertedDate,ct.startDate

---SELECT * FROM #CTAdminData

---,STRING_AGG(csc.comment,', ') WITHIN GROUP (ORDER BY csc.comment) AS usercomment

SELECT DISTINCT collectionEntityId AS EntityId,collectionEntityTypeName AS EntityType,insertedDate AS ProcessInsertedDate,stageInsertedDate,effectiveDate AS FilingDate,
contributor AS DocumentSource,languageName AS Language,Description AS VersionFormat,No_of_PEO,No_of_datapoints,relatedPersonId AS PersonId,relatedcompanyid AS CompanyId,
CompanyName,internationalFlag,IndustryName AS Industry,Country,collectionProcessName AS CollectionProcess,collectionStageName AS CollectionStage,collectionStageStatusName AS CollectionStageStatus,
priorityName AS Priority,sortOrder AS SortOrder,issueSourceName AS IssueSource,employeeNumber AS EmployeeNumber,UserName,startDate,endDate,Duration_in_Min,
collectionEntityToProcessId,collectionEntityTypeId,collectionEntityToCollectionStageId,collectionStageStatusId
FROM #CTAdminData