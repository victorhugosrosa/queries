set nocount on;
DECLARE @DATA_INI AS DATE = convert(date,'20140401')
DECLARE @DATA_FIM AS DATE = convert(date,'20140720')

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
	,NO_COMPRADOR VARCHAR(50)
	,DtEntradaZeus datetime
	,DtRecebimento datetime
	,DtGravacao datetime
);

-- -------------------------------------------------------------------------------------------------------------------------------
-- PRODUTO ENCONTRADO / CUSTO DIFERENTE
-- -------------------------------------------------------------------------------------------------------------------------------
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
		,CC.NO_COMPRADOR AS [Comprador]
		,STA.Dt_EntradaZeus
		,STA.DtRecebimento
		,IDE.DtGravacao
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
-- TEST
-- -------------------------------------------------------------------------------------------------------------------------------
/*
SELECT *
FROM
	@TAB_CAOS_CUSTO
WHERE 1 = 1
	AND Fator_Pedido BETWEEN 1 AND 2
	AND (DtRecebimento is not null or DtEntradaZeus is not null)
	AND CUSTO_DANFE > Custo_Pedido
*/	
-- -------------------------------------------------------------------------------------------------------------------------------
-- CUSTO ATUAL ZEUS
-- -------------------------------------------------------------------------------------------------------------------------------
--/*
SELECT
	year(DtGravacao) as ANO_RECEBIMENTO
	,month(DtGravacao) as MES_RECEBIMENTO
	,(CASE
		WHEN Fator_Pedido BETWEEN 1 AND 1.1 THEN '0-10%'
		WHEN Fator_Pedido BETWEEN 1.1 AND 1.2 THEN '10-20%'
		WHEN Fator_Pedido BETWEEN 1.2 AND 1.3 THEN '20-30%'
		WHEN Fator_Pedido BETWEEN 1.3 AND 1.4 THEN '30-40%'
		WHEN Fator_Pedido BETWEEN 1.4 AND 1.5 THEN '40-50%'
		WHEN Fator_Pedido BETWEEN 1.5 AND 1.6 THEN '50-60%'
		WHEN Fator_Pedido BETWEEN 1.6 AND 1.7 THEN '60-70%'
		WHEN Fator_Pedido BETWEEN 1.7 AND 1.8 THEN '70-80%'
		WHEN Fator_Pedido BETWEEN 1.8 AND 1.9 THEN '80-90%'
		WHEN Fator_Pedido BETWEEN 1.9 AND 2 THEN '90-100%'
		WHEN Fator_Pedido > 2 THEN '>100%'
		ELSE 'Não Classificado'
	END) AS Perc
	,NO_COMPRADOR
	,Forn	
	,[Plu]
	,Prod
	,CUSTO_DANFE
	,Custo_Pedido
	,DBO.FN_FORMATAVLR_EXCEL(COUNT(PROD)) AS [QTD ITENS]
	,DBO.FN_FORMATAVLR_EXCEL(SUM((CUSTO_DANFE-Custo_Pedido)*QTD_DANFE)) AS [CUSTO EXTRA]
FROM
	@TAB_CAOS_CUSTO
WHERE 1 = 1
	AND Fator_Pedido BETWEEN 1 AND 2
	AND (DtRecebimento is not null or DtEntradaZeus is not null)
	AND CUSTO_DANFE > Custo_Pedido
GROUP BY
	year(DtGravacao)
	,month(DtGravacao)
	,(CASE
		WHEN Fator_Pedido BETWEEN 1 AND 1.1 THEN '0-10%'
		WHEN Fator_Pedido BETWEEN 1.1 AND 1.2 THEN '10-20%'
		WHEN Fator_Pedido BETWEEN 1.2 AND 1.3 THEN '20-30%'
		WHEN Fator_Pedido BETWEEN 1.3 AND 1.4 THEN '30-40%'
		WHEN Fator_Pedido BETWEEN 1.4 AND 1.5 THEN '40-50%'
		WHEN Fator_Pedido BETWEEN 1.5 AND 1.6 THEN '50-60%'
		WHEN Fator_Pedido BETWEEN 1.6 AND 1.7 THEN '60-70%'
		WHEN Fator_Pedido BETWEEN 1.7 AND 1.8 THEN '70-80%'
		WHEN Fator_Pedido BETWEEN 1.8 AND 1.9 THEN '80-90%'
		WHEN Fator_Pedido BETWEEN 1.9 AND 2 THEN '90-100%'
		WHEN Fator_Pedido > 2 THEN '>100%'
		ELSE 'Não Classificado'
	END)
	,NO_COMPRADOR
	,Forn	
	,[Plu]
	,Prod
	,CUsTO_DANFE
	,Custo_Pedido
--*/

-- -------------------------------------------------------------------------------------------------------------------------------
-- CUSTO ATUAL ZEUS
-- -------------------------------------------------------------------------------------------------------------------------------
/*
SELECT
	year(DtGravacao) as ANO_RECEBIMENTO
	,month(DtGravacao) as MES_RECEBIMENTO
	,(CASE
		WHEN FATOR BETWEEN 1 AND 1.1 THEN '0-10%'
		WHEN FATOR BETWEEN 1.1 AND 1.2 THEN '10-20%'
		WHEN FATOR BETWEEN 1.2 AND 1.3 THEN '20-30%'
		WHEN FATOR BETWEEN 1.3 AND 1.4 THEN '30-40%'
		WHEN FATOR BETWEEN 1.4 AND 1.5 THEN '40-50%'
		WHEN FATOR BETWEEN 1.5 AND 1.6 THEN '50-60%'
		WHEN FATOR BETWEEN 1.6 AND 1.7 THEN '60-70%'
		WHEN FATOR BETWEEN 1.7 AND 1.8 THEN '70-80%'
		WHEN FATOR BETWEEN 1.8 AND 1.9 THEN '80-90%'
		WHEN FATOR BETWEEN 1.9 AND 2 THEN '90-100%'
		WHEN FATOR > 2 THEN '>100%'
		ELSE 'Não Classificado'
	END) AS Perc
	,NO_COMPRADOR
	,Forn	
	,DBO.FN_FORMATAVLR_EXCEL(COUNT(PROD)) AS [QTD ITENS]
	,DBO.FN_FORMATAVLR_EXCEL(SUM((CUSTO_DANFE-CUSTO_ZEUS)*QTD_DANFE)) AS [CUSTO EXTRA]
FROM
	@TAB_CAOS_CUSTO
WHERE 1 = 1
	AND FATOR > 1
	AND CUSTO_DANFE > CUSTO_ZEUS
GROUP BY
	year(DtGravacao)
	,month(DtGravacao)
	,(CASE
		WHEN FATOR BETWEEN 1 AND 1.1 THEN '0-10%'
		WHEN FATOR BETWEEN 1.1 AND 1.2 THEN '10-20%'
		WHEN FATOR BETWEEN 1.2 AND 1.3 THEN '20-30%'
		WHEN FATOR BETWEEN 1.3 AND 1.4 THEN '30-40%'
		WHEN FATOR BETWEEN 1.4 AND 1.5 THEN '40-50%'
		WHEN FATOR BETWEEN 1.5 AND 1.6 THEN '50-60%'
		WHEN FATOR BETWEEN 1.6 AND 1.7 THEN '60-70%'
		WHEN FATOR BETWEEN 1.7 AND 1.8 THEN '70-80%'
		WHEN FATOR BETWEEN 1.8 AND 1.9 THEN '80-90%'
		WHEN FATOR BETWEEN 1.9 AND 2 THEN '90-100%'
		WHEN FATOR > 2 THEN '>100%'
		ELSE 'Não Classificado'
	END)
	,NO_COMPRADOR
	,Forn	
*/

-- -------------------------------------------------------------------------------------------------------------------------------
-- CUSTO 50%
-- -------------------------------------------------------------------------------------------------------------------------------
/*
SELECT
	year(DtGravacao) as ANO_RECEBIMENTO
	,month(DtGravacao) as MES_RECEBIMENTO
	,NO_COMPRADOR
	,Forn	
	,dbo.fn_FormataVlr_Excel(SUM((Custo_Danfe-Custo_Zeus)*Qtd_Danfe)) as [Custo_Extra]
FROM
	@TAB_CAOS_CUSTO
WHERE 1 = 1
	AND Fator between 1 and 1.5
	and Custo_Danfe > Custo_Zeus
GROUP BY
	year(DtGravacao)
	,month(DtGravacao)
	,NO_COMPRADOR
	,Forn	
*/