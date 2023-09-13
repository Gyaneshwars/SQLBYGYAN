USE Estimates

DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2022-03-27 00:00:00.000' ----Provide From Date Here
SET @toDate = '2022-06-30 23:59:59.999' ----Provide To Date Here

IF OBJECT_ID('TEMPDB..#Estdt') IS NOT NULL DROP TABLE #Estdt
SELECT DISTINCT ed.companyid,ed.versionid,ednd.dataitemid,dataitem=dbo.DataItemName_fn(ednd.dataitemid),peo=dbo.formatPeriodId_fn(ed.estimatePeriodId),ednd.dataItemValue,
ed.parentflag,ed.tradingitemid,ed.accountingStandardId,ednd.currencyId,ednd.unitsId,ed.effectivedate,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),
l.languageName,ist.issueSourceName INTO #Estdt 
FROM           Estimates.[dbo].estimatedetail_tbl ed (NOLOCK)
INNER JOIN     Estimates.[dbo].[EstFull_vw] ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
INNER JOIN     WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct (NOLOCK) ON ct.collectionEntityId = ed.versionid AND ct.relatedcompanyid = ed.companyid
INNER JOIN     ComparisonData.[dbo].ResearchDocument_tbl Rd (NOLOCK) ON  Rd.versionId= ct.collectionEntityId
INNER JOIN      Workflow_Estimates.[dbo].[IssueSource_tbl] ist (NOLOCK) ON ist.issueSourceId=ct.issueSourceId
LEFT JOIN      [Estimates].[dbo].[DataItemMaster_vw] dm (NOLOCK) ON ednd.dataitemid=dm.dataitemid
LEFT JOIN      Estimates.[dbo].[EstimatePeriod_tbl] ep (NOLOCK) ON CT.relatedCompanyId = ep.companyId
LEFT JOIN      Comparisondata.[dbo].Language_tbl l (NOLOCK) ON l.languageId=rd.languageId
LEFT JOIN      Estimates.[dbo].DataItemMaster_vw di (NOLOCK) ON di.dataItemID=ednd.dataItemId
LEFT JOIN      financialsupport.dbo.TradingItem_vw cm (NOLOCK) ON ed.tradingItemId = cm.tradingItemId
WHERE          ct.endDate>=@frDate AND ct.endDate<=@toDate 
AND  di.dataCollectionTypeID IN (54,63) 
AND  ed.versionId IS NOT NULL
AND  ed.companyid IS NOT NULL

--SELECT * FROM #Estdt

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
SELECT DISTINCT a.companyid,a.versionId AS cur_vid,a.dataitem AS cur_din,a.peo AS cur_peo,a.dataItemValue AS cur_value,a.effectiveDate AS cur_Filingdate  ,a.contributor AS cur_contributor,
a.languageName AS cur_lang,b.versionId AS prev_vid,b.dataitem AS prev_din,b.peo AS prev_peo,b.dataItemValue AS prev_value,b.effectiveDate AS prev_Filingdate,a.contributor AS prev_contributor,
b.languageName AS Prev_lang,a.parentFlag,a.tradingItemId,a.accountingStandardId,a.issueSourceName AS cur_issueSource,b.issueSourceName AS Prev_issueSource INTO #EstdtFinal FROM #Estdtcur1 a
INNER JOIN #Estdtprev1 b ON b.companyId=a.companyId AND b.contributor=a.contributor AND b.peo =a.peo  AND b.parentFlag=a.parentFlag AND b.dataItemValue=a.dataItemValue 
AND ISNULL(b.tradingItemId,-1)=ISNULL(a.tradingItemId,-1) AND ISNULL(b.accountingstandardid,255)=ISNULL(a.accountingstandardid,255) AND b.dataItemId=a.dataItemId
AND b.currencyId=a.currencyId AND b.unitsId=a.unitsId AND b.languageName!=a.languageName AND b.versionId!=a.versionId
WHERE ---b.dataitem=a.dataitem 
--b.dataItemValue=a.dataItemValue 
--AND b.currencyId=a.currencyId 
--AND b.unitsId=a.unitsId
--AND b.dataItemId=a.dataItemId
--AND b.languageName!=a.languageName
--AND b.versionId!=a.versionId
DATEDIFF(DAY,b.effectiveDate,a.effectiveDate)<=10
AND NOT EXISTS (SELECT 1 FROM #Estdtcur1 x WHERE x.dataItemId=a.dataItemId AND x.companyId=a.companyId AND x.contributor=a.contributor
                AND x.dataItemValue=a.dataItemValue AND x.peo=a.peo AND x.versionId<>a.versionId AND x.parentFlag=a.parentFlag)
AND NOT EXISTS (SELECT 1 FROM #Estdtprev1 y WHERE y.dataItemId=a.dataItemId AND y.companyId=a.companyId AND y.contributor=a.contributor
                AND y.dataItemValue=a.dataItemValue AND y.peo=a.peo AND y.versionId<>a.versionId AND y.parentFlag=a.parentFlag)

SELECT DISTINCT companyId,cur_contributor,cur_vid,cur_lang,prev_vid,Prev_lang,cur_Filingdate,prev_Filingdate,cur_din,cur_peo,cur_value,prev_value FROM #EstdtFinal
ORDER BY cur_vid,cur_din

---,cur_issueSource,Prev_issueSource