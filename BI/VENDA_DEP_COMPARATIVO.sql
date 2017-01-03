DECLARE @COD_LOJA AS INT = 1
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- MAIN TABLE
-- -------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_VENDA_SECAO AS TABLE
(
	COD_LOJA INT
	,PNP VARCHAR(5)
	,COD_DEPARTAMENTO INT
	,NO_DEPARTAMENTO VARCHAR(50)
	,COD_SECAO INT 
	,NO_SECAO VARCHAR(50)
	,VENDA_P1_A NUMERIC(18,2)
	,VENDA_P1_B NUMERIC(18,2)
	,DELTA_VENDA_ANO NUMERIC(18,2)
	,VENDA_P2_A NUMERIC(18,2)
	,VENDA_P2_B NUMERIC(18,2)
	,DELTA_VENDA_PERIODO NUMERIC(18,2)
);

INSERT INTO @TAB_VENDA_SECAO
(
	COD_LOJA
	,COD_DEPARTAMENTO
	,NO_DEPARTAMENTO
	,COD_SECAO 
	,NO_SECAO
)
SELECT DISTINCT
	VP.COD_LOJA
	,VP.COD_DEPARTAMENTO
	,H.NO_DEPARTAMENTO
	,VP.COD_SECAO 
	,H.NO_SECAO	
FROM
	[BI].[dbo].[BI_VENDA_GRUPO] AS VP
		INNER JOIN [BI].[dbo].[VW_BI_CAD_HIERARQUIA_PRODUTO] AS H
		ON 1 = 1
		AND VP.COD_DEPARTAMENTO = H.COD_DEPARTAMENTO
		AND VP.COD_SECAO = H.COD_SECAO
		AND VP.COD_GRUPO = H.COD_GRUPO
WHERE 1 = 1
	AND VP.COD_LOJA = @COD_LOJA
ORDER BY
	VP.COD_LOJA
	,H.NO_DEPARTAMENTO
	,H.NO_SECAO

UPDATE VS
SET
	VS.PNP = TEMP.PNP
FROM
	@TAB_VENDA_SECAO AS VS
	INNER JOIN
	(SELECT DISTINCT COD_DEPARTAMENTO, PNP FROM BI_CAD_PRODUTO) AS TEMP
	ON VS.COD_DEPARTAMENTO = TEMP.COD_DEPARTAMENTO

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @DATA_P1_INI_A AS DATE = '20130128'
	DECLARE @DATA_P1_FIM_A AS DATE = '20130602'

	DECLARE @DATA_P1_INI_B AS DATE = '20140127'
	DECLARE @DATA_P1_FIM_B AS DATE = '20140601'

	DECLARE @DATA_P2_INI_A AS DATE = '20130729'
	DECLARE @DATA_P2_FIM_A AS DATE = '20130901'

	DECLARE @DATA_P2_INI_B AS DATE = '20140728'
	DECLARE @DATA_P2_FIM_B AS DATE = '20140831'
	
	DECLARE @NUM_SEM_P1 AS INT = 18
	DECLARE @NUM_SEM_P2 AS INT = 5

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_P1_A
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_VENDA_P1_A AS TABLE
	(
		COD_LOJA INT
		,COD_DEPARTAMENTO INT
		,COD_SECAO INT 
		,VENDA_P1_A NUMERIC(18,2)
	)

	INSERT INTO @TAB_VENDA_P1_A
	SELECT
		COD_LOJA
		,COD_DEPARTAMENTO
		,COD_SECAO
		,SUM(VALOR_TOTAL)/@NUM_SEM_P1 AS VENDA_P1_A
	FROM
		[BI].[dbo].[BI_CAD_PRODUTO] AS CP
			INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
			ON CP.COD_PRODUTO = VP.COD_PRODUTO
	WHERE 1 = 1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI_A) AND CONVERT(DATE,@DATA_P1_FIM_A)
		AND VP.COD_LOJA = @COD_LOJA
	GROUP BY
		COD_LOJA
		,COD_DEPARTAMENTO
		,COD_SECAO

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_P1_B
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_VENDA_P1_B AS TABLE
	(
		COD_LOJA INT
		,COD_DEPARTAMENTO INT
		,COD_SECAO INT 
		,VENDA_P1_B NUMERIC(18,2)
	)

	INSERT INTO @TAB_VENDA_P1_B
	SELECT
		COD_LOJA
		,COD_DEPARTAMENTO
		,COD_SECAO
		,SUM(VALOR_TOTAL)/@NUM_SEM_P1 AS VENDA_P1_B
	FROM
		[BI].[dbo].[BI_CAD_PRODUTO] AS CP
			INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
			ON CP.COD_PRODUTO = VP.COD_PRODUTO
	WHERE 1 = 1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI_B) AND CONVERT(DATE,@DATA_P1_FIM_B)
		AND VP.COD_LOJA = @COD_LOJA
	GROUP BY
		COD_LOJA
		,COD_DEPARTAMENTO
		,COD_SECAO

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_P2_A
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_VENDA_P2_A AS TABLE
	(
		COD_LOJA INT
		,COD_DEPARTAMENTO INT
		,COD_SECAO INT 
		,VENDA_P2_A NUMERIC(18,2)
	)

	INSERT INTO @TAB_VENDA_P2_A
	SELECT
		COD_LOJA
		,COD_DEPARTAMENTO
		,COD_SECAO
		,SUM(VALOR_TOTAL)/@NUM_SEM_P2 AS VENDA_P2_A
	FROM
		[BI].[dbo].[BI_CAD_PRODUTO] AS CP
			INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
			ON CP.COD_PRODUTO = VP.COD_PRODUTO
	WHERE 1 = 1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI_A) AND CONVERT(DATE,@DATA_P2_FIM_A)
		AND VP.COD_LOJA = @COD_LOJA
	GROUP BY
		COD_LOJA
		,COD_DEPARTAMENTO
		,COD_SECAO

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_P2_B
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_VENDA_P2_B AS TABLE
	(
		COD_LOJA INT
		,COD_DEPARTAMENTO INT
		,COD_SECAO INT 
		,VENDA_P2_B NUMERIC(18,2)
	)

	INSERT INTO @TAB_VENDA_P2_B
	SELECT
		COD_LOJA
		,COD_DEPARTAMENTO
		,COD_SECAO
		,SUM(VALOR_TOTAL)/@NUM_SEM_P2 AS VENDA_P2_B
	FROM
		[BI].[dbo].[BI_CAD_PRODUTO] AS CP
			INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
			ON CP.COD_PRODUTO = VP.COD_PRODUTO
	WHERE 1 = 1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI_B) AND CONVERT(DATE,@DATA_P2_FIM_B)
		AND VP.COD_LOJA = @COD_LOJA
	GROUP BY
		COD_LOJA
		,COD_DEPARTAMENTO
		,COD_SECAO
		
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATES
-- -------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VENDA_P1_A = T.VENDA_P1_A
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P1_A AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_DEPARTAMENTO = T.COD_DEPARTAMENTO
			AND MAIN.COD_SECAO = T.COD_SECAO
	
	UPDATE MAIN
	SET
		MAIN.VENDA_P1_B = T.VENDA_P1_B
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P1_B AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_DEPARTAMENTO = T.COD_DEPARTAMENTO
			AND MAIN.COD_SECAO = T.COD_SECAO
	
	UPDATE MAIN
	SET
		MAIN.VENDA_P2_A = T.VENDA_P2_A
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P2_A AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_DEPARTAMENTO = T.COD_DEPARTAMENTO
			AND MAIN.COD_SECAO = T.COD_SECAO
	
	UPDATE MAIN
	SET
		MAIN.VENDA_P2_B = T.VENDA_P2_B
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P2_B AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_DEPARTAMENTO = T.COD_DEPARTAMENTO
			AND MAIN.COD_SECAO = T.COD_SECAO

	UPDATE MAIN
	SET
		MAIN.DELTA_VENDA_ANO = (MAIN.VENDA_P1_B / MAIN.VENDA_P1_A) -1
		,MAIN.DELTA_VENDA_PERIODO = (MAIN.VENDA_P2_B / MAIN.VENDA_P2_A) -1
	FROM
		@TAB_VENDA_SECAO AS MAIN
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- SELECT
-- -------------------------------------------------------------------------------------------------------------------------------------------		
	SELECT
		COD_LOJA
		,PNP
		,NO_DEPARTAMENTO
		,NO_SECAO 
		,BI.dbo.fn_FormataVlr_Excel(VENDA_P1_A) AS VENDA_P1_A
		,BI.dbo.fn_FormataVlr_Excel(VENDA_P1_B) AS VENDA_P1_B
		,BI.dbo.fn_FormataVlr_Excel(DELTA_VENDA_ANO) AS DELTA_VENDA_ANO
		,BI.dbo.fn_FormataVlr_Excel(VENDA_P2_A) AS VENDA_P2_A
		,BI.dbo.fn_FormataVlr_Excel(VENDA_P2_B) AS VENDA_P2_B
		,BI.dbo.fn_FormataVlr_Excel(DELTA_VENDA_PERIODO) AS DELTA_VENDA_PERIODO
	FROM @TAB_VENDA_SECAO
	WHERE 1 = 1
		AND COD_LOJA = @COD_LOJA
	ORDER BY
		COD_LOJA
		,NO_DEPARTAMENTO
		,NO_SECAO
/*
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- TEST AREA
-- -------------------------------------------------------------------------------------------------------------------------------------------	
	DECLARE @DATA_P1_INI_A AS DATE = '20130128'
	DECLARE @DATA_P1_FIM_A AS DATE = '20130602'
	DECLARE @NUM_SEM_P1 AS INT = 18
	
	SELECT
		--COD_LOJA
		--,COD_DEPARTAMENTO
		--,COD_SECAO
		SUM(VALOR_TOTAL)/@NUM_SEM_P1 AS VENDA_P1_A
	FROM
		[BI].[dbo].[BI_CAD_PRODUTO] AS CP
			INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
			ON CP.COD_PRODUTO = VP.COD_PRODUTO
	WHERE 1 = 1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI_A) AND CONVERT(DATE,@DATA_P1_FIM_A)
		AND COD_LOJA = 1
		--AND COD_DEPARTAMENTO = 5
		--AND COD_SECAO = 38
		--AND LEFT(dbo.ISO_WEEK(DATA),4) = 2014
		--AND BI.DBO.F_ISO_WEEK_OF_YEAR(DATA) = 20
	GROUP BY
		COD_LOJA
		,COD_DEPARTAMENTO
		,COD_SECAO
*/

/*
SELECT DISTINCT
	LP.COD_LOJA
	,LP.COD_DEPARTAMENTO
	,CP.NO_DEPARTAMENTO
	,LP.COD_SECAO 
	,CP.NO_SECAO
FROM
	[BI].[dbo].[BI_LINHA_PRODUTOS] AS LP
		INNER JOIN [BI].[dbo].[BI_CAD_PRODUTO] AS CP
		ON LP.COD_PRODUTO = CP.COD_PRODUTO
ORDER BY
	LP.COD_LOJA
	,CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
*/