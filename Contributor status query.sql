
SELECT researchContributorId,contributionToCIQStartDate, researchContributorStatusTypeId,estimateContributorStatusTypeId,
contributorShortName,  CASE WHEN (estimateContributorStatusTypeId  = 2) THEN 'inactive' WHEN  (estimateContributorStatusTypeId  = 3) THEN 'History only' WHEN
(estimateContributorStatusTypeId  = 4) THEN 'EF only' ELSE 'Active' END AS contributorstatus
FROM ComparisonData..ResearchContributor_tbl RC 
--WHERE ---estimateContributorStatusTypeId IN (1)
order by contributorShortName



SELECT DISTINCT * FROM ComparisonData..ResearchContributor_tbl order by researchContributorId
SELECT DISTINCT * FROM ComparisonData.[dbo].[ResearchContributor_tbl]



SELECT DISTINCT researchContributorId,contributorShortName FROM ComparisonData.[dbo].[ResearchContributor_tbl]
WHERE researchContributorId IN (20,138,171,237,291,348,508,666,757)


SELECT * FROM ComparisonData.[dbo].[ResearchDocument_tbl] WHERE researchContributorId IN (20,138,171,237,291,348,508,666,757)

SELECT * FROM DocumentRepositoryProcessing.[dbo].[ContributorDetail_tbl] WHERE ContributorId IN (20,138,171,237,291,348,508,666,757)