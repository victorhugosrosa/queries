DECLARE @TAB_H AS TABLE
(
	COD_DEPARTAMENTO INT
	,NO_DEPARTAMENTO VARCHAR(50)
	,COD_SECAO INT
	,NO_SECAO VARCHAR(50)
)

INSERT INTO @TAB_H
SELECT DISTINCT
	COD_DEPARTAMENTO
	,NO_DEPARTAMENTO
	,COD_SECAO
	,NO_SECAO
FROM
	BI_CAD_HIERARQUIA_PRODUTO AS H

SELECT
	VS.COD_LOJA
	,YEAR(VS.DATA) AS ANO
	,MONTH(VS.DATA) AS MES
	,NO_DEPARTAMENTO
	,NO_SECAO
	,BI.dbo.fn_FormataVlr_Excel(SUM(VS.VLR_VENDA)) AS VLR_VENDA
	,BI.dbo.fn_FormataVlr_Excel(SUM(VS.QTD_CUPOM_SECAO)) AS QTD_CUPOM_SECAO
FROM
	BI.DBO.BI_VENDA_SECAO AS VS
	INNER JOIN @TAB_H AS H
		ON 1=1
		AND VS.COD_DEPARTAMENTO = H.COD_DEPARTAMENTO
		AND VS.COD_SECAO = H.COD_SECAO
WHERE 1=1
	AND CONVERT(DATE,VS.DATA) >= '20120601'
	AND VS.COD_LOJA = 2
GROUP BY
	VS.COD_LOJA
	,YEAR(VS.DATA)
	,MONTH(VS.DATA)
	,NO_DEPARTAMENTO
	,NO_SECAO
ORDER BY
	VS.COD_LOJA
	,NO_DEPARTAMENTO
	,NO_SECAO
	,YEAR(VS.DATA)
	,MONTH(VS.DATA)
