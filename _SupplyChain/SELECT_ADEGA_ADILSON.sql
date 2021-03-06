SELECT
	LP.COD_LOJA
	--,L.NO_LOJA
	,CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
	--,CP.NO_GRUPO
	,LP.CLASSIF_PRODUTO_LOJA
	,CP.COD_FORNECEDOR
	,CF.DESCRICAO AS NO_FORNECEDOR
	,CP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,EP.QTD_ESTOQUE
	,LP.VLR_VENDA
	--CUSTO
	
	
FROM
	BI.dbo.BI_LINHA_PRODUTOS AS LP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON LP.COD_PRODUTO = CP.COD_PRODUTO
	--INNER JOIN BI.dbo.BI_CAD_LOJA2 AS L
		--ON LP.COD_LOJA = L.COD_LOJA
	LEFT JOIN BI.dbo.BI_CAD_FORNECEDOR AS CF
		ON CP.COD_FORNECEDOR = CF.COD_FORNECEDOR
	LEFT JOIN BI.dbo.BI_ESTOQUE_PRODUTO AS EP
		ON 1=1
		AND LP.COD_LOJA = EP.COD_LOJA
		AND LP.COD_PRODUTO = EP.COD_PRODUTO
WHERE 1=1
	