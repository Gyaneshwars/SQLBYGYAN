use ComparisonData  

DECLARE @frDate AS DATE, @toDate AS DATE
SET @frDate = '2022-01-01 00:00:00:000'
SET @toDate = '2023-12-06 00:00:00:000'

SELECT distinct RDC.CompanyID, C.CompanyName,C.tickerSymbol,RC.ContributorShortName AS ContributorName, RD.VersionID,
RD.LastUpdatedDateUTC FilingDate,L.LanguageName AS Language,RD.primaryCompanyId as PrimaryCID,versionFormatId,RC.ResearchContributorID AS ContributorID,
Rd.headline, Rd.[pageCount],ff.researchFocusName,c.companyTypeId
--,ct.issueSourceId as ppt_issued,ct.PriorityID as PPT_PriorityID
FROM ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK)
INNER JOIN ResearchContributor_tbl RC (NOLOCK) ON RD.ResearchContributorID = RC.ResearchContributorID
LEFT JOIN ResearchDocumentToCompany_tbl RDC (NOLOCK) ON RD.ResearchDocumentID = RDC.ResearchDocumentID
LEFT JOIN Company_tbl C (NOLOCK) ON  RDC.CompanyID =C.CompanyID
LEFT JOIN Language_tbl L (NOLOCK) ON L.LanguageID = RD.LanguageID
LEFT JOIN  dbo.ResearchDocumentToResearchFocus_tbl f (NOLOCK) ON f.researchDocumentId= rd.researchDocumentId
left join dbo.ResearchFocus_tbl ff (NOLOCK) ON ff.researchFocusId =f.researchFocusId
--INNER JOIN DocumentRepository.dbo.ContentSearchResult_tbl CSR (NOLOCK) ON CSR.versionId=RD.versionId
left join [dbo].[ResearchDocumentToResearchEvent_tbl]  rv (nolock) on rv.researchDocumentId = rd.researchDocumentId

inner join WorkflowArchive_Estimates.dbo.CommonTracker_vw ct(nolock) on CT.collectionentityid=RD.VersionID
left join WorkflowArchive_Estimates.dbo.User_tbl ut(nolock) on ut.userId=ct.userId
INNER JOIN DocumentRepository.dbo.ContentSearchResult_tbl CSR (NOLOCK) ON CSR.versionId=RD.versionId
where CT.collectionstageId=2 AND ct.collectionProcessId=64 AND collectionEntityTypeId = 9 AND collectionStageStatusId = 4
AND rd.VersionID >1000 AND RD.primaryCompanyId >1
  
--and estimateContributorStatusTypeId=1
and RD.VersionID in (1925137292,1928539948,1928539812,1928539638,1929467272)
--and RDC.CompanyID in (430449299)
--and c.tickerSymbol like 'ARVL'
--and CSR.ruleId in (52824)
--and  RD.ResearchContributorID in (594)
--AND RD.LastUpdatedDateUTC between GETDATE()-07 and GETDATE()+1
and RD.LastUpdatedDateUTC between @frDate and @toDate
 --and rd.headline like 'IN :%'
-- and rd.headline like 'IN : %'
 order by FilingDate DESC

--- Select * from ResearchContributor_tbl