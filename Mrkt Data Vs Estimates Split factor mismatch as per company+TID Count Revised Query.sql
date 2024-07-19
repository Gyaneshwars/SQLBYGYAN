---Python & SQL ETL Developer-GNANESHWAR SRAVANE

----Pricing Vs Estimates
USE Estimates
DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2000-01-01 00:00:00.000'
SET @todate='2023-12-31 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#FD1') IS NOT NULL DROP TABLE #FD1
SELECT DISTINCT CompanyId,MIN(EffectiveDate) AS Min_FD INTO #FD1 FROM [EstimateTimeliness].dbo.[EstimateTimelinessDetail_tbl]
GROUP BY CompanyId
HAVING MIN(EffectiveDate)>=@frdate AND MIN(EffectiveDate)<=@todate

IF OBJECT_ID ('TEMPDB..#MktData') IS NOT NULL DROP TABLE #MktData
SELECT DISTINCT ed.versionid, ed.feedfileid, ed.tradingItemId, ed.companyid,ed.researchcontributorid, ed.effectiveDate,
ed.accountingStandardId INTO #MktData FROM EstimateDetail_tbl ED (NOLOCK)
INNER JOIN EstimatePeriod_tbl EP (NOLOCK) ON ED.estimatePeriodId = ep.estimatePeriodId
WHERE ed.effectiveDate>=@frdate AND ed.effectiveDate<=@todate
ORDER BY ed.effectiveDate DESC

IF OBJECT_ID ('TEMPDB..#SPLITFR') IS NOT NULL DROP TABLE #SPLITFR
SELECT DISTINCT stt.companyId,st.tradingItemId,st.exDate,st.rate as Pricing_splitfactor,csf.toDate as Esti_toDate,
esi.announcedDate AS Esti_announcedDate,esi.factor as Esti_splitfactor,fst.rate as FDCA_splitfactor,fst.primaryExDate as FDCA_exdate,esi.exDate as Esti_exDate,f2.Min_FD,esi.sourceTypeId
INTO #SPLITFR FROM comparisondata..split_tbl st (NOLOCK)
INNER JOIN comparisondata..tradingitemdetails_tbl tid (NOLOCK) ON tid.tradingitemid=st.tradingitemid
INNER JOIN comparisondata..security_tbl stt (NOLOCK) ON stt.securityid=tid.securityid
--LEFT JOIN comparisondata.[dbo].[SplitType_tbl] slt (NOLOCK) ON slt.splitTypeId=st.splitTypeId
LEFT JOIN Estimates.[dbo].[EstimateSplitInfo_tbl] esi (NOLOCK) ON esi.companyId=stt.companyId AND esi.tradingItemId=st.tradingItemId AND esi.exDate=st.toDate --AND esi.announcedDate IS NOT NULL
LEFT JOIN Estimates.dbo.CumilativeSplitFactor_tbl csf (NOLOCK) ON csf.companyId=esi.companyId AND csf.tradingItemId=esi.tradingitemid AND csf.toDate=esi.exDate
LEFT JOIN financialdata..splitmaster_tbl fst (NOLOCK) ON fst.companyId=stt.companyId AND st.exDate=fst.primaryExDate
INNER JOIN #MktData md (NOLOCK) ON md.companyId=stt.companyId AND md.tradingItemId=st.tradingItemId
--RIGHT JOIN CumilativeSplitFactor_tbl csf1 (NOLOCK) ON csf1.companyId=stt.companyId AND csf1.tradingItemId=st.tradingitemid AND csf1.toDate=st.exDate
--LEFT JOIN financialdata..splitmaster_tbl sm (NOLOCK) ON sm.companyId=stt.companyId AND sm.primaryExDate=st.exDate
INNER JOIN #FD1 f2 ON f2.CompanyId=stt.companyId
WHERE 
st.appliedFlag IN (1)
AND st.exDate>=f2.Min_FD
AND esi.factor IS NULL
--AND fst.rate IS NULL
ORDER BY stt.companyId,st.exDate DESC




SELECT DISTINCT *,COUNT(*) OVER(PARTITION BY companyId) AS Count_of_mismatch_of_splits_C_AND_T FROM #SPLITFR-- WHERE Esti_tradingItemId IS NULL AND Esti_toDate IS NULL
ORDER BY companyId,tradingItemId,exDate,Pricing_splitfactor,Esti_splitfactor DESC


----Count as per companyid & todate



--SELECT DISTINCT companyId,tradingItemId,COUNT(*) OVER(PARTITION BY companyId,tradingItemId) AS Count_of_mismatch_of_splits_C_AND_T FROM #SPLITFR-- WHERE Esti_tradingItemId IS NULL AND Esti_toDate IS NULL
--ORDER BY companyId,tradingItemId DESC