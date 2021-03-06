SELECT
	PRODUTO_SKU.DESCRICAO
	,bi.dbo.fn_FormataVlr_Excel(sum(PEDIDO_ITEM.[QUANTIDADE]))
FROM
	[dbCestaNatal].[dbo].[SMCB_PEDIDO] as PEDIDO WITH(NOLOCK)
		INNER JOIN [dbCestaNatal].[dbo].[SMCB_PEDIDO_ITEM] AS PEDIDO_ITEM WITH(NOLOCK) ON (PEDIDO.IDPEDIDO = PEDIDO_ITEM.IDPEDIDO)
		--INNER JOIN [dbCestaNatal].[dbo].[SMCB_STATUS] AS STATUS_PEDIDO_ITEM WITH(NOLOCK) ON (PEDIDO_ITEM.[STATUS] = STATUS_PEDIDO_ITEM.IDSTATUS)
		INNER JOIN [dbCestaNatal].[dbo].[SMCB_PRODUTO_SKU] AS PRODUTO_SKU WITH(NOLOCK) ON (PEDIDO_ITEM.IDPRODUTO_SKU = PRODUTO_SKU.IDPRODUTO_SKU)
		LEFT JOIN [dbCestaNatal].[dbo].[SMCB_PRODUTO_PLU] AS PRODUTO_PLU WITH(NOLOCK) ON (PRODUTO_SKU.IDPRODUTO_PLU = PRODUTO_PLU.IDPRODUTO_PLU)
WHERE 1 = 1
	AND PEDIDO_ITEM.[STATUS] <> 2
	AND PEDIDO.[STATUS] <> 2
	AND CONVERT(DATE,PEDIDO_ITEM.DATA_CRIACAO) >= CONVERT(DATE,GETDATE()-180)
group by
	PRODUTO_SKU.DESCRICAO
	
	
SELECT
	CP.DESCRICAO
	,bi.dbo.fn_FormataVlr_Excel(SUM(M03AO)) AS QUANTIDADE	
FROM
	ZEUSRETAIL.DBO.ZAN_M03 AS PDV INNER JOIN AX2009_INTEGRACAO.DBO.TAB_CODIGO_BARRA AS CB ON (PDV.M03AH = CB.COD_EAN)
		LEFT JOIN BI.DBO.BI_CAD_PRODUTO AS CP ON (CB.COD_PRODUTO = CP.COD_PRODUTO)
			LEFT JOIN [dbCestaNatal].[dbo].[SMCB_PRODUTO_PLU] AS PPLU ON (CB.COD_PRODUTO COLLATE Latin1_General_CI_AS = PPLU.CODIGO_PLU)
WHERE 1 = 1
	AND CONVERT(DATE,PDV.M00AF) >=CONVERT(DATE,GETDATE()-180)
	AND CONVERT(DATE,PPLU.DATA_CRIACAO) >= CONVERT(DATE,GETDATE()-180)
	AND PDV.M00ZA = 7
	AND CB.COD_PRODUTO IN (394697,394703,394710,394727,543101,543118,543125,543200,543224,543248,543279,543309,543330,543361,543378,543392,543415,543439,1001449,1001450,1001451)
	AND PDV.M00AD NOT IN (SELECT DISTINCT [NUMERO_CUPOM_FISCAL] FROM [dbCestaNatal].[dbo].[SMCB_PEDIDO])
GROUP BY
	CP.DESCRICAO

SELECT 
	PRODUTO.DESCRICAO 
	,ESTOQUE.[QTD_PRODUZIDA]
	,ESTOQUE.[META]
	,ESTOQUE.[QTD_DISPONIVEL]
FROM
	[dbCestaNatal].[dbo].[SMCB_PRODUTO_ESTOQUE] as ESTOQUE left join [dbCestaNatal].[dbo].[SMCB_PRODUTO_SKU] as PRODUTO on (ESTOQUE.IDPRODUTO_SKU = PRODUTO.IDPRODUTO_SKU)
where 1 = 1
	AND ESTOQUE.[DATA_PRODUCAO] > convert(date,GETDATE()-180)	
	AND ESTOQUE.STATUS = 1
order by
	PRODUTO.DESCRICAO 

