
Select top 40 * from [Estimates].dbo.[EstimateDetail_tbl] where versionId is not null -----estimateDetailId, versionId,Tradingitemid , contributorid,filingdate,companyid,parentflag,accountingstandardid.flavorTypeid

Select top 40 * from [Estimates].[dbo].[EstimateDetailNumericData_tbl]  ---------- estimateDetailId,DataitemId & data item value

Select top 40 * from [Estimates].[dbo].[EstimateConsensus_tbl]  ----- Companyid,estimateConsusId,estimatePeriodId,tradingItemId

Select top 40 * from [Estimates].[dbo].[EstimatePeriod_tbl]  ----- CompanyId,estimatePeriodId,fiscalYear

Select top 40 * from [Estimates].[dbo].[EstimateCompany_tbl] ---- CompanyId,Tradingitemid,CurrencyId,parentflag


Select top 40 * from [Workflow_Estimates].[dbo].[CollectionStage_tbl] ----CollectionStageId,CollectionStageName

Select top 40 * from [Workflow_Estimates].[dbo].[DataPoint_tbl]  ---- dataPointId,dataPointName,collectionProcessId

Select top 40 * from [Workflow_Estimates].[dbo].[WorkflowState_tbl]  ---- collectionProcessId,collectionStageId

Select top 40 * from [Workflow_Estimates].[dbo].[Priority_tbl]  -----PriorityId,PriorityName

Select top 40 * from [Workflow_Estimates].[dbo].[CollectionProcess_tbl] ---- collectionProcessId,collectionProcessName


Select top 40 * from ComparisonData.dbo.ResearchDocument_tbl ----researchContributorId,researchDocumentId,versionId,headline,filingdate,enteredDate,lastUpdatedDate,PageCount,languageId,versionformatId,lastUpdatedDateUTC,primaryCompanySymbol

Select top 40 * from ComparisonData.dbo.ResearchContributor_tbl ---companyId,researchContributorId,ContributorShortName

Select top 40 * from ComparisonData.dbo.ResearchDocumentToCompany_tbl ----researchDocumentId,companyId,researchDocumentToCompanyId

Select top 40 * from ComparisonData.dbo.Company_tbl ----companyName,tickerSymbol,companyId

Select top 40 * from ComparisonData.dbo.Language_tbl ----languageId,languageName

Select top 40 * from ComparisonData.dbo.ResearchDocumentToResearchFocus_tbl  ----researchDocumentId,researchFocusId

Select top 40 * from ComparisonData.dbo.ResearchFocus_tbl ----researchFocusId,researchFocusName,researchFocusRank

Select top 40 * from ComparisonData.[dbo].[ResearchDocumentToResearchEvent_tbl] ----researchDocumentId,researchDocumentToResearchEventId


Select top 40 * from WorkflowArchive_Estimates.dbo.CommonTracker_vw ----collectionentityid,relatedCompanyId,userId,collectionStageId,startdate,endDate,PriorityID

Select top 40 * from WorkflowArchive_Estimates.dbo.User_tbl --- userId,firstName,lastName,title,employeeNumber,emailAddress,displayName


Select top 40 * from DocumentRepository.dbo.ContentSearchResult_tbl

Select * from ComparisonData.[dbo].[Currency_tbl]

Select top 40 * from WorkflowArchive_Estimates.dbo.CommonTracker_vw -------- CT admin data

Select top 40 * from [ComparisonData]..[Company_vw]  ---------- company name,id,ticker,subtypeid

Select top 40 * from [ComparisonData].[dbo].[SubType_tbl] ----subtypeid

