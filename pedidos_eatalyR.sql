	SELECT
		P.COD_PARCEIRO as [Cod Forn]
		,f.[DES_FORNECEDOR] as Fornecedor		
        ,P.NUM_PEDIDO as [Pedido]
		,P.COD_LOJA as [Loja]
		,PP.COD_PRODUTO as [Plu]
		,PROD.DES_PRODUTO as [Produto]
		,bi.dbo.fn_FormataVlr_Excel(PP.QTD_PEDIDO) as [Qtd Pedido]
		,bi.dbo.fn_FormataVlr_Excel(PP.VAL_TABELA*PP.QTD_PEDIDO) as [Vlr Pedido]		
		,convert(date,P.DTA_EMISSAO) as [Data Emissao]
		,convert(date,P.DTA_ENTREGA) as [Data Entrega]	
	FROM
		[192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO] AS P
		INNER JOIN [192.168.0.6].[ZEUS_RTG].DBO.[TAB_PEDIDO_PRODUTO] AS PP
			ON 1=1
			and P.NUM_PEDIDO = PP.NUM_PEDIDO
			AND P.COD_LOJA = PP.COD_LOJA
			AND P.COD_PARCEIRO = PP.COD_PARCEIRO
		INNER JOIN [192.168.0.6].[Zeus_rtg].[dbo].[TAB_FORNECEDOR] AS F
			ON F.cod_fornecedor = p.cod_parceiro
		INNER JOIN [192.168.0.6].[Zeus_rtg].[dbo].[TAB_PRODUTO] AS PROD
			ON PP.COD_PRODUTO = PROD.COD_PRODUTO
	where 1=1
		and CONVERT(date,[DTA_EMISSAO]) between convert(date,'20150901') and convert(date,'20150930')
		and p.cod_loja = 33
	