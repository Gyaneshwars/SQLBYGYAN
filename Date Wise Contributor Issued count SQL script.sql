--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frdate='2024-03-01 00:00:00.000'
SET @todate='2024-03-15 23:59:59.999'

IF OBJECT_ID('tempdb..#ContributorwiseDetails') IS NOT NULL DROP TABLE #ContributorwiseDetails
SELECT DISTINCT CONVERT(VARCHAR(10),ct.insertedDate,101) InsertDate,CONVERT(VARCHAR(10),ed.effectiveDate,101) effectiveDate,ed.versionid ,ed.companyid,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),
css.collectionStageStatusName,CT.collectionstageStatusId,CT.collectionProcessId,ed.effectiveDate AS FilingDate,vf.Description,v.formatID,CASE WHEN v.formatID IN (7,63,64,83,157,177,176) THEN 'EXCEL' ELSE 'PDF' END AS DocFormat 
INTO #ContributorwiseDetails FROM Estimates.[dbo].[EstimateDetail_tbl] ed (NOLOCK)
RIGHT JOIN WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=CT.collectionstageStatusId
LEFT JOIN DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId=ed.versionid
INNER JOIN DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID=v.formatID
WHERE ct.insertedDate>= @frDate AND ct.insertedDate<=@toDate
AND ed.versionId IS NOT NULL
AND ed.researchcontributorid IN (2494)
AND CT.collectionProcessId IN (64,1062,4861,4862,4863,4864,4899,4900,4901,4902,4903,4904,4905,4906,4907)
AND CT.collectionstageId IN (2,122)
--AND CT.collectionstageStatusId IN (4,5)

---SELECT * FROM #ContributorwiseDetails

IF OBJECT_ID('tempdb..#Semis1') IS NOT NULL DROP TABLE #Semis1
SELECT InsertDate,contributor,DocFormat,COUNT(versionid) AS CountOfDocsIssued
INTO #Semis1 FROM #ContributorwiseDetails
GROUP BY InsertDate,contributor,DocFormat
ORDER BY InsertDate,DocFormat

IF OBJECT_ID('tempdb..#Semis2') IS NOT NULL DROP TABLE #Semis2
SELECT 
    InsertDate,
    contributor,
    DocFormat,
    [4] AS Processed,
    [5] AS Skipped,
    [1] AS Queued,
	[2] AS InProcess,
	[3] AS Pending,
	[34] AS IssuedtoChecksReview
INTO #Semis2 FROM 
    (SELECT 
        InsertDate,
        contributor,
        DocFormat,
        collectionstageStatusId,
        versionid
    FROM 
        #ContributorwiseDetails) AS SourceTable
PIVOT
    (COUNT(versionid)
    FOR collectionstageStatusId IN ([4], [5], [1], [2], [34], [3])
    ) AS PivotTable
ORDER BY 
    InsertDate, 
    DocFormat


SELECT a.*,b.Processed,b.Skipped,b.Queued,b.Pending,b.InProcess,b.IssuedtoChecksReview
FROM #Semis1 a
INNER JOIN #Semis2 b ON a.InsertDate=b.InsertDate AND a.contributor=b.contributor AND a.DocFormat=b.DocFormat
ORDER BY a.InsertDate,a.DocFormat


SELECT * FROM #ContributorwiseDetails


















--SELECT InsertDate,contributor,Description,DocFormat,COUNT(versionid) CountofDocs
--FROM #ContributorwiseDetails
--GROUP BY InsertDate,contributor,Description,DocFormat
--ORDER BY InsertDate



