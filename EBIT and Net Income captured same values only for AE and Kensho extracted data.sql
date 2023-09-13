USE Estimates

DECLARE @frdate AS DATETIME, @todate as DATETIME

IF OBJECT_ID('TEMPDB..#TOTAL') IS NOT NULL DROP TABLE #TOTAL
SELECT DISTINCT ED.VERSIONID,ED.EFFECTIVEDATE,ED.COMPANYID,EDND.DATAITEMVALUE,ednd.unitsId AS UNITSID,EDND.currencyId,ED.ACCOUNTINGSTANDARDID,ED.TRADINGITEMID,DM.DATAITEMNAME,ED.PARENTFLAG,ED.ESTIMATEPERIODID,ED.RESEARCHCONTRIBUTORID,
EDND.AUDITTYPEID,EDND.DATAITEMID,(EDND.LASTMODIFIEDUTCDATETIME + '5:30') AS ENDDATE,PEO = DBO.FORMATPERIODID_FN(EP.ESTIMATEPERIODID),EP.FISCALYEAR,EP.FISCALQUARTER,EP.PERIODTYPEID,EP.PERIODENDDATE,RESEARCHCONTRIBUTOR = DBO.RESEARCHCONTRIBUTORNAME_FN(ED.RESEARCHCONTRIBUTORID)
INTO #TOTAL 
FROM ESTIMATEDETAIL_TBL ED (NOLOCK)
INNER JOIN ESTIMATEDETAILNUMERICDATA_TBL EDND (NOLOCK) ON ED.ESTIMATEDETAILID = EDND.ESTIMATEDETAILID 
INNER JOIN ESTIMATEPERIOD_TBL EP (NOLOCK) ON EP.ESTIMATEPERIODID = ED.ESTIMATEPERIODID
INNER JOIN DATAITEMMASTER_VW DM (NOLOCK) ON DM.DATAITEMID = EDND.DATAITEMID 
WHERE  EDND.AUDITTYPEID NOT IN (2059)
AND EDND.lastModifiedUTCDateTime +'5:30' >= GETDATE()-10
AND EDND.lastModifiedUTCDateTime +'5:30'<=  GETDATE()+1 
AND ED.VERSIONID IS NOT NULL 
----AND EDND.AUDITTYPEID IN (2109,2097)
AND EDND.DATAITEMID IN (21645,21650,21649) -----dataItemId=21645(EBIT),dataItemId=21650(NIGAAP),dataItemId=21649(NI Normalised)
--SELECT * FROM #TOTAL


IF OBJECT_ID('TEMPDB..#TBLEBIT') IS NOT NULL DROP TABLE #TBLEBIT SELECT DISTINCT * INTO #TBLEBIT FROM #TOTAL WHERE DATAITEMID = 21645 ---SELECT * FROM #TBLEBIT
IF OBJECT_ID('TEMPDB..#TBLNI') IS NOT NULL DROP TABLE #TBLNI SELECT DISTINCT * INTO #TBLNI FROM #TOTAL WHERE DATAITEMID IN (21650,21649) ---SELECT * FROM #TBLNI

IF OBJECT_ID('TEMPDB..#TBLFINAL') IS NOT NULL DROP TABLE #TBLFINAL
SELECT DISTINCT TE.VERSIONID,TE.COMPANYID,TE.RESEARCHCONTRIBUTOR,TE.PARENTFLAG,TE.PEO,TE.DATAITEMVALUE as EBIT,TN.DATAITEMVALUE as NETINCOME INTO #TBLFINAL FROM #TBLEBIT TE (NOLOCK)
INNER JOIN #TBLNI TN (NOLOCK) ON TN.RESEARCHCONTRIBUTOR = TE.RESEARCHCONTRIBUTOR AND TN.VERSIONID = TE.VERSIONID AND TN.COMPANYID = TE.COMPANYID AND TN.PARENTFLAG = TE.PARENTFLAG AND TN.ACCOUNTINGSTANDARDID = TE.ACCOUNTINGSTANDARDID AND TN.PEO = TE.PEO AND TN.CURRENCYID = TE.CURRENCYID AND TN.UNITSID = TE.UNITSID
WHERE TE.DATAITEMVALUE = TN.DATAITEMVALUE
---AND AUDITTYPEID IN (2109,2097)

--SELECT * FROM #TBLFINAL

--SELECT DISTINCT TF.VERSIONID,TF.COMPANYID,CM.CompanyName,PEO,RESEARCHCONTRIBUTOR,PARENTFLAG FROM #TBLFINAL TF (NOLOCK)
--INNER JOIN companymaster..companyinfomaster CM (NOLOCK) ON CM.ciqcompanyid=TF.companyId
