--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frdate='2024-03-25 00:00:00.000'
SET @todate='2024-04-30 23:59:59.999'

IF OBJECT_ID('TEMPDB..#Cat') IS NOT NULL DROP TABLE #Cat  CREATE TABLE #Cat (PriorityID int,Cat varchar(3)); INSERT INTO #Cat VALUES  
(1,'A'),(3,'G'),(4,'E'),(5,'E'),(6,'E'),(7,'E'),(8,'E'),(13,'E'),(14,'A'),(18,'E'),(20,'A'),(30,'A'),(31,'E'),(32,'E'),(33,'NHL'),(19,'NHL'),(46,'E'),(55,'A'),(90,'E'),(128,'E')
,(130,'E'),(143,'A'),(145,'E'),(149,'E'),(9,'HA'),(10,'HG'),(11,'HE'),(15,'HA'),(19,'HE'),(47,'HE'),(56,'HA'),(144,'NHL')

IF OBJECT_ID('TEMPDB..#CatFS') IS NOT NULL DROP TABLE #CatFS  CREATE TABLE #CatFS (PriorityID int,collectionStageId int, Cat varchar(3)); INSERT INTO #CatFS VALUES  
(1,215,'A'),(1,216,'NHL'),(1,219,'A'),(1,220,'NHL'),(9,215,'HA'),(9,216,'HA'),(9,219,'HA'),(9,220,'HA'),(143,215,'HA'),(143,216,'HA'),(143,219,'HA'),(143,220,'NHL'),
(3,221,'G'),(10,221,'HG'),(33,215,'A'),(33,216,'NHL'),(33,219,'A'),(33,220,'NHL'),(144,215,'A'),(144,216,'NHL'),(144,219,'A'),(144,220,'NHL')

IF OBJECT_ID('TEMPDB..#CT') IS NOT NULL DROP TABLE #CT 
SELECT DISTINCT CT.*,B.Cat,CONVERT(VARCHAR(10),ct.Enddate,101)Date,CONVERT(VARCHAR(10),insertedDate,101)Date2,cp.collectionProcessName,usr.employeenumber INTO #CT 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw ct
INNER JOIN #Cat B on Ct.PriorityID = B.PriorityID
LEFT JOIN workflow_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = ct.collectionEntityToProcessId AND cdp.datapointid  = 1887
LEFT JOIN Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN workflow_Estimates.dbo.collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,ct.collectionProcessId) 
LEFT JOIN CTAdminRepTables.dbo.user_tbl usr (NOLOCK)ON ct.userId = usr.userid
WHERE ct.collectionStageId in (2)  AND ct.collectionProcessId IN (64,1062,4861,4862,4863,4864,4899,4900,4901,4902,4903,4904,4905,4906,4907) AND ct.collectionEntityTypeId = 9
AND ((ct.insertedDate > = @frDate  AND ct.insertedDate <= @toDate) OR (ct.Enddate> = @frDate  AND ct.Enddate <= @toDate)) AND (ct.userid > 0 OR ct.userid IS NULL)


INSERT INTO #CT 
SELECT DISTINCT CT.*,B.Cat,CONVERT(VARCHAR(10),ct.Enddate,101)Date,CONVERT(VARCHAR(10),insertedDate,101)Date2,cp.collectionProcessName,usr.employeenumber 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw ct
INNER JOIN #CatFS B on Ct.collectionStageId = B.collectionStageId and ct.PriorityID = b.PriorityID
LEFT JOIN workflow_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = ct.collectionEntityToProcessId and cdp.datapointid  = 1887
LEFT JOIN Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN workflow_Estimates.dbo.collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,ct.collectionProcessId)
LEFT JOIN CTAdminRepTables.dbo.user_tbl usr (NOLOCK) ON ct.userId = usr.userid
WHERE ct.collectionStageId IN (215,216,217,219,220,221) AND ct.collectionProcessId IN (4897,4898) AND ct.collectionEntityTypeId = 9
AND ((ct.insertedDate > = @frDate  AND ct.insertedDate <= @toDate) OR (ct.Enddate> = @frDate  AND ct.Enddate <= @toDate)) AND (ct.userid > 0 OR ct.userid IS NULL)


--SELECT * FROM #CT WHERE collectionstagestatusid=5 

IF OBJECT_ID('TEMPDB..#Processed') IS NOT NULL DROP TABLE #Processed 
SELECT DISTINCT Date,Cat,COUNT(collectionEntityId)Cnt INTO #Processed
FROM #CT WHERE Enddate> = @frDate  AND Enddate <= @toDate AND collectionStageStatusId IN (4)
GROUP BY Cat,Date

--SELECT * FROM #Processed ORDER BY Date

IF OBJECT_ID('TEMPDB..#Inserted') IS NOT NULL DROP TABLE #Inserted
SELECT DISTINCT Date2 Date,Cat,COUNT(collectionEntityId)Cnt INTO #Inserted FROM #CT
WHERE insertedDate> = @frDate  AND insertedDate <= @toDate --AND collectionStageStatusId in (4)
GROUP BY Cat,Date2

--SELECT * FROM #Inserted ORDER BY Date

IF OBJECT_ID('TEMPDB..#Skipp') IS NOT NULL DROP TABLE #Skipp
SELECT DISTINCT Date,Cat,COUNT(collectionEntityId)Cnt INTO #Skipp FROM #CT 
WHERE Enddate> = @frDate  AND Enddate <= @toDate AND collectionStageStatusId IN (5,18,104)
GROUP BY Cat,Date

--SELECT * FROM #Skipp

IF OBJECT_ID('TEMPDB..#queued1') IS NOT NULL DROP TABLE #queued1
SELECT DISTINCT Date,Cat,COUNT(collectionEntityId)Cnt INTO #queued1 FROM #CT 
WHERE Date> = @frDate  AND Date <= @toDate AND collectionStageStatusId NOT IN (4,5,18,104)
GROUP BY Cat,Date

IF OBJECT_ID('TEMPDB..#autoskipped') IS NOT NULL DROP TABLE #autoskipped
SELECT DISTINCT Date,Cat,COUNT(collectionEntityId)Cnt INTO #autoskipped FROM #CT 
WHERE Enddate> = @frDate  AND Enddate <= @toDate AND ((collectionStageStatusId IN (18,104)) OR (employeenumber IN ('000266','906036','191004')))
GROUP BY Cat,Date


---SELECT * FROM #autoskipped ORDER BY Date

--if OBJECT_ID('tempdb..#e') IS NOT NULL drop table #e
--SELECT DISTINCT Date, 'Inflow' as Doc_Details,Cnt Total_COUNT INTO #e FROM #Inserted GROUP BY Date,Cnt
--UNION ALL
--SELECT DISTINCT Date, 'Outflow' as Doc_Details,Cnt Total_COUNT FROM #processed GROUP BY Date,Cnt
--UNION ALL
--SELECT DISTINCT Date, 'Outflow' as Doc_Details,Cnt Total_COUNT FROM #Skipp GROUP BY Date,Cnt

--SELECT DISTINCT * FROM #e PIVOT (MAX(total_COUNT) FOR Doc_Details IN (inflow,outflow)) AS PIVOT1 

SELECT DISTINCT 
K.Date,
ISNULL(E.Cnt,0) Hist_iss_Est,
ISNULL(F.Cnt,0) Hist_iss_Act,
ISNULL(G.Cnt,0) Hist_iss_Gui,
(ISNULL(E.Cnt,0) + ISNULL(F.Cnt,0) + ISNULL(G.Cnt,0)) HistoricalIssuedTOTAL,
ISNULL(H.cnt,0) Recent_Iss_est,
ISNULL(I.cnt,0) Recent_Iss_Act,
ISNULL(J.cnt,0) Recent_Iss_G,
ISNULL(K.cnt,0) Recent_Iss_NHL,
ISNULL(H.cnt,0)+ISNULL(I.cnt,0)+ISNULL(J.cnt,0)+ISNULL(K.cnt,0) RecentIssuedTOTAL,
ISNULL(E.Cnt,0)+ISNULL(H.cnt,0)+ISNULL(F.Cnt,0)+ISNULL(I.cnt,0)+ISNULL(G.Cnt,0)+ISNULL(J.cnt,0)+ISNULL(K.cnt,0) IssuedTOTAL,

ISNULL(B.Cnt,0) Historical_Est_Proc,
ISNULL(C.Cnt,0) Historical_Act_Proc,
ISNULL(D.Cnt,0) Historical_Gui_Proc,
(ISNULL(B.Cnt,0) +ISNULL(C.Cnt,0) +ISNULL(D.Cnt,0)) His_TOTAL_Proc,
ISNULL(n.cnt,0) Recent_est_Proc,
ISNULL(o.cnt,0) Recent_Act_Proc,
ISNULL(p.cnt,0) Recent_G_Proc,
ISNULL(q.cnt,0) Recent_NHL_Proc,
ISNULL(n.cnt,0) + ISNULL(o.cnt,0) + ISNULL(p.cnt,0)+ ISNULL(q.cnt,0)  Recent_Proc_Total,
ISNULL(B.Cnt,0) +ISNULL(n.cnt,0) Total_Est_Proc,
ISNULL(C.Cnt,0) +ISNULL(o.cnt,0)+ISNULL(q.Cnt,0) Total_Act_Proc,
ISNULL(D.Cnt,0)+ISNULL(p.cnt,0) Total_Gui_Proc,
ISNULL(q.Cnt,0) Total_NHL_Proc,
ISNULL(B.Cnt,0) +ISNULL(n.cnt,0) + ISNULL(C.Cnt,0) +ISNULL(o.cnt,0) + ISNULL(D.Cnt,0)+ISNULL(p.cnt,0)+ ISNULL(q.Cnt,0) TotalProcessed,
	
ISNULL(T.Cnt,0) Historical_Skipp_Est, 	
ISNULL(U.Cnt,0) Historical_Skipp_Act,
ISNULL(V.Cnt,0) Historical_Skipp_Gui, 	
ISNULL(T.Cnt,0)+ISNULL(U.Cnt,0)+ISNULL(V.Cnt,0) TOTAL_His_Skip,
ISNULL(W.Cnt,0) Recent_Skipp_Est, 	
ISNULL(X.Cnt,0) Recent_Skipp_Act,
ISNULL(Y.Cnt,0) Recent_Skipp_Gui, 	
ISNULL(Z.Cnt,0) Recent_Skipp_NHL, 	
ISNULL(W.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0) TOTAL_Recent_Skip,
ISNULL(T.Cnt,0)+ISNULL(U.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(W.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0) Total_SKIP,

--ISNULL(ta.Cnt,0) Historical_IPICR_Est, 	
--ISNULL(ua.Cnt,0) Historical_IPICR_Act,
--ISNULL(va.Cnt,0) Historical_IPICR_Gui, 	
--ISNULL(ta.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(Va.Cnt,0) TOTALHis_IPICR,
--ISNULL(wa.Cnt,0) Recent_IPICR_Est, 	
--ISNULL(xa.Cnt,0) Recent_IPICR_Act,
--ISNULL(ya.Cnt,0) Recent_IPICR_Gui, 	
--ISNULL(Za.Cnt,0) Recent_IPICR_NHL, 	
--ISNULL(Wa.Cnt,0)+ISNULL(Xa.Cnt,0)+ISNULL(Ya.Cnt,0)+ISNULL(Za.Cnt,0) TOTALRecent_IPICR,
--ISNULL(ta.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(Va.Cnt,0)+ISNULL(Wa.Cnt,0)+ISNULL(Xa.Cnt,0)+ISNULL(Ya.Cnt,0)+ISNULL(Za.Cnt,0) TotalIPICR,

(ISNULL(E.Cnt,0)+ISNULL(H.cnt,0)+ISNULL(F.Cnt,0)+ISNULL(I.cnt,0)+ISNULL(G.Cnt,0)+ISNULL(J.cnt,0)+ISNULL(K.cnt,0)) TotalInflow,
(ISNULL(B.Cnt,0) +ISNULL(n.cnt,0) + ISNULL(C.Cnt,0) +ISNULL(o.cnt,0) + ISNULL(D.Cnt,0)+ISNULL(p.cnt,0)+ ISNULL(q.Cnt,0)+ISNULL(T.Cnt,0)+ISNULL(U.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(W.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0)+ISNULL(ta.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(Va.Cnt,0)+ISNULL(Wa.Cnt,0)+ISNULL(Xa.Cnt,0)+ISNULL(Ya.Cnt,0)+ISNULL(Za.Cnt,0)) TotalOutFlow,

((ISNULL(E.Cnt,0)+ISNULL(H.cnt,0)+ISNULL(F.Cnt,0)+ISNULL(I.cnt,0)+ISNULL(G.Cnt,0)+ISNULL(J.cnt,0)+ISNULL(K.cnt,0))-(ISNULL(B.Cnt,0) +ISNULL(n.cnt,0) + ISNULL(C.Cnt,0) +ISNULL(o.cnt,0) + ISNULL(D.Cnt,0)+ISNULL(p.cnt,0)+ ISNULL(q.Cnt,0)+ISNULL(T.Cnt,0)+ISNULL(U.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(W.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0)+ISNULL(ta.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(Va.Cnt,0)+ISNULL(Wa.Cnt,0)+ISNULL(Xa.Cnt,0)+ISNULL(Ya.Cnt,0)+ISNULL(Za.Cnt,0))) I_O_Diff,

(ISNULL(E.Cnt,0) + ISNULL(H.cnt,0)) Estimates_Issued,
(ISNULL(F.Cnt,0) + ISNULL(G.Cnt,0) + ISNULL(I.cnt,0) + ISNULL(J.cnt,0) +ISNULL(K.cnt,0)) A_and_G_Issued,
(ISNULL(E.Cnt,0) + ISNULL(H.cnt,0) +ISNULL(F.Cnt,0) + ISNULL(G.Cnt,0) + ISNULL(I.cnt,0) + ISNULL(J.cnt,0) +ISNULL(K.cnt,0)) TotalIssued,

(ISNULL(B.Cnt,0)+ISNULL(n.cnt,0)+ISNULL(ta.Cnt,0)+ISNULL(wa.Cnt,0)+ISNULL(T.cnt,0)+ISNULL(W.cnt,0)) EstimatesProcessed,

((ISNULL(B.Cnt,0)+ISNULL(n.cnt,0)+ISNULL(ta.Cnt,0)+ISNULL(wa.Cnt,0)+ISNULL(T.cnt,0)+ISNULL(W.cnt,0))-(ISNULL(Tb.Cnt,0)+ISNULL(Wb.Cnt,0))) EstimatesProcessed_Excluding_AutoSkipped,

(ISNULL(C.Cnt,0)+ISNULL(D.Cnt,0)+ISNULL(o.cnt,0)+ISNULL(p.cnt,0)+ISNULL(q.cnt,0)+ISNULL(U.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(va.Cnt,0)+ISNULL(xa.Cnt,0)+ISNULL(ya.Cnt,0)+ISNULL(Za.Cnt,0)) A_nd_G_Processed,

((ISNULL(C.Cnt,0)+ISNULL(D.Cnt,0)+ISNULL(o.cnt,0)+ISNULL(p.cnt,0)+ISNULL(q.cnt,0)+ISNULL(U.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(va.Cnt,0)+ISNULL(xa.Cnt,0)+ISNULL(ya.Cnt,0)+ISNULL(Za.Cnt,0))-(ISNULL(Ub.Cnt,0)+ISNULL(Vb.Cnt,0)+ISNULL(Xb.Cnt,0)+ISNULL(Yb.Cnt,0)+ISNULL(Zb.Cnt,0))) A_nd_G_Processed_Excluding_AutoSkipped,

(ISNULL(B.Cnt,0)+ISNULL(n.cnt,0)+ISNULL(ta.Cnt,0)+ISNULL(wa.Cnt,0)) Estimates_Excluding_skipped,

(ISNULL(C.Cnt,0)+ISNULL(D.Cnt,0)+ISNULL(o.cnt,0)+ISNULL(p.cnt,0)+ISNULL(q.cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(va.Cnt,0)+ISNULL(xa.Cnt,0)+ISNULL(ya.Cnt,0)+ISNULL(Za.Cnt,0)) A_nd_G_Excluding_skipped,

(ISNULL(B.Cnt,0)+ISNULL(n.cnt,0)+ISNULL(ta.Cnt,0)+ISNULL(wa.Cnt,0)+ISNULL(T.cnt,0)+ISNULL(W.cnt,0)+ISNULL(C.Cnt,0)+ISNULL(D.Cnt,0)+ISNULL(o.cnt,0)+ISNULL(p.cnt,0)+ISNULL(q.cnt,0)+ISNULL(U.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(va.Cnt,0)+ISNULL(xa.Cnt,0)+ISNULL(ya.Cnt,0)+ISNULL(Za.Cnt,0)) TotalProcessed,

(ISNULL(Tb.Cnt,0)+ISNULL(Wb.Cnt,0)) Estimates_Auto_Skipped,

((ISNULL(T.Cnt,0)+ISNULL(W.Cnt,0))-(ISNULL(Tb.Cnt,0)+ISNULL(Wb.Cnt,0))) Estimates_Manual_Skipped,

(ISNULL(T.Cnt,0)+ISNULL(W.Cnt,0)) Estimates_Total_Skipped,

(ISNULL(Ub.Cnt,0)+ISNULL(Vb.Cnt,0)+ISNULL(Xb.Cnt,0)+ISNULL(Yb.Cnt,0)+ISNULL(Zb.Cnt,0)) A_nd_G_Auto_Skipped,

((ISNULL(U.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0))-(ISNULL(Ub.Cnt,0)+ISNULL(Vb.Cnt,0)+ISNULL(Xb.Cnt,0)+ISNULL(Yb.Cnt,0)+ISNULL(Zb.Cnt,0))) A_nd_G_Manual_Skipped,

(ISNULL(U.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0)) A_nd_G_Total_Skipped,

(ISNULL(T.Cnt,0)+ISNULL(W.Cnt,0)+ISNULL(U.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0)) TotalSkipped,

(ISNULL(q.cnt,0)+ISNULL(Z.Cnt,0)) NHL_Outflow
			
FROM #Processed A
LEFT JOIN #Inserted E ON E.Cat='HE' AND A.Date= E.Date
LEFT JOIN #Inserted F ON F.Cat='HA' AND A.Date= F.Date
LEFT JOIN #Inserted G ON G.Cat='HG' AND A.Date= G.Date
LEFT JOIN #Inserted H ON H.Cat='E' AND A.Date= H.Date
LEFT JOIN #Inserted I ON I.Cat='A' AND A.Date= I.Date
LEFT JOIN #Inserted J ON J.Cat='G' AND A.Date= J.Date
LEFT JOIN #Inserted K ON K.Cat='NHL' AND A.Date= K.Date

LEFT JOIN #Processed B ON B.Cat='HE' AND A.Date= B.Date
LEFT JOIN #Processed C ON C.Cat='HA' AND A.Date= C.Date
LEFT JOIN #Processed D ON D.Cat='HG' AND A.Date= D.Date	
LEFT JOIN #Processed n ON n.Cat='E' AND A.Date= n.Date
LEFT JOIN #Processed o ON o.Cat='A' AND A.Date= o.Date
LEFT JOIN #Processed p ON p.Cat='G' AND A.Date= p.Date
LEFT JOIN #Processed q ON q.Cat='NHL' AND A.Date= q.Date

LEFT JOIN #Skipp T ON T.Cat='HE' AND A.Date= T.Date 
LEFT JOIN #Skipp U ON U.Cat='HA' AND A.Date= U.Date 		
LEFT JOIN #Skipp V ON V.Cat='HG' AND A.Date= V.Date 
LEFT JOIN #Skipp W ON W.Cat='E' AND A.Date= W.Date
LEFT JOIN #Skipp X ON X.Cat='A' AND A.Date= X.Date
LEFT JOIN #Skipp Y ON Y.Cat='G' AND A.Date= Y.Date
LEFT JOIN #Skipp Z ON Z.Cat='NHL' AND A.Date= Z.Date

LEFT JOIN #queued1 Ta ON Ta.Cat='HE' AND A.Date= ta.Date 
LEFT JOIN #queued1 Ua ON Ua.Cat='HA' AND A.Date= ua.Date 		
LEFT JOIN #queued1 Va ON Va.Cat='HG' AND A.Date= va.Date 
LEFT JOIN #queued1 Wa ON Wa.Cat='E' AND A.Date= Wa.Date
LEFT JOIN #queued1 Xa ON Xa.Cat='A' AND A.Date= Xa.Date
LEFT JOIN #queued1 Ya ON Ya.Cat='G' AND A.Date= Ya.Date
LEFT JOIN #queued1 Za ON Za.Cat='NHL' AND A.Date= Za.Date

LEFT JOIN #autoskipped Tb ON Tb.Cat='HE' AND A.Date= Tb.Date 
LEFT JOIN #autoskipped Ub ON Ub.Cat='HA' AND A.Date= Ub.Date 		
LEFT JOIN #autoskipped Vb ON Vb.Cat='HG' AND A.Date= Vb.Date 
LEFT JOIN #autoskipped Wb ON Wb.Cat='E' AND A.Date= Wb.Date
LEFT JOIN #autoskipped Xb ON Xb.Cat='A' AND A.Date= Xb.Date
LEFT JOIN #autoskipped Yb ON Yb.Cat='G' AND A.Date= Yb.Date
LEFT JOIN #autoskipped Zb ON Zb.Cat='NHL' AND A.Date= Zb.Date
WHERE K.Date IS NOT NULL


SELECT DISTINCT Date2 Date,Cat,collectionStageId,collectionProcessName, COUNT(collectionEntityId)Cnt FROM #CT
WHERE insertedDate> = @frDate  AND insertedDate <= @toDate --AND cat='e'
GROUP BY Cat,Date2,collectionStageId,collectionProcessName
ORDER BY Date

SELECT DISTINCT date,Cat,collectionEntityId,relatedCompanyId,collectionProcessId,collectionstageId,
collectionstageStatusId,PriorityID,collectionProcessName,employeenumber FROM #CT 
WHERE date IS NOT NULL
ORDER BY date

--SELECT DISTINCT * FROM #CT


