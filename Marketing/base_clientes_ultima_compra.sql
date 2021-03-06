DECLARE @TAB_VENDA_CLIENTE AS TABLE
(
	[idCliente] VARCHAR(20)
	,DATA_ULTIMA_COMPRA DATE
)
INSERT INTO @TAB_VENDA_CLIENTE
SELECT
	(CASE WHEN [VOCE_MARCHE] IS NULL THEN (CASE WHEN [CONTA_CLIENTE] IS NULL THEN [NOTA_FISCAL_PAULISTA] ELSE [CONTA_CLIENTE] END) ELSE [VOCE_MARCHE] END) AS [idCliente]
	,max(DATA)
FROM
	[DW].[dbo].[CUPOM_CLIENTES] AS CC
WHERE 1=1
	AND CONVERT(DATE,DATA) >= CONVERT(DATE,'2014-01-01')
GROUP BY
	(CASE WHEN [VOCE_MARCHE] IS NULL THEN (CASE WHEN [CONTA_CLIENTE] IS NULL THEN [NOTA_FISCAL_PAULISTA] ELSE [CONTA_CLIENTE] END) ELSE [VOCE_MARCHE] END)


SELECT
	C.[idCliente]
	,[txtNome]
	,[txtCpf]
	,[txtEndereco]
	,[txtNumero]
	,[txtComplemento]
	,[txtBairro]
	,[txtCidade]
	,[txtCep]
	,[txtUf]
	,[txtTelefone]
	,[txtCelular]
	,[txtEmail]
	,[txtSexo]
	,[txtEstadoCivil]
	,[datNascimento]
	,[datUltimaAlteracaoCadastro]
	,[datCadastro]
	,[flgInadimplente]
	,[flgOptOutEmail]
	,[flgOptOutMalaDireta]
	,[flgOptOutTelefone]
	,[txtOrigemCadastro]
	,VC.DATA_ULTIMA_COMPRA
FROM
	[DTM].[dbo].[CLIENTES] AS C
	LEFT JOIN @TAB_VENDA_CLIENTE AS VC
		ON CONVERT(DOUBLE PRECISION, C.idCliente) = CONVERT(DOUBLE PRECISION, VC.idCliente)
WHERE 1=1
	AND txtNome <> 'VOCE MARCHE'