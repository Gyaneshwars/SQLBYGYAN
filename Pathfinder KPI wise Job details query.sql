--PYTHO,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE Pathfinder
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2024-01-01 00:00:00.000' -- Give From Date here 
SET @toDate = '2024-04-30 23:59:00.000'-- Give To Date here

IF OBJECT_ID ('TEMPDB..#PFJobDetails') IS NOT NULL DROP TABLE #PFJobDetails
SELECT DISTINCT P.KEYPERSON,P.EmployeeFullName AS LOGINNAME,IPI.KEYPROCESSSTREAM,IPS.STREAMNAME , IPI.PROCESSINSTANCEAPPIANID ,TASKINSTANCEBEGUN=TI.TASKINSTANCEBEGUN + '5:30',PT.PFDataUpdated,
TASKINSTANCECOMPLETED=TI.TASKINSTANCECOMPLETED + '5:30',TI.TASKINSTANCEEFFORT,TI.EXPECTEDTASKEFFORT,IPI.PROCESSWORKUNITS,TI.SNLANALYSTTASKENTRY,PT.ProcessInstanceName,PT.TaskDisplayName,P.SupervisorFullName,
TI.TaskInstanceInstantiated,PN.INTERNALNOTES,PDV.FIELDIDENTIFIER,PDV.PROCESSFIELDVALUE,IPI.ProcessInstanceDescription,PFJ.ProcessInstanceTargetDate,IPS.UPDOPERATION,PT.TaskName INTO #PFJobDetails  FROM PROCESSINSTANCE IPI
LEFT JOIN PROCESSSTREAM IPS (NOLOCK) ON IPI.KEYPROCESSSTREAM = IPS.KEYPROCESSSTREAM --AND IPS.UPDOPERATION < 2
--LEFT JOIN DBO.PROCESSSTREAMGROUP PG (NOLOCK) ON PG.KEYPROCESSSTREAM=IPS.KEYPROCESSSTREAM
LEFT JOIN TASKINSTANCE TI (NOLOCK) ON IPI.KEYPROCESSINSTANCE = TI.KEYPROCESSINSTANCE --AND  TI.UPDOPERATION < 2
LEFT JOIN DBO.PROCESSDATAVALUE PDV (NOLOCK) ON PDV.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN DBO.PROCESSNOTES PN (NOLOCK) ON PN.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN InternalUseOnly.[dbo].[PFEmployee] P (NOLOCK) ON TI.KEYPERSON = P.KEYPERSON
LEFT JOIN PFJobs PFJ (NOLOCK) ON PFJ.ProcessInstanceAppianID = IPI.ProcessInstanceAppianID  --PFJ.KeyProcessStream = IPS.KeyProcessStream AND
LEFT JOIN [PFTask] PT (NOLOCK) ON PFJ.PROCESSINSTANCEAPPIANID = PT.ProcessInstanceAppianId AND TI.KEYPROCESSINSTANCE = PT.KEYPROCESSINSTANCE
WHERE ---((TI.TASKINSTANCEBEGUN BETWEEN GETDATE()-60 AND GETDATE()) OR (PFJ.ProcessInstanceTargetDate BETWEEN GETDATE()-60 AND GETDATE()))   --IPI.UPDOPERATION < 2 AND 
IPS.KEYPROCESSSTREAM IN (22169)
--AND ((PT.ProcessInstanceName IS NULL AND P.KEYPERSON IS NULL AND TI.TASKINSTANCEBEGUN IS NULL AND TI.TASKINSTANCECOMPLETED IS NULL) OR (PT.ProcessInstanceName IS NOT NULL AND P.KEYPERSON IS NOT NULL AND TI.TASKINSTANCEBEGUN IS NOT NULL AND TI.TASKINSTANCECOMPLETED IS NULL))
--AND PFJ.ProcessInstanceTargetDate BETWEEN @frDate AND @toDate
AND IPI.ProcessInstanceInstantiated > @frDate
AND IPI.ProcessInstanceInstantiated < @toDate
AND ipi.ProcessInstanceCompleted IS NULL

---SELECT * FROM #PFJobDetails




IF OBJECT_ID ('TEMPDB..#Finals') IS NOT NULL DROP TABLE #Finals
SELECT DISTINCT TaskInstanceInstantiated,CASE WHEN KEYPERSON IS NULL AND TASKINSTANCEBEGUN IS NULL AND TASKINSTANCECOMPLETED IS NULL THEN 'ACTIVE' WHEN KEYPERSON IS NOT NULL AND TASKINSTANCEBEGUN IS NOT NULL AND TASKINSTANCECOMPLETED IS NULL THEN 'PAUSED'  ELSE 'COMPLETED' END AS JobStatus,PROCESSINSTANCEAPPIANID AS JobID,KEYPROCESSSTREAM,ProcessInstanceName AS JobName,STREAMNAME AS Process_Stream,
KEYPERSON,LOGINNAME AS JobCreator,SupervisorFullName,TASKINSTANCEBEGUN,PROCESSINSTANCEDESCRIPTION,TASKINSTANCECOMPLETED,PROCESSINSTANCETARGETDATE AS GoalDate, 
SNLANALYSTTASKENTRY INTO #Finals FROM #PFJobDetails ---WHERE PROCESSINSTANCEAPPIANID IN (1517586164,-1893803856)
ORDER BY TASKINSTANCEBEGUN,PROCESSINSTANCETARGETDATE,PROCESSINSTANCEAPPIANID



SELECT * FROM #Finals WHERE JobStatus IN ('ACTIVE','PAUSED') ORDER BY GoalDate


