
UPDATE PF
SET
	VAL_CUSTO_EMBALAGEM = (select VAL_CUSTO_EMBALAGEM from zeus_rtg.dbo.tab_produto_fornecedor as tpf where pf.COD_PRODUTO = tpf.COD_PRODUTO and pf.COD_FORNECEDOR = tpf.COD_FORNECEDOR and tpf.COD_LOJA = 1)
	,QTD_EMBALAGEM_COMPRA = (select QTD_EMBALAGEM_COMPRA from zeus_rtg.dbo.tab_produto_fornecedor as tpf where pf.COD_PRODUTO = tpf.COD_PRODUTO and pf.COD_FORNECEDOR = tpf.COD_FORNECEDOR and tpf.COD_LOJA = 1)
from
	zeus_rtg.dbo.tab_produto_fornecedor as pf
where 1 = 1
	and cod_loja in (22,23,24)
	--and cod_produto = 992592
	--and cod_fornecedor = 2078