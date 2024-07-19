
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-10-01 06:00:00.000'
SET @toDate = '2023-11-30 05:59:59.999'

IF OBJECT_ID('TEMPDB..#Cat') IS NOT NULL DROP TABLE #Cat  CREATE TABLE #Cat (PriorityID int,Cat varchar(3)); INSERT INTO #Cat VALUES  
(1,'A'),(3,'G'),(4,'E'),(5,'E'),(6,'E'),(7,'E'),(8,'E'),(13,'E'),(14,'A'),(18,'E'),(20,'A'),(30,'A'),(31,'E'),(32,'E'),(33,'NHL'),(19,'NHL'),(46,'E'),(55,'A'),(90,'E'),(128,'E')
,(130,'E'),(143,'A'),(145,'E'),(149,'E'),(9,'HA'),(10,'HG'),(11,'HE'),(15,'HA'),(19,'HE'),(47,'HE'),(56,'HA'),(144,'NHL')

IF OBJECT_ID('TEMPDB..#CatFS') IS NOT NULL DROP TABLE #CatFS  CREATE TABLE #CatFS (PriorityID int,collectionStageId int, Cat varchar(3)); INSERT INTO #CatFS VALUES  
(1,215,'A'),(1,216,'NHL'),(1,219,'A'),(1,220,'NHL'),(9,215,'HA'),(9,216,'HA'),(9,219,'HA'),(9,220,'HA'),(143,215,'HA'),(143,216,'HA'),(143,219,'HA'),(143,220,'NHL'),
(3,221,'G'),(10,221,'HG'),(33,215,'A'),(33,216,'NHL'),(33,219,'A'),(33,220,'NHL'),(144,215,'A'),(144,216,'NHL'),(144,219,'A'),(144,220,'NHL')

IF OBJECT_ID('TEMPDB..#CT') IS NOT NULL DROP TABLE #CT 
SELECT DISTINCT CT.*,B.Cat,CONVERT(VARCHAR(10),ct.Enddate-'6:00',101)Date,CONVERT(VARCHAR(10),insertedDate-'6:00',101)Date2,cp.collectionProcessName INTO #CT 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CT
INNER JOIN #Cat B (NOLOCK) ON Ct.PriorityID = B.PriorityID
LEFT JOIN workflow_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = ct.collectionEntityToProcessId and datapointid  = 1887
LEFT JOIN Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN workflow_Estimates.dbo.collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,ct.collectionProcessId)
WHERE ct.collectionStageId in (2)  AND CT.collectionProcessId IN (64,1062,4861,4862,4863,4864,4899,4900,4901,4902,4903,4904,4905,4906,4907) AND collectionEntityTypeId = 9
AND ((ct.insertedDate > = @frDate  AND ct.insertedDate <= @toDate) OR (ct.Enddate> = @frDate  AND ct.Enddate <= @toDate)) AND (userid > 0 OR userid IS NULL)

--SELECT * FROM #CT

INSERT INTO #CT 
SELECT DISTINCT CT.*,B.Cat,Convert(varchar(10),ct.Enddate-'6:00',101)Date,Convert(varchar(10),insertedDate-'6:00',101)Date2,cp.collectionProcessName 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CT
INNER JOIN #CatFS B (NOLOCK) ON Ct.collectionStageId = B.collectionStageId and ct.PriorityID = b.PriorityID
LEFT JOIN workflow_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = ct.collectionEntityToProcessId and datapointid  = 1887
LEFT JOIN Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN workflow_Estimates.dbo.collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,ct.collectionProcessId)
WHERE ct.collectionStageId in (215,216,219,220,221)  and CT.collectionProcessId in (4897,4898) AND collectionEntityTypeId = 9
AND ((ct.insertedDate > = @frDate  AND ct.insertedDate <= @toDate) OR (ct.Enddate> = @frDate  AND ct.Enddate <= @toDate)) AND (userid > 0 or userid IS NULL)

--select * from #ct where collectionstagestatusid=5 

IF OBJECT_ID('TEMPDB..#Processed') IS NOT NULL DROP TABLE #Processed 
SELECT DISTINCT Date,Cat,COUNT(collectionEntityId)Cnt INTO #Processed
FROM #CT WHERE Enddate> = @frDate  AND Enddate <= @toDate AND collectionStageStatusId IN (4)
GROUP BY Cat,Date
--select * from #Processed

IF OBJECT_ID('TEMPDB..#Inserted') IS NOT NULL DROP TABLE #Inserted
SELECT DISTINCT Date2 Date,Cat,COUNT(collectionEntityId)Cnt INTO #Inserted FROM #CT
WHERE insertedDate> = @frDate  AND insertedDate <= @toDate --AND collectionStageStatusId in (4)
GROUP BY Cat,Date2
--select * from #Inserted

IF OBJECT_ID('TEMPDB..#Skipp') IS NOT NULL DROP TABLE #Skipp
SELECT DISTINCT Date,Cat,COUNT(collectionEntityId)Cnt INTO #Skipp FROM #CT 
WHERE Enddate> = @frDate  AND Enddate <= @toDate AND collectionStageStatusId IN (5,18)
GROUP BY Cat,Date
--select * from #Skipp

	SELECT DISTINCT 
	A.Date,
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
	ISNULL(C.Cnt,0) +ISNULL(o.cnt,0) Total_Act_Proc,
	ISNULL(D.Cnt,0)+ISNULL(p.cnt,0) Total_Gui_Proc,
	ISNULL(q.Cnt,0) Total_NHL_Proc,
	ISNULL(B.Cnt,0) +ISNULL(n.cnt,0) + ISNULL(C.Cnt,0) +ISNULL(o.cnt,0) + ISNULL(D.Cnt,0)+ISNULL(p.cnt,0)+ ISNULL(q.Cnt,0) TotalProcessed,
	
	ISNULL(t.Cnt,0) Historical_Skipp_Est, 	
	ISNULL(u.Cnt,0) Historical_Skipp_Act,
	ISNULL(v.Cnt,0) Historical_Skipp_Gui, 	
	ISNULL(t.Cnt,0)+ISNULL(u.Cnt,0)+ISNULL(V.Cnt,0) TOTALHis_Skip,
	ISNULL(w.Cnt,0) Recent_Skipp_Est, 	
	ISNULL(x.Cnt,0) Recent_Skipp_Act,
	ISNULL(y.Cnt,0) Recent_Skipp_Gui, 	
	ISNULL(Z.Cnt,0) Recent_Skipp_NHL, 	
	ISNULL(W.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0) TOTALRecent_Skip,
	ISNULL(t.Cnt,0)+ISNULL(u.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(W.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0) TotalSKIP
			
	FROM #Processed A
	LEFT JOIN #Inserted E ON E.Cat='HE' AND A.Date= E.Date
	LEFT JOIN #Inserted F ON F.Cat='HA' AND A.Date= F.Date
	LEFT JOIN #Inserted G ON G.Cat='HG' AND A.Date= G.Date
	LEFT JOIN #Inserted H ON h.Cat='E' AND A.Date= h.Date
	LEFT JOIN #Inserted I ON i.Cat='A' AND A.Date= I.Date
	LEFT JOIN #Inserted J ON j.Cat='G' AND A.Date= j.Date
	LEFT JOIN #Inserted k ON k.Cat='nhl' AND A.Date= k.Date
	
	LEFT JOIN #Processed B ON B.Cat='HE' AND A.Date= B.Date
	LEFT JOIN #Processed C ON C.Cat='HE' AND A.Date= C.Date
	LEFT JOIN #Processed D ON D.Cat='HG' AND A.Date= D.Date	
	LEFT JOIN #Processed n ON n.Cat='E' AND A.Date= n.Date
	LEFT JOIN #Processed o ON o.Cat='A' AND A.Date= o.Date
	LEFT JOIN #Processed p ON p.Cat='G' AND A.Date= p.Date
	LEFT JOIN #Processed q ON q.Cat='nhl' AND A.Date= q.Date

	LEFT JOIN #Skipp T ON T.Cat='HE' AND A.Date= t.Date 
	LEFT JOIN #Skipp U ON U.Cat='HA' AND A.Date= u.Date 		
	LEFT JOIN #Skipp V ON V.Cat='HG' AND A.Date= v.Date 
	LEFT JOIN #Skipp W ON W.Cat='E' AND A.Date= W.Date
	LEFT JOIN #Skipp X ON X.Cat='A' AND A.Date= X.Date
	LEFT JOIN #Skipp Y ON Y.Cat='G' AND A.Date= Y.Date
	LEFT JOIN #Skipp Z ON Z.Cat='NHL' AND A.Date= Z.Date


SELECT DISTINCT Date2 Date,Cat,collectionStageId,collectionProcessName, COUNT(collectionEntityId)Cnt FROM #CT
WHERE insertedDate> = @frDate  AND insertedDate <= @toDate --and cat='e'
GROUP BY Cat,Date2,collectionStageId,collectionProcessName
ORDER BY Date2
