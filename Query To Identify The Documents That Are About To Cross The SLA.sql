
USE Estimates

DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2023-07-01 00:00:00.000'
SET @todate='2023-09-12 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#SLA') IS NOT NULL DROP TABLE #SLA
SELECT DISTINCT ct.collectionEntityId AS VersionId,ct.relatedcompanyid AS CompanyId,FORMAT(CONVERT(datetime, ct.insertedDate), 'yyyy-MM-dd hh:mm:ss tt') AS ProcessInsertedDate,
FORMAT(CONVERT(datetime, ct.stageInsertedDate), 'yyyy-MM-dd hh:mm:ss tt') AS StageInsertedDate,FORMAT(CONVERT(datetime, ed.effectiveDate), 'yyyy-MM-dd hh:mm:ss tt') AS FilingDate,
DATEDIFF(HOUR,FORMAT(CONVERT(datetime, ed.effectiveDate), 'yyyy-MM-dd hh:mm:ss tt'),FORMAT(CONVERT(datetime, GETDATE()), 'yyyy-MM-dd hh:mm:ss tt')) AS SLA_CROSS_TIME_HR,
cp.collectionProcessName AS CollectionProcess,CTI.IndustryName AS Industry,vf.Description AS VersionFormat,---l.languageName AS Language,
cs.collectionStageName AS CollectionStage,css.collectionStageStatusName AS CollectionStageStatus,p.priorityName AS Priority,ist.issueSourceName AS IssueSource,
ct.collectionstageId INTO #SLA ----CTI.IndustryName AS Industry,vf.Description AS VersionFormat,Contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),FORMAT(CONVERT(datetime, ed.effectiveDate), 'yyyy-MM-dd hh:mm:ss tt') AS FilingDate,rd.lastUpdatedDateUTC,l.languageName AS Language,
FROM            WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct (NOLOCK)
LEFT JOIN      Estimates.[dbo].estimatedetail_tbl ed (NOLOCK) ON ct.collectionEntityId = ed.versionid AND ct.relatedcompanyid = ed.companyid
LEFT JOIN      CompanyMaster.[dbo].CompanyInfoMaster cm (NOLOCK) ON cm.CIQCompanyId=ed.companyid
LEFT JOIN      WorkflowArchive_Estimates.[dbo].[Priority_tbl] p (NOLOCK) ON p.priorityId = ct.PriorityID
--INNER JOIN      Workflow_Estimates.[dbo].[CollectionEntityType_tbl] cet (NOLOCK) ON cet.collectionEntityTypeId=ct.collectionEntityTypeId
LEFT JOIN		Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cm.IndustryID = CTI.IndustryId
LEFT JOIN      DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId=ed.versionid
LEFT JOIN      DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID=v.formatID
LEFT JOIN      Workflow_Estimates.[dbo].[IssueSource_tbl] ist (NOLOCK) ON ist.issueSourceId=ct.issueSourceId 
LEFT JOIN      Workflow_Estimates.[dbo].[CollectionProcess_tbl] cp (NOLOCK) ON cp.collectionProcessId=ct.collectionProcessId 
LEFT JOIN      Workflow_Estimates.[dbo].[CollectionStage_tbl] cs (NOLOCK) ON cs.collectionStageId=ct.collectionstageId
LEFT JOIN      Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=ct.collectionstageStatusId
--LEFT JOIN      ComparisonData.[dbo].ResearchDocument_tbl Rd (NOLOCK) ON  Rd.versionId= ct.collectionEntityId
--LEFT JOIN      Comparisondata.[dbo].Language_tbl l (NOLOCK) ON l.languageId=rd.languageId
WHERE           ed.effectiveDate>=@frdate AND ed.effectiveDate<=@todate
---AND             ct.collectionProcessId = 64
AND             ct.collectionstageId IN (2,122)
AND             ct.collectionstageStatusId IN (1,3)
AND             ct.collectionEntityId IS NOT NULL



--SELECT DISTINCT * FROM #SLA WHERE SLA_CROSS_TIME_HR<=24 AND collectionstageId=1 ORDER BY SLA_CROSS_TIME_HR

--SELECT DISTINCT * FROM #SLA WHERE SLA_CROSS_TIME_HR<=24 AND collectionstageId=2 ORDER BY SLA_CROSS_TIME_HR

SELECT DISTINCT * FROM #SLA WHERE SLA_CROSS_TIME_HR>15 AND collectionstageId=2 ORDER BY SLA_CROSS_TIME_HR,CollectionProcess


--SELECT DISTINCT * FROM #SLA ORDER BY CollectionStage

--SELECT GETDATE()

--SELECT FORMAT(CONVERT(datetime, GETDATE()), 'yyyy-MM-dd hh:mm:ss tt') AS FormattedDate

