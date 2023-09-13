Use Estimates
IF OBJECT_ID ('TEMPDB..#OGVERSIONS') IS NOT NULL DROP TABLE #OGVERSIONS
SELECT DISTINCT ed.versionId,ed.companyId,contributorname=dbo.researchcontributorname_fn(ed.researchcontributorid),ednd.dataitemid,
dataitemname=dbo.dataitemname_fn(ednd.dataitemid),ednd.dataitemvalue,peo = dbo.formatPeriodId_fn(ed.estimatePeriodId),
ednd.currencyid,ednd.unitsid,ed.parentFlag,ed.tradingItemId,ed.accountingStandardId,usr.employeeNumber,ed.effectivedate,ct.enddate AS CollectionDate,ct.PriorityID,p.priorityName
INTO #OGVERSIONS
FROM            Estimates.[dbo].estimatedetail_tbl ed (NOLOCK)
INNER JOIN      Estimates.[dbo].Estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
INNER JOIN      WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct (NOLOCK) ON ed.companyId = ct.relatedCompanyId AND ct.collectionEntityId = ed.versionId
INNER JOIN      Estimates.[dbo].[EstimateCompany_tbl] ec (NOLOCK) ON ec.companyId = ct.relatedCompanyId
INNER JOIN      Estimates.[dbo].[EstimatePeriod_tbl] ep (NOLOCK) ON ep.estimatePeriodid = ed.estimatePeriodid AND ct.relatedCompanyId = ep.companyId
INNER JOIN      WorkflowArchive_Estimates.[dbo].[Priority_tbl] p ON p.priorityId = ct.PriorityID
INNER JOIN      CTAdminRepTables.dbo.user_tbl usr (NOLOCK) ON ct.userId = usr.userid
WHERE           ct.collectionStageId IN (2,122,184) AND relatedcompanyid IS NOT NULL
AND             ednd.dataItemId in (115409,115435,115474,115396,115461)
AND             ct.collectionProcessId = 1062 AND ct.collectionStageStatusId IN (4)
AND             ct.enddate BETWEEN GETDATE() -7 AND  GETDATE() +1 AND ct.userId NOT IN (907321171)



SELECT TOP 1 percent * FROM #OGVERSIONS ORDER BY NEWID()