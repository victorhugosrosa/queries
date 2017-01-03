select * from
   (
	SELECT pl.[COD_PRODUTO]
		  --,pl.[COD_LOJA]
		  ,MAX(pl.VAL_MARGEM) as VS
		  ,MIN(pl.VAL_MARGEM) as VN
		  --,sum(case when pl.MARGEM_PRIORITARIA = 'S' then 1 else 0 end) as QtdSim
		  --,sum(case when pl.MARGEM_PRIORITARIA = 'N' then 1 else 0 end) as QtdNao
		  ,count(pl.[VAL_MARGEM]) as Qtd
		  ,STUFF(
				(
					select  --convert(varchar(3), tpf.cod_loja)+ 'p' + CONVERT(varchar,tpf.[VAL_CUSTO_EMBALAGEM])+' | ' 
							CONVERT(varchar,tpf.VAL_MARGEM)+' | ' 
					from    [Zeus_rtg].[dbo].[TAB_PRODUTO_LOJA] tpf
					where  1=1
					and  tpf.COD_PRODUTO = pl.COD_PRODUTO
					order by VAL_MARGEM
					for xml path('')
				),1,0,'') Concats
	  
		  
		  --,pl.[MARGEM_PRIORITARIA]
		  ,p.DES_PRODUTO
	  FROM [Zeus_rtg].[dbo].[TAB_PRODUTO_LOJA] as pl
		   inner join [Zeus_rtg].[dbo].[TAB_PRODUTO] as p
		   on pl.cod_produto = p.cod_produto
	       
	  where 1=1
	  and pl.MARGEM_PRIORITARIA = 'S'
	  and pl.[FORA_LINHA] = 'N'
	  --and pl.COD_PRODUTO = 73103
	  and COD_LOJA in (1,2,3,6,7,9,12,13,17,18,20,10,4,19)
	  group by pl.[COD_PRODUTO], p.DES_PRODUTO
	  ) as s
	  where 1=1
	  and VS <> VN
	  --order by qtdSim desc