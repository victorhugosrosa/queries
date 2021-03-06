	--[BI_VENDA_CUPOM_PRODUTO_RESTAURANTE]
	
	
	DECLARE @DATA_INI AS DATE = '2016-09-01'
	DECLARE @DATA_FIM AS DATE = '2016-10-01'
	
	SET NOCOUNT ON;
	-- -------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_PV_ATUAL_CHEF AS TABLE
	(
		COD_RESTAURANTE INT
		,COD_PRODUTO_CHEFF VARCHAR(50)
		,PRECO NUMERIC(18,3)
	)
	INSERT INTO @TAB_PV_ATUAL_CHEF
		SELECT
			RIGHT(EPROC_CNPJ,3)
			,FARTCOD 
			,FARTPR1
		FROM [EATALY.CHEFFSOLUTIONS.COM].EPROC_1024.DBO.FO_FAART
	
	-- -------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_PV_ATUAL AS TABLE
	(
		COD_PRODUTO VARCHAR(50)
		--COD_RESTAURANTE INT
		,PRECO NUMERIC(18,3)
	)
	INSERT INTO @TAB_PV_ATUAL
		SELECT
			DEPARA.COD_PRODUTO		
			--,DEPARA.COD_RESTAURANTE
			,MAX(PV.PRECO) AS PRECO
		FROM
			@TAB_PV_ATUAL_CHEF AS PV
			LEFT JOIN [BI].[DBO].[CAD_DE_PARA_CHEFF] AS DEPARA
				ON 1=1
				AND PV.COD_PRODUTO_CHEFF = DEPARA.COD_PRODUTO_CHEFF
				AND PV.COD_RESTAURANTE = DEPARA.COD_RESTAURANTE
			LEFT JOIN BI.DBO.BI_CAD_PRODUTO AS CP
				ON DEPARA.COD_PRODUTO = CP.COD_PRODUTO
		WHERE 1=1
			--AND DEPARA.COD_PRODUTO = 1030731
			--AND PV.COD_RESTAURANTE = 106
			--AND PV.PRECO <> 1
		GROUP BY
			DEPARA.COD_PRODUTO	
			--DEPARA.COD_RESTAURANTE
			
	
	-- -------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_CUPONS_PRANZO AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,CUPOM INT
		,CAIXA INT
		,PRIMARY KEY (COD_LOJA,DATA,CUPOM,CAIXA)
	)
	INSERT INTO @TAB_CUPONS_PRANZO
		SELECT DISTINCT --TOP 10
			VI.COD_LOJA
			,CONVERT(DATE,VI.DATA)
			,CUPOM
			,VI.CAIXA
		FROM
			[DW].[dbo].[TAB_CHEFFSOLUTION_CUPOM_ITENS] AS VI
			LEFT JOIN [BI].[dbo].[CAD_DE_PARA_CHEFF] AS DEPARA
				ON 1=1
				AND VI.COD_PRODUTO_CHEFF = DEPARA.COD_PRODUTO_CHEFF
				AND VI.COD_RESTAURANTE = DEPARA.COD_RESTAURANTE
			LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
				ON DEPARA.COD_PRODUTO = CP.COD_PRODUTO
		WHERE 1=1
			AND CONVERT(DATE,VI.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
			AND VI.COD_LOJA IN (33)
			AND VI.CUPOM = 63157
			AND VI.COD_RESTAURANTE = 106
			AND DEPARA.COD_PRODUTO = 1018862 --NAO REMOVER, PLU PRANZO COMBO

	-- -------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------	
	--SELECT * FROM @TAB_CUPONS_PRANZO	
	DECLARE @TAB_CUPOM_CHEFF AS TABLE
	(
		COD_LOJA INT
		,COD_RESTAURANTE INT
		,DATA DATE
		,CUPOM INT
		,CAIXA INT
		,COD_PRODUTO INT
		,COD_PRODUTO_CHEFF VARCHAR(50)
		,DES_PRODUTO_CHEFF VARCHAR(50)
		,DESCRICAO VARCHAR(50)
		,VLR_UNITARIO_PROD NUMERIC(18,3)
		,PV_ATUAL NUMERIC(18,3)
		,QTD_VENDA NUMERIC(18,3)
		,VALOR_TOTAL NUMERIC(18,3)
		,VLR_TOTAL_SEM_IMP NUMERIC(18,3)
	)
	INSERT INTO @TAB_CUPOM_CHEFF
		SELECT 
			VI.[COD_LOJA]
			,VI.COD_RESTAURANTE
			,CONVERT(DATE,VI.DATA) AS DATA
			,VI.CUPOM
			,VI.CAIXA
			,ISNULL(DEPARA.COD_PRODUTO,1) AS COD_PRODUTO
			,VI.COD_PRODUTO_CHEFF	
			,VI.DES_PRODUTO_CHEFF
			,CP.DESCRICAO	
			,VI.VALOR_UNITARIO as  VLR_UNITARIO_PROD
			,PV.PRECO AS PV_ATUAL
			,VI.QUANTIDADE*ISNULL(VI.Quantidade_Dividida,1) as QTD_VENDA
			,VI.VALOR_TOTAL as VLR_TOTAL_PRODUTO
			,VI.ValorTotalSemImposto
			--,isnull(VI.ValorTotalSemImposto,VI.VALOR_TOTAL*0.968) as VLR_TOTAL_SEM_IMP	
		FROM
			[DW].[dbo].[TAB_CHEFFSOLUTION_CUPOM_ITENS] AS VI
			INNER JOIN @TAB_CUPONS_PRANZO AS TC
				ON 1=1
				AND VI.COD_LOJA = TC.COD_LOJA
				AND VI.DATA = TC.DATA
				AND VI.CAIXA = TC.CAIXA
				AND VI.CUPOM = TC.CUPOM
			LEFT JOIN [BI].[dbo].[CAD_DE_PARA_CHEFF] AS DEPARA
				ON 1=1
				AND VI.COD_PRODUTO_CHEFF = DEPARA.COD_PRODUTO_CHEFF
				AND VI.COD_RESTAURANTE = DEPARA.COD_RESTAURANTE
			LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
				ON DEPARA.COD_PRODUTO = CP.COD_PRODUTO
			LEFT JOIN @TAB_PV_ATUAL AS PV
				ON 1=1
				AND DEPARA.COD_PRODUTO = PV.COD_PRODUTO
				--AND DEPARA.COD_RESTAURANTE = PV.COD_RESTAURANTE
		WHERE 1=1
			AND CONVERT(DATE,VI.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
			AND VI.COD_LOJA IN (33)
			--AND
			--(
			--	DEPARA.COD_PRODUTO IN (1030103,1030105,1030095,1030099,1030106,1033638,1030102,1030098,1033637,703192,1030096,1030104) --PLUS PRANZO
			--	OR
			--	DEPARA.COD_PRODUTO IN (1005483,1026054,1026056,686556,1030730,1030731,588744,491174,1032499) --PLUS BEBIDAS PRANZO
			--)
	
	-- -------------------------------------------------------------------------------------------------------------------------------
	-- CHECK ORIGINAL
	-- -------------------------------------------------------------------------------------------------------------------------------		
	/*SELECT SUM(VALOR_TOTAL) FROM @TAB_CUPOM_CHEFF
	SELECT	
		COD_LOJA
		,COD_RESTAURANTE
		,DATA
		,CUPOM
		,CAIXA
		,COD_PRODUTO	
		,COD_PRODUTO_CHEFF	
		,DES_PRODUTO_CHEFF
		,DESCRICAO	
		,VLR_UNITARIO_PROD
		,PV_ATUAL
		,QTD_VENDA
		,BI.dbo.fn_FormataVlr_Excel(VALOR_TOTAL) AS VALOR_TOTAL
		,VLR_TOTAL_SEM_IMP
	FROM
		@TAB_CUPOM_CHEFF
	ORDER BY
		COD_LOJA
		,COD_RESTAURANTE
		,DATA
		,CUPOM
		,CAIXA
		,COD_PRODUTO	
		,COD_PRODUTO_CHEFF	
	*/
	-- -------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------	
	-- ---------------------------------------------------
	-- var cursor_cupom
	-- ---------------------------------------------------
	DECLARE @COD_LOJA AS INT;
	DECLARE @COD_RESTAURANTE AS INT;
	DECLARE @DATA AS DATE;
	DECLARE @CUPOM AS INT;
	DECLARE @CAIXA AS INT;
	DECLARE @VALOR_TOTAL_CUPOM AS NUMERIC(18,3);
	
	-- ---------------------------------------------------
	-- var cursor_cupom_item
	-- ---------------------------------------------------
	DECLARE @COD_PRODUTO AS INT;
	DECLARE @COD_PRODUTO_CHEFF VARCHAR(50);
	DECLARE @VLR_UNITARIO_PROD AS NUMERIC(18,3);
	DECLARE @PV_ATUAL AS NUMERIC(18,3);
	DECLARE @QTD_VENDA AS NUMERIC(18,3);
	DECLARE @VALOR_TOTAL AS NUMERIC(18,3);
	
	-- ---------------------------------------------------
	-- var geral
	-- ---------------------------------------------------
	DECLARE @VLR_CUPOM_ANTES AS NUMERIC(18,3);
	DECLARE @VLR_CUPOM_DEPOIS AS NUMERIC(18,3);
	
	DECLARE @VLR_REMOVER_PRANZO AS NUMERIC(18,3);
	
	-- ##################################################################################################################
	--
	-- ##################################################################################################################
	DECLARE cursor_cupom CURSOR FOR 
		SELECT DISTINCT
			COD_LOJA
			,COD_RESTAURANTE
			,DATA
			,CUPOM
			,CAIXA
		FROM
			@TAB_CUPOM_CHEFF
		ORDER BY
			COD_LOJA
			,COD_RESTAURANTE
			,DATA
			,CUPOM
			,CAIXA

		
	OPEN cursor_cupom
	FETCH NEXT FROM cursor_cupom 
	INTO @COD_LOJA,@COD_RESTAURANTE,@DATA,@CUPOM,@CAIXA

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------	
				SET @VLR_REMOVER_PRANZO = 0
							
				SET @VLR_CUPOM_ANTES = (SELECT SUM(VALOR_TOTAL) FROM @TAB_CUPOM_CHEFF WHERE COD_LOJA = @COD_LOJA AND COD_RESTAURANTE = @COD_RESTAURANTE AND DATA = @DATA AND CUPOM = @CUPOM AND CAIXA = @CAIXA)			
				
				-- ##################################################################################################################
				--
				-- ##################################################################################################################
				DECLARE cursor_cupom_item CURSOR FOR 
					SELECT	
						COD_PRODUTO	
						,COD_PRODUTO_CHEFF	
						--,DES_PRODUTO_CHEFF
						--,DESCRICAO	
						,VLR_UNITARIO_PROD
						,PV_ATUAL
						,QTD_VENDA
						,VALOR_TOTAL
					FROM
						@TAB_CUPOM_CHEFF
					WHERE 1=1
						AND COD_LOJA = @COD_LOJA
						AND COD_RESTAURANTE = @COD_RESTAURANTE
						AND DATA = @DATA
						AND CUPOM = @CUPOM
						AND CAIXA = @CAIXA
					ORDER BY
						VLR_UNITARIO_PROD
							
				OPEN cursor_cupom_item
				FETCH NEXT FROM cursor_cupom_item 
				INTO @COD_PRODUTO,@COD_PRODUTO_CHEFF,@VLR_UNITARIO_PROD,@PV_ATUAL,@QTD_VENDA,@VALOR_TOTAL

				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- -------------------------------------------------------------------------------------
					-- -------------------------------------------------------------------------------------
						IF (@VLR_UNITARIO_PROD = 1 AND @COD_PRODUTO IN (1005483,1026054,1026056,686556,1030730,1030731,588744,491174,1032499) )
						BEGIN
							SET @VLR_REMOVER_PRANZO = @VLR_REMOVER_PRANZO + ((@PV_ATUAL-@VLR_UNITARIO_PROD)*@QTD_VENDA)
							
							UPDATE @TAB_CUPOM_CHEFF
							SET
								VALOR_TOTAL = (@PV_ATUAL*@QTD_VENDA)
							WHERE 1=1
								AND COD_LOJA = @COD_LOJA
								AND COD_RESTAURANTE = @COD_RESTAURANTE
								AND DATA = @DATA
								AND CUPOM = @CUPOM
								AND CAIXA = @CAIXA
								AND COD_PRODUTO_CHEFF = @COD_PRODUTO_CHEFF
						END
						
						
						IF (@COD_PRODUTO = 703192) --(1030103,1030105,1030095,1030099,1030106,1033638,1030102,1030098,1033637,703192,1030096,1030104)
						BEGIN
							UPDATE @TAB_CUPOM_CHEFF
							SET
								VALOR_TOTAL = VALOR_TOTAL - @VLR_REMOVER_PRANZO
							WHERE 1=1
								AND COD_LOJA = @COD_LOJA
								AND COD_RESTAURANTE = @COD_RESTAURANTE
								AND DATA = @DATA
								AND CUPOM = @CUPOM
								AND CAIXA = @CAIXA
								AND COD_PRODUTO_CHEFF = @COD_PRODUTO_CHEFF
						END	
					-- -------------------------------------------------------------------------------------
					-- -------------------------------------------------------------------------------------
					FETCH NEXT FROM cursor_cupom_item 
					INTO @COD_PRODUTO,@COD_PRODUTO_CHEFF,@VLR_UNITARIO_PROD,@PV_ATUAL,@QTD_VENDA,@VALOR_TOTAL
				END 
				CLOSE cursor_cupom_item;
				DEALLOCATE cursor_cupom_item;
				
				SET @VLR_CUPOM_DEPOIS = (SELECT SUM(VALOR_TOTAL) FROM @TAB_CUPOM_CHEFF WHERE COD_LOJA = @COD_LOJA AND COD_RESTAURANTE = @COD_RESTAURANTE AND DATA = @DATA AND CUPOM = @CUPOM AND CAIXA = @CAIXA)
				
				IF (@VLR_CUPOM_ANTES<>@VLR_CUPOM_DEPOIS)
				BEGIN
					PRINT CONVERT(VARCHAR,@COD_RESTAURANTE) + '_' + CONVERT(VARCHAR,@CUPOM) + ': ' + CONVERT(VARCHAR,@VLR_CUPOM_ANTES) + ' | ' + CONVERT(VARCHAR,@VLR_CUPOM_DEPOIS)
				END
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------
		FETCH NEXT FROM cursor_cupom 
		INTO @COD_LOJA,@COD_RESTAURANTE,@DATA,@CUPOM,@CAIXA
	END 
	CLOSE cursor_cupom;
	DEALLOCATE cursor_cupom;
		
	-- -------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------		
	--INSERT INTO BI.DBO.BI_VENDA_CUPOM_PRODUTO_RESTAURANTE
	--(
	--	COD_LOJA
	--	,COD_RESTAURANTE
	--	,DATA
	--	,CUPOM
	--	,CAIXA
	--	,COD_PRODUTO
	--	,COD_PRODUTO_CHEFF
	--	,VLR_UNITARIO_PROD
	--	,QTD_VENDA
	--	,VALOR_TOTAL
	--	,VLR_TOTAL_SEM_IMP
	--)	
	--SELECT SUM(VALOR_TOTAL) FROM @TAB_CUPOM_CHEFF
	SELECT	
		COD_LOJA
		,COD_RESTAURANTE
		,DATA
		,CUPOM
		,CAIXA
		,COD_PRODUTO
		,COD_PRODUTO_CHEFF		
		--,DES_PRODUTO_CHEFF
		--,DESCRICAO	
		,MAX(VLR_UNITARIO_PROD) as VLR_UNITARIO_PROD
		--,PV_ATUAL
		,SUM(QTD_VENDA) as QTD_VENDA
		,SUM(VALOR_TOTAL) AS VALOR_TOTAL
		,SUM(isnull(VLR_TOTAL_SEM_IMP,VALOR_TOTAL*0.968)) AS VLR_TOTAL_SEM_IMP
		,1
	FROM
		@TAB_CUPOM_CHEFF
	GROUP BY
		COD_LOJA
		,COD_RESTAURANTE
		,DATA
		,CUPOM
		,CAIXA
		,COD_PRODUTO
		,COD_PRODUTO_CHEFF	
	--ORDER BY
	--	COD_LOJA
	--	,COD_RESTAURANTE
	--	,DATA
	--	,CUPOM
	--	,CAIXA
	--	,COD_PRODUTO	
	--	,COD_PRODUTO_CHEFF	
	
	
	UNION ALL
	
	SELECT 
		VI.[COD_LOJA]
		,VI.COD_RESTAURANTE
		,CONVERT(DATE,VI.DATA) AS DATA
		,VI.CUPOM
		,VI.CAIXA
		,ISNULL(DEPARA.COD_PRODUTO,1) AS COD_PRODUTO
		,VI.COD_PRODUTO_CHEFF	
		--,VI.DES_PRODUTO_CHEFF
		--,CP.DESCRICAO	
		,MAX(VI.VALOR_UNITARIO) as  VLR_UNITARIO_PROD
		--,PV.PRECO AS PV_ATUAL
		,sum(VI.QUANTIDADE*ISNULL(VI.Quantidade_Dividida,1)) as QTD_VENDA
		,sum(VI.VALOR_TOTAL) as VLR_TOTAL_PRODUTO
		,sum(isnull(VI.ValorTotalSemImposto,VI.VALOR_TOTAL*0.968)) as VLR_TOTAL_SEM_IMP	
		,2
	FROM
		[DW].[dbo].[TAB_CHEFFSOLUTION_CUPOM_ITENS] AS VI
		LEFT JOIN @TAB_CUPOM_CHEFF AS TC
			ON 1=1
			AND VI.COD_LOJA = TC.COD_LOJA
			AND VI.COD_RESTAURANTE = TC.COD_RESTAURANTE
			AND VI.DATA = TC.DATA
			AND VI.CAIXA = TC.CAIXA
			AND VI.CUPOM = TC.CUPOM
			AND VI.COD_PRODUTO_CHEFF = TC.COD_PRODUTO_CHEFF
			AND VI.VALOR_UNITARIO = TC.VLR_UNITARIO_PROD
			AND VI.QUANTIDADE = TC.QTD_VENDA
		LEFT JOIN [BI].[dbo].[CAD_DE_PARA_CHEFF] AS DEPARA
			ON 1=1
			AND VI.COD_PRODUTO_CHEFF = DEPARA.COD_PRODUTO_CHEFF
			AND VI.COD_RESTAURANTE = DEPARA.COD_RESTAURANTE
		LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON DEPARA.COD_PRODUTO = CP.COD_PRODUTO
		LEFT JOIN @TAB_PV_ATUAL AS PV
			ON 1=1
			AND DEPARA.COD_PRODUTO = PV.COD_PRODUTO
			--AND DEPARA.COD_RESTAURANTE = PV.COD_RESTAURANTE
	WHERE 1=1
		AND TC.CUPOM IS NULL
		AND CONVERT(DATE,VI.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		AND VI.COD_LOJA IN (33)
		AND VI.CUPOM = 63157
			AND VI.COD_RESTAURANTE = 106
	GROUP BY
		VI.[COD_LOJA]
		,VI.COD_RESTAURANTE
		,CONVERT(DATE,VI.DATA)
		,VI.CUPOM
		,VI.CAIXA
		,ISNULL(DEPARA.COD_PRODUTO,1)
		,VI.COD_PRODUTO_CHEFF	