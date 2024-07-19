
Use Estimatesfeed
SELECT DISTINCT fd.feedid,f.researchContributorId,f.feedname,fp.companyId,fp.tradingItemId,fp.ciqId,DM.dataItemID,DM.dataItemName,fp.feedDataPointId,
fd.feedDataPointName,fdf.feedDataPointValue,fp.startDate,fp.endDate,fdmc.feedDataPointMapId,fdmc.comment,fdmc.userId,dpvg.dataPointValueGroupName FROM Estimatesfeed.dbo.FeedDataPointMap_tbl fp(NOLOCK)
LEFT JOIN Estimates.dbo.DataItemMaster_vw dm(NOLOCK) ON  dm.dataItemID = fp.ciqId
INNER JOIN Estimatesfeed.dbo.feeddatapoint_tbl fd(NOLOCK) ON  fp.feedDataPointId = fd.feedDataPointId
INNER JOIN Estimatesfeed.dbo.Feed_tbl f(NOLOCK) ON  f.feedId = fd.feedId
INNER JOIN Estimatesfeed.[dbo].[feedData_tbl] fdf (NOLOCK) ON fdf.feedDataPointId=fd.feedDataPointId
full JOIN estimatesfeed.dbo.FeedDataPointMapComment_tbl fdmc ON  fp.feedDataPointMapId = fdmc.feedDataPointMapId
left join ComparisonData.dbo.tradingitem_tbl cti(nolock) ON fp.tradingItemId = cti.tradingitemid
inner join Estimatesfeed.dbo.DataPointValueGroup_tbl dpvg on dpvg.dataPointValueGroupId=fp.dataPointValueGroupId
WHERE fp.endDate >GETDATE() AND fp.dataPointValueGroupId = 24 --No Mapping
AND fp.companyId IS NOT NULL
--and DM.dataItemID in (21643)
--AND f.researchContributorId IN (3)
--and fp.companyId
and (fd.feedDataPointName like '%Y0%' OR fd.feedDataPointName like '%LRY')
and fd.feedDataPointName not like '%Q%'
and cti.activeFlag = 1
and fp.companyId=9286191

