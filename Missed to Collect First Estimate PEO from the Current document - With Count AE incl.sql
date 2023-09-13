USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = Convert(varchar(10),getdate() -1,101)  
SET @toDate = Convert(varchar(10),getdate() ,101) 
--SET @frDate = '2017-02-26 00:00:00.000'		-- Give From Date here 
--SET @toDate = '2017-02-26 23:59:59.999'		-- Give To Date here
--<begDQ>
IF OBJECT_ID('TEMPDB..#ePDFs_tbl') IS NOT NULL DROP TABLE #ePDFs_tbl 
SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate INTO #ePDFs_tbl 
FROM EstimateDetail_tbl Ed (NOLOCK) 
INNER JOIN EstimateDetailNumericData_tbl EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId 
INNER JOIN  workflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CEP (nolock) ON CEP.collectionEntityId = ED.versionId AND CEP.relatedCompanyId = ED.companyId
INNER JOIN  WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CECS (nolock) ON CEP.collectionEntityToProcessId = CECS.collectionEntityToProcessId
WHERE Ed.versionId > 0 AND Ed.researchContributorId > 0 
AND CECS.endDate >= @frDate and CECS.endDate <= @toDate and CECS.collectionStageId in (2,122) and collectionProcessId =64  and collectionStageStatusId = 4 AND userId <> 915314212
GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate 

IF OBJECT_ID('TEMPDB..#eDataVf_tbl') IS NOT NULL DROP TABLE #eDataVf_tbl 
( SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate,Ep.estimatePeriodId, Ep.periodEndDate, Ep.periodTypeId, doneAtIST = EdNd.lastModifiedUTCDateTime + '5:30' INTO #eDataVf_tbl 
FROM #ePDFs_tbl e 
INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = e.versionId AND Ed.companyId = e.companyId AND Ed.researchContributorId = e.researchContributorId 
INNER JOIN EstimateDetailNumericData_tbl EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId AND EdNd.parentEstimateDetailNumericDataId IS NULL 
INNER JOIN DataItemMaster_vw dimV ON dimV.dataItemID = EdNd.dataItemId AND dimV.dataCollectionTypeID = 54 
INNER JOIN EstimatePeriod_tbl Ep (NOLOCK) ON Ep.estimatePeriodId = Ed.estimatePeriodId 
GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId,	Ed.effectiveDate, Ep.estimatePeriodId, Ep.periodEndDate, Ep.periodTypeId, EdNd.lastModifiedUTCDateTime + '5:30' ) 
IF OBJECT_ID ('TEMPDB..#actPEOs_Gr_tbl') IS NOT NULL DROP TABLE #actPEOs_Gr_tbl
(SELECT Ed.companyId, maxActualPEO = MAX(Ep.periodEndDate) INTO #actPEOs_Gr_tbl 
FROM EstimateDetail_tbl Ed (NOLOCK) INNER JOIN EstimatePeriod_tbl Ep (NOLOCK) ON Ep.estimatePeriodId = Ed.estimatePeriodId 
INNER JOIN EstimateDetailNumericData_tbl EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId 
INNER JOIN DataItemMaster_vw DimV (NOLOCK) ON DimV.dataItemId = EdNd.dataItemId AND DimV.dataCollectionTypeID = 56 
WHERE Ed.companyId IN (SELECT DISTINCT e.companyId FROM #eDataVf_tbl e) GROUP BY Ed.companyId ) 
IF OBJECT_ID('TEMPDB..#minEstPEO_tbl') IS NOT NULL DROP TABLE #minEstPEO_tbl 
SELECT a.versionId, a.companyId, a.researchContributorId, a.effectiveDate, a.periodTypeId, 
MIN(a.periodEndDate) AS minPEO, preEstPEO = CASE WHEN periodTypeId = 1 THEN DATEADD(mm, -12, MIN(a.periodEndDate)) 
WHEN periodTypeId = 2 THEN DATEADD(mm, -3, MIN(a.periodEndDate)) WHEN periodTypeId = 10 THEN DATEADD(mm, -6, 
MIN(a.periodEndDate)) END INTO #minEstPEO_tbl FROM #eDataVf_tbl a 
GROUP BY a.versionId, a.companyId, a.researchContributorId, a.effectiveDate , a.periodTypeId 
IF OBJECT_ID('TEMPDB..#notActualizedPreEstPEO_tbl') IS NOT NULL DROP TABLE #notActualizedPreEstPEO_tbl SELECT mE.versionId, 
mE.companyId, mE.researchContributorId,	mE.effectiveDate, mE.minPEO, mE.preEstPEO, mE.periodTypeId INTO #notActualizedPreEstPEO_tbl 
FROM #minEstPEO_tbl mE WHERE NOT EXISTS ( SELECT 1 FROM #actPEOs_Gr_tbl a WHERE a.companyId = mE.companyId AND a.maxActualPEO >= mE.preEstPEO ) 
IF OBJECT_ID('TEMPDB..#Gr_tbl') IS NOT NULL DROP TABLE #Gr_tbl 
SELECT DISTINCT n.companyId, n.researchContributorId, n.versionId curVerId, n.effectiveDate AS curEffDate, n.minPEO, n.preEstPEO, Ed.versionId AS preVerId, Ed.effectiveDate AS preEffDate, Ed.estimatePeriodId, Ep.periodEndDate, Ep.periodTypeId INTO #Gr_tbl 
FROM #notActualizedPreEstPEO_tbl n 
INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.companyId = n.companyId AND Ed.researchContributorId = n.researchContributorId AND Ed.effectiveDate < n.effectiveDate AND DATEDIFF(DD, Ed.effectiveDate, n.effectiveDate) <= 181 
INNER JOIN EstimateDetailNumericData_tbl EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId AND EdNd.parentEstimateDetailNumericDataId IS NULL 
INNER JOIN EstimatePeriod_tbl Ep ON Ep.estimatePeriodId = Ed.estimatePeriodId AND Ep.periodEndDate = n.preEstPEO AND Ep.periodTypeId = n.periodTypeId 
WHERE Ed.versionId IS NOT NULL IF OBJECT_ID('TEMPDB..#Gr1_tbl') IS NOT NULL DROP TABLE #Gr1_tbl 
SELECT * INTO #Gr1_tbl FROM #Gr_tbl Gr WHERE EXISTS ( SELECT a.companyId, a.researchContributorId, a.curVerId, a.curEffDate, a.minPEO, a.preEstPEO, MAX(a.preEffDate) AS maxPreEffDate, a.periodEndDate, 
	a.periodTypeId  FROM #Gr_tbl a  WHERE a.companyId = Gr.companyId  AND a.researchContributorId = Gr.researchContributorId  AND a.curVerId = Gr.curVerId  AND a.minPEO = Gr.minPEO  AND a.preEstPEO = Gr.preEstPEO  AND a.periodEndDate = Gr.periodEndDate  AND a.periodTypeId = Gr.periodTypeId  
GROUP BY a.companyId, a.researchContributorId, a.curVerId, a.curEffDate, a.minPEO, a.preEstPEO, a.periodEndDate, a.periodTypeId  HAVING MAX(a.preEffDate) = Gr.preEffDate ) 

SELECT DISTINCT a.companyId, Co.companyName, a.researchContributorId, Rc.contributorShortName, a.curVerId, a.curEffDate,
 a.minPEO AS curPeriodEndDate, a.preVerId, a.preEffDate, CASE Ep.periodTypeId WHEN 1 THEN 'FY: ' + CAST(Ep.fiscalYear AS VARCHAR) WHEN 2 THEN 'Q' + CAST(Ep.fiscalQuarter AS VARCHAR) + ': ' + CAST(Ep.fiscalYear AS VARCHAR) WHEN 10 THEN 'S' + CASE Ep.fiscalQuarter WHEN 2 THEN '1' + ': ' + CAST(Ep.fiscalYear AS VARCHAR) WHEN 4 THEN '2' + ': ' + CAST(Ep.fiscalYear AS VARCHAR) ELSE 'NA' END ELSE 'NA' END AS [prePeriod], a.periodEndDate AS prePeriodEndDate, doneAtIST = MAX(e.doneAtIST),a.periodTypeId ,count (distinct EdNd.dataitemid),
 '22371' AS Keyprocessstream
FROM #Gr1_tbl a 
INNER JOIN comparisonData.dbo.Company_tbl Co (NOLOCK) ON Co.companyId = a.CompanyId 
INNER JOIN EstimateDetail_tbl cont (NOLOCK) ON Cont.companyId = a.CompanyId  and a.curVerId = cont.versionid
INNER JOIN EstimateDetailNumericData_tbl EdNd ON EdNd.estimatedetailid = cont.estimatedetailid
INNER JOIN comparisonData.dbo.ResearchContributor_tbl Rc (NOLOCK) ON Rc.researchContributorId = a.researchContributorId 
INNER JOIN EstimatePeriod_tbl Ep ON ep.estimatePeriodId = a.estimatePeriodId 
INNER JOIN #eDataVf_tbl e (NOLOCK) ON e.versionId = a.curVerId AND e.companyId = a.companyId AND e.researchContributorId = a.researchContributorId 
where  EdNd.ParentEstimateDetailNumericDataID IS NULL
GROUP BY a.companyId, Co.companyName, a.researchContributorId, Rc.contributorShortName, a.curVerId, a.curEffDate, a.minPEO, a.preVerId, a.preEffDate, Ep.periodTypeId, Ep.fiscalYear, Ep.fiscalQuarter, a.periodEndDate, a.periodTypeId 
ORDER BY 1, 3 
--</endDQ>
----------------------------------------------------------------------------------------------------------------------------------------------------
