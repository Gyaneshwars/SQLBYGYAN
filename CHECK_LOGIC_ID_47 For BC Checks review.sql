USE Estimates
DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2023-07-16 00:00:00.000'
SET @todate='2023-08-13 23:59:59.999'
IF OBJECT_ID('tempdb..#Check47') IS NOT NULL DROP TABLE #Check47
SELECT DISTINCT CP.feedfileid,CP.versionid,CP.CompanyId,CP.parentflag,CP.tradingitemId,CP.researchcontributorId,CP.AccountingStandardID,c.checkLogicId,c.checkDescription,
DM.dataitemname,EEDV.value,PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),FI.periodEndDate,ERT.Errorresolutiondescription AS Errordescription,
CB.starttime AS Checkbatch_starttime,CB.endtime AS Checkbatch_endtime,E.errordatetime,ct.collectionstageId,ED.effectiveDate
INTO #Check47 FROM CheckParameters_tbl CP (NOLOCK)
INNER JOIN CheckBatch_tbl CB (NOLOCK) ON CP.checkBatchId = CB.checkBatchId
INNER JOIN Error_tbl E (NOLOCK) ON E.checkBatchId = CB.checkBatchId  
INNER JOIN Check_tbl C (NOLOCK) ON E.checkId = C.checkId
INNER JOIN ErrorToEstimateDataValue_tbl EEDV (NOLOCK) ON EEDV.errorId = E.errorId 
INNER JOIN dataitemmaster_vw DM (NOLOCK) ON DM.dataitemID = EEDV.dataitemID  
INNER JOIN Estimates.[dbo].estimatedetail_tbl ED (NOLOCK) ON EEDV.estimatedetailID = ED.estimatedetailID AND ED.feedFileId=cp.feedFileId AND ED.companyId = cp.companyId
INNER JOIN Estimates.[dbo].estimatePeriod_tbl FI (NOLOCK) ON FI.estimatePeriodId = ED.estimatePeriodId 
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw ct (NOLOCK) ON ct.relatedCompanyId=ED.companyId
LEFT JOIN WorkflowArchive_Estimates.dbo.collectionentitytoprocess_tbl CEtoP (NOLOCK) ON cp.versionid = CEtoP.collectionentityid                                                          
LEFT JOIN WorkflowArchive_Estimates.dbo.collectionentitytocollectionstage_tbl CEtoCS (NOLOCK) ON CEtoP.collectionentitytoprocessid = CEtoCS.collectionentitytoprocessid --and CEtoCS.collectionStageId = 24 
--LEFT JOIN Estimates.[dbo].estimatedetail_tbl ED (NOLOCK) ON EEDV.estimatedetailID = ED.estimatedetailID
--LEFT JOIN Estimates.[dbo].estimatePeriod_tbl FI (NOLOCK) ON FI.estimatePeriodId = ED.estimatePeriodId                   
LEFT JOIN ErrorToResolution_tbl ER (NOLOCK) ON ER.errorId = E.errorId   
LEFT JOIN ErrorResolutionType_tbl ERT (NOLOCK) ON ER.errorResolutionTypeId = ERT.errorResolutionTypeId
WHERE ED.effectiveDate>=@frDate AND ED.effectiveDate<=@toDate
AND c.checkLogicId IN (47)  
AND DM.dataItemID IN (21642)
AND cp.feedFileId IS NOT NULL 
AND cp.versionId IS NULL
AND cp.researchContributorId > 0
AND ct.collectionstageId IN (85)



SELECT * FROM #Check47