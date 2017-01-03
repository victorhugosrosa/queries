set nocount on;
DECLARE @DATA_INI AS DATE = convert(date,'20140401')
DECLARE @DATA_FIM AS DATE = convert(date,'20140531')

DECLARE @TAB_CAOS_CUSTO AS TABLE
(
	CodForn INT
	,Forn VARCHAR(50)
	--,Ref VARCHAR(50)
	,Plu INT 
	,Prod VARCHAR(50)
	,Abc VARCHAR(50)
	,Custo_Danfe NUMERIC(10,2)
	,Custo_Zeus NUMERIC(10,2)
	,Custo_Pedido NUMERIC(10,2)
	,Emb_Zeus NUMERIC(10,2)
	,Fator NUMERIC(10,2)
	,Fator_Pedido NUMERIC(10,2)
	,Qtd_Danfe NUMERIC(10,2)
	,NO_COMPRADOR VARCHAR(50) not null
	,DtEntradaZeus datetime
	,DtRecebimento datetime
	,DtGravacao datetime
	,num_danfe VARCHAR(50)
);	
	
INSERT INTO @TAB_CAOS_CUSTO
	SELECT
		 DET.Cod_fornecedor as [CodForn]
		,CF.DES_FANTASIA as [Forn]
		--,DET.cProd AS [Ref]
		,DET.COD_PRODUTO AS [Plu]
		,CP.DESCRICAO AS [Prod AX]
		,CP.CLASSIF_PRODUTO AS [Abc]
		,DET.vUnCom AS [Custo Danfe]
		,FORN_PROD.VAL_CUSTO_EMBALAGEM AS [Custo Zeus]
		,PED.val_custo_unit AS [Custo Pedido]
		,FORN_PROD.QTD_EMBALAGEM_COMPRA AS [Emb Zeus]
		,(CASE
			WHEN DET.vUnCom > FORN_PROD.VAL_CUSTO_EMBALAGEM THEN DET.vUnCom / (CASE WHEN (FORN_PROD.VAL_CUSTO_EMBALAGEM=0 OR FORN_PROD.VAL_CUSTO_EMBALAGEM IS NULL) THEN 1 ELSE FORN_PROD.VAL_CUSTO_EMBALAGEM END)
			WHEN DET.vUnCom = FORN_PROD.VAL_CUSTO_EMBALAGEM THEN FORN_PROD.VAL_CUSTO_EMBALAGEM / (CASE WHEN (DET.vUnCom=0 OR DET.vUnCom IS NULL) THEN 1 ELSE DET.vUnCom END)
			WHEN DET.vUnCom < FORN_PROD.VAL_CUSTO_EMBALAGEM THEN FORN_PROD.VAL_CUSTO_EMBALAGEM / (CASE WHEN (DET.vUnCom=0 OR DET.vUnCom IS NULL) THEN 1 ELSE DET.vUnCom END)
		END) AS [Fator]
		,(CASE
			WHEN DET.vUnCom > PED.val_custo_unit THEN DET.vUnCom / (CASE WHEN (PED.val_custo_unit=0 OR PED.val_custo_unit IS NULL) THEN 1 ELSE PED.val_custo_unit END)
			WHEN DET.vUnCom = PED.val_custo_unit THEN PED.val_custo_unit / (CASE WHEN (DET.vUnCom=0 OR DET.vUnCom IS NULL) THEN 1 ELSE DET.vUnCom END)
			WHEN DET.vUnCom < PED.val_custo_unit THEN PED.val_custo_unit / (CASE WHEN (DET.vUnCom=0 OR DET.vUnCom IS NULL) THEN 1 ELSE DET.vUnCom END)
		END) AS [Fator Pedido]
		,DET.qCom AS [Qtd Danfe]			
		,convert(varchar(50),CC.NO_COMPRADOR)
		,STA.Dt_EntradaZeus
		,STA.DtRecebimento
		,IDE.DtGravacao
		,DET.num_danfe
	FROM
		[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
			LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
			LEFT JOIN [CtrlNfe].[dbo].[NFE_PEDIDOS] AS PED ON (DET.num_danfe = PED.num_danfe AND DET.COD_PRODUTO = PED.COD_PRODUTO AND DET.Cod_fornecedor = PED.Cod_fornecedor)
			LEFT JOIN BI.DBO.BI_CAD_PRODUTO AS CP ON (DET.COD_PRODUTO = CP.COD_PRODUTO)
				LEFT JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC ON (CP.COD_USUARIO = CC.COD_USUARIO)
			LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF ON (DET.Cod_fornecedor = CF.Cod_fornecedor)
			LEFT JOIN BI.dbo.VW_CUSTOS_ATIVOS AS CUSTO ON (DET.COD_PRODUTO = CUSTO.COD_PRODUTO AND DET.Cod_fornecedor = CUSTO.Cod_fornecedor)
			LEFT JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS FORN_PROD ON (DET.COD_FORNECEDOR = FORN_PROD.COD_FORNECEDOR AND DET.COD_PRODUTO = FORN_PROD.COD_PRODUTO AND DET.cod_loja = FORN_PROD.COD_LOJA)
	WHERE 1 = 1
		AND DET.MENSAGEM IS NOT NULL
		AND DET.COD_PRODUTO IS NOT NULL
		AND DET.COD_FORNECEDOR IS NOT NULL
		AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)

	-- -------------------------------------------------------------------------------------------------------------------------------
	-- DANFES
	-- -------------------------------------------------------------------------------------------------------------------------------
		SELECT
			'DANFES RECEBIDAS' AS TIPO
			,year(IDE.DtGravacao) as ANO_RECEBIMENTO
			,month(IDE.DtGravacao) as MES_RECEBIMENTO
			,NO_COMPRADOR COLLATE DATABASE_DEFAULT as COMPRADOR
			,CF.DES_FANTASIA COLLATE DATABASE_DEFAULT as [Forn]
			,COUNT(distinct DET.num_danfe) AS [Total Danfes]
		FROM
			[CTRLNFE].[DBO].[NFE_DET] AS DET --INNER JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
				LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)				
				LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF ON (DET.Cod_fornecedor = CF.Cod_fornecedor)
					LEFT JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC ON (CF.COD_USUARIO = CC.COD_USUARIO)
		WHERE 1 = 1
			--AND MENSAGEM IS NOT NULL
			AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			year(IDE.DtGravacao)
			,month(IDE.DtGravacao)
			,NO_COMPRADOR
			,CF.DES_FANTASIA
UNION ALL
	-- -------------------------------------------------------------------------------------------------------------------------------
	-- DANFES COM ERRO
	-- -------------------------------------------------------------------------------------------------------------------------------
		SELECT
			'DANFES ERRO' AS TIPO
			,year(IDE.DtGravacao) as ANO_RECEBIMENTO
			,month(IDE.DtGravacao) as MES_RECEBIMENTO
			,NO_COMPRADOR COLLATE DATABASE_DEFAULT
			,CF.DES_FANTASIA COLLATE DATABASE_DEFAULT as [Forn]
			,COUNT(distinct DET.num_danfe) AS [Total Danfes]
		FROM
			[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
				LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
				LEFT JOIN [CtrlNfe].[dbo].[NFE_PEDIDOS] AS PED ON (DET.num_danfe = PED.num_danfe AND DET.COD_PRODUTO = PED.COD_PRODUTO AND DET.Cod_fornecedor = PED.Cod_fornecedor)
				LEFT JOIN BI.DBO.BI_CAD_PRODUTO AS CP ON (DET.COD_PRODUTO = CP.COD_PRODUTO)
					LEFT JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC ON (CP.COD_USUARIO = CC.COD_USUARIO)
				LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF ON (DET.Cod_fornecedor = CF.Cod_fornecedor)
				LEFT JOIN BI.dbo.VW_CUSTOS_ATIVOS AS CUSTO ON (DET.COD_PRODUTO = CUSTO.COD_PRODUTO AND DET.Cod_fornecedor = CUSTO.Cod_fornecedor)
				LEFT JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS FORN_PROD ON (DET.COD_FORNECEDOR = FORN_PROD.COD_FORNECEDOR AND DET.COD_PRODUTO = FORN_PROD.COD_PRODUTO AND DET.cod_loja = FORN_PROD.COD_LOJA)		
		WHERE 1 = 1
			AND MENSAGEM IS NOT NULL
			AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			year(IDE.DtGravacao)
			,month(IDE.DtGravacao)
			,NO_COMPRADOR
			,CF.DES_FANTASIA
			
UNION ALL
	-- -------------------------------------------------------------------------------------------------------------------------------
	-- FORNECEDOR NAO ENCONTRADO
	-- -------------------------------------------------------------------------------------------------------------------------------
		SELECT
			'DANFES SEM FORNECEDOR CADASTRO' AS TIPO
			,year(IDE.DtGravacao) as ANO_RECEBIMENTO
			,month(IDE.DtGravacao) as MES_RECEBIMENTO
			,NO_COMPRADOR COLLATE DATABASE_DEFAULT
			,CF.DES_FANTASIA COLLATE DATABASE_DEFAULT as [Forn]
			,COUNT(distinct DET.num_danfe) AS [Total Danfes]	
		FROM
			[CTRLNFE].[DBO].[NFE_DET] AS DET --INNER JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
				LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
				LEFT JOIN [CtrlNfe].[dbo].[NFE_COBR] AS COBR ON (DET.num_danfe = COBR.num_danfe)				
				LEFT JOIN [CtrlNfe].[dbo].[NFE_DEST] AS DEST ON (DET.num_danfe = DEST.num_danfe AND DEST.Tipo = 1)	
				LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF ON (DET.Cod_fornecedor = CF.Cod_fornecedor)
					LEFT JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC ON (CF.COD_USUARIO = CC.COD_USUARIO)
		WHERE 1 = 1
			AND MENSAGEM IS NOT NULL
			AND DET.COD_FORNECEDOR IS NULL
			AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			year(IDE.DtGravacao)ç
			,month(IDE.DtGravacao)
			,NO_COMPRADOR
			,CF.DES_FANTASIA
UNION ALL
	-- -------------------------------------------------------------------------------------------------------------------------------
	-- PRODUTO NAO ENCONTRADO
	-- -------------------------------------------------------------------------------------------------------------------------------
		SELECT	
			'DANFES SEM REFERENCIA NO SIST' AS TIPO
			,year(IDE.DtGravacao) as ANO_RECEBIMENTO
			,month(IDE.DtGravacao) as MES_RECEBIMENTO
			,NO_COMPRADOR COLLATE DATABASE_DEFAULT
			,CF.DES_FANTASIA COLLATE DATABASE_DEFAULT as [Forn]
			,COUNT(distinct DET.num_danfe) AS [Total Danfes]				
		FROM
			[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
				LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
				LEFT JOIN [CtrlNfe].[dbo].[NFE_PEDIDOS] AS PED ON (DET.num_danfe = PED.num_danfe AND DET.COD_PRODUTO = PED.COD_PRODUTO AND DET.Cod_fornecedor = PED.Cod_fornecedor)
				LEFT JOIN BI.DBO.BI_CAD_PRODUTO AS CP ON (DET.COD_PRODUTO = CP.COD_PRODUTO)
					LEFT JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC ON (CP.COD_USUARIO = CC.COD_USUARIO)
				LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF ON (DET.Cod_fornecedor = CF.Cod_fornecedor)
				LEFT JOIN BI.dbo.VW_CUSTOS_ATIVOS AS CUSTO ON (DET.COD_PRODUTO = CUSTO.COD_PRODUTO AND DET.Cod_fornecedor = CUSTO.Cod_fornecedor)
				LEFT JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS FORN_PROD ON (DET.COD_FORNECEDOR = FORN_PROD.COD_FORNECEDOR AND DET.COD_PRODUTO = FORN_PROD.COD_PRODUTO AND DET.cod_loja = FORN_PROD.COD_LOJA)		
		WHERE 1 = 1
			AND MENSAGEM IS NOT NULL
			AND DET.COD_PRODUTO IS NULL
			AND DET.COD_FORNECEDOR IS NOT NULL
			AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			year(IDE.DtGravacao)
			,month(IDE.DtGravacao)
			,NO_COMPRADOR
			,CF.DES_FANTASIA
UNION ALL
	-- -------------------------------------------------------------------------------------------------------------------------------
	-- PRODUTO ENCONTRADO / CUSTO DIFERENTE
	-- -------------------------------------------------------------------------------------------------------------------------------	
	/*
	SELECT
		'DANFES ERRO CUSTO/EMB' AS TIPO
		,year(DtGravacao) as ANO_RECEBIMENTO
		,month(DtGravacao) as MES_RECEBIMENTO
		,NO_COMPRADOR COLLATE DATABASE_DEFAULT
		,Forn COLLATE DATABASE_DEFAULT
		,COUNT(distinct num_danfe) AS [Total Danfes]	
	FROM
		@TAB_CAOS_CUSTO
	WHERE 1 = 1
		AND CUSTO_DANFE <> Custo_Pedido
	GROUP BY
		year(DtGravacao)
		,month(DtGravacao)
		,NO_COMPRADOR
		,Forn
UNION ALL*/
	-- -------------------------------------------------------------------------------------------------------------------------------
	-- PRODUTO ENCONTRADO / CUSTO DIFERENTE
	-- -------------------------------------------------------------------------------------------------------------------------------	
	SELECT
		'CUSTO DANFE > CUSTO PEDIDO EM ATÉ 100%' AS TIPO
		,year(DtGravacao) as ANO_RECEBIMENTO
		,month(DtGravacao) as MES_RECEBIMENTO
		,NO_COMPRADOR COLLATE DATABASE_DEFAULT
		,Forn  COLLATE DATABASE_DEFAULT
		,COUNT(distinct num_danfe) AS [Total Danfes]			
	FROM
		@TAB_CAOS_CUSTO
	WHERE 1 = 1
		AND Fator_Pedido BETWEEN 1 AND 2
		AND CUSTO_DANFE > Custo_Pedido
	GROUP BY
		year(DtGravacao)
		,month(DtGravacao)
		,NO_COMPRADOR
		,Forn
UNION ALL	
	-- -------------------------------------------------------------------------------------------------------------------------------
	-- PRODUTO ENCONTRADO / CUSTO DIFERENTE
	-- -------------------------------------------------------------------------------------------------------------------------------	
	SELECT
		'CUSTO DANFE < CUSTO PEDIDO EM ATÉ 100%' AS TIPO
		,year(DtGravacao) as ANO_RECEBIMENTO
		,month(DtGravacao) as MES_RECEBIMENTO
		,NO_COMPRADOR COLLATE DATABASE_DEFAULT
		,Forn COLLATE DATABASE_DEFAULT
		,COUNT(distinct num_danfe) AS [Total Danfes]	
	FROM
		@TAB_CAOS_CUSTO
	WHERE 1 = 1
		AND Fator_Pedido BETWEEN 1 AND 2
		AND CUSTO_DANFE < Custo_Pedido
	GROUP BY
		year(DtGravacao)
		,month(DtGravacao)
		,NO_COMPRADOR
		,Forn
UNION ALL	
	-- -------------------------------------------------------------------------------------------------------------------------------
	-- PRODUTO ENCONTRADO / CUSTO DIFERENTE
	-- -------------------------------------------------------------------------------------------------------------------------------	
	SELECT
		'ERRO DE EMBALAGEM' AS TIPO
		,year(DtGravacao) as ANO_RECEBIMENTO
		,month(DtGravacao) as MES_RECEBIMENTO
		,NO_COMPRADOR COLLATE DATABASE_DEFAULT
		,Forn COLLATE DATABASE_DEFAULT
		,COUNT(distinct num_danfe) AS [Total Danfes]	
	FROM
		@TAB_CAOS_CUSTO
	WHERE 1 = 1
		AND Fator_Pedido > 2
	GROUP BY
		year(DtGravacao)
		,month(DtGravacao)
		,NO_COMPRADOR
		,Forn

		
		
--SELECT * FROM @TAB_CAOS_CUSTO WHERE 1 = 1


--SELECT * FROM 	[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE) WHERE DET.NUM_DANFE = '31140617216621000100550010000702001000702000'