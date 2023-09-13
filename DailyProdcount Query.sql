
USE WorkflowArchive_Estimates

DECLARE @frDate AS DATETIME, @toDate AS DATETIME

--SET @frDate = Convert(varchar(10),getdate() -7,101)  

--SET @toDate = Convert(varchar(10),getdate()+1,101)


SET @frDate = '2022-01-01 00:00:00.000'

SET @toDate = '2022-12-31 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#ctversion') IS NOT NULL DROP TABLE #ctversion

select distinct ct.insertedDate,ct.stageInsertedDate,ct.collectionEntityId,collectionStageStatusId,

ct.PriorityID,priorityname,rd.researchContributorId, ct.issueSourceId,ct.startDate,ct.endDate,ct.userId,rdc.companyId,rd.lastUpdatedDateUTC,rd.headline,

employeeNumber,displayName AS EmpName,issueSourceName,case when(rd.languageId =123) then 'English' else 'Native' end as languagename  INTO #ctversion from WorkflowArchive_Estimates.dbo.CommonTracker_vw ct

INNER JOIN WorkflowArchive_Estimates.dbo.User_tbl UT (NOLOCK) ON UT.userId=CT.userId

INNER JOIN WorkflowArchive_Estimates.dbo.Priority_tbl pt(NOLOCK)ON ct.priorityId=pt.priorityid

INNER JOIN ComparisonData.dbo.ResearchDocument_tbl RD  (NOLOCK)ON RD.versionId = CT.collectionEntityId

LEFT JOIN [ComparisonData]..ResearchDocumentToCompany_tbl RDC (NOLOCK)ON RD.ResearchDocumentID = RDC.ResearchDocumentID

LEFT JOIN dbo.IssueSource_tbl IST (NOLOCK) ON IST.issueSourceId=ct.issueSourceId 

WHERE ct.collectionStageId=1 and CT.collectionProcessId = 64 and collectionEntityTypeId in (9)

--AND ct.PriorityID not in (32,128) and ct.userId not in ( 907321171,922608159) --266

AND ct.collectionStageStatusId in (4,5) and ct.endDate > = @frDate  and ct.endDate <= @toDate

--select distinct * from #ctversion where collectionStageId=1 ----------------collectionEntityId = 1598915358

  

IF OBJECT_ID ('TEMPDB..#PRODNULL') IS NOT NULL DROP TABLE #PRODNULL

select * INTO #PRODNULL from #ctversion ct

where  NOT EXISTS (SELECT 1 FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw crt   WHERE ct.collectionEntityId=crt.collectionEntityId and ct.companyId = crt.relatedCompanyId and crt.collectionStageId = 2  and crt.issueSourceId in(2,122))

--select * from #PRODNULL where collectionEntityId = 1598915358

 

IF OBJECT_ID ('TEMPDB..#count') IS NOT NULL DROP TABLE #count

select distinct ctt.collectionEntityId,  count(collectionEntityId) linked  into #count from  #PRODNULL ctt

group by ctt.collectionEntityId 

--select * from #count where collectionEntityId = 1598915358



IF OBJECT_ID ('TEMPDB..#processed') IS NOT NULL DROP TABLE #processed

select distinct ctt.collectionEntityId as prod_vid,ctt.relatedcompanyid,ctt.issuesourceid,ctv.lastUpdatedDateUTC INTO #processed 

from WorkflowArchive_Estimates.dbo.CommonTracker_vw ctt

INNER JOIN #ctversion ctv (nolock) on ctt.collectionEntityId = ctv.collectionEntityId

INNER JOIN ComparisonData.dbo.ResearchDocument_tbl rd on rd.versionid=ctt.collectionEntityId

LEFT JOIN WorkflowArchive_Estimates.dbo.IssueSource_tbl IST ON IST.IssueSourceID = ctt.IssueSourceID

WHERE ctt.collectionStageId=2 and ctt.issuesourceid in (32,3,34) and ctt. collectionEntityTypeId = 9 AND ctt.collectionProcessId=64 and  ctt.PriorityID not in (14,20)

 

IF OBJECT_ID ('TEMPDB..#count_processed') IS NOT NULL DROP TABLE #count_processed

select distinct pr.prod_vid,  count(prod_vid) linked  into #count_processed from  #processed Pr

group by pr.prod_vid



IF OBJECT_ID ('TEMPDB..#final') IS NOT NULL DROP TABLE #final

select distinct pp.collectionEntityId,insertedDate,stageInsertedDate,pp.lastUpdatedDateUTC+ '5:30' as fillingdate_IST,

PriorityID,priorityname,issueSourceId,researchContributorId,startDate,endDate,employeeNumber EmpID,EmpName ,languagename, co.linked as total_linked, 

case  when (cp.linked is null)   then 0 else cp.linked  end as total_moved,case  when (cp.linked is null)   then 'skipped' else 'processed' end as PPT_stage, case when (cp.linked  >co.linked) then cp.linked  else co.linked end as linked_final, 

cast(round(datediff(SECOND,startDate, endDate)/60.0,2) as numeric(36,2))as Timein_Minutues,CEILING(datediff(SECOND,startDate, endDate)) as Review_time_seconds into #final  from #ctversion PP

inner join #count co on co.collectionEntityId = pp.collectionEntityId

left join #count_processed cp on cp.prod_vid = pp.collectionEntityId

order by PP.endDate


IF OBJECT_ID ('TEMPDB..#final1') IS NOT NULL DROP TABLE #final1

select distinct  fr.collectionEntityId,convert(varchar, fillingdate_IST,110) as fillingdate,

fr.PriorityID,fr.priorityname,fr.issueSourceId,fr.researchContributorId,ctv.headline ,fr.startDate,Convert(varchar(10),fr.endDate-'6:20',101) as endDate,fr.EmpID,fr.EmpName ,fr.languagename,PPT_stage,total_linked ,total_moved ,linked_final,Timein_Minutues into #final1 from #final fr

--case when (languagename = 'Native ' and PPT_stage = 'processed ') then (total_linked1 *2) when (languagename = 'Native ' and PPT_stage = 'skipped ') then (total_linked1 *1.3) 

--case when (PPT_stage = 'skipped ' and linked_final > 60 ) then 40  when (PPT_stage = 'skipped ' and linked_final < 60 ) then (linked_final*0.65)  

--when (PPT_stage = 'processed ' and linked_final > 60 ) then 60   else ( linked_final *1) end as newmethod   into #final1 from #final fr

inner join #ctversion ctv on ctv.collectionEntityId = fr.collectionEntityId


select * from #final





