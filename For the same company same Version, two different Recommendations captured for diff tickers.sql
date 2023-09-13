USE Estimates
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2023-01-05 00:00:00.000' -----23 to 7th
SET @toDate = '2023-07-12 23:59:59.999'------08th to 22nd 
IF OBJECT_ID('tempdb..#DiffTickerSameVersionidDiffRating_Temp') IS NOT NULL DROP TABLE #DiffTickerSameVersionidDiffRating_Temp
SELECT DISTINCT  ed.versionid,ed.companyid,cm.CompanyName,cim.Country,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid), ed.effectiveDate, edn.dataItemId,
dm.dataItemName,PEO=dbo.formatPeriodId_fn(ed.estimateperiodid),ed.tradingItemId, edn.dataItemValue INTO #DiffTickerSameVersionidDiffRating_Temp
FROM Estimates.[dbo].EstimateDetail_tbl ed (NOLOCK)
INNER JOIN estimates.dbo.EstFull_vw edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
LEFT JOIN [Estimates].[dbo].[DataItemMaster_vw] dm (NOLOCK) ON edn.dataitemid=dm.dataitemid
LEFT JOIN Estimates.[dbo].[EstimatePeriod_tbl] ep (NOLOCK) ON ed.companyId = ep.companyId
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
LEFT JOIN CompanyMaster.dbo.CompanyInfoMaster cim (NOLOCK) ON ed.companyId = cim.CIQCompanyId
LEFT JOIN Comparisondata.dbo.Company_tbl cm (NOLOCK) ON ed.companyId = cm.companyId
WHERE CT.endDate > = @frDate and CT.endDate <= @toDate
AND edn.dataItemId IN (21625)
AND CT.collectionProcessId IN (64)
AND CT.collectionstageId IN (2)
AND CT.collectionstageStatusId IN (4)
AND cim.Country IN ('China')



SELECT DISTINCT T1.versionid,T1.companyId,T1.CompanyName,T1.contributor,T1.tradingItemId Ticker1,T1.dataItemName,T2.tradingItemId Ticker2,T2.dataItemName,T1.Country
FROM #DiffTickerSameVersionidDiffRating_Temp T1 INNER JOIN #DiffTickerSameVersionidDiffRating_Temp T2 ON T1.versionid = T2.versionid AND T1.companyId = T2.companyId AND T1.tradingItemId != T2.tradingItemId
WHERE T1.dataItemValue != T2.dataItemValue



