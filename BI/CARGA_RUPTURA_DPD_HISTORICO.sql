	DECLARE @DATA_INI DATE = '20140601'
	DECLARE @DATA_FIM DATE = '20150101'
	
	-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- 
	-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_PROD_EST AS TABLE
	(
		COD_LOJA INT
		,COD_PRODUTO INT
		,DATA DATE
		,QTD_ESTOQUE NUMERIC(18,2)
	)
	
	INSERT INTO @TAB_PROD_EST
	SELECT
		[COD_LOJA]
		,[COD_PRODUTO]
		,CONVERT(DATE,DATA) AS DATA
		,[QTD_ESTOQUE]
	FROM
		BI.dbo.BI_ESTOQUE_PRODUTO_DIA 
	WHERE 1 = 1
		AND CONVERT(DATE,DATA) >= CONVERT(DATE,@DATA_INI)
		AND CONVERT(DATE,DATA) < CONVERT(DATE,@DATA_FIM)
		--AND COD_LOJA = 1
		
	-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- 
	-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_PROD_DPD AS TABLE
	(
		DATA DATE
		,COD_LOJA INT
		,COD_PRODUTO INT
		,QTD_ESTOQUE NUMERIC(18,2)
		,PRECO_VENDA NUMERIC(18,2)
		,AVG_VENDA NUMERIC(18,2)
		,DPD NUMERIC(18,2)
		,RUPTURA NUMERIC(18,2)
	)
	
	INSERT INTO @TAB_PROD_DPD	
	SELECT
		PE.DATA
		,PE.COD_LOJA
		,PE.COD_PRODUTO
		,(CASE WHEN PE.QTD_ESTOQUE < 0 THEN 0 ELSE ISNULL(PE.QTD_ESTOQUE,0) END) AS QTD_ESTOQUE
		,LINHA.VLR_VENDA AS PRECO_VENDA
		,((EST.AVG_QTD_VENDA*LINHA.VLR_VENDA)/7) AS AVG_VENDA
		,(((CASE WHEN PE.QTD_ESTOQUE < 0 THEN 0 ELSE ISNULL(PE.QTD_ESTOQUE,0) END))*LINHA.VLR_VENDA)/((EST.AVG_QTD_VENDA*LINHA.VLR_VENDA)/7) AS DPD
		,(CASE WHEN PE.QTD_ESTOQUE = 0 THEN 1 ELSE 0 END) AS RUPTURA		
	FROM
		@TAB_PROD_EST AS PE
		INNER JOIN BI.DBO.COMPRAS_ESTATISTICA_PRODUTO AS EST
			ON 1=1
			AND PE.COD_LOJA = EST.COD_LOJA
			AND PE.COD_PRODUTO = EST.COD_PRODUTO
		INNER JOIN BI.DBO.BI_LINHA_PRODUTOS AS LINHA
			ON 1=1
			AND PE.COD_LOJA = LINHA.COD_LOJA
			AND PE.COD_PRODUTO = LINHA.COD_PRODUTO
		INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON PE.COD_PRODUTO = CP.COD_PRODUTO
	WHERE 1=1
		--AND CP.PESADO = 'N'
		AND LINHA.FORA_LINHA = 'N'
		AND LINHA.COD_DEPARTAMENTO NOT IN (15,20)
	ORDER BY
		PE.DATA
		,PE.COD_LOJA
		,PE.COD_PRODUTO
	
	-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- 
	-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	/*
	TRUNCATE TABLE [BI].[dbo].[BI_DPD_PRODUTO_MES]
	
	DELETE FROM [BI].[dbo].[BI_DPD_PRODUTO_MES]
	WHERE 1=1
		AND ANO = YEAR(GETDATE())
		AND MES = MONTH(GETDATE())
	*/
	
	INSERT INTO [BI].[dbo].[BI_DPD_PRODUTO_MES]
	(
		[COD_LOJA]
		,[ANO]
		,[MES]
		,[COD_PRODUTO]
		,[DPD]
		,[RUPTURA]
	)	
	
	SELECT
		COD_LOJA
		,YEAR(DATA) AS ANO
		,MONTH(DATA) AS MES
		,COD_PRODUTO
		--,BI.dbo.fn_FormataVlr_Excel(PRECO_VENDA) AS PRECO_VENDA
		--,BI.dbo.fn_FormataVlr_Excel(AVG_VENDA) AS AVG_VENDA
		,(SUM(QTD_ESTOQUE)*PRECO_VENDA)/(AVG_VENDA*30) AS DPD
		,AVG(RUPTURA) AS RUPTURA
	FROM
		@TAB_PROD_DPD
	GROUP BY
		COD_LOJA
		,YEAR(DATA)
		,MONTH(DATA)
		,COD_PRODUTO
		,PRECO_VENDA
		,AVG_VENDA
	-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- 
	-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/*
	TRUNCATE TABLE [BI].[dbo].[BI_DPD_PRODUTO_MES]
	
	DELETE FROM [BI].[dbo].[BI_DPD_PRODUTO_MES]
	WHERE 1=1
		AND ANO = YEAR(GETDATE())
		AND MES = MONTH(GETDATE())
	*/
	
	/*
	DELETE FROM [BI].[dbo].[BI_DPD_PRODUTO_MES]
	WHERE 1=1
		AND ANO = 2014
		AND MES = 9
	
	INSERT INTO [BI].[dbo].[BI_DPD_PRODUTO_MES]
	(
		[COD_LOJA]
		,[ANO]
		,[MES]
		,[COD_PRODUTO]
		,[DPD]
		,[RUPTURA]
	)	
	SELECT
		COD_LOJA
		,YEAR([DATA]) AS ANO
		,MONTH([DATA]) AS MES
		,COD_PRODUTO
		,AVG(DPD) AS DPD_AVG
		,AVG(RUPTURA) AS RUPTURA_AVG	
	FROM
		@TAB_PROD_DPD
	WHERE 1=1
		--AND COD_PRODUTO in (17,688888)
	GROUP BY
		COD_LOJA
		,YEAR([DATA])
		,MONTH([DATA])
		,COD_PRODUTO

	*/