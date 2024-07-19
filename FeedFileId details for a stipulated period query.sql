--- PYTHON & SQL ETL DEVELOPER-GNANESHWAR SRAVANE
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2021-02-01 00:00:00.000' ----Provide From Date Here
SET @toDate = '2021-02-28 23:59:59.999' ----Provide To Date Here 

IF OBJECT_ID('tempdb..#FeedfileId_Temp') IS NOT NULL DROP TABLE #FeedfileId_Temp
SELECT DISTINCT ed.feedFileId,ed.companyid,ctl.companyName,ed.researchcontributorid,researchcontributor=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.effectiveDate AS FilingDate,edn.dataItemId,
dataitemname=dbo.DataItemName_fn(edn.dataitemid),PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),edn.dataItemValue,edn.unitsId,utt.unitsType,edn.currencyId,crnc.currencyName,
CTI.IndustryId,CTI.IndustryName,stt.subTypeId,stt.subTypeValue,cm.Country
INTO #FeedfileId_Temp FROM Estimates.[dbo].[EstimateDetail_tbl] ed (NOLOCK)
LEFT JOIN Estimates.[dbo].[EstFull_vw] edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
LEFT JOIN WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT (NOLOCK) ON ed.feedFileId = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId AND CT.collectionEntityTypeId IN (51)
LEFT JOIN ComparisonData.[dbo].[Currency_tbl] crnc (NOLOCK) ON edn.currencyId = crnc.currencyId
LEFT JOIN ComparisonData.[dbo].[Company_tbl] ctl (NOLOCK) ON ed.companyid = ctl.companyId
LEFT JOIN Comparisondata.dbo.SubType_tbl stt (NOLOCK) ON stt.SubTypeId=ctl.PrimarySubTypeId
LEFT JOIN  CompanyMaster.[dbo].CompanyInfoMaster cm (NOLOCK) ON cm.CIQCompanyId=ed.companyid
INNER JOIN  Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cm.IndustryID = CTI.IndustryId
LEFT JOIN Estimates.[dbo].[Units_tbl] utt (NOLOCK) ON utt.unitsId=edn.unitsId
WHERE CT.endDate>= @frDate AND CT.endDate<=@toDate
AND ed.feedFileId IS NOT NULL
--AND ed.feedFileId IN (-2120562269,-2120471119)
AND ed.feedFileId<0
AND ed.researchcontributorid NOT IN (0)
ORDER BY ed.effectiveDate




SELECT DISTINCT feedFileId,companyId,companyName,researchcontributorid,researchcontributor,FilingDate,dataItemId,dataitemname,PEO,dataItemValue,unitsId,unitsType,currencyId,currencyName,
IndustryId,IndustryName,subTypeId,subTypeValue,Country
FROM #FeedfileId_Temp

