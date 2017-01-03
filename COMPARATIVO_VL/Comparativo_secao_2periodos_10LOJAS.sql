DECLARE @COD_LOJA AS INT = 1
--(1,2,3,6,9,13,12,18,17,20),22,23
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
	,QTD_P1_A NUMERIC(18,2)
	,VENDA_P1_B NUMERIC(18,2)
	,QTD_P1_B NUMERIC(18,2)
	

	,VENDA_P2_A NUMERIC(18,2)
	,QTD_P2_A NUMERIC(18,2)
	,VENDA_P2_B NUMERIC(18,2)
	,QTD_P2_B NUMERIC(18,2)	
	
	--,VENDA_P3_A NUMERIC(18,2)
	--,QTD_P3_A NUMERIC(18,2)
	--,VENDA_P3_B NUMERIC(18,2)
	--,QTD_P3_B NUMERIC(18,2)
	
	,AVG_PNP NUMERIC(18,4)
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
	AND VP.COD_DEPARTAMENTO NOT IN (15,99,20,7,18)
	AND VP.COD_SECAO NOT IN (16,85,21,9) --NATAL/OUTROS/SUCOSePOUPAS
	AND COD_LOJA NOT IN (4,10,19)
	AND COD_LOJA = @COD_LOJA
ORDER BY
	VP.COD_LOJA
	,H.NO_DEPARTAMENTO

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
	-- ----------------------------------------------------------------
	-- P1
	-- ----------------------------------------------------------------
	DECLARE @DATA_P1_INI_A AS DATE = '20121231'
	DECLARE @DATA_P1_FIM_A AS DATE = '20130505'

	DECLARE @DATA_P1_INI_B AS DATE = '20131230'
	DECLARE @DATA_P1_FIM_B AS DATE = '20140504'

	DECLARE @NUM_SEM_P1 AS INT = 18
	
	-- ----------------------------------------------------------------
	-- P2
	-- ----------------------------------------------------------------
	DECLARE @DATA_P2_INI_A AS DATE = '20131230'
	DECLARE @DATA_P2_FIM_A AS DATE = '20140504'

	DECLARE @DATA_P2_INI_B AS DATE = '20141229'
	DECLARE @DATA_P2_FIM_B AS DATE = '20150503'
	
	DECLARE @NUM_SEM_P2 AS INT = 18
	
	-- ----------------------------------------------------------------
	-- P3
	-- ----------------------------------------------------------------
	--DECLARE @DATA_P3_INI_A AS DATE = '20131230'
	--DECLARE @DATA_P3_FIM_A AS DATE = '20140126'

	--DECLARE @DATA_P3_INI_B AS DATE = '20141229'
	--DECLARE @DATA_P3_FIM_B AS DATE = '20150125'
	
	--DECLARE @NUM_SEM_P3 AS INT = 4

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- VENDAS
-- -------------------------------------------------------------------------------------------------------------------------------------------
	-- ----------------------------------------------------------------
	-- P1 
	-- ----------------------------------------------------------------
		-- @TAB_VENDA_P1_A
		DECLARE @TAB_VENDA_P1_A AS TABLE
		(
			COD_LOJA INT
			,COD_DEPARTAMENTO INT
			,COD_SECAO INT
			,VENDA_P1_A NUMERIC(18,2)
			,QTD_P1_A NUMERIC(18,2)
		)

		INSERT INTO @TAB_VENDA_P1_A
			SELECT
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO
				,SUM(VALOR_TOTAL)/@NUM_SEM_P1 AS VENDA_P1_A
				,SUM(QTDE_PRODUTO)/@NUM_SEM_P1 AS QTD_P1_A
			FROM
				[BI].[dbo].[BI_CAD_PRODUTO] AS CP
					INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
					ON CP.COD_PRODUTO = VP.COD_PRODUTO
			WHERE 1 = 1
				AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI_A) AND CONVERT(DATE,@DATA_P1_FIM_A)
				AND CP.COD_DEPARTAMENTO NOT IN (15,99,20,7,18)
				AND CP.COD_SECAO NOT IN (16,85,21,9) --NATAL/OUTROS/SUCOSePOUPAS
				AND COD_LOJA = @COD_LOJA
			GROUP BY
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO

		-- @TAB_VENDA_P1_B
		DECLARE @TAB_VENDA_P1_B AS TABLE
		(
			COD_LOJA INT
			,COD_DEPARTAMENTO INT
			,COD_SECAO INT
			,VENDA_P1_B NUMERIC(18,2)
			,QTD_P1_B NUMERIC(18,2)
		)

		INSERT INTO @TAB_VENDA_P1_B
			SELECT
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO
				,SUM(VALOR_TOTAL)/@NUM_SEM_P1 AS VENDA_P1_B
				,SUM(QTDE_PRODUTO)/@NUM_SEM_P1 AS QTD_P1_B
			FROM
				[BI].[dbo].[BI_CAD_PRODUTO] AS CP
					INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
					ON CP.COD_PRODUTO = VP.COD_PRODUTO
			WHERE 1 = 1
				AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI_B) AND CONVERT(DATE,@DATA_P1_FIM_B)
				AND CP.COD_DEPARTAMENTO NOT IN (15,99,20,7,18)
				AND CP.COD_SECAO NOT IN (16,85,21,9) --NATAL/OUTROS/SUCOSePOUPAS
				AND COD_LOJA = @COD_LOJA
			GROUP BY
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO

	-- ----------------------------------------------------------------
	-- P2 
	-- ----------------------------------------------------------------
		-- @TAB_VENDA_P2_A
		DECLARE @TAB_VENDA_P2_A AS TABLE
		(
			COD_LOJA INT
			,COD_DEPARTAMENTO INT
			,COD_SECAO INT
			,VENDA_P2_A NUMERIC(18,2)
			,QTD_P2_A NUMERIC(18,2)
		)

		INSERT INTO @TAB_VENDA_P2_A
			SELECT
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO
				,SUM(VALOR_TOTAL)/@NUM_SEM_P2 AS VENDA_P2_A
				,SUM(QTDE_PRODUTO)/@NUM_SEM_P2 AS QTD_P2_A
			FROM
				[BI].[dbo].[BI_CAD_PRODUTO] AS CP
					INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
					ON CP.COD_PRODUTO = VP.COD_PRODUTO
			WHERE 1 = 1
				AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI_A) AND CONVERT(DATE,@DATA_P2_FIM_A)
				AND CP.COD_DEPARTAMENTO NOT IN (15,99,20,7,18)
				AND CP.COD_SECAO NOT IN (16,85,21,9) --NATAL/OUTROS/SUCOSePOUPAS
				AND COD_LOJA = @COD_LOJA
			GROUP BY
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO

		-- @TAB_VENDA_P2_B
		DECLARE @TAB_VENDA_P2_B AS TABLE
		(
			COD_LOJA INT
			,COD_DEPARTAMENTO INT
			,COD_SECAO INT
			,VENDA_P2_B NUMERIC(18,2)
			,QTD_P2_B NUMERIC(18,2)
		)

		INSERT INTO @TAB_VENDA_P2_B
			SELECT
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO
				,SUM(VALOR_TOTAL)/@NUM_SEM_P2 AS VENDA_P2_B
				,SUM(QTDE_PRODUTO)/@NUM_SEM_P2 AS QTD_P2_B
			FROM
				[BI].[dbo].[BI_CAD_PRODUTO] AS CP
					INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
					ON CP.COD_PRODUTO = VP.COD_PRODUTO
			WHERE 1 = 1
				AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI_B) AND CONVERT(DATE,@DATA_P2_FIM_B)
				AND CP.COD_DEPARTAMENTO NOT IN (15,99,20,7,18)
				AND CP.COD_SECAO NOT IN (16,85,21,9) --NATAL/OUTROS/SUCOSePOUPAS
				AND COD_LOJA = @COD_LOJA
			GROUP BY
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO

	-- ----------------------------------------------------------------
	-- P3 
	-- ----------------------------------------------------------------
	/*
		-- @TAB_VENDA_P3_A
		DECLARE @TAB_VENDA_P3_A AS TABLE
		(
			COD_LOJA INT
			,COD_DEPARTAMENTO INT
			,COD_SECAO INT
			,VENDA_P3_A NUMERIC(18,2)
			,QTD_P3_A NUMERIC(18,2)
		)

		INSERT INTO @TAB_VENDA_P3_A
			SELECT
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO
				,SUM(VALOR_TOTAL)/@NUM_SEM_P3 AS VENDA_P3_A
				,SUM(QTDE_PRODUTO)/@NUM_SEM_P3 AS QTD_P3_A
			FROM
				[BI].[dbo].[BI_CAD_PRODUTO] AS CP
					INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
					ON CP.COD_PRODUTO = VP.COD_PRODUTO
			WHERE 1 = 1
				AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P3_INI_A) AND CONVERT(DATE,@DATA_P3_FIM_A)
				AND CP.COD_DEPARTAMENTO NOT IN (15,99,20,7,18)
				AND CP.COD_SECAO NOT IN (16,85,21,9) --NATAL/OUTROS/SUCOSePOUPAS
				AND COD_LOJA = @COD_LOJA
			GROUP BY
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO

		-- @TAB_VENDA_P3_B
		DECLARE @TAB_VENDA_P3_B AS TABLE
		(
			COD_LOJA INT
			,COD_DEPARTAMENTO INT
			,COD_SECAO INT
			,VENDA_P3_B NUMERIC(18,2)
			,QTD_P3_B NUMERIC(18,2)
		)

		INSERT INTO @TAB_VENDA_P3_B
			SELECT
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO
				,SUM(VALOR_TOTAL)/@NUM_SEM_P3 AS VENDA_P3_B
				,SUM(QTDE_PRODUTO)/@NUM_SEM_P3 AS QTD_P3_B
			FROM
				[BI].[dbo].[BI_CAD_PRODUTO] AS CP
					INNER JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP
					ON CP.COD_PRODUTO = VP.COD_PRODUTO
			WHERE 1 = 1
				AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P3_INI_B) AND CONVERT(DATE,@DATA_P3_FIM_B)
				AND CP.COD_DEPARTAMENTO NOT IN (15,99,20,7,18)
				AND CP.COD_SECAO NOT IN (16,85,21,9) --NATAL/OUTROS/SUCOSePOUPAS
				AND COD_LOJA = @COD_LOJA
			GROUP BY
				COD_LOJA
				,COD_DEPARTAMENTO
				,COD_SECAO
	*/
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATES
-- -------------------------------------------------------------------------------------------------------------------------------------------
	-- ----------------------------------------------------------------
	-- P1
	-- ----------------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VENDA_P1_A = T.VENDA_P1_A
		,MAIN.QTD_P1_A = T.QTD_P1_A
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
		,MAIN.QTD_P1_B = T.QTD_P1_B
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P1_B AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_DEPARTAMENTO = T.COD_DEPARTAMENTO
			AND MAIN.COD_SECAO = T.COD_SECAO

	-- ----------------------------------------------------------------
	-- P2
	-- ----------------------------------------------------------------	
	UPDATE MAIN
	SET
		MAIN.VENDA_P2_A = T.VENDA_P2_A
		,MAIN.QTD_P2_A = T.QTD_P2_A
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
		,MAIN.QTD_P2_B = T.QTD_P2_B
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P2_B AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_DEPARTAMENTO = T.COD_DEPARTAMENTO
			AND MAIN.COD_SECAO = T.COD_SECAO

	-- ----------------------------------------------------------------
	-- P3
	-- ----------------------------------------------------------------
	/*
	UPDATE MAIN
	SET
		MAIN.VENDA_P3_A = T.VENDA_P3_A
		,MAIN.QTD_P3_A = T.QTD_P3_A
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P3_A AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_DEPARTAMENTO = T.COD_DEPARTAMENTO
			AND MAIN.COD_SECAO = T.COD_SECAO
	
	UPDATE MAIN
	SET
		MAIN.VENDA_P3_B = T.VENDA_P3_B
		,MAIN.QTD_P3_B = T.QTD_P3_B
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_VENDA_P3_B AS T 
			ON 1 = 1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_DEPARTAMENTO = T.COD_DEPARTAMENTO
			AND MAIN.COD_SECAO = T.COD_SECAO
	*/

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- AVG_PNP
-- -------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_AVG_PNP AS TABLE
	(
		PNP VARCHAR(5)
		,AVG_PNP NUMERIC(18,4)
	)

	INSERT INTO @TAB_AVG_PNP
	SELECT
		VS.PNP
		,SUM(VENDA_P2_B) / SUM(VENDA_P2_A) AS AVG_PNP
	FROM
		@TAB_VENDA_SECAO as VS
	GROUP BY
		VS.PNP
		
	UPDATE MAIN
	SET
		MAIN.AVG_PNP = (T.AVG_PNP -1)
	FROM
		@TAB_VENDA_SECAO AS MAIN
			INNER JOIN @TAB_AVG_PNP AS T 
			ON 1 = 1
			AND MAIN.PNP = T.PNP	
	
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- SELECT
-- -------------------------------------------------------------------------------------------------------------------------------------------		
	SELECT
		VS.COD_LOJA
		,CL.NO_LOJA
		,VS.PNP
		,NO_DEPARTAMENTO
		,NO_SECAO
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VENDA_P1_A,0)) AS VENDA_P1_A
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(QTD_P1_A,0)) AS QTD_P1_A
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VENDA_P1_B,0)) AS VENDA_P1_B
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(QTD_P1_B,0)) AS QTD_P1_B
		
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VENDA_P2_A,0)) AS VENDA_P2_A
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(QTD_P2_A,0)) AS QTD_P2_A
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VENDA_P2_B,0)) AS VENDA_P2_B
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(QTD_P2_B,0)) AS QTD_P2_B

		--,BI.dbo.fn_FormataVlr_Excel(ISNULL(VENDA_P3_A,0)) AS VENDA_P3_A
		--,BI.dbo.fn_FormataVlr_Excel(ISNULL(QTD_P3_A,0)) AS QTD_P3_A
		--,BI.dbo.fn_FormataVlr_Excel(ISNULL(VENDA_P3_B,0)) AS VENDA_P3_B
		--,BI.dbo.fn_FormataVlr_Excel(ISNULL(QTD_P3_B,0)) AS QTD_P3_B
		
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(AVG_PNP,0)) AS AVG_PNP
	FROM
		@TAB_VENDA_SECAO as VS INNER JOIN BI.dbo.BI_CAD_LOJA2 AS CL ON (VS.COD_LOJA = CL.COD_LOJA)
	WHERE 1 = 1
		AND VS.COD_LOJA = @COD_LOJA
	ORDER BY
		NO_DEPARTAMENTO
		,NO_SECAO
		