declare @DateIni date = convert(date,'20140206')
declare @DateFim date = convert(date,'20140316')

SELECT NF.*, VENDA.VLR_VENDA, VENDA.QTD_VENDA FROM
(
	SELECT
		FN.COD_FORNECEDOR AS [CODFORN]
		,year(FN.DTA_EMISSAO) as ano
		,MONTH(FN.DTA_EMISSAO) as mes
		,FN.COD_LOJA AS [LOJA]
		,FP.COD_PRODUTO
		,CP.DESCRICAO
		,SUM(FP.VAL_TABELA * FP.QTD_ENTRADA) AS VAL_TOTAL_NF
		,SUM(FP.QTD_ENTRADA) AS QTD_ENTRADA
	FROM
		[192.168.0.6].ZEUS_RTG.DBO.TAB_FORNECEDOR_NOTA AS FN
			LEFT JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_FORNECEDOR_PRODUTO AS FP
				ON (FN.COD_FORNECEDOR = FP.COD_FORNECEDOR AND FN.NUM_NF_FORN = FP.NUM_NF_FORN AND FN.NUM_SERIE_NF = FP.NUM_SERIE_NF AND FN.COD_LOJA = FP.COD_LOJA)
				INNER JOIN BI_CAD_PRODUTO AS CP ON (FP.COD_PRODUTO = CP.COD_PRODUTO)
	WHERE 1 = 1
		AND FN.COD_FORNECEDOR = 102315--15866
		AND CONVERT(DATE,FN.DTA_EMISSAO) >= @DATEINI
		AND CONVERT(DATE,FN.DTA_EMISSAO) < @DATEFIM
	GROUP BY
		FN.COD_FORNECEDOR
		,year(FN.DTA_EMISSAO)
		,MONTH(FN.DTA_EMISSAO)
		,FN.COD_LOJA
		,FP.COD_PRODUTO
		,CP.DESCRICAO
) AS NF
LEFT JOIN 
(
	SELECT
		year(DATA) as ano
		,MONTH(DATA) as mes
		,COD_LOJA AS [LOJA]
		,COD_PRODUTO
		,SUM(VALOR_TOTAL) VLR_VENDA
		,SUM(QTDE_PRODUTO) QTD_VENDA
	FROM
		BI.DBO.BI_VENDA_PRODUTO
	WHERE 1 = 1
		AND CONVERT(DATE,DATA) >= @DATEINI
		AND CONVERT(DATE,DATA) < @DATEFIM
		AND COD_PRODUTO IN (SELECT DISTINCT COD_PRODUTO FROM AX2009_INTEGRACAO.dbo.TAB_PRODUTO_FORNECEDOR WHERE COD_FORNECEDOR = 102315)
	GROUP BY
		year(DATA)
		,MONTH(DATA)
		,COD_LOJA
		,COD_PRODUTO
) AS VENDA
ON (NF.LOJA = VENDA.LOJA AND NF.ano = VENDA.ano AND NF.mes = VENDA.mes AND NF.COD_PRODUTO = VENDA.COD_PRODUTO)

