SELECT
	   lp.cod_loja
	  ,p.COD_PRODUTO AS COD_PRODUTO
      ,vlrTer.[COD_PRODUTO_TERCEIRO] AS COD_PRODUTO_PA
      ,vlrTer.[VLR_PRODUTO] as VLR_VENDA_PA
      ,pv.VLR_VENDA AS VLR_VENDA_MARCHE
      ,pv.VLR_VENDA-vlrTer.[VLR_PRODUTO] AS DIF
      --,vlrTer.[PROMOCAO] as PROMO_PA
      ,p.DESCRICAO as NO_PRODUTO
      ,vlrTer.[NO_PRODUTO_TERCEIRO]
      ,vlrTer.[DATA_EXTRACAO]
      ,p.COD_DEPARTAMENTO
      ,p.COD_SECAO
      ,p.COD_GRUPO
      ,p.NO_DEPARTAMENTO
      ,p.NO_SECAO
      ,p.NO_GRUPO
      ,p.COD_FORNECEDOR
      ,forn.DESCRICAO as NO_FORNECEDOR
      ,p.DESCRICAO AS NO_PRODUTO
      ,CLASSIF_PRODUTO
      ,pTer.[ANALIZADO]
      ,comp.COD_USUARIO
      ,comp2.NO_COMPRADOR      

FROM [BI].[dbo].[BI_PRECOS_TERCEIROS] as vlrTer
		inner join [BI].[dbo].[BI_CAD_PRODUTO_TERCEIROS] as pTer
		on vlrTer.COD_PRODUTO_TERCEIRO = pTer.cod_produto_terceiro
		inner join [BI].[dbo].BI_cad_produto as p
		on p.cod_produto = pTer.cod_produto_marche
		inner join [BI].[dbo].COMPRA_GRUPO_COMPRADORES as comp
		on p.COD_SECAO = comp.COD_SECAO and p.COD_GRUPO = comp.COD_GRUPO
		LEFT join [BI].[dbo].BI_CAD_FORNECEDOR as forn
		on p.COD_FORNECEDOR = forn.COD_FORNECEDOR
		left join bi.dbo.BI_LINHA_PRODUTOS as lp
		on lp.COD_PRODUTO = p.COD_PRODUTO
		left join bi.dbo.COMPRAS_CAD_COMPRADOR as comp2
		on comp2.COD_USUARIO = comp.COD_USUARIO
		left join bi.dbo.VW_PRECOS_VENDA_ATIVOS as pv
		on pv.COD_PRODUTO = p.COD_PRODUTO and lp.cod_loja = pv.cod_loja
		
		
where 1=1
	and pTer.cod_produto_marche is not null
	and DATA_EXTRACAO = (select max(data_extracao) from [BI].[dbo].[BI_PRECOS_TERCEIROS] where 1=1)
	and vlrTer.[PROMOCAO] = 0
	and lp.FORA_LINHA = 'N'
	and lp.COD_LOJA not in (7)
	and p.[PESADO] = 'N'
order by DATA_EXTRACAO, DIF DESC, COD_PRODUTO