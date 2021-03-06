-- -------------------------------------------------------------------------------------------------------------------------------------------------
-- ENTRADA NA ORBIS
-- -------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT --TOP 1000
		'''' + F.NUM_CGC AS CNPJ_SAIDA
		,'''' + L.NUM_CGC AS CNPJ_ENTRADA
		,E.[COD_FORNECEDOR]
		,E.[COD_LOJA]
		,[DTA_ENTRADA]	
		,[NUM_NF_FORN]
		,[COD_PRODUTO]
		,[DES_UNIDADE]
		,[QTD_ENTRADA]
		,[QTD_EMBALAGEM]
		,[VAL_TABELA_LIQ]
	FROM
		[Zeus_rtg].[dbo].[vw_MARCHE_ENTRADAS_GERAIS] AS E
		INNER JOIN [Zeus_rtg].[dbo].[TAB_FORNECEDOR] AS F
			ON 1=1
			AND E.COD_FORNECEDOR = F.COD_FORNECEDOR
		INNER JOIN [Zeus_rtg].[dbo].[TAB_LOJA] AS L
			ON 1=1
			AND E.COD_LOJA = L.COD_LOJA
	WHERE 1=1
		AND E.COD_LOJA IN (5,28)
		AND CONVERT(DATE,E.DTA_ENTRADA) >= '20130101'
	ORDER BY
		[DTA_ENTRADA]
		,E.[COD_FORNECEDOR]

-- -------------------------------------------------------------------------------------------------------------------------------------------------
-- SAIDA DA ORBIS
-- -------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT --TOP 1000
		'''' + F.NUM_CGC AS CNPJ_SAIDA
		,'''' + L.NUM_CGC AS CNPJ_ENTRADA
		,E.[COD_FORNECEDOR]
		,E.[COD_LOJA]
		,[DTA_ENTRADA]	
		,[NUM_NF_FORN]
		,[COD_PRODUTO]
		,[DES_UNIDADE]
		,[QTD_ENTRADA]
		,[QTD_EMBALAGEM]
		,[VAL_TABELA_LIQ]
	FROM
		[Zeus_rtg].[dbo].[vw_MARCHE_ENTRADAS_GERAIS] AS E
		INNER JOIN [Zeus_rtg].[dbo].[TAB_FORNECEDOR] AS F
			ON 1=1
			AND E.COD_FORNECEDOR = F.COD_FORNECEDOR
		INNER JOIN [Zeus_rtg].[dbo].[TAB_LOJA] AS L
			ON 1=1
			AND E.COD_LOJA = L.COD_LOJA
	WHERE 1=1
		AND E.COD_FORNECEDOR = 18055
		AND CONVERT(DATE,E.DTA_ENTRADA) >= '20130101'
	ORDER BY
		[DTA_ENTRADA]
		,E.[COD_FORNECEDOR]
