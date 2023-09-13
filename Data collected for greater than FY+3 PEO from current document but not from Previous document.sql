
Use Estimates
if object_id('tempdb..#e') is not null drop table #e
select distinct ed.researchcontributorid,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.companyid,ed.versionid,
ednd.dataitemid,dataitem=dbo.DataItemName_fn(ednd.dataitemid),peo=dbo.formatPeriodId_fn(ed.estimateperiodid),ednd.dataitemvalue,ednd.audittypeid,
ed.parentflag,ed.tradingitemid,ed.accountingstandardid,ednd.currencyid,ednd.unitsId,ed.effectivedate into #e from EstimateDetail_tbl ed (nolock)
inner join estimatedetailnumericdata_tbl ednd (nolock) on ednd.estimatedetailid=ed.estimatedetailid
inner join estimateperiod_tbl ep (nolock) on ep.estimateperiodid=ed.estimatePeriodId and ep.companyId=ed.companyId and ep.periodTypeId=1
inner join DataItemMaster_vw di (nolock) on di.dataItemID=ednd.dataItemId
where di.dataCollectionTypeID=54 and ed.effectiveDate>=GETDATE()-30 and ed.versionId is not null and ednd.auditTypeId not in (2058,2059)
--select * from #e
if object_id('tempdb..#peocount') is not null drop table #peocount
select distinct researchcontributorid,companyid,versionid,dataitemid,count(peo) PEOCount into #peocount from #e 
group by researchcontributorid,companyid,versionid,dataitemid
--select * from #peocount
if object_id('tempdb..#e1') is not null drop table #e1 
select distinct a.*,b.PEOCount into #e1 from #e a
inner join #peocount b on b.researchContributorId=a.researchContributorId and b.companyId=a.companyId and b.versionId=a.versionId
where b.dataItemId=a.dataItemId
--select * from #e1
if object_id('tempdb..#cur') is not null drop table #cur
select distinct researchcontributorid,companyid,max(effectivedate) currdate into #cur from #e1
group by researchcontributorid,companyid
--select * from #cur
if object_id('tempdb..#cur1') is not null drop table #cur1
select distinct a.* into #cur1 from #e1 a
inner join #cur b on b.researchContributorId=a.researchContributorId and b.companyId=a.companyId
where b.currdate=a.effectiveDate and a.PEOCount>3
--select * from #cur1
if object_id('tempdb..#prev') is not null drop table #prev
select distinct a.researchcontributorid,a.companyid,max(a.effectivedate) prevdate into #prev from #e1 a
inner join #cur b on b.researchContributorId=a.researchContributorId and b.companyId=a.companyId
where b.currdate>a.effectiveDate
group by a.researchcontributorid,a.companyid
--select * from #prev
if object_id('tempdb..#prev1') is not null drop table #prev1
select distinct a.* into #prev1 from #e1 a
inner join #prev b on b.researchContributorId=a.researchContributorId and b.companyId=a.companyId
where b.prevdate=a.effectiveDate and a.PEOCount<=3
--select * from #prev1

select distinct a.contributor,a.companyid,a.versionid CurVID,a.dataitem CurDIM,a.peocount CurPEOcount,a.effectivedate CurrDate,
b.versionid PrevVID,b.dataitem PrevDIM,b.peocount PrevPEOcount,b.effectivedate PrevDate from #cur1 a
inner join #prev1 b on b.researchContributorId=a.researchContributorId and b.companyId=a.companyId and b.parentFlag=a.parentFlag 
and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255) and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1)
where b.dataItemId=a.dataItemId and b.PEOCount<=3 and a.PEOCount>3