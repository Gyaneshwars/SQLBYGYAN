USE Estimates
DECLARE @FRDATE AS DATETIME, @TODATE AS DATETIME

SET @FRDATE = '2023-09-20 00:00:00.000'
SET @TODATE = '2023-09-30 23:59:59.999' 

IF OBJECT_ID ('TEMPDB..#GYANCAGR') IS NOT NULL DROP TABLE #GYANCAGR
SELECT DISTINCT ED.VERSIONID,ED.FEEDFILEID,ED.COMPANYID,DBO.FORMATPERIODID_FN(EP.ESTIMATEPERIODID) AS PPEO,EDND.DATAITEMID,DBO.DATAITEMNAME_FN (EDND.DATAITEMID) AS DATAITEMNAME,
ED.EFFECTIVEDATE,EDND.TODATE,ED.RESEARCHCONTRIBUTORID,EDND.DATAITEMVALUE,EDND.UNITSID,EDND.CURRENCYID,ED.PARENTFLAG INTO #GYANCAGR FROM ESTIMATEDETAIL_TBL ED
INNER JOIN ESTIMATEDETAILNUMERICDATA_TBL EDND ON ED.ESTIMATEDETAILID = EDND.ESTIMATEDETAILID
INNER JOIN EstimatesCompanyTier_tbl ET (NOLOCK) ON ET.companyId = ED.companyId
INNER JOIN ESTIMATEPERIOD_TBL EP ON EP.ESTIMATEPERIODID = ED.ESTIMATEPERIODID
WHERE EDND.DATAITEMID IN (21629,22498,22499)
AND EDND.LASTMODIFIEDUTCDATETIME + '5:30' >= @FRDATE 
AND EDND.LASTMODIFIEDUTCDATETIME + '5:30' <= @TODATE


IF OBJECT_ID ('TEMPDB..#GYANMAX') IS NOT NULL DROP TABLE #GYANMAX
SELECT EPT.COMPANYID,MAX(EPT.PERIODENDDATE) AS MAXPERIOD INTO #GYANMAX FROM ESTIMATEPERIOD_TBL EPT
INNER JOIN #GYANCAGR KC ON KC.COMPANYID = EPT.COMPANYID
WHERE EPT.PERIODTYPEID = 1
AND EPT.ACTUALIZEDDATE IS NOT NULL
GROUP BY EPT.COMPANYID

IF OBJECT_ID ('TEMPDB..#GYANEPSACTUAL') IS NOT NULL DROP TABLE #GYANEPSACTUAL
SELECT DISTINCT EDT.VERSIONID,EDT.FEEDFILEID,EDT.COMPANYID,EDT.EFFECTIVEDATE,DBO.DATAITEMNAME_FN (EDNDT.DATAITEMID) AS DATAITEMNAME,DBO.FORMATPERIODID_FN (EDT.ESTIMATEPERIODID) AS PEO,
EDNDT.DATAITEMVALUE,EPT.PERIODENDDATE,EDT.PARENTFLAG,EDT.ACCOUNTINGSTANDARDID,EDT.TRADINGITEMID
INTO #GYANEPSACTUAL FROM ESTIMATEDETAIL_TBL EDT
INNER JOIN ESTIMATEDETAILNUMERICDATA_TBL EDNDT ON EDNDT.ESTIMATEDETAILID = EDT.ESTIMATEDETAILID
INNER JOIN ESTIMATEPERIOD_TBL EPT ON EPT.ESTIMATEPERIODID = EDT.ESTIMATEPERIODID
INNER JOIN #GYANMAX KM ON KM.COMPANYID = EDT.COMPANYID
INNER JOIN #GYANCAGR KC ON KC.COMPANYID = EDT.COMPANYID
WHERE EDNDT.DATAITEMID IN (100179,100284,100256,100270)
AND EPT.PERIODENDDATE = KM.MAXPERIOD
AND EDNDT.DATAITEMVALUE < 0
AND EPT.PERIODTYPEID = 1



IF OBJECT_ID ('TEMPDB..#GYANFINAL') IS NOT NULL DROP TABLE #GYANFINAL
SELECT CIM.COMPANYNAME,RCT.CONTRIBUTORSHORTNAME,K.*,PEO,KE.DATAITEMVALUE AS EPSACTUALVALUE,KE.DATAITEMNAME AS EPSACT,KE.EFFECTIVEDATE AS ACTUALIZEDDATE
INTO #GYANFINAL FROM #GYANCAGR K
INNER JOIN #GYANEPSACTUAL KE ON K.COMPANYID = KE.COMPANYID
LEFT JOIN COMPANYMASTER.DBO.COMPANYINFOMASTER CIM ON CIM.CIQCOMPANYID = K.COMPANYID
INNER JOIN COMPARISONDATA.DBO.RESEARCHCONTRIBUTOR_TBL RCT ON RCT.RESEARCHCONTRIBUTORID = K.RESEARCHCONTRIBUTORID



SELECT DISTINCT * FROM #GYANFINAL WHERE versionId IS NULL