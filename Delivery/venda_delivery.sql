DECLARE @TAB_CUPOM_DELIVERY AS TABLE
(
	CUPOM_HASH VARCHAR(22)
)

INSERT INTO @TAB_CUPOM_DELIVERY
	SELECT DISTINCT
		CUPOM_HASH
	FROM
		BI_VENDA_CUPOM_PRODUTO
	WHERE 1=1
		AND COD_PRODUTO in (119122,448086)
		AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,'20141001') AND CONVERT(DATE,'20141031')

SELECT
	COD_LOJA
	,SUM(VLR_CUPOM) AS VLR_VENDA
FROM
	BI_VENDA_CUPOM_CAPA AS C
	INNER JOIN @TAB_CUPOM_DELIVERY AS D
		ON 1=1
		AND C.CUPOM_HASH = D.CUPOM_HASH
GROUP BY
	COD_LOJA