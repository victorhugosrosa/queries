SELECT
	R.NO_RESTAURANTE
	,CONVERT(DATE,VP.DATA) AS DATA
	,VP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,BI.dbo.fn_FormataVlr_Excel(SUM(VALOR_TOTAL)) AS VLR_TOTAL
	,BI.dbo.fn_FormataVlr_Excel(SUM(QTDE_PRODUTO)) AS QTD_TOTAL
FROM
	BI_VENDA_PRODUTO AS VP
	LEFT JOIN BI_CAD_RESTAURANTE AS R
		ON 1=1
		AND VP.COD_LOJA = R.COD_LOJA
		AND VP.TIPO_VENDA = R.COD_RESTAURANTE
	LEFT JOIN BI_CAD_PRODUTO AS CP
		ON VP.COD_PRODUTO = CP.COD_PRODUTO		
WHERE 1=1
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,'20150518') AND CONVERT(DATE,'20150520')
	AND VP.COD_LOJA = 33
GROUP BY
	R.NO_RESTAURANTE
	,CONVERT(DATE,VP.DATA)
	,VP.COD_PRODUTO
	,CP.DESCRICAO
ORDER BY 
	R.NO_RESTAURANTE
	,CONVERT(DATE,VP.DATA)
	,SUM(VALOR_TOTAL) DESC