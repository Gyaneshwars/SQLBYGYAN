--PYTHO,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
DECLARE @frDate AS DATETIME, @toDate AS DATETIME

SET @frDate = '2024-01-16 00:00:00.000'
SET @toDate = '2024-06-30 23:59:59.999'

IF OBJECT_ID('TEMPDB..#Cat') IS NOT NULL DROP TABLE #Cat  CREATE TABLE #Cat (PriorityID int,Cat varchar(3)); INSERT INTO #Cat VALUES  
(1,'A'),(3,'G'),(4,'E'),(5,'E'),(6,'E'),(7,'E'),(8,'E'),(13,'E'),(14,'A'),(18,'E'),(20,'A'),(30,'A'),(31,'E'),(32,'E'),(33,'NHL'),(19,'NHL'),(46,'E'),(55,'A'),(90,'E'),(128,'E')
,(130,'E'),(143,'A'),(145,'E'),(149,'E'),(9,'HA'),(10,'HG'),(11,'HE'),(15,'HA'),(19,'HE'),(47,'HE'),(56,'HA'),(144,'NHL')

IF OBJECT_ID('TEMPDB..#CatFS') IS NOT NULL DROP TABLE #CatFS  CREATE TABLE #CatFS (PriorityID int,collectionStageId int, Cat varchar(3)); INSERT INTO #CatFS VALUES  
(1,215,'A'),(1,216,'NHL'),(1,219,'A'),(1,220,'NHL'),(9,215,'HA'),(9,216,'HA'),(9,219,'HA'),(9,220,'HA'),(143,215,'HA'),(143,216,'HA'),(143,219,'HA'),(143,220,'NHL'),
(3,221,'G'),(10,221,'HG'),(33,215,'A'),(33,216,'NHL'),(33,219,'A'),(33,220,'NHL'),(144,215,'A'),(144,216,'NHL'),(144,219,'A'),(144,220,'NHL')

IF OBJECT_ID('TEMPDB..#CT') IS NOT NULL DROP TABLE #CT 
SELECT DISTINCT CT.collectionEntityToProcessId,CT.insertedDate,CT.collectionEntityTypeId,CT.collectionEntityId,CT.relatedCompanyId,CT.collectionStageId,
CT.collectionstageStatusId,CT.PriorityID,CT.issueSourceId,B.Cat,P.priorityName,CONVERT(VARCHAR(10),ct.Enddate,101) Date,CONVERT(VARCHAR(10),insertedDate,101) Date2,cp.collectionProcessName INTO #CT 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CT
LEFT JOIN #Cat B (NOLOCK) ON Ct.PriorityID = B.PriorityID
LEFT JOIN workflow_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = ct.collectionEntityToProcessId and datapointid  = 1887
LEFT JOIN Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN workflow_Estimates.dbo.collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,ct.collectionProcessId)
LEFT JOIN Workflow_Estimates.[dbo].[Priority_tbl] P (NOLOCK) ON P.priorityId=CT.PriorityID
WHERE CT.collectionStageId in (2,85,86) AND CT.collectionProcessId IN (64,1062,374,378,895,4861,4862,4863,4864,4899,4900,4901,4902,4903,4904,4905,4906,4907) --AND CT.collectionEntityTypeId = 9
AND ((CT.insertedDate >=@frDate  AND CT.insertedDate<=@toDate) OR (CT.Enddate> = @frDate  AND CT.Enddate <= @toDate)) ---AND (CT.userid > 0 or CT.userid IS NULL)


--SELECT DISTINCT * FROM #CT

INSERT INTO #CT 
SELECT DISTINCT CT.collectionEntityToProcessId,CT.insertedDate,CT.collectionEntityTypeId,CT.collectionEntityId,CT.relatedCompanyId,CT.collectionStageId,
CT.collectionstageStatusId,CT.PriorityID,CT.issueSourceId,B.Cat,P.priorityName,Convert(varchar(10),ct.Enddate,101) Date,Convert(varchar(10),insertedDate,101) Date2,cp.collectionProcessName 
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CT
LEFT JOIN #CatFS B (NOLOCK) ON Ct.collectionStageId = B.collectionStageId and ct.PriorityID = b.PriorityID
LEFT JOIN workflow_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = ct.collectionEntityToProcessId and datapointid  = 1887
LEFT JOIN Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN workflow_Estimates.dbo.collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,ct.collectionProcessId)
LEFT JOIN Workflow_Estimates.[dbo].[Priority_tbl] P (NOLOCK) ON P.priorityId=CT.PriorityID
WHERE CT.collectionStageId IN (215,216,217,219,220,221)  and CT.collectionProcessId in (4897,4898) --AND CT.collectionEntityTypeId = 9
AND ((CT.insertedDate >=@frDate  AND CT.insertedDate <= @toDate) OR (CT.Enddate> = @frDate  AND CT.Enddate <= @toDate)) ---AND (CT.userid > 0 or CT.userid IS NULL)

---ct.collectionStageId 217
--SELECT DISTINCT * FROM #CT where collectionstagestatusid=5 

IF OBJECT_ID('TEMPDB..#Processed') IS NOT NULL DROP TABLE #Processed 
SELECT DISTINCT Date,Cat,COUNT(collectionEntityId)Cnt INTO #Processed
FROM #CT WHERE Date> = @frDate  AND Date <= @toDate AND collectionStageStatusId IN (4) --considered 4 for processed records---2:In Process,3:Pending,34:Issued to Checks Review
GROUP BY Cat,Date
--select * from #Processed

IF OBJECT_ID('TEMPDB..#Inserted') IS NOT NULL DROP TABLE #Inserted
SELECT DISTINCT Date2 Date,Cat,COUNT(collectionEntityId)Cnt INTO #Inserted FROM #CT
WHERE insertedDate> = @frDate  AND insertedDate <= @toDate ---AND collectionStageStatusId in (1,4,2,3,5,18,104,34)
GROUP BY Cat,Date2
--select * from #Inserted

IF OBJECT_ID('TEMPDB..#Skipp') IS NOT NULL DROP TABLE #Skipp
SELECT DISTINCT Date,Cat,COUNT(collectionEntityId)Cnt INTO #Skipp FROM #CT 
WHERE Date> = @frDate  AND Date <= @toDate AND collectionStageStatusId IN (5) ---,18,104
GROUP BY Cat,Date

IF OBJECT_ID('TEMPDB..#InpPIcr') IS NOT NULL DROP TABLE #InpPIcr
SELECT DISTINCT Date2 Date,Cat,COUNT(collectionEntityId)Cnt INTO #InpPIcr FROM #CT 
WHERE insertedDate> = @frDate  AND insertedDate <= @toDate AND collectionStageStatusId NOT IN (4,5,18,104)
GROUP BY Cat,Date2

--SELECT * FROM #InpPIcr
--autoskipped 104 added
--select * from #Skipp

SELECT DISTINCT 
H.Date,
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
ISNULL(t.Cnt,0)+ISNULL(u.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(W.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0) TotalSKIP,

ISNULL(ta.Cnt,0) Historical_IPICR_Est, 	
ISNULL(ua.Cnt,0) Historical_IPICR_Act,
ISNULL(va.Cnt,0) Historical_IPICR_Gui, 	
ISNULL(ta.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(Va.Cnt,0) TOTALHis_IPICR,
ISNULL(wa.Cnt,0) Recent_IPICR_Est, 	
ISNULL(xa.Cnt,0) Recent_IPICR_Act,
ISNULL(ya.Cnt,0) Recent_IPICR_Gui, 	
ISNULL(Za.Cnt,0) Recent_IPICR_NHL, 	
ISNULL(Wa.Cnt,0)+ISNULL(Xa.Cnt,0)+ISNULL(Ya.Cnt,0)+ISNULL(Za.Cnt,0) TOTALRecent_IPICR,
ISNULL(ta.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(Va.Cnt,0)+ISNULL(Wa.Cnt,0)+ISNULL(Xa.Cnt,0)+ISNULL(Ya.Cnt,0)+ISNULL(Za.Cnt,0) TotalIPICR,

ISNULL(E.Cnt,0)+ISNULL(H.cnt,0)+ISNULL(F.Cnt,0)+ISNULL(I.cnt,0)+ISNULL(G.Cnt,0)+ISNULL(J.cnt,0)+ISNULL(K.cnt,0) TotalInflow,
ISNULL(B.Cnt,0) +ISNULL(n.cnt,0) + ISNULL(C.Cnt,0) +ISNULL(o.cnt,0) + ISNULL(D.Cnt,0)+ISNULL(p.cnt,0)+ ISNULL(q.Cnt,0)+ISNULL(t.Cnt,0)+ISNULL(u.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(W.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0)+ISNULL(ta.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(Va.Cnt,0)+ISNULL(Wa.Cnt,0)+ISNULL(Xa.Cnt,0)+ISNULL(Ya.Cnt,0)+ISNULL(Za.Cnt,0) TotalOutFlow,
	
((ISNULL(E.Cnt,0)+ISNULL(H.cnt,0)+ISNULL(F.Cnt,0)+ISNULL(I.cnt,0)+ISNULL(G.Cnt,0)+ISNULL(J.cnt,0)+ISNULL(K.cnt,0))-(ISNULL(B.Cnt,0) +ISNULL(n.cnt,0) + ISNULL(C.Cnt,0) +ISNULL(o.cnt,0) + ISNULL(D.Cnt,0)+ISNULL(p.cnt,0)+ ISNULL(q.Cnt,0)+ISNULL(t.Cnt,0)+ISNULL(u.Cnt,0)+ISNULL(V.Cnt,0)+ISNULL(W.Cnt,0)+ISNULL(X.Cnt,0)+ISNULL(Y.Cnt,0)+ISNULL(Z.Cnt,0)+ISNULL(ta.Cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(Va.Cnt,0)+ISNULL(Wa.Cnt,0)+ISNULL(Xa.Cnt,0)+ISNULL(Ya.Cnt,0)+ISNULL(Za.Cnt,0))) I_O_Diff,
(ISNULL(E.Cnt,0) + ISNULL(H.cnt,0)) EstimatesIssued,
(ISNULL(F.Cnt,0) + ISNULL(G.Cnt,0) + ISNULL(o.cnt,0) + ISNULL(p.cnt,0) +ISNULL(q.cnt,0)) AandGIssued,
(ISNULL(E.Cnt,0) + ISNULL(H.cnt,0) +ISNULL(F.Cnt,0) + ISNULL(G.Cnt,0) + ISNULL(o.cnt,0) + ISNULL(p.cnt,0) +ISNULL(q.cnt,0)) TotalIssued,
(ISNULL(B.Cnt,0)+ISNULL(n.cnt,0)+ISNULL(ta.Cnt,0)+ISNULL(wa.Cnt,0)) EstimatesProcessed,
(ISNULL(C.Cnt,0)+ISNULL(D.Cnt,0)+ISNULL(o.cnt,0)+ISNULL(p.cnt,0)+ISNULL(q.cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(va.Cnt,0)+ISNULL(xa.Cnt,0)+ISNULL(ya.Cnt,0)+ISNULL(za.Cnt,0)) AndGProcessed,
(ISNULL(B.Cnt,0)+ISNULL(n.cnt,0)+ISNULL(ta.Cnt,0)+ISNULL(wa.Cnt,0)+ISNULL(C.Cnt,0)+ISNULL(D.Cnt,0)+ISNULL(o.cnt,0)+ISNULL(p.cnt,0)+ISNULL(q.cnt,0)+ISNULL(ua.Cnt,0)+ISNULL(va.Cnt,0)+ISNULL(xa.Cnt,0)+ISNULL(ya.Cnt,0)+ISNULL(za.Cnt,0)) TotalProcessed,
(ISNULL(t.Cnt,0)+ISNULL(w.Cnt,0)) EstimatesSkipped,
(ISNULL(u.Cnt,0)+ISNULL(v.Cnt,0)+ISNULL(x.Cnt,0)+ISNULL(y.Cnt,0)+ISNULL(Z.Cnt,0)) ActualsSkipped,
(ISNULL(t.Cnt,0)+ISNULL(w.Cnt,0)+ISNULL(u.Cnt,0)+ISNULL(v.Cnt,0)+ISNULL(x.Cnt,0)+ISNULL(y.Cnt,0)+ISNULL(Z.Cnt,0)) TotalSkipped

	

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

LEFT JOIN #InpPIcr Ta ON Ta.Cat='HE' AND A.Date= ta.Date 
LEFT JOIN #InpPIcr Ua ON Ua.Cat='HA' AND A.Date= ua.Date 		
LEFT JOIN #InpPIcr Va ON Va.Cat='HG' AND A.Date= va.Date 
LEFT JOIN #InpPIcr Wa ON Wa.Cat='E' AND A.Date= Wa.Date
LEFT JOIN #InpPIcr Xa ON Xa.Cat='A' AND A.Date= Xa.Date
LEFT JOIN #InpPIcr Ya ON Ya.Cat='G' AND A.Date= Ya.Date
LEFT JOIN #InpPIcr Za ON Za.Cat='NHL' AND A.Date= Za.Date
WHERE H.Date IS NOT NULL




SELECT DISTINCT Date2 Date,Cat,collectionProcessName, COUNT(collectionEntityId)Cnt FROM #CT
WHERE insertedDate> = @frDate  AND insertedDate <= @toDate --and cat='e'
GROUP BY Cat,Date2,collectionProcessName
ORDER BY Date2

SELECT Date2,COUNT(collectionEntityId) AS No_Of_Companies_Moved
FROM
#CT
GROUP BY Date2
ORDER BY Date2

SELECT * FROM #CT