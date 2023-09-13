
use comparisondata  
IF OBJECT_ID ('TEMPDB..#count') IS NOT NULL DROP TABLE #count
SELECT distinct RC.ContributorShortName AS ContributorName, RD.VersionID as versionn,
 RD.LastUpdatedDateUTC FilingDate,L.LanguageName AS Language,RD.primaryCompanyId as PrimaryCID,RC.ResearchContributorID AS ContributorID,
 Rd.headline, Rd.[pageCount],ff.researchFocusName,vd.filePath as path,Comment='\\II48HNAS001\DocumentRepositoryResearchRoot\',vfd.fileExtension into #count FROM ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK)
INNER JOIN ResearchContributor_tbl RC (NOLOCK)ON RD.ResearchContributorID = RC.ResearchContributorID
LEFT JOIN Language_tbl L (NOLOCK)ON L.LanguageID = RD.LanguageID
LEFT JOIN  dbo.ResearchDocumentToResearchFocus_tbl f (NOLOCK)ON f.researchDocumentId= rd.researchDocumentId
left join dbo.ResearchFocus_tbl ff (NOLOCK)ON ff.researchFocusId =f.researchFocusId
left join DocumentRepository.dbo.Version_tbl vd (nolock) on vd.versionId =rd.versionId
left join DocumentRepository.[dbo].[VersionFormat_tbl] vfd (nolock) on vfd.FormatID=vd.formatID
where rd.versionid in (1499855802,1500209712,1500237010,1501235592,1500684696,1501299274,1500171032,1500325050,1500704322,1499938694,1500949824,1500995796,1501040776,1501097586,1501148276,1501294742,1501314648,1499806990,1499843142,1500134604,1500223928,1500294346,1500306056,1499727608,1500480810,1500386428,1500388228,1500393010,1499383116,1499668218,1499701708,1499719390,1499817942,1499894744,1500087208,1500403482,1499851898,1500486298,1499766050,1499842212,1499911642,1499941258,1501310306,1501311360,1499415958,1499547188,1499581778,1499581796,1499733846,1499740858,1499746136,1499753568,1499782456,1499842790,1499842798,1499856994,1499887352,1499954100,1500099222,1500111922,1500134064,1500156718,1500171014,1500212114,1500385982,1500574328,1500584846,1500585128,1500585242,1500585348,1500594672,1500766566,1501230016,1501251004,1501251414,1501218136,1501255630,1501279886,1501326294,1499883862,1500187988,1499059324,1499779382,1499956128,1500146750,1500306926,1500547038,1501289436,1500401286,1500001202,1500202538,1500404462,1499885006,1499918128,1500245142,1499510680,1499555226,1499573424,1499614220,1499768980,1499960520,1499972118,1499972934,1499976878,1499977110,1499982712,1500002312,1500008378,1500008518,1500027642,1500037262,1500041128,1500064502,1500072414,1500215614,1500267790,1500309068,1500475286,1500605222,1500649592,1500727714,1500774654,1501106188,1501199164,1501235502,1501319660,1499665934,1499699240,1499701678,1499721252,1499811798,1499818222,1499857708,1499880352,1499889942,1499899474,1500104018,1500131138,1500234914,1500270756,1500279440,1500285332,1500311410,1500317164,1500323770,1500327516,1500366136,1500384650,1500410314,1500430992,1500431330,1500446594,1500481566,1500501726,1500503048,1500505376,1500556300,1500577380,1500691202,1500704154,1500083798,1500327322,1500396360,1500501204,1501281068,1499766742,1500520942,1500556410,1501154202,1501252654,1501253780,1501270082,1499974444,1501277518,1498744526,1499962630,1499747206,1499751340,1499674592,1501233718,1501240572,1501246984,1501267188,1499911730,1501336578,1500919712,1500928654,1500006670,1500083324,1500003592,1500019172,1500022198,1500042344,1500030774,1500056750,1500193744,1501309136,1499753678,1499898226,1500039398,1499721588,1500224062,1500224918,1500391606,1500044042,1500049856,1500127418,1500016248,1501267020,1500533686,1501334948,1499818030,1501329320,1500059158,1500101876,1499597436,1499856014,1499883680,1500193714,1500201262,1500613828,1499766612,1501100152,1501236264,1499987578)


use comparisondata  
IF OBJECT_ID ('TEMPDB..#prod_loaded') IS NOT NULL DROP TABLE #prod_loaded
SELECT distinct ct.collectionEntityId as vid,ct.relatedCompanyId, C.CompanyName,C.tickerSymbol as ticker  into #prod_loaded FROM [WorkflowArchive_Estimates].[dbo].[CommonTracker_vw] ct (NOLOCK)
--LEFT JOIN ResearchDocumentToCompany_tbl RDC (NOLOCK)ON RD.ResearchDocumentID = RDC.ResearchDocumentID
LEFT JOIN Company_tbl C (NOLOCK)ON C.CompanyID = ct.relatedCompanyId
--left join [WorkflowArchive_Estimates].[dbo].[CommonTracker_vw] ct (nolock) on ct.collectionEntityId = rd.VersionID and ct.relatedCompanyId = rdc.CompanyID
inner join #count co on co.versionn = ct.collectionEntityId
where ct.collectionstageId=2 and ct.issueSourceId in (2,122) --and ct.collectionstageStatusId 



select Querydate= getdate(),cu.versionn,cu.ContributorName,cu.FilingDate,cu.Language,cu.[pageCount],cu.headline,pl.CompanyName,pl.ticker,--cu.researchFocusName,
linkpath='\\II48HNAS001\DocumentRepositoryResearchRoot\'+cast(path as varchar) +cast(versionn as varchar)+'.'+cast(fileextension as varchar) from #count cu
left join #prod_loaded pl on cu.versionn = pl.vid

--where pageCount<10

