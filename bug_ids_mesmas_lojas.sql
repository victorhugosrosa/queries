-- ------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------------------
	DECLARE @TAB_PEDIDOS_ERRO AS TABLE
	(
		ID VARCHAR(50)
		,COD_FORNECEDOR INT
		,DATA DATE
		,QTD_LOJAS_MESMO_ID INT
		,QTD_PEDIDOS_MESMO_ID INT
		,FLG_AUTOMATICO	INT
	)

	INSERT INTO @TAB_PEDIDOS_ERRO
		SELECT
			ID
			,COD_FORNECEDOR
			,DATA
			,COUNT(DISTINCT COD_LOJA) QTD_LOJAS_MESMO_ID
			,COUNT(DISTINCT COD_PEDIDO) QTD_pedidos_ID
			,FLG_AUTOMATICO	
		FROM
			COMPRAS_PEDIDOS
		WHERE 1=1
			and DATA >= CONVERT(date,getdate()-90)
			AND COD_PEDIDO IS NOT NULL
			--and COD_FORNECEDOR = 15866
		GROUP BY
			ID
			,COD_FORNECEDOR
			,DATA
			,FLG_AUTOMATICO	
		HAVING
			COUNT(DISTINCT COD_LOJA) <> COUNT(DISTINCT COD_PEDIDO)
		ORDER BY
			DATA

-- ------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------------------	
	DECLARE @TAB_PEDIDOS_ZEUS AS TABLE
	(
		COD_FORNECEDOR INT
		,COD_LOJA INT
		,DATA DATE
		,MAX_PEDIDO INT
		,QTD_PEDIDO	INT
	)

	INSERT INTO @TAB_PEDIDOS_ZEUS		
		SELECT --top 10 *
			P.COD_PARCEIRO
			,P.COD_LOJA
			,CONVERT(DATE,P.DTA_EMISSAO) as DATA
			,max(P.NUM_PEDIDO) max_pedido
			,count(distinct P.NUM_PEDIDO) as qtd_pedido
			--,SUM(PP.VAL_TABELA*PP.QTD_PEDIDO) AS VLR_PEDIDO		
		FROM
			[192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO] AS P
			INNER JOIN [192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO_PRODUTO] AS PP
				ON 1=1
				and P.NUM_PEDIDO = PP.NUM_PEDIDO
				AND P.COD_LOJA = PP.COD_LOJA
				AND P.COD_PARCEIRO = PP.COD_PARCEIRO
			INNER JOIN @TAB_PEDIDOS_ERRO AS TPE
				ON 1=1
				AND P.COD_PARCEIRO = TPE.COD_FORNECEDOR
				AND CONVERT(DATE,P.DTA_EMISSAO) = CONVERT(DATE,TPE.DATA)
		WHERE 1=1
			--AND P.COD_PARCEIRO = 15383
			--AND CONVERT(DATE,P.DTA_EMISSAO) = CONVERT(DATE,'2016-03-14')
		GROUP BY
			P.COD_PARCEIRO
			,P.COD_LOJA
			--,P.NUM_PEDIDO
			,CONVERT(DATE,P.DTA_EMISSAO)
		ORDER BY
			CONVERT(DATE,P.DTA_EMISSAO)
		
-- ------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------------------------------------------		
select * from @TAB_PEDIDOS_ERRO where cod_fornecedor = 14536
select * from @TAB_PEDIDOS_ZEUS where cod_fornecedor = 14536


/*
	UPDATE P
	SET
		P.COD_PEDIDO = PZ.MAX_PEDIDO
	FROM
		BI.dbo.COMPRAS_PEDIDOS AS P
		INNER JOIN @TAB_PEDIDOS_ZEUS AS PZ
			ON 1=1
			AND P.COD_FORNECEDOR = PZ.COD_FORNECEDOR
			AND P.COD_LOJA = PZ.COD_LOJA
			AND CONVERT(DATE,P.DATA) = CONVERT(DATE,PZ.DATA)
	WHERE 1=1
		AND P.COD_PEDIDO <> PZ.MAX_PEDIDO
*/

/*

select * from @TAB_PEDIDOS_ERRO where cod_fornecedor = 15383
select * from @TAB_PEDIDOS_ZEUS where cod_fornecedor = 15383


SELECT DISTINCT
	P.COD_FORNECEDOR
	,P.COD_LOJA
	,P.ID
	,P.DATA
	,P.COD_PEDIDO
	,PZ.MAX_PEDIDO
	,PZ.QTD_PEDIDO
FROM
	BI.dbo.COMPRAS_PEDIDOS AS P
	INNER JOIN @TAB_PEDIDOS_ZEUS AS PZ
		ON 1=1
		AND P.COD_FORNECEDOR = PZ.COD_FORNECEDOR
		AND P.COD_LOJA = PZ.COD_LOJA
		AND CONVERT(DATE,P.DATA) = CONVERT(DATE,PZ.DATA)
WHERE 1=1
	--AND P.COD_FORNECEDOR = 15383

*/
