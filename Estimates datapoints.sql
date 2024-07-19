USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-09-11 06:00:00.000'
SET @toDate = '2023-09-12 06:00:00.000'

IF OBJECT_ID ('TEMPDB..#esnRunDates_tbl') IS NOT NULL DROP TABLE #esnRunDates_tbl
CREATE TABLE #esnRunDates_tbl (sNo SMALLINT NOT NULL,frDate DATETIME NOT NULL,toDate DATETIME NOT NULL) INSERT INTO #esnRunDates_tbl VALUES (1, @frDate, @toDate)
--SELECT * FROM #esnRunDates_tbl

SELECT CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber AS EmpId, Usr.firstName + ' ' + Usr.lastName AS EmpName, MAX(CeToCs.endDate) AS endDate, CASE WHEN CeToP.priorityId IN (4,5,6,7,8,11,13,31,32,90,128,130,145, 149) THEN 'Estimates' END AS myProcess, CeToP.issueSourceId INTO #dEe_tbl FROM WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) 
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId 
INNER JOIN ComparisonData.DBO.User_tbl Usr (NOLOCK) ON Usr.userId = CeToCs.userId 
WHERE CeToP.collectionEntityTypeId = 9 AND CeToP.collectionProcessId = 64 AND CeToCs.collectionStageId IN (2, 122) AND CeToCs.collectionStageStatusId = 4 AND CeToCs.endDate > = (SELECT frDate FROM #esnRunDates_tbl) AND CeToCs.endDate < = (SELECT toDate FROM #esnRunDates_tbl) AND CeToP.priorityId IN (4,5,6,7,8,11,13,31,32,90,128,130,145, 149) 
GROUP BY CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber, Usr.firstName, Usr.lastName, CeToP.issueSourceId



SELECT Ed.* into #EstimateDetail_tbl FROM #dEe_tbl d (NOLOCK) 
INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId



SELECT EdNd.estimateDetailId, EdNd.dataItemId, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId into #EstFull_vw FROM EstFull_vw  EdNd (NOLOCK) 
INNER JOIN #EstimateDetail_tbl Ed ON EdNd.estimateDetailId = Ed.estimateDetailId


SELECT x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, x.HideFlag, COUNT(*) AS noOfDPs, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId INTO #dPe_tbl FROM (
SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, Ed.parentFlag, Ed.accountingStandardId, Ed.tradingItemId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.myProcess, d.issueSourceId, Hd.HideFlag
FROM #dEe_tbl d (NOLOCK) 
INNER JOIN #EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = d.collectionEntityId AND Ed.companyId = d.relatedCompanyId 
INNER JOIN #EstFull_vw  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId
INNER JOIN DataItemMaster_vw Dim (NOLOCK) ON Dim.dataItemId = EdNd.dataItemId AND Dim.dataCollectionTypeID IN (54,63) 
LEFT JOIN AutoExtraction_Estimates.dbo.AutomatedDataFlowHiddenDataitems_tbl Hd (NOLOCK) ON Hd.VersionId = Ed.versionId AND Hd.companyId = Ed.companyId AND Hd.dataItemId = EdNd.dataItemId
AND Hd.parentFlag = Ed.parentFlag AND ISNULL(Hd.accountingStandardId, 255) = ISNULL(Ed.accountingStandardId, 255) AND ISNULL(Hd.tradingItemId, -1) = ISNULL(Ed.tradingItemId, -1) AND Hd.HideFlag = 1
GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, Ed.parentFlag, Ed.accountingStandardId, Ed.tradingItemId, EdNd.dataItemId, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.myProcess, d.issueSourceId, Hd.HideFlag) x
GROUP BY x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.HideFlag, x.auditTypeId, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId
GO

DROP TABLE #EstimateDetail_tbl
DROP TABLE #EstFull_vw
GO



SELECT e.versionId, e.companyId, e.researchContributorId, e.effectiveDate, e.auditTypeId, auditTypeName = CASE WHEN e.auditTypeId = 2056 THEN 'Production' 
WHEN e.auditTypeId = 2057 THEN 'Master Correction' WHEN e.auditTypeId = 2059 THEN 'Confirmations' WHEN e.auditTypeId = 2061 THEN 'EF Ingest' 
WHEN e.auditTypeId = 2062 THEN 'EF Reprocess' WHEN e.auditTypeId = 2067 THEN 'Copied From TradingItem' 
WHEN e.auditTypeId = 2065 THEN 'Batch Checks Review' WHEN e.auditTypeId = 2058 THEN 'Copied From EF' WHEN e.auditTypeId = 2082 THEN 'AE Service Transformation'
WHEN e.auditTypeId = 2060 THEN 'Auto Extraction' WHEN e.auditTypeId = 2092 THEN 'Online Checks Review - Auto Extraction' 
WHEN e.auditTypeId = 2097 THEN 'AE 3.0 Transformation' WHEN e.auditTypeId = 2098 THEN 'AE Flavor Duplication' WHEN e.auditTypeId = 2099 THEN 'AE-Confirmation' 
WHEN e.auditTypeId = 2100 THEN 'AE-Accurate combination' 
WHEN e.auditTypeId = 2108 THEN 'AE-ActualMatched' WHEN e.auditTypeId IS NULL THEN 'Coverage Actions/Events' WHEN e.auditTypeId = 2109 THEN 'Kensho Frozen'  
WHEN e.auditTypeId = 2110 THEN 'Kensho Unfrozen - Transformation' WHEN e.auditTypeId = 2111 THEN 'Kensho Unfrozen - Flavor Duplication' ELSE 'Esn Pl. Check' END,
isHidden = CASE WHEN e.HideFlag = 1 THEN 'Yes' ELSE 'No' END, e.noOfDPs, e.priorityId, e.EmpId, e.EmpName, e.endDate, 
myProcess = CASE  WHEN e.priorityId = 31 THEN 'Customer Request - Estimates'
WHEN e.issueSourceId = 34 THEN 'Estimates - Screening Research Documents' ELSE e.myProcess END,e.issueSourceId, rdt.languageId, rdt.[pageCount] 
INTO #Gr_tbl FROM #dPe_tbl e (NOLOCK)
LEFT JOIN ComparisonData.dbo.ResearchDocument_tbl rdt ON rdt.versionId = e.versionId


SELECT e.EmpId, e.EmpName, e.versionId, e.companyId, e.priorityId, e.languageId, e.auditTypeName, e.myProcess, e.endDate, e.noOfDPs, Lg.languageName, 
e.isHidden, e.issueSourceId INTO #esnFinal_tbl FROM #Gr_tbl e 
LEFT JOIN comparisondata.dbo.language_tbl Lg (NOLOCK) ON Lg.languageId = e.languageId


SELECT CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber AS EmpId, Usr.firstName + ' ' + Usr.lastName AS EmpName, 
MAX(CeToCs.endDate) AS endDate, CASE WHEN CeToP.priorityId IN (18,19, 55,56) THEN 'eIndices' END AS myProcess, CeToP.issueSourceId 
INTO #dEi_tbl FROM WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK)
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId 
INNER JOIN ComparisonData.DBO.User_tbl Usr (NOLOCK) ON Usr.userId = CeToCs.userId 
WHERE CeToP.collectionEntityTypeId = 9 AND CeToP.collectionProcessId = 64 AND CeToCs.collectionStageId = 2  AND CeToCs.collectionStageStatusId = 4 
AND CeToCs.endDate > = (SELECT frDate FROM #esnRunDates_tbl) AND CeToCs.endDate < = (SELECT toDate FROM #esnRunDates_tbl) AND CeToP.priorityId IN (18,19,55,56) 
GROUP BY CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber, Usr.firstName, Usr.lastName, CeToP.issueSourceId



SELECT x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, COUNT(*) AS noOfDPs, x.priorityId, x.EmpId, x.EmpName, x.endDate, 
x.myProcess, x.issueSourceId INTO #dPi_tbl FROM (SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue,
EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.myProcess,
d.issueSourceId FROM #dEi_tbl d (NOLOCK) 
INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId IN (2668699, 2667768) 
INNER JOIN EstFull_vw  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId 
INNER JOIN DataItemMaster_vw Dim (NOLOCK) ON Dim.dataItemId = EdNd.dataItemId AND Dim.dataCollectionTypeID IN (54,63)  
GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId, 
EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.myProcess, d.issueSourceId ) x 
GROUP BY x.versionId, x.companyId, x.researchContributorId, x.effectiveDate,  x.auditTypeId, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId



INSERT INTO #esnFinal_tbl 
SELECT i.EmpId, i.EmpName, i.versionId, i.companyId, i.priorityId, languageId = 123, auditTypeName = i.myProcess, i.myProcess, i.endDate, i.noOfDPs, 
languageName = 'English', isHidden = 'No', i.issueSourceId FROM #dPi_tbl i (NOLOCK)


SELECT CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber AS EmpId, Usr.firstName + ' ' + Usr.lastName AS EmpName, 
MAX(CeToCs.endDate) AS endDate, CASE             WHEN CeToP.priorityId IN (46,47) THEN 'eCommodities' END AS myProcess, CeToP.issueSourceId 
INTO #dEc_tbl FROM WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) 
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId 
INNER JOIN ComparisonData.DBO.User_tbl Usr (NOLOCK) ON Usr.userId = CeToCs.userId 
WHERE CeToP.collectionEntityTypeId = 9 AND CeToP.collectionProcessId = 64 AND CeToCs.collectionStageId IN (2) AND CeToCs.collectionStageStatusId = 4 
AND CeToCs.endDate > = (SELECT frDate FROM #esnRunDates_tbl) AND CeToCs.endDate < = (SELECT toDate FROM #esnRunDates_tbl) AND CeToP.priorityId IN (46,47) 
GROUP BY CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber, Usr.firstName, Usr.lastName, CeToP.issueSourceId


SELECT x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, COUNT(*) AS noOfDPs, x.priorityId, x.EmpId, x.EmpName, x.endDate, 
x.myProcess, x.issueSourceId 
INTO #dPc_tbl FROM (SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId, 
EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.myProcess, 
d.issueSourceId FROM #dEc_tbl d (NOLOCK) 
INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId 
INNER JOIN EstFull_vw  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId AND EdNd.dataItemId = 112021 
GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.myProcess, d.issueSourceId ) x GROUP BY x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId


INSERT INTO #esnFinal_tbl 
SELECT i.EmpId, i.EmpName, i.versionId, i.companyId, i.priorityId, languageId = 123, auditTypeName = i.myProcess, i.myProcess, i.endDate, i.noOfDPs, 
languageName = 'English', isHidden = 'No' , i.issueSourceId FROM #dPc_tbl i (NOLOCK)
SELECT CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber AS EmpId, Usr.firstName + ' ' + Usr.lastName AS EmpName, 
MAX(CeToCs.endDate) AS endDate, CASE WHEN CeToP.priorityId IN (1,9,14,15,20,30,33,143,144, 146, 3,10) THEN 'Act & Gui - O&G' 
WHEN CeToP.priorityId IN (4,5,6,7,8,11,13,31,32,90,128,130,145,149) THEN 'Estimates - O&G' END AS myProcess, CeToP.issueSourceId 
INTO #dEog_tbl FROM WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) 
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId
INNER JOIN ComparisonData.DBO.User_tbl Usr (NOLOCK) ON Usr.userId = CeToCs.userId 
WHERE CeToP.collectionEntityTypeId = 9  AND CeToP.collectionProcessId = 1062 AND CeToCs.collectionStageId = 2 AND CeToCs.collectionStageStatusId = 4 
AND CeToCs.endDate > = (SELECT frDate FROM #esnRunDates_tbl) AND CeToCs.endDate < = (SELECT toDate FROM #esnRunDates_tbl) 
GROUP BY CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber, Usr.firstName, Usr.lastName, CeToP.issueSourceId


SELECT x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, COUNT(*) AS noOfDPs, x.priorityId, x.EmpId, x.EmpName, x.endDate, 
x.myProcess, x.issueSourceId INTO #dPog_tbl FROM (SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, 
EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.myProcess, 
d.issueSourceId FROM #dEog_tbl d (NOLOCK) 
INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId 
INNER JOIN EstFull_vw  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId 
INNER JOIN DataItemMaster_vw Dim (NOLOCK) ON Dim.dataItemId = EdNd.dataItemId AND Dim.dataCollectionTypeID IN (78, 79, 80) 
GROUP BY Ed.versionId, Ed.companyId,Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, 
Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.myProcess, d.issueSourceId) x 
GROUP BY x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId


INSERT INTO #esnFinal_tbl 
SELECT i.EmpId, i.EmpName, i.versionId, i.companyId, i.priorityId, languageId = 123, auditTypeName = i.myProcess, i.myProcess, i.endDate, i.noOfDPs, 
languageName = 'English', isHidden = 'No' , i.issueSourceId FROM #dPog_tbl i (NOLOCK)

SELECT CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber AS EmpId, Usr.firstName + ' ' + Usr.lastName AS EmpName, 
MAX(CeToCs.endDate) AS endDate, CASE WHEN CeToP.priorityId IN (1,3,9,10,14,15,20,30,143, 33,144) THEN 'A & G' END AS myProcess, CeToP.issueSourceId,CeToCs.collectionStageId 
INTO #dEag_tbl FROM WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) 
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId 
INNER JOIN ComparisonData.DBO.User_tbl Usr (NOLOCK) ON Usr.userId = CeToCs.userId 
WHERE CeToP.collectionEntityTypeId = 9 AND CeToP.collectionProcessId in (64,4897,4898) AND CeToCs.collectionStageId in (2,215,216,217,219,220,221)  AND CeToCs.collectionStageStatusId = 4 
AND CeToCs.endDate > = (SELECT frDate FROM #esnRunDates_tbl) AND CeToCs.endDate < = (SELECT toDate FROM #esnRunDates_tbl) 
AND CeToP.priorityId IN (1,3,9,10,14,15,20,30,143, 33,144)
GROUP BY CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber, Usr.firstName, Usr.lastName, CeToP.issueSourceId,CeToCs.collectionStageId 



DELETE FROM #dEag_tbl WHERE empId = '000266' OR empId = '000EF2' OR empId = '000EF3' OR empId = '000EF4' OR empId = '000EF5' 

select Ed.* into #ED_tbl from #dEag_tbl a 
INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId 
INNER JOIN EstFull_vw  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId 



select EdNd.* into #EdNd_tbl from #dEag_tbl a 
INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId 
INNER JOIN EstFull_vw  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId

IF OBJECT_ID('TEMPDB..#HL_tbl')IS NOT NULL DROP TABLE #HL_tbl
SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, 
CASE WHEN EdNd.dataItemId IN (SELECT dataItemId FROM DataItemMaster_vw 
WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) THEN 'NHL Act' ELSE 'HL Act & Gui' END AS myProcess, EdNd.dataItemValue, EdNd.auditTypeId,
EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId 
into #HL_tbl FROM #dEag_tbl d (NOLOCK) 
INNER JOIN #ED_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId 
INNER JOIN #EdNd_tbl  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId
INNER JOIN DataItemMaster_vw Dim (NOLOCK) ON Dim.dataItemId = EdNd.dataItemId AND Dim.dataCollectionTypeID IN (56,62,70) 
WHERE d.priorityId IN (1,9,14,15,20,30,143, 3,10) AND  d.collectionStageId not in (216,220) and EdNd.dataItemId NOT IN (SELECT dataItemId FROM DataItemMaster_vw 
WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) 
GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId, 
EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId 


IF OBJECT_ID('TEMPDB..#NHL_tbl')IS NOT NULL DROP TABLE #NHL_tbl

SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, 
CASE WHEN EdNd.dataItemId IN (SELECT dataItemId FROM DataItemMaster_vw
WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) THEN 'NHL Act' ELSE 'HL Act & Gui' END AS myProcess, EdNd.dataItemValue, EdNd.auditTypeId, 
EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId
into #NHL_tbl FROM #dEag_tbl d (NOLOCK)
INNER JOIN #ED_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId 
INNER JOIN #EdNd_tbl  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId
INNER JOIN DataItemMaster_vw Dim (NOLOCK) ON Dim.dataItemId = EdNd.dataItemId AND Dim.dataCollectionTypeID IN (56,62,70)
WHERE (d.priorityId IN (33,144, 9,14,15,20) OR D.collectionStageId IN (216,220)) AND EdNd.dataItemId IN (SELECT dataItemId FROM DataItemMaster_vw 
WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) 
GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId,EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId 


SELECT x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, 
auditTypeName = CASE WHEN x.auditTypeId = 2056 THEN 'Production' WHEN x.auditTypeId = 2057 THEN 'Master Correction' 
WHEN x.auditTypeId = 2065 THEN 'Batch Checks Review' WHEN x.auditTypeId = 2067 THEN 'Copied From TradingItem' 
WHEN x.auditTypeId = 2093 THEN 'Batch Checks Offline Review - ActualsFromFinancials' WHEN x.auditTypeId = 2094 THEN 'ActualsFromFinancials'
WHEN x.auditTypeId = 2095 THEN 'Master Correction - ActualsFromFinancials' WHEN x.auditTypeId = 2096 THEN 'Production at AFF checks review' ELSE 'Esn Pl.Check' END, 
COUNT(*) AS noOfDPs, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId INTO #dPag_tbl FROM (select * from #HL_tbl 
UNION ALL select * from #NHL_tbl ) x 
GROUP BY x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess,x.issueSourceId

SELECT * INTO #onlyNHL_tbl FROM #dEag_tbl d (NOLOCK) WHERE priorityId IN (33,144) AND NOT EXISTS (SELECT 1 FROM WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId WHERE d.collectionEntityId = CeToP.collectionEntityId AND d.relatedCompanyId = CeToP.relatedCompanyId AND CeToP.collectionEntityTypeId = 9 AND CeToP.collectionProcessId = 64 AND CeToCs.collectionStageId = 2  AND CeToCs.collectionStageStatusId = 4 AND CeToP.priorityId IN (1,3,9,10,14,15,20,30,143) GROUP BY CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId)
INSERT INTO #dPag_tbl SELECT x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, auditTypeName = CASE WHEN x.auditTypeId = 2056 THEN 'Production' WHEN x.auditTypeId = 2057 THEN 'Master Correction' WHEN x.auditTypeId = 2065 THEN 'Batch Checks Review' WHEN x.auditTypeId = 2067 THEN 'Copied From TradingItem' WHEN x.auditTypeId = 2093 THEN 'Batch Checks Offline Review - ActualsFromFinancials' WHEN x.auditTypeId = 2094 THEN 'ActualsFromFinancials' WHEN x.auditTypeId = 2095 THEN 'Master Correction - ActualsFromFinancials' WHEN x.auditTypeId = 2096 THEN 'Production at AFF checks review' ELSE 'Esn Pl.Check' END, COUNT(*) AS noOfDPs, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId FROM (SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, CASE WHEN EdNd.dataItemId IN (SELECT dataItemId FROM DataItemMaster_vw WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) THEN 'NHL Act'  ELSE 'HL Act & Gui - Collected in NHL Priority' END AS myProcess, EdNd.dataItemValue, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId FROM #onlyNHL_tbl d (NOLOCK) INNER JOIN EstimateDetail_tbl Ed (NOLOCK) 
ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId INNER JOIN EstFull_vw  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId INNER JOIN DataItemMaster_vw Dim (NOLOCK) ON Dim.dataItemId = EdNd.dataItemId AND Dim.dataCollectionTypeID IN (56,62,70) WHERE d.priorityId IN (33,144) AND EdNd.dataItemId NOT IN (SELECT dataItemId FROM DataItemMaster_vw WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId,  EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId ) x GROUP BY x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId 
SELECT e.EmpId, e.EmpName, e.versionId, e.companyId, e.priorityId, dEcV.originalLanguageId, e.auditTypeName, e.myProcess, e.endDate, e.noOfDPs, e.issueSourceId INTO #GrAg_tbl FROM #dPag_tbl e (NOLOCK) LEFT JOIN DocumentRepositoryProcessing.dbo.DocumentElementCache_vw dEcV ON dEcV.versionId = e.versionId GROUP BY e.EmpId, e.EmpName, e.versionId, e.companyId, e.priorityId, dEcV.originalLanguageId, e.auditTypeName, e.myProcess, e.endDate, e.noOfDPs, e.issueSourceId
SELECT e.EmpId, e.EmpName, e.versionId, e.companyId, e.priorityId, e.originalLanguageId, e.auditTypeName, e.myProcess, e.endDate, e.noOfDPs, Lg.languageName, isHidden = 'No', e.issueSourceId INTO #esnFinal_Ag_tbl FROM #GrAg_tbl e LEFT JOIN comparisondata.dbo.language_tbl Lg (NOLOCK) ON Lg.languageId = e.originalLanguageId
SELECT CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber AS EmpId, Usr.firstName + ' ' + Usr.lastName AS EmpName, MAX(CeToCs.endDate) AS endDate, CASE WHEN CeToP.priorityId IN (1,9,14,15,20,30,143,3,10, 33,144) THEN 'AFF' END AS myProcess, CeToP.issueSourceId INTO #dEaff_tbl FROM  WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId INNER JOIN ComparisonData.DBO.User_tbl Usr (NOLOCK) ON Usr.userId = CeToCs.userId WHERE CeToP.collectionEntityTypeId = 9 AND CeToP.collectionProcessId = 64 AND CeToCs.collectionStageId = 155 AND CeToCs.collectionStageStatusId = 4 AND CeToP.priorityId IN (1,3,9,10,14,15,20,30,143, 33,144) AND CeToCs.endDate > = (SELECT frDate FROM #esnRunDates_tbl) AND CeToCs.endDate < = (SELECT toDate FROM #esnRunDates_tbl) GROUP BY CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber, Usr.firstName, Usr.lastName, CeToP.priorityId, CeToP.issueSourceId 
SELECT x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, COUNT(*) AS noOfDPs, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId INTO #dPaff_tbl FROM (SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, CASE WHEN EdNd.dataItemId IN (SELECT dataItemId FROM DataItemMaster_vw WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) THEN 'AFF - NHL                                  '  ELSE 'AFF - HL                                  ' END AS myProcess, EdNd.dataItemValue, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId FROM #dEaff_tbl d (NOLOCK) INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId INNER JOIN EstFull_vw  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId INNER JOIN DataItemMaster_vw Dim (NOLOCK) ON Dim.dataItemId = EdNd.dataItemId AND Dim.dataCollectionTypeID = 56 WHERE d.priorityId IN (1,9,14,15,20,30,143,3,10) AND EdNd.dataItemId NOT IN (SELECT dataItemId FROM DataItemMaster_vw WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) AND EdNd.auditTypeId IN (2093,2094,2095,2096) GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId UNION ALL
SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, CASE WHEN EdNd.dataItemId NOT IN (SELECT dataItemId FROM DataItemMaster_vw WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) THEN 'AFF - HL'  ELSE 'AFF - NHL' END AS myProcess, EdNd.dataItemValue, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId,  d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId FROM #dEaff_tbl d (NOLOCK) INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId INNER JOIN EstFull_vw  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId INNER JOIN DataItemMaster_vw Dim (NOLOCK) ON Dim.dataItemId = EdNd.dataItemId AND Dim.dataCollectionTypeID = 56 WHERE d.priorityId IN (33,144) AND EdNd.dataItemId IN (SELECT dataItemId FROM DataItemMaster_vw WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) AND EdNd.auditTypeId IN (2093,2094,2095,2096) GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId ) x GROUP BY x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId
SELECT e.EmpId, e.EmpName, e.versionId, e.companyId, e.priorityId, originalLanguageId = 123, 'Normal Production' AS auditTypeName, e.myProcess, MAX(e.endDate) AS endDate, totPoints = ISNULL(SUM(e.noOfDPs),0), e.issueSourceId INTO #GrAff_tbl FROM #dPaff_tbl e (NOLOCK) GROUP BY e.EmpId, e.EmpName, e.versionId, e.companyId, e.priorityId, e.myProcess, e.issueSourceId
SELECT * INTO #onlyNHL_AFF_tbl FROM #dEaff_tbl d (NOLOCK) WHERE priorityId IN (33,144) AND NOT EXISTS (SELECT 1 FROM WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId WHERE d.collectionEntityId = CeToP.collectionEntityId AND d.relatedCompanyId = CeToP.relatedCompanyId AND CeToP.collectionEntityTypeId = 9 AND CeToP.collectionProcessId = 64 AND CeToCs.collectionStageId = 2  AND CeToCs.collectionStageStatusId = 4 AND CeToP.priorityId IN (1,3,9,10,14,15,20,30,143) GROUP BY CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId)

IF OBJECT_ID ('TEMPDB..#EstimateDetail_tbl') IS NOT NULL DROP TABLE #EstimateDetail_tbl SELECT Ed.* into #EstimateDetail_tbl FROM #onlyNHL_AFF_tbl d (NOLOCK) INNER JOIN EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId IF OBJECT_ID ('TEMPDB..#EstFull_vw') IS NOT NULL DROP TABLE #EstFull_vw SELECT EdNd.estimateDetailId, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId into #EstFull_vw FROM EstFull_vw  EdNd (NOLOCK) INNER JOIN #EstimateDetail_tbl Ed ON EdNd.estimateDetailId = Ed.estimateDetailId
SELECT x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, auditTypeName = CASE WHEN x.auditTypeId = 2056 THEN 'Production' WHEN x.auditTypeId = 2057 THEN 'Master Correction' WHEN x.auditTypeId = 2065 THEN 'Batch Checks Review' WHEN x.auditTypeId = 2067 THEN 'Copied From TradingItem' WHEN x.auditTypeId = 2093 THEN 'Batch Checks Offline Review - ActualsFromFinancials' WHEN x.auditTypeId = 2094 THEN 'ActualsFromFinancials' WHEN x.auditTypeId = 2095 THEN 'Master Correction - ActualsFromFinancials' WHEN x.auditTypeId = 2096 THEN 'Production at AFF checks review' ELSE 'Esn Pl.Check' END, COUNT(*) AS noOfDPs, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId INTO #dPag_AFF_tbl FROM (SELECT Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, CASE WHEN EdNd.dataItemId IN (SELECT dataItemId FROM DataItemMaster_vw WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56) THEN 'NHL Act'  ELSE 'HL Act & Gui - Collected in NHL Priority' END AS myProcess, EdNd.dataItemValue, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId FROM #onlyNHL_AFF_tbl d (NOLOCK) INNER JOIN #EstimateDetail_tbl Ed (NOLOCK) ON Ed.versionId = collectionEntityId AND Ed.companyId = relatedCompanyId INNER JOIN #EstFull_vw  EdNd (NOLOCK) ON EdNd.estimateDetailId = Ed.estimateDetailId INNER JOIN DataItemMaster_vw Dim (NOLOCK) ON Dim.dataItemId = EdNd.dataItemId AND Dim.dataCollectionTypeID IN (56,62,70) WHERE d.priorityId IN (33,144) AND EdNd.dataItemId NOT IN (SELECT dataItemId FROM DataItemMaster_vw WHERE headlineItemFlag = 0 AND dataCollectionTypeID = 56)  GROUP BY Ed.versionId, Ed.companyId, Ed.researchContributorId, Ed.effectiveDate, EdNd.dataItemId, EdNd.dataItemValue, EdNd.auditTypeId, EdNd.estimateDetailNumericDataId, Ed.estimateDetailId, Ed.estimatePeriodId, d.priorityId, d.EmpId, d.EmpName, d.endDate, d.issueSourceId ) x GROUP BY x.versionId, x.companyId, x.researchContributorId, x.effectiveDate, x.auditTypeId, x.priorityId, x.EmpId, x.EmpName, x.endDate, x.myProcess, x.issueSourceId
INSERT INTO #GrAff_tbl SELECT e.EmpId, e.EmpName, e.versionId, e.companyId, e.priorityId, originalLanguageId = 123, 'Normal Production' AS auditTypeName,  e.myProcess, MAX(e.endDate) AS endDate, totPoints = ISNULL(SUM(e.noOfDPs),0), e.issueSourceId FROM #dPag_AFF_tbl e (NOLOCK) GROUP BY e.EmpId, e.EmpName, e.versionId, e.companyId, e.priorityId, e.myProcess, e.issueSourceId
INSERT INTO #esnFinal_Ag_tbl SELECT e.EmpId, e.EmpName, e.versionId, e.companyId, e.priorityId, e.originalLanguageId, e.auditTypeName, e.myProcess, e.endDate, e.totPoints, languageName = 'English', isHidden = 'No', e.issueSourceId FROM #GrAff_tbl e
SELECT Usr.employeeNumber AS EmpId, Usr.firstName + ' ' + Usr.lastName AS EmpName, CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, languageId = 123, auditTypeName = 'Coverage Action Events', myProcess = 'Coverage Action Events', MAX(endDate) AS endDate, 1 AS oriDataPoints, languageName = 'English', isHidden = 'No', CeToP.issueSourceId INTO #esnCoverateEvents_tbl FROM WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId INNER JOIN ComparisonData.DBO.User_tbl Usr (NOLOCK) ON Usr.userId = CeToCs.userId INNER JOIN Event_tbl Ev (NOLOCK) ON Ev.versionId = CeToP.collectionEntityId AND Ev.companyId = CeToP.relatedCompanyId INNER JOIN dbo.EventType_tbl Et (NOLOCK) ON Et.eventTypeId = Ev.eventTypeId WHERE CeToP.collectionEntityTypeId = 9 AND CeToP.collectionProcessId = 64 AND CeToCs.collectionStageId IN (2, 122)  AND CeToCs.collectionStageStatusId = 4 AND CeToCs.endDate > = (SELECT frDate FROM #esnRunDates_tbl) AND CeToCs.endDate < = (SELECT toDate FROM #esnRunDates_tbl) AND CeToP.priorityId IN (4,5,6,7,8,11,13,31,32,90,128,130,145, 149) GROUP BY CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber, Usr.firstName + ' ' + Usr.lastName, CeToP.issueSourceId      

-- skipped
SELECT Usr.employeeNumber AS EmpId, Usr.firstName + ' ' + Usr.lastName AS EmpName, CeToP.collectionEntityId, relatedCompanyId = ISNULL(CeToP.relatedCompanyId, -1), 
CeToCs.startDate, CeToCs.endDate, DATEDIFF(mi,CeToCs.startDate, CeToCs.endDate) AS oriMinsTaken, 
CASE WHEN (DATEDIFF(mi,CeToCs.startDate, CeToCs.endDate)) > 15 THEN 15 WHEN (DATEDIFF(mi,CeToCs.startDate, CeToCs.endDate)) = 0 THEN 1 ELSE DATEDIFF(mi,CeToCs.startDate, 
CeToCs.endDate) END AS modifiedMins, CeToP.priorityId, CASE WHEN CeToP.priorityId IN (1,9,14,15,20,30,33,143,144) THEN 'Act & Gui'  
WHEN CeToP.priorityId IN (3,10) THEN 'Only Gui' WHEN CeToP.priorityId IN (4,5,6,7,8,11,13,31,32,90,128,130,145,149) THEN 'Estimates' 
WHEN CeToP.priorityId IN (18,19, 55,56) THEN 'eIndices' WHEN CeToP.priorityId IN (46,47) THEN 'eCommodities' END AS ProcessType 
INTO #skippedVerIdDetails_tbl FROM WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) 
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId 
INNER JOIN ComparisonData.DBO.User_tbl Usr (NOLOCK) ON Usr.userId = CeToCs.userId 
WHERE CeToCs.collectionStageId in (2,215,216,217,219,220,221,223,224) AND CeToCs.collectionStageStatusId = 5 AND CeToP.collectionProcessId in (64,4915,4897,4898) 
AND Usr.employeeNumber NOT IN ('000266', '806001', '199001','906036') AND CeToCs.endDate > = (SELECT frDate FROM #esnRunDates_tbl) 
AND CeToCs.endDate < = (SELECT toDate FROM #esnRunDates_tbl) 
INSERT INTO #skippedVerIdDetails_tbl 
SELECT Usr.employeeNumber AS EmpId, Usr.firstName + ' ' + Usr.lastName AS EmpName, CeToP.collectionEntityId, relatedCompanyId = ISNULL(CeToP.relatedCompanyId, -1), 
CeToCs.startDate, CeToCs.endDate, DATEDIFF(mi,CeToCs.startDate, CeToCs.endDate) AS oriMinsTaken, 
CASE WHEN (DATEDIFF(mi,CeToCs.startDate, CeToCs.endDate)) > 15 THEN 15 WHEN (DATEDIFF(mi,CeToCs.startDate, CeToCs.endDate)) = 0 THEN 1 ELSE DATEDIFF(mi,CeToCs.startDate, 
CeToCs.endDate) END AS modifiedMins, CeToP.priorityId, CASE WHEN CeToP.priorityId IN (1,9,14,15,20,30,33,143,144, 146, 3,10) THEN 'Act & Gui - O&G' WHEN CeToP.priorityId 
IN (4,5,6,7,8,11,13,31,32,90,128,130,145,149) THEN 'Estimates - O&G' END AS myProcess 
FROM WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) 
INNER JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) ON CeToP.collectionEntityToProcessId = CeToCs.collectionEntityToProcessId 
INNER JOIN ComparisonData.DBO.User_tbl Usr (NOLOCK) ON Usr.userId = CeToCs.userId 
WHERE CeToP.collectionEntityTypeId = 9 AND CeToP.collectionProcessId in (1062,4915,4897,4898) AND CeToCs.collectionStageId in (2,215,216,217,219,220,221,223,224) 
AND CeToCs.collectionStageStatusId = 5 AND Usr.employeeNumber NOT IN ('000266', '806001', '199001','906036') AND CeToCs.endDate > = (SELECT frDate FROM #esnRunDates_tbl) 
AND CeToCs.endDate < = (SELECT toDate FROM #esnRunDates_tbl) GROUP BY CeToP.collectionEntityId, CeToP.relatedCompanyId, CeToP.priorityId, Usr.employeeNumber, 
Usr.firstName, Usr.lastName, CeToCs.startDate, CeToCs.endDate

CREATE TABLE #doc_tbl (versionId INT, companayId VARCHAR(20), priorityId VARCHAR(6), empId VARCHAR(10), empName VARCHAR(100), endDate DATETIME, myProcess VARCHAR(100),issueSourceId VARCHAR(60), languageId VARCHAR(10), languageName VARCHAR(60))
INSERT INTO #doc_tbl SELECT e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, MAX(e.endDate) AS endDate,              e.myProcess, e.issueSourceId, rdt.languageId, lt.languageName FROM #dEe_tbl e LEFT JOIN ComparisonData.dbo.ResearchDocument_tbl rdt ON rdt.versionId = e.collectionEntityId LEFT JOIN ComparisonData.dbo.Language_tbl lt ON rdt.languageId = lt.languageId GROUP BY e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, e.myProcess, e.issueSourceId, rdt.languageId, lt.languageName
INSERT INTO #doc_tbl SELECT e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, MAX(e.endDate) AS endDate,              e.myProcess, e.issueSourceId, rdt.languageId, lt.languageName FROM #dEi_tbl e LEFT JOIN ComparisonData.dbo.ResearchDocument_tbl rdt ON rdt.versionId = e.collectionEntityId LEFT JOIN ComparisonData.dbo.Language_tbl lt ON rdt.languageId = lt.languageId GROUP BY e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, e.myProcess, e.issueSourceId, rdt.languageId, lt.languageName
INSERT INTO #doc_tbl SELECT e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, MAX(e.endDate) AS endDate,              e.myProcess, e.issueSourceId, rdt.languageId, lt.languageName FROM #dEc_tbl e LEFT JOIN ComparisonData.dbo.ResearchDocument_tbl rdt ON rdt.versionId = e.collectionEntityId LEFT JOIN ComparisonData.dbo.Language_tbl lt ON rdt.languageId = lt.languageId GROUP BY e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, e.myProcess, e.issueSourceId, rdt.languageId, lt.languageName
INSERT INTO #doc_tbl SELECT e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, MAX(e.endDate) AS endDate,              e.myProcess, e.issueSourceId, rdt.languageId, lt.languageName FROM #dEog_tbl e LEFT JOIN ComparisonData.dbo.ResearchDocument_tbl rdt ON rdt.versionId = e.collectionEntityId LEFT JOIN ComparisonData.dbo.Language_tbl lt ON rdt.languageId = lt.languageId WHERE e.myProcess = 'Estimates - O&G' GROUP BY e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, e.myProcess, e.issueSourceId, rdt.languageId, lt.languageName
INSERT INTO #doc_tbl SELECT e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, MAX(e.endDate) AS endDate, e.myProcess, e.issueSourceId, dEcV.originalLanguageId, lt.languageName FROM #dEog_tbl e LEFT JOIN DocumentRepositoryProcessing.dbo.DocumentElementCache_vw dEcV ON dEcV.versionId = e.collectionEntityId LEFT JOIN ComparisonData.dbo.Language_tbl lt ON dEcV.originalLanguageId = lt.languageId WHERE e.myProcess = 'Act & Gui - O&G' GROUP BY e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, e.myProcess, e.issueSourceId, dEcV.originalLanguageId, lt.languageName
INSERT INTO #doc_tbl SELECT e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, MAX(e.endDate) AS endDate, e.myProcess, e.issueSourceId, dEcV.originalLanguageId, lt.languageName FROM #dEag_tbl e LEFT JOIN DocumentRepositoryProcessing.dbo.DocumentElementCache_vw dEcV ON dEcV.versionId = e.collectionEntityId LEFT JOIN ComparisonData.dbo.Language_tbl lt ON dEcV.originalLanguageId = lt.languageId GROUP BY e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, e.myProcess, e.issueSourceId, dEcV.originalLanguageId, lt.languageName
INSERT INTO #doc_tbl SELECT e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, MAX(e.endDate) AS endDate, e.myProcess, e.issueSourceId, dEcV.originalLanguageId, lt.languageName FROM #dEaff_tbl e LEFT JOIN DocumentRepositoryProcessing.dbo.DocumentElementCache_vw dEcV ON dEcV.versionId = e.collectionEntityId LEFT JOIN ComparisonData.dbo.Language_tbl lt ON dEcV.originalLanguageId = lt.languageId GROUP BY e.collectionEntityId, e.relatedCompanyId, e.priorityId, e.EmpId, e.EmpName, e.myProcess, e.issueSourceId, dEcV.originalLanguageId, lt.languageName
------------------------------------------------------------------------------------------------------------

-- Data points
SELECT e.*, ist.issueSourceName,RF.Description VersionFormat FROM #esnFinal_tbl e 
LEFT JOIN WorkflowArchive_Estimates.dbo.IssueSource_tbl ist (NOLOCK) ON ist.issueSourceId = e.issueSourceId 
left join ComparisonData.dbo.ResearchDocument_tbl Rd (nolock) on rd.VersionId = e.versionId
left join DocumentRepositoryProcessing..Version_tbl v on v.versionId=e.VersionId
left join DocumentRepositoryProcessing.DBO.VersionFormat_tbl RF ON RF.FormatID=isnull(RD.versionFormatId,v.formatId)
ORDER BY endDate

SELECT a.*, ist.issueSourceName FROM #esnFinal_Ag_tbl a 
LEFT JOIN WorkflowArchive_Estimates.dbo.IssueSource_tbl ist (NOLOCK) ON ist.issueSourceId = a.issueSourceId 
UNION ALL 
SELECT c.*, ist.issueSourceName FROM #esnCoverateEvents_tbl c 
LEFT JOIN WorkflowArchive_Estimates.dbo.IssueSource_tbl ist (NOLOCK) ON ist.issueSourceId = c.issueSourceId

-- skipped
SELECT EmpId, EmpName, collectionEntityId, relatedCompanyId, priorityId, '123' AS languageId, 'skipped' AS auditTypeName, ProcessType, endDate, 
1 AS noOfDPs, 'skipped' Lanaugae, isHidden = 'No',RF.Description VersionFormat FROM #skippedVerIdDetails_tbl e
left join ComparisonData.dbo.ResearchDocument_tbl Rd (nolock) on rd.VersionId = e.collectionEntityId
left join DocumentRepositoryProcessing..Version_tbl v on v.versionId=e.collectionEntityId
left join DocumentRepositoryProcessing.DBO.VersionFormat_tbl RF ON RF.FormatID=isnull(RD.versionFormatId,v.formatId)
--where collectionEntityId=1972987410

-- Documents:
SELECT e.*,RF.Description VersionFormat FROM #doc_tbl e
left join ComparisonData.dbo.ResearchDocument_tbl Rd (nolock) on rd.VersionId = e.VersionId
left join DocumentRepositoryProcessing..Version_tbl v on v.versionId=e.VersionId
left join DocumentRepositoryProcessing.DBO.VersionFormat_tbl RF ON RF.FormatID=isnull(RD.versionFormatId,v.formatId)
