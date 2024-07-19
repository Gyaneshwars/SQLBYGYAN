
USE Estimates
DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2023-08-25 00:00:00.000'
SET @todate='2023-12-31 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#Event') IS NOT NULL DROP TABLE #Event
SELECT DISTINCT e.researchcontributorid,e.companyid,e.versionid,e.tradingItemId,e.eventtypeid,et.eventtypename INTO #Event 
FROM Estimates.dbo.Event_tbl e (NOLOCK)
INNER JOIN Estimates.dbo.EventType_tbl et (NOLOCK) ON  et.eventtypeid=e.eventtypeid
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw ct (NOLOCK) ON ct.collectionEntityId = e.versionid
WHERE e.eventtypeid IS NOT NULL AND e.versionid IS NOT NULL
AND ct.endDate >=@frdate AND ct.endDate<=@todate

--SELECT * FROM #Event

IF Object_Id('TempDb..#checks ') IS NOT NULL DROP TABLE #checks
SELECT DISTINCT cp.versionId,cp.companyId,cp.researchContributorId,c.ChecklogicID,c.Checkdescription,DM.dataitemname,b.eventTypeName,b.eventTypeId,
ert.errorResolutionDescription,er.errorResolutionDateTime INTO #checks FROM Estimates.dbo.CheckParameters_tbl CP (NOLOCK)
INNER JOIN #Event b (NOLOCK) ON b.researchContributorId=cp.researchContributorId AND b.versionId=cp.versionId AND b.companyId=cp.companyId
INNER JOIN Estimates.dbo.CheckBatch_tbl CB (NOLOCK) ON CP.checkBatchId = CB.checkBatchId
INNER JOIN Estimates.dbo.Error_tbl E (NOLOCK) ON E.checkBatchId = CB.checkBatchId
INNER JOIN Estimates.dbo.Check_tbl C (NOLOCK) ON E.checkId = C.checkId
INNER JOIN Estimates.dbo.ErrorToEstimateDataValue_tbl EEDV (NOLOCK) ON EEDV.errorId = E.errorId
INNER JOIN Estimates.dbo.dataitemmaster_vw DM (NOLOCK) ON DM.dataitemID = EEDV.dataitemID
LEFT JOIN Estimates.dbo.ErrorToResolution_tbl ER (NOLOCK) ON ER.errorId = E.errorId
LEFT JOIN Estimates.dbo.ErrorResolutionType_tbl ERT (NOLOCK) ON ER.errorResolutionTypeId = ERT.errorResolutionTypeId
WHERE ert.errorResolutionDescription IS NOT NULL


--SELECT * FROM #checks


SELECT DISTINCT * FROM #checks