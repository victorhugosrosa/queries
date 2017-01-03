SELECT 
			   m.[COD_LOJA] as Loja
			  ,convert(date,m.DATA) as Data
			  ,datepart(dw,m.DATA) as DiaSem
			  ,isnull(sum(v.[VALOR_TOTAL]),0) as Venda
			  ,isnull(sum(m.VLR_META),0) as Meta
			  ,isnull(sum(v.[VALOR_TOTAL])/nullif(sum(m.VLR_META),0),0) as Perc
			  --,m.DATA
		  FROM [BI].[dbo].[BI_VENDA_META] AS m
			left JOIN 
			(
				select 
					VC.COD_LOJA
					,convert(date,VC.DATA) as DATA
					,isnull(sum(VC.[VALOR_TOTAL]),0) as [VALOR_TOTAL]
				FROM
					[BI].dbo.BI_VENDA_CUPOM AS VC
				WHERE 1=1
					AND DATA between convert(date,'2016-01-02') and convert(date,'2016-01-14')
				GROUP BY
					VC.COD_LOJA
					,convert(date,VC.DATA)
			) AS v			
			on m.COD_LOJA = v.COD_LOJA
			and m.DATA = v.DATA
			--and m.COD_BASE = v.tipo
		  where 1=1
		  and m.DATA between convert(date,'2016-01-02') and convert(date,'2016-01-14')
		  and m.COD_LOJA = 33
		  group by  m.[COD_LOJA],convert(date,m.DATA),datepart(dw,m.DATA) 
		  order by Data desc