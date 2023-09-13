
Use Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-01-31 00:00:00.000'  -- give from date here
SET @toDate = '2023-08-30 23:59:59.999'  -- give to date here

if OBJECT_ID('tempdb..#est') is not null drop table #est
select distinct ed.versionId,ed.companyId,PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataitemid,dataitem=dbo.DataItemName_fn(ednd.dataItemId),ed.estimatePeriodId,
ednd.dataItemValue,ednd.currencyid,ednd.unitsId,ed.parentFlag,ed.tradingItemId,ed.accountingStandardId,ed.effectiveDate into #est from EstimateDetail_tbl ed
inner join EstimateDetailNumericData_tbl ednd on ednd.estimateDetailId=ed.estimateDetailId
where ednd.dataItemId in (21642,600258,600264,600257,600254,602763,602841,105315,22503,600259)
and ed.effectiveDate>=@frDate and ed.effectiveDate<=@toDate and ed.versionId is not null

--select * from #est

if OBJECT_ID('tempdb..#act') is not null drop table #act
select distinct ed.versionId,ed.companyId,PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataitemid,dataitem=dbo.DataItemName_fn(ednd.dataItemId),ed.estimatePeriodId,
ednd.dataItemValue,ednd.currencyid,ednd.unitsId,ed.parentFlag,ed.tradingItemId,ed.accountingStandardId,ed.effectiveDate into #act from EstimateDetail_tbl ed
inner join EstimateDetailNumericData_tbl ednd on ednd.estimateDetailId=ed.estimateDetailId
where ednd.dataItemId in (100186,600311,600317,600310,600307,602770,602848,105321,105125,600312)
and ed.effectiveDate>=@frDate and ed.effectiveDate<=@toDate and ed.versionId is not null

--select * from #act

-----------Estimates Data Comparison--------------

----Revenue Vs Other Dataitem
select distinct a.versionId,a.companyId,a.PEO,a.dataItemId,a.dataitem,a.dataItemValue,b.dataItemId,b.dataitem,b.dataItemValue,a.effectiveDate from #est a 
inner join #est b on b.versionId=a.versionId and b.companyId=a.companyId and b.parentFlag=a.parentFlag 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
where a.dataItemId=21642 and b.dataItemId in (600254,600257,600258,600264,600259) and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

----Gross Premiums Written Estimate Vs Net Premiums Written Estimate
select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,b.dataitem,b.dataItemValue,a.effectiveDate from #est a 
inner join #est b on b.versionId=a.versionId and b.companyId=a.companyId and b.parentFlag=a.parentFlag 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
where a.dataItemId=600258 and b.dataItemId=600257 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

----Gross Premiums Earned Estimate Vs Net Premiums Earned Estimate
select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,b.dataitem,b.dataItemValue,a.effectiveDate from #est a 
inner join #est b on b.versionId=a.versionId and b.companyId=a.companyId and b.parentFlag=a.parentFlag 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
where a.dataItemId=600264 and b.dataItemId=600254 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

----Book Value Per Share excl. AOCI Estimate Vs Net Asset Value / Share Estimate
select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,b.dataitem,b.dataItemValue,a.effectiveDate from #est a 
inner join #est b on b.versionId=a.versionId and b.companyId=a.companyId and b.parentFlag=a.parentFlag 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
where a.dataItemId=602763 and b.dataItemId=105315 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

----Embedded Value Estimate Vs Net Asset Value Estimate
select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,b.dataitem,b.dataItemValue,a.effectiveDate from #est a 
inner join #est b on b.versionId=a.versionId and b.companyId=a.companyId and b.parentFlag=a.parentFlag 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
where a.dataItemId=602841 and b.dataItemId=22503 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId



-----------Actual Data Comparison--------------

----Revenue Actual Vs Other data items
select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,b.dataitem,b.dataItemValue,a.effectiveDate from #act a 
inner join #act b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and b.versionId=a.versionId 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
where a.dataItemId=100186 and b.dataItemId in (600307,600310,600311,600317,600312) and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

----Gross Premiums Written Actual Vs Net Premiums Written Actual
select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,b.dataitem,b.dataItemValue,a.effectiveDate from #act a 
inner join #act b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and b.versionId=a.versionId  
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
where a.dataItemId=600311 and b.dataItemId=600310 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

----Gross Premiums Earned Actual Vs Net Premiums Earned Actual
select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,b.dataitem,b.dataItemValue,a.effectiveDate from #act a 
inner join #act b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and b.versionId=a.versionId  
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
where a.dataItemId=600317 and b.dataItemId=600307 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

----Book Value Per Share excl. AOCI Actual Vs Net Asset Value / Share Actual
select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,b.dataitem,b.dataItemValue,a.effectiveDate from #act a 
inner join #act b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and b.versionId=a.versionId 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
where a.dataItemId=602770 and b.dataItemId=105321 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

----Embedded Value Actual Vs Net Asset Value Actual
select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,b.dataitem,b.dataItemValue,a.effectiveDate from #act a 
inner join #act b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and b.versionId=a.versionId 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
where a.dataItemId=602848 and b.dataItemId=105125 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

