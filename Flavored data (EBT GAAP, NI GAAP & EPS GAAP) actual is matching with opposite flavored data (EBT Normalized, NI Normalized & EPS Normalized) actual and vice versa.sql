-----SQL Query Developer---Gnaneshwar Sravane
USE Estimates
DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2023-08-20 00:00:00.000'
SET @todate='2023-08-30 23:59:59.999'

IF OBJECT_ID('tempdb..#act') IS NOT NULL DROP TABLE #act
SELECT DISTINCT ed.feedFileId,ed.companyId,PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataitemid,dataitem=dbo.DataItemName_fn(ednd.dataItemId),
ednd.dataItemValue,ednd.currencyid,ednd.unitsId,ed.parentFlag,ed.tradingItemId,ed.accountingStandardId,ed.effectiveDate INTO #act FROM EstimateDetail_tbl ed
INNER JOIN EstimateDetailNumericData_tbl ednd (NOLOCK) ON ednd.estimateDetailId=ed.estimateDetailId
WHERE ednd.dataItemId in (100249,100270,100284,100235,100256,100179)
AND ed.effectiveDate>=@frdate AND ed.effectivedate<=@todate  AND ed.feedFileId IS NOT NULL;

--select * from #act

IF OBJECT_ID('tempdb..#EBT') IS NOT NULL DROP TABLE #EBT
SELECT DISTINCT a.feedFileId,a.companyId,a.PEO,a.dataitem AS dataitem_GAAP,a.dataItemValue AS dataItemValue_GAAP,b.dataitem AS dataitem_Norm,b.dataItemValue AS dataItemValue_Norm,
a.effectiveDate,a.parentFlag,a.tradingItemId,a.accountingStandardId INTO #EBT FROM #act a 
INNER JOIN #act b ON b.companyId=a.companyId AND b.parentFlag=a.parentFlag AND b.feedFileId=a.feedFileId
AND ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) AND ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
WHERE a.dataItemId IN (100249) AND b.dataItemId IN (100235) AND b.peo=a.peo AND a.dataItemValue=b.dataItemValue
AND a.currencyId=b.currencyId AND a.unitsId=b.unitsId
ORDER BY a.effectiveDate;

----SELECT * FROM #EBT

IF OBJECT_ID('tempdb..#NI') IS NOT NULL DROP TABLE #NI
SELECT DISTINCT a.feedFileId,a.companyId,a.PEO,a.dataitem AS dataitem_GAAP,a.dataItemValue AS dataItemValue_GAAP,b.dataitem AS dataitem_Norm,b.dataItemValue AS dataItemValue_Norm,
a.effectiveDate,a.parentFlag,a.tradingItemId,a.accountingStandardId INTO #NI FROM #act a 
INNER JOIN #act b ON b.companyId=a.companyId AND b.parentFlag=a.parentFlag AND b.feedFileId=a.feedFileId
AND ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) AND ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
WHERE a.dataItemId IN (100270) AND b.dataItemId IN (100256) AND b.peo=a.peo AND a.dataItemValue=b.dataItemValue 
AND a.currencyId=b.currencyId AND a.unitsId=b.unitsId
ORDER BY a.effectiveDate;

----SELECT * FROM #NI

IF OBJECT_ID('tempdb..#EPS') IS NOT NULL DROP TABLE #EPS
SELECT DISTINCT a.feedFileId,a.companyId,a.PEO,a.dataitem AS dataitem_GAAP,a.dataItemValue AS dataItemValue_GAAP,b.dataitem AS dataitem_Norm,b.dataItemValue AS dataItemValue_Norm,
a.effectiveDate,a.parentFlag,a.tradingItemId,a.accountingStandardId INTO #EPS FROM #act a 
INNER JOIN #act b ON b.companyId=a.companyId AND b.parentFlag=a.parentFlag AND b.feedFileId=a.feedFileId
AND ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) AND ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
WHERE a.dataItemId IN (100284) AND b.dataItemId IN (100179) AND b.peo=a.peo AND a.dataItemValue=b.dataItemValue 
AND a.currencyId=b.currencyId AND a.unitsId=b.unitsId
ORDER BY a.effectiveDate;

----SELECT * FROM #EPS

WITH CombinedResults AS (
	SELECT * FROM #EBT
	UNION ALL
	SELECT * FROM #NI
	UNION ALL
	SELECT * FROM #EPS
)
SELECT *
FROM CombinedResults ORDER BY feedFileId,companyId;