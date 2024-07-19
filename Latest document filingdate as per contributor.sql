

SELECT rc.researchcontributorid,Rc.contributorshortname,Rc.estimatecontributorstatustypeid as status,Rc.contributiontociqstartdate,MAX(Rd.lastUpdatedDateutc) as Maxfilingdate 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw ct
INNER JOIN  Estimates.[dbo].estimatedetail_tbl ed (NOLOCK) ON ct.collectionEntityId = ed.versionid
INNER JOIN Comparisondata.dbo.ResearchDocument_tbl Rd (NOLOCK) ON Rd.researchContributorId = ed.researchContributorId
INNER JOIN Comparisondata.dbo.researchcontributor_tbl Rc (NOLOCK) ON Rd.researchContributorId = rc.researchContributorId
WHERE ct.collectionStageStatusId IN (4,5)
GROUP BY ed.researchcontributorid,Rc.contributorshortname,Rc.estimatecontributorstatustypeid,Rc.contributiontociqstartdate
