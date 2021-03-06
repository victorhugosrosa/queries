DECLARE @COD_LOJA AS INT
SET @COD_LOJA = 1

WHILE @COD_LOJA <= 20
BEGIN

update ZEUS
set ZEUS.VAL_VENDA = BI.VLR_VENDA	
from BI.dbo.VW_PRECOS_VENDA_ATIVOS as BI  with ( NOLOCK)
	, AX2009_INTEGRACAO.dbo.DE_PARA_LOJAS as Lojas with ( NOLOCK)
	,[192.168.0.6].zeus_rtg.dbo.TAB_PRODUTO_loja  as ZEUS		
where 1 = 1		
and ZEUS.VAL_VENDA  <> BI.VLR_VENDA
and ZEUS.COD_PRODUTO = BI.COD_PRODUTO
and ZEUS.COD_LOJA	 = BI.COD_LOJA
and Lojas.COD_LOJA	 = BI.COD_LOJA
and BI.COD_LOJA = @COD_LOJA
and BI.COD_LOJA NOT IN (9,19)
and isnull(BI.VLR_VENDA,0) <> 0
AND BI.COD_PRODUTO IN
(
	SELECT TOP 200 BI.COD_PRODUTO
	from BI.dbo.VW_PRECOS_VENDA_ATIVOS as BI  with ( NOLOCK)
		, AX2009_INTEGRACAO.dbo.DE_PARA_LOJAS as Lojas with ( NOLOCK)
		,[192.168.0.6].zeus_rtg.dbo.TAB_PRODUTO_loja  as ZEUS		
	where 1 = 1		
	and ZEUS.VAL_VENDA <> BI.VLR_VENDA
	and ZEUS.COD_PRODUTO = BI.COD_PRODUTO
	and ZEUS.COD_LOJA	 = BI.COD_LOJA
	and Lojas.COD_LOJA	 = BI.COD_LOJA
	and BI.COD_LOJA = @COD_LOJA
	and BI.COD_LOJA NOT IN (9,19)
	and isnull(BI.VLR_VENDA,0) <> 0
)

SET @COD_LOJA = @COD_LOJA + 1

END