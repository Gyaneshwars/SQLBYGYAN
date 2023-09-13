USE ComparisonData  

DECLARE @frDate AS DATE, @toDate AS DATE
SET @frDate = '2023-06-01 00:00:00:000'
SET @toDate = '2023-06-30 00:00:00:000'

IF OBJECT_ID('TEMPDB..#Contributorstrings') IS NOT NULL DROP TABLE #Contributorstrings
SELECT DISTINCT RDC.CompanyID, C.CompanyName,C.tickerSymbol,RC.ContributorShortName AS ContributorName, RD.VersionID,
RD.LastUpdatedDateUTC FilingDate,L.LanguageName AS Language,RD.primaryCompanyId AS PrimaryCID,versionFormatId,RC.ResearchContributorID AS ContributorID,
Rd.headline, Rd.[pageCount],ff.researchFocusName,c.companyTypeId,rv.researchEventId INTO #Contributorstrings
-----ct.issueSourceId as ppt_issued,ct.PriorityID as PPT_PriorityID
FROM ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK)
INNER JOIN ResearchContributor_tbl RC (NOLOCK) ON RD.ResearchContributorID = RC.ResearchContributorID
LEFT JOIN ResearchDocumentToCompany_tbl RDC (NOLOCK) ON RD.ResearchDocumentID = RDC.ResearchDocumentID
LEFT JOIN Company_tbl C (NOLOCK) ON  RDC.CompanyID = C.CompanyID
LEFT JOIN Language_tbl L (NOLOCK) ON L.LanguageID = RD.LanguageID
LEFT JOIN  dbo.ResearchDocumentToResearchFocus_tbl F (NOLOCK) ON F.researchDocumentId = RD.researchDocumentId
LEFT JOIN dbo.ResearchFocus_tbl FF (NOLOCK) ON FF.researchFocusId = F.researchFocusId
INNER JOIN DocumentRepository.dbo.ContentSearchResult_tbl CSR (NOLOCK) ON CSR.versionId = RD.versionId
LEFT JOIN [dbo].[ResearchDocumentToResearchEvent_tbl]  RV (NOLOCK) ON RV.researchDocumentId = RD.researchDocumentId

WHERE
estimateContributorStatusTypeId=1
AND RD.ResearchContributorID IN (2057)
AND RD.LastUpdatedDateUTC BETWEEN @frDate and @toDate
AND RD.headline LIKE '%fair%'
ORDER BY FilingDate DESC


SELECT DISTINCT ContributorName,VersionID ,FilingDate,Language,versionFormatId,ContributorID,
headline, [pageCount],researchFocusName FROM #Contributorstrings ORDER BY FilingDate DESC

