
Use Estimates
if object_id('tempdb..#Act') is not null drop table #Act
select distinct ed.companyid,ed.versionid,ednd.dataitemid,di.headlineItemFlag,dataitem=dbo.DataItemName_fn(ednd.dataitemid),
peo=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataItemValue,ed.parentflag,ed.tradingitemid,
ed.accountingStandardId,ednd.currencyId,ednd.unitsId,ed.effectivedate into #Act from estimatedetail_tbl ed (nolock)
inner join estimatedetailnumericdata_tbl ednd (nolock) on ednd.estimatedetailid=ed.estimatedetailid
inner join DataItemMaster_vw di (nolock) on di.dataItemID=ednd.dataItemId
where di.dataCollectionTypeID=56 and ed.effectivedate>=getdate()-180 and ed.versionId is not null
--select * from #Act

if object_id('tempdb..#hl') is not null drop table #hl select distinct * into #hl from #act where headlineItemFlag=1 --select * from #hl
if object_id('tempdb..#nhl') is not null drop table #nhl select distinct * into #nhl from #act where headlineItemFlag=0 --select * from #nhl

if object_id('tempdb..#hlcur') is not null drop table #hlcur select distinct companyid,max(effectivedate) currdate into #hlcur from #hl group by companyid --select * from #hlcur
if object_id('tempdb..#hlcur1') is not null drop table #hlcur1 select distinct a.* into #hlcur1 from #hl a 
inner join #hlcur b on b.companyId=a.companyId where b.currdate=a.effectiveDate --select * from #hlcur1
if object_id('tempdb..#hlprev') is not null drop table #hlprev select distinct a.companyid,max(a.effectivedate) prevdate into #hlprev from #hl a 
inner join #hlcur b on b.companyId=a.companyId where b.currdate>a.effectiveDate group by a.companyid --select * from #hlprev
if object_id('tempdb..#hlprev1') is not null drop table #hlprev1 select distinct a.* into #hlprev1 from #hl a
inner join #hlprev b on b.companyId=a.companyId where b.prevdate=a.effectiveDate --select * from #hlprev1

if object_id('tempdb..#nhlcur') is not null drop table #nhlcur select distinct companyid,max(effectivedate) currdate into #nhlcur from #nhl group by companyid --select * from #nhlcur
if object_id('tempdb..#nhlcur1') is not null drop table #nhlcur1 select distinct a.* into #nhlcur1 from #nhl a 
inner join #nhlcur b on b.companyId=a.companyId where b.currdate=a.effectiveDate --select * from #nhlcur1
if object_id('tempdb..#nhlprev') is not null drop table #nhlprev select distinct a.companyid,max(a.effectivedate) prevdate into #nhlprev from #nhl a 
inner join #nhlcur b on b.companyId=a.companyId where b.currdate>a.effectiveDate group by a.companyid --select * from #nhlprev
if object_id('tempdb..#nhlprev1') is not null drop table #nhlprev1 select distinct a.* into #nhlprev1 from #nhl a
inner join #nhlprev b on b.companyId=a.companyId where b.prevdate=a.effectiveDate --select * from #nhlprev1

if object_id('tempdb..#hlfinal') is not null drop table #hlfinal
select distinct a.companyid,a.versionId cur_vid,a.dataitem cur_dim,a.peo cur_peo,a.dataItemValue cur_value,a.effectiveDate cur_date,
b.versionId prev_vid,b.dataitem prev_dim,b.peo prev_peo,b.dataItemValue prev_value,b.effectiveDate prev_date,
a.parentFlag,a.tradingItemId,a.accountingStandardId into #hlfinal from #hlcur1 a
inner join #hlprev1 b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and isnull(b.tradingItemId,-1)=isnull(a.tradingItemId,-1) 
and isnull(b.accountingstandardid,255)=isnull(a.accountingstandardid,255)
where b.dataitem=a.dataitem and b.dataItemValue=a.dataItemValue and b.currencyId=a.currencyId and b.unitsId=a.unitsId

if object_id('tempdb..#nhlfinal') is not null drop table #nhlfinal
select distinct a.companyid,a.versionId cur_vid,a.dataitem cur_dim,a.peo cur_peo,a.dataItemValue cur_value,a.effectiveDate cur_date,
b.versionId prev_vid,b.dataitem prev_dim,b.peo prev_peo,b.dataItemValue prev_value,b.effectiveDate prev_date,
a.parentFlag,a.tradingItemId,a.accountingStandardId into #nhlfinal from #nhlcur1 a
inner join #nhlprev1 b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and isnull(b.tradingItemId,-1)=isnull(a.tradingItemId,-1) 
and isnull(b.accountingstandardid,255)=isnull(a.accountingstandardid,255)
where b.dataitem=a.dataitem and b.dataItemValue=a.dataItemValue and b.currencyId=a.currencyId and b.unitsId=a.unitsId

select distinct * from #hlfinal a
inner join #nhlfinal b on b.companyId=a.companyId