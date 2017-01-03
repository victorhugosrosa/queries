
declare @tab_prod_novo as table
(
	itemid int
	,DTA_GRAVACAO dateTIME
)

insert into @tab_prod_novo
select
	CONVERT(INT,ITEMID)
	,min(DTA_GRAVACAO)
from
	[BI].[dbo].[CADASTRO_CAD_PRODUTO_NOVO]
group by
	CONVERT(INT,ITEMID)
	

update PN
SET
	PN.PRODUTO_NOVO = 1
FROM
	[BI].[dbo].[CADASTRO_CAD_PRODUTO_NOVO] AS PN
	INNER JOIN @tab_prod_novo T
		ON PN.ITEMID = T.itemid AND PN.DTA_GRAVACAO = T.DTA_GRAVACAO