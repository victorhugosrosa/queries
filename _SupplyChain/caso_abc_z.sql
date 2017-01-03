SELECT
	CLASSIF_PRODUTO_LOJA
	,COUNT(COD_PRODUTO) AS QTD_PROD
FROM
	BI.dbo.BI_LINHA_PRODUTOS
WHERE 1=1
	AND COD_LOJA = 1
GROUP BY
	CLASSIF_PRODUTO_LOJA
ORDER BY
	CLASSIF_PRODUTO_LOJA

SELECT
	FORA_LINHA
	,COUNT(COD_PRODUTO) AS QTD_PROD
FROM
	BI.dbo.BI_LINHA_PRODUTOS
WHERE 1=1
	AND COD_LOJA = 1
	AND CLASSIF_PRODUTO_LOJA = 'Z'
GROUP BY
	FORA_LINHA
ORDER BY
	FORA_LINHA

SELECT
	COUNT(COD_PRODUTO) AS QTD_PROD_REMV_SECAO
FROM
	BI.dbo.BI_LINHA_PRODUTOS
WHERE 1=1
	AND COD_LOJA = 1
	AND CLASSIF_PRODUTO_LOJA = 'Z'
	AND FORA_LINHA = 'N'
	AND COD_SECAO not in (6,40,37,20,19,35,41,10)
	
	
SELECT
	CP.NO_DEPARTAMENTO
	,COUNT(LP.COD_PRODUTO) AS QTD_PROD
FROM
	BI.dbo.BI_LINHA_PRODUTOS AS LP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON LP.COD_PRODUTO = CP.COD_PRODUTO
WHERE 1=1
	AND LP.COD_LOJA = 1
	AND LP.CLASSIF_PRODUTO_LOJA = 'Z'
	AND LP.FORA_LINHA = 'N'
	AND LP.COD_SECAO not in (6,40,37,20,19,35,41,10)
GROUP BY
	CP.NO_DEPARTAMENTO
ORDER BY
	COUNT(LP.COD_PRODUTO) DESC

SELECT
	COUNT(COD_PRODUTO) AS QTD_PROD_SEM_NAO_REV
FROM
	BI.dbo.BI_LINHA_PRODUTOS
WHERE 1=1
	AND COD_LOJA = 1
	AND CLASSIF_PRODUTO_LOJA = 'Z'
	AND FORA_LINHA = 'N'
	AND COD_SECAO not in (6,40,37,20,19,35,41,10)
	and COD_DEPARTAMENTO not in (20)
	


SELECT
	COUNT(DISTINCT COD_PRODUTO) as QTD_VENDA_U52SEM
FROM
	BI.dbo.BI_VENDA_PRODUTO
WHERE 1=1
	AND
	(
	CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,'2015-10-08') AND CONVERT(DATE,'2015-11-29')
	OR
	CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,'2015-12-21') AND CONVERT(DATE,'2016-07-01')
	)
	AND COD_PRODUTO IN
	(
		SELECT COD_PRODUTO
		FROM
			BI.dbo.BI_LINHA_PRODUTOS
		WHERE 1=1
			AND COD_LOJA = 1
			AND CLASSIF_PRODUTO_LOJA = 'Z'
			AND FORA_LINHA = 'N'
			AND COD_SECAO not in (6,40,37,20,19,35,41,10)
			and COD_DEPARTAMENTO not in (20)
	)