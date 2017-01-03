SELECT --TOP 100
	YEAR(DATA) AS ANO
	,MONTH(DATA) AS MES	
	,(CASE
		WHEN VOCE_MARCHE IS NOT NULL OR CONTA_CLIENTE IS NOT NULL THEN 'VCM'
		WHEN NOTA_FISCAL_PAULISTA IS NOT NULL THEN 'CPF'
		ELSE 'N/I'
	END) AS TIPO_IDENTIFICACAO
	,COUNT(DISTINCT ID)	QTD_TICKETS
FROM
	DW.dbo.CUPOM_CLIENTES AS CC
WHERE 1=1
	AND CONVERT(DATE,DATA) >= CONVERT(DATE,'2014-01-01')
	AND COD_LOJA in (1,3,2,6,9,13,17,18,20,22,23,24,30)
GROUP BY
	YEAR(DATA)
	,MONTH(DATA)
	,(CASE
		WHEN VOCE_MARCHE IS NOT NULL OR CONTA_CLIENTE IS NOT NULL THEN 'VCM'
		WHEN NOTA_FISCAL_PAULISTA IS NOT NULL THEN 'CPF'
		ELSE 'N/I'
	END)
ORDER BY 1,2,3