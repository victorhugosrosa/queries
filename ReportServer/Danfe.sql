SELECT
	c.no_comprador
	,p.descricao as no_produto
	,s.[Cod_produto]
	,s.[Cod_fornecedor]
	,[nNF]
	,[val_custo_embalagem] as vlrProdZeus
	,dbo.fn_FormataVlr_Excel(vUnCom) AS vlrProdDanfe
	,dbo.fn_FormataVlr_Excel(vUnTrib) as vlrProdDanfe2
	,dbo.fn_FormataVlr_Excel([QTD_EMBALAGEM_COMPRA]) as qtdEmbCompraZeus
	,[QTD_MINIMA_COMPRA] AS MULTIPLO
	,p.cod_secao
	,p.cod_grupo
	,[DtGravacao]
	,'NF'+[num_danfe] as DANFE
	,[cod_loja]
	,s.[PESADO]
	,dbo.fn_FormataVlr_Excel([qEmbalagem]) as qtdEmbDanfe
	--,[EMBALAGEM_CAD_PROD] as qtdEmbZeus
	,[DES_UNIDADE_COMPRA] as desEmbCompraZeus
	,[uTrib] as desEmbTDanfe
	,[qTrib]
	,[vUnCom]
	,[vDesc] AS vlrDesconto
FROM
	[CtrlNfe].[dbo].[vw_ANALISE_CRITICA_DANFE] as s inner join bi.dbo.BI_CAD_PRODUTO  as p  with (NOLOCK) on (s.Cod_produto = p.cod_produto)
		inner join bi.dbo.COMPRA_GRUPO_COMPRADORES  as c with (NOLOCK) on (c.cod_secao = p.cod_secao and c.cod_grupo = p.cod_grupo)  
where 1=1
	and DtGravacao between '20130809 8:00' and '20130812 8:00'
	and STATUS = 'S'