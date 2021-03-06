/****** SCRIPT FOR SELECTTOPNROWS COMMAND FROM SSMS  ******/
SELECT 
	YEAR(DTA_ENTRADA) AS ANO
	,[COD_FORNECEDOR]
	,DES_FORNECEDOR
	,SUM([VAL_TABELA_LIQ]) AS VLR_ENTRADA
FROM
	[ZEUS_RTG].[DBO].[VW_MARCHE_ENTRADAS]
WHERE 1=1
	AND CONVERT(DATE,DTA_ENTRADA) BETWEEN CONVERT(DATE,'2013-01-01') AND CONVERT(DATE,'2015-12-31')
GROUP BY
	YEAR(DTA_ENTRADA)
	,[COD_FORNECEDOR]
	,DES_FORNECEDOR