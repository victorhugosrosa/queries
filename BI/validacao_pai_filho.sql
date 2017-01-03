select
	COD_FORNECEDOR
	,CONVERT(VARCHAR,COD_PRODUTO) + '_' + CONVERT(VARCHAR,COD_LOJA)
	,DES_REFERENCIA
	,VAL_CUSTO_EMBALAGEM
	,QTD_EMBALAGEM_COMPRA
from
	zeus_rtg.dbo.tab_produto_fornecedor
where 1 = 1
	and cod_fornecedor = 623

select
	COD_FORNECEDOR
	,CONVERT(VARCHAR,COD_PRODUTO) + '_' + CONVERT(VARCHAR,COD_LOJA)
	,DES_REFERENCIA
	,VAL_CUSTO_EMBALAGEM
	,QTD_EMBALAGEM_COMPRA
from
	zeus_rtg.dbo.tab_produto_fornecedor
where 1 = 1
	and cod_fornecedor = 101684
	
	
