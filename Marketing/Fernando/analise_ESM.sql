/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Planilha 1a:

Seção, Grupo 
Número de tickets, Venda valor, venda quantidade, ticket médio, penetração

Lojas: 7 + C1 (preciso poder filtrar isso, pois vou fazer a comparação do ESM com C1 STM)
Em: 2013, 2014 e 2015(até outubro fechado)
Mês a Mês

Obs: Não sei vale a pena separar grupo e seção em um planilha diferente, pois senão teria que fazer alguns dos indicadores duas vezes, como penetração. O TM daria pra fazer no excel mesmo né, dividindo a venda valor pelo número de tickets, certo?
*/-- ----------------------------------------------------------------------------------------------------------------------------------------------------------
	IF OBJECT_ID('TEMPDB.DBO.#TAB_CUPOM_MES') IS NOT NULL DROP TABLE #TAB_CUPOM_MES
	
	CREATE TABLE #TAB_CUPOM_MES
	(
		ANO INT
		,MES INT
		,COD_LOJA INT
		,QTD_CUPOM_TOTAL NUMERIC(18,0)
	)
	CREATE CLUSTERED INDEX IX_TAB_CUPOM_MES ON #TAB_CUPOM_MES (ANO, MES, COD_LOJA)
	
	INSERT INTO #TAB_CUPOM_MES
		SELECT
			S.ANO
			,S.MES
			,TVCP.COD_LOJA
			,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT TVCP.CUPOM_HASH)) AS QTD_CUPOM_TOTAL
		FROM
			BI.dbo.BI_VENDA_CUPOM_PRODUTO AS TVCP
			INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
				ON TVCP.DATA = S.DATA
		WHERE 1=1
			AND TVCP.COD_LOJA = 7 --in (1,2,9,7)
			AND S.DATA between convert(date,'2013-01-01') and convert(date,'2015-10-31')
		GROUP BY
			S.ANO
			,S.MES	
			,TVCP.COD_LOJA	

	SELECT
		S.ANO
		,S.MES
		,VCP.COD_LOJA
		--,S.SEMANA_454
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,TCM.QTD_CUPOM_TOTAL 
		,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT VCP.CUPOM_HASH)) AS QTD_CUPOM
		,BI.dbo.fn_FormataVlr_Excel(SUM(VCP.VLR_VENDA)) AS VLR_TOTAL
		,BI.dbo.fn_FormataVlr_Excel(SUM(VCP.QTDE_VENDA)) AS QTD_TOTAL
		,BI.dbo.fn_FormataVlr_Excel(SUM(VCP.VLR_VENDA)/SUM(VCP.QTDE_VENDA)) AS PRECO_MEDIO
		,BI.dbo.fn_FormataVlr_Excel(SUM(VCP.VLR_VENDA)/COUNT(DISTINCT VCP.CUPOM_HASH)) AS TICKET_MEDIO
		,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT VCP.CUPOM_HASH) / TCM.QTD_CUPOM_TOTAL) AS PENETRACAO
	FROM
		BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VCP
		INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON VCP.COD_PRODUTO = CP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
			ON VCP.DATA = S.DATA
		LEFT JOIN #TAB_CUPOM_MES AS TCM
			ON 1=1
			AND S.ANO = TCM.ANO
			AND S.MES = TCM.MES
			AND VCP.COD_LOJA = TCM.COD_LOJA
	WHERE 1=1
		AND VCP.COD_LOJA = 7 --in (1,2,9,7)
		AND S.DATA between convert(date,'2013-01-01') and convert(date,'2015-10-31')
		--AND CONVERT(DATE,VCP.DATA) BETWEEN CONVERT(DATE,'2013-01-01') AND CONVERT(DATE,'2013-12-31')
	GROUP BY
		S.ANO
		,S.MES
		,VCP.COD_LOJA
		--,S.SEMANA_454
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,TCM.QTD_CUPOM_TOTAL
		
/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Planilha 1b:
Mesmo acima, nos mesmos períodos, mas quebrado semana a semana. 
*/-- ----------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_CUPOM_SEMANA AS TABLE
	(
		ANO_454 INT
		,SEMANA_454 INT
		,COD_LOJA INT
		,QTD_CUPOM_TOTAL NUMERIC(18,0)
		,PRIMARY KEY(ANO_454, SEMANA_454, COD_LOJA)
	)
	INSERT INTO @TAB_CUPOM_SEMANA
		SELECT
			S.ANO_454
			,S.SEMANA_454
			,TVCP.COD_LOJA
			,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT TVCP.CUPOM_HASH)) AS QTD_CUPOM_TOTAL
		FROM
			BI.dbo.BI_VENDA_CUPOM_PRODUTO AS TVCP
			INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
				ON TVCP.DATA = S.DATA
		WHERE 1=1
			AND TVCP.COD_LOJA in (1,2,9,7)
			AND S.DATA between convert(date,'2012-12-31') and convert(date,'2015-10-25')
		GROUP BY
			S.ANO_454
			,S.SEMANA_454	
			,TVCP.COD_LOJA

	SELECT
		S.ANO_454
		,S.SEMANA_454
		,VCP.COD_LOJA
		--,S.SEMANA_454
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,TCM.QTD_CUPOM_TOTAL 
		,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT VCP.CUPOM_HASH)) AS QTD_CUPOM
		,BI.dbo.fn_FormataVlr_Excel(SUM(VCP.VLR_VENDA)) AS VLR_TOTAL
		,BI.dbo.fn_FormataVlr_Excel(SUM(VCP.QTDE_VENDA)) AS QTD_TOTAL
		,BI.dbo.fn_FormataVlr_Excel(SUM(VCP.VLR_VENDA)/SUM(VCP.QTDE_VENDA)) AS PRECO_MEDIO
		,BI.dbo.fn_FormataVlr_Excel(SUM(VCP.VLR_VENDA)/COUNT(DISTINCT VCP.CUPOM_HASH)) AS TICKET_MEDIO
		,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT VCP.CUPOM_HASH) / TCM.QTD_CUPOM_TOTAL) AS PENETRACAO
	FROM
		BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VCP
		INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON VCP.COD_PRODUTO = CP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
			ON VCP.DATA = S.DATA
		LEFT JOIN @TAB_CUPOM_SEMANA AS TCM
			ON 1=1
			AND S.ANO_454 = TCM.ANO_454
			AND S.SEMANA_454 = TCM.SEMANA_454
			AND VCP.COD_LOJA = TCM.COD_LOJA
	WHERE 1=1
		AND VCP.COD_LOJA in (1,2,9,7)
		AND S.DATA between convert(date,'2012-12-31') and convert(date,'2015-10-25')
		--AND CONVERT(DATE,VCP.DATA) BETWEEN CONVERT(DATE,'2013-01-01') AND CONVERT(DATE,'2013-12-31')
	GROUP BY
		S.ANO_454
		,S.SEMANA_454
		,VCP.COD_LOJA
		--,S.SEMANA_454
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,TCM.QTD_CUPOM_TOTAL
		
/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Planilha 2:
CPF + frequência (tickets) + venda valor por seção
Loja 7 apenas, em 2014 fechado
Obs: O ideal é que as seções fossem colunas na planilha, para eu filtrar com facilidade

Adicionar para comparação: 1 linha com vendas sem identificação+ número de tickets + venda valor por seção
*/-- ----------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_CUPOM_CPF AS TABLE
	(
		CPF_NFP NUMERIC(18,0)
		,QTD_CUPOM_TOTAL NUMERIC(18,0)
	)
	INSERT INTO @TAB_CUPOM_CPF
		SELECT
			(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END) AS CPF
			,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT VCC.CUPOM_HASH)) AS QTD_CUPOM_TOTAL
		FROM
			BI.dbo.BI_VENDA_CUPOM_CAPA AS VCC
			INNER JOIN BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VCP
				ON VCC.CUPOM_HASH = VCP.CUPOM_HASH
			INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
				ON VCC.DATA = S.DATA
		WHERE 1=1
			AND VCC.COD_LOJA = 7
			--AND S.ANO = 2014
			AND S.DATA between convert(date,'2014-01-01') and convert(date,'2014-10-31')
		GROUP BY
			(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END)

	SELECT --TOP 10
		(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END) AS CPF
		,CP.NO_SECAO
		,CPF.QTD_CUPOM_TOTAL
		,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT VCC.CUPOM_HASH)) AS QTD_CUPOM
		,BI.dbo.fn_FormataVlr_Excel(SUM(VCP.VLR_VENDA)) AS VLR_TOTAL
	FROM
		BI.dbo.BI_VENDA_CUPOM_CAPA AS VCC
		INNER JOIN BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VCP
			ON VCC.CUPOM_HASH = VCP.CUPOM_HASH
		INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON VCP.COD_PRODUTO = CP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
			ON VCC.DATA = S.DATA
		LEFT JOIN @TAB_CUPOM_CPF AS CPF
			ON (CASE WHEN VCC.CPF_NFP IS NOT NULL THEN VCC.CPF_NFP ELSE isnull(CPF_VCM,0) END) = CPF.CPF_NFP
	WHERE 1=1
		AND VCC.COD_LOJA = 7
		--AND S.ANO = 2014
		AND S.DATA between convert(date,'2014-01-01') and convert(date,'2014-10-31')
		--AND CONVERT(DATE,VCP.DATA) BETWEEN CONVERT(DATE,'2013-01-01') AND CONVERT(DATE,'2013-12-31')
	GROUP BY
		(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END)
		,CP.NO_SECAO
		,CPF.QTD_CUPOM_TOTAL

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Planilha 3:
CPFs + frequência(tickets) + datas dessas compras+ valor por compra
Loja 7 apenas, em 2014 fechado
*/-- ----------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_CUPOM_CPF_2 AS TABLE
	(
		CPF_NFP NUMERIC(18,0)
		,QTD_CUPOM_TOTAL NUMERIC(18,0)
	)
	INSERT INTO @TAB_CUPOM_CPF_2
		SELECT
			(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END) AS CPF
			,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT VCC.CUPOM_HASH)) AS QTD_CUPOM_TOTAL
		FROM
			BI.dbo.BI_VENDA_CUPOM_CAPA AS VCC
			--INNER JOIN BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VCP
			--	ON VCC.CUPOM_HASH = VCP.CUPOM_HASH
			INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
				ON VCC.DATA = S.DATA
		WHERE 1=1
			AND VCC.COD_LOJA = 27
			--AND S.ANO = 2014
			AND S.DATA between convert(date,'2015-01-01') and convert(date,'2015-10-31')
		GROUP BY
			(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END)
	
	
	SELECT --TOP 10
		(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END) AS CPF
		,CPF.QTD_CUPOM_TOTAL
		,CONVERT(DATE,VCC.DATA) AS DATA
		,BI.dbo.fn_FormataVlr_Excel(sum(VCC.VLR_CUPOM)) AS VLR_CUPOM
	FROM
		BI.dbo.BI_VENDA_CUPOM_CAPA AS VCC
		INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
			ON VCC.DATA = S.DATA
		LEFT JOIN @TAB_CUPOM_CPF_2 AS CPF
			ON (CASE WHEN VCC.CPF_NFP IS NOT NULL THEN VCC.CPF_NFP ELSE isnull(CPF_VCM,0) END) = CPF.CPF_NFP
	WHERE 1=1
		AND VCC.COD_LOJA = 27
		--AND S.ANO = 2014
		AND S.DATA between convert(date,'2015-01-01') and convert(date,'2015-10-31')
	group by
		(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END)
		,CPF.QTD_CUPOM_TOTAL
		,CONVERT(DATE,VCC.DATA)


/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
Planilha 8:
CPFs + frequência na loja 7+ valor total na loja 7 + frequência na HortusR + valor por Vinoteca, Sushi e Paneria (temos como separar isso? As seções e grupos não parecem me ajudar para essa analise. O cliente da Paneria é muito diferente do cliente do sushi)
Loja 7 e Hortus R, em 2015 (até outubro fechado)
*/-- ----------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_CUPOM_CPF_3 AS TABLE
	(
		CPF_NFP NUMERIC(18,0)
		,QTD_CUPOM_TOTAL NUMERIC(18,0)
	)
	INSERT INTO @TAB_CUPOM_CPF_3
		SELECT
			(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END) AS CPF
			,BI.dbo.fn_FormataVlr_Excel(COUNT(DISTINCT VCC.CUPOM_HASH)) AS QTD_CUPOM_TOTAL
		FROM
			BI.dbo.BI_VENDA_CUPOM_CAPA AS VCC
			--INNER JOIN BI.dbo.BI_VENDA_CUPOM_PRODUTO AS VCP
			--	ON VCC.CUPOM_HASH = VCP.CUPOM_HASH
			INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
				ON VCC.DATA = S.DATA
		WHERE 1=1
			AND VCC.COD_LOJA = 8
			--AND S.ANO = 2014
			AND S.DATA between convert(date,'2015-01-01') and convert(date,'2015-10-31')
		GROUP BY
			(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END)
	
	
	SELECT --TOP 10
		(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END) AS CPF
		,CPF.QTD_CUPOM_TOTAL
		,CONVERT(DATE,VCC.DATA) AS DATA
		,BI.dbo.fn_FormataVlr_Excel(sum(VCC.VLR_CUPOM)) AS VLR_CUPOM
	FROM
		BI.dbo.BI_VENDA_CUPOM_CAPA AS VCC
		INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
			ON VCC.DATA = S.DATA
		LEFT JOIN @TAB_CUPOM_CPF_3 AS CPF
			ON (CASE WHEN VCC.CPF_NFP IS NOT NULL THEN VCC.CPF_NFP ELSE isnull(CPF_VCM,0) END) = CPF.CPF_NFP
	WHERE 1=1
		AND VCC.COD_LOJA = 8
		--AND S.ANO = 2014
		AND S.DATA between convert(date,'2015-01-01') and convert(date,'2015-10-31')
	group by
		(CASE WHEN VCC.CPF_VCM IS NOT NULL THEN VCC.CPF_VCM ELSE VCC.CPF_NFP END)
		,CPF.QTD_CUPOM_TOTAL
		,CONVERT(DATE,VCC.DATA)