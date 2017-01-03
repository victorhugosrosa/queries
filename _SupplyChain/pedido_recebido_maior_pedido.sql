	SELECT	
		P.COD_LOJA
		,P.COD_PARCEIRO
		,P.NUM_PEDIDO
		,PP.COD_PRODUTO
		,PP.QTD_PEDIDO
		,PP.QTD_RECEBIDA	
    FROM
		[192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO] AS P
		INNER JOIN [192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO_PRODUTO] AS PP
			ON 1=1
			and P.NUM_PEDIDO = PP.NUM_PEDIDO
			AND P.COD_LOJA = PP.COD_LOJA
			AND P.COD_PARCEIRO = PP.COD_PARCEIRO
    WHERE 1 = 1
		--AND CONVERT(DATE,P.DTA_EMISSAO) between CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		AND PP.QTD_EMBALAGEM <> 0
		and P.NUM_PEDIDO = 1198353