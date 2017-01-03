

		--Estoque dos Intens A1 Não Pesáveis 
		SELECT  TOP 10 CONVERT(date,DATA) as cData
			   ,m.[COD_PRODUTO] as cCodProd
			   ,l.NO_LOJA as cNoLoja
			   ,m.[COD_LOJA] as cCodLoja
			   ,QTD_ESTOQUE as cQtdEst
			   ,DESCRICAO AS cNoProd
			   ,PESADO As cPesado
			   ,CLASSIF_PRODUTO_LOJA as cABC
		  FROM dw.dbo.estoque as m
				inner join 
				bi.dbo.BI_CAD_PRODUTO as p
				on 1=1
				and p.cod_produto = m.COD_PRODUTO
				and PESADO = 'N'
			    inner join
			    bi.dbo.BI_CAD_LOJA2 as l
			    on l.COD_LOJA = m.COD_LOJA
				inner join bi.dbo.COMPRAS_ESTATISTICA_PRODUTO as e
				on e.cod_produto = m.COD_PRODUTO
				and e.cod_loja = m.COD_LOJA				
		  where 1=1
			  and CONVERT(DATE,DATA) = CONVERT(date,GETDATE()-1)
			  and e.CLASSIF_PRODUTO_LOJA in (`1`)
			  and m.cod_loja in (`2`)
			  and p.cod_departamento not in (16,99,18,17,15)
		  order by QTD_ESTOQUE
		  --and COD_SECAO = 24 --bebidas
		  --group by l.NO_LOJA, m.[COD_LOJA]

	