-- -----------------------------------------------------------------------------------------------------------------------------------------
-- P1
-- -----------------------------------------------------------------------------------------------------------------------------------------
	SELECT
		LEFT(dbo.ISO_WEEK(C.DATA),4) AS ANO
		,BI.DBO.F_ISO_WEEK_OF_YEAR(C.DATA) AS SEMANA
		,L.NO_REGIONAL
		,L.NO_LOJA
		,'Venda P1' AS Title
		,BI.DBO.fn_FormataVlr_Excel(SUM(C.VALOR_TOTAL)) AS VALOR
	FROM
		BI.DBO.BI_VENDA_CUPOM AS C
		INNER JOIN BI.DBO.BI_CAD_LOJA2 AS L
			ON C.COD_LOJA = L.COD_LOJA
	WHERE 1=1
		AND L.FLG_LOJA = 1
		AND CONVERT(DATE,C.DATA) BETWEEN CONVERT(DATE,'20131230') AND CONVERT(DATE,'20140223')
	GROUP BY
		LEFT(dbo.ISO_WEEK(C.DATA),4)
		,BI.DBO.F_ISO_WEEK_OF_YEAR(C.DATA)
		,L.NO_REGIONAL
		,L.NO_LOJA
		

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- P2
-- -----------------------------------------------------------------------------------------------------------------------------------------
	UNION ALL
	SELECT
		LEFT(dbo.ISO_WEEK(C.DATA),4) AS ANO
		,BI.DBO.F_ISO_WEEK_OF_YEAR(C.DATA) AS SEMANA
		,L.NO_REGIONAL
		,L.NO_LOJA
		,'Venda P2' AS Title
		,BI.DBO.fn_FormataVlr_Excel(SUM(C.VALOR_TOTAL)) AS VALOR
	FROM
		BI.DBO.BI_VENDA_CUPOM AS C
		INNER JOIN BI.DBO.BI_CAD_LOJA2 AS L
			ON C.COD_LOJA = L.COD_LOJA
	WHERE 1=1
		AND L.FLG_LOJA = 1
		AND CONVERT(DATE,C.DATA) BETWEEN CONVERT(DATE,'20141229') AND CONVERT(DATE,'20150222')
	GROUP BY
		LEFT(dbo.ISO_WEEK(C.DATA),4)
		,BI.DBO.F_ISO_WEEK_OF_YEAR(C.DATA)
		,L.NO_REGIONAL
		,L.NO_LOJA
	
	
		
	
	