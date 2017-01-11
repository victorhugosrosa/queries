	-- ----------------------------------------------------------------------------------------------
	-- 
	-- ----------------------------------------------------------------------------------------------
	DECLARE @DATA_FIM AS DATE = GETDATE()-1
	DECLARE @CLUSTER AS VARCHAR(8) = 'STM'
	DECLARE @H AS INT = 43
	DECLARE @L AS INT = 12
	
	-- ----------------------------------------------------------------------------------------------
	-- 
	-- ----------------------------------------------------------------------------------------------
	DECLARE @DATA_INI AS DATE = CONVERT(DATE,DATEADD(MONTH,-12,@DATA_FIM))
	
	-- ----------------------------------------------------------------------------------------------
	-- CLASSIFICANDO HML
	-- ----------------------------------------------------------------------------------------------
	DECLARE @TAB_CPF AS TABLE
	(
		CPF NUMERIC(18,0)
		,QTD_CUPOM INT
		,HML VARCHAR(1)
	)
	
	INSERT INTO @TAB_CPF
	(
		CPF
		,QTD_CUPOM
	)
		SELECT
			VCC.CPF
			,COUNT(CUPOM_HASH)
		FROM
			BI.dbo.BI_VENDA_CUPOM_CAPA AS VCC
			--INNER JOIN BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VCP
			--	ON 1=1
			--	AND VCC.CUPOM_HASH = VCP.CUPOM_HASH
			INNER JOIN BI.dbo.BI_CAD_LOJA2 AS L
				ON VCC.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND L.CLUSTER = @CLUSTER
			AND CONVERT(DATE,VCC.DATA) BETWEEN CONVERT(DATE,DATEADD(MONTH,-12,@DATA_INI)) AND CONVERT(DATE,@DATA_FIM)
			AND VCC.CPF IS NOT NULL
		GROUP BY
			VCC.CPF		
	
	UPDATE @TAB_CPF
	SET
		HML = (CASE
					WHEN QTD_CUPOM <= @L THEN 'L'
					WHEN QTD_CUPOM > @L AND QTD_CUPOM < @H THEN 'M'
					ELSE 'H'
				END)
				
	--SELECT * FROM @TAB_CPF-- ORDER BY QTD_CUPOM DESC
	
	-- ----------------------------------------------------------------------------------------------
	-- 
	-- ----------------------------------------------------------------------------------------------
	SELECT
		VCC.COD_LOJA
		,HML.HML
		,BI.dbo.fn_FormataVlr_Excel(COUNT(CUPOM_HASH)) AS QTD_CUPOM
		,BI.dbo.fn_FormataVlr_Excel(SUM(VLR_CUPOM)) AS VLR_CUPOM
		,BI.dbo.fn_FormataVlr_Excel(SUM(VCC.QTD_ITEM)) AS [# de SKUs]
		,BI.dbo.fn_FormataVlr_Excel(AVG(VCC.QTD_ITEM)) AS [# de SKUs / compra]
	FROM
		BI.dbo.BI_VENDA_CUPOM_CAPA AS VCC
		--INNER JOIN BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VCP
		--	ON 1=1
		--	AND VCC.CUPOM_HASH = VCP.CUPOM_HASH
		INNER JOIN BI.dbo.BI_CAD_LOJA2 AS L
			ON VCC.COD_LOJA = L.COD_LOJA
		INNER JOIN @TAB_CPF AS HML
			ON VCC.CPF = HML.CPF
	WHERE 1=1
		AND L.CLUSTER = @CLUSTER
		AND CONVERT(DATE,VCC.DATA) BETWEEN CONVERT(DATE,DATEADD(MONTH,-1,@DATA_INI)) AND CONVERT(DATE,@DATA_FIM)
		AND VCC.CPF IS NOT NULL
	GROUP BY
		VCC.COD_LOJA
		,HML.HML
		
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TEMP_DASH_ITEM_SKU AS TABLE
	(
		COD_LOJA INT
		,HML VARCHAR(1)
		,COD_PRODUTO INT
		,AVG_ITEM_SKU NUMERIC(18,2)
		,VLR_VENDA NUMERIC(18,2)
		,QTD_VENDA NUMERIC(18,2)
		,PRIMARY KEY (COD_LOJA, HML, COD_PRODUTO)		
	)

	-- -------------------------------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO @TEMP_DASH_ITEM_SKU
		SELECT
			VCP.COD_LOJA
			,HML
			,COD_PRODUTO
			,AVG(QTDE_VENDA) as AVG_ITEM_SKU
			,SUM(VLR_VENDA)
			,COUNT(COD_PRODUTO)
		FROM
			BI.DBO.BI_VENDA_CUPOM_PRODUTO AS VCP
			INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
				ON VCP.DATA = S.DATA
			INNER JOIN BI.dbo.BI_CAD_LOJA2 AS L
				ON VCP.COD_LOJA = L.COD_LOJA
				AND L.FLG_LOJA = 1
			INNER JOIN @TAB_CPF AS HML
				ON VCP.CPF = HML.CPF
		WHERE 1=1
			AND CONVERT(DATE,VCP.DATA) BETWEEN CONVERT(DATE,DATEADD(MONTH,-1,@DATA_INI)) AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			VCP.COD_LOJA
			,HML
			,COD_PRODUTO
	
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT
			COD_LOJA
			,HML
			,BI.dbo.fn_FormataVlr_Excel(AVG(AVG_ITEM_SKU)) AS AVG_ITEM_SKU
			,BI.dbo.fn_FormataVlr_Excel(SUM(QTD_VENDA)) AS QTD_ITEM_SKU
		FROM
			@TEMP_DASH_ITEM_SKU
		GROUP BY
			COD_LOJA
			,HML