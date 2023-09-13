USE Estimates
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2023-01-01 00:00:00.000' -----23 to 7th
SET @toDate = '2023-07-14 23:59:59.999'------08th to 22nd 
IF OBJECT_ID('tempdb..#DiffTickerSameVersionidDiffRating_Temp') IS NOT NULL DROP TABLE #DiffTickerSameVersionidDiffRating_Temp
SELECT DISTINCT  ed.versionid,ed.companyid,cim.CompanyName,cim.Country,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid), ed.effectiveDate, edn.dataItemId,
dm.dataItemName,cm.tickerSymbol,ed.tradingItemId ,edn.dataItemValue,CT.endDate INTO #DiffTickerSameVersionidDiffRating_Temp
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK)   ---Estimates.[dbo].EstimateDetail_tbl ed
INNER JOIN Estimates.[dbo].EstimateDetail_tbl ed (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN Estimates.dbo.EstFull_vw edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
LEFT JOIN estimates.[dbo].[EstimateDetailIdData_tbl] eid (NOLOCK) ON ed.estimateDetailId = eid.estimateDetailId
LEFT JOIN [Estimates].[dbo].[DataItemMaster_vw] dm (NOLOCK) ON edn.dataitemid=dm.dataitemid
LEFT JOIN Estimates.[dbo].[EstimatePeriod_tbl] ep (NOLOCK) ON CT.relatedCompanyId = ep.companyId
LEFT JOIN CompanyMaster.dbo.CompanyInfoMaster cim (NOLOCK) ON ed.companyid = cim.CIQCompanyId
LEFT JOIN financialsupport.dbo.TradingItem_vw cm (NOLOCK) ON ed.tradingItemId = cm.tradingItemId
WHERE CT.endDate > = @frDate and CT.endDate <= @toDate
AND edn.dataItemId IN (21625)
AND CT.collectionProcessId IN (64)
AND CT.collectionstageId IN (2)
AND CT.collectionstageStatusId IN (4)
AND dm.dataCollectionTypeID IN (63)
AND cim.Country IN ('China')

SELECT * FROM #DiffTickerSameVersionidDiffRating_Temp

IF OBJECT_ID('tempdb..#final_Temp') IS NOT NULL DROP TABLE #final_Temp
SELECT DISTINCT T1.versionid,T1.companyId,T1.CompanyName,T1.contributor,T1.tradingItemId AS tradingItemId1,T1.tickerSymbol AS Ticker_1,
T1.dataItemValue AS Recommendation_1,T2.tradingItemId AS tradingItemId2,T2.tickerSymbol AS Ticker_2,T2.dataItemValue AS Recommendation_2,T1.Country,
(ROW_NUMBER() OVER(PARTITION BY T1.versionid,T1.companyId ORDER BY T1.versionid,T1.companyId)) AS Rownumber
INTO #final_Temp FROM #DiffTickerSameVersionidDiffRating_Temp T1 
LEFT JOIN #DiffTickerSameVersionidDiffRating_Temp T2 (NOLOCK) ON T2.versionid = T1.versionid AND T2.companyId = T1.companyId AND T2.tradingItemId <> T1.tradingItemId
WHERE T2.dataItemValue <> T1.dataItemValue

select * from #final_Temp order by versionId,companyId

SELECT versionId,companyId,CompanyName,contributor,Ticker_1,Recommendation_1,Ticker_2,Recommendation_2,Country FROM #final_Temp WHERE Rownumber=1