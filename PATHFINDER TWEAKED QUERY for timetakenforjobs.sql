--ETL,AZURE DATA FACTORY AND POWER BI DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2024-01-06 06:00:00.000'
SET @toDate = '2024-01-08 05:59:59.999'

IF OBJECT_ID('TEMPDB..#EMP')IS NOT NULL DROP TABLE #EMP 
SELECT DISTINCT employeeNumber,userId,displayName INTO #EMP
FROM WorkflowArchive_Estimates.dbo.User_tbl
WHERE employeeNumber in ('208076','B06042','407104','906106','208065','208069','407004','307025','108019','708072')

--select * from #EMP

IF OBJECT_ID('TEMPDB..#CTAdmin')IS NOT NULL DROP TABLE #CTAdmin 
SELECT A.employeeNumber,a.displayName,CeToP.collectionEntityId,CeToP.priorityId,CeToP.relatedCompanyId,CeToP.insertedDate, startDate,endDate,A.userId,collectionStageId,
DATEDIFF(Minute,startDate,endDate) insert2endmin,DATEDIFF(SECOND,startDate,endDate) insert2endmin_Sec,collectionProcessId,Convert(varchar(10),endDate-'6:20',101)  LoginDay,collectionStageStatusId
,DATEDIFF(Minute,startDate,endDate) start2end_min INTO #CTAdmin 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CeToP(NOLOCK) 
INNER JOIN #EMP A on A.userId= CeToP.userId
WHERE collectionEntityTypeId = 9 AND CeToP.collectionProcessId = 1062    AND collectionStageId IN (2) AND collectionStageStatusId in (4,5) 
AND endDate > = @frDate   AND endDate < = @toDate

INSERT INTO #CTAdmin 
SELECT A.employeeNumber,a.displayName,CeToP.collectionEntityId,CeToP.priorityId,CeToP.relatedCompanyId,CeToP.insertedDate,startDate,endDate,A.userId,collectionStageId,
DATEDIFF(Minute,cetop.startDate,cetop.endDate) insert2endmin,DATEDIFF(SECOND,cetop.startDate,cetop.endDate) insert2endmin_Sec,collectionProcessId ,Convert(varchar(10),endDate-'6:20',101)  LoginDay,collectionStageStatusId
,DATEDIFF(Minute,cetop.startDate,cetop.endDate) start2end_min FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CeToP(NOLOCK) 
INNER JOIN #EMP A on A.userId= CeToP.userId
WHERE collectionEntityTypeId = 9 AND collectionProcessId = 64    AND collectionStageId IN (2) AND collectionStageStatusId in(4 ,5)  
AND endDate > = @frDate   AND endDate < = @toDate   
AND NOT EXISTS (SELECT 1 FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CEP 
WHERE CeToP.collectionEntityId = CEP.collectionEntityId 
AND CEP.relatedCompanyId = CeToP.relatedCompanyId   
AND CEP.collectionProcessId = 64  AND CEP.collectionStageId IN (122)
AND CEP.PriorityID = CeToP.PriorityID
AND CEP.collectionStageStatusId <> 5)   

 INSERT INTO #CTAdmin 
SELECT A.employeeNumber,a.displayName,CeToP.collectionEntityId,CeToP.priorityId,CeToP.relatedCompanyId,CeToP.insertedDate,startDate,endDate,A.userId,collectionStageId,
DATEDIFF(Minute,startDate,endDate) insert2endmin,DATEDIFF(SECOND,startDate,endDate) insert2endmin_Sec,collectionProcessId,Convert(varchar(10),endDate-'6:20',101)  LoginDay,collectionStageStatusId
,DATEDIFF(Minute,startDate,endDate) start2end_min FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CeToP(NOLOCK) 
INNER JOIN #EMP A on A.userId= CeToP.userId
WHERE collectionProcessId =374    AND collectionStageId IN (168) AND collectionStageStatusId in(4 ,5)  
AND endDate > = @frDate   AND endDate < = @toDate   

INSERT INTO #CTAdmin 
SELECT A.employeeNumber,a.displayName,CeToP.collectionEntityId,CeToP.priorityId,CeToP.relatedCompanyId,CeToP.insertedDate,startDate,endDate,A.userId,collectionStageId,
DATEDIFF(Minute,cetop.startDate,cetop.endDate) as insert2endmin,DATEDIFF(SECOND,cetop.startDate,cetop.endDate) insert2endmin_Sec,collectionProcessId,Convert(varchar(10),endDate-'6:20',101)  LoginDay,collectionStageStatusId
,DATEDIFF(Minute,cetop.startDate,cetop.endDate) as start2end_min FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CeToP(NOLOCK) 
INNER JOIN #EMP A on A.userId= CeToP.userId
WHERE collectionProcessId = 378    AND collectionStageId IN (85) AND collectionStageStatusId in(4 ,5)  
AND endDate > = @frDate   AND endDate < = @toDate   

INSERT INTO #CTAdmin 
SELECT A.employeeNumber,a.displayName,CeToP.collectionEntityId,CeToP.priorityId,CeToP.relatedCompanyId,CeToP.insertedDate,startDate,endDate,A.userId,collectionStageId,
DATEDIFF(Minute,cetop.startDate,cetop.endDate) as insert2endmin,DATEDIFF(SECOND,cetop.startDate,cetop.endDate) insert2endmin_Sec,collectionProcessId,Convert(varchar(10),endDate-'6:20',101)  LoginDay,collectionStageStatusId
,DATEDIFF(Minute,cetop.startDate,cetop.endDate) as start2end_min FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CeToP(NOLOCK) 
INNER JOIN #EMP A on A.userId= CeToP.userId
WHERE collectionProcessId = 374    AND collectionStageId IN (167) AND collectionStageStatusId in(4 ,5)  
AND endDate > = @frDate   AND endDate < = @toDate   
--select * from #CTAdmin where employeeNumber='108019' and relatedCompanyId=20345796

IF OBJECT_ID('tempdb..#e') IS NOT NULL DROP TABLE #e
SELECT DISTINCT 'Batch Checks Review & Event Logs Review' as process, employeeNumber,displayName, count(collectionEntityId) total_files,SUM(start2end_min) AS Timetaken4Job into #e from #CTAdmin 
WHERE collectionStageId IN (85,167)
GROUP BY employeeNumber,displayName
UNION ALL
SELECT DISTINCT 'Post Staging Checks Review' as process, employeeNumber,displayName, count(collectionEntityId) total_files,SUM(start2end_min) AS Timetaken4Job from #CTAdmin 
WHERE collectionStageId IN (168)
GROUP BY employeeNumber,displayName
--select * from #e where employeeNumber='708072'

IF Object_Id('TempDb..#CHECK096 ') IS NOT NULL DROP TABLE #CHECK096 
SELECT employeeNumber,displayName,CP.versionId,CP.feedFileId,CP.companyId,CP.parentflag,CP.tradingitemId,CP.researchcontributorId,CP.AccountingStandardID,c.ChecklogicID,Checkdescription,DM.dataitemname,Value,
CASE iP.periodTypeId WHEN 1 THEN 'FY: ' + CAST(iP.fiscalYear AS VARCHAR) WHEN 2 THEN 'Q' + CAST(iP.fiscalQuarter AS VARCHAR) + ': ' + CAST(iP.fiscalYear AS VARCHAR) 
WHEN 10 THEN 'S' + CASE iP.fiscalQuarter WHEN 2 THEN '1' + ': ' + CAST(iP.fiscalYear AS VARCHAR) WHEN 4 THEN '2' + ': ' + CAST(iP.fiscalYear AS VARCHAR) ELSE 'NA' END ELSE 'NA' END AS PEO
,Errorresolutiondescription,CT.startDate,CT.endDate,errordatetime,EEDV.estimateDetailId,Cb.collectionProcessId ,DATEDIFF(MINUTE, startDate,endDate)as MM,errorResolutionDateTime,ct.collectionstageid,DATEDIFF(MINUTE, startDate,endDate)as MM_start2end_min INTO #CHECK096
 FROM CheckParameters_tbl CP(nolock) 
INNER JOIN CheckBatch_tbl CB(nolock) ON CP.checkBatchId = CB.checkBatchId
INNER JOIN Error_tbl E(NOLOCK) ON E.checkBatchId = CB.checkBatchId
INNER JOIN Check_tbl C(nolock) ON E.checkId = C.checkId
INNER JOIN ErrorToEstimateDataValue_tbl EEDV(nolock) on EEDV.errorId = E.errorId
INNER Join dataitemmaster_vw DM (NOLOCK) ON DM.dataitemID = EEDV.dataitemID
LEFT JOIN Estimatedetail_Tbl ED(nolock) on EEDV.estimatedetailID = ED.estimatedetailID
LEFT Join estimatePeriod_tbl IP (nolock) on IP.estimatePeriodId = ED.estimatePeriodId
LEFT JOIN ErrorToResolution_tbl ER(NOLOCK) ON ER.errorId = E.errorId
LEFT JOIN ErrorResolutionType_tbl ERT(NOLOCK) ON ER.errorResolutionTypeId = ERT.errorResolutionTypeId
INNER JOIN #CTAdmin CT on CT.collectionEntityId = ISNULL(CP.versionId,CP.feedFileId) and CT.relatedCompanyId = CP.companyId --AND errorDateTime >= CT.LstartDate and  errorDateTime <+ CT.LendDate 
--WHERE ChecklogicID = 96
--select * from #CHECK096 where employeeNumber='708072' and CompanyId=20345796

IF Object_Id('TempDb..#CHECK960 ') IS NOT NULL DROP TABLE #CHECK960 
SELECT employeeNumber,displayName,feedfileid,companyid,collectionstageid,COUNT(estimateDetailId) CHECK96,Errorresolutiondescription,SUM(MM_start2end_min) AS MM_Timetaken4job INTO #CHECK960 FROM #CHECK096 
WHERE employeeNumber <>'000266' AND dataitemname NOT like '%mean%'
--AND errorResolutionDateTime >= startDate and  errorResolutionDateTime <= endDate
GROUP BY employeeNumber,feedfileid,companyid,Errorresolutiondescription,displayName,collectionstageid
--select * from #CHECK960 where employeeNumber='708072'

IF OBJECT_ID('tempdb..#BCEL') IS NOT NULL DROP TABLE #BCEL
SELECT DISTINCT 'Batch Checks Review & Event Logs Review' as process, employeeNumber, displayName,collectionstageid,CONCAT(companyid,feedFileId) cvf into #BCEL from #CHECK960 --count(Errorresolutiondescription)
WHERE Errorresolutiondescription='error' and collectionstageid in (85,167) --and employeeNumber='708072'
GROUP BY employeeNumber, displayName,companyid,feedfileid,collectionstageid

IF OBJECT_ID('tempdb..#PSC') IS NOT NULL DROP TABLE #PSC
SELECT DISTINCT 'Post Staging Checks Review' as process,employeeNumber, displayName,collectionstageid,CONCAT(companyid,feedFileId) cvf into #PSC from #CHECK960 --count(Errorresolutiondescription)
WHERE Errorresolutiondescription='error' and collectionstageid in (168) --and employeeNumber='708072'
group by employeeNumber, displayName,companyid,feedfileid,collectionstageid
--select * from #Total_Errors where employeeNumber='708072'

--select * from #CHECK960
--select * from #BCEL
--select * from #PSC


IF OBJECT_ID('TEMPDB..#Processwise') IS NOT NULL DROP TABLE #Processwise
SELECT DISTINCT   c.*,collectionEntityTypeName AS Entitytype,c.insertedDate AS Processinserteddate,c.insertedDate AS Stageinserteddate,stageissuesource='',Personid='',com.companyName,
Templatetype=' ',Internationalflag=' ',subTypeValue AS Industry,
Country,rank AS CompanyRank,
ct.sortOrder,issueSourceName='',c.insert2endmin/60 AS DuratioinSeconds,
IdleDuration=' ',Resolution=' ',UserComment=' ',
collectionEntityToProcessId=' ',
ct.collectionEntityTypeId,
collectionEntityToCollectionStageId=''
,LoginDay AS DoneDate,
collectionProcessName,collectionStageName,priorityName,collectionStageStatusName,languageName='English',c.startDate as startDate1,c.endDate as endDate1 into #Processwise FROM #CTAdmin  c
LEFT JOIN WorkflowArchive_Estimates.dbo.Priority_tbl p on p.priorityId=c.PriorityID
LEFT JOIN WorkflowArchive_Estimates.dbo.CollectionProcess_tbl cp on cp.collectionProcessId=c.collectionProcessId
LEFT JOIN WorkflowArchive_Estimates.dbo.CollectionStage_tbl cs on cs.collectionStageId=c.collectionstageId
LEFT JOIN  WorkflowArchive_Estimates.dbo.CollectionStageStatus_tbl css on css.collectionStageStatusId=c.collectionstageStatusId
LEFT JOIN DocumentRepositoryProcessing.dbo.DocumentElementCache_vw DE on DE.versionId=C.collectionEntityId
LEFT JOIN ComparisonData.dbo.ResearchDocument_tbl rd on rd.versionId=c.collectionEntityId
LEFT JOIN ComparisonData.DBO.Language_tbl L ON L.languageId=DE.originalLanguageId
LEFT JOIN ComparisonData.DBO.Language_tbl Ll ON Ll.languageId=RD.languageId
LEFT JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw ct on ct.collectionEntityId=c.collectionEntityId and ct.relatedCompanyId=c.relatedCompanyId and c.collectionProcessId=ct.collectionProcessId and c.collectionstageId=ct.collectionstageId 
LEFT JOIN Workflow_Estimates.dbo.collectionentitytype_tbl cet on cet.collectionEntityTypeId=ct.collectionEntityTypeId
LEFT JOIN ComparisonData.dbo.company_tbl com on com.companyId=c.relatedCompanyId
LEFT JOIN ComparisonData.dbo.SubType_tbl s on s.subTypeId=com.PrimarySubTypeId
LEFT JOIN CompanyMaster.dbo.CompanyInfoMaster cim on cim.CIQCompanyId=c.relatedCompanyId
LEFT JOIN estimates.dbo.EstimatesCompanyTier_tbl ect on ect.companyid=c.relatedCompanyId
LEFT JOIN Workflow_Estimates.dbo.IssueSource_tbl iss on iss.issueSourceId=ct.issueSourceId
LEFT JOIN WorkflowArchive_Estimates.dbo.User_tbl x ON c.employeeNumber= x.employeeNumber 
AND c.startDate IS NOT NULL

--select * from #Processwise

IF OBJECT_ID('TEMPDB..#BERT1')IS NOT NULL DROP TABLE #BERT1
SELECT DISTINCT a.process,d.employeeNumber,d.displayName,a.total_files,COUNT(DISTINCT cvf) total_Errors,a.total_files-COUNT(DISTINCT cvf) Total_NotAnErrors INTO #BERT1 from #CHECK960 d
LEFT JOIN #e a ON a.employeeNumber=d.employeeNumber
LEFT JOIN #BCEL b ON b.employeeNumber=d.employeeNumber AND b.process=a.process
WHERE d.collectionstageId IN (85,167) 
GROUP BY d.employeeNumber,d.displayName,a.total_files,a.process,d.collectionstageId

IF OBJECT_ID('TEMPDB..#PRT1')IS NOT NULL DROP TABLE #PRT1
SELECT DISTINCT a.process,d.employeeNumber,d.displayName,a.total_files,COUNT(DISTINCT cvf) total_Errors,a.total_files-COUNT(DISTINCT cvf) Total_NotAnErrors INTO #PRT1 from #CHECK960 d
LEFT JOIN #e a ON a.employeeNumber=d.employeeNumber
LEFT JOIN #PSC b ON b.employeeNumber=d.employeeNumber AND b.process=a.process
WHERE d.collectionstageId IN (168) 
GROUP BY d.employeeNumber,d.displayName,a.total_files,a.process,d.collectionstageId

IF OBJECT_ID('TEMPDB..#BERT')IS NOT NULL DROP TABLE #BERT
SELECT 'Batch Checks Review & Event Logs Review' as process,employeeNumber,displayName,SUM(MM_Timetaken4job) AS Timetaken4job INTO #BERT FROM #CHECK960
WHERE collectionstageid IN (85,167)
GROUP BY employeeNumber,displayName,collectionstageid

IF OBJECT_ID('TEMPDB..#PRT')IS NOT NULL DROP TABLE #PRT
SELECT 'Post Staging Checks Review' as process,employeeNumber,displayName,SUM(MM_Timetaken4job) AS Timetaken4job INTO #PRT FROM #CHECK960
WHERE collectionstageid IN (168)
GROUP BY employeeNumber,displayName,collectionstageid

SELECT DISTINCT a.*,ISNULL(b.Timetaken4job,0) AS Timetaken4jobs FROM #BERT1 a LEFT JOIN #e b ON a.employeeNumber=b.employeeNumber AND a.process=b.process
UNION ALL
SELECT DISTINCT a.*,ISNULL(b.Timetaken4job,0) AS Timetaken4jobs FROM #PRT1 a LEFT JOIN #e b ON a.employeeNumber=b.employeeNumber AND a.process=b.process


--select distinct collectionEntityId as EntityID,Entitytype='FeedFileID',Processinserteddate,Stageinserteddate,stageissuesource,Personid,relatedCompanyId as CompanyID,
-- CompanyName,Templatetype,Internationalflag,Industry,Country,CompanyRank,collectionProcessName as CollectionProcess,collectionStageName as CollectionStage,
--collectionStageStatusName as Collectionstagestatus,priorityName as Priority,sortOrder,issueSourceName as Issuesource,employeeNumber,displayName as UserName,
--startDate,endDate,insert2endmin as DurationInMinutes,insert2endmin_Sec as DuratioinSeconds,IdleDuration,Resolution,UserComment,collectionEntityToProcessId,collectionEntityTypeId,collectionEntityToCollectionStageId,
--collectionstageStatusId,DoneDate, case when (collectionProcessId=374 and collectionstageId=168) Then '2.18' else '3.66' End as StandardMintues from #Processwise
----where employeeNumber='108019'

SELECT * FROM #Processwise