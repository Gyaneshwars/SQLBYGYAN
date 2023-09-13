USE ComparisonData  

DECLARE @frDate AS DATE, @toDate AS DATE
SET @frDate = '2023-05-15 00:00:00:000'
SET @toDate = '2023-05-31 00:00:00:000'

SELECT DISTINCT RDC.CompanyID, C.CompanyName,C.tickerSymbol,RC.ContributorShortName AS ContributorName, RD.VersionID,
RD.LastUpdatedDateUTC FilingDate,L.LanguageName AS Language,RD.primaryCompanyId AS PrimaryCID,versionFormatId,RC.ResearchContributorID AS ContributorID,
Rd.headline, Rd.[pageCount],ff.researchFocusName,c.companyTypeId,rv.researchEventId
--,ct.issueSourceId as ppt_issued,ct.PriorityID as PPT_PriorityID
FROM ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK)
INNER JOIN ResearchContributor_tbl RC (NOLOCK) ON RD.ResearchContributorID = RC.ResearchContributorID
LEFT JOIN ResearchDocumentToCompany_tbl RDC (NOLOCK) ON RD.ResearchDocumentID = RDC.ResearchDocumentID
LEFT JOIN Company_tbl C (NOLOCK) ON  RDC.CompanyID =C.CompanyID
LEFT JOIN Language_tbl L (NOLOCK) ON L.LanguageID = RD.LanguageID
LEFT JOIN dbo.ResearchDocumentToResearchFocus_tbl f (NOLOCK) ON f.researchDocumentId= rd.researchDocumentId
LEFT JOIN dbo.ResearchFocus_tbl ff (NOLOCK) ON ff.researchFocusId =f.researchFocusId
INNER JOIN DocumentRepository.dbo.ContentSearchResult_tbl CSR (NOLOCK) ON CSR.versionId=RD.versionId
LEFT JOIN [dbo].[ResearchDocumentToResearchEvent_tbl]  rv (NOLOCK) ON rv.researchDocumentId = rd.researchDocumentId
INNER JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw ct (NOLOCK) ON CT.collectionentityid=RD.VersionID
--LEFT JOIN WorkflowArchive_Estimates.dbo.User_tbl ut(nolock) on ut.userId=ct.userId
WHERE         -- CT.collectionstageId=2 AND ct.collectionProcessId=64 AND collectionEntityTypeId = 9

rd.VersionID >1000  
AND estimateContributorStatusTypeId=1
AND RDC.CompanyID = 876653
--AND c.tickerSymbol like 'ARVL'
--AND CSR.ruleId in (52824)
AND  RD.ResearchContributorID in (1325)
--AND RD.LastUpdatedDateUTC BETWEEN GETDATE()-07 and GETDATE()+1
AND RD.LastUpdatedDateUTC BETWEEN @frDate and @toDate
 --AND rd.headline like 'IN :%'
ORDER BY FilingDate DESC

