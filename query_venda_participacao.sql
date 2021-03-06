SELECT
	CP.DESCRICAO AS NO_PRODUTO
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.VALOR_TOTAL)) AS VLR_TOTAL_PROD
FROM
	BI_VENDA_PRODUTO AS VP
	INNER JOIN BI_CAD_PRODUTO AS CP
			ON 1=1
			AND VP.COD_PRODUTO = CP.COD_PRODUTO
WHERE 1=1
	AND CP.CLASSIF_PRODUTO = 'A1'
	AND CONVERT(DATE,VP.DATA) >= '20140101'
GROUP BY
	CP.DESCRICAO
	
SELECT BI.dbo.fn_FormataVlr_Excel(SUM(TVP.VALOR_TOTAL)) FROM BI_VENDA_PRODUTO AS TVP WHERE CONVERT(DATE,TVP.DATA) >= '20140101'