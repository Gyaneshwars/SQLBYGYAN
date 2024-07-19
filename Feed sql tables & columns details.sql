

SELECT top 10 * FROM Estimatesfeed.dbo.FeedDataPointMap_tbl ---companyid,ciqid(dataitemid)
SELECT top 10 * FROM Estimatesfeed.[dbo].[FeedDataPoint_tbl]
SELECT top 10 * FROM Estimatesfeed.[dbo].[feedData_tbl]
SELECT top 10 * FROM Estimatesfeed.[dbo].[DataPointValueToGroup_tbl] ----dataPointvalue(dataitemid)
SELECT top 10 * FROM Estimatesfeed.[dbo].[FeedDataPointGroup_tbl]

SELECT fd.*,fdpm.ciqId FROM Estimatesfeed.[dbo].[feedData_tbl] fd
INNER JOIN Estimatesfeed.dbo.FeedDataPointMap_tbl fdpm ON fdpm.feedDataPointId=fd.feedDataPointId
WHERE feedFileId IN (66964)----FeeddataPointvalue,feedDataPointId,feedFileId ----estimates feed data
AND fdpm.ciqId IN (21634,21635,21650,21649)
SELECT * FROM Estimatesfeed.[dbo].[FeedDataPoint_tbl] ----feedDataPointName,feedId,feedDataPointId

SELECT * FROM Estimatesfeed.dbo.Feed_tbl-----researchContributorId,feedid,feedname

SELECT * FROM Estimatesfeed.[dbo].[FeedDataPointGroup_tbl]

SELECT * FROM Estimatesfeed.[dbo].[FeedCoverage_tbl]

SELECT * FROM Estimatesfeed.[dbo].[FeedFile_tbl] ---feedFileId,filingDate

SELECT * FROM Estimatesfeed.[dbo].[FeedProcessEntity_tbl]

SELECT * FROM Estimatesfeed.[dbo].[FeedData_vw]

SELECT * FROM Estimatesfeed.[dbo].[FeedProcessEntityDetail_tbl]