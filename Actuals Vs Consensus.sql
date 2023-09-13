Use Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-04-01 00:00:00.000'  -- give from date here
SET @toDate = '2023-06-30 23:59:59.999'  -- give to date here

IF OBJECT_ID('tempdb..#Actual') IS NOT NULL DROP TABLE #Actual
SELECT distinct ed.companyid,cm.CompanyName,ed.versionid,ed.feedfileid,ednd.dataitemid,dataitemname=dbo.dataitemname_fn(ednd.dataitemid),
peo=dbo.formatperiodid_fn(ed.estimateperiodid),ednd.dataitemvalue as actualvalue, ed.parentflag,ed.accountingstandardid,ed.tradingitemid,
ednd.currencyid,ednd.unitsid,ed.effectiveDate INTO #Actual from estimatedetail_tbl ed
INNER JOIN Estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
inner join EstimatePeriod_tbl ep on ep.estimatePeriodId=ed.estimatePeriodId
INNER JOIN CompanyMaster.dbo.CompanyInfoMaster CM ON cm.CIQCompanyId=ed.companyid
inner join DataItemMaster_vw dim on dim.dataItemID=ednd.dataItemId
WHERE dim.dataCollectionTypeID=56 and ed.companyId=21719 and ed.effectivedate>=@frdate AND ed.effectivedate<=@todate
--select * from #Actual

IF OBJECT_ID('TEMPDB..#consval') IS NOT NULL DROP TABLE #consval
SELECT DISTINCT ED.companyId,ef.dataItemId,dataitemname=dbo.dataitemname_fn(ef.dataitemid),PEO =dbo.formatperiodid_fn(ed.estimateperiodid),
ecnd.dataitemvalue AS consvalue,ed.tradingItemId,ed.parentFlag,ed.accountingStandardId,ed.estimatePeriodId,ef.currencyid,ef.unitsid,max(ed.effectiveDate)effectiveDate,
edr1.relDataItemId INTO #consval FROM EstimateDetail_tbl ED
INNER JOIN Estimatedetailnumericdata_tbl EF (NOLOCK) ON EF.estimateDetailId = ED.estimateDetailId
inner join EstimatePeriod_tbl ep on ep.estimatePeriodId=ed.estimatePeriodId
INNER JOIN EstimateConsensus_tbl EC (NOLOCK) ON ec.estimatePeriodId=ED.estimatePeriodId AND ec.companyId=Ed.companyId  
AND ISNULL (eC.tradingItemId,-1) =ISNULL (Ed.tradingItemId,-1)AND ISNULL(ec.accountingStandardId,255)=ISNULL(ED.accountingStandardId,255)AND ec.parentFlag=Ed.parentflag
INNER JOIN EstimateConsensusNumericData_tbl ECND (NOLOCK) ON ecnd.estimateConsensusId=ec.estimateConsensusId 
INNER JOIN EstimateDataItemRel_tbl EDR ON edr.estimateDataItemRelTypeId=4 AND ecnd.dataItemId=edr.relDataItemId AND edr.dataitemid=ef.dataitemid
INNER JOIN EstimateDataItemRel_tbl EDR1 ON edr1.estimateDataItemRelTypeId=1 AND edr1.dataitemid=ef.dataitemid
WHERE ecnd.todate>GETDATE() AND ef.toDate>GETDATE() AND ed.companyId=21719 AND ed.effectivedate>=@frdate AND ed.effectivedate<=@todate
group by ED.companyId,ef.dataItemId,ef.dataitemid,ed.estimateperiodid,ecnd.dataitemvalue,ed.tradingItemId,ed.parentFlag,ed.accountingStandardId,ed.estimatePeriodId,ef.currencyid,ef.unitsid,edr1.relDataItemId
--select * from #consval

SELECT DISTINCT a.*,Adjactvalue=((Uc.conversionFactor *  a.actualvalue)*gc.conversionFactor),c.consvalue FROM #Actual a
INNER JOIN #consval c ON c.companyid=a.companyid and c.relDataItemId=a.dataitemid and c.peo=a.peo AND ISNULL(c.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) 
AND ISNULL(c.accountingstandardid,255)=ISNULL(a.accountingstandardid,255) AND c.parentflag=a.parentflag
LEFT JOIN DBO.UnitsConversion_tbl Uc (NOLOCK) ON Uc.convertFromUnitsId = a.unitsid AND UC.convertToUnitsId = c.unitsid 
LEFT JOIN Comparisondata.dbo.Currency_HistoricalConversionFactor_tbl GC(NOLOCK) ON Gc.convertFromCurrencyId= a.currencyId 
AND GC.convertToCurrencyId = c.currencyId and GC.conversionDate = Convert(varchar(10),a.effectiveDate,101)
