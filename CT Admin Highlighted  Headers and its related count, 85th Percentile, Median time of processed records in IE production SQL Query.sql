----PYTHON,POWER BI & SQL ETL DEVELOPER - GNANESHWAR SRAVANE
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-07-20 00:00:00.000' 
SET @toDate = '2023-12-31 23:59:59.999' 

IF OBJECT_ID('tempdb..#Inclxclsn') IS NOT NULL DROP TABLE #Inclxclsn
SELECT DISTINCT CT.collectionEntityId AS EntityId,cet.collectionEntityTypeName,CT.relatedCompanyId AS companyId,CT.collectionstageStatusId,CSST.collectionStageStatusName,cpt.collectionProcessName,CT.collectionProcessId,
CT.collectionstageId,cstt.collectionStageName,CT.stageInsertedDate,CT.startDate,CT.endDate,DATEDIFF(MINUTE,CT.stageInsertedDate,CT.endDate) AS DurationInMins,CONVERT(VARCHAR,CT.endDate,23) AS ProcessedDate,YEAR(CT.endDate) AS YearProcessed
INTO #Inclxclsn FROM WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT (NOLOCK)
INNER JOIN workflow_estimates.[dbo].[CollectionStage_tbl] cstt (NOLOCK) ON cstt.collectionstageId=CT.collectionstageId
INNER JOIN workflow_estimates.[dbo].[CollectionStageStatus_tbl] csst (NOLOCK) ON csst.collectionStageStatusId=CT.collectionstageStatusId
INNER JOIN workflow_estimates.[dbo].[CollectionProcess_tbl] cpt (NOLOCK) ON cpt.collectionProcessId=CT.collectionProcessId
INNER JOIN Workflow_Estimates.[dbo].[CollectionEntityType_tbl] cet (NOLOCK) ON cet.collectionEntityTypeId=CT.collectionEntityTypeId
WHERE CT.endDate>=@frDate AND CT.endDate<=@toDate
AND CT.collectionEntityId IS NOT NULL 
AND CT.collectionstageStatusId IN (4) --,5
AND CT.collectionstageId IN (49)
AND CT.collectionProcessId IN (64)
AND CT.collectionEntityTypeId IN (27)

---SELECT * FROM #Inclxclsn

IF OBJECT_ID('tempdb..#QFinal') IS NOT NULL DROP TABLE #QFinal
SELECT DISTINCT EntityId,ProcessedDate,collectionEntityTypeName,CollectionProcessName,CollectionStageName,CASE WHEN collectionstageStatusId=4 THEN COUNT(collectionstageStatusId) ELSE 0 END AS Processedd, 
CASE WHEN collectionstageStatusId=5 THEN COUNT(collectionstageStatusId) ELSE 0 END AS Skippedd,CASE WHEN collectionstageStatusId IN (4,5) THEN COUNT(collectionstageStatusId) ELSE 0 END AS Totall,DurationInMins
INTO #QFinal FROM #Inclxclsn
GROUP BY EntityId,ProcessedDate,collectionEntityTypeName,collectionProcessName,collectionStageName,collectionstageStatusId,DurationInMins

IF OBJECT_ID('tempdb..#SFinal') IS NOT NULL DROP TABLE #SFinal
SELECT ProcessedDate,collectionEntityTypeName,CollectionProcessName,CollectionStageName,SUM(Totall) AS Total,SUM(Processedd) AS Processed,SUM(Skippedd) AS Skipped INTO #SFinal FROM #QFinal
GROUP BY ProcessedDate,collectionEntityTypeName,collectionProcessName,collectionStageName
ORDER BY ProcessedDate

IF OBJECT_ID('tempdb..#Final') IS NOT NULL DROP TABLE #Final
SELECT DISTINCT 
    ProcessedDate,
    PERCENTILE_CONT(0.85) WITHIN GROUP (ORDER BY DurationInMins) OVER (PARTITION BY ProcessedDate) AS EightyFifthPercentile,PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY DurationInMins) OVER (PARTITION BY ProcessedDate) AS MedianTime
INTO #Final FROM 
    #Inclxclsn ORDER BY ProcessedDate

IF OBJECT_ID('tempdb..#LFinal') IS NOT NULL DROP TABLE #LFinal
SELECT DISTINCT a.*,b.EightyFifthPercentile,b.MedianTime,YEAR(a.ProcessedDate) AS YearEnd INTO #LFinal FROM #SFinal a INNER JOIN #Final b ON a.ProcessedDate=b.ProcessedDate
ORDER BY a.ProcessedDate

IF OBJECT_ID('tempdb..#L1Final') IS NOT NULL DROP TABLE #L1Final
SELECT DISTINCT 
    YearProcessed,
    PERCENTILE_CONT(0.85) WITHIN GROUP (ORDER BY DurationInMins) OVER (PARTITION BY YearProcessed) AS EightyFifthPercentile,PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY DurationInMins) OVER (PARTITION BY YearProcessed) AS MedianTime
INTO #L1Final FROM 
    #Inclxclsn ORDER BY YearProcessed


SELECT a.YearEnd,a.collectionEntityTypeName,a.collectionProcessName,a.collectionStageName,SUM(a.Total) AS TotalProcessed,SUM(a.Processed) AS processedfiles,b.EightyFifthPercentile,b.MedianTime FROM #LFinal a
INNER JOIN #L1Final b ON b.YearProcessed=a.YearEnd
GROUP BY YearEnd,collectionEntityTypeName,collectionProcessName,collectionStageName,b.EightyFifthPercentile,b.MedianTime

SELECT * FROM #LFinal

SELECT DISTINCT * FROM #Inclxclsn ORDER BY ProcessedDate
