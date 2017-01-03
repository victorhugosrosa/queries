Declare @DT_INI as Date = '05/01/2013'
declare @DT_FIM as Date = '10/11/2013'
declare @COD_LOJa as int = 9

declare @TableVar table ( 
DATA Date NULL,
VLR_PDV numeric(18,2) null ,
VLR_BI numeric(18,2) null ,
VLR_ZEUS numeric(18,2) null ,
DIF_BI int null ,
DIF_ZEUS int null
)

insert into @TableVar (DATA , VLR_PDV , VLR_BI , VLR_ZEUS)
select 
PDV.DATA ,
VLR_PDV ,
(
	select SUM(valor) as VLR_BI 
	from intranet.[dbo].BI_ANAL_TICKET 
	where cod_loja = @COD_LOJa 
	and data = PDV.DATA
	group by COD_LOJA , DATA
) as VLR_BI ,
(
	select SUM(VAL_TOTAL_PRODUTO) as VLR_ZEUS
	from Zeus_rtg.[dbo].TAB_PRODUTO_SAIDA 
	where cod_loja = @COD_LOJa 
	and DTA_SAIDA = PDV.DATA
	group by COD_LOJA , DTA_SAIDA
) as VLR_ZEUS

FROM (
--select 'Vendas no PDV'
	select data , SUM(VALOR_LIQuIDO) as VLR_PDV from [192.168.0.13].ZeusRetail.dbo.Vw_Marche_Produto_Cupons 
	where cod_loja = @COD_LOJa 
	and data between CONVERT (date, @DT_INI) and CONVERT (date, @DT_FIM)	
	group by DATA
) as PDV 
where 1 = 1

update @TableVar set DIF_BI = VLR_PDV - VLR_BI
update @TableVar set DIF_ZEUS = VLR_PDV - VLR_ZEUS

select * 
from @TableVar