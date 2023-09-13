
Use Estimates
declare @frdate as datetime,@todate as datetime
set @frdate='2023-01-31 00:00:00.000'
set @todate='2023-08-30 23:59:59.999'

IF OBJECT_ID('TEMPDB..#tempEA') IS NOT NULL DROP TABLE #tempEA  CREATE TABLE #tempEA (Est_dataid int,Act_dataid int); INSERT INTO #tempEA VALUES  
(21642,100186),(600258,600311),(600264,600317),(600257,600310),(600254,600307),(602763,602770),(602841,602848),(105315,105321),(22503,105125),(600259,600312)

if OBJECT_ID('tempdb..#est') is not null drop table #est
select distinct ed.versionId,ed.companyId,PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataitemid,dataitem=dbo.DataItemName_fn(ednd.dataItemId),
ednd.dataItemValue,ednd.currencyid,ednd.unitsId,ed.parentFlag,ed.tradingItemId,ed.accountingStandardId,ed.effectiveDate
into #est from EstimateDetail_tbl ed
inner join EstimateDetailNumericData_tbl ednd on ednd.estimateDetailId=ed.estimateDetailId
where ednd.dataItemId in (21642,600258,600264,600257,600254,602763,602841,105315,22503,600259)
and ed.effectiveDate>=@frdate and ed.effectivedate<=@todate and ed.versionId is not null

--select * from #est


if OBJECT_ID('tempdb..#act') is not null drop table #act
select distinct ed.versionId,ed.companyId,PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataitemid,dataitem=dbo.DataItemName_fn(ednd.dataItemId),
ednd.dataItemValue,ednd.currencyid,ednd.unitsId,ed.parentFlag,ed.tradingItemId,ed.accountingStandardId,ed.effectiveDate into #act from EstimateDetail_tbl ed
inner join EstimateDetailNumericData_tbl ednd on ednd.estimateDetailId=ed.estimateDetailId
where ednd.dataItemId in (100186,600311,600317,600310,600307,602770,602848,105321,105125,600312)
and ed.effectiveDate>=@frdate and ed.effectivedate<=@todate  and ed.versionId is not null

--select * from #act

if OBJECT_ID('tempdb..#comments') is not null drop table #comments
SELECT DISTINCT cc.dataItemId,cc.companyId,cc.consensusComment,PEO=dbo.formatPeriodId_fn(cc.estimatePeriodId),cc.parentFlag,cc.accountingStandardId,ea.Act_dataid INTO #comments 
FROM Estimates.[dbo].[ConsensusComment_tbl] cc
INNER JOIN #tempEA ea ON ea.Est_dataid=cc.dataItemId
WHERE cc.toDate>GETDATE()  ----effectiveDate>=@frdate and effectivedate<=@todate and
AND cc.dataItemId in (21642,600258,600264,600257,600254,602763,602841,105315,22503,600259)

--select * from #comments

-----------Estimates Data Comparison--------------

select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,cd.consensusComment,b.dataitem,b.dataItemValue,cc.consensusComment,a.effectiveDate from #est a 
inner join #est b on b.versionId=a.versionId and b.companyId=a.companyId and b.parentFlag=a.parentFlag
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
LEFT JOIN #comments cc ON cc.companyId=b.companyId and cc.parentFlag=b.parentFlag and cc.PEO=b.PEO and cc.dataItemId=b.dataItemId
LEFT JOIN #comments cd ON cd.companyId=a.companyId and cd.parentFlag=a.parentFlag and cd.PEO=a.PEO and cd.dataItemId=a.dataItemId
where a.dataItemId=21642 and b.dataItemId in (600254,600257,600258,600264,600259) and b.peo=a.peo and a.dataItemValue=b.dataItemValue 
and a.currencyId=b.currencyId and a.unitsId=b.unitsId


select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,cd.consensusComment,b.dataitem,b.dataItemValue,cc.consensusComment,a.effectiveDate from #est a 
inner join #est b on b.versionId=a.versionId and b.companyId=a.companyId and b.parentFlag=a.parentFlag 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
LEFT JOIN #comments cc ON cc.companyId=b.companyId and cc.parentFlag=b.parentFlag and cc.PEO=b.PEO and cc.dataItemId=b.dataItemId
LEFT JOIN #comments cd ON cd.companyId=a.companyId and cd.parentFlag=a.parentFlag and cd.PEO=a.PEO and cd.dataItemId=a.dataItemId
where a.dataItemId=600258 and b.dataItemId=600257 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId


select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,cd.consensusComment,b.dataitem,b.dataItemValue,cc.consensusComment,a.effectiveDate from #est a 
inner join #est b on b.versionId=a.versionId and b.companyId=a.companyId and b.parentFlag=a.parentFlag 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
LEFT JOIN #comments cc ON cc.companyId=b.companyId and cc.parentFlag=b.parentFlag and cc.PEO=b.PEO and cc.dataItemId=b.dataItemId
LEFT JOIN #comments cd ON cd.companyId=a.companyId and cd.parentFlag=a.parentFlag and cd.PEO=a.PEO and cd.dataItemId=a.dataItemId
where a.dataItemId=600264 and b.dataItemId=600254 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId


select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,cd.consensusComment,b.dataitem,b.dataItemValue,cc.consensusComment,a.effectiveDate from #est a 
inner join #est b on b.versionId=a.versionId and b.companyId=a.companyId and b.parentFlag=a.parentFlag 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
LEFT JOIN #comments cc ON cc.companyId=b.companyId and cc.parentFlag=b.parentFlag and cc.PEO=b.PEO and cc.dataItemId=b.dataItemId
LEFT JOIN #comments cd ON cd.companyId=a.companyId and cd.parentFlag=a.parentFlag and cd.PEO=a.PEO and cd.dataItemId=a.dataItemId
where a.dataItemId=602763 and b.dataItemId=105315 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId


select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,cd.consensusComment,b.dataitem,b.dataItemValue,cc.consensusComment,a.effectiveDate from #est a 
inner join #est b on b.versionId=a.versionId and b.companyId=a.companyId and b.parentFlag=a.parentFlag 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
LEFT JOIN #comments cc ON cc.companyId=b.companyId and cc.parentFlag=b.parentFlag and cc.PEO=b.PEO and cc.dataItemId=b.dataItemId
LEFT JOIN #comments cd ON cd.companyId=a.companyId and cd.parentFlag=a.parentFlag and cd.PEO=a.PEO and cd.dataItemId=a.dataItemId
where a.dataItemId=602841 and b.dataItemId=22503 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

-----------Actual Data Comparison--------------

select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,cd.consensusComment,b.dataitem,b.dataItemValue,cc.consensusComment,a.effectiveDate from #act a 
inner join #act b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and b.versionId=a.versionId 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
LEFT JOIN #comments cc ON cc.companyId=b.companyId and cc.parentFlag=b.parentFlag and cc.PEO=b.PEO and cc.Act_dataid=b.dataItemId
LEFT JOIN #comments cd ON cd.companyId=a.companyId and cd.parentFlag=a.parentFlag and cd.PEO=a.PEO and cd.Act_dataid=a.dataItemId
where a.dataItemId=100186 and b.dataItemId in (600307,600310,600311,600317,600312) and b.peo=a.peo and a.dataItemValue=b.dataItemValue 
and a.currencyId=b.currencyId and a.unitsId=b.unitsId


select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,cd.consensusComment,b.dataitem,b.dataItemValue,cc.consensusComment,a.effectiveDate from #act a 
inner join #act b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and b.versionId=a.versionId  
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
LEFT JOIN #comments cc ON cc.companyId=b.companyId and cc.parentFlag=b.parentFlag and cc.PEO=b.PEO and cc.Act_dataid=b.dataItemId
LEFT JOIN #comments cd ON cd.companyId=a.companyId and cd.parentFlag=a.parentFlag and cd.PEO=a.PEO and cd.Act_dataid=a.dataItemId
where a.dataItemId=600311 and b.dataItemId=600310 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,cd.consensusComment,b.dataitem,b.dataItemValue,cc.consensusComment,a.effectiveDate from #act a 
inner join #act b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and b.versionId=a.versionId  
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
LEFT JOIN #comments cc ON cc.companyId=b.companyId and cc.parentFlag=b.parentFlag and cc.PEO=b.PEO and cc.Act_dataid=b.dataItemId
LEFT JOIN #comments cd ON cd.companyId=a.companyId and cd.parentFlag=a.parentFlag and cd.PEO=a.PEO and cd.Act_dataid=a.dataItemId
where a.dataItemId=600317 and b.dataItemId=600307 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId

select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,cd.consensusComment,b.dataitem,b.dataItemValue,cc.consensusComment,a.effectiveDate from #act a 
inner join #act b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and b.versionId=a.versionId 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
LEFT JOIN #comments cc ON cc.companyId=b.companyId and cc.parentFlag=b.parentFlag and cc.PEO=b.PEO and cc.Act_dataid=b.dataItemId
LEFT JOIN #comments cd ON cd.companyId=a.companyId and cd.parentFlag=a.parentFlag and cd.PEO=a.PEO and cd.Act_dataid=a.dataItemId
where a.dataItemId=602770 and b.dataItemId=105321 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId


select distinct a.versionId,a.companyId,a.PEO,a.dataitem,a.dataItemValue,cd.consensusComment,b.dataitem,b.dataItemValue,cc.consensusComment,a.effectiveDate from #act a 
inner join #act b on b.companyId=a.companyId and b.parentFlag=a.parentFlag and b.versionId=a.versionId 
and ISNULL(b.tradingitemid,-1)=ISNULL(a.tradingitemid,-1) and ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
LEFT JOIN #comments cc ON cc.companyId=b.companyId and cc.parentFlag=b.parentFlag and cc.PEO=b.PEO and cc.Act_dataid=b.dataItemId
LEFT JOIN #comments cd ON cd.companyId=a.companyId and cd.parentFlag=a.parentFlag and cd.PEO=a.PEO and cd.Act_dataid=a.dataItemId
where a.dataItemId=602848 and b.dataItemId=105125 and b.peo=a.peo and a.dataItemValue=b.dataItemValue and a.currencyId=b.currencyId and a.unitsId=b.unitsId
