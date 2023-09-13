USE Estimates
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2023-06-01 00:00:00.000'
SET @toDate = '2023-07-20 23:59:59.999'
IF OBJECT_ID('tempdb..#InsuranceIndustryData_Temp') IS NOT NULL DROP TABLE #InsuranceIndustryData_Temp
SELECT DISTINCT ed.companyid,ed.versionid,ednd.dataitemid,dataItemName=dbo.DataItemName_fn(ednd.dataitemid),cim.CompanyName,ed.parentFlag,
PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataItemValue,CTI.IndustryName,cct.consensusComment,Cons_dataItemName=dbo.DataItemName_fn(ecnt.dataItemId),
ecnt.dataItemId as cons_dataitemid,ecnt.dataItemValue as consensus,MAX(ecnt.effectiveDate) as Cons_effectivedate,
ed.effectivedate INTO #InsuranceIndustryData_Temp FROM estimatedetail_tbl ed (NOLOCK)
INNER JOIN estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
INNER JOIN DataItemMaster_vw di (NOLOCK) ON di.dataItemID=ednd.dataItemId
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK) ON isnull(ed.versionid,ed.feedfileid) = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
LEFT JOIN CompanyMaster.dbo.CompanyInfoMaster cim (NOLOCK) ON ed.companyid = cim.CIQCompanyId
LEFT JOIN [Estimates].[dbo].[ConsensusComment_tbl] cct (NOLOCK) ON cct.companyId=ed.companyid AND ednd.dataitemid = cct.dataItemId AND cct.estimatePeriodId =ed.estimatePeriodId AND cct.parentFlag=ed.parentFlag
LEFT JOIN Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cim.IndustryID = CTI.IndustryId
LEFT JOIN Estimates.dbo.EstimateConsensus_tbl ec on ec.companyId = ed.companyid AND ec.estimatePeriodId = ed.estimatePeriodId AND ec.parentFlag = ed.parentFlag
LEFT JOIN Estimates.dbo.EstimateConsensusNumericData_tbl ecnt (NOLOCK) ON ec.estimateConsensusId = ecnt.estimateConsensusId
INNER JOIN Estimates.[dbo].[EstimateDataItemRel_tbl] edr (NOLOCK) ON edr.relDataItemId = ednd.dataItemId AND edr.dataItemId=ecnt.dataItemId AND edr.estimateDataItemRelTypeId=27
WHERE CT.endDate > = @frDate AND CT.endDate <= @toDate
AND ednd.dataItemId IN (600317,600311,600307) ----include any Non per share actual dataitemId
AND CT.collectionstageStatusId IN (4)
GROUP BY ed.companyid,ed.versionid,ednd.dataitemid,ednd.dataitemid,cim.CompanyName,ed.estimatePeriodId,ednd.dataItemValue,CTI.IndustryName,cct.consensusComment,ecnt.dataItemId,
ecnt.dataItemValue,ed.effectivedate,ed.parentFlag
HAVING MAX(ecnt.effectiveDate)<ed.effectivedate



IF OBJECT_ID('tempdb..#Maxconseffdate_Temp') IS NOT NULL DROP TABLE #Maxconseffdate_Temp
SELECT DISTINCT companyid,dataitemid,PEO,MAX(Cons_effectivedate) AS maxconseffdate INTO #Maxconseffdate_Temp FROM #InsuranceIndustryData_Temp
GROUP BY companyid,dataitemid,PEO



IF OBJECT_ID('tempdb..#semifinal_Temp') IS NOT NULL DROP TABLE #semifinal_Temp
SELECT a.* INTO #semifinal_Temp from #InsuranceIndustryData_Temp a INNER JOIN #Maxconseffdate_Temp b on a.companyid = b.companyid AND a.dataitemid = b.dataitemid AND a.PEO=b.PEO
WHERE a.Cons_effectivedate=b.maxconseffdate

IF OBJECT_ID('tempdb..#Final_Temp') IS NOT NULL DROP TABLE #Final_Temp
SELECT DISTINCT T1.dataItemName,T1.PEO,T1.dataItemValue,T1.versionid,T2.companyId,T1.companyName,T1.IndustryName,T1.consensus,T1.consensusComment,T2.effectivedate
INTO #Final_Temp FROM #semifinal_Temp T1 INNER JOIN #semifinal_Temp T2 
ON T1.versionid = T2.versionid AND T1.companyId = T2.companyId
WHERE T1.dataitemid <> T2.dataitemid
AND T1.dataItemValue = T2.dataItemValue
AND T1.PEO = T2.PEO



SELECT * FROM #Final_Temp ORDER BY companyId,versionid,effectivedate










--IF OBJECT_ID('tempdb..#ConsesData_Temp') IS NOT NULL DROP TABLE #ConsesData_Temp
--SELECT ec.*,cc.dataItemId as estDID,cc.consensusComment,ecnd.dataItemValue as consValue,ecnd.dataItemId as consDID,ecnd.effectiveDate as eff,edr.relDataItemId as actualdataitemID
--INTO #ConsesData_Temp FROM Estimates.dbo.EstimateConsensus_tbl ec 
--INNER JOIN [Estimates].[dbo].[ConsensusComment_tbl] cc ON ec.companyId=cc.companyId and ec.estimatePeriodId=cc.estimatePeriodId and ec.parentFlag=cc.parentFlag
--and ec.accountingStandardId=cc.accountingStandardId
--INNER JOIN Estimates.dbo.EstimateConsensusNumericData_tbl ecnd ON ecnd.estimateConsensusId=ec.estimateConsensusId
--INNER JOIN Estimates.[dbo].[EstimateDataItemRel_tbl] edr ON edr.dataItemId =ecnd.dataItemId and edr.estimateDataItemRelTypeId =27
--WHERE EXISTS (SELECT DISTINCT companyid FROM #InsuranceIndustryData_Temp WHERE ecnd.effectiveDate<=effectiveDate)





