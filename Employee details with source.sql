-----SQL Query Developer---Gnaneshwar Sravane
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-10-01 00:00:00.000' ----Provide From Date Here
SET @toDate = '2023-10-30 23:59:59.999' ----Provide To Date Here

IF OBJECT_ID('tempdb..#EmpData_Temp') IS NOT NULL DROP TABLE #EmpData_Temp
SELECT DISTINCT ed.versionid ,ed.companyid,ctl.companyName,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.effectiveDate AS FilingDate,edn.dataItemId,
dataitemname=dbo.DataItemName_fn(edn.dataitemid),PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),edn.dataItemValue,UT.employeeNumber AS EmpId,UT.firstName + ' '+ UT.lastName AS EmpName,
ed.parentFlag,ed.accountingStandardId,CT.startDate,CT.endDate,css.collectionStageStatusName,DATEDIFF(MINUTE,CT.startDate,CT.endDate) AS TimeSpent,vf.Description,v.formatID 
INTO #EmpData_Temp FROM Estimates.[dbo].[EstimateDetail_tbl] ed (NOLOCK)
INNER JOIN Estimates.[dbo].[EstFull_vw] edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
INNER JOIN WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN ComparisonData.[dbo].[Currency_tbl] crnc (NOLOCK) ON edn.currencyId = crnc.currencyId
INNER JOIN ComparisonData.[dbo].[Company_tbl] ctl (NOLOCK) ON ed.companyid = ctl.companyId
INNER JOIN CTAdminRepTables.[dbo].[user_tbl] UT (NOLOCK) ON UT.userId=CT.userId
INNER JOIN DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId=ed.versionid
INNER JOIN DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID=v.formatID
INNER JOIN Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=CT.collectionstageStatusId
WHERE CT.endDate>= @frDate AND CT.endDate<=@toDate
AND UT.employeeNumber IN ('415043','914040','716010','411016','415028','916001') -----Provide employee Id here in single quotes
AND ed.versionId IS NOT NULL
AND CT.collectionstageStatusId IN (1,2,3,4,5)
AND UT.employeeNumber NOT IN ('000266','000387','000EF2','000EF3','00000A')
AND v.formatID IN (7,63,64,83,157,177,176)
ORDER BY ed.effectiveDate




SELECT DISTINCT EmpName,EmpId,versionId,companyId,companyName,contributor,FilingDate,startDate,endDate,collectionStageStatusName,TimeSpent AS TimeSpent_In_Minutes,
Description AS SourceName FROM #EmpData_Temp WHERE formatID IN (7,63,64,83,157,177,176)

