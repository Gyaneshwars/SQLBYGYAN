--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNYANESHWAR SRAVANE


IF OBJECT_ID('TEMPDB..#EstiCoverage') IS NOT NULL DROP TABLE #EstiCoverage
SELECT DISTINCT ed.companyId INTO #EstiCoverage FROM estimates.[dbo].[EstimateDetail_tbl] ed
INNER JOIN estimates.[dbo].[EstimateDetailToAsOfDate_tbl] ed2 (NOLOCK) ON ed.estimateDetailId=ed2.estimateDetailId


SELECT DISTINCT * FROM #EstiCoverage