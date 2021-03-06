SELECT
	EP.COD_LOJA
	,EP.COD_PRODUTO
	,CP.DESCRICAO
	,CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,CP.CLASSIF_PRODUTO AS [ABC GERAL]
	,BI.dbo.fn_FormataVlr_Excel(EP.QTD_ESTOQUE) AS ESTOQUE
FROM
	BI.dbo.BI_ESTOQUE_PRODUTO AS EP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON 1=1
		AND EP.COD_PRODUTO = CP.COD_PRODUTO
	LEFT JOIN BI.DBO.BI_VENDA_PRODUTO AS VP
		ON 1=1
		AND EP.COD_LOJA = VP.COD_LOJA
		AND EP.COD_PRODUTO = VP.COD_PRODUTO
	
WHERE 1=1
	AND EP.COD_LOJA = 31
	AND EP.QTD_ESTOQUE > 0
	AND VP.DATA IS NULL
ORDER BY
	CP.CLASSIF_PRODUTO
	,CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,CP.DESCRICAO
	
	