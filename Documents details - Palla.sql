
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-07-24 6:00:00.000'
SET @toDate = '2023-07-25 05:59:59.999'
IF OBJECT_ID('TEMPDB..#Cat') IS NOT NULL DROP TABLE #Cat  CREATE TABLE #Cat (PriorityID int,Cat varchar(3)); INSERT INTO #Cat VALUES  
(1,'A'),(3,'G'),(4,'E'),(5,'E'),(6,'E'),(7,'E'),(8,'E'),(13,'E'),(14,'A'),(18,'E'),(20,'A'),(30,'HL'),(31,'E'),(32,'A'),(33,'NHL'),(19,'NHL'),(46,'E'),(55,'A'),(90,'E'),(128,'E')
,(130,'E'),(143,'A'),(145,'E'),(149,'E'),(9,'HA'),(10,'HG'),(11,'HE'),(15,'HA'),(19,'HE'),(47,'HE'),(56,'HA')
IF OBJECT_ID('TEMPDB..#CT') IS NOT NULL DROP TABLE #CT 
SELECT distinct CT.*,B.Cat,Convert(varchar(10),ct.Enddate-'6:00',101)Date,Convert(varchar(10),insertedDate-'6:00',101)Date2,cp.collectionProcessName INTO #CT 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw ct
INNER JOIN #Cat B on Ct.PriorityID = B.PriorityID
Left join workflow_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl cdp (Nolock) on cdp.collectionEntityToProcessId = ct.collectionEntityToProcessId and datapointid  = 1887
Left join Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl  est on est.industrysubtypeid = cdp.value 
Left join workflow_Estimates.dbo.collectionprocess_tbl cp on cp.collectionProcessId = isnull(est.collectionProcessId,ct.collectionProcessId)
WHERE ct.collectionStageId in (2,155,219,220,221)  and CT.collectionProcessId in (64,1062,4897,4898) AND collectionEntityTypeId = 9
AND ((ct.insertedDate > = @frDate  AND ct.insertedDate <= @toDate) OR (ct.Enddate> = @frDate  AND ct.Enddate <= @toDate))
--select * from #ct where collectionstagestatusid=5

IF OBJECT_ID('TEMPDB..#Processed') IS NOT NULL DROP TABLE #Processed 
SELECT distinct Date,Cat,collectionStageId,COUNT(collectionEntityId)Cnt INTO #Processed
FROM #CT WHERE Enddate> = @frDate  AND Enddate <= @toDate AND collectionStageStatusId in (4)
GROUP BY Cat,collectionStageId,Date
--select * from #Processed

IF OBJECT_ID('TEMPDB..#Inserted') IS NOT NULL DROP TABLE #Inserted
SELECT distinct Date2 Date,Cat,collectionStageId,COUNT(collectionEntityId)Cnt INTO #Inserted FROM #CT
WHERE insertedDate> = @frDate  AND insertedDate <= @toDate --AND collectionStageStatusId in (4)
GROUP BY Cat,Date2,collectionStageId
--select * from #Inserted

IF OBJECT_ID('TEMPDB..#Skipp') IS NOT NULL DROP TABLE #Skipp
SELECT distinct Date,Cat,collectionStageId,COUNT(collectionEntityId)Cnt INTO #Skipp FROM #CT 
WHERE Enddate> = @frDate  AND Enddate <= @toDate AND collectionStageStatusId in (5)
GROUP BY Cat,collectionStageId,Date
--select * from #Skipp

	SELECT DISTINCT A.Date,ISNULL(E.Cnt,0) Hist_iss_Est,ISNULL(F.Cnt,0) Hist_iss_Act,ISNULL(G.Cnt,0) Hist_iss_Gui ,
	(ISNULL(E.Cnt,0) + ISNULL(F.Cnt,0) + ISNULL(G.Cnt,0)) TOTAL,
	ISNULL(H.cnt,0) Recent_Iss_est ,ISNULL(I.cnt,0) Recent_Iss_Act,ISNULL(J.cnt,0) Recent_Iss_G,ISNULL(K.cnt,0) Recent_Iss_NHL,
	ISNULL(L.cnt,0) Recent_Iss_AFFH,ISNULL(m.cnt,0)Recent_Iss_AFFNHL,
	ISNULL(H.cnt,0)+ISNULL(I.cnt,0)+ISNULL(J.cnt,0)+ISNULL(K.cnt,0)+ISNULL(L.cnt,0)+ISNULL(m.cnt,0)+ISNULL(am.cnt,0)+ISNULL(an.cnt,0)+ISNULL(ao.cnt,0)TOTAL
	,ISNULL(E.Cnt,0)+ISNULL(H.cnt,0),ISNULL(F.Cnt,0)+ISNULL(I.cnt,0),
	ISNULL(G.Cnt,0)+ISNULL(J.cnt,0),ISNULL(K.cnt,0),ISNULL(L.cnt,0),ISNULL(m.cnt,0),
	ISNULL(E.Cnt,0)+ISNULL(H.cnt,0)+ISNULL(F.Cnt,0)+ISNULL(I.cnt,0)+ISNULL(G.Cnt,0)+ISNULL(J.cnt,0)+ISNULL(K.cnt,0)+ISNULL(L.cnt,0)+ISNULL(m.cnt,0) TOTAL,
	ISNULL(B.Cnt,0) Historical_Est ,ISNULL(C.Cnt,0) Historical_Act,ISNULL(D.Cnt,0) Historical_Gui,(ISNULL(B.Cnt,0) +ISNULL(C.Cnt,0) +ISNULL(D.Cnt,0))TOTAL,
	ISNULL(n.cnt,0) Recent_proc_est ,ISNULL(o.cnt,0)+ISNULL(bs.cnt,0) Recent_proc_Act,ISNULL(p.cnt,0)+ISNULL(bu.cnt,0) Recent_proc_G,ISNULL(q.cnt,0) Recent_proc_NHL,
	ISNULL(r.cnt,0) Recent_proc_AFFH,ISNULL(s.cnt,0) Recent_proc_AFFNHL,	
	ISNULL(n.cnt,0) + ISNULL(o.cnt,0) + ISNULL(p.cnt,0)+ ISNULL(q.cnt,0) +	ISNULL(r.cnt,0) + ISNULL(s.cnt,0)+ISNULL(bs.cnt,0)+ISNULL(bt.cnt,0)+ISNULL(bu.cnt,0) TOTAL,
	
	
	ISNULL(B.Cnt,0) +ISNULL(n.cnt,0) Total_Proc_EST,
	ISNULL(C.Cnt,0) +ISNULL(o.cnt,0)+ISNULL(bs.cnt,0) Total_Proc_Act
	,ISNULL(D.Cnt,0)+ISNULL(p.cnt,0)+ISNULL(bu.cnt,0) Total_Proc_Gui,
	ISNULL(q.cnt,0)  Total_proc_NHL,isNULL(r.cnt,0) Total_proc_AFFH,ISNULL(s.cnt,0) Total_proc_AFFNHL,0,
	ISNULL(t.Cnt,0) Historical_Skipp_Est 	
	,ISNULL(u.Cnt,0) Historical_Skipp_Act
	,ISNULL(v.Cnt,0) Historical_Skipp_Gui 	
	,ISNULL(t.Cnt,0)+ISNULL(u.Cnt,0)+ISNULL(V.Cnt,0) TOTAL
	
	,ISNULL(w.Cnt,0) Recent_Skipp_Est 	
	,ISNULL(x.Cnt,0)+ISNULL(cz.Cnt,0) Recent_Skipp_Act
	,ISNULL(y.Cnt,0)+ISNULL(cb.Cnt,0) Recent_Skipp_Gui 	
	,ISNULL(Z.Cnt,0)+ISNULL(ca.Cnt,0) Recent_Skipp_NHL 	
	,ISNULL(W.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0)+ISNULL(cz.Cnt,0)+ISNULL(ca.Cnt,0)+ISNULL(cb.Cnt,0)  TOTAL
	
	
	
	FROM #Processed A
	LEFT JOIN #Inserted E ON E.Cat='HE' AND A.Date= E.Date
	LEFT JOIN #Inserted F ON E.Cat='HA' AND A.Date= F.Date
	LEFT JOIN #Inserted G ON E.Cat='HG' AND A.Date= G.Date
	
	LEFT JOIN #Inserted H ON h.Cat='E' AND A.Date= h.Date AND h.collectionStageId=2
	LEFT JOIN #Inserted I ON i.Cat='A' AND A.Date= I.Date AND i.collectionStageId=2
	LEFT JOIN #Inserted J ON j.Cat='G' AND A.Date= j.Date AND j.collectionStageId=2
	LEFT JOIN #Inserted k ON k.Cat='nhl' AND A.Date= k.Date AND k.collectionStageId=2
	LEFT JOIN #Inserted L ON L.Cat='A' AND A.Date= L.Date AND L.collectionStageId=155
	LEFT JOIN #Inserted m ON m.Cat='nhl' AND A.Date= m.Date AND m.collectionStageId=155
	LEFT JOIN #Inserted am ON am.Cat='A' AND A.Date= am.Date AND am.collectionStageId=219
	LEFT JOIN #Inserted an ON an.Cat='NHL' AND A.Date= an.Date AND an.collectionStageId=220
	LEFT JOIN #Inserted ao ON ao.Cat='G' AND A.Date= ao.Date AND ao.collectionStageId=221
		
	LEFT JOIN #Processed B ON B.Cat='HE' AND A.Date= B.Date
	LEFT JOIN #Processed C ON C.Cat='HE' AND A.Date= C.Date
	LEFT JOIN #Processed D ON D.Cat='HG' AND A.Date= D.Date
		
	LEFT JOIN #Processed n ON n.Cat='E' AND A.Date= n.Date AND n.collectionStageId=2
	LEFT JOIN #Processed o ON o.Cat='A' AND A.Date= o.Date AND o.collectionStageId=2
	LEFT JOIN #Processed p ON p.Cat='G' AND A.Date= p.Date AND p.collectionStageId=2
	LEFT JOIN #Processed q ON q.Cat='nhl' AND A.Date= q.Date AND q.collectionStageId=2
	LEFT JOIN #Processed r ON r.Cat='A' AND A.Date= r.Date AND r.collectionStageId=155
	LEFT JOIN #Processed s ON s.Cat='nhl' AND A.Date= s.Date AND s.collectionStageId=155
	LEFT JOIN #Processed bs ON bs.Cat='A' AND A.Date= bs.Date AND bs.collectionStageId=219
	LEFT JOIN #Processed bt ON bt.Cat='NHL' AND A.Date= bt.Date AND bt.collectionStageId=220
	LEFT JOIN #Processed bu ON bu.Cat='G' AND A.Date= bu.Date AND bu.collectionStageId=221
	
	LEFT JOIN #Skipp T ON T.Cat='HE' AND A.Date= t.Date 
	LEFT JOIN #Skipp U ON U.Cat='HA' AND A.Date= u.Date 		
	LEFT JOIN #Skipp V ON V.Cat='HG' AND A.Date= v.Date 


	LEFT JOIN #Skipp W ON W.Cat='E' AND A.Date= W.Date AND w.collectionStageId =2
	LEFT JOIN #Skipp X ON X.Cat='A' AND A.Date= X.Date AND X.collectionStageId =2
	LEFT JOIN #Skipp Y ON Y.Cat='G' AND A.Date= Y.Date AND y.collectionStageId =2
	LEFT JOIN #Skipp Z ON Z.Cat='NHL' AND A.Date= Z.Date AND Z.collectionStageId =2
	LEFT JOIN #Skipp cZ ON cZ.Cat='A' AND A.Date= cz.Date AND cZ.collectionStageId =219
	LEFT JOIN #Skipp ca ON ca.Cat='NHL' AND A.Date= ca.Date AND ca.collectionStageId =220
	LEFT JOIN #Skipp cb ON cb.Cat='G' AND A.Date= cb.Date AND cb.collectionStageId =221

SELECT distinct Date2 Date,Cat,collectionStageId,collectionProcessName, COUNT(collectionEntityId)Cnt FROM #CT
WHERE insertedDate> = @frDate  AND insertedDate <= @toDate --and cat='e'
GROUP BY Cat,Date2,collectionStageId,collectionProcessName
