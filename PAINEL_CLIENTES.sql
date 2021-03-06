	SET NOCOUNT ON
-- --------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-- --------------------------------------------------------------------------------------------------------------------
	DECLARE @DATA_INI AS DATE = '2015-03-01'
	DECLARE @DATA_FIM AS DATE = '2016-02-29'

	DECLARE @PERC_A AS NUMERIC(6,2) = 0.1
	DECLARE @PERC_B AS NUMERIC(6,2) = 0.1
	DECLARE @PERC_C AS NUMERIC(6,2) = 0.8

-- --------------------------------------------------------------------------------------------------------------------
-- CPF U12M VALOR
-- --------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_CPF AS TABLE
	(
		CPF NUMERIC(18,0)
		,VLR_VENDA NUMERIC(18,2)
	)

	INSERT INTO @TAB_CPF
		SELECT --TOP 10
			[CPF]
			,SUM(VLR_CUPOM) AS VLR_VENDA
		FROM
			[BI].[dbo].[BI_VENDA_CUPOM_CAPA] AS CAPA
		WHERE 1=1
			AND CAPA.CPF_IDENTIFICADO = 1
			AND CONVERT(DATE,CAPA.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			[CPF]

-- --------------------------------------------------------------------------------------------------------------------
-- RANK CPF
-- --------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_CPF_RANK AS TABLE
	(
		CPF NUMERIC(18,0)
		,VLR_VENDA NUMERIC(18,2)
		,SEQ INT
		,DECIL INT
		,ABC VARCHAR(5)
	)

	INSERT INTO @TAB_CPF_RANK (CPF, VLR_VENDA, SEQ)
	SELECT
		CPF
		,VLR_VENDA
		,RANK() over (ORDER BY VLR_VENDA DESC) AS SEQ
	FROM @TAB_CPF

-- --------------------------------------------------------------------------------------------------------------------
-- CLASSIFICANDO ABC - QTC
-- --------------------------------------------------------------------------------------------------------------------
	DECLARE @MAX_RANK AS INT
	
	SELECT @MAX_RANK = MAX(SEQ) FROM @TAB_CPF_RANK	
		UPDATE @TAB_CPF_RANK SET ABC = 'HU' WHERE SEQ < @MAX_RANK * @PERC_A		
		UPDATE @TAB_CPF_RANK SET ABC = 'MU' WHERE SEQ BETWEEN (@MAX_RANK * @PERC_A) AND (@MAX_RANK * @PERC_A)+(@MAX_RANK * @PERC_B)		
		UPDATE @TAB_CPF_RANK SET ABC = 'LU' WHERE SEQ > @MAX_RANK * @PERC_C
		
	
		UPDATE @TAB_CPF_RANK SET DECIL = 1 WHERE SEQ < @MAX_RANK * 0.1 AND DECIL IS NULL
		UPDATE @TAB_CPF_RANK SET DECIL = 2 WHERE SEQ < @MAX_RANK * 0.2 AND DECIL IS NULL		
		UPDATE @TAB_CPF_RANK SET DECIL = 3 WHERE SEQ < @MAX_RANK * 0.3 AND DECIL IS NULL
		UPDATE @TAB_CPF_RANK SET DECIL = 4 WHERE SEQ < @MAX_RANK * 0.4 AND DECIL IS NULL
		UPDATE @TAB_CPF_RANK SET DECIL = 5 WHERE SEQ < @MAX_RANK * 0.5 AND DECIL IS NULL
		UPDATE @TAB_CPF_RANK SET DECIL = 6 WHERE SEQ < @MAX_RANK * 0.6 AND DECIL IS NULL
		UPDATE @TAB_CPF_RANK SET DECIL = 7 WHERE SEQ < @MAX_RANK * 0.7 AND DECIL IS NULL
		UPDATE @TAB_CPF_RANK SET DECIL = 8 WHERE SEQ < @MAX_RANK * 0.8 AND DECIL IS NULL
		UPDATE @TAB_CPF_RANK SET DECIL = 9 WHERE SEQ < @MAX_RANK * 0.9 AND DECIL IS NULL
		UPDATE @TAB_CPF_RANK SET DECIL = 10 WHERE SEQ >= @MAX_RANK * 0.9 AND DECIL IS NULL
	
	SELECT
		CPF 
		,SEQ
		,DECIL
		,ABC 
	FROM
		@TAB_CPF_RANK
	ORDER BY SEQ
	
-- --------------------------------------------------------------------------------------------------------------------
-- SELECT RANK CLIENTE
-- --------------------------------------------------------------------------------------------------------------------
	SELECT --TOP 10
		CAPA.[COD_LOJA]
		,CAPA.[DATA]
		,CAPA.[CPF]
		,BI.dbo.fn_FormataVlr_Excel(SUM(ITEM.VLR_VENDA)) AS VLR_VENDA		
		,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT CAPA.CUPOM_HASH)) AS QTD_CUPOM
		,BI.dbo.fn_FormataVlr_Excel(COUNT(ITEM.COD_PRODUTO)) AS QTD_SKU
		,BI.dbo.fn_FormataVlr_Excel(SUM(ITEM.QTDE_VENDA)) AS QTD_ITEM
	FROM
		[BI].[dbo].[BI_VENDA_CUPOM_CAPA] AS CAPA
		INNER JOIN [BI].[dbo].[BI_VENDA_CUPOM_PRODUTO] AS ITEM
			ON 1=1
			AND CAPA.CUPOM_HASH = ITEM.CUPOM_HASH
		INNER JOIN [BI].[dbo].[BI_CAD_PRODUTO] AS CP
			ON 1=1
			AND ITEM.COD_PRODUTO = CP.COD_PRODUTO
	WHERE 1=1
		AND CAPA.CPF_IDENTIFICADO = 1
		AND CONVERT(DATE,CAPA.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
	GROUP BY
		CAPA.[COD_LOJA]
		,CAPA.[DATA]
		,CAPA.[CPF]

-- --------------------------------------------------------------------------------------------------------------------
-- SUM TOTAL VENDA
-- --------------------------------------------------------------------------------------------------------------------
/*	
	SELECT 
		@VLR_A = SUM(VLR_VENDA) * @PERC_A
		,@VLR_B = SUM(VLR_VENDA) * @PERC_B
		,@VLR_C = SUM(VLR_VENDA) * @PERC_C	
	FROM @TAB_CPF_RANK
*/
-- --------------------------------------------------------------------------------------------------------------------
-- CLASSIFICANDO ABC - VLR
-- --------------------------------------------------------------------------------------------------------------------
/*
	DECLARE @CURSOR_CPF AS NUMERIC(18,0)
	DECLARE @CURSOR_VLR_VENDA AS NUMERIC(18,2)
	DECLARE @CURSOR_SEQ AS INT
	
	DECLARE @VAL_ACUMULADO AS NUMERIC(18,2) = 0

	DECLARE nome_cursor CURSOR FOR 
		SELECT CPF, VLR_VENDA, SEQ FROM @TAB_CPF_RANK ORDER BY SEQ
		
	OPEN nome_cursor
	FETCH NEXT FROM nome_cursor 
	INTO @CURSOR_CPF, @CURSOR_VLR_VENDA, @CURSOR_SEQ

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------	
			IF @VAL_ACUMULADO <= @VLR_A
			BEGIN				
				UPDATE @TAB_CPF_RANK SET ABC = 'A' WHERE CPF = @CURSOR_CPF
				
				SET @VAL_ACUMULADO = @VAL_ACUMULADO + @CURSOR_VLR_VENDA
				PRINT 'Definindo ABC = A para o CPF ' + convert(varchar,@CURSOR_CPF) + ' | Valor A: ' + convert(varchar,@VLR_A) + ' | Valor Acumulado: ' + convert(varchar,@VAL_ACUMULADO)
			END
			ELSE IF @VAL_ACUMULADO <= @VLR_A + @VLR_B
			BEGIN
				UPDATE @TAB_CPF_RANK SET ABC = 'B' WHERE CPF = @CURSOR_CPF
				
				SET @VAL_ACUMULADO = @VAL_ACUMULADO + @CURSOR_VLR_VENDA
				PRINT 'Definindo ABC = B para o CPF ' + convert(varchar,@CURSOR_CPF) + ' | Valor B: ' + convert(varchar,@VLR_B) + ' | Valor Acumulado: ' + convert(varchar,@VAL_ACUMULADO)
			END
			/*
			ELSE
			BEGIN
				UPDATE @TAB_CPF_RANK SET ABC = 'C' WHERE CPF = @CURSOR_CPF
				
				SET @VAL_ACUMULADO = @VAL_ACUMULADO + @CURSOR_VLR_VENDA
			END
			*/
						
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------
		FETCH NEXT FROM nome_cursor 
		INTO @CURSOR_CPF, @CURSOR_VLR_VENDA, @CURSOR_SEQ
	END 
	CLOSE nome_cursor;
	DEALLOCATE nome_cursor;
*/