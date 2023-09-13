
Use Estimates
if object_id('tempdb..#e') is not null drop table #e
select distinct contributorname=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.companyid,ed.versionid,ednd.dataitemid,dataitemname=dbo.DataItemName_fn(ednd.dataitemid),
case ednd.dataitemid when 21635 then 'EPS' when 21647 then 'EBT' when 21650 then 'NI' when 21634 then 'EPS' when 21646 then 'EBT' when 21649 then 'NI' end dataitem,
peo=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataItemValue,ed.parentflag,ed.tradingitemid,
ed.accountingStandardId,ednd.currencyId,ednd.unitsId,ed.effectivedate into #e from estimatedetail_tbl ed (nolock)
inner join estimatedetailnumericdata_tbl ednd (nolock) on ednd.estimatedetailid=ed.estimatedetailid
where ednd.dataitemid in (21635,21650,21647,21634,21649,21646)and ed.effectivedate>=getdate()-90 and ednd.auditTypeId<>2059 and ed.versionId is not null
--select * from #e

if object_id('tempdb..#cur') is not null drop table #cur
select distinct contributorname,companyid,max(effectivedate) currdate  into #cur from #e
group by contributorname,companyid
--select * from #cur
if object_id('tempdb..#cur1') is not null drop table #cur1
select distinct a.* into #cur1 from #e a
inner join #cur c on c.contributorname=a.contributorname and c.companyId=a.companyId
where c.currdate=a.effectiveDate 
--select * from #cur1 order by 2,3
if object_id('tempdb..#prev') is not null drop table #prev
select distinct a.contributorname,a.companyid,max(a.effectivedate) prevdate  into #prev from #e a
inner join #cur b on b.contributorname=a.contributorname and b.companyId=a.companyId
where datediff(dd,b.currdate,a.effectiveDate)<=30
group by a.contributorname,a.companyid
--select * from #prev
if object_id('tempdb..#prev1') is not null drop table #prev1
select distinct a.* into #prev1 from #e a
inner join #prev c on c.contributorname=a.contributorname and c.companyId=a.companyId
where c.prevdate=a.effectiveDate
--select * from #prev1 order by 2,3

select distinct a.contributorname,a.companyId,a.versionId curversionid,a.dataitemname,a.peo,a.dataitemvalue,a.effectiveDate currdate,
b.versionId prevversionid,b.dataitemname,b.peo,b.dataitemvalue,b.effectiveDate prevdate from #cur1 a
inner join #prev1 b on b.contributorname=a.contributorname and b.companyId=a.companyId and b.parentflag=a.parentFlag 
and isnull(b.tradingitemid,-1)=isnull(a.tradingitemid,-1) and isnull(b.accountingstandardid,255)=isnull(a.accountingstandardid,255)
where b.dataitem=a.dataitem and b.dataitemname<>a.dataitemname and b.peo=a.peo and b.dataitemvalue=a.dataitemvalue and b.currencyId=a.currencyId and b.unitsId=a.unitsId
and b.versionId<>a.versionId
order by 1,2,3