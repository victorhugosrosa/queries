DECLARE @DATA AS DATE = GETDATE()-1

DECLARE @DTA_INI_MES AS DATE = DW.[DBO].[fn_PrimeiroDiadoMes](CONVERT(DATE,@DATA)) 
-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------------------------------------------------------------
DELETE FROM [BI].[dbo].[BI_VENDA_PRODUTO_MES]
WHERE 1 = 1
	AND MES = MONTH(GETDATE())

INSERT INTO [BI].[dbo].[BI_VENDA_PRODUTO_MES]
(
	[COD_LOJA]
	,[ANO]
	,[MES]
	,[COD_PRODUTO]
	,[TIPO_VENDA]
	,[QTD_PRODUTO]
	,[VLR_TOTAL]
	,[QTD_DEMANDA]
)
SELECT
	[COD_LOJA]
	,YEAR([DATA]) AS ANO
	,MONTH([DATA]) AS MES
	,[COD_PRODUTO]
	,[TIPO_VENDA]
	,SUM([QTDE_PRODUTO])
	,SUM([VALOR_TOTAL])
	,SUM([QTDE_DEMANDA])
FROM
	[BI].[dbo].[BI_VENDA_PRODUTO]
WHERE 1 = 1
	AND CONVERT(DATE,DATA) >= CONVERT(DATE,@DTA_INI_MES)
GROUP BY
	[COD_LOJA]
	,YEAR([DATA])
	,[COD_PRODUTO]
	,[TIPO_VENDA]
ORDER BY
	[COD_LOJA]
	,YEAR([DATA])
	,[COD_PRODUTO]
	
-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO [BI].[dbo].[BI_VENDA_PRODUTO_ANO]
(
	[COD_LOJA]
	,[ANO]
	,[COD_PRODUTO]
	,[TIPO_VENDA]
	,[QTD_PRODUTO]
	,[VLR_TOTAL]
	,[QTD_DEMANDA]
)
SELECT
	[COD_LOJA]
	,YEAR([DATA]) AS ANO
	,[COD_PRODUTO]
	,[TIPO_VENDA]
	,SUM([QTDE_PRODUTO])
	,SUM([VALOR_TOTAL])
	,SUM([QTDE_DEMANDA])
FROM
	[BI].[dbo].[BI_VENDA_PRODUTO]
WHERE 1 = 1
	AND CONVERT(DATE,DATA) >= '20140101'
GROUP BY
	[COD_LOJA]
	,YEAR([DATA])
	,[COD_PRODUTO]
	,[TIPO_VENDA]
ORDER BY
	[COD_LOJA]
	,YEAR([DATA])
	,[COD_PRODUTO]