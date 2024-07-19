
---Python & SQL ETL Developer-GNANESHWAR SRAVANE
USE Estimates

DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-09-01 00:00:00.000'
SET @toDate = '2023-11-30 23:59:59.999'

IF OBJECT_ID('tempdb..#OGCommoditydata_Temp') IS NOT NULL DROP TABLE #OGCommoditydata_Temp
SELECT DISTINCT ed.versionid ,ed.companyid,ed.researchContributorId,ed.effectiveDate,edn.dataItemId----,dataitemname=dbo.DataItemName_fn(edn.dataitemid) ---INTO #OGCommoditydata_Temp ,edn.dataItemId,ctl.companyName
INTO #OGCommoditydata_Temp FROM Estimates.dbo.EstimateDetail_tbl ed (NOLOCK)
LEFT JOIN Estimates.[dbo].[EstFull_vw] edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
LEFT JOIN WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT (NOLOCK) ON ed.versionid = CT.collectionEntityTypeId AND ed.companyid = CT.relatedCompanyId
WHERE 
edn.dataItemId IN (115396,115448,115422,115584,115409,115461,115435,115474,115487,115513,115500,115526,604167,604154,112021)
AND ed.effectiveDate>= @frDate AND ed.effectiveDate<=@toDate
AND ed.versionId IS NOT NULL
ORDER BY ed.effectiveDate


IF OBJECT_ID('tempdb..#OGData_Temp') IS NOT NULL DROP TABLE #OGData_Temp
SELECT DISTINCT versionid ,companyid,researchContributorId,effectiveDate INTO #OGData_Temp FROM #OGCommoditydata_Temp 
WHERE dataItemId IN (115396,115448,115422,115584,115409,115461,115435,115474,115487,115513,115500,115526,604167,604154)

---SELECT * FROM #OGData_Temp

IF OBJECT_ID('tempdb..#Commoditydata_Temp') IS NOT NULL DROP TABLE #Commoditydata_Temp
SELECT DISTINCT versionid ,companyid,researchContributorId,effectiveDate INTO #Commoditydata_Temp FROM #OGCommoditydata_Temp 
WHERE dataItemId IN (112021)

---SELECT * FROM #Commoditydata_Temp

SELECT DISTINCT a.versionid,a.researchContributorId,a.effectiveDate FROM #OGData_Temp a
INNER JOIN #Commoditydata_Temp b ON a.versionid=b.versionid AND a.researchContributorId=b.researchContributorId
ORDER BY a.versionid