SELECT --TOP 100
	VG.COD_LOJA
	,MONTH(VG.DATA) AS MES
	,BI.dbo.fn_FormataVlr_Excel(SUM(VG.VLR_VENDA)) AS VALOR_VENDA
	,BI.dbo.fn_FormataVlr_Excel(SUM(MG.VLR_META)) AS VALOR_META
	,BI.dbo.fn_FormataVlr_Excel(SUM(VG.VLR_VENDA) / SUM(MG.VLR_META)) AS PERC_META
	,BI.dbo.fn_FormataVlr_Excel(SUM(QG.VLR_QUEBRA*-1)) AS VALOR_QUEBRA
FROM 
	[BI].[dbo].[BI_VENDA_GRUPO]	AS VG
	LEFT JOIN [BI].[dbo].[BI_VENDA_META_GRUPO] AS MG
		ON 1=1
		AND VG.COD_LOJA = MG.COD_LOJA
		AND VG.DATA = MG.DATA
		AND VG.COD_DEPARTAMENTO = MG.COD_DEPARTAMENTO
		AND VG.COD_SECAO = MG.COD_SECAO
		AND VG.COD_GRUPO = MG.COD_GRUPO
	LEFT JOIN [BI].[dbo].[BI_QUEBRA_GRUPO] AS QG
		ON 1=1
		AND VG.COD_LOJA = QG.COD_LOJA
		AND VG.DATA = QG.DATA
		AND VG.COD_DEPARTAMENTO = QG.COD_DEPARTAMENTO
		AND VG.COD_SECAO = QG.COD_SECAO
		AND VG.COD_GRUPO = QG.COD_GRUPO
WHERE 1=1
	AND VG.COD_SECAO = 44
	AND CONVERT(DATE,VG.DATA) >= CONVERT(DATE,'20150101')
GROUP BY
	VG.COD_LOJA
	,MONTH(VG.DATA)
ORDER BY
	VG.COD_LOJA
	,MONTH(VG.DATA)