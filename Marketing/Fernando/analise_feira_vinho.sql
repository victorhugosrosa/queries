--DECLARE @DT_INI AS DATE = '2013-12-30'
--DECLARE @DT_FIM AS DATE = '2014-12-28'

DECLARE @DT_INI AS DATE = '2014-12-29'
DECLARE @DT_FIM AS DATE = '2015-09-27'

SELECT
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,VP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,CP.NO_GRUPO	
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.VALOR_TOTAL)) AS VLR_TOTAL
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.QTDE_PRODUTO)) AS QTD_TOTAL
FROM
	BI.dbo.BI_VENDA_PRODUTO AS VP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON VP.COD_PRODUTO = CP.COD_PRODUTO
	LEFT JOIN BI.dbo.BI_CAD_SEMANA AS S
		ON VP.DATA = S.DATA
WHERE 1=1
	AND VP.COD_LOJA = 7
	AND CP.COD_SECAO = 27
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DT_INI) AND CONVERT(DATE,@DT_FIM)
GROUP BY
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,VP.COD_PRODUTO
	,CP.DESCRICAO
	,CP.NO_GRUPO
ORDER BY
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CP.DESCRICAO
		

SELECT
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CONVERT(DATE,S.DATA) AS DATA
	,(CASE
		WHEN DATEPART(DW,S.DATA) = 1 THEN 'Dom'
		WHEN DATEPART(DW,S.DATA) = 2 THEN 'Seg'
		WHEN DATEPART(DW,S.DATA) = 3 THEN 'Ter'
		WHEN DATEPART(DW,S.DATA) = 4 THEN 'Qua'
		WHEN DATEPART(DW,S.DATA) = 5 THEN 'Qui'
		WHEN DATEPART(DW,S.DATA) = 6 THEN 'Sex'
		WHEN DATEPART(DW,S.DATA) = 7 THEN 'Sab'
	END) AS WEEK_DAY
	,VP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,CP.NO_GRUPO	
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.VALOR_TOTAL)) AS VLR_TOTAL
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.QTDE_PRODUTO)) AS QTD_TOTAL
FROM
	BI.dbo.BI_VENDA_PRODUTO AS VP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON VP.COD_PRODUTO = CP.COD_PRODUTO
	LEFT JOIN BI.dbo.BI_CAD_SEMANA AS S
		ON VP.DATA = S.DATA
WHERE 1=1
	AND VP.COD_LOJA = 7
	AND CP.COD_SECAO = 27
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DT_INI) AND CONVERT(DATE,@DT_FIM)
GROUP BY
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CONVERT(DATE,S.DATA)	
	,VP.COD_PRODUTO
	,CP.DESCRICAO
	,CP.NO_GRUPO
ORDER BY
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CONVERT(DATE,S.DATA)	
	,CP.DESCRICAO
		


SELECT
	VP.COD_LOJA
	,S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CP.NO_GRUPO	
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.VALOR_TOTAL)) AS VLR_TOTAL
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.QTDE_PRODUTO)) AS QTD_TOTAL
FROM
	BI.dbo.BI_VENDA_PRODUTO AS VP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON VP.COD_PRODUTO = CP.COD_PRODUTO
	LEFT JOIN BI.dbo.BI_CAD_SEMANA AS S
		ON VP.DATA = S.DATA
WHERE 1=1
	AND CP.COD_SECAO = 27
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DT_INI) AND CONVERT(DATE,@DT_FIM)
GROUP BY
	VP.COD_LOJA
	,S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CP.NO_GRUPO	
ORDER BY
	VP.COD_LOJA
	,S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CP.NO_GRUPO	

-- --------------------------------------------------------------------------------------------------------------------------------------------------
--
-- --------------------------------------------------------------------------------------------------------------------------------------------------	
DECLARE @DT_INI_FEIRA_2014 AS DATE = '2014-07-24'
DECLARE @DT_FIM_FEIRA_2014 AS DATE = '2014-07-26'	

DECLARE @DT_INI_FEIRA_2015 AS DATE = '2015-09-18'
DECLARE @DT_FIM_FEIRA_2015 AS DATE = '2015-09-20'	

SELECT
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CONVERT(DATE,S.DATA) AS DATA
	,(CASE
		WHEN DATEPART(DW,S.DATA) = 1 THEN 'Dom'
		WHEN DATEPART(DW,S.DATA) = 2 THEN 'Seg'
		WHEN DATEPART(DW,S.DATA) = 3 THEN 'Ter'
		WHEN DATEPART(DW,S.DATA) = 4 THEN 'Qua'
		WHEN DATEPART(DW,S.DATA) = 5 THEN 'Qui'
		WHEN DATEPART(DW,S.DATA) = 6 THEN 'Sex'
		WHEN DATEPART(DW,S.DATA) = 7 THEN 'Sab'
	END) AS WEEK_DAY
	,VP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,CP.NO_GRUPO
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.VLR_VENDA)) AS VLR_TOTAL
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.QTDE_VENDA))	AS QTD_TOTAL
FROM
	BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON VP.COD_PRODUTO = CP.COD_PRODUTO
	LEFT JOIN BI.dbo.BI_CAD_SEMANA AS S
		ON VP.DATA = S.DATA
WHERE 1=1
	AND VP.COD_LOJA = 7
	AND CP.COD_SECAO IN (27)
	AND VP.CAIXA IN (25)
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DT_INI_FEIRA_2014) AND CONVERT(DATE,@DT_FIM_FEIRA_2014)
GROUP BY
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CONVERT(DATE,S.DATA)
	,VP.COD_PRODUTO
	,CP.DESCRICAO
	,CP.NO_GRUPO
ORDER BY
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CP.DESCRICAO
		
		
SELECT 
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CONVERT(DATE,S.DATA) AS DATA
	,COUNT(DISTINCT VP.CUPOM_HASH) AS  QTD_CUPONS
	,COUNT(DISTINCT CASE WHEN VCC.CPF_NFP IS NOT NULL OR VCC.CPF_VCM IS NOT NULL THEN VP.CUPOM_HASH END) AS  QTD_CUPONS_CPF
FROM
	BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VP
	INNER JOIN BI.dbo.BI_VENDA_CUPOM_CAPA AS VCC
		ON VP.CUPOM_HASH = VCC.CUPOM_HASH
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON VP.COD_PRODUTO = CP.COD_PRODUTO
	LEFT JOIN BI.dbo.BI_CAD_SEMANA AS S
		ON VP.DATA = S.DATA
WHERE 1=1
	AND VP.COD_LOJA = 7
	AND CP.COD_SECAO IN (27)
	AND VP.CAIXA IN (25)
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DT_INI_FEIRA_2014) AND CONVERT(DATE,@DT_FIM_FEIRA_2014)
GROUP BY
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CONVERT(DATE,S.DATA)
	
SELECT 
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CONVERT(DATE,S.DATA) AS DATA	
	,''''+(CASE WHEN VCC.CPF_NFP IS NOT NULL THEN CONVERT(VARCHAR,VCC.CPF_NFP) ELSE CONVERT(VARCHAR,VCC.CPF_VCM) END) AS CPF
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.VLR_VENDA)) AS VLR_TOTAL
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.QTDE_VENDA))	AS QTD_TOTAL
FROM
	BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VP
	INNER JOIN BI.dbo.BI_VENDA_CUPOM_CAPA AS VCC
		ON VP.CUPOM_HASH = VCC.CUPOM_HASH
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON VP.COD_PRODUTO = CP.COD_PRODUTO
	LEFT JOIN BI.dbo.BI_CAD_SEMANA AS S
		ON VP.DATA = S.DATA
WHERE 1=1
	AND VP.COD_LOJA = 7
	AND CP.COD_SECAO IN (27)
	AND VP.CAIXA IN (25)
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DT_INI_FEIRA_2014) AND CONVERT(DATE,@DT_FIM_FEIRA_2014)
GROUP BY
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,CONVERT(DATE,S.DATA)
	,''''+(CASE WHEN VCC.CPF_NFP IS NOT NULL THEN CONVERT(VARCHAR,VCC.CPF_NFP) ELSE CONVERT(VARCHAR,VCC.CPF_VCM) END)