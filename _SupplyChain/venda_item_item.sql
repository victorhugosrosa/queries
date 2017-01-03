-- ---------------------------------------------------------------------------------------------------------------------------------------
--
-- ---------------------------------------------------------------------------------------------------------------------------------------
SELECT
	VP.COD_LOJA AS Loja
	,convert(date,VP.DATA) AS Data
	,VP.COD_PRODUTO as PLU
	,CP.DESCRICAO as Descricao
	,CP.NO_DEPARTAMENTO as Dep
	,CP.NO_SECAO as Sec
	,CP.NO_GRUPO as Grupo
	,CP.FORA_LINHA
	,BI.dbo.fn_FormataVlr_Excel(VP.QTDE_PRODUTO) as [Qtd Prod]
	,BI.dbo.fn_FormataVlr_Excel(VP.VALOR_TOTAL) as [Vlr Prod]
	,BI.dbo.fn_FormataVlr_Excel(EPD.QTD_ESTOQUE) as Estoque
FROM
	BI.dbo.BI_VENDA_PRODUTO VP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO CP
		ON 1=1
		AND VP.COD_PRODUTO = CP.COD_PRODUTO
	INNER JOIN BI.dbo.BI_ESTOQUE_PRODUTO_DIA EPD
		ON 1=1
		AND VP.COD_PRODUTO = EPD.COD_PRODUTO
		AND VP.COD_LOJA = EPD.COD_LOJA
		AND VP.DATA = EPD.DATA
WHERE 1=1 
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,GETDATE()-90) AND CONVERT(DATE,GETDATE())
	AND CP.PNP = 'NP'
	AND VP.COD_LOJA IN (1,3,2,6,7,8)
	--AND VP.COD_LOJA IN (9,13,12,17,18,20,22)
	--AND VP.COD_LOJA IN (23,24,30,31,21,25,27)
ORDER BY
	CONVERT(DATE,VP.DATA)
	
-- ---------------------------------------------------------------------------------------------------------------------------------------
--
-- ---------------------------------------------------------------------------------------------------------------------------------------
/*
SELECT
	EPD.COD_LOJA AS Loja
	,convert(date,EPD.DATA) AS Data
	,EPD.COD_PRODUTO as PLU
	,CP.DESCRICAO as Descricao
	,CP.NO_DEPARTAMENTO as Dep
	,CP.NO_SECAO as Sec
	,CP.NO_GRUPO as Grupo
	,CP.FORA_LINHA
	,BI.dbo.fn_FormataVlr_Excel(VP.QTDE_PRODUTO) as [Qtd Prod]
	,BI.dbo.fn_FormataVlr_Excel(VP.VALOR_TOTAL) as [Vlr Prod]
	,BI.dbo.fn_FormataVlr_Excel(EPD.QTD_ESTOQUE) as Estoque
FROM
	BI.dbo.BI_ESTOQUE_PRODUTO_DIA EPD
	INNER JOIN BI.dbo.BI_CAD_PRODUTO CP
		ON 1=1
		AND EPD.COD_PRODUTO = CP.COD_PRODUTO
	INNER JOIN BI.dbo.BI_VENDA_PRODUTO VP
		ON 1=1
		AND VP.COD_PRODUTO = EPD.COD_PRODUTO
		AND VP.COD_LOJA = EPD.COD_LOJA
		AND VP.DATA = EPD.DATA
WHERE 1=1 
	AND CONVERT(DATE,EPD.DATA) BETWEEN CONVERT(DATE,GETDATE()-120) AND CONVERT(DATE,GETDATE())
	AND CP.PNP = 'NP'
	--and EPD.COD_PRODUTO = 998484
	--AND VP.COD_LOJA IN (1,13,18)
ORDER BY
	CONVERT(DATE,EPD.DATA)
*/