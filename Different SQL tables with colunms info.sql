
Select top 10 * from [Estimates].[dbo].[EstimateDetailNumericData_tbl] -------Data availab for different companies,Audittypeid,DATAITEMID,LASTMODIFIEDUTCDATETIME,unitsId,
Select top 10 * from [Estimates].[dbo].[EstimatePeriod_tbl] ----- Different periods will be available,FISCALYEAR,FISCALQUARTER,PERIODTYPEID,PERIODENDDATE
Select top 40 * from [Estimates].[dbo].DATAITEMMASTER_VW ----- Dataitemid,flavortypeid,dataitemname,datacollectiontypeid,flagEAG
Select top 40 * from [Estimates].[dbo].ESTIMATEDETAIL_TBL where versionId is not NULL ----Versionid,companyid,researchcontributorid,effectivedate,parentflag,tradingitem,flavortypeid

Select DISTINCT Ticker,CIQCompanyId,CompanyName from companymaster..companyinfomaster where Ticker in ('BKH','CMS','DUK') -------- Based on Tickerid getting company name and company id

Select top 40 * from companymaster..companyinfomaster where Ticker is not null and Country in ('INDIA')

Select top 40 * from [Estimates].[dbo].[CompanyNotes_tbl] ----------company notes

select top 40 * from CTAdminRepTables.dbo.user_tbl  ------Employee details like userid,name etc

select top 40 * from workflowArchive_Estimates.dbo.commontracker_vw  ------ CT Admin data---userid,insertdate,relatedcompanyid,startdate,enddate,collectionstageStatusid,priorityid

select * from CTAdminRepTables.[dbo].[CollectionStage_tbl]  -------------- PP=1 & production=2[CTAdminRepTables]

select top 40 * from ComparisonData.dbo.ResearchDocument_tbl   -------------- researchContributorId

select top 40 * from WorkflowArchive_Estimates.dbo.collectionStageComment_tbl  --------collectionEntityToCollectionStageID

select top 40 * from Workflow_Estimates.[dbo].[CollectionEntityStatus_tbl]

select top 65 * from Workflow_Estimates.[dbo].[CollectionProcess_tbl] ----- CollectionProcessId=64(Estimates/Actuals/Guidance)

select top 65 * from Workflow_Estimates.[dbo].[CollectionEntityType_tbl]  ----collectionEntityTypeId =9

select top 65 * from Workflow_Estimates.[dbo].[CollectionStageStatus_tbl]

select top 40 * from Comparisondata.dbo.Company_tbl   ---companyid,companyname,ticker

select top 40 * from ComparisonData.dbo.ResearchContributor_tbl order by researchContributorId desc  ------researchContributorId,contributorShortName

select top 40 * from ComparisonData.dbo.ResearchDocument_tbl order by researchContributorId desc -------versionId,researchContributorId,headline

select * from WorkflowArchive_Estimates.dbo.Priority_tbl


