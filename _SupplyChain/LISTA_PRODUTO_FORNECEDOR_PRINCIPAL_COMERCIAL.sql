DECLARE @TAB_PRODUTOS_A1_A2_N_UN AS TABLE
(
	COD_PRODUTO INT
)

INSERT INTO @TAB_PRODUTOS_A1_A2_N_UN	
	SELECT DISTINCT COD_PRODUTO	FROM
	(
		SELECT DISTINCT
			COD_PRODUTO
		FROM
			BI.DBO.CADASTRO_CAD_PRODUTO_METADADOS AS PM
		WHERE 1=1 
			AND COD_METADADO IN (16,17) AND VLR_METADADO = '1'
		
		UNION ALL
		
		SELECT DISTINCT
			COD_PRODUTO
		FROM
			BI.dbo.BI_LINHA_PRODUTOS AS LP
		WHERE 1=1
			AND CLASSIF_PRODUTO_LOJA IN ('A1','A2')
	) AS X
	
SELECT
	FP.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,FP.COD_FORNECEDOR
	,CF.DESCRICAO AS NO_FORNECEDOR
	,(CASE WHEN FA.COD_FORNECEDOR IS NOT NULL THEN 'PRINICPAL' ELSE '' END) AS FLG_PRINC
FROM
	[BI].dbo.BI_CAD_FORNECEDOR_PRODUTO AS FP
	INNER JOIN @TAB_PRODUTOS_A1_A2_N_UN AS TEMP
		ON FP.COD_PRODUTO = TEMP.COD_PRODUTO	
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON FP.COD_PRODUTO = CP.COD_PRODUTO
	INNER JOIN BI.dbo.BI_CAD_FORNECEDOR AS CF
		ON FP.COD_FORNECEDOR = CF.COD_FORNECEDOR
	LEFT JOIN [BI].[dbo].[SUPPLY_PRODUTO_FORN_PRINCIPAL_AUTO] AS FA
		ON 1=1
		AND FP.COD_PRODUTO = FA.COD_PRODUTO
		AND FP.COD_FORNECEDOR = FA.COD_FORNECEDOR
WHERE 1=1

ORDER BY
	FP.COD_FORNECEDOR
	,FP.COD_PRODUTO


/*
SELECT
	FA.COD_PRODUTO
	,CP.DESCRICAO AS NO_PRODUTO
	,FA.COD_FORNECEDOR
	,CF.DESCRICAO AS NO_FORNECEDOR
FROM
	[BI].[dbo].[SUPPLY_PRODUTO_FORN_PRINCIPAL_AUTO] AS FA
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON FA.COD_PRODUTO = CP.COD_PRODUTO
	INNER JOIN BI.dbo.BI_CAD_FORNECEDOR AS CF
		ON FA.COD_FORNECEDOR = CF.COD_FORNECEDOR
	INNER JOIN
	(
	SELECT  
		[COD_PRODUTO]
		,COUNT([COD_FORNECEDOR]) AS QTD_FORN
	FROM [BI].[dbo].[SUPPLY_PRODUTO_FORN_PRINCIPAL_AUTO]
	GROUP BY
		[COD_PRODUTO]
	HAVING
		COUNT([COD_FORNECEDOR]) > 1
	) AS TAB_FORN_DUPLI
	ON FA.COD_PRODUTO = TAB_FORN_DUPLI.COD_PRODUTO
ORDER BY
	FA.COD_PRODUTO
*/