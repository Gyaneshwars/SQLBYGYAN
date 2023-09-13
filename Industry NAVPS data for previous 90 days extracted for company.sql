USE Estimates
SELECT DISTINCT ed.versionid ,ed.companyid,ed.tradingItemId, ed.researchContributorId,edn.dataItemId,ctl.companyName,ctl.tickerSymbol,ed.effectiveDate,
dataitemname=dbo.DataItemName_fn(edn.dataitemid),PEO=dbo.formatPeriodId_fn(ed.estimateperiodid),edn.dataItemValue,crnc.ISOCode AS Currency 
FROM Estimates.dbo.EstimateDetail_tbl ed (NOLOCK)
INNER JOIN Estimates.[dbo].[EstFull_vw] edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
INNER JOIN ComparisonData.[dbo].[Currency_tbl] crnc (NOLOCK) ON edn.currencyId = crnc.currencyId
INNER JOIN ComparisonData.[dbo].[Company_tbl] ctl (NOLOCK) ON ed.companyid = ctl.companyId
--WHERE ed.companyId IN (189526)
WHERE ctl.tickerSymbol IN ('AIRC','AVB','CPT','CSR','EQR','ESS','IRT','MAA','UDR','ELS','SUI','AMH','INVH','CUBE','EXR','LSI','NSA','PSA','BXP','CUZ','DEI','DEA','ESRT','HPP','JBGS','KRC','SLG','VNO','PLD','PLYM','REXR','STAG','BNL','PSTL','WPC','SPG','BRX','FRT','KIM','PECO','REG','ROIC','CTRE','GMRE','PEAK','HR','LTC','NHI','DOC','SBRA','VTR','WELL','HHC','PCH','RYN','WY','DLR','EQIX','CLDT','HT','HST','PK','PEB','XHR')
AND edn.dataItemId IN (21625)
AND ed.effectiveDate>= GETDATE()-35
AND ed.versionId IS NOT NULL
AND ed.researchContributorId IN (228)
ORDER BY ed.effectiveDate DESC

--114208 = NAV
--21626 = Price Target
--21634 = EPS Normalized Estimate
--21635 = EPS (GAAP) Estimate
--21642 = Revenue Estimate





--2057---’PCTY’,’PAYC’,’WDAY’,’INTU’,’IOT’,’TYL’,’MSFT’,’NOW’,’SMAR’,’TWLO’,’INFA’,’ZI’,’ADBE’,’HCP’,’HUBS’,’TEAM’,’PLTR’,’SPLK’,’CHKP’,’CYBR’,’TENB’,’PANW’,’OKTA’,’S’,’ZS’,’QLYS’,’ADSK’,’U’,’PTC’,’CDNS’,’SNPS’,’ANSS’,’APP’,’BSY’,’ALTR’,’RBLX’,’DSY’,’AI’
---43----'ARTG','BTR','DSV','DCMC','FF','GMIN','ITR','MAI','NCAU','OIII','OSI','OSK','RIO','TML','TSG','TLG','BYN','BNCH','BRVO','EXN','GTWO','HIGH','LGD','QCCU','RGD','ROS','RUP','SGD','TDG','TAU','TBX','WM'

---197----'AEM','ABX','EDV','K','BTO','ELD','IMG','BCM','DPM','ELVT','KNT','STGO','VGCX','FNV','OR','SSL','TRR','TFPM','WPM','USA','AYA','MAG','SIL','CS','FM','FCX','HBM','LUN','TECK.B','ATYM','CMMC','ERO','TKO'