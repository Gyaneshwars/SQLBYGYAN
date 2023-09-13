
SELECT researchContributorId,contributionToCIQStartDate, researchContributorStatusTypeId,estimateContributorStatusTypeId,
contributorShortName,  CASE WHEN (estimateContributorStatusTypeId  = 2) THEN 'inactive' WHEN  (estimateContributorStatusTypeId  = 3) THEN 'History only' WHEN
(estimateContributorStatusTypeId  = 4) THEN 'EF only' ELSE 'Active' END AS contributorstatus
FROM ComparisonData..ResearchContributor_tbl RC 
WHERE estimateContributorStatusTypeId IN (1)
order by contributorShortName
