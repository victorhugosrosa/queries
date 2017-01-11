-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXTERNAL VARIABLES
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @packRoundLimit AS NUMERIC(18,2) = 0.9
	
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INTERNAL VARIABLES
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------	
	DECLARE @COD_PRODUTO AS INT;
	DECLARE @QTD_PEDIDO AS NUMERIC(18,3);
	DECLARE @COD_LOJA AS INT;
	DECLARE @QTD_PEDIDO_RMV AS NUMERIC(18,3);
	DECLARE @QTD_PEDIDO_ADD AS NUMERIC(18,3);	
	
	
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INITIAL TABLE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_BASE_PICKING AS TABLE
	(
		ID_SIMULADO INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,COD_FORNECEDOR INT
		,FLG_PICKING_UN INT
		,QTD_PEDIDO NUMERIC(18,3)
		,QTD_EMB_FORN NUMERIC(18,3)
		,QTD_MULTIPLO_FORN NUMERIC(18,3)
		,QTD_PEDIDO_RMV NUMERIC(18,3)
		,QTD_PEDIDO_ADD NUMERIC(18,3)
		,QTD_PEDIDO_NEW NUMERIC(18,3)
	)

	INSERT @TAB_BASE_PICKING
		SELECT
			P.ID_SIMULADO
			,P.COD_LOJA
			,P.COD_PRODUTO
			,P.COD_FORNECEDOR
			,P.FLG_COMPRA as FLG_PICKING_UN
			,P.QTD_EMBALAGEM as QTD_PEDIDO
			,P.QTD_EMB_ORG as QTD_EMB_FORN
			,P.VLR_MULTIPLO	 as QTD_MULTIPLO_FORN
			,NULL AS QTD_PEDIDO_RMV
			,NULL AS QTD_PEDIDO_ADD
			,NULL AS QTD_PEDIDO_NEW
		FROM
			[BI].[DBO].[COMPRAS_PEDIDOS] AS P
			INNER JOIN BI.DBO.BI_CAD_PRODUTO AS CP
				ON P.COD_PRODUTO = CP.COD_PRODUTO
			INNER JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF
				ON P.COD_FORNECEDOR = CF.COD_FORNECEDOR
			LEFT JOIN [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A
				ON P.ID_AGENDA = A.ID
			LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF2
				ON A.COD_FORNECEDOR = CF2.COD_FORNECEDOR
		WHERE 1=1
			AND P.FLG_PICKING_UN = 1
			AND P.QTD_EMBALAGEM > 0
			AND P.ID_SIMULADO = 17787--17703
			AND CONVERT(DATE,P.DATA) >= CONVERT(DATE,GETDATE()) --TEMPORARIO

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- AUXILIAR TABLE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_CHECK_QTD AS TABLE
	(
		COD_PRODUTO INT		
		,QTD_PEDIDO NUMERIC(18,3)
		,QTD_EMB_FORN NUMERIC(18,3)
		,QTD_MULTIPLO_FORN NUMERIC(18,3)
		
		,FLG_QTD_EMB INT
		,MOD_QTD_EMB NUMERIC(18,3)
		,DIV_QTD_EMB NUMERIC(18,3)
		
		,FLG_QTD_MULTIPLO INT
		,MOD_VLR_MULTIPLO NUMERIC(18,3)
		,DIV_VLR_MULTIPLO NUMERIC(18,3)	
		
		,FLG_ARREDONDAR_PED INT
		,QTD_PEDIDO_RMV NUMERIC(18,3)
		,QTD_PEDIDO_ADD NUMERIC(18,3)
	)
	INSERT INTO @TAB_CHECK_QTD
		SELECT
			COD_PRODUTO
			,SUM(QTD_PEDIDO) AS SUM_QTD_PEDIDO
			,QTD_EMB_FORN
			,QTD_MULTIPLO_FORN			
			,NULL AS FLG_QTD_EMB
			,SUM(QTD_PEDIDO) % QTD_EMB_FORN AS MOD_QTD_EMB
			,SUM(QTD_PEDIDO) / QTD_EMB_FORN AS DIV_QTD_EMB
			,NULL AS FLG_QTD_MULTIPLO
			,SUM(QTD_PEDIDO) % QTD_MULTIPLO_FORN AS MOD_VLR_MULTIPLO
			,SUM(QTD_PEDIDO) / QTD_MULTIPLO_FORN AS DIV_VLR_MULTIPLO	
			,NULL AS FLG_ARREDONDAR_PED
			,NULL AS QTD_PEDIDO_RMV
			,NULL AS QTD_PEDIDO_ADD
		FROM
			@TAB_BASE_PICKING
		GROUP BY
			COD_PRODUTO
			,QTD_EMB_FORN
			,QTD_MULTIPLO_FORN	

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARCAR SE VAI OU NÃO ARREDONDAR E DEFINIR QUANTIDADES PARA ADD OU RMV
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- ####################################################################################################################################
	-- VALORES < DO QUE UMA CAIXA
	-- ####################################################################################################################################		
		-- ------------------------------------------------------------------------------------------------------------
		-- MARCANDO SE ARREDONDARÁ OU NÃO E QUAL VARIAVEL USARA (EMBALAGEM/MULIPLO)
		-- ------------------------------------------------------------------------------------------------------------
			-- ------------------
			-- FLG_QTD_EMB
			-- ------------------
			UPDATE TCQ
			SET
				FLG_QTD_EMB = 1
				,FLG_ARREDONDAR_PED = (CASE WHEN DIV_QTD_EMB < @packRoundLimit THEN 0 ELSE 1 END)
			FROM
				@TAB_CHECK_QTD as TCQ
			WHERE 1=1
				AND QTD_EMB_FORN <> 1
				AND QTD_PEDIDO % QTD_EMB_FORN <> 0
				AND DIV_QTD_EMB < 1
			
			-- ------------------
			-- FLG_QTD_MULTIPLO
			-- ------------------
			UPDATE TCQ
			SET
				FLG_QTD_MULTIPLO = 1
				,FLG_ARREDONDAR_PED = (CASE WHEN DIV_VLR_MULTIPLO < @packRoundLimit THEN 0 ELSE 1 END)
			FROM
				@TAB_CHECK_QTD as TCQ
			WHERE 1=1
				AND QTD_EMB_FORN = 1
				AND QTD_MULTIPLO_FORN <> 1
				AND QTD_PEDIDO % QTD_MULTIPLO_FORN <> 0
				AND DIV_VLR_MULTIPLO < 1		
		
		-- ------------------------------------------------------------------------------------------------------------
		-- DEFININDO QTD ADD/RMV (GERAL, A SEPARAÇÃO POR LOJA É NO LOOP)
		-- ------------------------------------------------------------------------------------------------------------
			-- ------------------
			-- QTD_PEDIDO_RMV
			-- ------------------
			UPDATE TBP
			SET
				TBP.QTD_PEDIDO_RMV = TBP.QTD_PEDIDO
			FROM
				@TAB_BASE_PICKING AS TBP
				INNER JOIN @TAB_CHECK_QTD as TCQ
					ON TBP.COD_PRODUTO = TCQ.COD_PRODUTO
			WHERE 1=1
				AND FLG_ARREDONDAR_PED = 0
				AND (DIV_QTD_EMB < 1 or DIV_VLR_MULTIPLO < 1)
			
			-- ------------------
			-- QTD_PEDIDO_ADD
			-- ------------------				
				-- ------------------
				-- FLG_QTD_EMB
				-- ------------------
				UPDATE TCQ
				SET
					TCQ.QTD_PEDIDO_ADD = TCQ.QTD_EMB_FORN - TCQ.QTD_PEDIDO
				FROM
					@TAB_CHECK_QTD as TCQ
				WHERE 1=1
					AND FLG_QTD_EMB = 1
					AND FLG_ARREDONDAR_PED = 1
					AND DIV_QTD_EMB < 1
				
				-- ------------------
				-- FLG_QTD_MULTIPLO
				-- ------------------
				UPDATE TCQ
				SET
					TCQ.QTD_PEDIDO_ADD = TCQ.QTD_MULTIPLO_FORN - TCQ.QTD_PEDIDO
				FROM
					@TAB_CHECK_QTD as TCQ
				WHERE 1=1
					AND FLG_QTD_MULTIPLO = 1
					AND FLG_ARREDONDAR_PED = 1
					AND DIV_VLR_MULTIPLO < 1
			
		
	-- ####################################################################################################################################
	-- VALORES > DO QUE UMA CAIXA --select 27.0 % 12.0 as mod, 27.0 / 12.0 as div, (27.0 % 12.0) / 12.0 as mod_div
	-- ####################################################################################################################################
		-- ------------------------------------------------------------------------------------------------------------
		-- MARCANDO SE ARREDONDARÁ OU NÃO E QUAL VARIAVEL USARA (EMBALAGEM/MULIPLO)
		-- ------------------------------------------------------------------------------------------------------------
			-- ------------------
			-- FLG_QTD_EMB
			-- ------------------
			UPDATE TCQ
			SET
				FLG_QTD_EMB = 1
				,FLG_ARREDONDAR_PED = (CASE WHEN (QTD_PEDIDO % QTD_EMB_FORN) / QTD_EMB_FORN  < @packRoundLimit THEN 0 ELSE 1 END)
			FROM
				@TAB_CHECK_QTD as TCQ
			WHERE 1=1
				AND QTD_EMB_FORN <> 1
				AND QTD_PEDIDO % QTD_EMB_FORN <> 0
				AND DIV_QTD_EMB > 1
		
			-- ------------------
			-- FLG_QTD_MULTIPLO
			-- ------------------
			UPDATE TCQ
			SET
				FLG_QTD_MULTIPLO = 1
				,FLG_ARREDONDAR_PED = (CASE WHEN (QTD_PEDIDO % QTD_MULTIPLO_FORN) / QTD_MULTIPLO_FORN  < @packRoundLimit THEN 0 ELSE 1 END)
			FROM
				@TAB_CHECK_QTD as TCQ
			WHERE 1=1
				AND QTD_EMB_FORN = 1
				AND QTD_MULTIPLO_FORN <> 1
				AND QTD_PEDIDO % QTD_MULTIPLO_FORN <> 0
				AND DIV_VLR_MULTIPLO > 1
	
		-- ------------------------------------------------------------------------------------------------------------
		-- DEFININDO QTD ADD/RMV (GERAL, A SEPARAÇÃO POR LOJA É NO LOOP)
		-- ------------------------------------------------------------------------------------------------------------
			-- ------------------
			-- QTD_PEDIDO_RMV
			-- ------------------
				-- ------------------
				-- FLG_QTD_EMB
				-- ------------------
				UPDATE TCQ
				SET
					TCQ.QTD_PEDIDO_RMV = (QTD_PEDIDO % QTD_EMB_FORN)
				FROM
					@TAB_CHECK_QTD as TCQ
				WHERE 1=1
					AND FLG_QTD_EMB = 1
					AND FLG_ARREDONDAR_PED = 0
					AND DIV_QTD_EMB > 1
				
				-- ------------------
				-- FLG_QTD_MULTIPLO
				-- ------------------
				UPDATE TCQ
				SET
					TCQ.QTD_PEDIDO_RMV = (QTD_PEDIDO % QTD_MULTIPLO_FORN)
				FROM
					@TAB_CHECK_QTD as TCQ
				WHERE 1=1
					AND FLG_QTD_MULTIPLO = 1
					AND FLG_ARREDONDAR_PED = 0
					AND DIV_VLR_MULTIPLO > 1
			
			-- ------------------
			-- QTD_PEDIDO_ADD
			-- ------------------			
				-- ------------------
				-- FLG_QTD_EMB
				-- ------------------
				UPDATE TCQ
				SET
					TCQ.QTD_PEDIDO_ADD = (QTD_PEDIDO % QTD_EMB_FORN)
				FROM
					@TAB_CHECK_QTD as TCQ
				WHERE 1=1
					AND FLG_QTD_EMB = 1
					AND FLG_ARREDONDAR_PED = 1
					AND DIV_QTD_EMB > 1
				
				-- ------------------
				-- FLG_QTD_MULTIPLO
				-- ------------------
				UPDATE TCQ
				SET
					TCQ.QTD_PEDIDO_ADD = (QTD_PEDIDO % QTD_MULTIPLO_FORN)
				FROM
					@TAB_CHECK_QTD as TCQ
				WHERE 1=1
					AND FLG_QTD_MULTIPLO = 1
					AND FLG_ARREDONDAR_PED = 1
					AND DIV_VLR_MULTIPLO > 1
				
				
	-- ####################################################################################################################################
	-- MANTER PEDIDOS PARA QUEM JÁ ESTAVA NA QTD CORRETA
	-- ####################################################################################################################################
	UPDATE TBP
	SET
		TBP.QTD_PEDIDO_RMV = 0
		,TBP.QTD_PEDIDO_ADD = 0
	FROM
		@TAB_BASE_PICKING AS TBP
		INNER JOIN @TAB_CHECK_QTD as TCQ
			ON TBP.COD_PRODUTO = TCQ.COD_PRODUTO
	WHERE 1=1
		AND FLG_ARREDONDAR_PED IS NULL
		
	-- ####################################################################################################################################
	-- LOOPs
	-- ####################################################################################################################################
		
	-- ------------------
	-- ADD-LOOP
	-- ------------------	
	DECLARE CURSOR_ADD_TAB_CHECK_QTD CURSOR FOR 
		SELECT
			COD_PRODUTO
			,QTD_PEDIDO_ADD
		FROM
			@TAB_CHECK_QTD
		WHERE 1=1
			AND QTD_PEDIDO_ADD > 0
		
	OPEN CURSOR_ADD_TAB_CHECK_QTD
	FETCH NEXT FROM CURSOR_ADD_TAB_CHECK_QTD 
	INTO @COD_PRODUTO, @QTD_PEDIDO_ADD

	WHILE @@FETCH_STATUS = 0
	BEGIN				
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------	
				PRINT @COD_PRODUTO
				PRINT @QTD_PEDIDO_ADD
				
				WHILE @QTD_PEDIDO_ADD > 0
				BEGIN
				
					DECLARE CURSOR_ADD_TAB_BASE_PICKING CURSOR FOR 
						SELECT
							COD_PRODUTO
							,QTD_PEDIDO
							,COD_LOJA
						FROM 
							@TAB_BASE_PICKING
						WHERE 1=1
							AND COD_PRODUTO = @COD_PRODUTO	
						ORDER BY
							QTD_PEDIDO DESC
							
					OPEN CURSOR_ADD_TAB_BASE_PICKING
					FETCH NEXT FROM CURSOR_ADD_TAB_BASE_PICKING 
					INTO @COD_PRODUTO, @QTD_PEDIDO, @COD_LOJA

					WHILE @@FETCH_STATUS = 0
					BEGIN
						-- -------------------------------------------------------------------------------------
						-- -------------------------------------------------------------------------------------
							IF @QTD_PEDIDO_ADD > 0
							BEGIN
								UPDATE @TAB_BASE_PICKING SET QTD_PEDIDO_ADD = QTD_PEDIDO_ADD + 1
								WHERE 1=1
									AND COD_PRODUTO = @COD_PRODUTO	
									AND COD_LOJA = @COD_LOJA	
							END
							SET @QTD_PEDIDO_ADD = @QTD_PEDIDO_ADD - 1								
						-- -------------------------------------------------------------------------------------
						-- -------------------------------------------------------------------------------------
						FETCH NEXT FROM CURSOR_ADD_TAB_BASE_PICKING 
						INTO @COD_PRODUTO, @QTD_PEDIDO, @COD_LOJA
					END 
					CLOSE CURSOR_ADD_TAB_BASE_PICKING;
					DEALLOCATE CURSOR_ADD_TAB_BASE_PICKING;
					
				END
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------				
		FETCH NEXT FROM CURSOR_ADD_TAB_CHECK_QTD 
		INTO @COD_PRODUTO, @QTD_PEDIDO_ADD
	END 
	CLOSE CURSOR_ADD_TAB_CHECK_QTD;
	DEALLOCATE CURSOR_ADD_TAB_CHECK_QTD;
	
	
	-- ------------------
	-- RMV-LOOP
	-- ------------------	
	DECLARE CURSOR_RMV_TAB_CHECK_QTD CURSOR FOR 
		SELECT
			COD_PRODUTO
			,QTD_PEDIDO_RMV
		FROM
			@TAB_CHECK_QTD
		WHERE 1=1
			AND QTD_PEDIDO_RMV > 0
		
	OPEN CURSOR_RMV_TAB_CHECK_QTD
	FETCH NEXT FROM CURSOR_RMV_TAB_CHECK_QTD 
	INTO @COD_PRODUTO, @QTD_PEDIDO_RMV

	WHILE @@FETCH_STATUS = 0
	BEGIN				
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------	
				PRINT @COD_PRODUTO
				PRINT @QTD_PEDIDO_RMV
				
				WHILE @QTD_PEDIDO_RMV > 0
				BEGIN
				
					DECLARE CURSOR_RMV_TAB_BASE_PICKING CURSOR FOR 
						SELECT
							COD_PRODUTO
							,QTD_PEDIDO
							,COD_LOJA
						FROM 
							@TAB_BASE_PICKING
						WHERE 1=1
							AND COD_PRODUTO = @COD_PRODUTO	
						ORDER BY
							QTD_PEDIDO ASC
							
					OPEN CURSOR_RMV_TAB_BASE_PICKING
					FETCH NEXT FROM CURSOR_RMV_TAB_BASE_PICKING 
					INTO @COD_PRODUTO, @QTD_PEDIDO, @COD_LOJA

					WHILE @@FETCH_STATUS = 0
					BEGIN
						-- -------------------------------------------------------------------------------------
						-- -------------------------------------------------------------------------------------
							IF @QTD_PEDIDO_RMV > 0
							BEGIN
								UPDATE @TAB_BASE_PICKING SET QTD_PEDIDO_RMV = QTD_PEDIDO_RMV + 1
								WHERE 1=1
									AND COD_PRODUTO = @COD_PRODUTO	
									AND COD_LOJA = @COD_LOJA	
							END
							SET @QTD_PEDIDO_RMV = @QTD_PEDIDO_RMV - 1								
						-- -------------------------------------------------------------------------------------
						-- -------------------------------------------------------------------------------------
						FETCH NEXT FROM CURSOR_RMV_TAB_BASE_PICKING 
						INTO @COD_PRODUTO, @QTD_PEDIDO, @COD_LOJA
					END 
					CLOSE CURSOR_RMV_TAB_BASE_PICKING;
					DEALLOCATE CURSOR_RMV_TAB_BASE_PICKING;
					
				END
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------				
		FETCH NEXT FROM CURSOR_RMV_TAB_CHECK_QTD 
		INTO @COD_PRODUTO, @QTD_PEDIDO_ADD
	END 
	CLOSE CURSOR_RMV_TAB_CHECK_QTD;
	DEALLOCATE CURSOR_RMV_TAB_CHECK_QTD;
	
	-- ####################################################################################################################################
	-- updating NEW_QTD_PEDIDO
	-- ####################################################################################################################################
	UPDATE TBP
	SET
		TBP.QTD_PEDIDO_NEW = TBP.QTD_PEDIDO - ISNULL(TBP.QTD_PEDIDO_RMV,0) + ISNULL(TBP.QTD_PEDIDO_ADD,0)
	FROM
		@TAB_BASE_PICKING AS TBP
		INNER JOIN @TAB_CHECK_QTD as TCQ
			ON TBP.COD_PRODUTO = TCQ.COD_PRODUTO
	WHERE 1=1
		--AND FLG_ARREDONDAR_PED = 0	
	
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MONTAR UPDATE NA COMPRAS_PEDIDOS
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT *
	--UPDATE P
	--SET
	--	P.QTD_EMBALAGEM = TBP.QTD_PEDIDO_NEW
	FROM
		@TAB_BASE_PICKING AS TBP
		INNER JOIN BI.dbo.COMPRAS_PEDIDOS as P
			ON 1=1
			AND TBP.ID_SIMULADO = P.ID_SIMULADO
			AND TBP.COD_LOJA = P.COD_LOJA
			AND TBP.COD_PRODUTO = P.COD_PRODUTO
	WHERE 1=1
		AND TBP.QTD_PEDIDO_NEW <> TBP.QTD_PEDIDO
	
	
	SELECT *
	FROM
		@TAB_BASE_PICKING AS TBP
		INNER JOIN @TAB_CHECK_QTD as TCQ
			ON TBP.COD_PRODUTO = TCQ.COD_PRODUTO
	WHERE 1=1
		AND FLG_QTD_EMB = 1

/*
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TESTING
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- --------------------------------------------------
	-- FLG_QTD_MULTIPLO = 1
	-- --------------------------------------------------
	SELECT
		COD_PRODUTO
		,QTD_PEDIDO
		,QTD_EMB_FORN
		,QTD_MULTIPLO_FORN
		,MOD_VLR_MULTIPLO
		,DIV_VLR_MULTIPLO
		,FLG_ARREDONDAR_PED
	FROM
		@TAB_CHECK_QTD as TCQ
	WHERE 1=1
		AND FLG_QTD_MULTIPLO = 1
	
	-- --------------------------------------------------
	-- FLG_QTD_EMB = 1
	-- --------------------------------------------------
	SELECT
		COD_PRODUTO
		,QTD_PEDIDO
		,QTD_EMB_FORN
		,QTD_MULTIPLO_FORN
		,MOD_QTD_EMB
		,DIV_QTD_EMB
		,FLG_ARREDONDAR_PED
		,QTD_PEDIDO-QTD_EMB_FORN
	FROM
		@TAB_CHECK_QTD as TCQ
	WHERE 1=1
		AND FLG_QTD_EMB = 1
	
	
	
*/