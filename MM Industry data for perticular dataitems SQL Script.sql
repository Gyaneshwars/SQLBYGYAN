--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNYANESHWAR SRAVANE
USE Estimates

DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2023-01-01 00:00:00.000'
SET @todate='2024-02-29 23:59:59.999'

IF OBJECT_ID('tempdb..#MM') IS NOT NULL DROP TABLE #MM
SELECT DISTINCT ed.versionid,ed.feedFileId,ed.companyid,cs.companyName,edn.dataItemId,dataitemname=dbo.DataItemName_fn(edn.dataitemid),Contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),
ed.effectiveDate AS FilingDate,cs.businessDescription,cs.industryName
INTO #MM FROM Estimates.[dbo].EstimateDetail_tbl ed (NOLOCK)
INNER JOIN Estimates.[dbo].[EstFull_vw] edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
INNER JOIN Estimates.[dbo].DATAITEMMASTER_VW dm (NOLOCK) ON edn.dataItemId=dm.dataItemId
INNER JOIN CompanyMaster.[dbo].[CompanySearch_vw] cs (NOLOCK) ON cs.companyId=ed.companyId
WHERE
ed.effectiveDate>=@frdate AND ed.effectiveDate<=@todate
AND edn.dataItemId IN (600266,600269)
ORDER BY ed.effectiveDate



SELECT DISTINCT versionId,companyId,companyName,Contributor,FilingDate,dataItemId,dataitemname,industryName FROM #MM 
WHERE industryName LIKE '%Metals & Mining%'
ORDER BY versionId,FilingDate




