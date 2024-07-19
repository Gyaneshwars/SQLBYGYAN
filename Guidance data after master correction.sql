
USE Estimates

DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-10-01 00:00:00.000'
SET @toDate = '2023-10-30 23:59:59.999'

IF OBJECT_ID('TEMPDB..#guidance') IS NOT NULL DROP TABLE #guidance
SELECT DISTINCT ED.versionId,ED.companyId,ed.tradingitemid,ED.parentFlag,ED.accountingStandardId,ed.effectiveDate AS FilingDate,ednd.auditTypeId,
EDND.lastModifiedUTCDateTime+'5:30' AS MCdonedate,EDND.dataItemId,DM.dataitemName,dbo.formatPeriodId_fn(ed.estimatePeriodId) AS PEO,ed.estimatePeriodId,
ecc.ChangeCategoryDescription,opt.Description,ednd.dataitemvalue,etdd.ChangeCapturedDateTimeUTC+'5:30' AS ChangeCapturedDateTimeUTC,
etdd.ChangeReceivedDateTimeUTC+'5:30' AS ChangeReceivedDateTimeUTC,etdd.InsertDateTimeUTC+'5:30' AS InsertDateTimeUTC,etdd.ReadyForPlatformDateTimeUTC+'5:30' AS ReadyForPlatformDateTimeUTC INTO #guidance FROM EstimateDetailNumericData_tbl EDND
INNER JOIN DataItemMaster_vw DM (NOLOCK) ON DM.dataitemID = EDND.dataitemID 
INNER JOIN EstimateDetail_tbl ED (NOLOCK) ON ED.estimateDetailId = EDND.estimateDetailId
INNER JOIN estimatePeriod_tbl FI (NOLOCK) ON FI.estimatePeriodId = ED.estimatePeriodId
INNER JOIN WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct (NOLOCK) ON ct.collectionEntityId = ISNULL(ed.versionid,ed.feedFileId) AND ct.relatedCompanyId=ed.companyId
INNER JOIN EstimateTimeliness.[dbo].[EstimateTimelinessDetail_tbl] etd (NOLOCK) ON etd.EntityId=ct.collectionEntityId AND etd.CompanyId=ed.companyId AND etd.EffectiveDate =ed.effectiveDate AND etd.EstimatePeriodId=ed.estimatePeriodId AND etd.ParentFlag=ed.parentFlag
INNER JOIN EstimateTimeliness.[dbo].[EstimateTimelinessDetailData_tbl] etdd (NOLOCK) ON etdd.EstimateTimelinessDetailId=etd.EstimateTimelinessDetailId AND etdd.DataItemid=ednd.dataItemId
INNER JOIN EstimateTimeliness.[dbo].[EstimateChangeCategory_tbl] ecc (NOLOCK) ON ecc.ChangeCategoryId=etdd.ChangeCategoryId
INNER JOIN EstimateTimeliness.[dbo].[OperationType_tbl] opt (NOLOCK) ON opt.OperationTypeId=etdd.OperationTypeId
WHERE ct.enddate >= @frDate AND ct.enddate <= @toDate
AND ed.versionid IS NOT NULL 
AND ed.companyId IS NOT NULL
AND DM.dataCollectionTypeID IN (62,70) 
AND ednd.auditTypeId IN (2057)


---SELECT * FROM #guidance


IF OBJECT_ID('TEMPDB..#final') IS NOT NULL DROP TABLE #final
SELECT DISTINCT versionId,companyId,FilingDate,dataitemName,PEO,dataitemvalue,MCdonedate,ChangeCategoryDescription,
LAG(ChangeCapturedDateTimeUTC) OVER(PARTITION BY versionId,companyId,FilingDate,dataitemName,PEO ORDER BY ChangeCapturedDateTimeUTC) AS collectionDate INTO #final FROM #guidance
WHERE ChangeCategoryDescription IN ('Estimate Insert', 'Estimate Update')

SELECT DISTINCT versionId,companyId,FilingDate,dataitemName,PEO,dataitemvalue,collectionDate,MCdonedate FROM #final 
WHERE ChangeCategoryDescription = 'Estimate Update' AND collectionDate IS NOT NULL





