SELECT
	[COD_LOJA]
	,[DATA]
	,[COD_DEPARTAMENTO]
	,[COD_SECAO]
	,[COD_GRUPO]
	,SUM(CASE WHEN [QTD_ESTOQUE] < 0 THEN 0 ELSE [QTD_ESTOQUE] END)
	,SUM((CASE WHEN [QTD_ESTOQUE] < 0 THEN 0 ELSE [QTD_ESTOQUE] END) * [VLR_CUSTO_UN])
FROM
	[BI].[dbo].[BI_ESTOQUE_PRODUTO_DIA] AS EPD
	INNER JOIN BI.DBO.BI_CAD_PRODUTO AS CP
		ON EPD.COD_PRODUTO = CP.COD_PRODUTO
WHERE 1=1
	AND COD_LOJA = 1
	AND CONVERT(DATE,EPD.DATA) = CONVERT(DATE,GETDATE()-1)
	AND CP.COD_DEPARTAMENTO = 2
GROUP BY
	[COD_LOJA]
	,[DATA]
	,[COD_DEPARTAMENTO]
	,[COD_SECAO]
	,[COD_GRUPO]


SELECT
SUM(QTD_ESTOQUE)
,SUM(ESTOQUE_CUSTO)
FROM
	[BI].[dbo].[BI_ESTOQUE_GRUPO] AS EG
	INNER JOIN [BI].[dbo].[BI_CAD_HIERARQUIA_PRODUTO] AS H
		ON 1=1
		AND EG.COD_DEPARTAMENTO = H.COD_DEPARTAMENTO
		AND EG.COD_SECAO = H.COD_SECAO
		AND EG.COD_GRUPO = H.COD_GRUPO
WHERE 1=1
	AND COD_LOJA = 1
	AND CONVERT(DATE,EG.DATA) = CONVERT(DATE,GETDATE()-1)
	AND EG.COD_DEPARTAMENTO = 2
	--AND EG.COD_SECAO = 7
	--AND EG.COD_GRUPO = 11