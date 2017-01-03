DECLARE @DATA_INI AS DATE = GETDATE()-30
DECLARE @DATA_FIM AS DATE = GETDATE()-1

SELECT
	P.COD_LOJA
	,P.COD_FORNECEDOR
	,P.COD_PEDIDO AS NUM_PEDIDO
	,P.DTA_EMISSAO as DATA_PEDIDO
	,P.DTA_ENTREGA_PREVISTA AS DATA_RECEBIMENTO_PEDIDO
	,R.DTA_ENTRADA AS DATA_RECEBIMENTO		
	,P.COD_PRODUTO
	,BI.dbo.fn_FormataVlr_Excel(P.QTD_PEDIDO) AS QTD_PEDIDO
	,BI.dbo.fn_FormataVlr_Excel(ISNULL(R.QTD_ENTRADA,0)) AS QTD_RECEBIDA	
	,(CASE
		WHEN ISNULL(R.QTD_ENTRADA,0) < P.QTD_PEDIDO THEN -1
		WHEN ISNULL(R.QTD_ENTRADA,0) = P.QTD_PEDIDO THEN 0
		WHEN ISNULL(R.QTD_ENTRADA,0) > P.QTD_PEDIDO THEN 1
	END) AS SCORE_RECEBIMENTO
	,dbo.fn_FormataVlr_Excel(ISNULL(R.QTD_ENTRADA,0)/P.QTD_PEDIDO) AS SCORE_RECEBIMENTO_DETALHADO
	,(CASE
		WHEN CONVERT(DATE,P.DTA_ENTREGA_PREVISTA) > CONVERT(DATE,R.DTA_ENTRADA) THEN -1
		WHEN CONVERT(DATE,P.DTA_ENTREGA_PREVISTA) = CONVERT(DATE,R.DTA_ENTRADA) THEN 0
		WHEN CONVERT(DATE,P.DTA_ENTREGA_PREVISTA) < CONVERT(DATE,R.DTA_ENTRADA) THEN 1
	END) AS SCORE_DATA
	,dbo.fn_FormataVlr_Excel(DATEDIFF(D,CONVERT(DATE,P.DTA_ENTREGA_PREVISTA),CONVERT(DATE,R.DTA_ENTRADA))) AS SCORE_DATA_DETALHADO
	,(CASE
		WHEN ISNULL(R.QTD_ENTRADA,0) <= 0 THEN 'PENDENTE'
		WHEN ISNULL(R.QTD_ENTRADA,0) < P.QTD_PEDIDO THEN 'PARCIAL'		
		WHEN ISNULL(R.QTD_ENTRADA,0) >= P.QTD_PEDIDO THEN 'OK'
	END) as [STATUS_PEDIDO]
	
	
	,DATEDIFF(DAY,P.DTA_EMISSAO,R.DTA_ENTRADA) AS TEMPO_ENTREGA_DIAS
	,r.VAL_TABELA
	,BI.dbo.fn_FormataVlr_Excel(P.VLR_TOTAL_PEDIDO) AS VLR_TOTAL_PEDIDO
	,BI.dbo.fn_FormataVlr_Excel(ISNULL(R.VLR_TOTAL_RECEBIMENTO,0)) AS VLR_TOTAL_RECEBIMENTO
	
FROM
	(
		SELECT --COD_LOJA , NUM_PEDIDO , DTA_EMISSAO  , DTA_ENTREGA , COD_FORNECEDOR ,  COD_PRODUTO , QTDE AS QTD_PEDIDO, VAL_TABELA_FINAL
			PED.COD_LOJA
			,PED.COD_FORNECEDOR
			,CF.DESCRICAO AS NO_FORNECEDOR
			,PED.DTA_EMISSAO
			,DATEADD(D,F_LT.DIAS_LEAD_TIME,PED.DTA_EMISSAO) AS DTA_ENTREGA_PREVISTA
			,PED.NUM_PEDIDO AS COD_PEDIDO
			,PED.COD_PRODUTO
			,CP.DESCRICAO AS NO_PRODUTO
			,PED.QTD_PEDIDO AS QTD_PEDIDO
			,PED.VAL_TABELA_FINAL AS VLR_TOTAL_PEDIDO
		FROM
			DW.DBO.VW_MARCHE_PEDIDOS_PROD AS PED
			LEFT JOIN BI.dbo.BI_CAD_FORNECEDOR AS CF
				ON PED.COD_FORNECEDOR = CF.COD_FORNECEDOR
			LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
				ON PED.COD_PRODUTO = CP.COD_PRODUTO
			LEFT JOIN
			(SELECT DISTINCT COD_FORNECEDOR, DIAS_LEAD_TIME FROM COMPRAS_AGENDA_PEDIDO_AUTO WHERE FLG_ATIVO = 1 AND TIPO = 1) AS F_LT
				ON PED.COD_FORNECEDOR = F_LT.COD_FORNECEDOR
		WHERE 1 = 1
			AND DATAAREAID = 'ORB'
			AND NUM_PEDIDO LIKE 'CD%'
			AND CONVERT(DATE,PED.DTA_EMISSAO) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
	) AS P
LEFT JOIN
	( 
		SELECT-- TOP 10
			ENT.COD_LOJA
			,ENT.COD_FORNECEDOR
			,CF.DESCRICAO AS NO_FORNECEDOR
			,ENT.DTA_ENTRADA
			,ENT.PURCHID AS COD_PEDIDO
			,ENT.NUM_NF_FORN
			,ENT.NUM_SERIE_NF
			,ENT.NUM_DANFE
			,ENT.COD_PRODUTO
			,CP.DESCRICAO AS NO_PRODUTO
			,ENT.QTD_ENTRADA*-1 AS QTD_ENTRADA
			,ENT.VAL_TABELA AS VAL_TABELA
			,ENT.VAL_TABELA_FINAL*-1 AS VLR_TOTAL_RECEBIMENTO
		FROM
			DW.DBO.VW_MARCHE_ENTRADAS AS ENT
			LEFT JOIN BI.dbo.BI_CAD_FORNECEDOR AS CF
				ON ENT.COD_FORNECEDOR = CF.COD_FORNECEDOR
			LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
				ON ENT.COD_PRODUTO = CP.COD_PRODUTO
		WHERE  1 = 1
			AND ENT.PURCHID LIKE 'CD%'
			AND ENT.DATAAREAID = 'ORB'
			AND CONVERT(DATE,ENT.DTA_ENTRADA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
	) AS R
	ON 1=1
	AND P.COD_LOJA = R.COD_LOJA
	AND P.COD_FORNECEDOR = R.COD_FORNECEDOR
	AND P.COD_PEDIDO = R.COD_PEDIDO