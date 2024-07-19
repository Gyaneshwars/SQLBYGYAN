USE Estimates
DECLARE @frDate DATETIME, @toDate DATETIME 
SET @frDate = '2022-05-27 00:00:00.000'
SET @toDate = '2022-06-30 23:59:59.999' 
IF OBJECT_ID('TEMPDB..#Estdt') IS NOT NULL DROP TABLE #Estdt
SELECT DISTINCT CT.collectionEntityId AS versionId,CT.relatedCompanyId AS companyid,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid), ed.effectiveDate, ednd.dataItemId,
dm.dataItemName,ed.tradingItemId,ednd.dataItemValue,CT.endDate,ed.parentflag,ed.accountingStandardId,ednd.currencyId,ednd.unitsId,l.languageName,ist.issueSourceName 
,PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),CT.insertedDate AS ProcessInsertedDate INTO #Estdt
FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK)
INNER JOIN Estimates.[dbo].EstimateDetail_tbl ed (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN Estimates.dbo.EstFull_vw ednd (NOLOCK) ON ed.estimateDetailId = ednd.estimateDetailId
INNER JOIN ComparisonData.[dbo].ResearchDocument_tbl Rd (NOLOCK) ON  Rd.researchContributorId=ed.researchContributorId AND rd.versionId=ed.versionId
INNER JOIN Workflow_Estimates.[dbo].[IssueSource_tbl] ist (NOLOCK) ON ist.issueSourceId=ct.issueSourceId
INNER JOIN [Estimates].[dbo].[DataItemMaster_vw] dm (NOLOCK) ON ednd.dataitemid=dm.dataitemid
INNER JOIN Estimates.[dbo].[EstimatePeriod_tbl] ep (NOLOCK) ON ed.companyId = ep.companyId
INNER JOIN Comparisondata.[dbo].Language_tbl l (NOLOCK) ON l.languageId=rd.languageId
--LEFT JOIN financialsupport.dbo.TradingItem_vw cm (NOLOCK) ON cm.companyId=ct.relatedCompanyId
WHERE CT.endDate>=@frDate and CT.endDate<=@toDate
AND CT.collectionProcessId IN (64)
AND CT.collectionstageId IN (2)
AND CT.collectionstageStatusId IN (4)
AND dm.dataCollectionTypeID IN (54,63)

--SELECT * FROM #Estdt WHERE versionId=1656115148 ORDER BY versionId

IF OBJECT_ID('TEMPDB..#Estdtcur') IS NOT NULL DROP TABLE #Estdtcur 
SELECT DISTINCT contributor,companyid,MAX(effectivedate) AS currdate INTO #Estdtcur FROM #Estdt 
GROUP BY contributor,companyid 

--SELECT * FROM #Estdtcur

IF OBJECT_ID('TEMPDB..#Estdtcur1') IS NOT NULL DROP TABLE #Estdtcur1 
SELECT DISTINCT a.* INTO #Estdtcur1 FROM #Estdt a 
INNER JOIN #Estdtcur b ON b.companyId=a.companyId AND b.contributor=a.contributor 
WHERE b.currdate=a.effectiveDate 

--SELECT * FROM #Estdtcur1

IF OBJECT_ID('TEMPDB..#Estdtprev') IS NOT NULL DROP TABLE #Estdtprev 
SELECT DISTINCT a.contributor,a.companyid,MAX(a.effectivedate) prevdate INTO #Estdtprev FROM #Estdt a 
INNER JOIN #Estdtcur b ON b.companyId=a.companyId AND b.contributor=a.contributor 
WHERE b.currdate>a.effectiveDate 
GROUP BY a.contributor,a.companyid 

--SELECT * FROM #Estdtprev

if OBJECT_ID('TEMPDB..#Estdtprev1') IS NOT NULL DROP TABLE #Estdtprev1 
SELECT DISTINCT a.* INTO #Estdtprev1 FROM #Estdt a
INNER JOIN #Estdtprev b ON b.companyId=a.companyId AND b.contributor=a.contributor 
WHERE b.prevdate=a.effectiveDate 

--SELECT * FROM #Estdtprev1

IF OBJECT_ID('TEMPDB..#EstdtFinal') IS NOT NULL DROP TABLE #EstdtFinal
SELECT DISTINCT a.companyid,a.versionId AS cur_vid,a.dataItemName AS cur_din,a.peo AS cur_peo,a.dataItemValue AS cur_value,a.effectiveDate AS cur_Filingdate  ,a.contributor AS cur_contributor,
a.languageName AS cur_lang,b.versionId AS prev_vid,b.dataItemName AS prev_din,b.peo AS prev_peo,b.dataItemValue AS prev_value,b.effectiveDate AS prev_Filingdate,a.ProcessInsertedDate AS curr_ProcessInserteddate,
b.ProcessInsertedDate AS Prev_ProcessInsertedDate,a.contributor AS prev_contributor,b.languageName AS Prev_lang,a.parentFlag,a.tradingItemId,a.accountingStandardId,
a.issueSourceName AS cur_issueSource,b.issueSourceName AS Prev_issueSource INTO #EstdtFinal FROM #Estdtcur1 a
INNER JOIN #Estdtprev1 b ON b.companyId=a.companyId AND b.contributor=a.contributor AND b.parentFlag=a.parentFlag
AND ISNULL(b.tradingItemId,-1)=ISNULL(a.tradingItemId,-1) AND ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255)
WHERE
b.dataItemId=a.dataItemId
--AND b.dataItemName=a.dataItemName
AND ISNULL(b.PEO,2000) =ISNULL(a.PEO,2000)
AND b.dataItemValue=a.dataItemValue 
AND ISNULL(b.currencyId,200)=ISNULL(a.currencyId,200) 
AND ISNULL(b.unitsId,101)=ISNULL(a.unitsId,101)
AND b.versionId!=a.versionId
AND b.languageName!=a.languageName
AND DATEDIFF(DAY,b.effectiveDate,a.effectiveDate)<=10



SELECT DISTINCT companyId,cur_contributor,cur_vid,cur_lang,prev_vid,Prev_lang,cur_Filingdate,prev_Filingdate,curr_ProcessInserteddate,Prev_ProcessInsertedDate,
CASE WHEN curr_ProcessInserteddate>Prev_ProcessInsertedDate THEN 'Previous Document' ELSE 'Current Document' END AS FirstDocumentInserted,cur_din,cur_peo,cur_value,prev_value,cur_issueSource,Prev_issueSource FROM #EstdtFinal
ORDER BY cur_vid,cur_din