-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_VENDA_SECAO_LOJAS AS TABLE
(
	NO_DEPARTAMENTO VARCHAR(50)
	,COD_LOJA INT
	,VLR_VENDA NUMERIC(18,2)
	,PERCENTUAL NUMERIC(18,2)
	,CLUSTER VARCHAR(50)
)

INSERT INTO @TAB_VENDA_SECAO_LOJAS
	SELECT
		NO_DEPARTAMENTO
		,COD_LOJA
		,SUM(VALOR_TOTAL) AS VLR_VENDA
		,NULL
		,NULL
	FROM
		BI.DBO.BI_VENDA_PRODUTO AS VP
		INNER JOIN BI.DBO.BI_CAD_PRODUTO AS CP
			ON 1=1
			AND VP.COD_PRODUTO = CP.COD_PRODUTO
	WHERE 1=1
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,'20140101') AND CONVERT(DATE,'20141231')
		--AND VP.COD_LOJA NOT IN (7)
		--AND CP.NO_SECAO = 'ACOMPANHAMENTO'
	GROUP BY
		NO_DEPARTAMENTO
		,COD_LOJA
	ORDER BY
		NO_DEPARTAMENTO
		,SUM(VALOR_TOTAL) DESC
		
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @NO_SECAO AS VARCHAR(50);
	DECLARE @COD_LOJA AS INT;
	DECLARE @VLR_VENDA AS NUMERIC(18,2);

	DECLARE @NO_SECAO_OLD AS VARCHAR(50)
	DECLARE @VLR_VENDA_MAIOR AS NUMERIC(18,2);;

	DECLARE @CONTADOR AS INT = 1;
	DECLARE @PERCENTUAL AS NUMERIC(18,2);

	DECLARE nome_cursor CURSOR FOR 
		SELECT
			NO_DEPARTAMENTO
			,COD_LOJA
			,VLR_VENDA
		FROM
			@TAB_VENDA_SECAO_LOJAS
		
	OPEN nome_cursor
	FETCH NEXT FROM nome_cursor 
	INTO @NO_SECAO, @COD_LOJA, @VLR_VENDA

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------			
			IF @NO_SECAO <> @NO_SECAO_OLD SET @CONTADOR = 1
			IF @CONTADOR = 1 SET @VLR_VENDA_MAIOR = @VLR_VENDA			
			SET @PERCENTUAL = @VLR_VENDA/@VLR_VENDA_MAIOR
			
			UPDATE @TAB_VENDA_SECAO_LOJAS SET PERCENTUAL = @PERCENTUAL	WHERE COD_LOJA = @COD_LOJA AND NO_DEPARTAMENTO = @NO_SECAO			
			
			SET @NO_SECAO_OLD = @NO_SECAO	
			SET @CONTADOR = @CONTADOR + 1
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------
		FETCH NEXT FROM nome_cursor 
		INTO @NO_SECAO, @COD_LOJA, @VLR_VENDA
	END 
	CLOSE nome_cursor;
	DEALLOCATE nome_cursor;


	UPDATE @TAB_VENDA_SECAO_LOJAS
	SET
		CLUSTER =
		(CASE
			WHEN PERCENTUAL <= 1 AND PERCENTUAL >= 0.75 THEN 'A'
			WHEN PERCENTUAL < 0.75 AND PERCENTUAL >= 0.5 THEN 'B'
			WHEN PERCENTUAL < 0.5 AND PERCENTUAL >= 0.25 THEN 'C'
			WHEN PERCENTUAL < 0.25 THEN 'D'
		END)

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_QUEBRA AS TABLE
	(
		NO_DEPARTAMENTO VARCHAR(50)
		,COD_LOJA INT
		,VLR_QUEBRA NUMERIC(18,2)
	)

	INSERT INTO @TAB_QUEBRA
	SELECT
		CP.NO_DEPARTAMENTO
		,COD_LOJA
		,SUM([QTD_AJUSTE]*[VAL_CUSTO_REP])*(-1) AS VLR_QUEBRA
	FROM
		[192.168.0.6].Zeus_rtg.dbo.TAB_AJUSTE_ESTOQUE AS AE INNER JOIN BI.DBO.BI_CAD_PRODUTO AS CP ON (AE.COD_PRODUTO = CP.COD_PRODUTO)
	WHERE 1 = 1
		AND AE.COD_AJUSTE IN (51,120,121,122,123,124,154,155)
		AND CONVERT(DATE,AE.DTA_AJUSTE) BETWEEN CONVERT(DATE,'20140101') AND CONVERT(DATE,'20141231')
	GROUP BY
		CP.NO_DEPARTAMENTO
		,COD_LOJA

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT
		V.NO_DEPARTAMENTO
		,L.NO_LOJA
		,BI.dbo.fn_FormataVlr_Excel(V.VLR_VENDA) AS VLR_VENDA
		,BI.dbo.fn_FormataVlr_Excel(V.PERCENTUAL) AS PERC_CLUSTER
		,BI.dbo.fn_FormataVlr_Excel(V.CLUSTER) AS CLUSTER
		,BI.dbo.fn_FormataVlr_Excel(Q.VLR_QUEBRA/V.VLR_VENDA) AS PERC_QUEBRA
	FROM
		@TAB_VENDA_SECAO_LOJAS AS V
		INNER JOIN BI.dbo.BI_CAD_LOJA2 AS L
			ON V.COD_LOJA = L.COD_LOJA
		INNER JOIN @TAB_QUEBRA AS Q
			ON 1=1
			AND V.COD_LOJA = Q.COD_LOJA
			AND V.NO_DEPARTAMENTO = Q.NO_DEPARTAMENTO