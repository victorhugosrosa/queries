SELECT
ZANTHUS.COD_LOJA
,ZANTHUS.MES
,ZANTHUS.VLR_VENDA AS VLR_VENDA_ZANTHUS
,ZEUS.VLR_VENDA AS VLR_VENDA_ZEUS
,ZEUS.VLR_VENDA-ZANTHUS.VLR_VENDA AS DIF
FROM

	(
		SELECT --TOP 100
			M00ZA AS COD_LOJA
			,MONTH(M00AF) AS MES
			,SUM(M03AP) AS VLR_VENDA
		FROM
			[ZEUSRETAIL].DBO.ZAN_M03 WITH (NOLOCK)
		WHERE 1 = 1
			AND CONVERT (DATE, M00AF) BETWEEN CONVERT (DATE, '20130101') AND CONVERT (DATE, '20131030')
		GROUP BY
			M00ZA
			,MONTH(M00AF)
	) AS ZANTHUS

LEFT JOIN

	(
		SELECT
			S.COD_LOJA AS COD_LOJA
			,MONTH(S.DTA_SAIDA) AS MES
			,SUM(S.VAL_TOTAL_PRODUTO) AS VLR_VENDA
		FROM 
		   [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO AS P INNER JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_SAIDA AS S WITH (NOLOCK) ON(P.COD_PRODUTO = S.COD_PRODUTO) 
		  
		WHERE 1=1
			AND P.FLG_GRADE_PRODUTO = 'N' 
			AND CONVERT(DATE,S.DTA_SAIDA)  BETWEEN CONVERT (DATE, '20130101') AND CONVERT (DATE, '20131030')
		GROUP BY
			S.COD_LOJA
			,MONTH(S.DTA_SAIDA)
	) AS ZEUS

ON (ZANTHUS.COD_LOJA = ZEUS.COD_LOJA AND ZANTHUS.MES = ZEUS.MES)


