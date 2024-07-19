--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE
USE ComparisonData  

DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2024-04-01 06:00:00.000'
SET @toDate = '2024-05-30 05:59:59.999'

IF OBJECT_ID('TEMPDB..#LinkedCompanies') IS NOT NULL DROP TABLE #LinkedCompanies
SELECT DISTINCT RD.VersionID,cs.CompanyID AS LinkedcompanyId,COUNT(cs.CompanyID) AS NoOfLinkedCompanies
INTO #LinkedCompanies FROM ComparisonData.dbo.ResearchDocument_tbl RD
--INNER JOIN ResearchContributor_tbl RC (NOLOCK) ON RD.ResearchContributorID = RC.ResearchContributorID
LEFT JOIN ResearchDocumentToCompany_tbl RDC (NOLOCK) ON RD.ResearchDocumentID = RDC.ResearchDocumentID
LEFT JOIN CompanyMaster.[dbo].[CompanySearch_vw] cs (NOLOCK) ON cs.companyId=RDC.companyId
LEFT JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK) ON CT.collectionEntityId = RD.VersionID AND CT.relatedCompanyId = cs.CompanyID
LEFT JOIN Workflow_Estimates.[dbo].[CollectionStage_tbl] cst (NOLOCK) ON cst.collectionstageid = CT.collectionstageId
LEFT JOIN Workflow_Estimates.[dbo].CollectionStageStatus_tbl csts (NOLOCK) ON csts.collectionStageStatusId=CT.collectionstageStatusId
WHERE  ---RD.VersionID IN (-2034225132,-1925147694,-1925152532)
    CT.collectionstageid IN (2)
AND CT.collectionstageStatusId IN (4,5)
AND CT.collectionEntityId IS NOT NULL
AND CT.endDate >= @frDate AND CT.endDate <= @toDate
GROUP BY RD.VersionID,cs.CompanyID
HAVING COUNT(cs.CompanyID)>1




SELECT DISTINCT VersionID,LinkedcompanyId FROM #LinkedCompanies
ORDER BY VersionID
