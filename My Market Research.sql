--Use estimates DECLARE @frDate DATETIME, @tooDate DATETIME 
--SET @frDate = '2020-01-01 06:00:00.000' -- Give From Date here 
--SET @tooDate = '2021-07-30 05:59:59.000'-- Give To Date here
SELECT ed.versionId,ed.companyid,ep.fiscalYear,ed.tradingItemId, ed.researchContributorId,
contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.effectiveDate, edn.toDate, 
dataitem=dbo.DataItemName_fn(edn.dataItemId), edn.dataItemId, edn.dataItemValue 
FROM estimates.dbo.EstimateDetail_tbl ed (NOLOCK)
INNER JOIN estimates.dbo.EstimateDetailNumericData_tbl edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId 
INNER JOIN estimates.dbo.EstimatePeriod_tbl ep (NOLOCK) ON ed.estimatePeriodId = ep.estimatePeriodId AND ed.companyId = ep.companyId 
INNER JOIN estimates.dbo.DataItemMaster_vw dim (NOLOCK) ON edn.dataItemId = dim.dataItemID 
WHERE ep.companyId = 21719 
--AND ed.researchContributorId = 1065
AND ed.versionId>1000
AND edn.dataItemId IN (21640) 
AND dim.dataCollectionTypeID = 54
--AND effectiveDate >= @frDate  AND effectiveDate <= @tooDate 
AND ep.periodTypeId = 1 
AND toDate = '06/06/2079'
ORDER BY effectiveDate DESC