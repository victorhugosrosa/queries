SELECT
	L.[ID_ROTINA] as [ID]
	,R.NO_ROTINA as [Rotina]
	,L.[DTA_INICIO] as [Data Ini]
	,L.[TEMPO]/60 as [Minutos]
FROM
	[BI].[dbo].[BI_LOG_ROTINA] AS L
	INNER JOIN BI.dbo.BI_CAD_ROTINA AS R
		ON L.ID_ROTINA = R.ID_ROTINA
WHERE 1=1
	AND CONVERT(DATE,L.DTA_INICIO) >= CONVERT(DATE,GETDATE()-30)
	AND L.ID_ROTINA NOT IN (1,2,15,9)
	and L.ID_ROTINA = 31
order by DTA_INICIO desc


