select
	VP.COD_LOJA	
	,YEAR(VP.DATA) as ANO
	,MONTH(VP.DATA) as MES
	,CP.NO_DEPARTAMENTO	
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,CP.NO_SUBGRUPO
	,VP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,CB.COD_EAN
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.VALOR_TOTAL)) AS VLR_TOTAL
	,BI.dbo.fn_FormataVlr_Excel(SUM(VP.QTDE_PRODUTO)) AS QTD_TOTAL
from
	BI_CAD_PRODUTO AS CP
	INNER JOIN BI_VENDA_PRODUTO AS VP
		ON CP.COD_PRODUTO = VP.COD_PRODUTO
	LEFT JOIN AX2009_INTEGRACAO.dbo.TAB_CODIGO_BARRA_PRINCIPAL AS CB
		ON CP.COD_PRODUTO = CB.COD_PRODUTO
WHERE 1=1
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,'2014-01-01') AND CONVERT(DATE,'2014-12-31')
	AND CP.COD_PRODUTO IN
	(
		SELECT DISTINCT
			COD_PRODUTO
		FROM
			BI.DBO.BI_CAD_FORNECEDOR_PRODUTO
		WHERE 1=1
			AND COD_FORNECEDOR IN (101948,102778,14648,103375,103374,14640,13828,2567,2392)	
	)	
	AND COD_LOJA = 7	
GROUP BY
	VP.COD_LOJA	
	,YEAR(VP.DATA)
	,MONTH(VP.DATA)
	,CP.NO_DEPARTAMENTO	
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,CP.NO_SUBGRUPO
	,VP.COD_PRODUTO
	,CP.DESCRICAO
	,CB.COD_EAN
ORDER BY
	VP.COD_LOJA	
	,YEAR(VP.DATA)
	,MONTH(VP.DATA)
	,CP.NO_DEPARTAMENTO	
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,CP.NO_SUBGRUPO
	,CP.DESCRICAO
