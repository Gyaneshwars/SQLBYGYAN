--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates

DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2024-04-01 06:00:00.000'
SET @toDate = '2024-05-30 05:59:59.999'

IF OBJECT_ID('TEMPDB..#EMP') IS NOT NULL DROP TABLE #EMP 
SELECT DISTINCT employeeNumber,userId,firstName + ' '+ lastName AS EmpName INTO #EMP
FROM CTAdminRepTables.[dbo].[user_tbl]
WHERE employeeNumber IN ('208076','B06042','407104','906106','208065','208069','407004','307025','108019','708072','307023','002267','009022','202006','A09030','718017','009086')

---SELECT * FROM #EMP

IF OBJECT_ID('TEMPDB..#CTAdmin') IS NOT NULL DROP TABLE #CTAdmin 
SELECT DISTINCT A.employeeNumber,A.EmpName,CeToP.collectionEntityId,CeToP.priorityId,CeToP.relatedCompanyId,CeToP.insertedDate, startDate,endDate,A.userId,collectionStageId,
DATEDIFF(MINUTE,startDate,endDate) insert2endmin,DATEDIFF(SECOND,startDate,endDate) insert2endmin_Sec,collectionProcessId,CONVERT(VARCHAR(10),endDate-'6:20',101) AS LoginDay,collectionStageStatusId,
DATEDIFF(MINUTE,startDate,endDate) start2end_min INTO #CTAdmin 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CeToP (NOLOCK) 
INNER JOIN #EMP A (NOLOCK) ON A.userId= CeToP.userId
WHERE collectionEntityTypeId = 9 AND CeToP.collectionProcessId = 1062 AND collectionStageId IN (2) AND collectionStageStatusId IN (4,5) 
AND endDate >= @frDate AND endDate <= @toDate

INSERT INTO #CTAdmin 
SELECT DISTINCT A.employeeNumber,A.EmpName,CeToP.collectionEntityId,CeToP.priorityId,CeToP.relatedCompanyId,CeToP.insertedDate,startDate,endDate,A.userId,collectionStageId,
DATEDIFF(MINUTE,cetop.startDate,cetop.endDate) AS insert2endmin,DATEDIFF(SECOND,cetop.startDate,cetop.endDate) AS insert2endmin_Sec,collectionProcessId ,CONVERT(VARCHAR(10),endDate-'6:20',101) AS LoginDay,collectionStageStatusId,
DATEDIFF(MINUTE,cetop.startDate,cetop.endDate) AS start2end_min FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CeToP (NOLOCK) 
INNER JOIN #EMP A (NOLOCK) ON A.userId= CeToP.userId
WHERE collectionEntityTypeId = 9 AND collectionProcessId = 64 AND collectionStageId IN (2) AND collectionStageStatusId IN (4 ,5)  
AND endDate >= @frDate AND endDate <= @toDate   
AND NOT EXISTS (SELECT 1 FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CEP 
WHERE CeToP.collectionEntityId = CEP.collectionEntityId 
AND CEP.relatedCompanyId = CeToP.relatedCompanyId   
AND CEP.collectionProcessId = 64  AND CEP.collectionStageId IN (122)
AND CEP.PriorityID = CeToP.PriorityID
AND CEP.collectionStageStatusId <> 5)   
 
INSERT INTO #CTAdmin 
SELECT DISTINCT A.employeeNumber,A.EmpName,CeToP.collectionEntityId,CeToP.priorityId,CeToP.relatedCompanyId,CeToP.insertedDate,startDate,endDate,A.userId,collectionStageId,
DATEDIFF(MINUTE,startDate,endDate) AS insert2endmin,DATEDIFF(SECOND,startDate,endDate) AS insert2endmin_Sec,collectionProcessId,CONVERT(VARCHAR(10),endDate-'6:20',101) AS LoginDay,collectionStageStatusId,
DATEDIFF(MINUTE,startDate,endDate) AS start2end_min FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CeToP (NOLOCK) 
INNER JOIN #EMP A (NOLOCK) ON A.userId = CeToP.userId
WHERE collectionProcessId IN (374,895) AND collectionStageId IN (168) AND collectionStageStatusId IN (4 ,5)  
AND endDate >= @frDate AND endDate <= @toDate   

 
INSERT INTO #CTAdmin 
SELECT DISTINCT A.employeeNumber,A.EmpName,CeToP.collectionEntityId,CeToP.priorityId,CeToP.relatedCompanyId,CeToP.insertedDate,startDate,endDate,A.userId,collectionStageId,
DATEDIFF(MINUTE,cetop.startDate,cetop.endDate) AS insert2endmin,DATEDIFF(SECOND,cetop.startDate,cetop.endDate) AS insert2endmin_Sec,collectionProcessId,CONVERT(VARCHAR(10),endDate-'6:20',101) AS LoginDay,collectionStageStatusId,
DATEDIFF(MINUTE,cetop.startDate,cetop.endDate) AS start2end_min FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CeToP (NOLOCK) 
INNER JOIN #EMP A (NOLOCK) ON A.userId = CeToP.userId
WHERE collectionProcessId IN (378,895) AND collectionStageId IN (85) AND collectionStageStatusId IN (4 ,5)  
AND endDate >= @frDate AND endDate <= @toDate   
 
INSERT INTO #CTAdmin 
SELECT DISTINCT A.employeeNumber,A.EmpName,CeToP.collectionEntityId,CeToP.priorityId,CeToP.relatedCompanyId,CeToP.insertedDate,startDate,endDate,A.userId,collectionStageId,
DATEDIFF(MINUTE,cetop.startDate,cetop.endDate) AS insert2endmin,DATEDIFF(SECOND,cetop.startDate,cetop.endDate) AS insert2endmin_Sec,collectionProcessId,CONVERT(VARCHAR(10),endDate-'6:20',101) AS LoginDay,collectionStageStatusId,
DATEDIFF(MINUTE,cetop.startDate,cetop.endDate) AS start2end_min FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CeToP (NOLOCK) 
INNER JOIN #EMP A (NOLOCK) ON A.userId= CeToP.userId
WHERE collectionProcessId IN (374,895) AND collectionStageId IN (167) AND collectionStageStatusId IN (4 ,5)  
AND endDate >= @frDate AND endDate <= @toDate   

---SELECT * FROM #CTAdmin
 
IF OBJECT_ID('TEMPDB..#e') IS NOT NULL DROP TABLE #e
SELECT DISTINCT 'Batch Checks Review & Event Logs Review' AS process,LoginDay, employeeNumber,EmpName, COUNT(collectionEntityId) AS total_files,SUM(start2end_min) AS Timetaken4Job INTO #e FROM #CTAdmin 
WHERE collectionStageId IN (85,167)
GROUP BY LoginDay,employeeNumber,EmpName
UNION ALL
SELECT DISTINCT 'Post Staging Checks Review' AS process,LoginDay, employeeNumber,EmpName, COUNT(collectionEntityId) AS total_files,SUM(start2end_min) AS Timetaken4Job FROM #CTAdmin 
WHERE collectionStageId IN (168)
GROUP BY LoginDay,employeeNumber,EmpName

---SELECT * FROM #e WHERE employeeNumber='708072'
 
IF OBJECT_ID('TEMPDB..#CHECK096 ') IS NOT NULL DROP TABLE #CHECK096 
SELECT DISTINCT employeeNumber,EmpName,CP.versionId,CP.feedFileId,CP.companyId,CP.parentflag,CP.tradingitemId,CP.researchcontributorId,CP.AccountingStandardID,c.ChecklogicID,Checkdescription,DM.dataitemname,Value,
CASE IP.periodTypeId WHEN 1 THEN 'FY: ' + CAST(IP.fiscalYear AS VARCHAR) WHEN 2 THEN 'Q' + CAST(IP.fiscalQuarter AS VARCHAR) + ': ' + CAST(IP.fiscalYear AS VARCHAR) 
WHEN 10 THEN 'S' + CASE IP.fiscalQuarter WHEN 2 THEN '1' + ': ' + CAST(IP.fiscalYear AS VARCHAR) WHEN 4 THEN '2' + ': ' + CAST(IP.fiscalYear AS VARCHAR) ELSE 'NA' END ELSE 'NA' END AS PEO,
Errorresolutiondescription,CT.startDate,CT.endDate,CT.LoginDay,errordatetime,EEDV.estimateDetailId,Cb.collectionProcessId ,DATEDIFF(MINUTE, startDate,endDate) AS MM,errorResolutionDateTime,ct.collectionstageid,DATEDIFF(MINUTE, startDate,endDate) AS MM_start2end_min INTO #CHECK096
FROM CheckParameters_tbl CP (NOLOCK)
INNER JOIN CheckBatch_tbl CB (NOLOCK) ON CP.checkBatchId = CB.checkBatchId
INNER JOIN Error_tbl E (NOLOCK) ON E.checkBatchId = CB.checkBatchId
INNER JOIN Check_tbl C (NOLOCK) ON E.checkId = C.checkId
INNER JOIN ErrorToEstimateDataValue_tbl EEDV (NOLOCK) ON EEDV.errorId = E.errorId
INNER JOIN dataitemmaster_vw DM (NOLOCK) ON DM.dataitemID = EEDV.dataitemID
LEFT JOIN Estimatedetail_Tbl ED (NOLOCK) ON EEDV.estimatedetailID = ED.estimatedetailID
LEFT Join estimatePeriod_tbl IP (NOLOCK) ON IP.estimatePeriodId = ED.estimatePeriodId
LEFT JOIN ErrorToResolution_tbl ER (NOLOCK) ON ER.errorId = E.errorId
LEFT JOIN ErrorResolutionType_tbl ERT (NOLOCK) ON ER.errorResolutionTypeId = ERT.errorResolutionTypeId
INNER JOIN #CTAdmin CT (NOLOCK) ON CT.collectionEntityId = ISNULL(CP.versionId,CP.feedFileId) AND CT.relatedCompanyId = CP.companyId --AND errorDateTime >= CT.LstartDate and  errorDateTime <+ CT.LendDate 

---WHERE ChecklogicID = 96

---SELECT * FROM #CHECK096
 
IF OBJECT_ID('TEMPDB..#CHECK960 ') IS NOT NULL DROP TABLE #CHECK960 
SELECT DISTINCT LoginDay,employeeNumber,EmpName,feedfileid,companyid,collectionstageid,COUNT(estimateDetailId) AS CHECK96,Errorresolutiondescription,SUM(MM_start2end_min) AS MM_Timetaken4job INTO #CHECK960 FROM #CHECK096 
WHERE employeeNumber <>'000266' AND dataitemname NOT LIKE '%mean%'
---AND errorResolutionDateTime >= startDate and  errorResolutionDateTime <= endDate
GROUP BY LoginDay,employeeNumber,feedfileid,companyid,Errorresolutiondescription,EmpName,collectionstageid

---SELECT * FROM #CHECK960 where employeeNumber='708072'
 
IF OBJECT_ID('TEMPDB..#BCEL') IS NOT NULL DROP TABLE #BCEL
SELECT DISTINCT 'Batch Checks Review & Event Logs Review' AS process,LoginDay, employeeNumber, EmpName,collectionstageid,CONCAT(companyid,feedFileId) AS cvf INTO #BCEL FROM #CHECK960 --count(Errorresolutiondescription)
WHERE Errorresolutiondescription='error' AND collectionstageid IN (85,167) --and employeeNumber='708072'
---GROUP BY employeeNumber, EmpName,companyid,feedfileid,collectionstageid
 
IF OBJECT_ID('TEMPDB..#PSC') IS NOT NULL DROP TABLE #PSC
SELECT DISTINCT 'Post Staging Checks Review' AS process,LoginDay,employeeNumber, EmpName,collectionstageid,CONCAT(companyid,feedFileId) AS cvf INTO #PSC FROM #CHECK960 --count(Errorresolutiondescription)
WHERE Errorresolutiondescription='error' AND collectionstageid IN (168) --and employeeNumber='708072'
---group by employeeNumber, EmpName,companyid,feedfileid,collectionstageid

---SELECT * FROM #Total_Errors where employeeNumber='708072'
 
---SELECT * FROM #CHECK960

---SELECT * FROM #BCEL

---SELECT * FROM #PSC
 
 
IF OBJECT_ID('TEMPDB..#Processwise') IS NOT NULL DROP TABLE #Processwise
SELECT DISTINCT   c.*,collectionEntityTypeName AS Entitytype,c.insertedDate AS Processinserteddate,c.insertedDate AS Stageinserteddate,stageissuesource='',Personid='',com.companyName,
Templatetype=' ',Internationalflag=' ',subTypeValue AS Industry,
cim.Country,RANK AS CompanyRank,
ct.sortOrder,issueSourceName='',c.insert2endmin/60 AS DuratioinSeconds, 
IdleDuration=' ',Resolution=' ',UserComment=' ',
collectionEntityToProcessId=' ',ct.collectionEntityTypeId,collectionEntityToCollectionStageId='',LoginDay AS DoneDate,
collectionProcessName,collectionStageName,priorityName,collectionStageStatusName,languageName='English',c.startDate AS startDate1,c.endDate AS endDate1 INTO #Processwise FROM #CTAdmin c
LEFT JOIN WorkflowArchive_Estimates.dbo.Priority_tbl p (NOLOCK) ON p.priorityId=c.PriorityID
LEFT JOIN WorkflowArchive_Estimates.dbo.CollectionProcess_tbl cp (NOLOCK) ON cp.collectionProcessId=c.collectionProcessId
LEFT JOIN WorkflowArchive_Estimates.dbo.CollectionStage_tbl cs (NOLOCK) ON cs.collectionStageId=c.collectionstageId
LEFT JOIN  WorkflowArchive_Estimates.dbo.CollectionStageStatus_tbl css (NOLOCK) ON css.collectionStageStatusId=c.collectionstageStatusId
LEFT JOIN DocumentRepositoryProcessing.dbo.DocumentElementCache_vw DE (NOLOCK) ON DE.versionId=C.collectionEntityId
LEFT JOIN ComparisonData.dbo.ResearchDocument_tbl rd (NOLOCK) ON rd.versionId=c.collectionEntityId
LEFT JOIN ComparisonData.DBO.Language_tbl L (NOLOCK) ON L.languageId=DE.originalLanguageId
LEFT JOIN ComparisonData.DBO.Language_tbl Ll (NOLOCK) ON Ll.languageId=RD.languageId
LEFT JOIN WorkflowArchive_Estimates.dbo.CommonTracker_vw ct (NOLOCK) ON ct.collectionEntityId=c.collectionEntityId AND ct.relatedCompanyId=c.relatedCompanyId AND c.collectionProcessId=ct.collectionProcessId AND c.collectionstageId=ct.collectionstageId 
LEFT JOIN Workflow_Estimates.dbo.collectionentitytype_tbl cet (NOLOCK) ON cet.collectionEntityTypeId=ct.collectionEntityTypeId
LEFT JOIN ComparisonData.dbo.company_tbl com (NOLOCK) ON com.companyId=c.relatedCompanyId
LEFT JOIN ComparisonData.dbo.SubType_tbl s (NOLOCK) ON s.subTypeId=com.PrimarySubTypeId
LEFT JOIN CompanyMaster.dbo.CompanyInfoMaster cim (NOLOCK) ON cim.CIQCompanyId=c.relatedCompanyId
LEFT JOIN estimates.dbo.EstimatesCompanyTier_tbl ect (NOLOCK) ON ect.companyid=c.relatedCompanyId
LEFT JOIN Workflow_Estimates.dbo.IssueSource_tbl iss (NOLOCK) ON iss.issueSourceId=ct.issueSourceId
LEFT JOIN WorkflowArchive_Estimates.dbo.User_tbl x (NOLOCK) ON c.employeeNumber= x.employeeNumber 
AND c.startDate IS NOT NULL

---SELECT * FROM #Processwise



IF OBJECT_ID('TEMPDB..#BERT1') IS NOT NULL DROP TABLE #BERT1
SELECT DISTINCT d.LoginDay,a.process,d.employeeNumber,d.EmpName,a.total_files,COUNT(DISTINCT cvf) AS total_Errors,a.total_files-COUNT(DISTINCT cvf) AS Total_NotAnErrors INTO #BERT1 FROM #CHECK960 d
LEFT JOIN #e a ON a.employeeNumber=d.employeeNumber AND a.LoginDay=d.LoginDay
LEFT JOIN #BCEL b ON b.employeeNumber=d.employeeNumber AND b.process=a.process AND b.LoginDay=d.LoginDay
LEFT JOIN #e a1 ON a1.employeeNumber=d.employeeNumber AND a1.process=b.process
WHERE d.collectionstageId IN (85,167) 
GROUP BY d.LoginDay,d.employeeNumber,d.EmpName,a.total_files,a.process,d.collectionstageId

IF OBJECT_ID('TEMPDB..#PRT1') IS NOT NULL DROP TABLE #PRT1
SELECT DISTINCT d.LoginDay,a.process,d.employeeNumber,d.EmpName,a.total_files,COUNT(DISTINCT cvf) AS total_Errors,a.total_files-COUNT(DISTINCT cvf) AS Total_NotAnErrors INTO #PRT1 FROM #CHECK960 d
LEFT JOIN #e a ON a.employeeNumber=d.employeeNumber AND a.LoginDay=d.LoginDay
LEFT JOIN #BCEL b ON b.employeeNumber=d.employeeNumber AND b.process=a.process AND b.LoginDay=d.LoginDay
LEFT JOIN #e a1 ON a1.employeeNumber=d.employeeNumber AND a1.process=b.process
WHERE d.collectionstageId IN (168) 
GROUP BY d.LoginDay,d.employeeNumber,d.EmpName,a.total_files,a.process,d.collectionstageId

IF OBJECT_ID('TEMPDB..#BERT') IS NOT NULL DROP TABLE #BERT
SELECT DISTINCT 'Batch Checks Review & Event Logs Review' AS process,employeeNumber,EmpName,SUM(MM_Timetaken4job) AS Timetaken4job INTO #BERT FROM #CHECK960
WHERE collectionstageid IN (85,167)
GROUP BY employeeNumber,EmpName,collectionstageid

IF OBJECT_ID('TEMPDB..#PRT') IS NOT NULL DROP TABLE #PRT
SELECT DISTINCT 'Post Staging Checks Review' AS process,employeeNumber,EmpName,SUM(MM_Timetaken4job) AS Timetaken4job INTO #PRT FROM #CHECK960
WHERE collectionstageid IN (168)
GROUP BY employeeNumber,EmpName,collectionstageid

IF OBJECT_ID('TEMPDB..#Summary') IS NOT NULL DROP TABLE #Summary
SELECT DISTINCT a.*,ISNULL(b.Timetaken4job,0) AS Timetaken4jobs INTO #Summary FROM #BERT1 a LEFT JOIN #e b ON a.employeeNumber=b.employeeNumber AND a.process=b.process AND a.LoginDay=b.LoginDay
UNION ALL
SELECT DISTINCT a.*,ISNULL(b.Timetaken4job,0) AS Timetaken4jobs FROM #PRT1 a LEFT JOIN #e b ON a.employeeNumber=b.employeeNumber AND a.process=b.process AND a.LoginDay=b.LoginDay

SELECT DISTINCT * FROM #Summary ORDER BY LoginDay,process



SELECT DISTINCT * FROM #Processwise