/*
select * from [AX2009_INTEGRACAO].DBO.TAB_CODIGO_BARRA WHERE COD_PRODUTO = 1014377 
*/

DECLARE @DATA_INI AS DATE = convert(date,'20140101')
DECLARE @DATA_FIM  AS DATE = convert(date,'20141102')

SELECT
	CAPA.COD_LOJA
	,CAPA.COD_OPERADOR AS CodOp
	,fz.[Nome] as NomeOp
	,dbo.fn_FormataVlr_Excel(SUM(VLR_VENDA)) AS VALOR
FROM	
	BI_VENDA_CUPOM_CAPA AS CAPA
	INNER JOIN BI_VENDA_CUPOM_PRODUTO AS PROD
		ON 1=1
		AND CAPA.CUPOM_HASH = PROD.CUPOM_HASH
	LEFT JOIN [ZeusRetail].[dbo].[tab_funcionario] as fz
		on fz.cod_funcionario = CAPA.COD_OPERADOR
WHERE 1=1
	AND CONVERT(DATE,CAPA.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
	AND PROD.COD_PRODUTO = 1014377
GROUP BY
	CAPA.COD_LOJA
	,CAPA.COD_OPERADOR
	,fz.[Nome] 