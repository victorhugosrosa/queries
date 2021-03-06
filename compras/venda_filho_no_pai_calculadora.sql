SELECT TOP 1000
	*
FROM
	BI.DBO.BI_CAD_PRODUTO AS CP
	LEFT JOIN BI.DBO.[COMPRAS_DEPARA_PRODUTO] AS DEPARA
		ON DEPARA.[COD_PRODUTO_DST] = CP.COD_PRODUTO
WHERE 1=1 
	AND CP.COD_PRODUTO = 12782



			SELECT
				VP.[COD_LOJA]
				,DBO.ISO_WEEK(DATA) AS ISOWEEK
				,ISNULL(DEPARA.[COD_PRODUTO_ORG],VP.COD_PRODUTO) AS COD_PRODUTO
				, SUM([QTDE_PRODUTO]) AS XXX
			FROM
				#TAB_RETORNO AS L
				LEFT JOIN BI.DBO.[COMPRAS_DEPARA_PRODUTO] AS DEPARA
					ON DEPARA.[COD_PRODUTO_ORG] = L.COD_PRODUTO
				LEFT [BI].[DBO].[BI_VENDA_PRODUTO] AS VP
					ON 1=1
					AND L.COD_LOJA = VP.COD_LOJA
					AND ISNULL(DEPARA.[COD_PRODUTO_DST],L.COD_PRODUTO) = VP.COD_PRODUTO	
			WHERE 1=1
				AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DATAINI) AND CONVERT(DATE,@DATAFIM)
				AND COD_LOJA = 3
			GROUP BY
				VP.[COD_LOJA]
				,DBO.ISO_WEEK(DATA)
				,ISNULL(DEPARA.[COD_PRODUTO_ORG],VP.COD_PRODUTO)
				
			