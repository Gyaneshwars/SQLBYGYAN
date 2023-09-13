Use Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2022-01-01 00:00:00.000'  -- give from date here
SET @toDate = '2023-08-30 23:59:59.999'  -- give to date here

IF OBJECT_ID('tempdb..#SGA') IS NOT NULL DROP TABLE #SGA
SELECT distinct ed.companyid,cm.CompanyName,ed.versionid,ednd.dataitemid,dataitemname=Estimates.dbo.dataitemname_fn(ednd.dataitemid),
peo=Estimates.dbo.formatperiodid_fn(ed.estimateperiodid),ednd.dataitemvalue AS estimatevalue, ed.parentflag,ed.accountingstandardid,
ed.effectiveDate INTO #SGA FROM Estimates.dbo.estimatedetail_tbl ed
INNER JOIN Estimates.dbo.Estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN Estimates.dbo.EstimatePeriod_tbl ep ON ep.estimatePeriodId=ed.estimatePeriodId
INNER JOIN CompanyMaster.dbo.CompanyInfoMaster CM ON cm.CIQCompanyId=ed.companyid
INNER JOIN Estimates.dbo.DataItemMaster_vw dim ON dim.dataItemID=ednd.dataItemId
WHERE dim.dataCollectionTypeID=54 AND ed.effectivedate>=@frdate AND ed.effectivedate<=@todate
AND ed.versionid IS NOT NULL
AND CT.collectionstageStatusId IN (4)
AND ednd.dataItemId IN (21642,21645,21643,114186,600263,114175)


---Revenue,EBIT,EBITDA,GM,D&A,Avg. Diluted Shares Outstanding Estimate 

---Excluded cons table due to taking more time to execute query

IF OBJECT_ID('TEMPDB..#consval') IS NOT NULL DROP TABLE #consval
SELECT DISTINCT ED.companyId,ef.dataItemId,dataitemname=Estimates.dbo.dataitemname_fn(ef.dataitemid),PEO =Estimates.dbo.formatperiodid_fn(ed.estimateperiodid),
ecnd.dataitemvalue AS consvalue,ed.tradingItemId,ed.parentFlag,ed.accountingStandardId,ed.estimatePeriodId,ef.currencyid,ef.unitsid,max(ed.effectiveDate)effectiveDate,
edr1.relDataItemId INTO #consval FROM Estimates.dbo.EstimateDetail_tbl ED
INNER JOIN Estimates.dbo.Estimatedetailnumericdata_tbl EF (NOLOCK) ON EF.estimateDetailId = ED.estimateDetailId
inner join Estimates.dbo.EstimatePeriod_tbl ep on ep.estimatePeriodId=ed.estimatePeriodId
INNER JOIN Estimates.dbo.EstimateConsensus_tbl EC (NOLOCK) ON ec.estimatePeriodId=ED.estimatePeriodId AND ec.companyId=Ed.companyId  
AND ISNULL (eC.tradingItemId,-1) =ISNULL (Ed.tradingItemId,-1)AND ISNULL(ec.accountingStandardId,255)=ISNULL(ED.accountingStandardId,255)AND ec.parentFlag=Ed.parentflag
INNER JOIN Estimates.dbo.EstimateConsensusNumericData_tbl ECND (NOLOCK) ON ecnd.estimateConsensusId=ec.estimateConsensusId 
INNER JOIN Estimates.dbo.EstimateDataItemRel_tbl EDR ON edr.estimateDataItemRelTypeId=4 AND ecnd.dataItemId=edr.relDataItemId AND edr.dataitemid=ef.dataitemid
INNER JOIN Estimates.dbo.EstimateDataItemRel_tbl EDR1 ON edr1.estimateDataItemRelTypeId=1 AND edr1.dataitemid=ef.dataitemid
WHERE ecnd.todate>GETDATE() AND ef.toDate>GETDATE() AND ed.effectivedate>=@frdate AND ed.effectivedate<=@todate AND ef.dataItemId IN (21642,21645,21643,114186,600263,114175)
group by ED.companyId,ef.dataItemId,ef.dataitemid,ed.estimateperiodid,ecnd.dataitemvalue,ed.tradingItemId,ed.parentFlag,ed.accountingStandardId,ed.estimatePeriodId,ef.currencyid,ef.unitsid,edr1.relDataItemId

---SELECT * FROM #consval
---SELECT * FROM #SGA


--IF OBJECT_ID('TEMPDB..#final') IS NOT NULL DROP TABLE #final
--SELECT s.*,c.consvalue INTO #final FROM #SGA s INNER JOIN #consval c (NOLOCK) ON s.dataitemid = c.dataItemId 
--AND s.peo = c.PEO 
--AND s.companyid = c.companyId
--AND s.parentFlag = c.parentflag
--AND s.accountingstandardid = c.accountingStandardId

IF OBJECT_ID('TEMPDB..#semiSGA') IS NOT NULL DROP TABLE #semiSGA
SELECT DISTINCT * INTO #semiSGA FROM #SGA
EXCEPT
SELECT DISTINCT * FROM #SGA
WHERE dataitemid = 603153

--SELECT DISTINCT * FROM #semiSGA

IF OBJECT_ID('TEMPDB..#semiconsval') IS NOT NULL DROP TABLE #semiconsval
SELECT DISTINCT * INTO #semiconsval FROM #consval
EXCEPT
SELECT DISTINCT *  FROM #consval
WHERE dataItemId = 603153

--SELECT DISTINCT * FROM #semiconsval

IF OBJECT_ID('TEMPDB..#final') IS NOT NULL DROP TABLE #final
SELECT s.*,c.consvalue INTO #final FROM #semiSGA s INNER JOIN #semiconsval c (NOLOCK) ON s.dataitemid = c.dataItemId 
AND s.peo = c.PEO 
AND s.companyid = c.companyId
AND s.parentFlag = c.parentflag
AND s.accountingstandardid = c.accountingStandardId

SELECT DISTINCT versionId,companyId FROM #final
EXCEPT
SELECT DISTINCT versionId,companyId  FROM #final
WHERE dataItemId = 603153
