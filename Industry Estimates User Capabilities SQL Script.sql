--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE

USE ApplicationManager

SELECT DISTINCT UT.displayName AS EMPLOYEE_NAME, UT.employeeNumber AS EMP_ID,C.displayName AS CAPABILITY_NAME

FROM ComparisonData.hyd.ObjectToCapability_tbl OTCT (NOLOCK)

INNER JOIN ApplicationManager.dbo.User_tbl UT (NOLOCK) ON OTCT.objectId = UT.userId
INNER JOIN comparisondata.hyd.Capability_tbl C (NOLOCK) ON OTCT.capabilityId = C.capabilityId

WHERE

UT.primaryUserGroupId IN (900000940)

AND UT.employeeNumber IN ('B09014','311010') ----Provide Employee ID's in Inverted commas


SELECT DISTINCT * FROM [dbo].[Capability_tbl]
SELECT DISTINCT TOP 10 * FROM ApplicationManager.[dbo].[FunctionalityGroup_tbl]
SELECT DISTINCT * FROM comparisondata.hyd.Capability_tbl

SELECT DISTINCT * FROM ApplicationManager.[dbo].[Application_tbl] order by applicationname

SELECT DISTINCT * FROM ApplicationManager.[dbo].[ApplicationFunctionality_tbl]
SELECT DISTINCT * FROM ApplicationManager.[dbo].[User_tbl] WHERE employeeNumber in ('B09014')
SELECT DISTINCT TOP 10 * FROM comparisondata.[HYD].[CapabilityToCapabilityGroup_tbl]

SELECT DISTINCT TOP 10 * FROM ApplicationManager.[dbo].[AD_Users_Hyd_tmp]

SELECT DISTINCT TOP 10 * FROM ApplicationManager.[dbo].[CapabilityToCapabilityGroup_tbl]
--@applicationId ,121 EEDCA,140 CTadmin,1,4 FDCA,200 FDCA III
EXEC ApplicationManager.[dbo].[FetchCapability_Prc] @userid = 910285973 , @applicationId = 121,@applicationfunctionalityId = 71
EXEC ApplicationManager.[dbo].[FetchCapability_Prc] @userid = 910285973 , @applicationId = 200,@applicationfunctionalityId = 71