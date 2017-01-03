declare @rollback table

(dta_extrato date,
 cod_produto varchar (8) ,
 des_produto text,
 tipo_operação int,
 num_pdv int,
 descricao text,
 des_docto varchar (8000) ,
 quantidade int,
 val_venda money,
 val_custo_rep money,
 val_custo_medio money,
 val_custo_sicms money )

insert into @rollback
select
'07/09/2013'
,00991676
,'CERVEJA MINI GARRAFA ESTRELLA GALICIA 200ML'
,1
,null
,'estoque inicial'
,null
,45800
,null
,null
,null
,null


insert into @rollback  exec [dbo].[STP_PROD_EXTRATO_ANA] '07/09/2013' , '01/08/2014' , '3' , '00991676' ,0,0


insert into @rollback
select
'20130105'
,00991676
,'CERVEJA MINI GARRAFA ESTRELLA GALICIA 200ML'
,1
,null
,'venda'
,null
,-800
,null
,null
,null
,null

insert into @rollback
select
'20130108'
,00991676
,'CERVEJA MINI GARRAFA ESTRELLA GALICIA 200ML'
,1
,null
,'venda'
,null
,-800
,null
,null
,null
,null







select * from @rollback