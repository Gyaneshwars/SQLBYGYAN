Use Estimates
IF OBJECT_ID('tempdb..#Est') IS NOT NULL DROP TABLE #Est
SELECT distinct contributorname=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.companyid,ed.versionid,ed.feedfileid,ednd.dataitemid,
dataitemname=dbo.dataitemname_fn(ednd.dataitemid),peo=dbo.formatperiodid_fn(ed.estimateperiodid),ednd.dataitemvalue,
ednd.currencyid,ednd.unitsid,ed.parentFlag,ed.tradingItemId,ed.accountingStandardId,ed.effectivedate INTO #Est from estimatedetail_tbl ed (nolock)
INNER JOIN Estimatedetailnumericdata_tbl ednd (NOLOCK) ON ednd.estimatedetailid=ed.estimatedetailid
WHERE ednd.dataItemId in (21645,21649,21650) AND ednd.audittypeid not in (2059) and ednd.toDate>getdate() and ed.effectivedate>='2020-12-01'
--select * from #Est

IF OBJECT_ID('TEMPDB..#EBIT') IS NOT NULL DROP TABLE #EBIT SELECT DISTINCT * INTO #EBIT FROM #Est WHERE DATAITEMID = 21645 ---SELECT * FROM #TBLEBIT
IF OBJECT_ID('TEMPDB..#NI') IS NOT NULL DROP TABLE #NI SELECT DISTINCT * INTO #NI FROM #Est WHERE DATAITEMID IN (21650,21649) ---SELECT * FROM #TBLNI

IF OBJECT_ID('TEMPDB..#FINAL') IS NOT NULL DROP TABLE #FINAL
SELECT DISTINCT TE.VERSIONID,TE.COMPANYID,TE.contributorname,TE.PARENTFLAG,TE.PEO,TE.DATAITEMVALUE as EBIT,TN.DATAITEMVALUE as NETINCOME INTO #FINAL FROM #EBIT TE (NOLOCK)
INNER JOIN #NI TN (NOLOCK) ON TN.contributorname = TE.contributorname AND TN.VERSIONID = TE.VERSIONID AND TN.COMPANYID = TE.COMPANYID AND TN.PARENTFLAG = TE.PARENTFLAG AND TN.ACCOUNTINGSTANDARDID = TE.ACCOUNTINGSTANDARDID

WHERE TE.DATAITEMVALUE = TN.DATAITEMVALUE
AND TN.PEO = TE.PEO 
AND TN.CURRENCYID = TE.CURRENCYID 
AND TN.UNITSID = TE.UNITSID

--select * from #FINAL
