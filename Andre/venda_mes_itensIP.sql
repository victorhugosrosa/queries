SELECT
	VP.COD_LOJA
	,YEAR(VP.DATA) AS ANO
	,MONTH(VP.DATA) AS MES
	,VP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,LP.FORA_LINHA
	,BI.DBO.FN_FORMATAVLR_EXCEL(SUM(VP.VALOR_TOTAL)) AS VLR_TOTAL
	,BI.DBO.FN_FORMATAVLR_EXCEL(SUM(VP.QTDE_PRODUTO)) AS QTD_TOTAL
FROM
	BI.dbo.BI_VENDA_PRODUTO AS VP
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON VP.COD_PRODUTO = CP.COD_PRODUTO	
	LEFT JOIN BI.DBO.BI_LINHA_PRODUTOS AS LP
		ON 1=1
		AND VP.COD_PRODUTO = LP.COD_PRODUTO
		AND VP.COD_LOJA = LP.COD_LOJA
WHERE 1=1
	AND CP.COD_PRODUTO IN (SELECT COD_PRODUTO FROM CADASTRO_CAD_PRODUTO_METADADOS TPM WHERE TPM.COD_METADADO = 4 and TPM.VLR_METADADO = 1)
	AND CONVERT(DATE,DATA) >= '2015-01-01'
	--AND LP.COD_LOJA not in (5)
	--AND LP.FORA_LINHA = 'N'
GROUP BY
	VP.COD_LOJA
	,YEAR(VP.DATA)
	,MONTH(VP.DATA)
	,VP.COD_PRODUTO
	,CP.DESCRICAO
	,CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,LP.FORA_LINHA