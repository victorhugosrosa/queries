SELECT
	[COD_PRODUTO]
	,[COD_FORNECEDOR]
	,[IPI_VLR]
	,[IPI_PERC]
	,[CST_ICMS_ENTRADA]
	,[ALIQUOTA_ICMS_ENTRADA]
	,[REDUCAO_ICMS_ENTRADA]
	,[IVA]
	,[PAUTA_GOV]
	,[CST_ICMS_SAIDA]
	,[ALIQUOTA_ICMS_SAIDA]
	,[REDUCAO_ICMS_SAIDA]
	,[PIS]
	,[COFINS]
	,[DTA_GRAVACAO]
	,[DTA_ALTERACAO]
	,[CREDITA_PISCOFINS]
FROM
	[BI].[dbo].[BI_PRECO_IMPOSTOS]
WHERE 1 = 1
	AND [COD_FORNECEDOR] = 14721
	AND [COD_PRODUTO] IN 
	(
	29360,
	3674,
	88824,
	89586,
	90070,
	90704,
	91510,
	94108,
	97802
	)