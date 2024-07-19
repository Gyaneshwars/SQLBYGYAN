
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2021-08-01 00:00:00.000' ----give here from date
SET @toDate = '2021-08-31 23:59:59.999' ----give here to date

IF OBJECT_ID('TEMPDB..#aDataVf_tblgr') IS NOT NULL DROP TABLE #aDataVf_tblgr 
SELECT DISTINCT Ed.versionId, Ed.feedFileId, Ed.companyId, Ed.effectiveDate,EdNd.dataItemId, Ed.estimatePeriodId,peo=dbo.formatPeriodId_fn(ed.estimateperiodid),
actDoneAt = EdNd.lastModifiedUTCDateTime INTO #aDataVf_tblgr FROM EstimateDetailNumericData_tbl EdNd (NOLOCK) 
INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId 
INNER JOIN workflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CEP (nolock) ON CEP.collectionEntityId = ED.versionId and CEP.relatedCompanyId = ED.companyId
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CECS (nolock) ON CEP.collectionEntityToProcessId = CECS.collectionEntityToProcessId 
INNER JOIN DataItemMaster_vw DIM ON DIM.dataItemID = EdNd.dataItemId
WHERE  CECS.collectionStageId in (2,122) AND collectionProcessId =64   AND collectionStageStatusId = 4  AND userId <>915314212 AND DIM.dataCollectionTypeID=56 
and EdNd.lastModifiedUTCDateTime>=@frDate and EdNd.lastModifiedUTCDateTime<=@toDate
INSERT INTO #aDataVf_tblgr
SELECT  DISTINCT Ed.versionId, Ed.feedFileId, Ed.companyId, Ed.effectiveDate,EdNd.dataItemId, Ed.estimatePeriodId,peo=dbo.formatPeriodId_fn(ed.estimateperiodid), 
actDoneAt = EdNd.lastModifiedUTCDateTime FROM EstimateDetailNumericData_tbl EdNd (NOLOCK) 
INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId 
INNER JOIN  DataItemMaster_vw DIM ON DIM.dataItemID = EdNd.dataItemId
WHERE DIM.dataCollectionTypeID=56 AND ed.researchContributorId=0 and EdNd.lastModifiedUTCDateTime>=@frDate and EdNd.lastModifiedUTCDateTime<=@toDate
--select * from #aDataVf_tblgr

IF OBJECT_ID('TEMPDB..#aDataVf_tbl') IS NOT NULL DROP TABLE #aDataVf_tbl 
SELECT DISTINCT versionId, feedFileId, companyId, effectiveDate, dataItemId, estimatePeriodId,MAX(actDoneAt) AS actDoneAt INTO #aDataVf_tbl FROM #aDataVf_tblgr 
GROUP BY versionId, feedFileId, companyId, effectiveDate, estimatePeriodId, dataItemId 
--select * from #aDataVf_tbl

IF OBJECT_ID ('TEMPDB..#conData_tbl') IS NOT NULL DROP TABLE #conData_tbl 
SELECT DISTINCT Ec.companyId, actEffDate = aD.effectiveDate,Ec.estimatePeriodId, PEO=dbo.formatPeriodId_fn(Ec.estimatePeriodId),actDataItemId = EDR.relDataItemId,
Ec.parentFlag, Ec.accountingStandardId,Ec.tradingItemId, aD.actDoneAt INTO #conData_tbl FROM #aDataVf_tbl aD 
INNER JOIN EstimateDetail_tbl Ec (NOLOCK) ON Ec.companyId = aD.companyId  AND Ec.estimatePeriodId = aD.estimatePeriodId 
INNER JOIN EstimateDetailNumericData_tbl EcNd (NOLOCK) ON EcNd.estimateDetailId= Ec.estimateDetailId
INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE ON ISNULL(EE.versionId,EE.feedFileId ) = ISNULL(AD.versionId,AD.feedFileId) AND EE.companyId = AD.companyId
INNER JOIN EstimateDataItemRel_tbl EDR ON EDR.dataItemId = EcNd.dataItemId
WHERE EcNd.dataItemId IN (601376,601389,600255,600247,601454,600260,600249,600245,600262,600246,600236,600277,600254,600257,600239,600237,600243,601441,600263,600253)
AND EcNd.toDate >GETDATE() AND edr.estimateDataItemRelTypeId =1
--select * from #conData_tbl

IF OBJECT_ID ('TEMPDB..#final') IS NOT NULL DROP TABLE #final 
SELECT DISTINCT cD.companyId,cd.PEO,actualDataItem = dimVa.dataItemName, cD.parentFlag, 
acStd.accountingStandardDescription, cD.tradingItemId, trVw.tradingItemNamePlus, actDoneAt,actDataItemId into #final FROM #conData_tbl cD 
INNER JOIN EstimatePeriod_tbl IP (NOLOCK) ON Ip.estimatePeriodId = cD.estimatePeriodId 
INNER JOIN DataItemMaster_vw dimVa (NOLOCK) ON dimVa.dataItemID = cD.actDataItemId 
INNER JOIN Comparisondata.dbo.company_tbl Co (NOLOCK) ON Co.companyId = cD.companyId 
LEFT JOIN EstimatesArchiveFull.dbo.TradingItem_vw trVw (NOLOCK) ON ISNULL(trVw.tradingItemId, -1) = ISNULL(cD.tradingItemId, -1) 
LEFT JOIN comparisondata.dbo.accountingStandard_tbl acStd (NOLOCK) ON acStd.accountingStandardId = cD.accountingStandardId 
WHERE NOT EXISTS ( SELECT 1 FROM EstimateDetailNumericData_tbl EdNd_ (NOLOCK) 
	INNER JOIN EstimateDetail_tbl Ed_ (NOLOCK) ON EdNd_.estimateDetailId = Ed_.estimateDetailId 
	WHERE Ed_.companyId = cD.companyId AND Ed_.estimatePeriodId = cD.estimatePeriodId AND EdNd_.dataItemId = cD.actDataItemId AND Ed_.parentFlag = cD.parentFlag
	AND ISNULL(Ed_.accountingStandardId, 255) = ISNULL(cD.accountingStandardId, 255)  AND ISNULL(Ed_.tradingItemId, -1) = ISNULL(cD.tradingItemId, -1) ) 
ORDER BY 1, 4
--select * from #final

if OBJECT_ID('tempdb..#ANJAN') is not null drop table #ANJAN
select ed2.* INTO #ANJAN from #final ed2
inner join #final ed on ed.companyId = ed2.companyId
INNER JOIN  EstimatePrimaryEarningsMetric_tbl cd on ed.tradingItemId = cd.tradingItemId and ED.companyId  = cd.companyId 
where ((ED.actDataItemId = 100284 and cd.DataItemId = 100278) or (ED.actDataItemId = 100179 and cd.DataItemId = 100173)) 
INSERT INTO #ANJAN
select ed2.* from #final ed2
where not exists (select 1 from #final ed 
INNER JOIN  EstimatePrimaryEarningsMetric_tbl cd on ed.tradingItemId = cd.tradingItemId and ED.companyId  = cd.companyId 
where ((ED.actDataItemId = 100284 and cd.DataItemId = 100278) or (ED.actDataItemId = 100179 and cd.DataItemId = 100173)) and ed.companyId = ed2.companyId)

select distinct companyId,actDataItemId,actualDataItem,peo,parentFlag,accountingStandardDescription,tradingItemId,tradingItemNamePlus,max(actdoneat) actdoneat from #ANJAN
group by companyId,actDataItemId,actualDataItem,peo,parentFlag,accountingStandardDescription,tradingItemId,tradingItemNamePlus