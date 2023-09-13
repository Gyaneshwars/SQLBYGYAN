USE Estimates

DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2020-12-01 00:00:00.000'
SET @toDate = '2020-12-06 23:59:59.999'
IF OBJECT_ID('TEMPDB..#guid') IS NOT NULL DROP TABLE #guid
select ED.versionId,ED.companyId,ed.tradingitemid,ED.parentFlag,ED.accountingStandardId,ed.effectiveDate,ed.researchContributorId,
EDND.dataItemId,DM.dataitemName as CurrDataitemname,dbo.formatPeriodId_fn(ed.estimatePeriodId)as apeo,ed.estimatePeriodId,
ednd.dataitemvalue,
EDND.currencyId,EDND.unitsId into #guid from EstimateDetailNumericData_tbl EDND
Inner Join DataItemMaster_vw DM (Nolock)On DM.dataitemID = EDND.dataitemID 
Inner Join EstimateDetail_tbl ED (Nolock)On ED.estimateDetailId = EDND.estimateDetailId
Inner Join estimatePeriod_tbl FI (Nolock) on FI.estimatePeriodId = ED.estimatePeriodId

where  ed.effectiveDate > = @frDate AND ed.effectiveDate < = @toDate

and ed.versionid > 111 and ed.companyId >11  and DM.dataCollectionTypeID = 54



IF OBJECT_ID('TEMPDB..#guid1') IS NOT NULL DROP TABLE #guid1
select DISTINCT ED.versionId,ED.companyId,ed.tradingitemid,ED.parentFlag,ED.accountingStandardId,ed.effectiveDate,ed.researchContributorId
into #guid1 from EstimateDetailNumericData_tbl EDND
Inner Join DataItemMaster_vw DM (Nolock)On DM.dataitemID = EDND.dataitemID 
Inner Join EstimateDetail_tbl ED (Nolock)On ED.estimateDetailId = EDND.estimateDetailId
Inner Join estimatePeriod_tbl FI (Nolock) on FI.estimatePeriodId = ED.estimatePeriodId
inner join #guid ct on ct.versionId = ED.versionId and ct.companyId = ed.companyId
where ed.versionid > 111 and ed.companyId >11 and ednd.audittype <> 2109



select DISTINCT a.versionId,a.companyid,a.effectiveDate,a.researchContributorId from #guid a
WHERE NOT EXISTS (SELECT 1  FROM #guid1 F WHERE a.VersionID=F.VersionID)



select * from DataItemMaster_vw
