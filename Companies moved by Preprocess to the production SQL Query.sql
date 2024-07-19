--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE WorkflowArchive_Estimates

IF OBJECT_ID('TEMPDB..#CTsData') IS NOT NULL DROP TABLE #CTsData
SELECT DISTINCT CT.collectionentityid AS VersionID,CT.relatedCompanyId AS Companyid,cmt.companyname,CONVERT(VARCHAR(16),CT.insertedDate,120) AS ProcessInsertedDate,rc.contributorShortName AS 'ContributorName',
CT.PriorityID,ed.effectiveDate AS FilingDate,cp.collectionProcessName,CT.startDate,CT.endDate,css.collectionStageStatusName,ist.issueSourceName,
CT.collectionstageStatusId,CT.issueSourceId,usr.employeenumber AS Prod_empid,usr.firstName+' '+usr.lastName AS Prod_EmpName,
CONVERT(date,CT.insertedDate) AS ProcessInsertedDate1 INTO #CTsData FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CT
LEFT JOIN     ComparisonData.dbo.ResearchDocument_tbl Rd (NOLOCK) ON Rd.versionId=CT.collectionEntityId
LEFT JOIN     CTAdminRepTables.dbo.user_tbl usr (NOLOCK)ON ct.userId = usr.userid
LEFT JOIN     Comparisondata.dbo.Company_tbl cmt (NOLOCK)ON cmt.companyId=ct.relatedCompanyId
INNER JOIN    Estimates.[dbo].estimatedetail_tbl ed (NOLOCK) ON ct.collectionEntityId = ed.versionid AND ct.relatedcompanyid = ed.companyid
LEFT JOIN     ComparisonData.dbo.ResearchContributor_tbl RC (NOLOCK) ON RD.ResearchContributorID=RC.ResearchContributorID
INNER JOIN    Workflow_Estimates.[dbo].[IssueSource_tbl] ist (NOLOCK) ON ist.issueSourceId=ct.issueSourceId 
INNER JOIN    Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=ct.collectionstageStatusId
LEFT JOIN     workflow_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = ct.collectionEntityToProcessId and datapointid  = 1887
LEFT JOIN     Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN     workflow_Estimates.dbo.collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,ct.collectionProcessId)
WHERE         ct.collectionProcessId=64 AND CT.collectionstageStatusId IN (1,2,4,5,3) AND CT.collectionstageId=2 AND CT.issueSourceId IN (34)
AND           CT.issueSourceId NOT IN (2)

----Please Enter the Preprocess Processed VersionId's below

AND ct.collectionentityid IN (-2034225132)


SELECT ProcessInsertedDate1,COUNT(DISTINCT(Companyid)) AS No_Of_Companies_Moved_By_Preprocess
FROM
#CTsData
GROUP BY ProcessInsertedDate1
ORDER BY ProcessInsertedDate1

SELECT DISTINCT VersionID,Companyid FROM #CTsData ORDER BY VersionID


