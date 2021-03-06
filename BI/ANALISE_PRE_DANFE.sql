DECLARE @DATA_INI AS DATE = GETDATE()-1
DECLARE @DATA_FIM AS DATE = GETDATE()


-- -------------------------------------------------------------------------------------------------------------------------------
-- DANFES
-- -------------------------------------------------------------------------------------------------------------------------------
	SELECT
		COUNT(distinct DET.num_danfe) AS [Total Danfes]
	FROM
		[CTRLNFE].[DBO].[NFE_DET] AS DET --INNER JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
			LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)				
	WHERE 1 = 1
		--AND MENSAGEM IS NOT NULL
		AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)

-- -------------------------------------------------------------------------------------------------------------------------------
-- DANFES COM ERRO
-- -------------------------------------------------------------------------------------------------------------------------------
	SELECT
		IDE.DtGravacao
		,DET.cod_loja
		,'NF' + DET.num_danfe AS [Danfe]
		,SUBSTRING(DET.num_danfe,7,14) as CNPJ
		,convert(date,IDE.dEmi) AS [Data Emissao]
		,IDE.DtGravacao as [Data Gravacao]
		,COUNT(DET.cProd) AS [Item]
	FROM
		[CTRLNFE].[DBO].[NFE_DET] AS DET --INNER JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
			LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
			LEFT JOIN [CtrlNfe].[dbo].[NFE_COBR] AS COBR ON (DET.num_danfe = COBR.num_danfe)				
	WHERE 1 = 1
		AND MENSAGEM IS NOT NULL
		AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
	GROUP BY
		DET.cod_loja
		,DET.num_danfe
		,IDE.dEmi
		,IDE.DtGravacao


-- -------------------------------------------------------------------------------------------------------------------------------
-- FORNECEDOR NAO ENCONTRADO
-- -------------------------------------------------------------------------------------------------------------------------------
	SELECT
		IDE.DtGravacao
		,DET.cod_loja
		,'NF' + DET.num_danfe AS [Danfe]
		,SUBSTRING(DET.num_danfe,7,14) as CNPJ
	
		,DEST.xNome
		,convert(date,IDE.dEmi) AS [Data Emissao]
		,IDE.DtGravacao as [Data Gravacao]
		,COUNT(DET.cProd) AS [Item]
		
	FROM
		[CTRLNFE].[DBO].[NFE_DET] AS DET --INNER JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
			LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
			LEFT JOIN [CtrlNfe].[dbo].[NFE_COBR] AS COBR ON (DET.num_danfe = COBR.num_danfe)				
			LEFT JOIN [CtrlNfe].[dbo].[NFE_DEST] AS DEST ON (DET.num_danfe = DEST.num_danfe AND DEST.Tipo = 1)	
	WHERE 1 = 1
		AND MENSAGEM IS NOT NULL
		AND DET.COD_FORNECEDOR IS NULL
		AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
	GROUP BY
		DET.cod_loja
		,DET.num_danfe
		,IDE.dEmi
		,IDE.DtGravacao
		,DEST.CNPJ
		,DEST.xNome

-- -------------------------------------------------------------------------------------------------------------------------------
-- PRODUTO NAO ENCONTRADO
-- -------------------------------------------------------------------------------------------------------------------------------
	SELECT
		IDE.DtGravacao
		,DET.cod_loja
		,'NF' + DET.num_danfe AS [Danfe]
		,DET.Cod_fornecedor as [CodForn]
		,CF.DES_FANTASIA as [Forn]
		,DET.cProd
		,DET.xProd
		,dbo.fn_FormataVlr_Excel(DET.vUnCom) AS [Custo Danfe]
		,dbo.fn_FormataVlr_Excel(DET.qCom) AS [Qtd Danfe]
		,CC.NO_COMPRADOR
		,STUFF(
				(
					select  DISTINCT
							CONVERT(varchar,tpf.COD_FORNECEDOR)+' | ' 
					from    AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR tpf
					where  1=1
					and  tpf.DES_REFERENCIA = DET.cProd
					--order by tpf.COD_FORNECEDOR
					for xml path('')
				),1,0,'') as [Ref em outro Forn]
		--,'Produto não encontrado' as [Erro]
	FROM
		[CTRLNFE].[DBO].[NFE_DET] AS DET INNER JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
			LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
			LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF ON (DET.Cod_fornecedor = CF.Cod_fornecedor)
				LEFT JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC ON (CF.COD_USUARIO = CC.COD_USUARIO)
	WHERE 1 = 1
		AND MENSAGEM IS NOT NULL
		AND DET.COD_PRODUTO IS NULL
		AND DET.COD_FORNECEDOR IS NOT NULL
		AND CF.COD_USUARIO IS NOT NULL
		AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)

-- -------------------------------------------------------------------------------------------------------------------------------
-- PRODUTO ENCONTRADO / CUSTO DIFERENTE
-- -------------------------------------------------------------------------------------------------------------------------------
	SELECT
		IDE.DtGravacao
		,DET.cod_loja as [Loja]
		,'NF' + DET.num_danfe as [Danfe]
		,DET.Cod_fornecedor as [CodForn]
		,CF.DES_FANTASIA as [Forn]
		,DET.cProd AS [Ref]
		,DET.COD_PRODUTO AS [Plu]
		,DET.xProd AS [Prod Danfe]
		,CP.DESCRICAO AS [Prod BI]
		,dbo.fn_FormataVlr_Excel(DET.vUnCom) AS [Custo Danfe]
		,dbo.fn_FormataVlr_Excel(FORN_PROD.VAL_CUSTO_EMBALAGEM) AS [Custo Zeus]
		,dbo.fn_FormataVlr_Excel(CUSTO.VLR_EMB_COMPRA) AS [Custo BI]
		,dbo.fn_FormataVlr_Excel(DET.qCom) AS [Qtd Danfe]
		,dbo.fn_FormataVlr_Excel(FORN_PROD.QTD_EMBALAGEM_COMPRA) AS [Emb Zeus]
		,dbo.fn_FormataVlr_Excel(CUSTO.QTD_EMB_COMPRA) AS [Emb BI]
		,CC.NO_COMPRADOR
		,DET.MENSAGEM		
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
		DET.DTA_GRAVACAO




