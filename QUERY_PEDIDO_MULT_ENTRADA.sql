	DECLARE @DATA_INI AS DATE = GETDATE()-90
	DECLARE @DATA_FIM AS DATE = GETDATE()
	
	/*
		SELECT  TOP 10
			*
		FROM
			[ZEUS_RTG].DBO.[TAB_PEDIDO] AS P
			INNER JOIN [ZEUS_RTG].DBO.[TAB_PEDIDO_PRODUTO] AS PP
				ON 1=1
				and P.NUM_PEDIDO = PP.NUM_PEDIDO
				AND P.COD_LOJA = PP.COD_LOJA
				AND P.COD_PARCEIRO = PP.COD_PARCEIRO
		WHERE 1 = 1
			AND CONVERT(DATE,P.DTA_EMISSAO) between CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
			--AND ISNULL(PP.QTD_RECEBIDA,0) > PP.QTD_PEDIDO*10
			and p.num_pedido = 1075316
			
			select * from  [ZEUS_RTG].DBO.[TAB_PEDIDO_CANCELADO] WHERE num_pedido = 1075316
	*/

	DECLARE @TAB_MULTI AS TABLE
	(
		NUM_PEDIDO INT
		,PRIMARY KEY (NUM_PEDIDO)
	)

	DECLARE @NUM_PEDIDO_MULTI AS VARCHAR(1000);

	DECLARE nome_cursor CURSOR FOR 
		SELECT multi_pedidos FROM [Intranet].[dbo].[TAB_RECEB_MERCADORIA] WHERE ISNULL(multi_pedidos,'') <> ''
		AND CONVERT(DATE,DATA) between CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		
	OPEN nome_cursor
	FETCH NEXT FROM nome_cursor 
	INTO @NUM_PEDIDO_MULTI

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------	
		
		INSERT INTO @TAB_MULTI	
		SELECT ITEM FROM INTRANET.[dbo].[fnSplitv](REPLACE(@NUM_PEDIDO_MULTI,'''','') ,',')
		WHERE item NOT IN (SELECT DISTINCT NUM_PEDIDO FROM @TAB_MULTI)
				
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------
		FETCH NEXT FROM nome_cursor 
		INTO @NUM_PEDIDO_MULTI
	END 
	CLOSE nome_cursor;
	DEALLOCATE nome_cursor;
	
	SELECT
		P.COD_LOJA
		,P.COD_PARCEIRO
		,P.NUM_PEDIDO
		,PP.COD_PRODUTO
		,PP.QTD_PEDIDO
		,PP.QTD_RECEBIDA
	FROM
		[ZEUS_RTG].DBO.[TAB_PEDIDO] AS P
		INNER JOIN [ZEUS_RTG].DBO.[TAB_PEDIDO_PRODUTO] AS PP
			ON 1=1
			and P.NUM_PEDIDO = PP.NUM_PEDIDO
			AND P.COD_LOJA = PP.COD_LOJA
			AND P.COD_PARCEIRO = PP.COD_PARCEIRO
		INNER JOIN @TAB_MULTI AS TM
			ON P.NUM_PEDIDO = TM.NUM_PEDIDO
    WHERE 1 = 1
		AND CONVERT(DATE,P.DTA_EMISSAO) between CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		AND ISNULL(PP.QTD_RECEBIDA,0) > PP.QTD_PEDIDO*10


--SELECT * FROM @TAB_MULTI
  
  



