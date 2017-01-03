-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_PROD AS TABLE
	(
		COD_PRODUTO INT
	)
	INSERT INTO @TAB_PROD
		SELECT DISTINCT COD_PRODUTO FROM [192.168.0.13].BI.DBO.BI_CAD_PRODUTO AS TP WHERE TP.COD_DEPARTAMENTO = 4

-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_PROD_VENDA AS TABLE
	(
		ANO INT
		,NO_DEPARTAMENTO VARCHAR(50)
		,COD_PRODUTO INT
		,VLR_VENDA NUMERIC(18,2)
	)
	INSERT INTO @TAB_PROD_VENDA
		SELECT
			YEAR(VP.DATA) AS ANO
			,CP.NO_DEPARTAMENTO
			,CP.COD_PRODUTO
			,SUM(VP.VALOR_TOTAL) AS VLR_VENDA
		FROM
			[192.168.0.13].BI.DBO.BI_VENDA_PRODUTO AS VP
			INNER JOIN [192.168.0.13].BI.DBO.BI_CAD_PRODUTO AS CP
				ON VP.COD_PRODUTO = CP.COD_PRODUTO
		WHERE 1=1
			AND CP.COD_DEPARTAMENTO = 4
			AND CONVERT(DATE,DATA) >= CONVERT(DATE,'20130101')
		GROUP BY
			YEAR(VP.DATA)
			,CP.NO_DEPARTAMENTO
			,CP.COD_PRODUTO
		ORDER BY
			1,2
		
-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_PROD_QUEBRA_SIST AS TABLE
	(
		ANO INT
		,COD_PRODUTO INT
		,QTD_QUEBRA_SIST NUMERIC(18,2)
		,VLR_QUEBRA_SIST NUMERIC(18,2)
	)
	INSERT INTO @TAB_PROD_QUEBRA_SIST
		SELECT
			YEAR(AE.DTA_AJUSTE) AS ANO
			,AE.COD_PRODUTO
			,SUM(AE.QTD_AJUSTE) AS QTD_QUEBRA
			,SUM(AE.QTD_AJUSTE * AE.VAL_CUSTO_REP) AS VLR_QUEBRA
		FROM
			ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS AE INNER JOIN @TAB_PROD AS P ON (AE.COD_PRODUTO = P.COD_PRODUTO)
		WHERE 1=1
			AND AE.COD_AJUSTE IN (155,120,123,124,154,122,51,121)
			AND CONVERT(DATE,AE.DTA_AJUSTE) >= CONVERT(DATE,'20130101')
		GROUP BY
			YEAR(AE.DTA_AJUSTE)
			,AE.COD_PRODUTO
		ORDER BY
			1,2	
		
-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_PROD_ENT AS TABLE
	(
		ANO INT
		,COD_PRODUTO INT
		,QTD_ENT NUMERIC(18,2)
		,CUSTO_ENT NUMERIC(18,2)
	)
	INSERT INTO @TAB_PROD_ENT
		SELECT
			YEAR(ENT.DTA_ENTRADA) AS ANO
			,ENT.COD_PRODUTO
			,SUM(ENT.QTD_ENTRADA * ENT.QTD_EMBALAGEM) AS QTD_ENTRADA
			,SUM(ENT.QTD_ENTRADA * ENT.VAL_TABELA) AS CUSTO_ENTRADA
		FROM
			ZEUS_RTG.DBO.vw_MARCHE_ENTRADAS AS ENT INNER JOIN @TAB_PROD AS P ON (ENT.COD_PRODUTO = P.COD_PRODUTO)
		WHERE 1=1
			AND CONVERT(DATE,ENT.DTA_ENTRADA) >= CONVERT(DATE,'20130101')
		GROUP BY
			YEAR(ENT.DTA_ENTRADA)
			,ENT.COD_PRODUTO
		ORDER BY
			1,2
			
-- ------------------------------------------------------------------------------------------------------------------
-- 
-- ------------------------------------------------------------------------------------------------------------------
	SELECT
		PV.ANO
		,PV.NO_DEPARTAMENTO
		,PV.COD_PRODUTO
		,PV.VLR_VENDA
		,Q.QTD_QUEBRA_SIST
		,Q.VLR_QUEBRA_SIST
		,E.QTD_ENT
		,E.QTD_ENT
	FROM
		@TAB_PROD_VENDA AS PV
		LEFT JOIN @TAB_PROD_QUEBRA_SIST AS Q
			ON 1=1
			AND PV.COD_PRODUTO = Q.COD_PRODUTO
			AND PV.ANO = Q.ANO
		LEFT JOIN @TAB_PROD_ENT AS E
			ON 1=1
			AND PV.COD_PRODUTO = E.COD_PRODUTO
			AND PV.ANO = E.ANO