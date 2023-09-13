Use Estimates
IF OBJECT_ID ('TEMPDB..#OGVERSIONS') IS NOT NULL DROP TABLE #OGVERSIONS
SELECT DISTINCT ed.versionId,ed.companyId,contributorname=dbo.researchcontributorname_fn(ed.researchcontributorid),ednd.dataitemid,
dataitemname=dbo.dataitemname_fn(ednd.dataitemid),ednd.dataitemvalue,peo = dbo.formatPeriodId_fn(ed.estimatePeriodId),
ednd.currencyid,ednd.unitsid,ed.parentFlag,ed.tradingItemId,ed.accountingStandardId,ed.effectivedate,ct.enddate AS CollectionDate,ct.PriorityID,p.priorityName,
usr.employeeNumber INTO #OGVERSIONS 
FROM            Estimates.[dbo].estimatedetail_tbl ed (NOLOCK)
INNER JOIN      Estimates.[dbo].Estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
INNER JOIN      WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct (NOLOCK) ON ed.companyId = ct.relatedCompanyId AND ct.collectionEntityId = ed.versionId
INNER JOIN      Estimates.[dbo].[EstimateCompany_tbl] ec (NOLOCK) ON ec.companyId = ct.relatedCompanyId
INNER JOIN      Estimates.[dbo].[EstimatePeriod_tbl] ep (NOLOCK) ON ep.estimatePeriodid = ed.estimatePeriodid AND ct.relatedCompanyId = ep.companyId
INNER JOIN      WorkflowArchive_Estimates.[dbo].[Priority_tbl] p ON p.priorityId = ct.PriorityID
INNER JOIN      CTAdminRepTables.dbo.user_tbl usr (NOLOCK) ON ct.userId = usr.userid
WHERE           ct.collectionStageId IN (2,122,184) AND relatedcompanyid IS NOT NULL
AND             ednd.dataItemId in (115409,115435,115474,115396,115461)
AND             ct.collectionProcessId = 1062 AND ct.collectionStageStatusId IN (4) -- AND ct.PriorityID IN (1,3,9,10,14,15,20,30,33,35)
AND             ct.enddate BETWEEN GETDATE() -7 AND  GETDATE() +1 AND ct.userId NOT IN (907321171)
--AND             ct.relatedCompanyId in (592007691,45511302,878688)  ----Provide the client focused companies and market moving companies id's here


SELECT TOP 1 percent * FROM #OGVERSIONS ORDER BY NEWID()



--SELECT * FROM Estimates.[dbo].[EstimatePeriod_tbl]
--WHERE ednd.dataItemId in (21645,21649,21650) AND ednd.audittypeid not in (2059) and ednd.toDate>getdate() and ed.effectivedate>='2020-12-01'

--SELECT * FROM Estimates.[dbo].[EstimateDetail_tbl]
--SELECT * FROM Estimates.[dbo].[EstimateDetailIdData_tbl]
--SELECT * FROM Estimates.[dbo].[EstimateDetailNumericData_tbl]
--SELECT * FROM Estimates.[dbo].[EstimateDetailTextData_tbl]
--SELECT * FROM Estimates.[dbo].[EstimateDataItemRel_tbl]
--SELECT * FROM Estimates.[dbo].[DataItemAttribute_tbl]
--SELECT * FROM Estimates.[dbo].[DataItemGroup_tbl]
--SELECT * FROM Estimates.[dbo].[EstimateCompany_tbl]