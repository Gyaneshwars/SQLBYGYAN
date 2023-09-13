USE Estimates
IF OBJECT_ID('tempdb..#DatainVersionid_Temp') IS NOT NULL DROP TABLE #DatainVersionid_Temp
SELECT DISTINCT ed.versionid,ep.companyId,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),DM.dataItemID,
dm.dataItemName,PEO=dbo.formatPeriodId_fn(ed.estimateperiodid),edn.dataItemValue INTO #DatainVersionid_Temp FROM [Estimates].[dbo].[DataItemMaster_vw] DM
INNER JOIN Estimates.[dbo].EstimateDetailNumericData_tbl EDN ON edn.dataitemid=DM.dataitemid
LEFT JOIN Estimates.[dbo].EstimateDetail_tbl ED ON ed.estimateDetailId=EDN.estimateDetailId
LEFT JOIN Estimates.[dbo].[EstimatePeriod_tbl] ep ON ed.companyId = ep.companyId
WHERE ed.versionId IN (1931129342)
ORDER BY DM.dataItemID

SELECT * FROM #DatainVersionid_Temp ORDER BY dataItemID,PEO

---------------------------------------------------------------------------------------

USE Estimates
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2023-06-23 00:00:00.000' -----23 to 7th
SET @toDate = '2023-07-07 23:59:59.999'------08th to 22nd 
IF OBJECT_ID('tempdb..#DatainVersionid_Temp') IS NOT NULL DROP TABLE #DatainVersionid_Temp
SELECT DISTINCT  ed.versionid,ed.companyid,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid), ed.effectiveDate, edn.dataItemId,
dm.dataItemName,PEO=dbo.formatPeriodId_fn(ed.estimateperiodid), edn.dataItemValue INTO #DatainVersionid_Temp
FROM Estimates.[dbo].EstimateDetail_tbl ed 
INNER JOIN estimates.dbo.EstimateDetailNumericData_tbl edn ON ed.estimateDetailId = edn.estimateDetailId
LEFT JOIN [Estimates].[dbo].[DataItemMaster_vw] dm ON edn.dataitemid=dm.dataitemid
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw CT ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
WHERE CT.endDate > = @frDate and CT.endDate <= @toDate
AND edn.dataItemId IN (600263)

SELECT * FROM #DatainVersionid_Temp ORDER BY dataItemName DESC


