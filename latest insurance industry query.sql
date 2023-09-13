USE Estimates
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2023-01-01 00:00:00.000'
SET @toDate = '2023-07-30 23:59:59.999'
IF OBJECT_ID('tempdb..#InsuranceIndustryData_Temp') IS NOT NULL DROP TABLE #InsuranceIndustryData_Temp
SELECT DISTINCT ed.companyid,ed.versionid,ednd.dataitemid,dataItemName=dbo.DataItemName_fn(ednd.dataitemid),cim.CompanyName,
PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataItemValue,CTI.IndustryName,ed.parentFlag,ed.accountingStandardId,
ed.effectivedate INTO #InsuranceIndustryData_Temp FROM Estimates.dbo.estimatedetail_tbl ed (NOLOCK)
INNER JOIN Estimates.dbo.estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
INNER JOIN Estimates.dbo.DataItemMaster_vw di (NOLOCK) ON di.dataItemID=ednd.dataItemId
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
LEFT JOIN CompanyMaster.dbo.CompanyInfoMaster cim (NOLOCK) ON ed.companyid = cim.CIQCompanyId
LEFT JOIN Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cim.IndustryID = CTI.IndustryId
WHERE CT.endDate > = @frDate and CT.endDate <= @toDate
AND ednd.dataItemId IN (600317,600311,600307,100186,600310)   ---Included (Revenue Actual(100186) & Net Premiums Written Actual(600310)) & ParentFlag =1 means Parent data
AND ed.versionId IS NOT NULL
AND CT.collectionstageStatusId IN (4)

----Due to query getting more time for execution below consensus script has been removed

--IF OBJECT_ID('tempdb..#ConsesData_Temp') IS NOT NULL DROP TABLE #ConsesData_Temp
--SELECT ec.*,cc.dataItemId as estDID,cc.consensusComment,ecnd.dataItemValue as consValue,ecnd.dataItemId as consDID,ecnd.effectiveDate as eff,edr.relDataItemId as actualdataitemID
--INTO #ConsesData_Temp FROM Estimates.dbo.EstimateConsensus_tbl ec 
--INNER JOIN [Estimates].[dbo].[ConsensusComment_tbl] cc ON ec.companyId=cc.companyId and ec.estimatePeriodId=cc.estimatePeriodId and ec.parentFlag=cc.parentFlag
--and ec.accountingStandardId=cc.accountingStandardId
--INNER JOIN Estimates.dbo.EstimateConsensusNumericData_tbl ecnd ON ecnd.estimateConsensusId=ec.estimateConsensusId
--INNER JOIN Estimates.[dbo].[EstimateDataItemRel_tbl] edr ON edr.dataItemId =ecnd.dataItemId and edr.estimateDataItemRelTypeId =27
--WHERE EXISTS (SELECT DISTINCT companyid FROM #InsuranceIndustryData_Temp WHERE ecnd.effectiveDate<=effectiveDate)
--AND ToDate>getdate()


IF OBJECT_ID('tempdb..#Final_Temp') IS NOT NULL DROP TABLE #Final_Temp
SELECT DISTINCT T1.dataItemName,T1.PEO,T1.dataItemValue,T1.versionid,T2.companyId,T1.companyName,T1.IndustryName,T2.effectivedate,T1.parentFlag,T1.dataitemid,T1.accountingStandardId
INTO #Final_Temp FROM #InsuranceIndustryData_Temp T1 INNER JOIN #InsuranceIndustryData_Temp T2 
ON T1.versionid = T2.versionid AND T1.companyId = T2.companyId
WHERE T1.dataitemid <> T2.dataitemid
AND T1.dataItemValue = T2.dataItemValue
AND T1.PEO = T2.PEO
AND T1.parentFlag=T2.parentFlag
AND T1.accountingStandardId = T2.accountingStandardId


---This result includes two and more dataitem values duplicated VersionId + CompanyId

SELECT dataItemName,PEO,dataItemValue,versionid,companyId,companyName,IndustryName,effectivedate,parentFlag,dataitemid as Act_dataitemid,accountingStandardId FROM #Final_Temp
ORDER BY versionid,companyId,effectivedate,PEO,parentFlag
