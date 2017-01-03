-- -------------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @DATA_P1_INI_A AS DATE = '20121231'
	DECLARE @DATA_P1_FIM_A AS DATE = '20130929'

	DECLARE @DATA_P1_INI_B AS DATE = '20121230'
	DECLARE @DATA_P1_FIM_B AS DATE = '20140928'
	
	DECLARE @COD_SECAO AS INT = 60
	DECLARE @COD_GRUPO AS INT = 11

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- MAIN TABLE
-- -------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_VENDA_SECAO AS TABLE
(
	COD_LOJA INT
	,COD_DEPARTAMENTO INT
	,NO_DEPARTAMENTO VARCHAR(50)
	,COD_SECAO INT 
	,NO_SECAO VARCHAR(50)
	,COD_GRUPO INT
	,NO_GRUPO VARCHAR(50)
	,COD_PRODUTO INT
	,NO_PRODUTO VARCHAR(50)
	,ABC VARCHAR(5)
	,VENDA_P1_A NUMERIC(18,2)
	,VENDA_P1_B NUMERIC(18,2)
	,QTD_P1_A NUMERIC(18,2)
	,QTD_P1_B NUMERIC(18,2)
	,DELTA_VENDA_ANO NUMERIC(18,2)
);

INSERT INTO @TAB_VENDA_SECAO
(
	COD_LOJA
	,COD_DEPARTAMENTO
	,NO_DEPARTAMENTO
	,COD_SECAO 
	,NO_SECAO
	,COD_GRUPO
	,NO_GRUPO
	,COD_PRODUTO
	,NO_PRODUTO
	,ABC
)
SELECT DISTINCT
	VP.COD_LOJA
	,CP.COD_DEPARTAMENTO
	,CP.NO_DEPARTAMENTO
	,CP.COD_SECAO 
	,CP.NO_SECAO
	,CP.COD_GRUPO 
	,CP.NO_GRUPO
	,VP.COD_PRODUTO
	,CP.DESCRICAO	
	,CP.CLASSIF_PRODUTO
FROM
	[BI].[dbo].[BI_VENDA_PRODUTO] AS VP
		INNER JOIN [BI].[dbo].[BI_CAD_PRODUTO] AS CP
		ON 1 = 1
		AND VP.COD_PRODUTO = CP.COD_PRODUTO
WHERE 1 = 1
	AND CP.COD_SECAO = @COD_SECAO
	AND CP.COD_GRUPO = @COD_GRUPO

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_P1_A
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_VENDA_P1_A AS TABLE
	(
		COD_LOJA INT
		,COD_PRODUTO INT 
		,VENDA_P1_A NUMERIC(18,2)
		,QTD_P1_A NUMERIC(18,2)
	)

	INSERT INTO @TAB_VENDA_P1_A
	SELECT
		COD_LOJA
		,VP.COD_PRODUTO
		,SUM(VALOR_TOTAL) AS VENDA_P1_A
		,SUM(QTDE_PRODUTO) AS QTD_P1_A
		
	FROM
		[BI].[dbo].[BI_CAD_PRODUTO] AS CP
			INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
			ON CP.COD_PRODUTO = VP.COD_PRODUTO
	WHERE 1 = 1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI_A) AND CONVERT(DATE,@DATA_P1_FIM_A)
		AND CP.COD_SECAO = @COD_SECAO
		AND CP.COD_GRUPO = @COD_GRUPO
	GROUP BY
		COD_LOJA
		,VP.COD_PRODUTO

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_P1_B
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_VENDA_P1_B AS TABLE
	(
		COD_LOJA INT
		,COD_PRODUTO INT 
		,VENDA_P1_B NUMERIC(18,2)
		,QTD_P1_B NUMERIC(18,2)
		
	)

	INSERT INTO @TAB_VENDA_P1_B
	SELECT
		COD_LOJA
		,VP.COD_PRODUTO
		,SUM(VALOR_TOTAL) AS VENDA_P1_B
		,SUM(QTDE_PRODUTO) AS QTD_P1_B
	FROM
		[BI].[dbo].[BI_CAD_PRODUTO] AS CP
			INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
			ON CP.COD_PRODUTO = VP.COD_PRODUTO
	WHERE 1 = 1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI_B) AND CONVERT(DATE,@DATA_P1_FIM_B)
		AND CP.COD_SECAO = @COD_SECAO
		AND CP.COD_GRUPO = @COD_GRUPO
	GROUP BY
		COD_LOJA
		,VP.COD_PRODUTO


-- -------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATES
-- -------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE MAIN
	SET
		 MAIN.VENDA_P1_A = T.VENDA_P1_A
		,MAIN.QTD_P1_A = T.QTD_P1_A
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P1_A AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
	
	UPDATE MAIN
	SET
		 MAIN.VENDA_P1_B = T.VENDA_P1_B
		,MAIN.QTD_P1_B = T.QTD_P1_B
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P1_B AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO	

	UPDATE MAIN
	SET
		MAIN.DELTA_VENDA_ANO = (MAIN.VENDA_P1_B / MAIN.VENDA_P1_A) -1
	FROM
		@TAB_VENDA_SECAO AS MAIN
		
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- SELECT
-- -------------------------------------------------------------------------------------------------------------------------------------------		
	SELECT
		COD_LOJA
		,NO_DEPARTAMENTO
		,NO_SECAO
		,NO_GRUPO
		,COD_PRODUTO
		,NO_PRODUTO
		,ABC
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VENDA_P1_A,0)) AS VENDA_P1_A
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VENDA_P1_B,0)) AS VENDA_P1_B

		,BI.dbo.fn_FormataVlr_Excel(ISNULL(QTD_P1_A,0)) AS QTD_P1_A
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(QTD_P1_B,0)) AS QTD_P1_B

		--,BI.dbo.fn_FormataVlr_Excel(DELTA_VENDA_ANO) AS DELTA_VENDA_ANO
	FROM @TAB_VENDA_SECAO
	ORDER BY
		COD_LOJA
		,NO_DEPARTAMENTO
		,NO_SECAO
		,NO_GRUPO
		,COD_PRODUTO

