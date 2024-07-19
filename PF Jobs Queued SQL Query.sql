--PYTHO,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE Pathfinder
DECLARE @frDate DATETIME, @toDate DATETIME 
--SET @frDate = '2019-11-01 06:00:00.000' -- Give From Date here 
--SET @toDate = '2019-11-10 23:59:00.000'-- Give To Date here

IF OBJECT_ID ('TEMPDB..#Pathfinders') IS NOT NULL DROP TABLE #Pathfinders
SELECT DISTINCT P.KEYPERSON,P.SPGMIEIN, P.LOGINNAME,IPS.KEYPROCESSSTREAM,IPS.STREAMNAME , IPI.PROCESSINSTANCEAPPIANID ,TASKINSTANCEBEGUN=TI.TASKINSTANCEBEGUN + '5:30'
,TASKINSTANCECOMPLETED=TI.TASKINSTANCECOMPLETED + '5:30',TI.TASKINSTANCEEFFORT,TI.EXPECTEDTASKEFFORT,IPI.PROCESSWORKUNITS,TI.SNLANALYSTTASKENTRY,
PN.INTERNALNOTES,PDV.FIELDIDENTIFIER,PDV.PROCESSFIELDVALUE,ipi.ProcessInstanceDescription INTO #Pathfinders FROM PROCESSINSTANCE IPI
INNER JOIN PROCESSSTREAM IPS ON IPI.KEYPROCESSSTREAM = IPS.KEYPROCESSSTREAM AND IPS.UPDOPERATION < 2
INNER JOIN DBO.PROCESSSTREAMGROUP PG ON PG.KEYPROCESSSTREAM=IPS.KEYPROCESSSTREAM
JOIN TASKINSTANCE TI ON IPI.KEYPROCESSINSTANCE = TI.KEYPROCESSINSTANCE AND  TI.UPDOPERATION < 2
JOIN DBO.PROCESSDATAVALUE PDV ON PDV.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN DBO.PROCESSNOTES PN ON PN.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN InternalUseOnly.DBO.EMPLOYEE P ON TI.KEYPERSON = P.KEYPERSON
WHERE IPI.UPDOPERATION < 2 AND TASKINSTANCECOMPLETED BETWEEN GETDATE()-360 AND GETDATE()  
AND IPS.KEYPROCESSSTREAM IN (23849) --,46486,52344,52345,52346,56853,56854,56855,56856)

--SELECT * FROM #Pathfinder

IF OBJECT_ID ('TEMPDB..#queued') IS NOT NULL DROP TABLE #queued
SELECT DISTINCT P.KEYPERSON,P.SPGMIEIN, P.LOGINNAME,IPS.KEYPROCESSSTREAM,IPS.STREAMNAME , IPI.PROCESSINSTANCEAPPIANID,IPI.PROCESSWORKUNITS,
PN.INTERNALNOTES,PDV.FIELDIDENTIFIER,PDV.PROCESSFIELDVALUE,ipi.ProcessInstanceDescription INTO #queued FROM PROCESSINSTANCE IPI
INNER JOIN PROCESSSTREAM IPS ON IPI.KEYPROCESSSTREAM = IPS.KEYPROCESSSTREAM AND IPS.UPDOPERATION < 2
--INNER JOIN DBO.PROCESSSTREAMGROUP PG ON PG.KEYPROCESSSTREAM=IPS.KEYPROCESSSTREAM
--JOIN TASKINSTANCE TI ON IPI.KEYPROCESSINSTANCE = TI.KEYPROCESSINSTANCE 
JOIN DBO.PROCESSDATAVALUE PDV ON PDV.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN DBO.PROCESSNOTES PN ON PN.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN InternalUseOnly.DBO.EMPLOYEE P ON IPS.KeyProcessOwner = P.KEYPERSON
WHERE IPI.UPDOPERATION < 2 AND IPI.ProcessInstanceCompleted IS NULL
AND IPS.KEYPROCESSSTREAM IN (23849) ---,46486,52344,52345,52346,56853,56854,56855,56856)


IF OBJECT_ID ('TEMPDB..#queued2') IS NOT NULL DROP TABLE #queued2
SELECT DISTINCT * INTO #queued2 FROM (SELECT KEYPERSON, LOGINNAME,KEYPROCESSSTREAM,STREAMNAME,PROCESSINSTANCEAPPIANID ,
FIELDIDENTIFIER,ProcessInstanceDescription,CAST(PROCESSFIELDVALUE AS VARCHAR(MAX)) PROCESSFIELDVALUE FROM #queued)
AS pathSOURCE
PIVOT
( MAX (PROCESSFIELDVALUE) FOR FIELDIDENTIFIER IN ([emailSubject],[emailBody],[Comment],[Source]))
AS pathPIVOT

IF OBJECT_ID ('TEMPDB..#queued3') IS NOT NULL DROP TABLE #queued3
SELECT DISTINCT a.ProcessInstanceAppianID,pfj.ProcessInstanceTargetDate AS goaldate,a.StreamName,emailSubject,a.ProcessInstanceDescription AS additionalinformation, 
Comment, 'Type'='queud'  INTO #queued3 FROM #queued2 a
LEFT JOIN PFJobs PFJ ON PFJ.KeyProcessStream = a.KeyProcessStream AND PFJ.ProcessInstanceAppianID = a.ProcessInstanceAppianID
ORDER BY pfj.ProcessInstanceTargetDate DESC

SELECT * FROM #queued3

IF OBJECT_ID ('TEMPDB..#queued4') IS NOT NULL DROP TABLE #queued4
SELECT ProcessInstanceAppianID,SUBSTRING(emailSubject,CHARINDEX('VID# -', emailSubject) + LEN('VID# -')-1,CHARINDEX(' of CID#', emailSubject) - CHARINDEX('VID# -', emailSubject) - LEN('VID# -')) AS [VID#],
CASE WHEN CHARINDEX('</br>', emailSubject) > 0 THEN SUBSTRING(emailSubject,CHARINDEX('</br>', emailSubject) + LEN('</br> '),
LEN(emailSubject) - CHARINDEX('</br>', emailSubject) - LEN('</br> ') + 1) 
ELSE SUBSTRING(emailSubject,CHARINDEX('CID# ', emailSubject) + LEN('CID# '),LEN(emailSubject) - CHARINDEX('CID# ', emailSubject) - LEN('CID# ') + 1) END AS [CID#]
INTO #queued4 FROM #queued3

--SELECT Q3.*,Q4.VID#,Q4.CID# FROM #queued3 Q3
--INNER JOIN #queued4 Q4 (NOLOCK) ON q3.ProcessInstanceAppianID=q4.ProcessInstanceAppianID


SELECT emailSubject,
  ProcessInstanceAppianID,
  CASE 
    WHEN CHARINDEX('VID# -', emailSubject) > 0 AND CHARINDEX(' of CID#', emailSubject) > CHARINDEX('VID# -', emailSubject) THEN 
      SUBSTRING(
        emailSubject,
        CHARINDEX('VID# -', emailSubject) + LEN('VID# -'),
        CHARINDEX(' of CID#', emailSubject) - CHARINDEX('VID# -', emailSubject) - LEN('VID# -')
      ) 
    ELSE NULL -- Adjusted to NULL for clarity; adjust as needed
  END AS [VID#],
  CASE 
    WHEN CHARINDEX('</br>', emailSubject) > 0 THEN 
      RIGHT(
        emailSubject,
        LEN(emailSubject) - CHARINDEX('</br>', emailSubject) - LEN('</br>') + 1
      ) 
    WHEN CHARINDEX('CID# ', emailSubject) > 0 THEN 
      RIGHT(
        emailSubject,
        LEN(emailSubject) - CHARINDEX('CID# ', emailSubject) - LEN('CID# ') + 1
      )
    ELSE NULL -- Adjusted to NULL for clarity; adjust as needed
  END AS [CID#]
INTO #queued6
FROM #queued3


SELECT * FROM #queued6



--SELECT
--    -- Extract VID
--    CASE
--        WHEN emailSubject LIKE '%VID# -%' THEN
--            CAST(SUBSTRING(emailSubject, PATINDEX('%VID# -%', emailSubject) + 6, 
--                CHARINDEX(' ', emailSubject + ' ', PATINDEX('%VID# -%', emailSubject) + 6) - (PATINDEX('%VID# -%', emailSubject) + 6)) AS BIGINT)
--        WHEN emailSubject LIKE 'Translation required for -%' THEN
--            CAST(SUBSTRING(emailSubject, PATINDEX('%Translation required for -%', emailSubject) + 25, 
--                CHARINDEX('_', emailSubject, PATINDEX('%Translation required for -%', emailSubject)) - (PATINDEX('%Translation required for -%', emailSubject) + 25)) AS BIGINT)
--        WHEN emailSubject LIKE 'RE: Translation required for -%' THEN
--            CAST(SUBSTRING(emailSubject, PATINDEX('%RE: Translation required for -%', emailSubject) + 29, 
--                CHARINDEX('_', emailSubject, PATINDEX('%RE: Translation required for -%', emailSubject)) - (PATINDEX('%RE: Translation required for -%', emailSubject) + 29)) AS BIGINT)
--        ELSE NULL
--    END AS VID,
--    -- Extract CID
--    CASE
--        WHEN emailSubject LIKE '%CID# %' THEN
--            CAST(SUBSTRING(emailSubject, PATINDEX('%CID# %', emailSubject) + 5, 
--                CHARINDEX(' ', emailSubject + ' ', PATINDEX('%CID# %', emailSubject) + 5) - (PATINDEX('%CID# %', emailSubject) + 5)) AS BIGINT)
--        WHEN emailSubject LIKE '%_%_%_%' THEN
--            CAST(SUBSTRING(emailSubject, CHARINDEX('_', emailSubject) + 1, 
--                CHARINDEX('_', emailSubject, CHARINDEX('_', emailSubject) + 1) - (CHARINDEX('_', emailSubject) + 1)) AS BIGINT)
--        ELSE NULL
--    END AS CID
--FROM #queued3

--SELECT
--    emailSubject,
--    -- Attempt to extract VID based on various patterns
--    CASE
--        WHEN CHARINDEX('VID# -', emailSubject) > 0 THEN
--            SUBSTRING(emailSubject, CHARINDEX('VID# -', emailSubject) + 5,
--                NULLIF(CHARINDEX(' ', emailSubject, CHARINDEX('VID# -', emailSubject) + 5), 0) - (CHARINDEX('VID# -', emailSubject) + 5))
--        WHEN CHARINDEX('Translation required for -', emailSubject) > 0 THEN
--            SUBSTRING(emailSubject, CHARINDEX('-', emailSubject, CHARINDEX('Translation required for -', emailSubject)) + 0,
--                NULLIF(CHARINDEX('_', emailSubject, CHARINDEX('Translation required for -', emailSubject)), 0) - (CHARINDEX('-', emailSubject, CHARINDEX('Translation required for -', emailSubject)) + 0))
--        WHEN CHARINDEX('Translation required for_-', emailSubject) > 0 THEN
--            SUBSTRING(emailSubject, CHARINDEX('_-', emailSubject, CHARINDEX('Translation required for_-', emailSubject)) + 0,
--                NULLIF(CHARINDEX('_-', emailSubject, CHARINDEX('Translation required for_-', emailSubject)), 0) - (CHARINDEX('_-', emailSubject, CHARINDEX('Translation required for_-', emailSubject)) + 0))
--        ELSE
--            NULL
--    END AS VID,
--    -- Attempt to extract CID based on various patterns
--    CASE
--        WHEN CHARINDEX('CID# ', emailSubject) > 0 THEN
--            SUBSTRING(emailSubject, CHARINDEX('CID# ', emailSubject) + 5,
--                NULLIF(CHARINDEX(' ', emailSubject + ' ', CHARINDEX('CID# ', emailSubject) + 5), 0) - (CHARINDEX('CID# ', emailSubject) + 5))
--        WHEN CHARINDEX('_', emailSubject) > 0 THEN
--            SUBSTRING(emailSubject, CHARINDEX('_', emailSubject, CHARINDEX('_', emailSubject) + 1) + 1,
--                NULLIF(CHARINDEX('_', emailSubject, CHARINDEX('_', emailSubject, CHARINDEX('_', emailSubject) + 1) + 1), 0) - (CHARINDEX('_', emailSubject, CHARINDEX('_', emailSubject) + 1) + 1))
--        ELSE
--            NULL
--    END AS CID
--FROM
--    #queued3

--SELECT
--    emailSubject,
--    -- Extracting VID based on various patterns
	
--    CASE
--        WHEN CHARINDEX('VID# -', emailSubject) > 0 THEN
--            SUBSTRING(emailSubject, 
--                      CHARINDEX('VID# -', emailSubject) + 5, 
--                      CHARINDEX(' of CID#', emailSubject) - CHARINDEX('VID# -', emailSubject) - 5)
--        WHEN CHARINDEX('Translation required for -', emailSubject) > 0 THEN
--            SUBSTRING(emailSubject, 
--                      CHARINDEX('Translation required for -', emailSubject) + 25, 
--                      CHARINDEX('_', emailSubject, CHARINDEX('Translation required for -', emailSubject)) - CHARINDEX('Translation required for -', emailSubject) - 25)
--        WHEN CHARINDEX('Translation required for_ -', emailSubject) > 0 THEN
--            SUBSTRING(emailSubject, 
--                      CHARINDEX('Translation required for_ -', emailSubject) + 26, 
--                      CHARINDEX('_', emailSubject, CHARINDEX('Translation required for_ -', emailSubject)) - CHARINDEX('Translation required for_ -', emailSubject) - 24)
--        ELSE
--            NULL
--    END AS VID,
--    -- Extracting CID based on various patterns
--    CASE
--        WHEN CHARINDEX('CID# ', emailSubject) > 0 THEN
--            SUBSTRING(emailSubject, 
--                      CHARINDEX('CID# ', emailSubject) + 5, 
--                      LEN(emailSubject) - CHARINDEX('CID# ', emailSubject) - 4)
--        WHEN CHARINDEX('_', emailSubject) > 0 THEN
--            SUBSTRING(emailSubject, 
--                      CHARINDEX('_', emailSubject, CHARINDEX('_', emailSubject) + 1) + 1, 
--                      CHARINDEX('_', emailSubject, CHARINDEX('_', emailSubject, CHARINDEX('_', emailSubject) + 1) + 1) - CHARINDEX('_', emailSubject, CHARINDEX('_', emailSubject) + 1) - 1)

--        ELSE
--            NULL
--    END AS CID
--FROM
--    #queued3


--SELECT ProcessInstanceAppianID,SUBSTRING(emailSubject,CHARINDEX('VID# -', emailSubject) + LEN('VID# -')-1,CHARINDEX(' of CID#', emailSubject) - CHARINDEX('VID# -', emailSubject) - LEN('VID# -')) AS [VID#],
--CASE WHEN CHARINDEX('</br>', emailSubject) > 0 THEN SUBSTRING(emailSubject,CHARINDEX('</br>', emailSubject) + LEN('</br> '),
--LEN(emailSubject) - CHARINDEX('</br>', emailSubject) - LEN('</br> ') + 1) 
--ELSE SUBSTRING(emailSubject,CHARINDEX('CID# ', emailSubject) + LEN('CID# '),LEN(emailSubject) - CHARINDEX('CID# ', emailSubject) - LEN('CID# ') + 1) END AS [CID#]
--FROM #queued3


--SELECT emailSubject, CHARINDEX('VID# -', emailSubject) + LEN('VID# -')-1,CHARINDEX('Translation required for -', emailSubject) + LEN('Translation required for -')-1,
--CHARINDEX('RE: Translation required for -', emailSubject) + LEN('RE: Translation required for -')-1,CHARINDEX('Translation required for_-', emailSubject) + LEN('Translation required for_-')-1,


--CHARINDEX(' of CID#', emailSubject) - CHARINDEX('VID# -', emailSubject) - LEN('VID# -'),CHARINDEX('_', emailSubject) - CHARINDEX('Translation required for -', emailSubject) + LEN('Translation required for -'),
--CHARINDEX('_', emailSubject) - CHARINDEX('RE: Translation required for -', emailSubject) + LEN('RE: Translation required for -'),
--CHARINDEX('_', emailSubject) - CHARINDEX('Translation required for_-', emailSubject) + LEN('Translation required for_-')
--FROM #queued3


--SELECT emailSubject,CASE WHEN CHARINDEX('VID# -', emailSubject)>0 THEN SUBSTRING(emailSubject,CHARINDEX('VID# -', emailSubject) + LEN('VID# -')-1,CHARINDEX(' of CID#', emailSubject) - CHARINDEX('VID# -', emailSubject) - LEN('VID# -')) 
--WHEN CHARINDEX('Translation required for -', emailSubject)>0 THEN SUBSTRING(emailSubject,CHARINDEX('Translation required for -', emailSubject) + LEN('Translation required for -')-1,CHARINDEX('_', emailSubject) - CHARINDEX('Translation required for -', emailSubject) + LEN('Translation required for -'))
--WHEN CHARINDEX('RE: Translation required for -', emailSubject)>0 THEN SUBSTRING(emailSubject,CHARINDEX('RE: Translation required for -', emailSubject) + LEN('RE: Translation required for -')-1,CHARINDEX('_', emailSubject) - CHARINDEX('RE: Translation required for -', emailSubject) + LEN('RE: Translation required for -'))
--WHEN CHARINDEX('Translation required for_-', emailSubject)>0 THEN SUBSTRING(emailSubject,CHARINDEX('Translation required for_-', emailSubject) + LEN('Translation required for_-')-1,CHARINDEX('_', emailSubject) - CHARINDEX('Translation required for_-', emailSubject) + LEN('Translation required for_-'))
--ELSE NULL END AS VID

--FROM #queued3































