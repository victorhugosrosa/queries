select * from BI_CAD_PRODUTO where cod_produto in (1002093,1002094,1002095,1002096)


select * from BI_CAD_PRODUTO where DESCRICAO like '%geleia%essencial%'


select * from [192.168.0.6].zeus_rtg.dbo.tab_produto where cod_produto in (1002093,1002094,1002095,1002096)


select * from [192.168.0.6].zeus_rtg.dbo.tab_produto_loja where cod_produto in (1002093,1002094,1002095,1002096)

select * from [192.168.0.6].zeus_rtg.dbo.TAB_PRODUTO_SAIDA with(nolock) where cod_produto in (1002093,1002094,1002095,1002096) and val_custo_sicms > 0