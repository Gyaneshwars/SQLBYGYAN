USE Estimates
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2023-07-01 00:00:00.000'
SET @toDate = '2023-07-25 23:59:59.999'
IF OBJECT_ID('tempdb..#InsuranceIndustryData_Temp') IS NOT NULL DROP TABLE #InsuranceIndustryData_Temp
SELECT DISTINCT ed.companyid,ed.versionid,ednd.dataitemid,dataItemName=dbo.DataItemName_fn(ednd.dataitemid),cim.CompanyName,
PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataItemValue,CTI.IndustryName,cct.consensusComment,ecn.dataItemValue as consensus,ecn.toDate,ep.periodTypeId,
ep.periodEndDate,ed.effectiveDate as Est_effectivedate,ecn.effectiveDate as Cons_effectivedate,edr1.relDataItemId
INTO #InsuranceIndustryData_Temp FROM estimatedetail_tbl ed (NOLOCK)
INNER JOIN estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
--INNER JOIN DataItemMaster_vw di (NOLOCK) ON di.dataItemID=ednd.dataItemId
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK) ON isnull(ed.versionid,ed.feedfileid) = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN CompanyMaster.dbo.CompanyInfoMaster cim (NOLOCK) ON ed.companyid = cim.CIQCompanyId
left JOIN [Estimates].[dbo].[ConsensusComment_tbl] cct (NOLOCK) ON ednd.dataitemid = cct.dataItemId
left JOIN Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cim.IndustryID = CTI.IndustryId
INNER JOIN Estimates.dbo.EstimateConsensus_tbl ec on ec.companyId = ed.companyid AND ec.estimatePeriodId = ed.estimatePeriodId and ec.parentFlag=ed.parentFlag
and ISNULL(ec.tradingitemid,-1)=ISNULL(ed.tradingitemid,-1) and ISNULL(ec.accountingstandardid,255)=ISNULL(ed.accountingstandardid,255)
INNER JOIN Estimates.dbo.EstimateConsensusNumericData_tbl ecn (NOLOCK) ON ec.estimateConsensusId = ecn.estimateConsensusId
INNER JOIN Estimates.[dbo].[EstimateDataItemRel_tbl] edr (NOLOCK) ON edr.dataItemId = ednd.dataItemId and edr.relDataItemId=ecn.dataItemId and edr.estimateDataItemRelTypeId=4
INNER JOIN Estimates.[dbo].[EstimateDataItemRel_tbl] edr1 (NOLOCK) ON edr1.dataItemId = ednd.dataItemId and edr1.estimateDataItemRelTypeId=1
INNER JOIN estimates.dbo.EstimatePeriod_tbl ep on ec.estimatePeriodId = ep.estimatePeriodId
WHERE CT.endDate > = @frDate and CT.endDate <= @toDate and 
ednd.dataItemId=21642 --IN (600317,600311,600307,600310,100186)
and ecn.toDate >GETDATE()
and ednd.toDate>GETDATE()
and ed.companyId=29618 --and ed.effectiveDate>GETDATE()-30
--GROUP BY ed.companyid,ed.versionid,ednd.dataitemid,di.headlineItemFlag,cim.CompanyName,ednd.dataItemValue,CTI.IndustryName,cct.consensusComment,
--ecn.dataItemValue,ecn.toDate,ep.periodTypeId,ep.periodEndDate,ed.effectiveDate,ed.estimatePeriodId,edr1.relDataItemId
 --select * from #InsuranceIndustryData_Temp 

 select top 10 * from [EstimateDataItemReltype_tbl]


 --actual data temp
 --companyid,companyname,peo, dataitemid,dataitemanme,dataitemvalue,effectivedate



IF OBJECT_ID('tempdb..#Final_Temp') IS NOT NULL DROP TABLE #Final_Temp
SELECT DISTINCT T1.dataItemName,T1.PEO,T1.dataItemValue,T1.versionid,T2.companyId,T1.companyName,T1.IndustryName,T1.consensus,T1.consensusComment,T2.Est_effectivedate,
T1.periodEndDate,T1.Cons_effectivedate,T1.dataItemId
INTO #Final_Temp FROM #InsuranceIndustryData_Temp T1 INNER JOIN #InsuranceIndustryData_Temp T2 
ON T1.versionid = T2.versionid AND T1.companyId = T2.companyId
WHERE T1.dataitemid <> T2.dataitemid
AND T1.dataItemValue = T2.dataItemValue
AND T1.PEO = T2.PEO
AND T1.Cons_effectivedate<=T2.Est_effectivedate


---This result includes two and three dataitem values duplicated VersionId + CompanyId

SELECT dataItemName,dataItemId,PEO,dataItemValue,versionid,companyId,companyName,IndustryName,consensus,consensusComment,Est_effectivedate,periodEndDate,Cons_effectivedate FROM #Final_Temp
ORDER BY versionid,companyId,PEO








