USE estimates DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2021-06-30 06:00:00.000' -- Give From Date here 
SET @toDate = '2021-07-30 05:59:59.000'-- Give To Date here
SELECT DISTINCT ed.versionId,ed.companyId, 
ed.parentFlag,ed.researchContributorId,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),
ed.effectiveDate,L.languageName
FROM       estimates.dbo.EstimateDetail_tbl ed (NOLOCK)
INNER JOIN estimates.dbo.EstimateDetailNumericData_tbl edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId  
INNER JOIN ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK) ON RD.versionId = ed.versionId
LEFT JOIN  ComparisonData.dbo.Language_tbl L (NOLOCK) ON L.LanguageID = RD.LanguageID
WHERE
ed.versionId > 1000
AND L.LanguageID NOT IN (123)
AND ed.parentFlag IN (1,0)
AND effectiveDate >= @frDate  AND effectiveDate <= @toDate
ORDER BY effectiveDate








