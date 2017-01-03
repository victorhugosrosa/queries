	-- --------------------------------------------------------------------------------------------------------------------------
	--
	-- --------------------------------------------------------------------------------------------------------------------------
		DECLARE @DATA_INI DATE = GETDATE()-90
		DECLARE @DATA_FIM DATE = GETDATE()

		DECLARE @ID_AGENDA INT = 757
		DECLARE @ARRAY_LOJAS VARCHAR(80) = '1,2,3,6,7,9,10,12,13,17,18,19,20,21,30,31,5'
		
		DECLARE @COD_FORNECEDOR INT
		DECLARE @COD_FORNECEDOR_PEDIDO INT
		DECLARE @DIAS_EXTRAS INT
	
	-- --------------------------------------------------------------------------------------------------------------------------
	--
	-- --------------------------------------------------------------------------------------------------------------------------
		SELECT
			@COD_FORNECEDOR = COD_FORNECEDOR
			,@COD_FORNECEDOR_PEDIDO = (CASE WHEN FLG_CENTRALIZADO = 1 THEN 18055 ELSE COD_FORNECEDOR END)
			,@DIAS_EXTRAS = (CASE WHEN FLG_CENTRALIZADO = 1 THEN 5 ELSE 7 END)
		FROM COMPRAS_AGENDA_PEDIDO_AUTO
		WHERE 1=1
			AND ID = @ID_AGENDA
			
	-- --------------------------------------------------------------------------------------------------------------------------
	--
	-- --------------------------------------------------------------------------------------------------------------------------	
		DECLARE @TEMP_PEDIDOS_ABERTOS_BI AS TABLE
		(
			COD_LOJA INT
			,COD_FORNECEDOR INT
			,COD_FORNECEDOR_PEDIDO INT
			,COD_PEDIDO INT
			,DTA_EMISSAO DATE
			,DTA_ENTREGA DATE
			,DATA_ENTREGA_EXTRA DATE			
		)
		INSERT INTO @TEMP_PEDIDOS_ABERTOS_BI
			SELECT DISTINCT
				P.COD_LOJA
				,A.COD_FORNECEDOR
				,P.[COD_FORNECEDOR] as [COD_FORNECEDOR_PEDIDO]	
				,P.COD_PEDIDO
				,CONVERT(DATE,P.DATA) AS DATA_EMISSAO
				,CONVERT(DATE,P.DATA_ENTREGA) AS DATA_ENTREGA
				,CONVERT(DATE,DATEADD(D,@DIAS_EXTRAS,P.DATA_ENTREGA)) AS DATA_ENTREGA_EXTRA
			FROM
				[BI].[DBO].[COMPRAS_PEDIDOS] AS P
				LEFT JOIN [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A
					ON P.ID_AGENDA = A.ID
			WHERE 1=1
				AND CONVERT(DATE,DATA) between CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
				AND P.COD_PEDIDO IS NOT NULL
				AND P.QTD_EMBALAGEM > 0
				AND
				(
					P.FLG_ERRO_FORNECEDOR_PRINCIPAL = 0
					AND P.FLG_ERRO_TIPO_ABASTECIMENTO = 0
					AND P.FLG_ERRO_SEM_CUSTO = 0
					AND P.FLG_COMPRA = 1
					AND P.FLG_BLOQUEADO_SUPPLY IS NULL
					AND P.FLG_ERRO_CONVERSAO_UNIDADE IS NULL
					AND P.FLG_ERRO_SEM_REFERENCIA IS NULL
				)	
				AND A.COD_FORNECEDOR = @COD_FORNECEDOR
				AND P.COD_LOJA IN ( select ITEM from [dbo].[fnSplit](@ARRAY_LOJAS,',') )
				AND CONVERT(DATE,DATEADD(D,@DIAS_EXTRAS,P.DATA_ENTREGA)) >= CONVERT(DATE,GETDATE())
				
	-- --------------------------------------------------------------------------------------------------------------------------
	--
	-- --------------------------------------------------------------------------------------------------------------------------
		DECLARE @TEMP_PEDIDOS_ABERTOS_ZEUS AS TABLE
		(
			COD_LOJA INT
			,COD_FORNECEDOR INT
			,DTA_EMISSAO DATE
			,DTA_ENTREGA DATE
			,COD_PEDIDO INT
			,COD_PRODUTO INT
			,QTD_PEDIDO NUMERIC(18,2)
			,QTD_RECEBIDA NUMERIC(18,2)
		)
		INSERT INTO @TEMP_PEDIDOS_ABERTOS_ZEUS
			SELECT	
				P.COD_LOJA
				,convert(int,P.COD_PARCEIRO) as COD_FORNECEDOR
				,CONVERT(DATE,DTA_EMISSAO) as DTA_EMISSAO
				,CONVERT(DATE,DTA_ENTREGA) as DTA_ENTREGA
				,P.NUM_PEDIDO
				,PP.COD_PRODUTO
				,SUM(PP.QTD_PEDIDO) AS QTD_PEDIDO
				,SUM(PP.QTD_RECEBIDA) AS QTD_RECEBIDA		
			FROM
				[192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO] AS P
				INNER JOIN [192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO_PRODUTO] AS PP
					ON 1=1
					and P.NUM_PEDIDO = PP.NUM_PEDIDO
					AND P.COD_LOJA = PP.COD_LOJA
					AND P.COD_PARCEIRO = PP.COD_PARCEIRO
			WHERE 1 = 1
				AND CONVERT(DATE,P.DTA_EMISSAO) between CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
				AND P.COD_PARCEIRO = @COD_FORNECEDOR_PEDIDO
				AND PP.QTD_EMBALAGEM <> 0
				--AND P.COD_LOJA = 3
			GROUP BY
				P.COD_LOJA
				,convert(int,P.COD_PARCEIRO)
				,CONVERT(DATE,DTA_EMISSAO)
				,CONVERT(DATE,DTA_ENTREGA)
				,P.NUM_PEDIDO
				,PP.COD_PRODUTO
	
	-- --------------------------------------------------------------------------------------------------------------------------
	--
	-- --------------------------------------------------------------------------------------------------------------------------
			SELECT
				TZ.COD_LOJA
				,TZ.COD_PRODUTO
				,sum(TZ.QTD_PEDIDO)
			FROM
				@TEMP_PEDIDOS_ABERTOS_ZEUS AS TZ
				INNER JOIN @TEMP_PEDIDOS_ABERTOS_BI AS TB
					ON 1=1
					AND TZ.COD_FORNECEDOR = TB.COD_FORNECEDOR_PEDIDO
					AND TZ.COD_PEDIDO = TB.COD_PEDIDO				
			WHERE 1=1
				AND TZ.QTD_RECEBIDA = 0
				AND TZ.COD_LOJA IN ( select ITEM from [dbo].[fnSplit](@ARRAY_LOJAS,',') )
				--AND CONVERT(DATE,DATEADD(D,@DIAS_LEAD_TIME,TZ.DTA_ENTREGA)) >= CONVERT(DATE,GETDATE())			
			GROUP BY
				TZ.COD_LOJA
				,TZ.COD_PRODUTO
		
