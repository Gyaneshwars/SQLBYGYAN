use ComparisonData  
SELECT RD.VersionID,C.CompanyID AS linkedcompanies FROM ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK)
INNER JOIN ResearchContributor_tbl RC (NOLOCK)ON RD.ResearchContributorID = RC.ResearchContributorID
LEFT JOIN ResearchDocumentToCompany_tbl RDC (NOLOCK) ON RD.ResearchDocumentID = RDC.ResearchDocumentID
LEFT JOIN Company_tbl C (NOLOCK)ON C.CompanyID = RDC.CompanyID
LEFT JOIN Language_tbl L (NOLOCK) ON L.languageId = RD.languageId
WHERE  RD.VersionID in (1925137292,1928539948,1928539812,1928539638,1929467272)
--AND tickerSymbol is not null
---GROUP BY RD.VersionID , RC.ContributorShortName,L.languageName
--order by linkedcompanies DESC
