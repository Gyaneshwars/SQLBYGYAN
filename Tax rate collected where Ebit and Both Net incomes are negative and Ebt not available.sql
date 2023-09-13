USE Estimates
SELECT DISTINCT ResearchContributor=dbo.researchContributorName_fn(ed.researchcontributorid),ed.versionid,ed.companyid,
PEO=dbo.formatPeriodId_fn(ed.estimateperiodid),ednd.dataitemvalue as EBIT,ednd1.dataitemvalue as NIGAAP,ednd11.dataitemvalue as NINormalised,ednd2.dataitemvalue as ETR,
ed.effectivedate FROM EstimateDetail_tbl ed (NOLOCK)
INNER JOIN EstimateDetailNumericData_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid AND ednd.dataitemvalue<0
INNER JOIN EstimateDetailNumericData_tbl ednd1 (NOLOCK) ON ednd1.estimatedetailid=ed.estimatedetailid AND ednd1.dataitemvalue<0
INNER JOIN EstimateDetailNumericData_tbl ednd11 (NOLOCK) ON ednd11.estimatedetailid=ed.estimatedetailid AND ednd11.dataitemvalue<0
INNER JOIN EstimateDetailNumericData_tbl ednd2 (NOLOCK) ON ednd2.estimatedetailid=ed.estimatedetailid AND ednd2.dataitemvalue<>0
WHERE ednd.dataItemId=21645 AND ednd1.dataItemId=21650 AND ednd11.dataItemId=21649 AND ednd2.dataItemId=114164 AND ed.effectiveDate>GETDATE()-30
AND ednd.dataItemId NOT IN (21646,21647) 