--Use estimates DECLARE @frDate DATETIME, @toDate DATETIME 
--SET @frDate = '2020-12-01 06:00:00.000' -- Give From Date here 
--SET @toDate = '2021-02-28 05:59:59.000'-- Give To Date here
--SET @toDate = '2018-12-31 23:59:59.999'-- Give To Date here
--USE Estimates 
DECLARE @frDate AS DATE, @toDate AS DATE
SET @frDate = Convert(varchar(10),getdate() -8,101)  
SET @toDate = Convert(varchar(10),getdate()+2,101) 
IF OBJECT_ID('TEMPDB..#Pre_Process') IS NOT NULL DROP TABLE #Pre_Process
SELECT DISTINCT cecs.enddate,cecs.startdate,cep.collectionentityid as versionid, cep.relatedCompanyId,cep.priorityid,p.priorityname,usr.employeenumber,
usr.displayName as EMPName, cs.collectionStageName,cecs.collectionStageid,cecs.collectionStagestatusid ,issuesourceid,CSC.comment 
INTO #Pre_Process FROM WorkflowArchive_Estimates.dbo.collectionentitytoprocess_tbl cep (NOLOCK)
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl cecs (NOLOCK)ON cep.collectionEntityToProcessId = cecs.collectionEntityToProcessId
INNER JOIN CTAdminRepTables.dbo.user_tbl usr (NOLOCK)ON cecs.userId = usr.userid
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionStage_tbl cs (NOLOCK)ON cecs.collectionStageId = cs.collectionStageId
INNER JOIN WorkflowArchive_Estimates.dbo.priority_tbl p (NOLOCK)ON cep.priorityid = p.priorityid
LEFT JOIN WorkflowArchive_Estimates.dbo.collectionStageComment_tbl CSC ON CSC.collectionEntityToCollectionStageID = cecs.collectionEntityToCollectionStageId AND collectionCommentTypeId in (6685)
WHERE cecs.collectionStageid = 1 and Cep.collectionProcessId = 64 AND cecs.collectionStagestatusid in (4,5) AND cep.collectionEntityTypeId = 9
and cecs.enddate >= @frDate  and cecs.enddate <= @toDate and usr.employeenumber not like '000266' and usr.employeenumber not like '007111'


---select * from #Pre_Process
---select * from WorkflowArchive_Estimates.dbo.collectionentitytoprocess_tbl
---select * from WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl

IF OBJECT_ID ('TEMPDB..#rDocDtl_tbl') IS NOT NULL DROP TABLE #rDocDtl_tbl 
SELECT DISTINCT pp.Versionid, RdToCo.companyId, RdToCo.primaryFlag, Rd.primaryCompanyId, Rd.researchContributorId, 
Rd.lastUpdatedDateUTC AS filingDate, Rd.headline, Rd.[pageCount], Rd.languageId,pp.issuesourceid,pp.priorityname,pp.employeenumber,pp.EMPName,pp.enddate,pp.startdate,pp.comment 
INTO #rDocDtl_tbl FROM #Pre_Process PP (NOLOCK)
LEFT JOIN ComparisonData.dbo.ResearchDocument_tbl Rd (NOLOCK) ON  Rd.versionId = pp.versionId
LEFT JOIN Comparisondata.dbo.ResearchDocumentToCompany_tbl RdToCo (NOLOCK)ON RdToCo.researchDocumentId = Rd.researchDocumentId 

---select * from #rDocDtl_tbl
---select * from Comparisondata.dbo.ResearchDocumentToCompany_tbl

IF OBJECT_ID ('TEMPDB..#final') IS NOT NULL DROP TABLE #final 
SELECT DISTINCT  rD.versionid, rD.primaryCompanyId, rD.companyId,
Co.companyName, Co.tickerSymbol, rD.headline,rD.[pageCount],rD.filingDate,  rd.languageId, rD.primaryFlag,
Cs.collectionStageStatusName AS statusName,CeToP.issuesourceid,rd.priorityname,rd.employeenumber,rd.enddate,rd.startdate,comment
into #final FROM #rDocDtl_tbl rD (NOLOCK) 
LEFT JOIN Comparisondata.dbo.Company_tbl Co (NOLOCK)ON Co.companyId = rD.companyId 
LEFT JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) ON CeToP.collectionEntityId = rD.versionid AND CeToP.relatedCompanyId = rD.companyId  AND CeToP.collectionProcessId = 64
LEFT JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToCs.collectionEntityToProcessId = CeToP.collectionEntityToProcessId and CeToCs.collectionStageId in (2)
LEFT JOIN WorkflowArchive_Estimates.dbo.CollectionStageStatus_tbl Cs (NOLOCK) ON Cs.collectionStageStatusId = CeToCs.collectionStageStatusId 
LEFT JOIN Comparisondata.dbo.Language_tbl Lg (NOLOCK) ON Lg.languageId = rD.languageId 
WHERE CeToP.issuesourceid not in (2) or CeToP.issuesourceid is Null
GROUP BY rD.versionid, rD.companyId, Co.companyName, Co.tickerSymbol, rD.primaryFlag, rD.primaryCompanyId,  rD.filingDate, rD.headline, rD.[pageCount], rd.languageId, 
Cs.collectionStageStatusName,CeToP.issuesourceid,rd.priorityname,comment,rd.employeenumber,rd.enddate,rd.startdate

---select * from #final

IF OBJECT_ID ('TEMPDB..#movedrecords') IS NOT NULL DROP TABLE #movedrecords
SELECT DISTINCT CONVERT(varchar(11),CT.INSERTEDDATE,101)Prod_INSERTEDDATE,pp.versionid, CT.relatedCompanyId,CT.issuesourceid AS Prod_issuesourceid,ct.PriorityID,
ct.collectionstageStatusId INTO #movedrecords FROM #Pre_Process pp
left join WorkflowArchive_Estimates.dbo.CommonTracker_vw CT on  ct.collectionEntityId = pp.versionid
WHERE CT.collectionstageId=2  AND collectionEntityTypeId = 9 AND ct.collectionProcessId=64 AND CT.issueSourceId IN (34) and ct.PriorityID not in (14,20) 

---select * from #movedrecords

IF OBJECT_ID ('TEMPDB..#reviewed') IS NOT NULL DROP TABLE #reviewed 
select distinct a.versionid,a.companyId,a.employeenumber,convert(varchar(10),a.enddate -'6:00',101)Enddate into #reviewed from #final   A

---select * from #reviewed

IF OBJECT_ID ('TEMPDB..#reviewednative') IS NOT NULL DROP TABLE #reviewednative
select distinct a.versionid,a.companyId,a.employeenumber,convert(varchar(10),a.enddate -'6:00',101)Edate into #reviewednative from #final   A
where a.languageId <> 123

---select * from #reviewednative

IF OBJECT_ID ('TEMPDB..#done') IS NOT NULL DROP TABLE #done 
select DISTINCT convert(date,Enddate)as eddate,employeenumber,count(enddate)Totalcount,count(distinct versionid)#VIDs into #done from #reviewed rD
group by enddate,employeenumber

---select * from #done

IF OBJECT_ID ('TEMPDB..#done_native') IS NOT NULL DROP TABLE #done_native
select DISTINCT convert(date,Edate)as endate,employeenumber,count(edate)Totalcount_Native into #done_native from #reviewednative rn
group by edate,employeenumber


IF OBJECT_ID ('TEMPDB..#Linktype') IS NOT NULL DROP TABLE #Linktype
select DISTINCT RD.versionId,RdToCo.Companyid INTO #Linktype  FROM Comparisondata.dbo.ResearchDocument_tbl RD
INNER JOIN  #movedrecords CT(NOLOCK) ON RD.versionId=ct.versionId
INNER JOIN Comparisondata.dbo.ResearchDocumentToCompany_tbl RdToCo (NOLOCK)ON  RdToCo.researchDocumentId = Rd.researchDocumentId 


IF OBJECT_ID ('TEMPDB..#revisionPP') IS NOT NULL DROP TABLE #revisionPP
select DISTINCT CT.*,ppt.employeenumber, Comments=CASE when RD.Companyid IS NULL THEN 'Company Not linked' ELSE 'Already linked company' end into #revisionPP from #movedrecords CT
LEFT JOIN #Linktype RD ON RD.versionId=ct.versionId AND RD.Companyid=CT.relatedCompanyId 
left join #Pre_Process ppt on ppt.versionid =ct.versionid 
where rd.companyId is null


IF OBJECT_ID ('TEMPDB..#linked') IS NOT NULL DROP TABLE #linked
select DISTINCT CONVERT(varchar(11),Prod_INSERTEDDATE,100)as eldate,employeenumber,count(Prod_INSERTEDDATE) toallinked into #linked from #revisionPP
group by Prod_INSERTEDDATE,employeenumber

IF OBJECT_ID ('TEMPDB..#total') IS NOT NULL DROP TABLE #total 
select DISTINCT eddate,dn.employeenumber,Totalcount,#VIDs,isnull(dv.Totalcount_Native,0) Native_count, isnull(lv.toallinked,0)emp_linked_count into #total from #done dn
left join #done_native dv on  dv.employeenumber = dn.employeenumber and dv.endate = dn.eddate
left join #linked lv on lv.employeenumber = dn.employeenumber  and lv.eldate = dn.eddate
group by Eddate,dn.employeenumber,Totalcount,#VIDs,Totalcount_Native ,lv.toallinked

select * from #total

