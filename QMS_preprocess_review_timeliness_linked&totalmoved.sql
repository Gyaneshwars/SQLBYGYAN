USE WorkflowArchive_Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
--SET @frDate = Convert(varchar(10),getdate() -10,101)  
--SET @toDate = Convert(varchar(10),getdate()+1,101) 

SET @frDate = '2021-08-10 06:00:00.000'
SET @toDate = '2021-08-30 05:59:59.999'
IF OBJECT_ID ('TEMPDB..#ctversion') IS NOT NULL DROP TABLE #ctversion
select distinct ct.insertedDate,ct.stageInsertedDate,ct.collectionEntityId,collectionStageStatusId,
ct.PriorityID,priorityname,rd.researchContributorId, ct.issueSourceId,ct.startDate,ct.endDate,ct.userId,rdc.companyId,rd.lastUpdatedDateUTC,
employeeNumber,displayName AS EmpName,issueSourceName,case when(rd.languageId =123) then 'English' else 'Native' end as languagename  INTO #ctversion from WorkflowArchive_Estimates.dbo.CommonTracker_vw ct
inner join WorkflowArchive_Estimates.dbo.User_tbl UT (NOLOCK) ON UT.userId=CT.userId
inner JOIN WorkflowArchive_Estimates.dbo.Priority_tbl pt(NOLOCK)ON ct.priorityId=pt.priorityid
INNER JOIN ComparisonData.dbo.ResearchDocument_tbl RD  (NOLOCK)ON RD.versionId = CT.collectionEntityId
LEFT JOIN [ComparisonData]..ResearchDocumentToCompany_tbl RDC (NOLOCK)ON RD.ResearchDocumentID = RDC.ResearchDocumentID
left join dbo.IssueSource_tbl IST (NOLOCK) ON IST.issueSourceId=ct.issueSourceId 
where ct.collectionStageId=1 and CT.collectionProcessId = 64 and collectionEntityTypeId in (9)
and ct.PriorityID not in (32,128) and ct.userId not in ( 907321171,922608159) --266
and ct.collectionStageStatusId in (4,5) and ct.endDate > = @frDate  and ct.endDate <= @toDate

IF OBJECT_ID ('TEMPDB..#count') IS NOT NULL DROP TABLE #count
select distinct ctt.collectionEntityId,  count(collectionEntityId) linked  into #count from  #ctversion ctt
group by ctt.collectionEntityId 


IF OBJECT_ID ('TEMPDB..#processed') IS NOT NULL DROP TABLE #processed
select distinct ctt.collectionEntityId as prod_vid,ctt.relatedcompanyid,CTt.issuesourceid INTO #processed 
from WorkflowArchive_Estimates.dbo.CommonTracker_vw ctt
inner join #ctversion ctv (nolock) on ctt.collectionEntityId = ctv.collectionEntityId
inner join ComparisonData.dbo.ResearchDocument_tbl rd on rd.versionid=ctt.collectionEntityId
LEFT JOIN WorkflowArchive_Estimates.dbo.IssueSource_tbl IST ON IST.IssueSourceID = ctt.IssueSourceID
where ctt.collectionStageId=2 and ctt.issuesourceid in (32,3,34) and ctt. collectionEntityTypeId = 9 AND ctt.collectionProcessId=64 and  ctt.PriorityID not in (14,20) 

IF OBJECT_ID ('TEMPDB..#count_processed') IS NOT NULL DROP TABLE #count_processed
select distinct pr.prod_vid,  count(prod_vid) linked  into #count_processed from  #processed Pr
group by pr.prod_vid 

select distinct pp.collectionEntityId as VersionID,insertedDate,stageInsertedDate,pp.stageInsertedDate+ '5:30' as fillingdate_IST,
PriorityID,priorityname,issueSourceId,researchContributorId,startDate,endDate,employeeNumber EmpID,EmpName ,languagename, co.linked as total_linked, 
case  when (cp.linked is null)   then 0 else cp.linked  end as total_moved,case  when (cp.linked is null)   then 'skipped' else 'processed' end as PPT_stage, case when (cp.linked  >co.linked) then cp.linked  else co.linked end as total_linked1
,cast(round(datediff(SECOND,startDate, endDate)/60.0,2) as numeric(36,2))as Timein_Minutues,CEILING(datediff(SECOND,startDate, endDate)) as Review_time_seconds  from #ctversion PP
inner join #count co on co.collectionEntityId = pp.collectionEntityId
left join #count_processed cp on cp.prod_vid = pp.collectionEntityId
order by PP.endDate 
