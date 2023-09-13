USE Estimates
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2023-07-05 00:00:00.000' -----23 to 7th
SET @toDate = '2023-07-07 23:59:59.999'------08th to 22nd 
IF OBJECT_ID('tempdb..#DatainVersionid_Temp') IS NOT NULL DROP TABLE #DatainVersionid_Temp
SELECT DISTINCT  ed.versionid,ed.companyid,cim.CompanyName,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid), ed.effectiveDate, edn.dataItemId,
dm.dataItemName,PEO=dbo.formatPeriodId_fn(ed.estimateperiodid),cm.tickerSymbol,ed.tradingItemId ,edn.dataItemValue,edn.auditTypeId INTO #DatainVersionid_Temp
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK)   ------------Estimates.[dbo].EstimateDetail_tbl ed
INNER JOIN Estimates.[dbo].EstimateDetail_tbl ed (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN estimates.dbo.EstimateDetailNumericData_tbl edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
LEFT JOIN [Estimates].[dbo].[DataItemMaster_vw] dm (NOLOCK) ON edn.dataitemid=dm.dataitemid
LEFT JOIN Estimates.[dbo].[EstimatePeriod_tbl] ep (NOLOCK) ON ed.companyId = ep.companyId
LEFT JOIN CompanyMaster.dbo.CompanyInfoMaster cim (NOLOCK) ON ed.companyid = cim.CIQCompanyId
LEFT JOIN financialsupport.dbo.TradingItem_vw cm (NOLOCK) ON ed.tradingItemId = cm.tradingItemId
WHERE CT.endDate > = @frDate and CT.endDate <= @toDate
AND edn.dataItemId IN (600263)
AND CT.collectionProcessId IN (64)
AND CT.collectionstageId IN (2)
AND CT.collectionstageStatusId IN (4)
AND edn.auditTypeId IN (2058,2059,2056,2057,2065,2092,2093,2096)



IF OBJECT_ID('tempdb..#Final_Temp') IS NOT NULL DROP TABLE #Final_Temp
SELECT DISTINCT T1.versionid,T1.companyId,T1.companyName,T1.contributor,T1.PEO,T1.tradingItemId,T1.tickerSymbol as Ticker,T1.dataItemName,T1.dataItemValue
INTO #Final_Temp FROM #DatainVersionid_Temp T1 INNER JOIN #DatainVersionid_Temp T2 ON T1.versionid = T2.versionid AND T1.companyId = T2.companyId AND T1.tradingItemId != T2.tradingItemId
WHERE T1.dataItemValue = T2.dataItemValue
AND T1.PEO = T2.PEO

SELECT * FROM #Final_Temp





