-- ---------------------------------------------------------------------------------------------------------------------------------
-- PARA CRIAR A TABELA
-- ---------------------------------------------------------------------------------------------------------------------------------
/*
	CREATE TABLE BI.DBO.FIN_FLUXO_RECEBIVEL
	(
		COD_LOJA INT
		,DATA DATE
		,CREDITO_META NUMERIC(18,2)
		,DEBITO_META NUMERIC(18,2)
		,DINHEIRO_META NUMERIC(18,2)
		,VOUCHER_META NUMERIC(18,2)
		,CONTA_CLIENTE_META NUMERIC(18,2)
		,DEVOLUCOES_META NUMERIC(18,2)		
		--
		,CREDITO_REAL NUMERIC(18,2)
		,DEBITO_REAL NUMERIC(18,2)
		,DINHEIRO_REAL NUMERIC(18,2)
		,VOUCHER_REAL NUMERIC(18,2)
		,CONTA_CLIENTE_REAL NUMERIC(18,2)
		,DEVOLUCOES_REAL NUMERIC(18,2)		
		--
		,ANTECIPACAO_CREDITO NUMERIC(18,2)
		,ANTECIPACAO_DEBITO NUMERIC(18,2)	
		,PRIMARY KEY (COD_LOJA, DATA)
	)
	
	
	CREATE TABLE BI.DBO.FIN_PARAM_RECEBIVEL
	(
		COD_LOJA INT
		,MES INT			
		,PERC_CREDITO NUMERIC(10,4)
		,PERC_DEBITO NUMERIC(10,4)
		,PERC_DINHEIRO NUMERIC(10,4)
		,PERC_VOUCHER NUMERIC(10,4)
		,PERC_CONTA_CLIENTE NUMERIC(10,4)
		,PERC_DEVOLUCOES NUMERIC(10,4)			
		,PRIMARY KEY (COD_LOJA, MES)
	)
	
	
	INSERT INTO BI.DBO.FIN_PARAM_RECEBIVEL (COD_LOJA, MES)
	SELECT
		L.COD_LOJA
		,TAB_MES.MES
	FROM
		BI.DBO.BI_CAD_LOJA2 AS L
		INNER JOIN
		(
			SELECT DISTINCT MONTH(DATA) AS MES FROM BI_CAD_SEMANA WHERE CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,'2015-01-01') AND CONVERT(DATE,'2015-12-31')
		) AS TAB_MES
		ON 1=1
	ORDER BY
		L.COD_LOJA
		,TAB_MES.MES
	
	
	select * from BI.DBO.FIN_PARAM_RECEBIVEL
	
	UPDATE BI.DBO.FIN_PARAM_RECEBIVEL
	SET
		PERC_CREDITO = NULL
		,PERC_DEBITO = NULL
		,PERC_DINHEIRO = NULL
		,PERC_VOUCHER = NULL
		,PERC_CONTA_CLIENTE = NULL
		,PERC_DEVOLUCOES = NULL
	
*/


-- ---------------------------------------------------------------------------------------------------------------------------------
-- PARA ADICIONAR NOVO PERIODO
-- ---------------------------------------------------------------------------------------------------------------------------------
/* 
	INSERT INTO BI.DBO.FIN_FLUXO_RECEBIVEL (COD_LOJA, DATA)
	SELECT
		COD_LOJA
		,DATA
	FROM
		BI.dbo.BI_CAD_SEMANA AS S
		INNER JOIN BI.dbo.BI_CAD_LOJA2 AS L
			ON 1=1
	WHERE 1=1
		AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,'2014-01-01') AND CONVERT(DATE,'2018-01-01')
		
		
	DELETE FROM BI.DBO.FIN_FLUXO_RECEBIVEL
	WHERE 1=1
		AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,'2014-01-01') AND CONVERT(DATE,'2014-12-31')
		
*/

-- ---------------------------------------------------------------------------------------------------------------------------------
-- PARA RECALCULAR META
-- ---------------------------------------------------------------------------------------------------------------------------------
/*
	UPDATE BI.DBO.FIN_FLUXO_RECEBIVEL
	SET
		CREDITO_META = NULL
		,DEBITO_META = NULL
		,DINHEIRO_META = NULL
		,VOUCHER_META = NULL
		,CONTA_CLIENTE_META = NULL
		,DEVOLUCOES_META = NULL
		
*/

-- #########################################################################################################################################################
-- @TAB_AJUSTE_META_U15D
-- #########################################################################################################################################################
	DECLARE @TAB_AJUSTE_META_U15D AS TABLE
	(
		COD_LOJA INT
		,PERC_AJUSTE_META_U15D NUMERIC(8,4)
	)
	
	INSERT INTO @TAB_AJUSTE_META_U15D
	SELECT
		VC.COD_LOJA
		,SUM(VC.VALOR_TOTAL)/SUM(VM.VLR_META)
	FROM
		BI.dbo.BI_VENDA_CUPOM  AS VC
		LEFT JOIN BI.DBO.BI_VENDA_META_FLUXO_RECEBIVEL AS VM
			ON 1=1
			AND VC.COD_LOJA = VM.COD_LOJA
			AND VC.DATA = VM.DATA
	WHERE 1=1
		AND CONVERT(DATE,VC.DATA) BETWEEN CONVERT(DATE,GETDATE()-15) AND CONVERT(DATE,GETDATE()-1)
	GROUP BY
		VC.COD_LOJA
	
	--DECLARE @FATOR_REDUCAO_META AS NUMERIC(6,2) = 1--0.85	
	
-- #########################################################################################################################################################
-- CREDITO APOS @DIAS_RECEBIMENTO_CREDITO DIAS
-- #########################################################################################################################################################
	DECLARE @DIAS_RECEBIMENTO_CREDITO INT = 30	
	
	-- ------------------------------------------------------------------------
	-- BASE COM DATA E DTA_PGTO
	-- ------------------------------------------------------------------------
	DECLARE @TEMP_CREDITO AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,DATA_RECEB DATE
		,DATA_PGTO DATE
		,CREDITO_META NUMERIC(18,2)
	)

	INSERT INTO @TEMP_CREDITO
	SELECT
		M.[COD_LOJA]
		,M.DATA AS DATA
		,DATEADD(D,@DIAS_RECEBIMENTO_CREDITO,M.DATA) AS DATA_RECEB
		,(SELECT TS.DATA_PROX_DIA_UTIL FROM BI.dbo.BI_CAD_SEMANA AS TS WHERE TS.DATA = DATEADD(D,@DIAS_RECEBIMENTO_CREDITO,M.DATA)) AS DATA_PGTO
		,M.VLR_META*PR.PERC_CREDITO*AM.PERC_AJUSTE_META_U15D as [CREDITO_META]
	FROM
		[BI].[dbo].[BI_VENDA_META_FLUXO_RECEBIVEL] AS M
		INNER JOIN [BI].[dbo].[FIN_PARAM_RECEBIVEL] AS PR
			ON 1=1
			AND M.COD_LOJA = PR.COD_LOJA
			AND MONTH(M.DATA) = PR.MES
		INNER JOIN [BI].[dbo].[BI_CAD_SEMANA] AS S
			ON M.DATA = S.DATA
		LEFT JOIN @TAB_AJUSTE_META_U15D AS AM
			ON M.COD_LOJA = AM.COD_LOJA
	WHERE 1=1
		AND CONVERT(DATE,M.DATA) BETWEEN CONVERT(DATE,'2015-01-01') AND CONVERT(DATE,'2016-12-31')
		--AND M.COD_LOJA = 1	
	
	-- ------------------------------------------------------------------------
	-- BASE COM DTA_PGTO SOMADA
	-- ------------------------------------------------------------------------
	DECLARE @TEMP_CREDITO_FINAL AS TABLE
	(
		COD_LOJA INT
		,DATA_PGTO DATE
		,CREDITO_META NUMERIC(18,2)
	)
	
	INSERT INTO @TEMP_CREDITO_FINAL	
		SELECT
			COD_LOJA
			,DATA_PGTO
			,SUM(CREDITO_META) AS CREDITO_META
		FROM
			@TEMP_CREDITO
		GROUP BY
			COD_LOJA
			,DATA_PGTO		
	
	-- ------------------------------------------------------------------------
	-- UPDATING FIN_FLUXO_RECEBIVEL
	-- ------------------------------------------------------------------------
	UPDATE FR
	SET
		FR.CREDITO_META = T.CREDITO_META
	FROM
		BI.DBO.FIN_FLUXO_RECEBIVEL AS FR
		INNER JOIN @TEMP_CREDITO_FINAL AS T
			ON 1=1
			AND FR.COD_LOJA = T.COD_LOJA
			AND FR.DATA = T.DATA_PGTO
	WHERE 1=1
		AND T.CREDITO_META > 0


-- #########################################################################################################################################################
-- VOUCHER APOS @DIAS_RECEBIMENTO_VOUCHER DIAS
-- #########################################################################################################################################################
	DECLARE @DIAS_RECEBIMENTO_VOUCHER INT = 21
	
	-- ------------------------------------------------------------------------
	-- BASE COM DATA E DTA_PGTO
	-- ------------------------------------------------------------------------
	DECLARE @TEMP_VOUCHER AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,DATA_RECEB DATE
		,DATA_PGTO DATE
		,VOUCHER_META NUMERIC(18,2)
	)

	INSERT INTO @TEMP_VOUCHER
	SELECT
		M.[COD_LOJA]
		,M.DATA AS DATA
		,DATEADD(D,@DIAS_RECEBIMENTO_VOUCHER,M.DATA) AS DATA_RECEB
		,(SELECT TS.DATA_PROX_DIA_UTIL FROM BI.dbo.BI_CAD_SEMANA AS TS WHERE TS.DATA = DATEADD(D,@DIAS_RECEBIMENTO_VOUCHER,M.DATA)) AS DATA_PGTO
		,M.VLR_META*PR.PERC_VOUCHER*AM.PERC_AJUSTE_META_U15D as [VOUCHER_META]
	FROM
		[BI].[dbo].[BI_VENDA_META_FLUXO_RECEBIVEL] AS M
		INNER JOIN [BI].[dbo].[FIN_PARAM_RECEBIVEL] AS PR
			ON 1=1
			AND M.COD_LOJA = PR.COD_LOJA
			AND MONTH(M.DATA) = PR.MES
		INNER JOIN [BI].[dbo].[BI_CAD_SEMANA] AS S
			ON M.DATA = S.DATA
		LEFT JOIN @TAB_AJUSTE_META_U15D AS AM
			ON M.COD_LOJA = AM.COD_LOJA
	WHERE 1=1
		AND CONVERT(DATE,M.DATA) BETWEEN CONVERT(DATE,'2015-01-01') AND CONVERT(DATE,'2016-12-31')
		--AND M.COD_LOJA = 1	
	
	-- ------------------------------------------------------------------------
	-- BASE COM DTA_PGTO SOMADA
	-- ------------------------------------------------------------------------
	DECLARE @TEMP_VOUCHER_FINAL AS TABLE
	(
		COD_LOJA INT
		,DATA_PGTO DATE
		,VOUCHER_META NUMERIC(18,2)
	)
	
	INSERT INTO @TEMP_VOUCHER_FINAL	
		SELECT
			COD_LOJA
			,DATA_PGTO
			,SUM(VOUCHER_META) AS VOUCHER_META
		FROM
			@TEMP_VOUCHER
		GROUP BY
			COD_LOJA
			,DATA_PGTO		
	
	-- ------------------------------------------------------------------------
	-- UPDATING FIN_FLUXO_RECEBIVEL
	-- ------------------------------------------------------------------------
	UPDATE FR
	SET
		FR.VOUCHER_META = T.VOUCHER_META
	FROM
		BI.DBO.FIN_FLUXO_RECEBIVEL AS FR
		INNER JOIN @TEMP_VOUCHER_FINAL AS T
			ON 1=1
			AND FR.COD_LOJA = T.COD_LOJA
			AND FR.DATA = T.DATA_PGTO
	WHERE 1=1
		AND T.VOUCHER_META > 0			


-- #########################################################################################################################################################
-- DEBITO APOS @DIAS_RECEBIMENTO_DEBITO DIAS
-- #########################################################################################################################################################
	DECLARE @DIAS_RECEBIMENTO_DEBITO INT = 1
	
	-- ------------------------------------------------------------------------
	-- BASE COM DATA E DTA_PGTO
	-- ------------------------------------------------------------------------
	DECLARE @TEMP_DEBITO AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,DATA_RECEB DATE
		,DATA_PGTO DATE
		,DEBITO_META NUMERIC(18,2)
	)

	INSERT INTO @TEMP_DEBITO
	SELECT
		M.[COD_LOJA]
		,M.DATA AS DATA
		,DATEADD(D,@DIAS_RECEBIMENTO_DEBITO,M.DATA) AS DATA_RECEB
		,(SELECT TS.DATA_PROX_DIA_UTIL FROM BI.dbo.BI_CAD_SEMANA AS TS WHERE TS.DATA = DATEADD(D,@DIAS_RECEBIMENTO_DEBITO,M.DATA)) AS DATA_PGTO
		,M.VLR_META*PR.PERC_DEBITO*AM.PERC_AJUSTE_META_U15D as [DEBITO_META]
	FROM
		[BI].[dbo].[BI_VENDA_META_FLUXO_RECEBIVEL] AS M
		INNER JOIN [BI].[dbo].[FIN_PARAM_RECEBIVEL] AS PR
			ON 1=1
			AND M.COD_LOJA = PR.COD_LOJA
			AND MONTH(M.DATA) = PR.MES
		INNER JOIN [BI].[dbo].[BI_CAD_SEMANA] AS S
			ON M.DATA = S.DATA
		LEFT JOIN @TAB_AJUSTE_META_U15D AS AM
			ON M.COD_LOJA = AM.COD_LOJA
	WHERE 1=1
		AND CONVERT(DATE,M.DATA) BETWEEN CONVERT(DATE,'2015-01-01') AND CONVERT(DATE,'2016-12-31')
		--AND M.COD_LOJA = 1	
	
	-- ------------------------------------------------------------------------
	-- BASE COM DTA_PGTO SOMADA
	-- ------------------------------------------------------------------------
	DECLARE @TEMP_DEBITO_FINAL AS TABLE
	(
		COD_LOJA INT
		,DATA_PGTO DATE
		,DEBITO_META NUMERIC(18,2)
	)
	
	INSERT INTO @TEMP_DEBITO_FINAL	
		SELECT
			COD_LOJA
			,DATA_PGTO
			,SUM(DEBITO_META) AS DEBITO_META
		FROM
			@TEMP_DEBITO
		GROUP BY
			COD_LOJA
			,DATA_PGTO		
	
	-- ------------------------------------------------------------------------
	-- UPDATING FIN_FLUXO_RECEBIVEL
	-- ------------------------------------------------------------------------
	UPDATE FR
	SET
		FR.DEBITO_META = T.DEBITO_META
	FROM
		BI.DBO.FIN_FLUXO_RECEBIVEL AS FR
		INNER JOIN @TEMP_DEBITO_FINAL AS T
			ON 1=1
			AND FR.COD_LOJA = T.COD_LOJA
			AND FR.DATA = T.DATA_PGTO
	WHERE 1=1
		AND T.DEBITO_META > 0 			


-- #########################################################################################################################################################
-- DINHEIRO APOS REGRA_COLETA DIAS
-- #########################################################################################################################################################

	-- ------------------------------------------------------------------------
	-- BASE COM DATA E DTA_PGTO
	-- ------------------------------------------------------------------------
	DECLARE @TEMP_DINHEIRO AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,DATA_RECEB DATE
		,DATA_PGTO DATE
		,DINHEIRO_META NUMERIC(18,2)
	)

	INSERT INTO @TEMP_DINHEIRO
	SELECT
		M.[COD_LOJA]
		,M.DATA AS DATA
		,(CASE
			WHEN DATEPART(DW,M.DATA) = 2 THEN DATEADD(D,3,M.DATA) --Venda de Seg entrada na Qui
			WHEN DATEPART(DW,M.DATA) = 3 THEN DATEADD(D,2,M.DATA) --Venda de Ter entrada na Qui
			WHEN DATEPART(DW,M.DATA) = 4 THEN DATEADD(D,5,M.DATA) --Venda de Qua entrada na Seg
			WHEN DATEPART(DW,M.DATA) = 5 THEN DATEADD(D,4,M.DATA) --Venda de Qui entrada na Seg
			WHEN DATEPART(DW,M.DATA) = 6 THEN DATEADD(D,3,M.DATA) --Venda de Sex entrada na Seg
			WHEN DATEPART(DW,M.DATA) = 7 THEN DATEADD(D,3,M.DATA) --Venda de Sab entrada na Ter
			WHEN DATEPART(DW,M.DATA) = 1 THEN DATEADD(D,2,M.DATA) --Venda de Dom entrada na Ter
		END)AS DATA_RECEB
		,NULL AS DATA_PGTO
		,M.VLR_META*PR.PERC_DINHEIRO*AM.PERC_AJUSTE_META_U15D as [DINHEIRO_META]
	FROM
		[BI].[dbo].[BI_VENDA_META_FLUXO_RECEBIVEL] AS M
		INNER JOIN [BI].[dbo].[FIN_PARAM_RECEBIVEL] AS PR
			ON 1=1
			AND M.COD_LOJA = PR.COD_LOJA
			AND MONTH(M.DATA) = PR.MES
		INNER JOIN [BI].[dbo].[BI_CAD_SEMANA] AS S
			ON M.DATA = S.DATA
		LEFT JOIN @TAB_AJUSTE_META_U15D AS AM
			ON M.COD_LOJA = AM.COD_LOJA
	WHERE 1=1
		AND CONVERT(DATE,M.DATA) BETWEEN CONVERT(DATE,'2015-01-01') AND CONVERT(DATE,'2016-12-31')
		--AND M.COD_LOJA = 1	
	
	--ATUALIZANDO PROX DIA UTIL
	UPDATE T
	SET
		T.DATA_PGTO = S.DATA_PROX_DIA_UTIL
	FROM
		@TEMP_DINHEIRO AS T
		INNER JOIN [BI].[dbo].[BI_CAD_SEMANA] AS S
			ON T.DATA_RECEB = S.DATA
				
	-- ------------------------------------------------------------------------
	-- BASE COM DTA_PGTO SOMADA
	-- ------------------------------------------------------------------------
	DECLARE @TEMP_DINHEIRO_FINAL AS TABLE
	(
		COD_LOJA INT
		,DATA_PGTO DATE
		,DINHEIRO_META NUMERIC(18,2)
	)
	
	INSERT INTO @TEMP_DINHEIRO_FINAL	
		SELECT
			COD_LOJA
			,DATA_PGTO
			,SUM(DINHEIRO_META) AS DINHEIRO_META
		FROM
			@TEMP_DINHEIRO
		GROUP BY
			COD_LOJA
			,DATA_PGTO		
	
	-- ------------------------------------------------------------------------
	-- UPDATING FIN_FLUXO_RECEBIVEL
	-- ------------------------------------------------------------------------
	UPDATE FR
	SET
		FR.DINHEIRO_META = T.DINHEIRO_META
	FROM
		BI.DBO.FIN_FLUXO_RECEBIVEL AS FR
		INNER JOIN @TEMP_DINHEIRO_FINAL AS T
			ON 1=1
			AND FR.COD_LOJA = T.COD_LOJA
			AND FR.DATA = T.DATA_PGTO
	WHERE 1=1
		AND T.DINHEIRO_META > 0 

-- #########################################################################################################################################################
-- CONTA CLIENTE (DIA 10 DO MÊS)
-- #########################################################################################################################################################
	
	-- ------------------------------------------------------------------------
	-- BASE COM DATA E DTA_PGTO
	-- ------------------------------------------------------------------------
	DECLARE @TEMP_CONTA_CLIENTE AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,DATA_RECEB DATE
		,DATA_PGTO DATE
		,CONTA_CLIENTE_META NUMERIC(18,2)
	)

	INSERT INTO @TEMP_CONTA_CLIENTE
	SELECT
		M.[COD_LOJA]
		,M.DATA AS DATA
		,S.DATA_CONTA_CLIENTE
		,NULL AS DATA_PGTO
		,M.VLR_META*PR.PERC_CONTA_CLIENTE*AM.PERC_AJUSTE_META_U15D as CONTA_CLIENTE_META
	FROM
		[BI].[dbo].[BI_VENDA_META_FLUXO_RECEBIVEL] AS M
		INNER JOIN [BI].[dbo].[FIN_PARAM_RECEBIVEL] AS PR
			ON 1=1
			AND M.COD_LOJA = PR.COD_LOJA
			AND MONTH(M.DATA) = PR.MES
		INNER JOIN [BI].[dbo].[BI_CAD_SEMANA] AS S
			ON M.DATA = S.DATA
		LEFT JOIN @TAB_AJUSTE_META_U15D AS AM
			ON M.COD_LOJA = AM.COD_LOJA
	WHERE 1=1
		AND CONVERT(DATE,M.DATA) BETWEEN CONVERT(DATE,'2015-01-01') AND CONVERT(DATE,'2016-12-31')
		--AND M.COD_LOJA = 1	
	
	--ATUALIZANDO PROX DIA UTIL
	UPDATE T
	SET
		T.DATA_PGTO = S.DATA_PROX_DIA_UTIL
	FROM
		@TEMP_CONTA_CLIENTE AS T
		INNER JOIN [BI].[dbo].[BI_CAD_SEMANA] AS S
			ON T.DATA_RECEB = S.DATA
				
	-- ------------------------------------------------------------------------
	-- BASE COM DTA_PGTO SOMADA
	-- ------------------------------------------------------------------------
	DECLARE @TEMP_CONTA_CLIENTE_FINAL AS TABLE
	(
		COD_LOJA INT
		,DATA_PGTO DATE
		,CONTA_CLIENTE_META NUMERIC(18,2)
	)
	
	INSERT INTO @TEMP_CONTA_CLIENTE_FINAL	
		SELECT
			COD_LOJA
			,DATA_PGTO
			,SUM(CONTA_CLIENTE_META) AS CONTA_CLIENTE_META
		FROM
			@TEMP_CONTA_CLIENTE
		GROUP BY
			COD_LOJA
			,DATA_PGTO		
	
	-- ------------------------------------------------------------------------
	-- UPDATING FIN_FLUXO_RECEBIVEL
	-- ------------------------------------------------------------------------
	UPDATE FR
	SET
		FR.CONTA_CLIENTE_META = T.CONTA_CLIENTE_META
	FROM
		BI.DBO.FIN_FLUXO_RECEBIVEL AS FR
		INNER JOIN @TEMP_CONTA_CLIENTE_FINAL AS T
			ON 1=1
			AND FR.COD_LOJA = T.COD_LOJA
			AND FR.DATA = T.DATA_PGTO
	WHERE 1=1
		AND T.CONTA_CLIENTE_META > 0 


-- ---------------------------------------------------------------------------------------------------------------------------------
-- VERIFICANDO INCONSISTÊNCIAS - Não pode existir recebivel de SAB e DOM
-- ---------------------------------------------------------------------------------------------------------------------------------				
	--SELECT * FROM BI.DBO.FIN_FLUXO_RECEBIVEL WHERE CONTA_CLIENTE_META IS NOT NULL AND DATEPART(DW,DATA) IN (7,1)
	--SELECT * FROM BI.DBO.FIN_FLUXO_RECEBIVEL WHERE DATA >= '2016-01-01' and DATA <= '2016-02-28'