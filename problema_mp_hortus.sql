SELECT
	CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,CP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO	
	,CP.COD_FORNECEDOR
	,CF.DESCRICAO AS NO_FORNECEDOR
	,(SELECT VLR_METADADO FROM CADASTRO_CAD_PRODUTO_METADADOS TPM WHERE TPM.COD_PRODUTO = CP.COD_PRODUTO AND TPM.COD_METADADO = 2) AS [MTD ORG PRODUCAO]
	,(SELECT VLR_METADADO FROM CADASTRO_CAD_PRODUTO_METADADOS TPM WHERE TPM.COD_PRODUTO = CP.COD_PRODUTO AND TPM.COD_METADADO = 1 AND TPM.VLR_METADADO = 1) AS [MTD MARCA PROPRIA]
	,(SELECT VLR_METADADO FROM CADASTRO_CAD_PRODUTO_METADADOS TPM WHERE TPM.COD_PRODUTO = CP.COD_PRODUTO AND TPM.COD_METADADO = 18 AND TPM.VLR_METADADO = 1) AS [MTD PRODUCAO PROPRIA]	
FROM
	BI_CAD_PRODUTO AS CP
	LEFT JOIN BI_CAD_FORNECEDOR AS CF
		ON CP.COD_FORNECEDOR = CF.COD_FORNECEDOR
WHERE 1=1
	--AND CP.FORA_LINHA = 'N'
	AND CP.COD_DEPARTAMENTO = 6
	AND CP.COD_SECAO IN (42,50)
	--AND CP.COD_PRODUTO IN (SELECT COD_PRODUTO FROM CADASTRO_CAD_PRODUTO_METADADOS TPM WHERE TPM.COD_PRODUTO = CP.COD_PRODUTO AND TPM.COD_METADADO = 1 AND TPM.VLR_METADADO = 1)
ORDER BY
	CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
	,CP.NO_GRUPO
	,CP.DESCRICAO
	
	
/*

SELECT * FROM CADASTRO_CAD_METADADOS

SELECT * FROM CADASTRO_CAD_PRODUTO_METADADOS WHERE COD_METADADO = 2

*/