-- ------------------------------------------------------------------------------------------
-- META POR CESTA
-- ------------------------------------------------------------------------------------------
	SELECT
		(CASE WHEN E.META IS NULL THEN 9999999 ELSE SKU.CODIGO_ERP END) AS ID
		,(CASE
			WHEN SKU.DESCRICAO LIKE '%PERSONALIZADA%' THEN 'CESTA PERSONALIZADA'
			ELSE SKU.DESCRICAO
		END) AS NO_PRODUTO
		,SUM(PP.QUANTIDADE * PLU.PRECO_UNITARIO) AS VLR_VENDA
		,(E.META * PLU.PRECO_UNITARIO) AS VLR_META
		,SUM(PP.QUANTIDADE) AS QTD_VENDA
		,(E.META) AS QTD_META
	FROM
		[DBCestanatal].[dbo].[SMCB_PEDIDO] AS P
		INNER JOIN [DBCestanatal].[dbo].[SMCB_PEDIDO_ITEM] AS PP
			ON 1=1
			AND P.IDPEDIDO = PP.IDPEDIDO
		INNER JOIN [DBCestanatal].[dbo].[SMCB_PRODUTO_SKU] AS SKU
			ON 1=1
			AND PP.IDPRODUTO_SKU = SKU.IDPRODUTO_SKU
		LEFT JOIN [dbCestaNatal].[dbo].[SMCB_PRODUTO_PLU] AS PLU
			ON 1=1
			AND SKU.IDPRODUTO_PLU = PLU.IDPRODUTO_PLU
		LEFT JOIN [DBCestanatal].[dbo].[SMCB_PRODUTO_ESTOQUE] AS E
			ON 1=1
			AND PP.IDPRODUTO_SKU = E.IDPRODUTO_SKU	
	WHERE 1=1
		AND CONVERT(DATE,P.DATA_CRIACAO) >= '20141101'
		--AND P.[STATUS] IN (8,9,12)
	GROUP BY
		(CASE WHEN E.META IS NULL THEN 9999999 ELSE SKU.CODIGO_ERP END)
		,(CASE
			WHEN SKU.DESCRICAO LIKE '%PERSONALIZADA%' THEN 'CESTA PERSONALIZADA'
			ELSE SKU.DESCRICAO
		END)
		,(E.META * PLU.PRECO_UNITARIO)
		,E.META
	ORDER BY
		ID
		
-- ------------------------------------------------------------------------------------------
-- META GERAL
-- ------------------------------------------------------------------------------------------
	SELECT
		SUM(PRODUTO_EST.[META]*PRODUTO_PLU.PRECO_UNITARIO)  AS META_VLR
	FROM
		[dbCestaNatal].[dbo].[SMCB_PRODUTO_ESTOQUE] as PRODUTO_EST
		INNER JOIN [dbCestaNatal].[dbo].[SMCB_PRODUTO_SKU] AS PRODUTO_SKU
			ON 1=1
			AND PRODUTO_EST.IDPRODUTO_SKU = PRODUTO_SKU.IDPRODUTO_SKU		
		LEFT JOIN [dbCestaNatal].[dbo].[SMCB_PRODUTO_PLU] AS PRODUTO_PLU
			ON 1=1
			AND PRODUTO_SKU.IDPRODUTO_PLU = PRODUTO_PLU.IDPRODUTO_PLU
	WHERE 1=1
		AND CONVERT(DATE,PRODUTO_EST.DATA_CRIACAO) >= '20141001'


-- ------------------------------------------------------------------------------------------
-- VENDA POR OPERADOR
-- ------------------------------------------------------------------------------------------
	SELECT
		U.NOME
		,SUM(P.TOTAL) VLR_VENDA
		,SUM(P.VALOR_DESCONTO) VLR_DESCONTO
	FROM
		[DBCestanatal].[dbo].[SMCB_PEDIDO] AS P
		INNER JOIN [DBCestanatal].[dbo].[SMCB_USUARIO] AS U
			ON 1=1
			AND P.IDUSUARIO = U.IDUSUARIO
	WHERE 1=1
		AND CONVERT(DATE,P.DATA_CRIACAO) >= '20141101'
		--AND P.[STATUS] IN (8,9,12)
	GROUP BY
		U.NOME

-- ------------------------------------------------------------------------------------------
-- META GERAL
-- ------------------------------------------------------------------------------------------
	SELECT
		(CASE WHEN E.META IS NULL THEN 9999999 ELSE SKU.CODIGO_ERP END) AS ID
		,(CASE
			WHEN SKU.DESCRICAO LIKE '%PERSONALIZADA%' THEN 'CESTA PERSONALIZADA'
			ELSE SKU.DESCRICAO
		END) AS NO_PRODUTO
		,SUM(E.QTD_PRODUZIDA) - SUM(PP.QUANTIDADE) AS QTD_ESTOQUE
	FROM
		[DBCestanatal].[dbo].[SMCB_PEDIDO] AS P
		INNER JOIN [DBCestanatal].[dbo].[SMCB_PEDIDO_ITEM] AS PP
			ON 1=1
			AND P.IDPEDIDO = PP.IDPEDIDO
		INNER JOIN [DBCestanatal].[dbo].[SMCB_PRODUTO_SKU] AS SKU
			ON 1=1
			AND PP.IDPRODUTO_SKU = SKU.IDPRODUTO_SKU
		LEFT JOIN [dbCestaNatal].[dbo].[SMCB_PRODUTO_PLU] AS PLU
			ON 1=1
			AND SKU.IDPRODUTO_PLU = PLU.IDPRODUTO_PLU
		LEFT JOIN [DBCestanatal].[dbo].[SMCB_PRODUTO_ESTOQUE] AS E
			ON 1=1
			AND PP.IDPRODUTO_SKU = E.IDPRODUTO_SKU	
	WHERE 1=1
		AND CONVERT(DATE,P.DATA_CRIACAO) >= '20141101'
		--AND P.[STATUS] IN (8,9,12)
	GROUP BY
		(CASE WHEN E.META IS NULL THEN 9999999 ELSE SKU.CODIGO_ERP END)
		,(CASE
			WHEN SKU.DESCRICAO LIKE '%PERSONALIZADA%' THEN 'CESTA PERSONALIZADA'
			ELSE SKU.DESCRICAO
		END)
	ORDER BY
		ID
		