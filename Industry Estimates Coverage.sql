
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-10-09 00:00:00.000' ----Provide From Date Here
SET @toDate = '2023-10-30 23:59:59.999' ----Provide To Date Here

IF OBJECT_ID('tempdb..#IndustryCID') IS NOT NULL DROP TABLE #IndustryCID
SELECT DISTINCT ed.companyId, cc.companyName,stt.subTypeId,stt.subTypeValue,ed.effectiveDate,ednd.dataItemId,cm.IndustryID,id.IndustryName INTO #IndustryCID FROM EstimateDetail_tbl ed 
INNER JOIN ComparisonData.dbo.Company_tbl CC (NOLOCK) ON cc.companyId = ed.companyId
INNER JOIN Comparisondata.dbo.SubType_tbl stt (NOLOCK) ON stt.SubTypeId=cc.PrimarySubTypeId
INNER JOIN CompanyMaster.[dbo].[CompanyInfoMaster] cm (NOLOCK) ON cm.CIQCompanyId=cc.companyId
INNER JOIN Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] id (NOLOCK) ON cm.IndustryID=id.IndustryId
INNER JOIN EstimateDetailNumericData_tbl ednd (NOLOCK) ON ednd.estimateDetailId=ed.estimateDetailId
WHERE ed.effectiveDate>=@frDate AND ed.effectiveDate<=@toDate AND ed.versionId IS NOT NULL
AND stt.subTypeId IN (3221000,3211000,7013000,7012000,9551733,7132000,7121000,7113000,7021000,7112000,7111000,7133000,3112400,6032000,6022000,9551728,6021000,6033000,9551730,3041000,4113000,4214000,4211000,4212000,9621070,4213000,7214000,6034000,7212000,7215000,7213000,2052001,1033404,2052000,2053000,2054000,9621065,2055000,7131000,1033402,6111000,6121000,6031000,9551731,9551737,9551735,9612015,9612014,9551736,9612016,7312000,9551734,9551732,9621071,9551705,4444000,5122000,4432000,3112100,4444100,4441000,4131000,5022000,4431000,3112800,4442000,4411000,5024000,5021000,1033000,5023000,3061000,4443000,4132000,4422000,9612013,8041000,3081000,9031000,8030001,3242000,4314000,9612012,4300003,8043000,4313000,4311000,9022000,3111000,9021000,3253000)
---AND ednd.dataItemId IN (600254,601441,600262,600263,602945,600237)   ----Please provide dataItemId's here

--SELECT * FROM #IndustryCID

IF OBJECT_ID('tempdb..#IndDIMcolctd') IS NOT NULL DROP TABLE #IndDIMcolctd
SELECT DISTINCT a.* INTO #IndDIMcolctd FROM EstimateDetail_tbl ed
INNER JOIN EstimateDetailNumericData_tbl ednd (NOLOCK) ON ednd.estimateDetailId=ed.estimateDetailId
INNER JOIN DataItemMaster_vw dim (NOLOCK) ON dim.dataItemID=ednd.dataItemId
INNER JOIN #IndustryCID a (NOLOCK) ON a.companyId=ed.companyId
WHERE dim.dataCollectionTypeID=54 AND ednd.toDate>GETDATE() AND ednd.dataItemId>600000 AND ed.effectiveDate>=@frDate AND ed.effectiveDate<=@toDate

--SELECT * FROM #IndDIMcolctd


IF OBJECT_ID('tempdb..#IndDIMnotcolctd') IS NOT NULL DROP TABLE #IndDIMnotcolctd
SELECT DISTINCT * INTO #IndDIMnotcolctd FROM #IndustryCID WHERE dataItemId IN (600263,603101,603153,603283,603439,603062,603296,603205,600248,603400,602945,602984,602997,600252,600242,602971,603257,603127,603192,603348,603322,602750,602815,603309,602854,602893,602906,603361,603335,603036,603387,603374,603114,603231,602763,602841,600264,600258,600259,600256,600265,600266,600267,600269,600270,600271,602724,603075,604206,604245,603452,600284,603140,603166,603179,603244,602737,603426,602867,602919,602932,603010,604154,604167)


IF OBJECT_ID('tempdb..#Cons') IS NOT NULL DROP TABLE #Cons
SELECT DISTINCT a.companyid,a.tradingitemid,a.parentflag,a.accountingstandardid,estimatePeriodId,ednd.dataItemId,b.subTypeId,b.subTypeValue,b.effectiveDate,b.IndustryID,b.IndustryName INTO #cons FROM EstimateDetail_tbl a
INNER JOIN #IndustryCID b (NOLOCK) ON b.companyid=a.companyid
INNER JOIN EstimateDetailNumericData_tbl ednd (NOLOCK) ON ednd.estimateDetailId=a.estimateDetailId
WHERE a.effectiveDate>=@frDate AND a.effectiveDate<=@toDate AND ednd.toDate>getdate() AND ednd.dataItemId>600000

--SELECT * FROM #Cons

IF OBJECT_ID('tempdb..#IndDIMCons') IS NOT NULL DROP TABLE #IndDIMCons
SELECT DISTINCT c.*,ecnd.dataItemValue ConsVal INTO #IndDIMCons FROM #Cons c
INNER JOIN EstimateConsensus_tbl EC (NOLOCK) ON ec.companyId=c.companyId and ec.estimatePeriodId=c.estimatePeriodId AND ISNULL(eC.tradingItemId,-1) =ISNULL(c.tradingItemId,-1)
AND ISNULL(ec.accountingStandardId,255)=ISNULL(c.accountingStandardId,255) AND ec.parentFlag=c.parentflag
INNER JOIN EstimateConsensusNumericData_tbl ECND (NOLOCK) ON ecnd.estimateConsensusId=ec.estimateConsensusId
INNER JOIN EstimateDataItemRel_tbl EDR (NOLOCK) ON edr.dataItemId=c.dataItemId AND edr.estimateDataItemRelTypeId=4 AND ecnd.dataItemId=edr.relDataItemId
WHERE ecnd.toDate>GETDATE()

--SELECT * FROM #IndDIMCons

IF OBJECT_ID('tempdb..#IndGeneral') IS NOT NULL DROP TABLE #IndGeneral
SELECT DISTINCT a.* INTO #IndGeneral FROM EstimateDetail_tbl ed
INNER JOIN EstimateDetailNumericData_tbl ednd (NOLOCK) ON ednd.estimateDetailId=ed.estimateDetailId
INNER JOIN #IndustryCID a (NOLOCK) ON a.companyId=ed.companyId
WHERE ednd.dataItemId in (21642,21643,21634) AND ednd.toDate>GETDATE() AND ed.effectiveDate>=@frDate AND ed.effectiveDate<=@toDate

--SELECT * FROM #IndDIMcolctd

-------------------- Results-------------------------------


SELECT DISTINCT * FROM #IndustryCID --1221(total Industry Coverage) ----1
SELECT DISTINCT * FROM #IndDIMcolctd --553 --latest industry metric(Industry estimates coverage periodic only)----2
SELECT DISTINCT * FROM #IndDIMnotcolctd WHERE dataItemId IN (600263,603153,603101)--668 (Including General)---3
SELECT DISTINCT * FROM #IndDIMnotcolctd WHERE dataItemId NOT IN (600263,603153,603101) --668 (Excluding General)---4
SELECT DISTINCT * FROM #IndDIMCons --5103 (total industry coverage with consensus value & parent/tradingitemid)----5 --5103 (total industry coverage with consensus value & parent/tradingitemid)----5


----Max Filing Date for Industry data item collected---Industry estimates coverage periodic only----6

IF OBJECT_ID('tempdb..#maxdate') IS NOT NULL DROP TABLE #maxdate 
SELECT DISTINCT companyid,MAX(effectivedate) AS MaxFilingDate INTO #maxdate FROM #IndDIMcolctd 
GROUP BY companyid

SELECT DISTINCT a.* FROM #IndDIMcolctd a 
INNER JOIN #maxdate b (NOLOCK) ON b.companyId=a.companyId 
WHERE b.MaxFilingDate=a.effectiveDate

----Max Filing Date for Industry data item collected---Industry General----7
IF OBJECT_ID('tempdb..#maxdate1') IS NOT NULL DROP TABLE #maxdate1 
SELECT DISTINCT companyid,MAX(effectivedate) AS MaxFilingDate INTO #maxdate1 
FROM #IndGeneral 
GROUP BY companyid

SELECT DISTINCT a.* FROM #IndGeneral a 
INNER JOIN #maxdate1 b (NOLOCK) ON b.companyId=a.companyId 
WHERE b.MaxFilingDate=a.effectiveDate



