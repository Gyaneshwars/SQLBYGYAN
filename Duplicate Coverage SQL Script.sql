
--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE

USE Estimates

IF OBJECT_ID('TempDb..#Dup') IS NOT NULL DROP TABLE #Dup
SELECT DISTINCT ED.researchContributorId,CASE ED.researchContributorId  
WHEN 2925 THEN 568
WHEN 2870 THEN 2882
WHEN 2302 THEN 239
WHEN 150  THEN 85
--WHEN 110 THEN 31
--WHEN 167 THEN 323
--WHEN 167 THEN 713
WHEN 713  THEN 323
WHEN 389  THEN 754
WHEN 573  THEN 2999
WHEN 1045 THEN 594
WHEN 446  THEN 594
WHEN 953  THEN 594
--WHEN 265 THEN 2929
WHEN 2376 THEN 2790
WHEN 1108 THEN 833
WHEN 705  THEN 2300
WHEN 863  THEN 90
WHEN 781  THEN 90
--WHEN 3086 THEN 90
WHEN 2675 THEN 90
WHEN 2730 THEN 90
WHEN 676  THEN 90
WHEN 94   THEN 2853
WHEN 108  THEN 1235
WHEN 114  THEN 308
WHEN 1114 THEN 319
WHEN 114  THEN 568
--WHEN 114 THEN 2604
--WHEN 114 THEN 1574
--WHEN 308 THEN 2604
--WHEN 308 THEN 1574
--WHEN 2604 THEN 1574
WHEN 645  THEN 1174
WHEN 926  THEN 10
--WHEN 591 THEN 1029
--WHEN 899 THEN 1178
--WHEN 3163 THEN 4
WHEN 3224 THEN 405
WHEN 2489 THEN 405
WHEN 112  THEN 1009
--WHEN 4 THEN 372
WHEN 145  THEN 1352
WHEN 2748 THEN	2351
WHEN 2557 THEN 2748
--WHEN 197 THEN 287 
WHEN 370  THEN 2302
WHEN 1331 THEN 5
WHEN 592  THEN 90
--WHEN 3138 THEN 745
WHEN 3043 THEN 3253
--WHEN 731 THEN 712
--WHEN 630 THEN 2929
WHEN 2348 THEN 2929
WHEN 140  THEN 24
WHEN 982  THEN 594
WHEN 3358 THEN 1098
WHEN 3031 THEN 2781
WHEN 2508 THEN 3343
WHEN 3352 THEN 204
WHEN 3209 THEN 2715
WHEN 3209 THEN 2715
WHEN 3343 THEN 471
WHEN 2302 THEN 370
END AS DUP_cont INTO #Dup
FROM EstimateDetail_tbl ED
WHERE ED.researchContributorId IN (2925,2870,2302,150,713,389,573,1045,446,953,2376,1108,705,863,781,2675,2730,676,94,108,114,1114,645,112,3224,2489,926,145,2351,2557,2748,370,1331,592,3043,2348,140,982,3358,3031,2508,3352,3209,3343,2302)


IF OBJECT_ID('TempDb..#Dup2') IS NOT NULL DROP TABLE #Dup2
SELECT A.*,RC.contributorShortName,RC2.contributorShortName AS DUP_con_NAme INTO #Dup2
FROM #Dup A
INNER JOIN ComparisonData.dbo.ResearchContributor_tbl RC (NOLOCK) ON RC.researchContributorId = A.researchContributorId
INNER JOIN ComparisonData.dbo.ResearchContributor_tbl RC2 (NOLOCK) ON RC2.researchContributorId = A.DUP_cont

--SELECT * FROM #Dup2

IF OBJECT_ID('TempDb..#GYAN') IS NOT NULL DROP TABLE #GYAN 
SELECT DISTINCT DUP.*,ed.companyId,ED.versionId,Ed.feedFileId,ED.effectiveDate,ED2.versionId AS DUP_VID,ED2.feedFileId AS DUP_FeedID, ED2.effectiveDate AS DUP_Date, DIM.dataItemName,ed.estimatePeriodId
INTO #GYAN
FROM  EstimateDetail_tbl ED
INNER JOIN EstimatePeriod_tbl EP (NOLOCK) ON EP.estimatePeriodId = ED.estimatePeriodId AND EP.actualizedDate IS NULL
INNER JOIN EstimateDetail_tbl ED2 (NOLOCK) ON ED.companyId= ED2.companyId AND ED.estimatePeriodId = ED2.estimatePeriodId
INNER JOIN #Dup2 DUP (NOLOCK) ON ED2.researchContributorId = Dup.DUP_cont
INNER JOIN EstimateDetailNumericData_tbl EDND (NOLOCK) ON EDND.estimateDetailId = ED.estimateDetailId AND EDND.toDate >= '2079-06-06 00:00:00.000'
INNER JOIN EstimateDetailNumericData_tbl EDND2 (NOLOCK) ON EDND2.estimateDetailId =ED2.estimateDetailId AND EDND2.toDate >= '2079-06-06 00:00:00.000' AND EDND.dataItemId= EDND2.dataItemId
INNER JOIN DataItemMaster_vw DIM (NOLOCK) ON DIM.dataItemID = EDND.dataItemId
--INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE ON ISNULL(EE.versionId,EE.feedFileId ) = ISNULL(ED.versionId,ED.feedFileId) AND EE.companyId = ED.companyId
--INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE2 ON ISNULL(EE2.versionId,EE2.feedFileId ) = ISNULL(ED2.versionId,ED2.feedFileId) AND EE2.companyId = ED2.companyId
WHERE ED.researchContributorId = DUP.researchContributorId 


IF OBJECT_ID('TempDb..#TEXT') IS NOT NULL DROP TABLE #TEXT
SELECT DISTINCT DUP.*,ED.companyId,ED.versionId,ED.feedFileId,ED.effectiveDate,ED2.versionId AS DUP_VID,ED2.feedFileId AS DUP_FeedID,ED2.effectiveDate AS DUP_Date, DIM.dataItemName,ED.estimatePeriodId
INTO #TEXT
FROM  EstimateDetail_tbl ED (NOLOCK)
INNER JOIN EstimateDetail_tbl ED2 (NOLOCK) ON ED.companyId= ED2.companyId 
INNER JOIN #Dup2 DUP ON ED2.researchContributorId = DUP.DUP_cont
INNER JOIN EstimateDetailIdData_tbl EDND (NOLOCK) ON EDND.estimateDetailId =ED.estimateDetailId and EDND.toDate >= '2079-06-06 00:00:00.000'
INNER JOIN EstimateDetailIdData_tbl EDND2 (NOLOCK) ON EDND2.estimateDetailId =ED2.estimateDetailId and EDND2.toDate >= '2079-06-06 00:00:00.000' and EDND.dataItemId= EDND2.dataItemId
--INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE ON ISNULL(EE.versionId,EE.feedFileId ) = ISNULL(ED.versionId,ED.feedFileId) AND EE.companyId = ED.companyId
--INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE2 ON ISNULL(EE2.versionId,EE2.feedFileId ) = ISNULL(ED2.versionId,ED2.feedFileId) AND EE2.companyId = ED2.co
INNER JOIN DataItemMaster_vw DIM (NOLOCK) ON DIM.dataItemID = EDND.dataItemId
WHERE ED.researchContributorId = Dup.researchContributorId


IF OBJECT_ID('TempDb..#FINAL') IS NOT NULL DROP TABLE #FINAL
SELECT * INTO #FINAL FROM #GYAN INSERT INTO #FINAL  SELECT * FROM #TEXT

IF OBJECT_ID('TempDb..#FINAL1') IS NOT NULL DROP TABLE #FINAL1
SELECT DISTINCT ED.*,ABS(DATEDIFF(DAY,ED.effectiveDate,ED.DUP_Date)) AS FD_Diff,
CASE IP.periodTypeId WHEN 1 THEN 'FY: ' + CAST(IP.fiscalYear AS VARCHAR) WHEN 2 THEN 'Q' + CAST(IP.fiscalQuarter AS VARCHAR) + ': ' + CAST(IP.fiscalYear AS VARCHAR) WHEN 10 THEN 'S' + CASE IP.fiscalQuarter WHEN 2 THEN '1' + ': ' + CAST(IP.fiscalYear AS VARCHAR) WHEN 4 THEN '2' + ': ' + CAST(IP.fiscalYear AS VARCHAR) ELSE 'NA' END ELSE 'NA' END AS PEO 
INTO #FINAL1 FROM #FINAL ED
INNER JOIN EstimatePeriod_tbl IP (NOLOCK) ON ED.estimateperiodid = IP.estimateperiodid	
--INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE ON ISNULL(EE.versionId,EE.feedFileId ) = ISNULL(ED.versionId,ED.feedFileId) AND EE.companyId = ED.companyId
--INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE2 ON EE2.versionId = ED.DUP_VID AND EE2.companyId = ED.companyId
WHERE ED.companyId NOT IN (53837907,53838134,53838987,53838840,53838182,53838219,53838254,53838701,53839132,53839346,53839519,53839639,53839708,53839770,53840173,53840236,113212991,53839233)


SELECT DISTINCT F1.* FROM #FINAL1 F1 
WHERE F1.FD_Diff<=8
ORDER BY F1.effectiveDate


