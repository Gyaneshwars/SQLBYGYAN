USE Pathfinder 

---Please Provide ProcessInstanceInstantiated Date Here
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2024-01-01 00:00:00' ---Task details entered date
SET @toDate = '2024-12-30 00:00:00' ---Task details entered date

---Please Provide Task Done Date Here
DECLARE @frDate1 AS DATETIME, @toDate1 AS DATETIME
SET @frDate1 = '2024-01-17'  ---(YYYY-MM-DD)---Task done date
SET @toDate1 = '2024-01-19'  ---(YYYY-MM-DD)---Task done date

IF OBJECT_ID ('TEMPDB..#QueuedPF') IS NOT NULL DROP TABLE #QueuedPF
SELECT DISTINCT IPS.KEYPROCESSSTREAM,IPS.STREAMNAME, IPI.PROCESSINSTANCEAPPIANID,IPI.ProcessInstanceInstantiated,IPI.ProcessInstanceDescription,ti.SNLAnalystTaskEntry
,PDV.FIELDIDENTIFIER,PDV.PROCESSFIELDVALUE,PN.InternalNotes,ti.Rapidaccept,ti.keyperson,ti.taskname,ti.TaskInstanceBegun,ti.TaskInstanceCompleted,ti.TaskInstanceEffort,
C.ContentMetric,TICM.[ContentMetricValue],TICM.[ContentMetricGroup],IPI.processinstancecompleted,p.bestpersonname into #QueuedPF  FROM PROCESSINSTANCE IPI
FULL JOIN PROCESSSTREAM IPS ON IPI.KEYPROCESSSTREAM = IPS.KEYPROCESSSTREAM 
FULL JOIN DBO.PROCESSSTREAMGROUP PG ON PG.KEYPROCESSSTREAM=IPS.KEYPROCESSSTREAM
FULL JOIN dbo.ProcessDataValue PDV on pdv.KeyProcessInstance=ipi.KeyProcessInstance
FULL JOIN dbo.taskinstance ti on ti.keyprocessinstance=ipi.keyprocessinstance
FULL JOIN dbo.TaskInstanceContentMetric TICM on TI.[KeyTaskInstance]=TICM.[KeyTaskInstance]
FULL JOIN dbo.contentmetric C on c.keycontentmetric=TICM.keycontentmetric
FULL JOIN dbo.ProcessNotes PN ON PN.KeyProcessInstance=ipi.KeyProcessInstance
LEFT JOIN snledit..person p ON p.keyperson=ti.keyperson
WHERE IPI.keyprocessstream in (58076)
AND IPI.ProcessInstanceInstantiated > @frDate   ---Task details entered date
AND IPI.ProcessInstanceInstantiated < @toDate   ---Task details entered date
--and ti.TaskInstanceCompleted is not null
--and IPI.ProcessInstanceAppianID in (-1319782567)
--and ipi.ProcessInstanceCompleted is null 
--and IPI.UpdOperation=1
--select DISTINCT  contentmetric from  #QueuedPF
IF OBJECT_ID ('TEMPDB..#RESULTS') IS NOT NULL DROP TABLE #RESULTS
SELECT DISTINCT * INTO #RESULTS FROM #QueuedPF
PIVOT (MAX(PROCESSFIELDVALUE) FOR FIELDIDENTIFIER IN
([Date],
[Day],
Manager,
Manager2, 
Manager3,
[Location],
Strength,
Leaves,
Weekoff,
Overtime,
NetManpower,
CoreWorkFTE,
NonCoreWorkFTE,
WorkfromOffice))AS PathPIVOT    
PIVOT (MAX(ContentMetricValue) FOR ContentMetric IN
([Non-Core work description],[Comments],[Non-Core work FTE]))AS PathPIVOT 

IF OBJECT_ID ('TEMPDB..#RESULTS1') IS NOT NULL DROP TABLE #RESULTS1
SELECT *,CONVERT(DATE,FORMAT(CAST([Date] AS DATETIME), 'yyyy-MM-dd')) AS DoneDate INTO #RESULTS1 FROM #RESULTS

IF OBJECT_ID ('TEMPDB..#RESULTS2') IS NOT NULL DROP TABLE #RESULTS2
SELECT KEYPROCESSSTREAM,STREAMNAME,PROCESSINSTANCEAPPIANID,ProcessInstanceInstantiated,ProcessInstanceDescription,SNLAnalystTaskEntry,InternalNotes,Rapidaccept,keyperson,taskname,TaskInstanceBegun,TaskInstanceCompleted,TaskInstanceEffort,ContentMetricGroup,processinstancecompleted,bestpersonname,Date,Day,Manager,Manager2,Manager3,Location,Strength,Leaves,Weekoff,Overtime,NetManpower,CoreWorkFTE,NonCoreWorkFTE,WorkfromOffice,[Non-Core work description],[Comments],[Non-Core work FTE],DoneDate INTO #RESULTS2 FROM #RESULTS1
WHERE [DoneDate]>@frDate1 AND [DoneDate]<@toDate1

--SELECT * FROM #RESULTS2
--SELECT * FROM #RESULTS1

IF OBJECT_ID ('TEMPDB..#PIVOT') IS NOT NULL DROP TABLE #PIVOT
SELECT DISTINCT KEYPROCESSSTREAM,STREAMNAME,bestpersonname,Date,Day,Strength,isnull(Leaves,0) Leaves,isnull(Weekoff,0) Weekoff,isnull(Overtime,0) Overtime,isnull(NetManpower,0) NetManpower,isnull(CoreWorkFTE,0) CoreWorkFTE,isnull(NonCoreWorkFTE,0) NonCoreWorkFTE INTO #PIVOT FROM #RESULTS2
WHERE TaskInstanceCompleted IS NOT NULL



IF OBJECT_ID ('TEMPDB..#DAILY') IS NOT NULL DROP TABLE #DAILY
SELECT DISTINCT (DATENAME(MONTH,(Date))) MONTH,Date,Day,SUM(CAST(Strength AS float)) AS Strength,SUM(CAST(Leaves AS float)) AS Leaves,SUM(CAST(Weekoff AS float))Weekoff,SUM(CAST(Overtime AS float))Overtime,
SUM(CAST(NetManpower AS float))NetManpower,SUM(CAST(CoreWorkFTE AS float))CoreWorkFTE,SUM(CAST(NonCoreWorkFTE AS float))NonCoreWorkFTE
INTO #DAILY FROM #PIVOT
GROUP BY Date,Day

IF OBJECT_ID ('TEMPDB..#MONTHLY') IS NOT NULL DROP TABLE #MONTHLY
SELECT DISTINCT MONTH,SUM(Strength) AS Strength,SUM(Leaves) AS Leaves,SUM(Weekoff)Weekoff,SUM(Overtime)Overtime,
SUM(NetManpower)NetManpower,SUM(CoreWorkFTE)CoreWorkFTE,SUM(NonCoreWorkFTE)NonCoreWorkFTE
INTO #MONTHLY  FROM #DAILY
GROUP BY MONTH

IF OBJECT_ID ('TEMPDB..#PIVOTtext') IS NOT NULL DROP TABLE #PIVOTtext
SELECT DISTINCT KEYPROCESSSTREAM,STREAMNAME,bestpersonname,Date,Day,Strength,isnull(Leaves,0) Leaves,isnull(Weekoff,0) Weekoff,isnull(Overtime,0) Overtime,isnull(NetManpower,0) NetManpower,isnull(CoreWorkFTE,0) CoreWorkFTE,isnull(NonCoreWorkFTE,0) NonCoreWorkFTE,[Non-Core work FTE],[Comments],[Non-Core work description] INTO #PIVOTtext FROM #RESULTS2
WHERE [Non-Core work FTE] IS NOT NULL

IF OBJECT_ID ('TEMPDB..#DAILYtext') IS NOT NULL DROP TABLE #DAILYtext
SELECT DISTINCT (DATENAME(MONTH,(Date))) MONTH,Date,Day,[Non-Core work description],[Comments],SUM(CAST([Non-Core work FTE] AS float))NonCoreWorkFTE
INTO #DAILYtext FROM #PIVOTtext
GROUP BY Date,Day,[Non-Core work description] ,[Comments]

IF OBJECT_ID ('TEMPDB..#MONTHLYtext') IS NOT NULL DROP TABLE #MONTHLYtext
SELECT DISTINCT MONTH,[Non-Core work description],[Comments],SUM(NonCoreWorkFTE) AS NonCoreWorkFTE 
INTO #MONTHLYtext FROM #DAILYtext
GROUP BY MONTH,[Non-Core work description],[Comments]; 

--select * from #RESULTS order by Date

IF OBJECT_ID ('TEMPDB..#Final') IS NOT NULL DROP TABLE #Final
SELECT DISTINCT KEYPROCESSSTREAM,STREAMNAME,PROCESSINSTANCEAPPIANID,ProcessInstanceInstantiated,ProcessInstanceDescription,SNLAnalystTaskEntry,InternalNotes,Rapidaccept,keyperson,
taskname,TaskInstanceBegun,TaskInstanceCompleted,TaskInstanceEffort,processinstancecompleted,bestpersonname,Date,Day,Manager,Manager2,Manager3,Location,
Strength,Leaves,Weekoff,Overtime,NetManpower,CoreWorkFTE,NonCoreWorkFTE,WorkfromOffice,STRING_AGG([Comments], ',') AS [Comments],STRING_AGG([Non-Core work description], ',') AS [Non-Core work description],
STRING_AGG(CAST(NonCoreWorkFTE AS NVARCHAR), ',') AS NonCoreWorkFTE1,DoneDate INTO #Final FROM #RESULTS2
WHERE TaskInstanceCompleted IS NOT NULL
GROUP BY KEYPROCESSSTREAM,STREAMNAME,PROCESSINSTANCEAPPIANID,ProcessInstanceInstantiated,ProcessInstanceDescription,SNLAnalystTaskEntry,InternalNotes,Rapidaccept,keyperson,
taskname,TaskInstanceBegun,TaskInstanceCompleted,TaskInstanceEffort,processinstancecompleted,bestpersonname,Date,Day,Manager,Manager2,Manager3,Location,
Strength,Leaves,Weekoff,Overtime,NetManpower,CoreWorkFTE,NonCoreWorkFTE,WorkfromOffice,DoneDate;



WITH ConvertedTable AS (
    SELECT 
        Manager3, 
        [Non-Core work description], 
        CONVERT(DECIMAL(10, 2), [Non-Core work FTE]) AS NonCoreWorkFTE
    FROM #RESULTS2
)
SELECT
    Manager3,
    ISNULL([Segment /Product Research], 0) AS [Segment /Product Research],
    ISNULL([Data Transformation/Foreseer], 0) AS [Data Transformation/Foreseer],
    ISNULL([SNL duites], 0) AS [SNL duites],
    ISNULL([Training], 0) AS [Training],
    ISNULL([Smart Sourcing], 0) AS [Smart Sourcing],
    ISNULL([Dily Queries], 0) AS [Dily Queries],
    ISNULL([Missing Actuals/Guidance/NHL], 0) AS [Missing Actuals/Guidance/NHL],
    ISNULL([Others If Any], 0) AS [Others If Any]
FROM
       ConvertedTable
PIVOT
    (
        SUM(NonCoreWorkFTE)
        FOR [Non-Core work description] IN (
            [Segment /Product Research], 
            [Training], 
            [Others If Any],
            [Data Transformation/Foreseer],
            [SNL duites],
            [Smart Sourcing],
            [Dily Queries],
            [Missing Actuals/Guidance/NHL]
        )
    ) AS PivotTable;

--SELECT DISTINCT * FROM #RESULTS WHERE TaskInstanceCompleted IS NOT NULL 

SELECT DISTINCT * FROM #Final WHERE TaskInstanceCompleted IS NOT NULL 
ORDER BY Date

SELECT * FROM #DAILY
order by Date
SELECT * FROM #MONTHLY
select * from #DAILYtext
order by day
select * from #MONTHLYtext