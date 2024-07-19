--PYTHO,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frdate='2023-01-01 00:00:00.000'
SET @todate='2024-01-14 23:59:59.999'
USE Estimates
IF OBJECT_ID('TEMPDB..#Versioniddta') IS NOT NULL DROP TABLE #Versioniddta
SELECT DISTINCT ed.versionid,ed.feedfileid,ed.companyid,ed.researchcontributorid,ed.effectiveDate,ed.tradingItemId,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),
ed.accountingStandardId,edn.dataitemid,dataitemname=dbo.DataItemName_fn(edn.dataitemid),CTI.IndustryName AS Industry,CTI.IndustryId,edn.dataItemValue,edn.unitsId,u.unitsType,ed.parentFlag,PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ed.flavorTypeId
INTO #Versioniddta FROM EstimateDetail_tbl ED (NOLOCK)
INNER JOIN EstimatePeriod_tbl EP (NOLOCK) ON ED.estimatePeriodId = ep.estimatePeriodId
INNER JOIN Estimates.[dbo].[EstFull_vw] edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
INNER JOIN Estimates.[dbo].[Units_tbl] u (NOLOCK) ON u.unitsId=edn.unitsId
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw ct ON ed.versionId=ct.collectionEntityId AND ed.companyId=ct.relatedCompanyId
LEFT JOIN  CompanyMaster.[dbo].CompanyInfoMaster cm (NOLOCK) ON cm.CIQCompanyId=ed.companyid
LEFT JOIN  Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cm.IndustryID = CTI.IndustryId
WHERE ct.endDate>=@frdate AND ct.endDate<=@todate ---ed.versionid IN (1580025966,-2065955714)
AND CTI.IndustryId IN (210,157,73,54,57,123)
AND edn.dataitemid IN (600266,600265,600267,600269,600270)
AND edn.dataItemValue NOT IN ('0.0','0','0.00','0.000','0.0000')
--AND ed.researchcontributorid IN (2684)
ORDER BY ed.effectiveDate DESC

---SELECT * FROM #Versioniddta

--IF OBJECT_ID('TEMPDB..#Final') IS NOT NULL DROP TABLE #Final
--SELECT DISTINCT versionid,contributor,companyid,effectiveDate,Industry,IndustryId,unitsId,unitsType,COUNT(dataitemid) AS No_Of_DataPoints,CASE WHEN flavorTypeId IN (3,4) THEN COUNT(dataitemid) ELSE 0 END AS NonPeriodic,
--CASE WHEN flavorTypeId IN (1,2) THEN COUNT(dataitemid) ELSE 0 END AS Periodic INTO #Final FROM #Versioniddta
--GROUP BY versionid,companyid,contributor,effectiveDate,Industry,IndustryId,flavorTypeId,unitsId,unitsType,contributor

--SELECT DISTINCT versionid,companyid,contributor,effectiveDate,Industry,IndustryId,SUM(No_Of_DataPoints) AS TotalDataPoints,SUM(NonPeriodic) AS NonPeriodics,SUM(Periodic) AS Periodics FROM #Final
--GROUP BY versionid,companyid,contributor,effectiveDate,Industry,IndustryId,contributor
--ORDER BY effectiveDate

IF OBJECT_ID('TEMPDB..#PreciousMetals') IS NOT NULL DROP TABLE #PreciousMetals
SELECT DISTINCT versionid,contributor,companyid,effectiveDate,Industry,IndustryId,dataitemid,dataitemname,PEO,unitsId,unitsType,
CASE WHEN (dataitemid IN (600265,600269) AND unitsId IN (67,68,69,70,71,72,73,74,75,76,77,78,87,92,93,94,95,96,97,98)) THEN unitsId ELSE NULL END AS Correct_units,CASE WHEN (dataitemid IN (600265,600269) AND unitsId NOT IN (67,68,69,70,71,72,73,74,75,76,77,78,87,92,93,94,95,96,97,98)) THEN unitsId ELSE NULL END AS Wrong_units,
CASE WHEN (dataitemid IN (600265,600269) AND unitsType IN ('oz-Ounces','Koz/Moz-Thousands of Ounce','MMoz-Millions of Ounce','Boz-Billions of Ounce','Toz-Troy Ounces','KToz/MToz-Thousands of  Troy Ounce','MMToz-Millions of Troy Ounce','BToz-Billions of Troy Ounce','t-Tonne','Kt/Mt-Thousands of Tonne','MMt-Millions of Tonne','Bt-Billions of Tonne','Kg-Kilogram,g-Gram','Kg/Mg - Thousands of Gram','MMg - Millions of Gram','Bg - Billions of Gram','KKg/MKg-Thousands of Kilogram','MMKg - Millions of Kilogram','BKg - Billions of Kilogram')) THEN unitsType ELSE NULL END AS Correct_unitTypes,CASE WHEN (dataitemid IN (600265,600269) AND unitsType NOT IN ('oz-Ounces','Koz/Moz-Thousands of Ounce','MMoz-Millions of Ounce','Boz-Billions of Ounce','Toz-Troy Ounces','KToz/MToz-Thousands of  Troy Ounce','MMToz-Millions of Troy Ounce','BToz-Billions of Troy Ounce','t-Tonne','Kt/Mt-Thousands of Tonne','MMt-Millions of Tonne','Bt-Billions of Tonne','Kg-Kilogram,g-Gram','Kg/Mg - Thousands of Gram','MMg - Millions of Gram','Bg - Billions of Gram','KKg/MKg-Thousands of Kilogram','MMKg - Millions of Kilogram','BKg - Billions of Kilogram')) THEN unitsType ELSE NULL END AS Wrong_unitTypes
INTO #PreciousMetals FROM #Versioniddta
WHERE dataitemid IN (600265,600269)

IF OBJECT_ID('TEMPDB..#BaseMetals') IS NOT NULL DROP TABLE #BaseMetals
SELECT DISTINCT versionid,contributor,companyid,effectiveDate,Industry,IndustryId,dataitemid,dataitemname,PEO,unitsId,unitsType,
CASE WHEN (dataitemid IN (600266,600267,600270) AND unitsId IN (88,75,76,77,78,89,90,91)) THEN unitsId ELSE NULL END AS Correct_units,CASE WHEN (dataitemid IN (600266,600267,600270) AND unitsId NOT IN (88,75,76,77,78,89,90,91)) THEN unitsId ELSE NULL END AS Wrong_units,
CASE WHEN (dataitemid IN (600266,600267,600270) AND unitsType IN ('Lb-Pound','t-Tonne','Kt/Mt-Thousands of Tonne','MMt-Millions of Tonne','Bt-Billions of Tonne','KLb/MLb-Thousands of Pound','MMLb-Millions of Pound','BLb-Billions of Pound')) THEN unitsType ELSE NULL END AS Correct_unitTypes,CASE WHEN (dataitemid IN (600266,600267,600270) AND unitsType NOT IN ('Lb-Pound','t-Tonne','Kt/Mt-Thousands of Tonne','MMt-Millions of Tonne','Bt-Billions of Tonne','KLb/MLb-Thousands of Pound','MMLb-Millions of Pound','BLb-Billions of Pound')) THEN unitsType ELSE NULL END AS Wrong_unittypes
INTO #BaseMetals FROM #Versioniddta
WHERE dataitemid IN (600266,600267,600270)

SELECT * FROM #PreciousMetals WHERE Correct_units IS NULL AND Wrong_units IS NOT NULL
UNION ALL
SELECT * FROM #BaseMetals WHERE Correct_units IS NULL AND Wrong_units IS NOT NULL



