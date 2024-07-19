---PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
Use PATHFINDER

IF OBJECT_ID('TEMPDB..#PF') IS NOT NULL DROP TABLE #PF
SELECT DISTINCT p.keyperson,p.SPGMIEIN,ips.KeyProcessStream,ips.StreamName, ipi.ProcessInstanceAppianID ,
ti.TaskInstanceBegun,ti.TaskInstanceCompleted,ti.TaskInstanceEffort,ti.ExpectedTaskEffort,ipi.ProcessWorkUnits,
ti.SNLAnalystTaskEntry INTO #PF FROM ProcessInstance ipi
INNER JOIN ProcessStream ips (NOLOCK) ON ipi.KeyProcessStream = ips.KeyProcessStream AND ips.UpdOperation < 2
INNER JOIN dbo.ProcessStreamGroup PSG (NOLOCK) ON Psg.KeyProcessStream=ipi.KeyProcessStream
JOIN TaskInstance ti (NOLOCK) ON ipi.KeyProcessInstance = ti.KeyProcessInstance AND  ti.UpdOperation < 2
LEFT JOIN dbo.ProcessNotes pn (NOLOCK) ON pn.KeyProcessInstance=ipi.KeyProcessInstance
LEFT JOIN  InternalUseOnly.dbo.Employee p (NOLOCK) ON ti.KeyPerson = p.KeyPerson
INNER JOIN dbo.ProcessDataValue PDV (NOLOCK) ON pdv.KeyProcessInstance=ipi.KeyProcessInstance
WHERE ipi.updoperation < 2
AND ti.TaskInstanceCompleted >= '2023-01-01 12:00:00 AM'
AND ti.TaskInstanceCompleted <= '2024-12-31 23:59:59 PM'
AND ips.KeyDepartment = 143
---AND psg.KeyProcessGroup IN (625,618)
AND ips.keyprocessstream IN (21851,75)

--SELECT * FROM #PF


IF OBJECT_ID('TEMPDB..#PF1') IS NOT NULL DROP TABLE #PF1
SELECT DISTINCT KeyProcessStream,StreamName,COUNT(KeyProcessStream) AS CountOfTasks, 
SUM(ProcessWorkUnits) AS NoofWorkUnits,SNLAnalystTaskEntry,SUM(TaskInstanceEffort) AS TotalTimeSpent,
SUM(TaskInstanceEffort)/60.0 AS TotalTimeSpenthrs,SUM(ExpectedTaskEffort) AS ExpectedTotalTimeSpent INTO #PF1 FROM #PF
GROUP BY KeyProcessStream,StreamName,SNLAnalystTaskEntry
ORDER BY KeyProcessStream

SELECT * FROM #PF1 ORDER BY KeyProcessStream,SNLAnalystTaskEntry




;WITH WorkUnitsCTE AS (
    SELECT
        KeyProcessStream,
        StreamName,
        SNLAnalystTaskEntry,
        SUM(ProcessWorkUnits) AS WorkUnits
    FROM #PF
    GROUP BY KeyProcessStream, StreamName, SNLAnalystTaskEntry
), TimeSpentHrsCTE AS (
    SELECT
        KeyProcessStream,
        StreamName,
        SNLAnalystTaskEntry,
        SUM(TaskInstanceEffort) / 60.0 AS TotalTimeSpentHrs
    FROM #PF
    GROUP BY KeyProcessStream, StreamName, SNLAnalystTaskEntry
), ExpectedTimeSpentHrsCTE AS (
    SELECT
        KeyProcessStream,
        StreamName,
        SNLAnalystTaskEntry,
        SUM(ExpectedTaskEffort) AS EXpectedTotalTimeSpentHrs
    FROM #PF
    GROUP BY KeyProcessStream, StreamName, SNLAnalystTaskEntry
), CountOfTasksCTE AS (
    SELECT
        KeyProcessStream,
        StreamName,
        COUNT(KeyProcessStream) AS CountOfTasks
    FROM #PF
    GROUP BY KeyProcessStream, StreamName
)
SELECT DISTINCT
    p.KeyProcessStream,
    p.StreamName,
	c.CountOfTasks,
    ISNULL(w.[0], 0) AS NoWorkPerformed,
    ISNULL(w.[1], 0) AS WorkPerformed,
    ISNULL(w.[2], 0) AS WorkPreviouslyPerformed,
    ISNULL(t.[0], 0) AS TotalstdTimeSpentDNU_Hrs,
    ISNULL(t.[1], 0) AS TotalstdTimeSpentDU_Hrs,
    ISNULL(t.[2], 0) AS TotalstdTimeSpentDPU_Hrs,
    ISNULL(e.[0], 0) AS AvgActualTimeDNU_Min,
    ISNULL(e.[1], 0) AS AvgActualTimeDU_Min,
    ISNULL(e.[2], 0) AS AvgActualTimeDPU_Min
FROM
    (SELECT DISTINCT KeyProcessStream, StreamName FROM #PF) p
LEFT JOIN
    (SELECT * FROM WorkUnitsCTE PIVOT(SUM(WorkUnits) FOR SNLAnalystTaskEntry IN ([0], [1], [2])) AS pv) w
    ON p.KeyProcessStream = w.KeyProcessStream AND p.StreamName = w.StreamName
LEFT JOIN
    (SELECT * FROM TimeSpentHrsCTE PIVOT(SUM(TotalTimeSpentHrs) FOR SNLAnalystTaskEntry IN ([0], [1], [2])) AS pv) t
    ON p.KeyProcessStream = t.KeyProcessStream AND p.StreamName = t.StreamName
LEFT JOIN
    (SELECT * FROM ExpectedTimeSpentHrsCTE PIVOT(SUM(EXpectedTotalTimeSpentHrs) FOR SNLAnalystTaskEntry IN ([0], [1], [2])) AS pv) e
    ON p.KeyProcessStream = e.KeyProcessStream AND p.StreamName = e.StreamName
INNER JOIN
    CountOfTasksCTE c
    ON p.KeyProcessStream = c.KeyProcessStream AND p.StreamName = c.StreamName
ORDER BY
    p.KeyProcessStream, p.StreamName;



--SELECT * FROM #PF ORDER BY KeyProcessStream,SNLAnalystTaskEntry

