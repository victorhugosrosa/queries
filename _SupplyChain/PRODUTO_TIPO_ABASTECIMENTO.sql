SELECT
	AFP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,AFP.COD_FORNECEDOR	
	,CF1.DESCRICAO AS NO_FORNECEDOR	
	,AFP.FORNECEDOR_COMPRAS AS COD_FORNECEDOR_PED_AUTO
	,CF2.DESCRICAO AS NO_FORNECEDOR_PED_AUTO
	,(CASE
		WHEN afp.ModelArmazenagem = 0 THEN 'Direto'
		WHEN afp.ModelArmazenagem = 1 THEN 'CrossDocking'
		WHEN afp.ModelArmazenagem = 2 THEN 'Armazenagem'
		WHEN afp.ModelArmazenagem = 3 THEN 'PickingUnitario'
	END) AS TIPO_ABASTECIMENTO
FROM
	AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL AS AFP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON AFP.COD_PRODUTO = CP.COD_PRODUTO
	LEFT JOIN BI.dbo.BI_CAD_FORNECEDOR AS CF1
		ON AFP.COD_Fornecedor = CF1.COD_FORNECEDOR
	LEFT JOIN BI.dbo.BI_CAD_FORNECEDOR AS CF2
		ON AFP.FORNECEDOR_COMPRAS = CF2.COD_FORNECEDOR
WHERE 1=1
	AND AFP.COD_LOJA = 5