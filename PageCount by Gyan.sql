
SELECT DISTINCT RD.versionId,RD.pagecount,RC.contributorShortName,RD.Headline 
FROM ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK)
INNER JOIN ComparisonData.dbo.ResearchContributor_tbl RC (NOLOCK) on RD.researchContributorId = RC.researchContributorId
WHERE versionId IN (1156930408)

