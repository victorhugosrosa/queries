SELECT
	CONVERT(DATE,DTA_AJUSTE) AS DATA
	,T.DES_AJUSTE
	,AE.COD_PRODUTO
	,CP.DESCRICAO
	,CP.NO_DEPARTAMENTO
	,CP.NO_SECAO
	,BI.dbo.fn_FormataVlr_Excel(QTD_AJUSTE*-1) AS QTD_TRANSF
	--,BI.dbo.fn_FormataVlr_Excel(AE.VAL_CUSTO_REP) AS VAL_CUSTO_REP	
	,BI.dbo.fn_FormataVlr_Excel(PL.VAL_CUSTO_REP) AS VAL_CUSTO_REP
FROM
	[192.168.0.6].ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS AE
	INNER JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_TIPO_AJUSTE AS T
		ON AE.COD_AJUSTE = T.COD_AJUSTE
	LEFT JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_LOJA AS PL
		ON AE.COD_PRODUTO = PL.COD_PRODUTO
		AND PL.COD_LOJA = 29		
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON AE.COD_PRODUTO = CP.COD_PRODUTO
WHERE 1=1
	AND CONVERT(DATE,DTA_AJUSTE) BETWEEN CONVERT(DATE,'2015-10-01') AND CONVERT(DATE,'2015-10-31')
	AND AE.COD_AJUSTE IN (261)
	--AND AE.COD_PRODUTO = 00451475



SELECT * FROM [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_LOJA WHERE COD_PRODUTO = 00451475 AND COD_LOJA IN (29,33)





select * from [192.168.0.6].ZEUS_RTG.DBO.TAB_TIPO_AJUSTE



GROUP BY
	MONTH(DTA_AJUSTE)
	,T.DES_AJUSTE
	,AE.COD_PRODUTO
	,CP.DESCRICAO
	,CP.NO_DEPARTAMENTO
	,CP.NO_SECAO


SELECT TOP 10 * FROM 
[192.168.0.6].ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS AE
	INNER JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_TIPO_AJUSTE AS T
		ON AE.COD_AJUSTE = T.COD_AJUSTE
	INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
		ON AE.COD_PRODUTO = CP.COD_PRODUTO
WHERE 1=1
	AND CONVERT(DATE,DTA_AJUSTE) >= '2015-05-19'
	AND AE.COD_AJUSTE IN (260,294)




SELECT * FROM
	[192.168.0.6].ZEUS_RTG.DBO.TAB_TIPO_AJUSTE



260
262