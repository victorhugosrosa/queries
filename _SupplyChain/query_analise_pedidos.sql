-- ---------------------------------------------------------------------------------------------------------------------------------------
	-- 
	-- ---------------------------------------------------------------------------------------------------------------------------------------	
	DECLARE @DATA_INI AS DATE = '2016-01-01'
	DECLARE @DATA_FIM AS DATE = GETDATE()
	
	--pedidos centralizados
	SELECT
		P.COD_LOJA
		,convert(int,P.COD_FORNECEDOR) as COD_FORNECEDOR
		,P.COD_PEDIDO AS NUM_PEDIDO
		,P.DTA_EMISSAO as DATA_PEDIDO
		,P.DTA_ENTREGA_PREVISTA AS DATA_RECEBIMENTO_PEDIDO
		,R.DTA_ENTRADA AS DATA_RECEBIMENTO		
		,CONVERT(INT,P.COD_PRODUTO) AS COD_PRODUTO
		,BI.dbo.fn_FormataVlr_Excel(P.QTD_PEDIDO) AS QTD_PEDIDO
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(R.QTD_ENTRADA,0)) AS QTD_RECEBIDA	
		--,(CASE
		--	WHEN ISNULL(R.QTD_ENTRADA,0) < P.QTD_PEDIDO THEN -1
		--	WHEN ISNULL(R.QTD_ENTRADA,0) = P.QTD_PEDIDO THEN 0
		--	WHEN ISNULL(R.QTD_ENTRADA,0) > P.QTD_PEDIDO THEN 1
		--END) AS SCORE_RECEBIMENTO
		--,dbo.fn_FormataVlr_Excel(ISNULL(R.QTD_ENTRADA,0)/P.QTD_PEDIDO) AS SCORE_RECEBIMENTO_DETALHADO
		--,(CASE
		--	WHEN CONVERT(DATE,P.DTA_ENTREGA_PREVISTA) > CONVERT(DATE,R.DTA_ENTRADA) THEN -1
		--	WHEN CONVERT(DATE,P.DTA_ENTREGA_PREVISTA) = CONVERT(DATE,R.DTA_ENTRADA) THEN 0
		--	WHEN CONVERT(DATE,P.DTA_ENTREGA_PREVISTA) < CONVERT(DATE,R.DTA_ENTRADA) THEN 1
		--END) AS SCORE_DATA
		--,dbo.fn_FormataVlr_Excel(DATEDIFF(D,CONVERT(DATE,P.DTA_ENTREGA_PREVISTA),CONVERT(DATE,R.DTA_ENTRADA))) AS SCORE_DATA_DETALHADO
		,(CASE
			WHEN ISNULL(R.QTD_ENTRADA,0) = 0 THEN 'PENDENTE'
			WHEN ISNULL(R.QTD_ENTRADA,0) < P.QTD_PEDIDO THEN 'PARCIAL'		
			WHEN ISNULL(R.QTD_ENTRADA,0) >= P.QTD_PEDIDO THEN 'OK'
		END) as [STATUS_PEDIDO]
		,BI.dbo.fn_FormataVlr_Excel(P.VLR_TOTAL_PEDIDO) AS VLR_TOTAL_PEDIDO
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(R.VLR_TOTAL_RECEBIMENTO,0)) AS VLR_TOTAL_RECEBIMENTO
		,'Pedido CD' as TIPO_PEDIDO
		,(CASE
			WHEN DATEADD(D,7,P.DTA_ENTREGA_PREVISTA) < GETDATE() AND R.QTD_ENTRADA = 0 THEN 'Expirado'
			WHEN DATEADD(D,7,P.DTA_ENTREGA_PREVISTA) < GETDATE() AND R.DTA_ENTRADA <= P.DTA_ENTREGA_PREVISTA AND ISNULL(R.QTD_ENTRADA,0) < P.QTD_PEDIDO THEN 'Parcial'
			WHEN DATEADD(D,7,P.DTA_ENTREGA_PREVISTA) < GETDATE() AND R.DTA_ENTRADA <= P.DTA_ENTREGA_PREVISTA AND ISNULL(R.QTD_ENTRADA,0) >= P.QTD_PEDIDO THEN 'Entregue'
			ELSE 'Aberto'
		END) AS VALIDADE_PEDIDO
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
		AND P.COD_PRODUTO = R.COD_PRODUTO
	WHERE 1=1
		AND ISNULL(R.QTD_ENTRADA,0) <= P.QTD_PEDIDO*20

	UNION ALL	
	
	--pedidos zeus
	SELECT	
		P.COD_LOJA
		,convert(int,P.COD_PARCEIRO) as COD_FORNECEDOR
		,CONVERT(VARCHAR(12),P.NUM_PEDIDO) AS NUM_PEDIDO
		,CONVERT(DATE,P.DTA_EMISSAO) as DATA_PEDIDO
		,CONVERT(DATE,P.DTA_ENTREGA) AS DATA_RECEBIMENTO_PEDIDO
		,CONVERT(DATE,P.DTA_ENTREGA) AS DATA_RECEBIMENTO		
		,PP.COD_PRODUTO
		,BI.dbo.fn_FormataVlr_Excel(PP.QTD_PEDIDO*PP.QTD_EMBALAGEM) AS QTD_PEDIDO
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(PP.QTD_RECEBIDA,0)) AS QTD_RECEBIDA	
		,(CASE
			WHEN ISNULL(PP.QTD_RECEBIDA,0) = 0 THEN 'PENDENTE'
			WHEN ISNULL(PP.QTD_RECEBIDA,0) < PP.QTD_PEDIDO THEN 'PARCIAL'		
			WHEN ISNULL(PP.QTD_RECEBIDA,0) >= PP.QTD_PEDIDO THEN 'OK'
		END) as [STATUS_PEDIDO]
		,BI.dbo.fn_FormataVlr_Excel(PP.VAL_TABELA*PP.QTD_PEDIDO) AS VLR_TOTAL_PEDIDO
		,BI.dbo.fn_FormataVlr_Excel(PP.VAL_TABELA*(PP.QTD_RECEBIDA/PP.QTD_EMBALAGEM)) AS VLR_TOTAL_RECEBIMENTO		
		,'Pedido Normal' as TIPO_PEDIDO
		--,(CASE WHEN DATEADD(D,7,P.DTA_ENTREGA) < GETDATE() AND PP.QTD_RECEBIDA = 0 THEN 'Expirado' ELSE 'Valido' END) AS VALIDADE_PEDIDO
		,(CASE
			WHEN ISNULL(PP.QTD_RECEBIDA,0) > (PP.QTD_PEDIDO*PP.QTD_EMBALAGEM)*2 THEN 'Em analise'
			WHEN DATEADD(D,7,P.DTA_ENTREGA) < GETDATE() AND PP.QTD_RECEBIDA = 0 THEN 'Expirado'
			WHEN DATEADD(D,7,P.DTA_ENTREGA) < GETDATE() AND P.DTA_ENTREGA <= P.DTA_ENTREGA AND ISNULL(PP.QTD_RECEBIDA,0) < PP.QTD_PEDIDO THEN 'Parcial'
			WHEN DATEADD(D,7,P.DTA_ENTREGA) < GETDATE() AND P.DTA_ENTREGA <= P.DTA_ENTREGA AND ISNULL(PP.QTD_RECEBIDA,0) >= PP.QTD_PEDIDO THEN 'Entregue'
			ELSE 'Aberto'
		END) AS VALIDADE_PEDIDO
    FROM
		[192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO] AS P
		INNER JOIN [192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO_PRODUTO] AS PP
			ON 1=1
			and P.NUM_PEDIDO = PP.NUM_PEDIDO
			AND P.COD_LOJA = PP.COD_LOJA
			AND P.COD_PARCEIRO = PP.COD_PARCEIRO
    WHERE 1 = 1
		AND CONVERT(DATE,P.DTA_EMISSAO) between CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		--AND ISNULL(PP.QTD_RECEBIDA,0) <= PP.QTD_PEDIDO*10
		--AND P.NUM_PEDIDO NOT IN (1060717,1080543,1030346)
		
	UNION ALL
	
	--pedidos cancelados
	SELECT	
		P.COD_LOJA
		,convert(int,P.COD_PARCEIRO) as COD_FORNECEDOR
		,CONVERT(VARCHAR(12),P.NUM_PEDIDO) AS NUM_PEDIDO
		,CONVERT(DATE,P.DTA_EMISSAO) as DATA_PEDIDO
		,CONVERT(DATE,P.DTA_ENTREGA) AS DATA_RECEBIMENTO_PEDIDO
		,CONVERT(DATE,P.DTA_ENTREGA) AS DATA_RECEBIMENTO		
		,NULL
		,NULL AS QTD_PEDIDO
		,NULL AS QTD_RECEBIDA	
		,'Pendente' as [STATUS_PEDIDO]
		,BI.dbo.fn_FormataVlr_Excel(P.VAL_PEDIDO) AS VLR_TOTAL_PEDIDO
		,NULL AS VLR_TOTAL_RECEBIMENTO		
		,'Pedido Normal' as TIPO_PEDIDO
		--,(CASE WHEN DATEADD(D,7,P.DTA_ENTREGA) < GETDATE() AND PP.QTD_RECEBIDA = 0 THEN 'Expirado' ELSE 'Valido' END) AS VALIDADE_PEDIDO
		,'Cancelado' AS VALIDADE_PEDIDO
    FROM
		[192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO_CANCELADO] AS P
    WHERE 1 = 1
		AND CONVERT(DATE,P.DTA_EMISSAO) between CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)