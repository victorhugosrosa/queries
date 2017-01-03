	-- ##############################################################################################################################################################################################
	-- EXPANDE CLUSTER LOJAS
	-- ##############################################################################################################################################################################################

	SET NOCOUNT ON;
	TRUNCATE TABLE [BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS_EXPANDIDO]

	UPDATE [BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS] SET COD_LOJA = REPLACE(COD_LOJA,'''','') WHERE CONVERT(DATE,[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE());

	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- CURSORES
	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @COD_USUARIO AS INT
	DECLARE @COD_LOJA_FULL AS VARCHAR(50)
	DECLARE @COD_PRODUTO AS VARCHAR(50)
	DECLARE @DTA_INI AS DATE
	DECLARE @DTA_FIM AS DATE
	DECLARE @DESCRICAO AS VARCHAR(50)
	DECLARE @VALOR AS NUMERIC(8,2)
	DECLARE @ARREDONDAR AS INT
	DECLARE @APLICAR_SIMILAR AS INT
	DECLARE @DTA_GRAVACAO AS DATE
	DECLARE @COD_LOJA AS VARCHAR(50)

	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- (C0)
	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO [BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS_EXPANDIDO]
		SELECT
			[COD_USUARIO]
			,CL.COD_LOJA
			,[COD_PRODUTO]
			,[DTA_INI]
			,[DTA_FIM]
			,[DESCRICAO]
			,[VALOR]
			,[ARREDONDAR]
			,[APLICAR_SIMILAR]
			,[DTA_GRAVACAO]		
		FROM
			[BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS] AS PRECO
				INNER JOIN [BI].DBO.[BI_CLUSTER_LOJAS] AS CL ON (PRECO.COD_LOJA = CL.CLUSTER)	
		where 1 = 1
			AND PRECO.DTA_GRAVACAO >= CONVERT(DATE,GETDATE())
			--AND PRECO.COD_USUARIO = 7774
			--AND PRECO.COD_PRODUTO = 4886
			AND PRECO.COD_LOJA NOT like '%,%'
			AND PRECO.COD_LOJA NOT like '%-%'
			AND ISNUMERIC(PRECO.COD_LOJA) = 0;

	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- (1)
	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO [BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS_EXPANDIDO]
		SELECT
			[COD_USUARIO]
			,PRECO.COD_LOJA
			,[COD_PRODUTO]
			,[DTA_INI]
			,[DTA_FIM]
			,[DESCRICAO]
			,[VALOR]
			,[ARREDONDAR]
			,[APLICAR_SIMILAR]
			,[DTA_GRAVACAO]		
		FROM
			[BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS] AS PRECO
		where 1 = 1
			AND PRECO.DTA_GRAVACAO >= CONVERT(DATE,GETDATE())
			--AND PRECO.COD_USUARIO = 7774
			--AND PRECO.COD_LOJA = '2'
			--AND PRECO.COD_PRODUTO = 4886
			AND PRECO.COD_LOJA NOT like '%,%'
			AND PRECO.COD_LOJA NOT like '%-%'
			AND ISNUMERIC(PRECO.COD_LOJA) = 1;

	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- (1,2,3,4,5,6,7)
	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE db_cursor_1 CURSOR FOR  
		SELECT
			[COD_USUARIO]
			,[COD_LOJA]
			,[COD_PRODUTO]
			,[DTA_INI]
			,[DTA_FIM]
			,[DESCRICAO]
			,[VALOR]
			,[ARREDONDAR]
			,[APLICAR_SIMILAR]
			,[DTA_GRAVACAO]
		FROM
			[BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS]
		where 1 = 1
			AND DTA_GRAVACAO >= CONVERT(DATE,GETDATE())
			AND COD_LOJA like '%,%'
			


	OPEN db_cursor_1   
	FETCH NEXT FROM db_cursor_1 INTO @COD_USUARIO, @COD_LOJA_FULL, @COD_PRODUTO, @DTA_INI, @DTA_FIM, @DESCRICAO, @VALOR, @ARREDONDAR, @APLICAR_SIMILAR, @DTA_GRAVACAO

	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		SET @COD_LOJA_FULL = REPLACE(@COD_LOJA_FULL,'''','')

		--SET @COD_LOJA_TRATADA = SUBSTRING(@COD_LOJA_TRATADA,0,2)
		--SET @COD_LOJA_TRATADA = dbo.fnSplit(@COD_LOJA_TRATADA,',')
		
		
		--##########################################################################################
			DECLARE db_cursor_2 CURSOR FOR  
				(select ITEM from [dbo].[fnSplit](@COD_LOJA_FULL,','))
			
			OPEN db_cursor_2   
			FETCH NEXT FROM db_cursor_2 INTO @COD_LOJA   

			WHILE @@FETCH_STATUS = 0   
			BEGIN  
				
				
				
				INSERT INTO [BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS_EXPANDIDO] VALUES
				(@COD_USUARIO, @COD_LOJA, @COD_PRODUTO, @DTA_INI, @DTA_FIM, @DESCRICAO, @VALOR, @ARREDONDAR, @APLICAR_SIMILAR, @DTA_GRAVACAO)
				

				
				FETCH NEXT FROM db_cursor_2 INTO @COD_LOJA   
			END   

			CLOSE db_cursor_2  
			DEALLOCATE db_cursor_2
		--##########################################################################################
		--PRINT @COD_LOJA_TRATADA

		FETCH NEXT FROM db_cursor_1 INTO @COD_USUARIO, @COD_LOJA_FULL, @COD_PRODUTO, @DTA_INI, @DTA_FIM, @DESCRICAO, @VALOR, @ARREDONDAR, @APLICAR_SIMILAR, @DTA_GRAVACAO 
	END   

	CLOSE db_cursor_1   
	DEALLOCATE db_cursor_1

	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- XX-2
	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE db_cursor_3 CURSOR FOR  
		SELECT TOP 1
			[COD_USUARIO]
			,[COD_LOJA]
			,[COD_PRODUTO]
			,[DTA_INI]
			,[DTA_FIM]
			,[DESCRICAO]
			,[VALOR]
			,[ARREDONDAR]
			,[APLICAR_SIMILAR]
			,[DTA_GRAVACAO]
		FROM
			[BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS]
		where 1 = 1
			AND DTA_GRAVACAO >= CONVERT(DATE,GETDATE())
			AND COD_LOJA like '%-%'


	OPEN db_cursor_3   
	FETCH NEXT FROM db_cursor_3 INTO @COD_USUARIO, @COD_LOJA_FULL, @COD_PRODUTO, @DTA_INI, @DTA_FIM, @DESCRICAO, @VALOR, @ARREDONDAR, @APLICAR_SIMILAR, @DTA_GRAVACAO

	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		SET @COD_LOJA_FULL = REPLACE(@COD_LOJA_FULL,'''','')

		--SET @COD_LOJA_TRATADA = SUBSTRING(@COD_LOJA_TRATADA,0,2)
		--SET @COD_LOJA_TRATADA = dbo.fnSplit(@COD_LOJA_TRATADA,',')

		--##########################################################################################		
			DECLARE db_cursor_4 CURSOR FOR  
				(select ITEM from [dbo].[fnSplit](@COD_LOJA_FULL,'-'))
			
			OPEN db_cursor_4   
			FETCH NEXT FROM db_cursor_4 INTO @COD_LOJA   

			WHILE @@FETCH_STATUS = 0   
			BEGIN  			
				DECLARE @COD_LOJA_PRECO_OLD AS VARCHAR(20)
		
				DECLARE @TAB_LOJAS_EXCLUIDAS AS TABLE
				(
					COD_LOJA_PRECO VARCHAR(10)
					,COD_LOJA_EXCLUIDA INT
				);

				IF ISNUMERIC(@COD_LOJA) = 0
				BEGIN
					INSERT INTO @TAB_LOJAS_EXCLUIDAS VALUES (@COD_LOJA,NULL)
					SET @COD_LOJA_PRECO_OLD = @COD_LOJA
				END
				
				IF ISNUMERIC(@COD_LOJA) = 1
				BEGIN
					UPDATE @TAB_LOJAS_EXCLUIDAS SET COD_LOJA_EXCLUIDA = @COD_LOJA WHERE COD_LOJA_PRECO = @COD_LOJA_PRECO_OLD AND COD_LOJA_EXCLUIDA IS NULL
				END
				
				FETCH NEXT FROM db_cursor_4 INTO @COD_LOJA   
			END   

			CLOSE db_cursor_4  
			DEALLOCATE db_cursor_4
		--##########################################################################################
		
		INSERT INTO [BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS_EXPANDIDO]
		SELECT @COD_USUARIO, P.COD_LOJA, @COD_PRODUTO, @DTA_INI, @DTA_FIM, @DESCRICAO, @VALOR, @ARREDONDAR, @APLICAR_SIMILAR, @DTA_GRAVACAO  FROM @TAB_LOJAS_EXCLUIDAS AS E INNER JOIN [BI].DBO.[BI_CLUSTER_LOJAS] AS P ON (E.COD_LOJA_PRECO = P.CLUSTER and E.COD_LOJA_EXCLUIDA <> P.COD_LOJA)	


		FETCH NEXT FROM db_cursor_3 INTO @COD_USUARIO, @COD_LOJA_FULL, @COD_PRODUTO, @DTA_INI, @DTA_FIM, @DESCRICAO, @VALOR, @ARREDONDAR, @APLICAR_SIMILAR, @DTA_GRAVACAO 
	END   

	CLOSE db_cursor_3   
	DEALLOCATE db_cursor_3

	SET NOCOUNT OFF;

SELECT * FROM [BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS_EXPANDIDO]