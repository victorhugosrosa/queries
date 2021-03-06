DECLARE @DT_INI AS DATE = CONVERT(DATE,'20131212')
DECLARE @DT_FIM AS DATE = CONVERT(DATE,'20131212')

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT 
		M00ZA AS COD_LOJA
		,CONVERT(DATE,M00AF) AS DATA
		--,SUM(M01AK) AS VLRCUPOM
		--,SUM(CASE WHEN [M01AV] = '0' THEN 0 ELSE M01AK END) AS VLRCUPOMCLI
		,COUNT(M00AD) AS QTDCUPOM
		,SUM(CASE WHEN [M01AV] = '0' THEN 0 ELSE 1 END) AS [VOCE_MARCHE]
		,SUM(CASE WHEN [M01BV] = '0' THEN 0 ELSE 1 END)  AS [NOTA_FISCAL_PAULISTA]
		,null as [CONTA_CLIENTE]
		,SUM(CASE WHEN [M01BV] <> '0' OR [M01AV] <> '0' THEN 1 ELSE 0 END)  AS QTD_IDENT
	FROM
		ZEUSRETAIL.DBO.ZAN_M01 AS C WITH (NOLOCK)
	WHERE 1 = 1
		AND M00ZA IN (1)
		AND CONVERT(DATE,M00AF) BETWEEN CONVERT(DATE,@DT_INI) AND CONVERT(DATE,@DT_FIM)

	GROUP BY  M00ZA 
		,CONVERT(DATE,M00AF)

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT
		[COD_LOJA]
		,[DATA]
		,COUNT([CUPOM]) as QTDCUPOM
		,SUM(CASE WHEN [VOCE_MARCHE] IS NOT NULL THEN 1 ELSE 0 END) as [VOCE_MARCHE]
		,SUM(CASE WHEN [NOTA_FISCAL_PAULISTA] IS NOT NULL THEN 1 ELSE 0 END) as [NOTA_FISCAL_PAULISTA]
		,SUM(CASE WHEN [CONTA_CLIENTE] IS NOT NULL THEN 1 ELSE 0 END) as [CONTA_CLIENTE]
		,SUM(CASE WHEN ([NOTA_FISCAL_PAULISTA] IS NOT NULL OR [CONTA_CLIENTE] IS NOT NULL OR [VOCE_MARCHE] IS NOT NULL) THEN 1 ELSE 0 END) as QTD_IDENT
		
	FROM
		[DW].[DBO].[CUPOM_CLIENTES]
	WHERE 1 = 1
		AND COD_LOJA IN (1)
		AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DT_INI) AND CONVERT(DATE,@DT_FIM)
	GROUP BY
		[COD_LOJA]
		,[DATA]
		

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT DISTINCT
		idLoja
		,datVenda
		,numCaixa
		,(numCupom)
		,(idCliente)
	FROM
		[DTM].[DBO].[CUPOM_PRODUTO] WITH (NOLOCK)
	WHERE 1 = 1
		AND idLoja IN (3)
		AND CONVERT(DATE,DATVENDA) BETWEEN CONVERT(DATE,'20130131') AND CONVERT(DATE,'20130131')
		AND idCliente IS NOT NULL

	select
		CONVERT(DATE,DATVENDA)
		,SUM(vlrTotal)
	FROM
		[DTM].[DBO].[CUPOM_PRODUTO] WITH (NOLOCK)
	WHERE 1 = 1
		AND idLoja IN (3)
		AND CONVERT(DATE,DATVENDA) BETWEEN CONVERT(DATE,'20130101') AND CONVERT(DATE,'20130131')
		--AND idCliente IS NOT NULL
	group by
		CONVERT(DATE,DATVENDA)
	order by
		CONVERT(DATE,DATVENDA)
		
		
		
	select
		SUM(vlrTotal)
	FROM
		[DTM].[DBO].[CUPOM_PRODUTO] WITH (NOLOCK)
	WHERE 1 = 1
		AND idLoja IN (3)
		AND CONVERT(DATE,DATVENDA) BETWEEN CONVERT(DATE,'20130101') AND CONVERT(DATE,'20130131')
		--AND idCliente IS NOT NULL

	SELECT 
		idLoja, 
		CONVERT(DATETIME,datVenda) datVenda,
		SUM(CONVERT(REAL,vlrTotal)) VlrVendaCliIdentif,
		COUNT(DISTINCT CONVERT(VARCHAR,numcupom) + CONVERT(VARCHAR,numCaixa) + CONVERT(VARCHAR,idLoja) + CONVERT(VARCHAR,datVenda)) QtdCliIdentif
	FROM
		[DTM].[DBO].[CUPOM_PRODUTO] CP
	WHERE 
		idLoja IN (1)
		and ISNULL(REPLACE(idCliente,' ',''),'') <> ''
		AND 
		CONVERT(DATE,DATVENDA) BETWEEN CONVERT(DATE,'20131201') AND CONVERT(DATE,'20131201')
	GROUP BY
		idLoja, 
		datVenda			
		
		
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- conferencia
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select
	idLoja
	,datVenda
	,SUM(QtdVenda) as QtdVenda
	,SUM(QtdCliIdentif) as QtdCliIdentif
	,SUM(VlrVenda) as VlrVenda
	,SUM(VlrVendaCliIdentif) as VlrVendaCliIdentif
from
(
	SELECT
		idLoja
		,datVenda
		,numCaixa
		,count(distinct numCupom) QtdVenda
		,count(distinct idCliente) QtdCliIdentif
		,sum(vlrTotal) VlrVenda
		,sum(case when idCliente is not null then vlrTotal else 0 end) VlrVendaCliIdentif
	FROM
		[DTM].[DBO].[CUPOM_PRODUTO] WITH (NOLOCK)
	WHERE 1 = 1
		AND idLoja IN (1)
		AND CONVERT(DATE,DATVENDA) BETWEEN CONVERT(DATE,'20131201') AND CONVERT(DATE,'20131201')
	group by
		idLoja
		,datVenda
		,numCaixa
) as tab
where 1 = 1
group by
	idLoja
	,datVenda
order by 
	idLoja
	,datVenda

-- ------

SELECT 
	C.idLoja, 
	CONVERT(DATETIME,C.datVenda) datVenda,
	COUNT(DISTINCT CONVERT(VARCHAR,C.numcupom) + CONVERT(VARCHAR,C.numCaixa) + CONVERT(VARCHAR,C.idLoja) + CONVERT(VARCHAR,C.datVenda)) QtdVenda,
	SUM(CONVERT(REAL,C.vlrTotal)) VlrVenda,
	ISNULL(A.QtdCliIdentif,0) QtdCliIdentif, 
	ISNULL(A.VlrVendaCliIdentif,0) VlrVendaCliIdentif
FROM
	[DTM].[DBO].[CUPOM_PRODUTO] C
LEFT JOIN
	(
		SELECT 
			idLoja, 
			CONVERT(DATETIME,datVenda) datVenda,
			SUM(CONVERT(REAL,vlrTotal)) VlrVendaCliIdentif,
			COUNT(DISTINCT CONVERT(VARCHAR,numcupom) + CONVERT(VARCHAR,numCaixa) + CONVERT(VARCHAR,idLoja) + CONVERT(VARCHAR,datVenda)) QtdCliIdentif
		FROM
			[DTM].[DBO].[CUPOM_PRODUTO] CP
		WHERE 
			ISNULL(REPLACE(idCliente,' ',''),'') <> ''
			AND 
			CONVERT(DATE,DATVENDA) BETWEEN CONVERT(DATE,'20131201') AND CONVERT(DATE,'20131231')
		GROUP BY
			idLoja, 
			datVenda			
	) A ON
		A.idLoja = C.idLoja
		AND
		A.datVenda = CONVERT(DATETIME,C.datVenda)
WHERE 1 = 1
	--AND idLoja IN (1)
	AND CONVERT(DATE,c.DATVENDA) BETWEEN CONVERT(DATE,'20131201') AND CONVERT(DATE,'20131231')
group by
	C.idLoja, 
	CONVERT(DATETIME,C.datVenda) ,
	ISNULL(A.QtdCliIdentif,0),
	ISNULL(A.VlrVendaCliIdentif,0)