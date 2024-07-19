USE Estimates

DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2020-11-01 00:00:00.000'
SET @toDate = '2020-12-06 23:59:59.999'
IF OBJECT_ID('TEMPDB..#getDocWfVf_tbl') IS NOT NULL DROP TABLE #getDocWfVf_tbl 
SELECT  CTv.collectionEntityId AS entityId, CTv.relatedCompanyId AS companyId, 
CTv.PriorityID, MAX(CTv.endDate) AS doneAtIST INTO #getDocWfVf_tbl FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CTv (NOLOCK) 
WHERE CTv.collectionProcessId IN (64) AND CTv.collectionEntityTypeId IN (9) AND CTv.collectionStageId IN (2,122) AND CTv.collectionStageStatusId = 4  and CTv.relatedCompanyId > 11
AND CTv.endDate > = @frDate AND CTv.endDate < = @toDate GROUP BY CTv.collectionEntityId, CTv.PriorityID, CTv.relatedCompanyId 


IF OBJECT_ID('TEMPDB..#guid1') IS NOT NULL DROP TABLE #guid1
select ED.versionId,ED.companyId,ed.tradingitemid,ED.parentFlag,ED.accountingStandardId,ed.effectiveDate,ed.researchContributorId,
EDND.dataItemId,DM.dataitemName as CurrDataitemname,dbo.formatPeriodId_fn(ed.estimatePeriodId)as apeo,ed.estimatePeriodId,ednd.dataitemvalue,
EDND.currencyId,EDND.unitsId into #guid1 from EstimateDetailNumericData_tbl EDND
Inner Join DataItemMaster_vw DM (Nolock)On DM.dataitemID = EDND.dataitemID 
Inner Join EstimateDetail_tbl ED (Nolock)On ED.estimateDetailId = EDND.estimateDetailId
Inner Join estimatePeriod_tbl FI (Nolock) on FI.estimatePeriodId = ED.estimatePeriodId
inner join #getDocWfVf_tbl ct on ct.entityId = ED.versionId and ct.companyId = ed.companyId
inner join [ComparisonData]..[Company_vw] st on st.companyid = ed.companyid
inner  join [ComparisonData].[dbo].[SubType_tbl] sb on  sb.subTypeId = st.PrimarySubTypeId

where ed.versionid > 111 and ed.companyId >11 and EDND.dataItemId = 21645
and sb.subTypeId in (7012000,7021000,7013000,7121000,7113000,7212000,7131000)



IF OBJECT_ID('TEMPDB..#Prevtp') IS NOT NULL DROP TABLE #Prevtp
select DISTINCT ec.versionId PrVersionid,ec.companyId,ec.effectiveDate as preeffetivedate,ec.researchContributorId
into #Prevtp
from #guid1 c
inner join EstimateDetail_tbl ec on c.companyid = ec.companyid and ec.researchContributorId = c.researchContributorId
inner join EstimateDetailNumericData_tbl ednd on ec.estimateDetailId = ednd.estimateDetailId
and ec.effectiveDate > (getdate()-90)
and ec.effectiveDate < c.effectiveDate
and ISNULL (ec.tradingitemid,-1) = ISNULL (c.tradingitemid,-1) and ec.versionId > 11
where EDND.dataItemId in (21646,21647)


IF OBJECT_ID('TEMPDB..#Pdoc') IS NOT NULL DROP TABLE #Pdoc
select companyId,researchContributorId,  max(preeffetivedate) as PreDocDate into #Pdoc from #Prevtp
group by companyId,  researchContributorId

IF OBJECT_ID('TEMPDB..#Pdocs') IS NOT NULL DROP TABLE #Pdocs
select ED.versionId,ED.companyId,ed.tradingitemid,ED.parentFlag,ED.accountingStandardId,ed.effectiveDate,ed.researchContributorId,
EDND.dataItemId,DM.dataitemName as PreDataitemname,dbo.formatPeriodId_fn(ed.estimatePeriodId)as peo,ed.estimatePeriodId,ednd.dataitemvalue,
EDND.currencyId,EDND.unitsId into #Pdocs from EstimateDetailNumericData_tbl EDND
Inner Join DataItemMaster_vw DM (Nolock)On DM.dataitemID = EDND.dataitemID 
Inner Join EstimateDetail_tbl ED (Nolock)On ED.estimateDetailId = EDND.estimateDetailId
Inner Join estimatePeriod_tbl FI (Nolock) on FI.estimatePeriodId = ED.estimatePeriodId
inner join #Pdoc ct on ct.companyId = ed.companyId and ed.researchContributorId = ct.researchContributorId and ed.effectiveDate = ct.PreDocDate
where ed.versionid > 111 and ed.companyId >11 and EDND.dataItemId in (21646,21647)

---#Pdocs--previous data ----#guid1--- current

IF OBJECT_ID('TEMPDB..#final') IS NOT NULL DROP TABLE #final
select ED.versionId,ED.companyId,ed.tradingitemid,ED.parentFlag,ED.accountingStandardId,ed.effectiveDate,ed.researchContributorId,
ed.dataItemId,ed.CurrDataitemname,apeo,ed.dataitemvalue, ed.currencyId,ed.unitsId,pds.versionId as PreVID,pds.dataItemId as PreDataItemId, PreDataitemname,pds.peo

into #final from #guid1 ed
inner join #Pdocs pds on pds.companyId = ed.companyId and ed.researchContributorId = pds.researchContributorId
and ED.parentFlag = pds.parentFlag and pds.accountingStandardId = ED.accountingStandardId and apeo = peo
and pds.dataitemvalue = ed.dataitemvalue and ed.dataItemId <> pds.dataItemId

select * from #final
