SET NOCOUNT ON

DECLARE @COD_LOJA AS INT;
DECLARE @COD_PRODUTO AS INT;
DECLARE @DATA AS DATE;

DECLARE nome_cursor CURSOR FOR 
	SELECT TOP 1000000
		[COD_LOJA]
		,[COD_PRODUTO]
		,[DATA]
	FROM
		[BI].[dbo].[BI_ESTOQUE_PRODUTO_DIA]
	WHERE 1=1
		AND FLG_ATUALIZADO IS NULL
		AND VLR_VENDA_U30D_PD IS NULL
		AND CONVERT(DATE,DATA) >= CONVERT(DATE,'20150101')
		--AND COD_PRODUTO = 17
		
OPEN nome_cursor
FETCH NEXT FROM nome_cursor 
INTO @COD_LOJA, @COD_PRODUTO, @DATA

WHILE @@FETCH_STATUS = 0
BEGIN
	-- -------------------------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------		
	DECLARE @TAB_AVG_VENDA_EST AS TABLE
	(
		COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_VENDA_U30D_PD NUMERIC(18,2)
		PRIMARY KEY (COD_LOJA, COD_PRODUTO)
	);
	DELETE FROM @TAB_AVG_VENDA_EST
	
	INSERT INTO @TAB_AVG_VENDA_EST
	SELECT
		VP.COD_LOJA
		,VP.COD_PRODUTO
		,SUM(VALOR_TOTAL)/SUM(QTDE_PRODUTO)
	FROM
		BI.DBO.BI_VENDA_PRODUTO AS VP
	WHERE 1=1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,DATEADD(D,-30,@DATA)) AND CONVERT(DATE,DATEADD(D,-1,@DATA))
		AND VP.COD_LOJA = @COD_LOJA
		AND VP.COD_PRODUTO = @COD_PRODUTO
	GROUP BY
		VP.COD_LOJA
		,VP.COD_PRODUTO
	
	-- ------------------------
	-- UPDATE
	-- ------------------------
	UPDATE EPD
	SET
		EPD.VLR_VENDA_U30D_PD = T.VLR_VENDA_U30D_PD
	FROM
		[BI].[dbo].[BI_ESTOQUE_PRODUTO_DIA] AS EPD
		INNER JOIN @TAB_AVG_VENDA_EST AS T
			ON 1=1
			AND EPD.COD_LOJA = T.COD_LOJA
			AND EPD.COD_PRODUTO = T.COD_PRODUTO
			AND CONVERT(DATE,EPD.DATA) = CONVERT(DATE,@DATA)
			
	UPDATE [BI].[dbo].[BI_ESTOQUE_PRODUTO_DIA]
	SET
		FLG_ATUALIZADO = 1
	WHERE 1=1
		AND COD_LOJA = @COD_LOJA
		AND COD_PRODUTO = @COD_PRODUTO
		AND CONVERT(DATE,DATA) = CONVERT(DATE,@DATA)		
	-- -------------------------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------
    FETCH NEXT FROM nome_cursor 
    INTO @COD_LOJA, @COD_PRODUTO, @DATA
END 
CLOSE nome_cursor;
DEALLOCATE nome_cursor;


	