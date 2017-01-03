-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @FORN_ORBIS AS TABLE
	(
		COD_FORNECEDOR INT
		,NO_FORNECEDOR VARCHAR(50)
		,VLR_VENDA NUMERIC(18,3)
	)

	INSERT INTO @FORN_ORBIS
	SELECT
		CP.COD_FORNECEDOR
		,CF.DES_FANTASIA
		,SUM(VALOR_TOTAL) AS VLR_VENDA
	FROM 
		BI_VENDA_PRODUTO AS VP INNER JOIN BI_CAD_PRODUTO AS CP ON (VP.COD_PRODUTO = CP.COD_PRODUTO)
			INNER JOIN BI_CAD_FORNECEDOR AS CF ON (CP.COD_FORNECEDOR = CF.COD_FORNECEDOR)
	WHERE 1 = 1
		AND CP.COD_FORNECEDOR = 18055
		AND CP.COD_DEPARTAMENTO NOT IN (6)
		AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,'20141201') AND CONVERT(DATE,'20141231')
		AND CP.COD_PRODUTO IN (SELECT DISTINCT COD_PRODUTO FROM CADASTRO_CAD_PRODUTO_METADADOS AS M WHERE M.COD_METADADO = 4 AND VLR_METADADO = 1)
	GROUP BY
		CP.COD_FORNECEDOR
		,CF.DES_FANTASIA
	ORDER BY
		SUM(VALOR_TOTAL) DESC
		
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @FORN_TOPS AS TABLE
	(
		COD_FORNECEDOR INT
		,NO_FORNECEDOR VARCHAR(50)
		,VLR_VENDA NUMERIC(18,3)
	)

	INSERT INTO @FORN_TOPS
	SELECT TOP 99
		CP.COD_FORNECEDOR
		,CF.DES_FANTASIA
		,SUM(VALOR_TOTAL) AS VLR_VENDA
	FROM 
		BI_VENDA_PRODUTO AS VP INNER JOIN BI_CAD_PRODUTO AS CP ON (VP.COD_PRODUTO = CP.COD_PRODUTO)
			INNER JOIN BI_CAD_FORNECEDOR AS CF ON (CP.COD_FORNECEDOR = CF.COD_FORNECEDOR)
	WHERE 1 = 1
		AND CP.COD_FORNECEDOR <> 18055
		AND CP.COD_DEPARTAMENTO NOT IN (6)
		AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,'20141201') AND CONVERT(DATE,'20141231')
	GROUP BY
		CP.COD_FORNECEDOR
		,CF.DES_FANTASIA
	ORDER BY
		SUM(VALOR_TOTAL) DESC
	
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @RANKING_FORN AS TABLE
	(
		COD_FORNECEDOR INT
		,NO_FORNECEDOR VARCHAR(50)
		,VLR_VENDA NUMERIC(18,3)
	)

	INSERT INTO @RANKING_FORN
	SELECT
		COD_FORNECEDOR
		,NO_FORNECEDOR
		,VLR_VENDA
	FROM
		@FORN_ORBIS
		
	INSERT INTO @RANKING_FORN
	SELECT
		COD_FORNECEDOR
		,NO_FORNECEDOR
		,VLR_VENDA
	FROM
		@FORN_TOPS

	-- ##############################################################
	-- 
	-- ##############################################################
	SELECT
		COD_FORNECEDOR
		,NO_FORNECEDOR
		,BI.dbo.fn_FormataVlr_Excel(VLR_VENDA) AS VENDA
	FROM
		@RANKING_FORN
	ORDER BY
		VLR_VENDA DESC