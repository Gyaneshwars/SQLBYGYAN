
---Python & SQL ETL Developer-GNANESHWAR SRAVANE

----Estimates Vs Pricing

USE Estimates
DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2000-01-01 00:00:00.000'
SET @todate='2015-12-31 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#FD') IS NOT NULL DROP TABLE #FD
SELECT DISTINCT CompanyId,MIN(EffectiveDate) AS Min_FD INTO #FD FROM [EstimateTimeliness].dbo.[EstimateTimelinessDetail_tbl]
GROUP BY CompanyId
HAVING MIN(EffectiveDate)>=@frdate AND MIN(EffectiveDate)<=@todate

IF OBJECT_ID ('TEMPDB..#EstData') IS NOT NULL DROP TABLE #EstData
SELECT DISTINCT ed.versionid, ed.feedfileid, ed.tradingItemId, ed.companyid,ed.researchcontributorid, ed.effectiveDate,
ed.accountingStandardId INTO #EstData FROM EstimateDetail_tbl ED (NOLOCK)
INNER JOIN EstimatePeriod_tbl EP (NOLOCK) ON ED.estimatePeriodId = ep.estimatePeriodId
WHERE ed.effectiveDate>=@frdate AND ed.effectiveDate<=@todate
ORDER BY ed.effectiveDate DESC

IF OBJECT_ID ('TEMPDB..#SPLITFR1') IS NOT NULL DROP TABLE #SPLITFR1
SELECT DISTINCT esi.companyId,esi.tradingItemId,csf.effectiveDate,esi.exDate,esi.factor as Esti_splitfactor,esi.announcedDate,st.announcedDate as Pricing_announcedDate,
st.rate as Pricing_splitfactor,st.exDate as Pricing_exDate,fst.rate as FDCA_splitfactor,fst.primaryExDate as FDCA_exDate,f1.Min_FD,esi.sourceTypeId
INTO #SPLITFR1 FROM Estimates.[dbo].[EstimateSplitInfo_tbl] esi
LEFT JOIN Estimates.dbo.CumilativeSplitFactor_tbl csf ON esi.companyId=csf.companyId AND esi.tradingItemId=csf.tradingItemId AND esi.exDate=csf.toDate
LEFT JOIN comparisondata..split_tbl st ON st.tradingItemId=esi.tradingItemId AND st.exDate=esi.exDate AND st.appliedFlag=1
LEFT JOIN financialdata..splitmaster_tbl fst (NOLOCK) ON fst.companyId=esi.companyId AND esi.exDate=fst.primaryExDate
INNER JOIN #EstData ed (NOLOCK) ON ed.companyId=esi.companyId AND ed.tradingItemId=esi.tradingItemId
INNER JOIN #FD f1 ON f1.CompanyId=esi.companyId
WHERE esi.exDate>=f1.Min_FD
AND st.rate IS NULL
AND fst.rate IS NULL




SELECT DISTINCT *,COUNT(*) OVER(PARTITION BY companyId) AS Count_of_mismatch_of_splits_C_AND_T FROM #SPLITFR1
ORDER BY companyId,tradingItemId,exDate,Esti_splitfactor,Pricing_announcedDate DESC

--SELECT DISTINCT companyId,tradingItemId,COUNT(*) OVER(PARTITION BY companyId,tradingItemId) AS Count_of_mismatch_of_splits_C_AND_T FROM #SPLITFR1-- WHERE Esti_tradingItemId IS NULL AND Esti_toDate IS NULL
--ORDER BY companyId,tradingItemId DESC
