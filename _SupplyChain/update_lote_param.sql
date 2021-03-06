DECLARE @TAB_UPDATE_PARAMETRO AS TABLE
(
	COD_PRODUTO INT
	,COD_FORNECEDOR INT
	,DIAS_SS INT
)

INSERT INTO @TAB_UPDATE_PARAMETRO
	SELECT
		FP.COD_PRODUTO
		,FP.COD_FORNECEDOR
		,(CASE
			WHEN CP.CLASSIF_PRODUTO = 'A1' THEN 10 - (A.DIAS_REVIEW_TIME + A.DIAS_LEAD_TIME)
			WHEN CP.CLASSIF_PRODUTO = 'A2' THEN 7 - (A.DIAS_REVIEW_TIME + A.DIAS_LEAD_TIME)
			WHEN CP.CLASSIF_PRODUTO = 'A3' THEN 3 - (A.DIAS_REVIEW_TIME + A.DIAS_LEAD_TIME)
			WHEN CP.CLASSIF_PRODUTO = 'B' THEN 2 - (A.DIAS_REVIEW_TIME + A.DIAS_LEAD_TIME)
			WHEN CP.CLASSIF_PRODUTO = 'C' THEN 0
			WHEN CP.CLASSIF_PRODUTO = 'Z' THEN 0		
		END) AS SS
	FROM
		[BI].dbo.BI_CAD_FORNECEDOR_PRODUTO AS FP
		INNER JOIN BI.DBO.BI_CAD_PRODUTO AS CP
			ON FP.COD_PRODUTO = CP.COD_PRODUTO	
		--INNER JOIN BI.dbo.BI_LINHA_PRODUTOS AS LP
		--	ON FP.COD_PRODUTO = LP.COD_PRODUTO				
		INNER JOIN [BI].[dbo].[SUPPLY_PRODUTO_FORN_PRINCIPAL_AUTO] AS FA
			ON 1=1
			AND FP.COD_PRODUTO = FA.COD_PRODUTO
			AND FP.COD_FORNECEDOR = FA.COD_FORNECEDOR
		INNER JOIN BI.dbo.COMPRAS_AGENDA_PEDIDO_AUTO AS A
			ON FP.COD_FORNECEDOR = A.COD_FORNECEDOR
			and CP.COD_DEPARTAMENTO IN ( select ITEM from [dbo].[fnSplit](A.LISTA_DEP,';') )
	WHERE 1=1
		AND FP.COD_FORNECEDOR NOT IN (125,302)
		and A.FLG_ATIVO = 1
		--and fp.COD_PRODUTO = 241014

UPDATE @TAB_UPDATE_PARAMETRO SET DIAS_SS = 0 WHERE DIAS_SS < 0

UPDATE PP
SET
	PP.DIA_SS = UP.DIAS_SS
FROM
	@TAB_UPDATE_PARAMETRO AS UP
	INNER JOIN [BI].[dbo].[COMPRA_PRODUTO_PARAMETRO] AS PP
		ON UP.COD_PRODUTO = PP.COD_PRODUTO
WHERE 1=1
	AND PP.DIA_SS <> UP.DIAS_SS

/*	
SELECT UP.*
FROM
	@TAB_UPDATE_PARAMETRO AS UP
	LEFT JOIN [BI].[dbo].[COMPRA_PRODUTO_PARAMETRO] AS PP
		ON UP.COD_PRODUTO = PP.COD_PRODUTO
WHERE 1=1
	AND PP.COD_PRODUTO IS NULL
*/