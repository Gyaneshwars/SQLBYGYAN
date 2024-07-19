--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frdate='2024-03-01 00:00:00.000'
SET @todate='2024-03-31 23:59:59.999'

IF OBJECT_ID('TEMPDB..#CTMSR') IS NOT NULL DROP TABLE #CTMSR 
SELECT DISTINCT CT.*,CONVERT(VARCHAR(10),insertedDate,101)Date2,cp.collectionProcessName,vf.Description,v.formatID,
CASE WHEN v.formatID IN (7,63,64,83,157,177,176) THEN 'EXCEL' ELSE 'PDF' END AS DocFormat,css.collectionStageStatusName,rd.researchcontributorid,contributor=dbo.researchcontributorname_fn(rd.researchcontributorid) INTO #CTMSR 
FROM WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct
LEFT JOIN  workflow_Estimates.[dbo].CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = ct.collectionEntityToProcessId AND cdp.datapointid  = 1887
LEFT JOIN  Estimates.[dbo].Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN  workflow_Estimates.[dbo].collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,ct.collectionProcessId) 
LEFT JOIN  ComparisonData.[dbo].[ResearchDocument_tbl] rd (NOLOCK) ON rd.versionId=ct.collectionEntityId
LEFT JOIN  DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId=ct.collectionEntityId
INNER JOIN DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID=v.formatID
INNER JOIN Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=ct.collectionstageStatusId
WHERE      ct.collectionStageId IN (2)  AND ct.collectionProcessId IN (64,1062) AND ct.collectionEntityTypeId = 9
AND        ct.insertedDate > = @frDate  AND ct.insertedDate <= @toDate
AND        rd.researchcontributorid IN (2494)


--SELECT DISTINCT * FROM #CTMSR

IF OBJECT_ID('tempdb..#Semis1') IS NOT NULL DROP TABLE #Semis1
SELECT DISTINCT Date2 AS InsertDate,contributor,DocFormat,COUNT(collectionEntityId) AS CountOfDocsIssued INTO #Semis1 FROM #CTMSR
GROUP BY Date2,contributor,DocFormat
ORDER BY Date2,DocFormat

IF OBJECT_ID('tempdb..#Semis2') IS NOT NULL DROP TABLE #Semis2
SELECT DISTINCT
    Date2,
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
        Date2,
        contributor,
        DocFormat,
        collectionstageStatusId,
        collectionEntityId
    FROM 
        #CTMSR) AS SourceTable
PIVOT
    (COUNT(collectionEntityId)
    FOR collectionstageStatusId IN ([4], [5], [1], [2], [34], [3])
    ) AS PivotTable
ORDER BY 
    Date2, 
    DocFormat


SELECT DISTINCT a.*,b.Processed,b.Skipped,b.Queued,b.Pending,b.InProcess,b.IssuedtoChecksReview
FROM #Semis1 a
INNER JOIN #Semis2 b ON a.InsertDate=b.Date2 AND a.contributor=b.contributor AND a.DocFormat=b.DocFormat
ORDER BY a.InsertDate,a.DocFormat