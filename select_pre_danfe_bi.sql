-- -------------------------------------------------------------------------------------------------------------------------------
-- PRODUTO ENCONTRADO / CUSTO DIFERENTE
-- -------------------------------------------------------------------------------------------------------------------------------
	SELECT
		 DET.Cod_fornecedor as [CodForn]
		,CF.DES_FANTASIA as [Forn]
		,DET.cProd AS [Ref]
		,DET.COD_PRODUTO AS [Plu]
		,DET.xProd AS [Prod Danfe]
		,CP.DESCRICAO AS [Prod AX]
		,CP.CLASSIF_PRODUTO AS [Abc]
		,DET.vUnCom AS [Custo Danfe]
		,FORN_PROD.VAL_CUSTO_EMBALAGEM AS [Custo Zeus]
		,FORN_PROD.QTD_EMBALAGEM_COMPRA AS [Emb Zeus]
		,CUSTO.VLR_EMB_COMPRA AS [Custo AX]
		,CUSTO.QTD_EMB_COMPRA AS [Emb AX]
		,(CASE
			WHEN DET.vUnCom > FORN_PROD.VAL_CUSTO_EMBALAGEM THEN DET.vUnCom / (CASE WHEN (FORN_PROD.VAL_CUSTO_EMBALAGEM=0 OR FORN_PROD.VAL_CUSTO_EMBALAGEM IS NULL) THEN 1 ELSE FORN_PROD.VAL_CUSTO_EMBALAGEM END)
			WHEN DET.vUnCom = FORN_PROD.VAL_CUSTO_EMBALAGEM THEN FORN_PROD.VAL_CUSTO_EMBALAGEM / (CASE WHEN (DET.vUnCom=0 OR DET.vUnCom IS NULL) THEN 1 ELSE DET.vUnCom END)
			WHEN DET.vUnCom < FORN_PROD.VAL_CUSTO_EMBALAGEM THEN FORN_PROD.VAL_CUSTO_EMBALAGEM / (CASE WHEN (DET.vUnCom=0 OR DET.vUnCom IS NULL) THEN 1 ELSE DET.vUnCom END)
		END) AS [Fator]
		,(CASE
			WHEN 
				(CONVERT(NUMERIC(8,2),FORN_PROD.VAL_CUSTO_EMBALAGEM) % CONVERT(NUMERIC(8,2),DET.vUnCom) = 0
				or
				CONVERT(NUMERIC(8,2),DET.vUnCom) % CONVERT(NUMERIC(8,2),FORN_PROD.VAL_CUSTO_EMBALAGEM) = 0) THEN 'True'
			ELSE 'False'
		END) AS [Fator Int]
		,DET.qCom AS [Qtd Danfe]			
		,CC.NO_COMPRADOR AS [Comprador]
		--,DET.MENSAGEM		
		,IDE.DtGravacao as [Data Gravacao]
		,ISNULL(CUSTO.DTA_GRAVACAO,'19000101') AS [Data Custo]
		,(CASE WHEN CUSTO.DTA_GRAVACAO > IDE.DtGravacao THEN 1 ELSE 0 END) AS [Custo atualizado]
		,DET.cod_loja as [Loja]
		,'NF' + DET.num_danfe as [Danfe]	
		,'' AS [Insert] 			
	FROM
		[CTRLNFE].[DBO].[NFE_DET] AS DET INNER JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
			LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
			LEFT JOIN BI.DBO.BI_CAD_PRODUTO AS CP ON (DET.COD_PRODUTO = CP.COD_PRODUTO)
				LEFT JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC ON (CP.COD_USUARIO = CC.COD_USUARIO)
			LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF ON (DET.Cod_fornecedor = CF.Cod_fornecedor)
			LEFT JOIN BI.dbo.VW_CUSTOS_ATIVOS AS CUSTO ON (DET.COD_PRODUTO = CUSTO.COD_PRODUTO AND DET.Cod_fornecedor = CUSTO.Cod_fornecedor)
			LEFT JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS FORN_PROD ON (DET.COD_FORNECEDOR = FORN_PROD.COD_FORNECEDOR AND DET.COD_PRODUTO = FORN_PROD.COD_PRODUTO AND DET.cod_loja = FORN_PROD.COD_LOJA)
	WHERE 1 = 1
		AND MENSAGEM IS NOT NULL
		AND DET.COD_PRODUTO IS NOT NULL
		AND DET.COD_FORNECEDOR IS NOT NULL
		AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		--AND DET.vUnCom <> FORN_PROD.VAL_CUSTO_EMBALAGEM
	ORDER BY 
		CP.CLASSIF_PRODUTO
