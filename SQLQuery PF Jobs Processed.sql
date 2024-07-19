--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE  Pathfinder
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2023-12-21 06:00:00.000' -- Give From Date here 
SET @toDate = '2024-12-23 23:59:00.000'-- Give To Date here
--SET @frDate = Convert(varchar(10),getdate() -48,101)  
--SET @toDate = Convert(varchar(10),getdate()+1,101) 

IF OBJECT_ID ('TEMPDB..#Pathfinder') IS NOT NULL DROP TABLE #Pathfinder
SELECT DISTINCT P.KEYPERSON,P.SPGMIEIN, P.LOGINNAME,IPS.KEYPROCESSSTREAM,IPS.STREAMNAME , IPI.PROCESSINSTANCEAPPIANID ,TASKINSTANCEBEGUN=TI.TASKINSTANCEBEGUN + '5:30',ti.TaskInstanceDuration
,TASKINSTANCECOMPLETED=TI.TASKINSTANCECOMPLETED + '5:30',TI.TASKINSTANCEEFFORT,TI.EXPECTEDTASKEFFORT ,IPI.PROCESSWORKUNITS,TI.SNLANALYSTTASKENTRY,PN.INTERNALNOTES,PDV.FIELDIDENTIFIER,PDV.PROCESSFIELDVALUE
INTO #Pathfinder  FROM PROCESSINSTANCE IPI
INNER JOIN PROCESSSTREAM IPS (NOLOCK) ON IPI.KEYPROCESSSTREAM = IPS.KEYPROCESSSTREAM AND IPS.UPDOPERATION < 2
INNER JOIN DBO.PROCESSSTREAMGROUP PG (NOLOCK) ON PG.KEYPROCESSSTREAM=IPS.KEYPROCESSSTREAM
JOIN TASKINSTANCE TI (NOLOCK) ON IPI.KEYPROCESSINSTANCE = TI.KEYPROCESSINSTANCE AND  TI.UPDOPERATION < 2
JOIN DBO.PROCESSDATAVALUE PDV (NOLOCK) ON PDV.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN DBO.PROCESSNOTES PN (NOLOCK) ON PN.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE 
LEFT JOIN InternalUseOnly.DBO.EMPLOYEE P ON TI.KEYPERSON = P.KEYPERSON
WHERE IPI.UPDOPERATION < 2 AND TASKINSTANCECOMPLETED >= @frDate  AND TASKINSTANCECOMPLETED <= @toDate AND IPS.KEYDEPARTMENT = 143 
AND IPS.KEYPROCESSSTREAM IN (46486,52344,52345,52346,56853,56854,56855,56856)--,22265,53181) 

IF OBJECT_ID ('TEMPDB..#Stats') IS NOT NULL DROP TABLE #Stats
SELECT DISTINCT * INTO #Stats FROM 
(SELECT KEYPERSON,SPGMIEIN, LOGINNAME,KEYPROCESSSTREAM,STREAMNAME,PROCESSINSTANCEAPPIANID ,TASKINSTANCEBEGUN,TASKINSTANCECOMPLETED,TASKINSTANCEEFFORT,EXPECTEDTASKEFFORT
,PROCESSWORKUNITS,SNLANALYSTTASKENTRY,INTERNALNOTES,FIELDIDENTIFIER , PROCESSFIELDVALUE FROM #Pathfinder) AS PathSOURCE 
PIVOT ( MAX (PROCESSFIELDVALUE) FOR FIELDIDENTIFIER IN (Taskname,Records,emailSubject)) AS PathPIVOT 

--SELECT * FROM #Stats

IF OBJECT_ID ('TEMPDB..#22264') IS NOT NULL DROP TABLE #22264
SELECT DISTINCT KEYPERSON,SPGMIEIN, LOGINNAME,KEYPROCESSSTREAM,STREAMNAME,PROCESSINSTANCEAPPIANID,TaskInstanceBegun,TASKINSTANCECOMPLETED,ProcessWorkUnits,Taskname,SNLANALYSTTASKENTRY,CONVERT(INT,Records) AS records ,INTERNALNOTES comment_note, emailSubject,
CASE SNLANALYSTTASKENTRY WHEN 0 THEN 'Data Not Update' WHEN 1 THEN 'Data Updated' ELSE 'Previous update' END AS User_input,TASKINSTANCEEFFORT AS timetaken,EXPECTEDTASKEFFORT AS Targettime INTO #22264 FROM #Stats

--WHERE SPGMIEIN <> 710834510

IF OBJECT_ID ('TEMPDB..#22265') IS NOT NULL DROP TABLE #22265
SELECT DISTINCT CONVERT(VARCHAR(10),TaskInstanceCompleted -'6:20',101)   TASKINSTANCECOMPLETED ,pfe.KeyPerson, SPGMIEIN,pfe.EmployeeFullName, pfe.SupervisorFullName,KeyProcessStream,StreamName,ProcessInstanceAppianID,TaskInstanceBegun,--TaskInstanceCompleted,
timetaken,Targettime,ProcessWorkUnits,SNLANALYSTTASKENTRY,TASKINSTANCECOMPLETED AS insertdate, emailSubject INTO #22265 FROM #22264 
INNER JOIN dbo.PFEmployee PFE ON pfe.KeyPerson = #22264.KeyPerson
WHERE KeyProcessStream IN (46486,52344,52345,52346,56853,56854,56855,56856)--,22265,53181)


IF OBJECT_ID ('TEMPDB..#22266') IS NOT NULL DROP TABLE #22266
SELECT
    emailSubject,
	TASKINSTANCECOMPLETED,
	KeyPerson,
	KeyProcessStream,
	ProcessInstanceAppianID,
    CASE
        WHEN emailSubject LIKE 'Translated Version Available For : VID#%' THEN
            CASE 
                WHEN CHARINDEX(' of CID#', emailSubject) > CHARINDEX(':', emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX(':', emailSubject) + 6, CHARINDEX(' of CID#', emailSubject) - CHARINDEX(':', emailSubject) - 6)
                ELSE 'Unknown'
            END
        WHEN emailSubject LIKE 'Got Error Out By Estimates Translation Service Version ID#%</br>%' THEN
            CASE
                WHEN CHARINDEX('-', emailSubject) < CHARINDEX(' CID', emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX('-', emailSubject) + 1, CHARINDEX(' CID', emailSubject) - CHARINDEX('-', emailSubject) - 1)
                ELSE 'Unknown'
            END
        WHEN emailSubject LIKE 'VID %CID%' THEN
            CASE
                WHEN CHARINDEX(' CID', emailSubject) > CHARINDEX('VID ', emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX('VID ', emailSubject) + 4, CHARINDEX(' CID', emailSubject) - CHARINDEX('VID ', emailSubject) - 4)
                ELSE 'Unknown'
            END
        WHEN emailSubject LIKE 'Translation required for%' THEN
            CASE
                WHEN CHARINDEX('_', emailSubject, CHARINDEX('for_', emailSubject) + 4) > CHARINDEX('for_', emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX('for_', emailSubject) + 4, CHARINDEX('_', emailSubject, CHARINDEX('for_', emailSubject) + 4) - CHARINDEX('for_', emailSubject) - 4)
                ELSE 'Unknown'
            END
        ELSE 'Unknown'
    END AS VID,
    
    CASE
        WHEN emailSubject LIKE '% of CID# %' THEN
            SUBSTRING(emailSubject, CHARINDEX(' of CID# ', emailSubject) + 9, 1000)
        WHEN emailSubject LIKE '%CID %' AND emailSubject NOT LIKE '%CID#%' AND emailSubject NOT LIKE '%</br>%' THEN
            SUBSTRING(emailSubject, CHARINDEX('CID ', emailSubject) + 4, 1000)
        WHEN emailSubject LIKE '%CID# %' THEN
            SUBSTRING(emailSubject, CHARINDEX('CID# ', emailSubject) + 5, 1000)
		WHEN emailSubject LIKE '% of CID# </br>%' THEN
			SUBSTRING(emailSubject, CHARINDEX('</br>', emailSubject) + 5, LEN(emailSubject) - CHARINDEX('</br>', emailSubject) - 4)
        WHEN emailSubject LIKE '%</br>%CID%' THEN
            CASE
                WHEN CHARINDEX('CID', emailSubject, CHARINDEX('</br>', emailSubject)) + 4 < LEN(emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX('CID', emailSubject, CHARINDEX('</br>', emailSubject)) + 4, 1000)
                ELSE 'Unknown'
            END
        WHEN emailSubject LIKE 'Translation required for%' THEN
            CASE
                WHEN CHARINDEX('_', emailSubject, CHARINDEX('for_', emailSubject) + 4) < CHARINDEX('_Korean', emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX('_', emailSubject, CHARINDEX('for_', emailSubject) + 4) + 1, CHARINDEX('_Korean', emailSubject) - CHARINDEX('_', emailSubject, CHARINDEX('for_', emailSubject) + 4) - 1)
                ELSE 'Unknown'
            END
        ELSE 'Unknown'
    END AS CID
INTO #22266
FROM
    #22265


SELECT A.*,B.VID AS VERSIONID,B.CID AS COMPANYID FROM #22265 A
LEFT JOIN #22266 B ON A.ProcessInstanceAppianID=B.ProcessInstanceAppianID AND A.TASKINSTANCECOMPLETED=B.TASKINSTANCECOMPLETED
AND A.KeyPerson=B.KeyPerson AND A.KeyProcessStream=B.KeyProcessStream AND A.emailSubject=B.emailSubject

























