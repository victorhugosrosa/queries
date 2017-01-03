SELECT --v.[COD_LOJA] as Loja
	   v.[COD_DEPARTAMENTO] as Dep
	  ,isnull(sum(v.[VLR_VENDA]),0) as [Venda]
	  ,isnull(SUM(m.[VLR_META]),0) as [Meta]
	  ,isnull(nullif(sum (v.[VLR_VENDA])/sum(m.[VLR_META]),0),0) as Perc
FROM [BI].[dbo].[BI_VENDA_GRUPO] as v
     left join
	[BI].[dbo].[BI_VENDA_META_GRUPO] as m	   
	   on 1=1
	   and m.DATA = v.DATA
	   and m.COD_DEPARTAMENTO = v.COD_DEPARTAMENTO
	   and m.COD_SECAO = v.COD_SECAO
	   and m.COD_GRUPO = v.COD_GRUPO
	   and m.COD_LOJA = v.COD_LOJA
  where 1=1
  and m.DATA between convert(date,'20140101') and convert(date,'20140131')
--and m.COD_LOJA = 8
  group by v.[COD_DEPARTAMENTO]
  order by Meta desc
  
  
  
  
SELECT 
   m.[COD_LOJA] as Loja
  ,isnull(sum(v.[VALOR_TOTAL]),0) as Venda
  ,isnull(sum(m.VLR_META),0) as Meta
  ,isnull(nullif(sum (v.[VALOR_TOTAL])/sum(m.VLR_META),0),0) as Perc
  --,m.DATA
FROM [BI].[dbo].[BI_VENDA_META] AS m
left JOIN  [BI].dbo.BI_VENDA_CUPOM AS v
on m.COD_LOJA = v.COD_LOJA
and m.DATA = v.DATA
and m.COD_BASE = v.tipo

where 1=1
and m.DATA between convert(date,'20140101') and convert(date,'20140131')
and m.COD_LOJA = 8
group by m.[COD_LOJA]
having isnull(sum(m.VLR_META),0) > 0