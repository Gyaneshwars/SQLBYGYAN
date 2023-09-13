
--SQL QUERY DEVELOPER-->GNANESHWAR SRAVANE
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2022-01-01 00:00:00.000'  -- give from date here
SET @toDate = '2023-08-30 23:59:59.999'  -- give to date here

IF OBJECT_ID('TEMPDB..#tempFA') IS NOT NULL DROP TABLE #tempFA  CREATE TABLE #tempFA (FDCAdataItemId int,EDCAdataItemId int,dataItemTag varchar(5)); INSERT INTO #tempFA VALUES  
(21889,600317,'GEP'),(21884,600311,'GWP'),(21886,600310,'NWP'),(31478,600307,'IAR')

--select * from #tempFA

IF OBJECT_ID('tempdb..#Actual') IS NOT NULL DROP TABLE #Actual
SELECT distinct ed.companyid,cm.CompanyName,ed.versionid,ed.feedfileid,ednd.dataitemid,dataitemname=Estimates.dbo.dataitemname_fn(ednd.dataitemid),
peo=Estimates.dbo.formatperiodid_fn(ed.estimateperiodid),ednd.dataitemvalue as actualvalue, ed.parentflag,ed.accountingstandardid,ed.tradingitemid,
ednd.currencyid,ednd.unitsid,ed.effectiveDate,ep.periodEndDate,fa.FDCAdataItemId,fa.dataItemTag,ep.periodTypeId INTO #Actual from Estimates.dbo.estimatedetail_tbl ed (NOLOCK)
INNER JOIN Estimates.dbo.Estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN Estimates.dbo.EstimatePeriod_tbl ep (NOLOCK) ON ep.estimatePeriodId=ed.estimatePeriodId
INNER JOIN CompanyMaster.dbo.CompanyInfoMaster CM (NOLOCK) ON cm.CIQCompanyId=ed.companyid
INNER JOIN Estimates.dbo.DataItemMaster_vw dim (NOLOCK) ON dim.dataItemID=ednd.dataItemId
INNER JOIN #tempFA fa (NOLOCK) ON fa.EDCAdataItemId=ednd.dataitemid
WHERE dim.dataCollectionTypeID=56 AND ed.effectivedate>=@frdate AND ed.effectivedate<=@todate
AND ednd.dataItemId IN (600311,600317,600310,600307)
AND ed.versionid IS NOT NULL
AND ed.companyId IN (38652174,160077,5631163,26273,1038328,7320497,8707653,527074,104673,875917,100321596,379475737,869527,246247134,875632,10203726) ---Provide companyids here
AND CT.collectionstageStatusId IN (4)

---Consensus data taking more time to execute hence excluded.nearly 6 to 7 hrs

--IF OBJECT_ID('TEMPDB..#consval') IS NOT NULL DROP TABLE #consval
--SELECT DISTINCT ED.companyId,ef.dataItemId,dataitemname=Estimates.dbo.dataitemname_fn(ef.dataitemid),PEO =Estimates.dbo.formatperiodid_fn(ed.estimateperiodid),
--ecnd.dataitemvalue AS consvalue,ed.tradingItemId,ed.parentFlag,ed.accountingStandardId,ed.estimatePeriodId,ef.currencyid,ef.unitsid,max(ed.effectiveDate)effectiveDate,
--edr1.relDataItemId INTO #consval FROM Estimates.dbo.EstimateDetail_tbl ED
--INNER JOIN Estimates.dbo.Estimatedetailnumericdata_tbl EF (NOLOCK) ON EF.estimateDetailId = ED.estimateDetailId
--inner join Estimates.dbo.EstimatePeriod_tbl ep on ep.estimatePeriodId=ed.estimatePeriodId
--INNER JOIN Estimates.dbo.EstimateConsensus_tbl EC (NOLOCK) ON ec.estimatePeriodId=ED.estimatePeriodId AND ec.companyId=Ed.companyId  
--AND ISNULL (eC.tradingItemId,-1) =ISNULL (Ed.tradingItemId,-1)AND ISNULL(ec.accountingStandardId,255)=ISNULL(ED.accountingStandardId,255)AND ec.parentFlag=Ed.parentflag
--INNER JOIN Estimates.dbo.EstimateConsensusNumericData_tbl ECND (NOLOCK) ON ecnd.estimateConsensusId=ec.estimateConsensusId 
--INNER JOIN Estimates.dbo.EstimateDataItemRel_tbl EDR ON edr.estimateDataItemRelTypeId=4 AND ecnd.dataItemId=edr.relDataItemId AND edr.dataitemid=ef.dataitemid
--INNER JOIN Estimates.dbo.EstimateDataItemRel_tbl EDR1 ON edr1.estimateDataItemRelTypeId=1 AND edr1.dataitemid=ef.dataitemid
--WHERE ecnd.todate>GETDATE() AND ef.toDate>GETDATE() AND ed.effectivedate>=@frDate AND ed.effectivedate<=@toDate --AND ED.companyId=9003966
--group by ED.companyId,ef.dataItemId,ef.dataitemid,ed.estimateperiodid,ecnd.dataitemvalue,ed.tradingItemId,ed.parentFlag,ed.accountingStandardId,ed.estimatePeriodId,ef.currencyid,ef.unitsid,edr1.relDataItemId



IF OBJECT_ID('tempdb..#FDCA') IS NOT NULL DROP TABLE #FDCA
SELECT DISTINCT ft.filingId,fdit.dataItemId,fdit.ObjectID,ft.versionId,ft.companyId,ft.filingDateTime,pt.asReportedPeriodEndDate,pndt.Dataitemvalue,fdm.dataItemTag,
ft.primaryPeriodEndDate,ftpt.Filingtoperiodid,ft.primaryPeriodTypeId,(CASE pt.numMonths  WHEN 3 THEN '2' WHEN 6 THEN '10' WHEN 12 THEN '1' END) AS numMonths INTO #FDCA 
FROM FinancialData.dbo.Filing_tbl ft (NOLOCK)
INNER JOIN FinancialData.dbo.FilingDataItem_tbl fdit (NOLOCK) ON ft.filingId = fdit.filingId
INNER JOIN FinancialData.dbo.Periodicnumericdata_tbl pndt (NOLOCK) ON pndt.Filingdataitemid = fdit.filingdataItemId
INNER JOIN FinancialData.[dbo].[FinancialDataItemMaster_vw] fdm (NOLOCK) ON fdit.dataItemId=fdm.dataItemId
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK) ON  ft.companyId = CT.relatedCompanyId
INNER JOIN Estimates.dbo.estimatedetail_tbl ed (NOLOCK) ON  ed.versionid = CT.collectionEntityId AND ed.companyId = CT.relatedCompanyId
--INNER JOIN Estimates.dbo.Estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
--inner join FinancialData.dbo.PeriodicDateData_tbl pndt (NOLOCK)
--inner join FinancialData.dbo.PeriodicIDData_tbl pndt (NOLOCK)
INNER JOIN FinancialData.dbo.FilingToPeriod_tbl ftpt (NOLOCK) ON ftpt.filingId = ft.filingId and ftpt.Filingtoperiodid = pndt.Filingtoperiodid
INNER JOIN FinancialData.dbo.Period_tbl pt (NOLOCK) ON ftpt.Periodid = pt.PeriodID
--INNER JOIN FinancialData.[dbo].[FilingToPeriodDetails_vw] fpd (NOLOCK) ON fpd.companyId = ft.companyId
WHERE ft.filingDateTime>=@frdate AND ft.filingDateTime<=@todate AND ed.effectivedate>=@frdate AND ed.effectivedate<=@todate
AND ft.companyId IN (38652174,160077,5631163,26273,1038328,7320497,8707653,527074,104673,875917)--,100321596,379475737,869527,246247134,875632,10203726) ---Provide companyids here
AND CT.collectionstageStatusId IN (4)
AND fdit.dataItemId IN (21889,21884,21886,31478,31785)
--AND ft.primaryPeriodTypeId IN (1,2,10)
--AND pt.numMonths IN (3,6,12)
AND ft.activeFlag=1
AND asReportedPeriodEndDate = primaryPeriodEndDate

---Without Consensus Table

IF OBJECT_ID('tempdb..#final') IS NOT NULL DROP TABLE #final
SELECT DISTINCT a.companyId,a.CompanyName,a.dataItemTag AS FDCA_Tag,a.dataitemname,a.peo,a.periodTypeId AS EDCA_PeriodType,f.numMonths AS FDCA_PeriodType,SUM(f.Dataitemvalue) AS FDCA_Actual,
a.actualvalue AS EDCA_Actual,a.parentflag,a.accountingstandardid,f.filingId,f.versionId AS FDCA_VersionId INTO #final FROM #Actual a (NOLOCK)
LEFT JOIN #FDCA f (NOLOCK) ON a.companyid = f.companyId AND a.FDCAdataItemId=f.dataItemId AND a.periodEndDate=f.asReportedPeriodEndDate AND f.numMonths=a.periodTypeId
GROUP BY a.companyId,a.CompanyName,a.dataItemTag,a.dataitemname,a.peo,a.periodTypeId,f.numMonths,a.actualvalue,a.parentflag,a.accountingstandardid,f.filingId,f.versionId



---With Consensus Table

--IF OBJECT_ID('tempdb..#finalc') IS NOT NULL DROP TABLE #finalc
--SELECT DISTINCT a.companyId,a.CompanyName,a.dataItemTag AS FDCA_Tag,a.dataitemname,a.peo,a.periodTypeId AS EDCA_PeriodType,f.numMonths AS FDCA_PeriodType,f.Dataitemvalue as FDCA_Actual,
--a.actualvalue as EDCA_Actual,(CASE WHEN c.consvalue IS NOT NULL THEN 'Yes' ELSE 'No' END) AS consvalue,a.parentflag,a.accountingstandardid
--INTO #finalc FROM #Actual a (NOLOCK)
--LEFT JOIN #FDCA f (NOLOCK) ON a.companyid = f.companyId AND a.FDCAdataItemId=f.dataItemId AND a.periodEndDate=f.asReportedPeriodEndDate
--LEFT JOIN #consval c (NOLOCK) ON c.companyId=a.companyid AND c.relDataItemId = a.dataitemid AND c.PEO=a.peo

SELECT DISTINCT companyId,CompanyName,FDCA_TAG,dataitemname,peo,FDCA_Actual,EDCA_Actual,parentflag FROM #final


---SELECT DISTINCT * FROM #final

--SELECT DISTINCT * FROM #finalc



--SELECT DISTINCT * FROM #FDCA

--SELECT DISTINCT * FROM #Actual

--SELECT DISTINCT * FROM #consval