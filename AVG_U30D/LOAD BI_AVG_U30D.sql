/*
SELECT TOP 1000
	[COD_LOJA]
	,[COD_PRODUTO]
	,[DATA]
	,[AVG_VLR_U30D_PD]
	,[AVG_QTD_U30D_PD]
FROM [BI].[dbo].[BI_AVG_U30D]


select count(*) from [BI].[dbo].[BI_AVG_U30D]
*/

SET NOCOUNT ON

DECLARE @COD_LOJA AS INT;
DECLARE @COD_PRODUTO AS INT;
DECLARE @DATA AS DATE;

DECLARE nome_cursor CURSOR FOR 
	SELECT TOP 10000000
		EPD.[COD_LOJA]
		,EPD.[COD_PRODUTO]
		,EPD.[DATA]
	FROM
		[BI].[dbo].[BI_ESTOQUE_PRODUTO_DIA] AS EPD
		LEFT JOIN [BI].[dbo].[BI_AVG_U30D] AS T
			ON 1=1
			AND EPD.[COD_LOJA] = T.[COD_LOJA]
			AND EPD.[COD_PRODUTO] = T.[COD_PRODUTO]
			AND EPD.[DATA] = T.[DATA]
	WHERE 1=1
		AND T.[COD_PRODUTO] IS NULL
		AND CONVERT(DATE,EPD.DATA) >= CONVERT(DATE,'20150101')
	ORDER BY 
		EPD.[COD_LOJA]
		,EPD.[COD_PRODUTO]
		,EPD.[DATA]
		
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
		,AVG_VLR_U30D_PD NUMERIC(18,2)
		,AVG_QTD_U30D_PD NUMERIC(18,2)
		PRIMARY KEY (COD_LOJA, COD_PRODUTO)
	);
	DELETE FROM @TAB_AVG_VENDA_EST
	
	INSERT INTO @TAB_AVG_VENDA_EST
	SELECT
		VP.COD_LOJA
		,VP.COD_PRODUTO
		,SUM(VALOR_TOTAL)/30
		,SUM(QTDE_PRODUTO)/30
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
	INSERT INTO BI.DBO.BI_AVG_U30D
	SELECT
		COD_LOJA
		,COD_PRODUTO
		,@DATA
		,AVG_VLR_U30D_PD
		,AVG_QTD_U30D_PD
	FROM
		@TAB_AVG_VENDA_EST		
	-- -------------------------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------
    FETCH NEXT FROM nome_cursor 
    INTO @COD_LOJA, @COD_PRODUTO, @DATA
END 
CLOSE nome_cursor;
DEALLOCATE nome_cursor;


	