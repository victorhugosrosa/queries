select
	LP.COD_LOJA
	,CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,LP.COD_PRODUTO
	,CP.DESCRICAO
	,BI.dbo.fn_FormataVlr_Excel(LP.VLR_VENDA) AS VLR_VENDA
	,BI.dbo.fn_FormataVlr_Excel(LP.VLR_OFERTA) AS VLR_OFERTA
	,BI.dbo.fn_FormataVlr_Excel(LP.VLR_VCMARCHE) AS VLR_VCMARCHE
from
	BI_LINHA_PRODUTOS as LP
	INNER JOIN BI_CAD_PRODUTO AS CP
		ON LP.COD_PRODUTO = CP.COD_PRODUTO
WHERE 1=1
	AND LP.COD_LOJA = 31
	AND LP.COD_DEPARTAMENTO IN (4,5,8)
ORDER BY
	LP.COD_LOJA
	,CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,CP.DESCRICAO
	
