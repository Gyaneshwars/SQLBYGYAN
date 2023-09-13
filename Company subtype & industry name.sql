-----SQL Query Developer---Gnaneshwar Sravane

IF OBJECT_ID('tempdb..#companysubtype') IS NOT NULL DROP TABLE #companysubtype
SELECT DISTINCT c.companyName,c.companyId,c.PrimarySubTypeId AS SubTypeId,s.subTypeValue AS SubtypeName,s.subparentId,cm.Country,cm.SectorID,cm.IndustryID,id.IndustryName 
INTO #companysubtype FROM ComparisonData.[dbo].[Company_tbl] c
INNER JOIN ComparisonData.[dbo].[SubType_tbl] s (NOLOCK) ON s.subTypeId=c.PrimarySubTypeId
INNER JOIN CompanyMaster.[dbo].[CompanyInfoMaster] cm (NOLOCK) ON cm.CIQCompanyId=c.companyId
INNER JOIN Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] id (NOLOCK) ON cm.IndustryID=id.IndustryId
WHERE PrimarySubTypeId IS NOT NULL AND tickerSymbol IS NOT NULL
AND c.companyId IN (6143410,398006,6789549,61598267,20378703,1697628,23519888) -----Provide company id here
ORDER BY PrimarySubTypeId


SELECT DISTINCT companyName,companyId,SubTypeId,SubtypeName,IndustryID,IndustryName FROM #companysubtype ORDER BY IndustryID