SELECT
	COD_LOJA
	,PV.COD_PRODUTO
	,CP.DESCRICAO
	,PV.DTA_INI
	,PV.DTA_FIM
	,PV.DESCRICAO
	,PV.VALOR
	,PV.DTA_GRAVACAO
FROM
	BI_PRECO_VENDA AS PV INNER JOIN BI_CAD_PRODUTO AS CP ON (PV.COD_PRODUTO = CP.COD_PRODUTO)
WHERE 1 = 1
	AND PV.COD_PRODUTO IN (541688,541664,541671,538947,538909)
ORDER BY
	PV.DTA_GRAVACAO DESC
	,COD_LOJA
	,PV.COD_PRODUTO
	
	
SELECT
	COD_LOJA
	,PC.COD_PRODUTO
	,CP.DESCRICAO
	,PC.DTA_INI
	,PC.DTA_FIM
	,PC.DESCRICAO
	,PC.VLR_EMB_COMPRA
	,PC.DTA_GRAVACAO
FROM
	BI_PRECO_COMPRA AS PC INNER JOIN BI_CAD_PRODUTO AS CP ON (PC.COD_PRODUTO = CP.COD_PRODUTO)
WHERE 1 = 1
	AND PC.COD_PRODUTO IN (541688,541664,541671,538947,538909)
ORDER BY
	PC.DTA_GRAVACAO DESC
	,COD_LOJA
	,PC.COD_PRODUTO