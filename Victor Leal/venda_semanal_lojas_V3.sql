-- ####################################################################################################################################################################
-- 
-- ####################################################################################################################################################################
	SET NOCOUNT ON;
	DECLARE @DATA_P1_INI AS DATE = '20121231'
	DECLARE @DATA_P1_FIM AS DATE = '20131229'

	DECLARE @DATA_P2_INI AS DATE = '20131230'
	DECLARE @DATA_P2_FIM AS DATE = '20141228'

-- ####################################################################################################################################################################
-- 
-- ####################################################################################################################################################################
	DECLARE @TAB_VENDA_PERIODO AS TABLE
	(
		SEMANA INT	
		,COD_LOJA INT
		--,NO_REGIONAL VARCHAR(50)
		--,NO_LOJA VARCHAR(50)
		,VENDA_P1 NUMERIC(18,2)
		,VENDA_P2 NUMERIC(18,2)	
		,TICKET_P1 NUMERIC(18,2)
		,TICKET_P2 NUMERIC(18,2)
		,TM_P1 NUMERIC(18,2)
		,TM_P2 NUMERIC(18,2)
	);

	INSERT INTO @TAB_VENDA_PERIODO
	(
		SEMANA
		,COD_LOJA
	)
		SELECT DISTINCT
			BI.DBO.F_ISO_WEEK_OF_YEAR(C.DATA) AS SEMANA
			,C.COD_LOJA
		FROM
			BI.DBO.BI_VENDA_CUPOM AS C
			INNER JOIN BI.DBO.BI_CAD_LOJA2 AS L
				ON C.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND L.FLG_LOJA = 1
			AND CONVERT(DATE,C.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI) AND CONVERT(DATE,@DATA_P2_FIM)
			
	
-- ####################################################################################################################################################################
-- 
-- ####################################################################################################################################################################
	-- ----------------------------------------------------------
	-- P1
	-- ----------------------------------------------------------
	DECLARE @VENDA_P1 AS TABLE
	(
		SEMANA INT	
		,COD_LOJA INT
		,VENDA_P1 NUMERIC(18,2)
		,TICKET_P1 NUMERIC(18,2)
		,TM_P1 NUMERIC(18,2)
	)

	INSERT INTO @VENDA_P1
		SELECT
			BI.DBO.F_ISO_WEEK_OF_YEAR(C.DATA) AS SEMANA
			,C.COD_LOJA
			,SUM(C.VALOR_TOTAL) AS VLR_TOTAL
			,SUM(C.QTDE_CUPOM) AS QTD_CUPOM
			,AVG(C.CUPOM_MEDIO) AS CUPOM_MEDIO
		FROM
			BI.DBO.BI_VENDA_CUPOM AS C
			INNER JOIN BI.DBO.BI_CAD_LOJA2 AS L
				ON C.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND L.FLG_LOJA = 1
			AND CONVERT(DATE,C.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI) AND CONVERT(DATE,@DATA_P1_FIM)
		GROUP BY
			BI.DBO.F_ISO_WEEK_OF_YEAR(C.DATA)
			,C.COD_LOJA
	
	-- ----------------------------------------------------------
	-- P2
	-- ----------------------------------------------------------
	DECLARE @VENDA_P2 AS TABLE
	(
		SEMANA INT	
		,COD_LOJA INT
		,VENDA_P2 NUMERIC(18,2)
		,TICKET_P2 NUMERIC(18,2)
		,TM_P2 NUMERIC(18,2)
	)

	INSERT INTO @VENDA_P2
		SELECT
			BI.DBO.F_ISO_WEEK_OF_YEAR(C.DATA) AS SEMANA
			,C.COD_LOJA
			,SUM(C.VALOR_TOTAL) AS VLR_TOTAL
			,SUM(C.QTDE_CUPOM) AS QTD_CUPOM
			,AVG(C.CUPOM_MEDIO) AS CUPOM_MEDIO
		FROM
			BI.DBO.BI_VENDA_CUPOM AS C
			INNER JOIN BI.DBO.BI_CAD_LOJA2 AS L
				ON C.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND L.FLG_LOJA = 1
			AND CONVERT(DATE,C.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI) AND CONVERT(DATE,@DATA_P2_FIM)
		GROUP BY
			BI.DBO.F_ISO_WEEK_OF_YEAR(C.DATA)
			,C.COD_LOJA

-- ####################################################################################################################################################################
-- 
-- ####################################################################################################################################################################
	-- ----------------------------------------------------------
	-- P1
	-- ----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VENDA_P1 = T.VENDA_P1
		,MAIN.TICKET_P1 = T.TICKET_P1
		,MAIN.TM_P1 = T.TM_P1
	FROM
		@TAB_VENDA_PERIODO AS MAIN
		INNER JOIN @VENDA_P1 AS T
			ON 1=1
			AND MAIN.SEMANA = T.SEMANA
			AND MAIN.COD_LOJA = T.COD_LOJA
	
	-- ----------------------------------------------------------
	-- P2
	-- ----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VENDA_P2 = T.VENDA_P2
		,MAIN.TICKET_P2 = T.TICKET_P2
		,MAIN.TM_P2 = T.TM_P2
	FROM
		@TAB_VENDA_PERIODO AS MAIN
		INNER JOIN @VENDA_P2 AS T
			ON 1=1
			AND MAIN.SEMANA = T.SEMANA
			AND MAIN.COD_LOJA = T.COD_LOJA
			
-- ####################################################################################################################################################################
-- 
-- ####################################################################################################################################################################
	SELECT
		V.SEMANA	
		,L.NO_REGIONAL
		,L.NO_LOJA
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(V.VENDA_P1,0)) AS VENDA_P1
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(V.VENDA_P2,0)) AS VENDA_P2
		--,BI.dbo.fn_FormataVlr_Excel(ISNULL(1-(V.VENDA_P1/V.VENDA_P2),0)) AS 'ΔVenda'
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(V.TICKET_P1,0)) AS TICKET_P1
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(V.TICKET_P2,0)) AS TICKET_P2
		--,BI.dbo.fn_FormataVlr_Excel(ISNULL(1-(V.TICKET_P1/V.TICKET_P2),0)) AS 'ΔTicket'
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(V.TM_P1,0)) AS TM_P1
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(V.TM_P2,0)) AS TM_P2
		--,BI.dbo.fn_FormataVlr_Excel(ISNULL(1-(V.TM_P1/V.TM_P2),0)) AS 'ΔTM'
	FROM
		@TAB_VENDA_PERIODO AS V
		INNER JOIN BI.dbo.BI_CAD_LOJA2 AS L
			ON V.COD_LOJA = L.COD_LOJA
	ORDER BY
		SEMANA
		,L.NO_REGIONAL
		,L.DTA_ABERTURA