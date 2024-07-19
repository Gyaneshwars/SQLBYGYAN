--- PYTHON & SQL ETL DEVELOPER-GNANESHWAR SRAVANE
USE Estimates

IF OBJECT_ID ('TEMPDB..#STDM') IS NOT NULL DROP TABLE #STDM
SELECT DISTINCT ct.collectionEntityId AS VersionId,cet.collectionEntityTypeName AS EntityType,ct.relatedcompanyid AS CompanyId,stt.subTypeId,stt.subTypeValue,
cp.collectionProcessName AS CollectionProcess,cp.collectionProcessId,cs.collectionStageName AS CollectionStage,CTI.IndustryName AS Industry,ct.collectionstageId INTO #STDM 
FROM          WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct (NOLOCK)
LEFT JOIN     WorkflowArchive_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl ctdp (NOLOCK) ON ctdp.collectionEntityToProcessId=ct.collectionEntityToProcessId and ctdp.datapointId=1887
LEFT JOIN     Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl est (NOLOCK) ON est.industrySubTypeId=ctdp.value
LEFT JOIN     WorkflowArchive_Estimates.dbo.CollectionProcess_tbl cp (NOLOCK) ON cp.collectionProcessId=isnull(est.collectionProcessId,ct.collectionProcessId)
LEFT JOIN     Workflow_Estimates.[dbo].[CollectionStage_tbl] cs (NOLOCK) ON cs.collectionStageId=ct.collectionstageId
LEFT JOIN     Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=ct.collectionstageStatusId
LEFT JOIN     Estimates.[dbo].estimatedetail_tbl ed (NOLOCK) ON ct.collectionEntityId = ISNULL(ed.versionid,ed.feedFileId)
LEFT JOIN     ComparisonData.[dbo].[Company_tbl] ctl (NOLOCK) ON ct.relatedcompanyid = ctl.companyId
LEFT JOIN     Comparisondata.dbo.SubType_tbl stt (NOLOCK) ON stt.SubTypeId=ctl.PrimarySubTypeId
LEFT JOIN     CompanyMaster.[dbo].CompanyInfoMaster cm (NOLOCK) ON cm.CIQCompanyId=ct.relatedCompanyId
LEFT JOIN	  Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cm.IndustryID = CTI.IndustryId
LEFT JOIN     Workflow_Estimates.[dbo].[CollectionEntityType_tbl] cet (NOLOCK) ON cet.collectionEntityTypeId=ct.collectionEntityTypeId
WHERE 
              ct.collectionProcessId IN (64,1062,4861,4862,4863,4864,4899,4900,4901,4902,4903,4904,4905,4906,4907)
AND           ct.collectionstageId IN (2)
AND           ct.collectionstageStatusId IN (4)
AND           ct.collectionEntityId IS NOT NULL
AND           ct.relatedcompanyid IS NOT NULL
AND           stt.subTypeId IN (2061000,3021000,3241000,4012000,4312000,5221000,7211000,8042000,8133000,8212000,9521000,9541000,9612009,9621063,9621091,9622304)
---AND           usr.employeeNumber NOT IN ('000387','000266','000EF2','000EF3','00000A')



---SELECT DISTINCT * FROM #STDM

IF OBJECT_ID ('TEMPDB..#SLA1') IS NOT NULL DROP TABLE #SLA1
SELECT a.* INTO #SLA1 FROM #STDM a
INNER JOIN #STDM b ON a.VersionId=b.VersionId AND a.CompanyId=b.CompanyId
WHERE a.collectionstageId=122 AND b.collectionstageId=2

---SELECT * FROM #SLA1

IF OBJECT_ID ('TEMPDB..#SLA2') IS NOT NULL DROP TABLE #SLA2
SELECT a.* INTO #SLA2 FROM #STDM a
INNER JOIN #STDM b ON a.VersionId=b.VersionId AND a.CompanyId=b.CompanyId
WHERE a.collectionstageId=2 AND b.collectionstageId=122

---SELECT * FROM #SLA2


---SELECT DISTINCT CompanyId,subTypeId,subTypeValue,CollectionProcess AS Docs_moving_to_which_industry,collectionProcessId AS Docs_moving_to_which_industryID FROM #STDM ORDER BY CompanyId
--EXCEPT
--SELECT DISTINCT subTypeId,subTypeValue,CollectionProcess AS Docs_moving_to_which_industry FROM #SLA2

SELECT DISTINCT subTypeId,subTypeValue,CollectionProcess AS Docs_moving_to_which_industry,collectionProcessId AS Docs_moving_to_which_industryID FROM #STDM ORDER BY subTypeId

SELECT DISTINCT CompanyId,subTypeId,subTypeValue,CollectionProcess AS Docs_moving_to_which_industry,collectionProcessId AS Docs_moving_to_which_industryID FROM #STDM ORDER BY CompanyId
