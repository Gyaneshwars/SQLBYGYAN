Use estimates DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2023-07-25 00:00:00.000' -- Give From Date here 
SET @toDate = '2023-08-30 23:59:59.999'-- Give To Date here
SELECT ed.versionId,ed.companyid,ed.tradingItemId, ed.researchContributorId,Ed.estimatePeriodId, ----,[PEO]=dbo.formatPeriodId_fn(Ed.estimatePeriodId)
contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.effectiveDate, ef.toDate,CT.enddate,
dataitem=dbo.DataItemName_fn(ef.dataItemId), ef.dataItemId, ef.dataItemValue 
FROM estimates.dbo.EstimateDetail_tbl ed (NOLOCK)
INNER JOIN estimates.dbo.EstimateDetailNumericData_tbl edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId 
INNER JOIN estimates.dbo.EstimatePeriod_tbl ep (NOLOCK) ON ed.estimatePeriodId = ep.estimatePeriodId AND ed.companyId = ep.companyId 
INNER JOIN estimates.dbo.EstFull_vw ef (NOLOCK) ON ef.estimateDetailId = ed.estimateDetailId
INNER JOIN estimates.dbo.DataItemMaster_vw dim (NOLOCK) ON ef.dataItemId = dim.dataItemID 
LEFT JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw CT ON ed.companyId = CT.relatedCompanyId

WHERE                                           --ep.companyId = 19049 
    ed.versionId IS NOT NULL
--AND ed.researchContributorId = 1065 
ef.dataItemId IN (21629)
---AND NOT EXISTS (select DISTINCT dataItemId from estimates.dbo.EstimateDetailNumericData_tbl WHERE dataItemId = 21640) 
--AND dim.dataCollectionTypeID = 64
AND CT.enddate >= @frDate  AND CT.enddate <= @toDate 
ORDER BY effectiveDate DESC


----select * from estimates.dbo.DataItemMaster_vw
----select DISTINCT dataItemID from estimates.dbo.DataItemMaster_vw WHERE dataItemID = 21640