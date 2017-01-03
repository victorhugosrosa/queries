-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @COD_INV AS INT
	DECLARE @DT_INI AS DATE
	DECLARE @DT_FIM AS DATE
	DECLARE @COD_LOJA AS INT
	DECLARE @COD_PRODUTO AS INT	
	
	-- ------------------------------------------------
		SET @COD_INV = 471
		SET @DT_FIM = '20140205'
		SET @COD_LOJA = 6
		SET @COD_PRODUTO = 68680	
	-- ------------------------------------------------

	SELECT @DT_INI = CONVERT(VARCHAR,DTA_INVENTARIO,112) FROM ZEUS_RTG.DBO.TAB_INVENTARIO WHERE COD_INVENTARIO = @COD_INV

	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ------------------------------------------------
	-- SALDO INICIAL
	-- ------------------------------------------------
	SELECT
		@COD_LOJA AS COD_LOJA
		,CONVERT(DATE,@DT_INI) AS DATA
		,II.COD_PRODUTO
		,P.DES_PRODUTO
		,'SI' AS TIPO_OPERACAO
		,'SALDO INICIAL' AS DESCRICAO
		,'' AS DES_DOCTO
		,QTD_INVENTARIO AS QUANTIDADE
		,'N/A' AS DANFE
	FROM
		ZEUS_RTG.DBO.TAB_PRODUTO AS P LEFT JOIN ZEUS_RTG.DBO.TAB_INVENTARIO_ITEM AS II ON (II.COD_PRODUTO = P.COD_PRODUTO)
	WHERE 1 = 1
		AND II.COD_INVENTARIO = @COD_INV
		AND II.COD_PRODUTO = @COD_PRODUTO 

	UNION ALL

	-- ------------------------------------------------
	-- NOTAS
	-- ------------------------------------------------
	SELECT
		FN.COD_LOJA AS [LOJA]
		,CONVERT(DATE,FN.DTA_ENTRADA)
		,FP.COD_PRODUTO
		,P.DES_PRODUTO
		,(CASE WHEN DES_ESPECIE = 'NFD' THEN '1' ELSE '0' END) AS TIPO_OPERACAO
		, 'NF. FORN.: ' + F.DES_FANTASIA AS DESCRICAO
		, FN.NUM_NF_FORN AS DES_DOCTO
		,(CASE WHEN DES_ESPECIE = 'NFD' THEN FP.QTD_ENTRADA*-1 ELSE FP.QTD_ENTRADA END) AS QTD_ENTRADA
		,ISNULL(FN.NUM_DANFE,'N/A') AS NUM_DANFE
	FROM
		ZEUS_RTG.DBO.TAB_FORNECEDOR_NOTA AS FN LEFT JOIN ZEUS_RTG.DBO.TAB_FORNECEDOR_PRODUTO AS FP
			ON (FN.COD_FORNECEDOR = FP.COD_FORNECEDOR AND FN.NUM_NF_FORN = FP.NUM_NF_FORN AND FN.NUM_SERIE_NF = FP.NUM_SERIE_NF AND FN.COD_LOJA = FP.COD_LOJA)
			LEFT JOIN ZEUS_RTG.DBO.TAB_PRODUTO AS P ON (FP.COD_PRODUTO = P.COD_PRODUTO)
			LEFT JOIN ZEUS_RTG.DBO.TAB_FORNECEDOR AS F ON (FN.COD_FORNECEDOR = F.COD_FORNECEDOR)
	WHERE 1 = 1
		AND FN.COD_LOJA = @COD_LOJA
		AND FP.COD_PRODUTO = @COD_PRODUTO
		AND CONVERT(DATE,FN.DTA_ENTRADA) BETWEEN CONVERT(DATE,@DT_INI) AND CONVERT(DATE,@DT_FIM)

	UNION ALL

	-- ------------------------------------------------
	-- QUEBRA
	-- ------------------------------------------------
	SELECT
		AE.COD_LOJA AS [LOJA]
		,CONVERT(DATE,AE.DTA_AJUSTE)
		,AE.COD_PRODUTO
		,P.DES_PRODUTO
		,CONVERT(VARCHAR(2),TA.TIPO_OPERACAO) AS TIPO_OPERACAO
		,TA.DES_AJUSTE AS DESCRICAO
		,'' AS DES_DOCTO
		,AE.QTD_AJUSTE AS QTD_ENTRADA
		,'N/A' AS NUM_DANFE
	FROM
		ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS AE 
			LEFT JOIN ZEUS_RTG.DBO.TAB_TIPO_AJUSTE AS TA ON (AE.COD_AJUSTE = TA.COD_AJUSTE)
			LEFT JOIN ZEUS_RTG.DBO.TAB_PRODUTO AS P ON (AE.COD_PRODUTO = P.COD_PRODUTO)
	WHERE 1 = 1
		AND AE.COD_LOJA = @COD_LOJA
		AND AE.COD_PRODUTO = @COD_PRODUTO
		AND CONVERT(DATE,AE.DTA_AJUSTE) BETWEEN CONVERT(DATE,@DT_INI) AND CONVERT(DATE,@DT_FIM)

	UNION ALL 

	-- ------------------------------------------------
	-- VENDAS
	-- ------------------------------------------------
	SELECT 
		@COD_LOJA , 
		CONVERT(DATE,DTA_SAIDA),
		1*PS.COD_PRODUTO,
		P.DES_PRODUTO,
		'1',
		'VENDA',
		'',
		SUM(QTD_TOTAL_PRODUTO*-1)
		,'N/A' AS DANFE
	FROM
		ZEUS_RTG.DBO.TAB_PRODUTO_SAIDA AS PS INNER JOIN ZEUS_RTG.DBO.TAB_PRODUTO AS P ON 
		PS.COD_PRODUTO = P.COD_PRODUTO	
	WHERE 1=1
	  AND PS.COD_PRODUTO = @COD_PRODUTO
	  AND PS.QTD_TOTAL_PRODUTO > 0
	  AND COD_LOJA = @COD_LOJA
	  AND CONVERT(DATE,DTA_SAIDA) BETWEEN CONVERT(DATE,@DT_INI) AND CONVERT(DATE,@DT_FIM)
	GROUP BY
		DTA_SAIDA,
		PS.COD_PRODUTO,
		P.DES_PRODUTO,
		COD_LOJA,
		QTD_TOTAL_PRODUTO
	
	ORDER BY 
		COD_PRODUTO,DATA, TIPO_OPERACAO	DESC
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------