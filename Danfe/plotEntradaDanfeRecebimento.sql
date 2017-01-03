select 
	   DtaEntradaRec
	  ,SUM(case when AutoQ = -1 then 1 else 0 end) as QtdSemEntrada
	  ,SUM(case when AutoQ = 0 then 1 else 0 end) as QtdManual
	  ,SUM(case when AutoQ = 1 then 1 else 0 end) as QtdAuto
	  ,COUNT(DtaEntradaRec) as QtdTotal

	 from
	(
		 SELECT  CONVERT(date,rec.DATA) as DtaEntradaRec
				--,rec.DAMFE 
				--,N2.DtaEntradaFinanc
				,ISNULL(N2.AutoQ,-1) as AutoQ

		  FROM  bi.[dbo].[VW_OCORECEB] as rec
				Left join
					(Select  num_danfe
							--,min(DTA_ENTRADA) as DtaEntradaFinanc
							,max(case when USUARIO_GRAVACAO = 'marcelo.frade' then 1 else 0 end) as AutoQ
					from [192.168.0.6].[Zeus_rtg].[dbo].[TAB_FORNECEDOR_NOTA]   --Entradas no financeiro
					where 1=1
					and CONVERT(date,DTA_ENTRADA) > '20140401' --Necessario para agilizar a consulta
					Group By num_danfe
				) as N2
				on 1=1
				AND N2.num_danfe = rec.DAMFE

		  WHERE 1=1
		  AND convert(date,rec.DATA) between convert(date,`1`) and convert(date,`2`)
		  and rec.[DAMFE] <> ''
		  and rec.cod_loja in (1,2,3,6,7,9,12,13,17,18,20,10,4,21,30)
		) as s
		
	where 1=1
	group by DtaEntradaRec
	