
USE Estimates
DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2023-08-20 00:00:00.000'
SET @todate='2023-08-30 23:59:59.999'

IF OBJECT_ID('tempdb..#Estdatasubtype') IS NOT NULL DROP TABLE #Estdatasubtype
SELECT DISTINCT ed.versionId,ed.companyId,PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataitemid,dataitem=dbo.DataItemName_fn(ednd.dataItemId),ednd.dataItemValue,
ed.parentFlag,ed.tradingItemId,ed.accountingStandardId,ed.effectiveDate,c.PrimarySubTypeId AS SubTypeId,s.subTypeValue AS SubtypeName INTO #Estdatasubtype 
FROM EstimateDetail_tbl ed (NOLOCK)
INNER JOIN Estimates.[dbo].[EstFull_vw] ednd (NOLOCK) ON ednd.estimateDetailId=ed.estimateDetailId
LEFT JOIN  Estimates.[dbo].estimatePeriod_tbl FI (NOLOCK) ON FI.estimatePeriodId = ED.estimatePeriodId 
LEFT JOIN  ComparisonData.[dbo].[Company_tbl] c (NOLOCK) ON ed.companyId=c.companyId
LEFT JOIN  ComparisonData.[dbo].[SubType_tbl] s (NOLOCK) ON s.subTypeId=c.PrimarySubTypeId
WHERE ed.effectiveDate>=@frdate AND ed.effectivedate<=@todate  AND ed.versionId IS NOT NULL
AND c.PrimarySubTypeId IN (1033000,8031000,3211000,4121000,4212000,6121000,6031000,9621063,2041000,4444000,4441000,9551704)
AND ednd.dataItemId in (21642)
AND FI.periodTypeId IN (1)
AND ednd.toDate

IF OBJECT_ID('tempdb..#Final') IS NOT NULL DROP TABLE #Final
SELECT *,ROW_NUMBER() OVER(PARTITION BY versionId,companyId,parentFlag,dataitemid ORDER BY PEO) AS rwnumber INTO #Final FROM #Estdatasubtype


SELECT * FROM #Final WHERE rwnumber=1