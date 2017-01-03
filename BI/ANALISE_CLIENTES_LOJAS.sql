-- -------------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @DATA_P1_INI AS DATE = '20120102'
	DECLARE @DATA_P1_FIM AS DATE = '20121230'

	DECLARE @DATA_P2_INI AS DATE = '20121231'
	DECLARE @DATA_P2_FIM AS DATE = '20131229'

	DECLARE @DATA_P3_INI AS DATE = '20131230'
	DECLARE @DATA_P3_FIM AS DATE = '20141228'
	
	DECLARE @SEM_MAX AS INT = 27

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- MAIN TABLE
-- -------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_VENDA_SECAO AS TABLE
(
	COD_LOJA INT
	,SEMANA INT
	,VENDA_P1 NUMERIC(18,2)
	,QTD_P1 NUMERIC(18,2)
	,VENDA_P2 NUMERIC(18,2)
	,QTD_P2 NUMERIC(18,2)
	,VENDA_P3 NUMERIC(18,2)
	,QTD_P3 NUMERIC(18,2)
);

INSERT INTO @TAB_VENDA_SECAO
(
	COD_LOJA
	,SEMANA
)
SELECT DISTINCT
	VP.COD_LOJA
	,BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA) as NR_SEMANA
FROM
	[BI].[dbo].[BI_VENDA_CUPOM] AS VP
WHERE 1 = 1
	AND BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA) <= @SEM_MAX
ORDER BY
	VP.COD_LOJA
	
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_P1
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_VENDA_P1 AS TABLE
	(
		COD_LOJA INT
		,ANO INT
		,SEMANA INT
		,VENDA_P1 NUMERIC(18,2)
		,QTD_P1 NUMERIC(18,2)
	)

	INSERT INTO @TAB_VENDA_P1
	SELECT
		COD_LOJA
		,LEFT(dbo.ISO_WEEK(VP.DATA),4) as ANO
		,BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA) as NR_SEMANA
		,SUM(VALOR_TOTAL)
		,SUM(QTDE_CUPOM)
	FROM
		[BI].[dbo].[BI_VENDA_CUPOM] AS VP
	WHERE 1 = 1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI) AND CONVERT(DATE,@DATA_P1_FIM)
		AND BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA) <= @SEM_MAX
	GROUP BY
		COD_LOJA
		,LEFT(dbo.ISO_WEEK(VP.DATA),4)
		,BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA)

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_P1
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_VENDA_P2 AS TABLE
	(
		COD_LOJA INT
		,ANO INT
		,SEMANA INT
		,VENDA_P2 NUMERIC(18,2)
		,QTD_P2 NUMERIC(18,2)
	)

	INSERT INTO @TAB_VENDA_P2
	SELECT
		COD_LOJA
		,LEFT(dbo.ISO_WEEK(VP.DATA),4) as ANO
		,BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA) as NR_SEMANA
		,SUM(VALOR_TOTAL)
		,SUM(QTDE_CUPOM)
	FROM
		[BI].[dbo].[BI_VENDA_CUPOM] AS VP
	WHERE 1 = 1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI) AND CONVERT(DATE,@DATA_P2_FIM)
		AND BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA) <= @SEM_MAX
	GROUP BY
		COD_LOJA
		,LEFT(dbo.ISO_WEEK(VP.DATA),4)
		,BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA)

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_P3
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_VENDA_P3 AS TABLE
	(
		COD_LOJA INT
		,ANO INT
		,SEMANA INT
		,VENDA_P3 NUMERIC(18,2)
		,QTD_P3 NUMERIC(18,2)
	)

	INSERT INTO @TAB_VENDA_P3
	SELECT
		COD_LOJA
		,LEFT(dbo.ISO_WEEK(VP.DATA),4) as ANO
		,BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA) as NR_SEMANA
		,SUM(VALOR_TOTAL)
		,SUM(QTDE_CUPOM)
	FROM
		[BI].[dbo].[BI_VENDA_CUPOM] AS VP
	WHERE 1 = 1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P3_INI) AND CONVERT(DATE,@DATA_P3_FIM)
		AND BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA) <= @SEM_MAX
	GROUP BY
		COD_LOJA
		,LEFT(dbo.ISO_WEEK(VP.DATA),4)
		,BI.DBO.F_ISO_WEEK_OF_YEAR(VP.DATA)

		
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATES
-- -------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VENDA_P1 = T.VENDA_P1
		,MAIN.QTD_P1 = T.QTD_P1
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P1 AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.SEMANA = T.SEMANA
	
	UPDATE MAIN
	SET
		MAIN.VENDA_P2 = T.VENDA_P2
		,MAIN.QTD_P2 = T.QTD_P2
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P2 AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.SEMANA = T.SEMANA
	
	UPDATE MAIN
	SET
		MAIN.VENDA_P3 = T.VENDA_P3
		,MAIN.QTD_P3 = T.QTD_P3
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P3 AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.SEMANA = T.SEMANA

/*
	UPDATE MAIN
	SET
		MAIN.DELTA_VENDA_ANO = (MAIN.VENDA_P1_B / MAIN.VENDA_P1_A) -1
		,MAIN.DELTA_VENDA_PERIODO = (MAIN.VENDA_P2_B / MAIN.VENDA_P2_A) -1
	FROM
		@TAB_VENDA_SECAO AS MAIN
*/
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- SELECT
-- -------------------------------------------------------------------------------------------------------------------------------------------		
	SELECT
		COD_LOJA
		,SEMANA
		,BI.dbo.fn_FormataVlr_Excel(VENDA_P1) AS VENDA_2012
		,BI.dbo.fn_FormataVlr_Excel(QTD_P1) AS QTD_2012
		,BI.dbo.fn_FormataVlr_Excel(VENDA_P2) AS VENDA_2013
		,BI.dbo.fn_FormataVlr_Excel(QTD_P2) AS QTD_2013
		,BI.dbo.fn_FormataVlr_Excel(VENDA_P3) AS VENDA_2014
		,BI.dbo.fn_FormataVlr_Excel(QTD_P3) AS QTD_2014
	FROM @TAB_VENDA_SECAO
	ORDER BY
		COD_LOJA
		,SEMANA

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
SELECT DISTINCTç
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