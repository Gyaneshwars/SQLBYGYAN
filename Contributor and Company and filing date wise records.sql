USE ComparisonData
DECLARE @ContributorID INT DECLARE @CompanyID INT DECLARE @FilingDate DATETIME

SET @ContributorID=180 -- Give ContributorID Here
--SET @CompanyID= -- Give CompanyID Here
SET @FilingDate='2023-01-22 00:00:00.000' -- FilingDate Here

IF OBJECT_ID('TEMPDB..#QueuedDocs_tbl')IS NOT NULL DROP TABLE #QueuedDocs_tbl 
SELECT * INTO #QueuedDocs_tbl FROM (
SELECT DISTINCT RD.VersionID, RD.LastUpdatedDateUTC, RDC.CompanyID, L.LanguageName, RD.ResearchContributorID, 
RC.ContributorShortName FROM ResearchDocument_tbl RD (NOLOCK)
INNER JOIN ResearchDocumentToCompany_tbl RDC (NOLOCK) ON RD.ResearchDocumentID=RDC.ResearchDocumentID
INNER JOIN ResearchContributor_tbl RC (NOLOCK) ON RD.ResearchContributorID=RC.ResearchContributorID
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CEP (NOLOCK) 
ON RD.VersionID=CEP.CollectionEntityID AND RDC.CompanyID=CEP.RelatedCompanyID
INNER JOIN Language_tbl L (NOLOCK)ON RD.LanguageID=L.LanguageID
WHERE RD.ResearchContributorID= @ContributorID AND RDC.CompanyID= @CompanyID AND RD.LastUpdatedDateUTC >@FilingDate
GROUP BY RD.VersionID, RD.LastUpdatedDateUTC, RDC.CompanyID, L.LanguageName, RD.ResearchContributorID, 
RC.ContributorShortName) QDT
ALTER TABLE #QueuedDocs_tbl ADD Status INT UPDATE #QueuedDocs_tbl SET Status=1 
SELECT DISTINCT RD.VersionID, RD.LastUpdatedDateUTC AS FilingDate, RDC.CompanyID, CIM.CompanyName, L.LanguageName, 
RD.ResearchContributorID, RC.ContributorShortName, CASE WHEN QDT.Status=1 THEN 'Queued'ELSE 'Not Queued' END AS Status 
FROM ResearchDocument_tbl RD (NOLOCK)
INNER JOIN ResearchDocumentToCompany_tbl RDC (NOLOCK) ON RD.ResearchDocumentID=RDC.ResearchDocumentID
INNER JOIN CompanyMaster.dbo.CompanyInfoMaster CIM (NOLOCK) ON RDC.CompanyID=CIM.CIQCompanyID
INNER JOIN ResearchContributor_tbl RC (NOLOCK) ON RD.ResearchContributorID=RC.ResearchContributorID
INNER JOIN Language_tbl L (NOLOCK)ON RD.LanguageID=L.LanguageID
LEFT JOIN #QueuedDocs_tbl QDT (NOLOCK)ON RD.VersionID=QDT.VersionID AND RDC.CompanyID=QDT.CompanyID
WHERE RD.ResearchContributorID= @ContributorID AND RDC.CompanyID= @CompanyID AND RD.LastUpdatedDateUTC >@FilingDate
ORDER BY RD.LastUpdatedDateUTC DESC

--SELECT * FROM ResearchContributor_tbl WHERE
