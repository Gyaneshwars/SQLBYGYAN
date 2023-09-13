USE Estimates
SELECT DISTINCT Contributor=dbo.researchContributorName_fn(ed.researchcontributorid),ed.companyid,ed.versionid,
peo=dbo.formatPeriodId_fn(ed.estimateperiodid),ednd.dataitemvalue as EBTGAAP,ednd1.dataitemvalue as NIGAAP,ednd2.dataitemvalue as ETR,
ed.effectivedate FROM EstimateDetail_tbl ed (NOLOCK)
INNER JOIN EstimateDetailNumericData_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid AND ednd.dataitemvalue<0
INNER JOIN EstimateDetailNumericData_tbl ednd1 (NOLOCK) ON ednd1.estimatedetailid=ed.estimatedetailid AND ednd1.dataitemvalue<0
INNER JOIN EstimateDetailNumericData_tbl ednd2 (NOLOCK) ON ednd2.estimatedetailid=ed.estimatedetailid AND ednd2.dataitemvalue<>0
WHERE ednd.dataItemId=21647 AND ednd1.dataItemId=21650 AND ednd2.dataItemId=114164 AND ed.effectiveDate>GETDATE()-30
AND ednd.dataItemValue>ednd1.dataItemValue