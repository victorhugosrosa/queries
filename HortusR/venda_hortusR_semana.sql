SELECT
	S.ANO_454
	,S.MES_454
	,S.NO_MES_454
	,S.SEMANA_454
	,S.DATA
	,CP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,CP.NO_DEPARTAMENTO
	,BI.dbo.fn_FormataVlr_Excel(SUM(VALOR_TOTAL)) AS VLR_TOTAL
	,BI.dbo.fn_FormataVlr_Excel(SUM(QTDE_PRODUTO)) AS QTD_TOTAL
FROM
	BI.dbo.BI_VENDA_PRODUTO AS VP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON VP.COD_PRODUTO = CP.COD_PRODUTO
	INNER JOIN BI.DBO.BI_CAD_SEMANA AS S
		ON VP.DATA = S.DATA
WHERE 1=1
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,'20130101') AND CONVERT(DATE,'20151130')
	AND VP.COD_LOJA = 8
GROUP BY
	S.ANO_454
	,S.MES_454
	,S.NO_MES_454
	,S.SEMANA_454
	,S.DATA
	,CP.COD_PRODUTO
	,CP.DESCRICAO
	,CP.NO_DEPARTAMENTO
ORDER BY
	S.ANO_454
	,S.MES_454
	,S.SEMANA_454
	,SUM(VALOR_TOTAL) DESC