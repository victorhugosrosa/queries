-- ############################################################################################################################################
-- Variables
-- ############################################################################################################################################
	--DECLARE @DATA_P1_INI AS DATE = '20121231'
	DECLARE @DATA_P1_INI AS DATE = '20140101'
	--DECLARE @DATA_P1_FIM AS DATE = '20131229'
	DECLARE @DATA_P1_FIM AS DATE = '20140131'
	
	--DECLARE @DATA_P2_INI AS DATE = '20131230'
	DECLARE @DATA_P2_INI AS DATE = '20150101'
	--DECLARE @DATA_P2_FIM AS DATE = '20141228'
	DECLARE @DATA_P2_FIM AS DATE = '20150131'
	
	DECLARE @COD_FORNECEDOR AS INT = 1999
	
-- ############################################################################################################################################
-- Week table
-- ############################################################################################################################################
	DECLARE @TAB_SEMANAS AS TABLE
	(
		SEMANA INT
	)
	INSERT INTO @TAB_SEMANAS
		select ITEM from BI.dbo.fnSplit('1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52',',')

-- ############################################################################################################################################
-- Test Area
-- ############################################################################################################################################
	
	
-- ############################################################################################################################################
-- Base
-- ############################################################################################################################################
	DECLARE @TAB_LINHA_FORNECEDOR AS TABLE
	(
		SEMANA INT
		,COD_FORNECEDOR INT
		,NO_FORNECEDOR VARCHAR(50)
		,COD_LOJA INT
		,NO_LOJA VARCHAR(50)
		,NO_DEPARTAMENTO VARCHAR(50)
		,NO_SECAO VARCHAR(50)
		,NO_GRUPO VARCHAR(50)
		,COD_PRODUTO INT
		,NO_PRODUTO VARCHAR(50)
		,VLR_VENDA_P1 NUMERIC(18,2)
			--,QTD_VENDA_P1 NUMERIC(18,2)
		,VLR_VENDA_P2 NUMERIC(18,2)
			--,QTD_VENDA_P2 NUMERIC(18,2)
		,VLR_QUEBRA_P1 NUMERIC(18,2)
			--,QTD_QUEBRA_P1 NUMERIC(18,2)
		,VLR_QUEBRA_P2 NUMERIC(18,2)
			--,QTD_QUEBRA_P2 NUMERIC(18,2)
		,VLR_ENTRADA_P1 NUMERIC(18,2)
			--,QTD_ENTRADA_P1 NUMERIC(18,2)
		,VLR_ENTRADA_P2 NUMERIC(18,2)
			--,QTD_ENTRADA_P1 NUMERIC(18,2)
		,VLR_DPD_P1 NUMERIC(18,2)
		,VLR_DPD_P2 NUMERIC(18,2)
		,RUPTURA_P1 NUMERIC(18,2)
		,RUPTURA_P2 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_FORNECEDOR, COD_LOJA, COD_PRODUTO)
	);	
	INSERT INTO @TAB_LINHA_FORNECEDOR
	(
		SEMANA
		,COD_FORNECEDOR
		,NO_FORNECEDOR
		,COD_LOJA
		,NO_LOJA
		,NO_DEPARTAMENTO
		,NO_SECAO
		,NO_GRUPO
		,COD_PRODUTO
		,NO_PRODUTO
	)
	SELECT
		S.SEMANA
		,CFP.COD_FORNECEDOR
		,CF.DESCRICAO AS NO_FORNECEDOR
		,LP.COD_LOJA
		,L.NO_LOJA --+ '   [' + CONVERT(VARCHAR,L.DTA_ABERTURA) + ']'
		,CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,CP.COD_PRODUTO
		,CP.DESCRICAO AS NO_PRODUTO
	FROM
		BI.dbo.BI_CAD_PRODUTO AS CP
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR_PRODUTO AS CFP
			ON CP.COD_PRODUTO = CFP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR AS CF
			ON CFP.COD_FORNECEDOR = CF.COD_FORNECEDOR
		INNER JOIN BI.dbo.BI_LINHA_PRODUTOS AS LP
			ON CP.COD_PRODUTO = LP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_CAD_LOJA2 AS L
			ON LP.COD_LOJA = L.COD_LOJA
		INNER JOIN @TAB_SEMANAS AS S
			ON 1=1
	WHERE 1=1
		AND L.FLG_LOJA = 1
		AND CFP.COD_FORNECEDOR = @COD_FORNECEDOR
		--AND LP.FORA_LINHA = 'N'
		AND CP.COD_DEPARTAMENTO NOT IN (7,15,18,20,99)

-- ############################################################################################################################################
-- Venda
-- ############################################################################################################################################
	-- -------------------------------------
	-- P1 - INSERT
	-- -------------------------------------
	DECLARE @TAB_VENDA_FORNECEDOR_P1 AS TABLE
	(
		SEMANA INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_VENDA_P1 NUMERIC(18,2)
		--,QTD_VENDA_P1 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_VENDA_FORNECEDOR_P1
	SELECT
		S.SEMANA_454
		,VP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(VP.VALOR_TOTAL)
		--,SUM(VP.QTDE_PRODUTO)
	FROM	
		BI.dbo.BI_CAD_PRODUTO AS CP
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR_PRODUTO AS CFP
			ON CP.COD_PRODUTO = CFP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_VENDA_PRODUTO AS VP
			ON CP.COD_PRODUTO = VP.COD_PRODUTO
		INNER JOIN BI.DBO.BI_CAD_SEMANA AS S
			ON VP.DATA = S.DATA
	WHERE 1=1
		AND CFP.COD_FORNECEDOR = @COD_FORNECEDOR
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI) AND CONVERT(DATE,@DATA_P1_FIM)
		--AND CP.FORA_LINHA = 'N'
	GROUP BY
		S.SEMANA_454
		,VP.COD_LOJA
		,CP.COD_PRODUTO
	
	-- -------------------------------------
	-- P2 - INSERT
	-- -------------------------------------
	DECLARE @TAB_VENDA_FORNECEDOR_P2 AS TABLE
	(
		SEMANA INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_VENDA_P2 NUMERIC(18,2)
		--,QTD_VENDA_P2 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_VENDA_FORNECEDOR_P2
	SELECT
		S.SEMANA_454
		,VP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(VP.VALOR_TOTAL)
		--,SUM(VP.QTDE_PRODUTO)
	FROM	
		BI.dbo.BI_CAD_PRODUTO AS CP
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR_PRODUTO AS CFP
			ON CP.COD_PRODUTO = CFP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_VENDA_PRODUTO AS VP
			ON CP.COD_PRODUTO = VP.COD_PRODUTO
		INNER JOIN BI.DBO.BI_CAD_SEMANA AS S
			ON VP.DATA = S.DATA
	WHERE 1=1
		AND CFP.COD_FORNECEDOR = @COD_FORNECEDOR
		AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI) AND CONVERT(DATE,@DATA_P2_FIM)
		--AND CP.FORA_LINHA = 'N'
	GROUP BY
		S.SEMANA_454
		,VP.COD_LOJA
		,CP.COD_PRODUTO
		
	-- -----------------------------------------------------------
	-- P1 - UPDATE
	-- -----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VLR_VENDA_P1 = T.VLR_VENDA_P1
		--,MAIN.QTD_VENDA_P1 = T.QTD_VENDA_P1
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN @TAB_VENDA_FORNECEDOR_P1 AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
			AND MAIN.SEMANA = T.SEMANA
	
	-- -----------------------------------------------------------
	-- P2 - UPDATE
	-- -----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VLR_VENDA_P2 = T.VLR_VENDA_P2
		--,MAIN.QTD_VENDA_P2 = T.QTD_VENDA_P2
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN @TAB_VENDA_FORNECEDOR_P2 AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
			AND MAIN.SEMANA = T.SEMANA

-- ############################################################################################################################################
-- Quebra
-- ############################################################################################################################################
	-- -------------------------------------
	-- P1 - INSERT
	-- -------------------------------------
	DECLARE @TAB_QUEBRA_FORNECEDOR_P1 AS TABLE
	(
		SEMANA INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_QUEBRA_P1 NUMERIC(18,2)
		--,QTD_QUEBRA_P1 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_QUEBRA_FORNECEDOR_P1
	SELECT
		S.SEMANA_454
		,QP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(QP.VLR_QUEBRA)
		--,SUM(QP.QTD_QUEBRA)
	FROM	
		BI.dbo.BI_CAD_PRODUTO AS CP
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR_PRODUTO AS CFP
			ON CP.COD_PRODUTO = CFP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_QUEBRA_PRODUTO AS QP
			ON CP.COD_PRODUTO = QP.COD_PRODUTO
		INNER JOIN BI.DBO.BI_CAD_SEMANA AS S
			ON QP.DATA = S.DATA
	WHERE 1=1
		AND CFP.COD_FORNECEDOR = @COD_FORNECEDOR
		AND CONVERT(DATE,QP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI) AND CONVERT(DATE,@DATA_P1_FIM)
		--AND CP.FORA_LINHA = 'N'
	GROUP BY
		S.SEMANA_454
		,QP.COD_LOJA
		,CP.COD_PRODUTO
	
	-- -------------------------------------
	-- P2 - INSERT
	-- -------------------------------------
	DECLARE @TAB_QUEBRA_FORNECEDOR_P2 AS TABLE
	(
		SEMANA INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_QUEBRA_P2 NUMERIC(18,2)
		--,QTD_QUEBRA_P2 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_QUEBRA_FORNECEDOR_P2
	SELECT
		S.SEMANA_454
		,QP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(QP.VLR_QUEBRA)
		--,SUM(QP.QTD_QUEBRA)
	FROM	
		BI.dbo.BI_CAD_PRODUTO AS CP
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR_PRODUTO AS CFP
			ON CP.COD_PRODUTO = CFP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_QUEBRA_PRODUTO AS QP
			ON CP.COD_PRODUTO = QP.COD_PRODUTO
		INNER JOIN BI.DBO.BI_CAD_SEMANA AS S
			ON QP.DATA = S.DATA
	WHERE 1=1
		AND CFP.COD_FORNECEDOR = @COD_FORNECEDOR
		AND CONVERT(DATE,QP.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI) AND CONVERT(DATE,@DATA_P2_FIM)
		--AND CP.FORA_LINHA = 'N'
	GROUP BY
		S.SEMANA_454
		,QP.COD_LOJA
		,CP.COD_PRODUTO
		
	-- -----------------------------------------------------------
	-- P1 - UPDATE
	-- -----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VLR_QUEBRA_P1 = T.VLR_QUEBRA_P1
		--,MAIN.QTD_QUEBRA_P1 = T.QTD_QUEBRA_P1
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN @TAB_QUEBRA_FORNECEDOR_P1 AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
			AND MAIN.SEMANA = T.SEMANA
	
	-- -----------------------------------------------------------
	-- P2 - UPDATE
	-- -----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VLR_QUEBRA_P2 = T.VLR_QUEBRA_P2
		--,MAIN.QTD_QUEBRA_P2 = T.QTD_QUEBRA_P2
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN @TAB_QUEBRA_FORNECEDOR_P2 AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
			AND MAIN.SEMANA = T.SEMANA

-- ############################################################################################################################################
-- Entrada
-- ############################################################################################################################################
	-- -------------------------------------
	-- P1 - INSERT
	-- -------------------------------------
	DECLARE @TAB_ENTRADA_FORNECEDOR_P1 AS TABLE
	(
		SEMANA INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_ENTRADA_P1 NUMERIC(18,2)
		--,QTD_ENTRADA_P1 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_ENTRADA_FORNECEDOR_P1
	SELECT
		S.SEMANA_454
		,EP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(EP.VLR_ENTRADA)
		--,SUM(QP.QTD_ENTRADA)
	FROM	
		BI.dbo.BI_CAD_PRODUTO AS CP
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR_PRODUTO AS CFP
			ON CP.COD_PRODUTO = CFP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_ENTRADA_PRODUTO AS EP
			ON CP.COD_PRODUTO = EP.COD_PRODUTO
		INNER JOIN BI.DBO.BI_CAD_SEMANA AS S
			ON EP.DATA = S.DATA
	WHERE 1=1
		AND CFP.COD_FORNECEDOR = @COD_FORNECEDOR
		AND CONVERT(DATE,EP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI) AND CONVERT(DATE,@DATA_P1_FIM)
		--AND CP.FORA_LINHA = 'N'
	GROUP BY
		S.SEMANA_454
		,EP.COD_LOJA
		,CP.COD_PRODUTO
	
	-- -------------------------------------
	-- P2 - INSERT
	-- -------------------------------------
	DECLARE @TAB_ENTRADA_FORNECEDOR_P2 AS TABLE
	(
		SEMANA INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_ENTRADA_P2 NUMERIC(18,2)
		--,QTD_ENTRADA_P2 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_ENTRADA_FORNECEDOR_P2
	SELECT
		S.SEMANA_454
		,EP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(EP.VLR_ENTRADA)
		--,SUM(QP.QTD_ENTRADA)
	FROM	
		BI.dbo.BI_CAD_PRODUTO AS CP
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR_PRODUTO AS CFP
			ON CP.COD_PRODUTO = CFP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_ENTRADA_PRODUTO AS EP
			ON CP.COD_PRODUTO = EP.COD_PRODUTO
		INNER JOIN BI.DBO.BI_CAD_SEMANA AS S
			ON EP.DATA = S.DATA
	WHERE 1=1
		AND CFP.COD_FORNECEDOR = @COD_FORNECEDOR
		AND CONVERT(DATE,EP.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI) AND CONVERT(DATE,@DATA_P2_FIM)
		--AND CP.FORA_LINHA = 'N'
	GROUP BY
		S.SEMANA_454
		,EP.COD_LOJA
		,CP.COD_PRODUTO
		
	-- -----------------------------------------------------------
	-- P1 - UPDATE
	-- -----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VLR_ENTRADA_P1 = T.VLR_ENTRADA_P1
		--,MAIN.QTD_ENTRADA_P1 = T.QTD_ENTRADA_P1
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN @TAB_ENTRADA_FORNECEDOR_P1 AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
			AND MAIN.SEMANA = T.SEMANA
	
	-- -----------------------------------------------------------
	-- P2 - UPDATE
	-- -----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VLR_ENTRADA_P2 = T.VLR_ENTRADA_P2
		--,MAIN.QTD_ENTRADA_P2 = T.QTD_ENTRADA_P2
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN @TAB_ENTRADA_FORNECEDOR_P2 AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
			AND MAIN.SEMANA = T.SEMANA

-- ############################################################################################################################################
-- DPD e Ruptura
-- ############################################################################################################################################
	-- -------------------------------------
	-- P1 - INSERT
	-- -------------------------------------
	DECLARE @TAB_DPD_FORNECEDOR_P1 AS TABLE
	(
		SEMANA INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_DPD_P1 NUMERIC(18,2)
		,RUPTURA_P1 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_DPD_FORNECEDOR_P1
	SELECT
		S.SEMANA_454
		,EP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(EP.QTD_ESTOQUE * EP.VLR_VENDA) / SUM(NULLIF(EP.AVG_VLR_U30D_PD,0)) as DPD
		,CONVERT(NUMERIC(18,2),SUM(CASE WHEN ISNULL(EP.QTD_ESTOQUE,0) = 0 THEN 1 ELSE 0 END)) / CONVERT(NUMERIC(18,2),COUNT(EP.COD_PRODUTO)) as RUPTURA
	FROM	
		BI.dbo.BI_CAD_PRODUTO AS CP
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR_PRODUTO AS CFP
			ON CP.COD_PRODUTO = CFP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_ESTOQUE_PRODUTO_DIA AS EP
			ON CP.COD_PRODUTO = EP.COD_PRODUTO
		INNER JOIN BI.DBO.BI_CAD_SEMANA AS S
			ON EP.DATA = S.DATA
	WHERE 1=1
		AND CFP.COD_FORNECEDOR = @COD_FORNECEDOR
		AND CONVERT(DATE,EP.DATA) BETWEEN CONVERT(DATE,@DATA_P1_INI) AND CONVERT(DATE,@DATA_P1_FIM)
		--AND CP.FORA_LINHA = 'N'
	GROUP BY
		S.SEMANA_454
		,EP.COD_LOJA
		,CP.COD_PRODUTO
	
	-- -------------------------------------
	-- P2 - INSERT
	-- -------------------------------------
	DECLARE @TAB_DPD_FORNECEDOR_P2 AS TABLE
	(
		SEMANA INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_DPD_P2 NUMERIC(18,2)
		,RUPTURA_P2 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_DPD_FORNECEDOR_P2
	SELECT
		S.SEMANA_454
		,EP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(EP.QTD_ESTOQUE * EP.VLR_VENDA) / SUM(NULLIF(EP.AVG_VLR_U30D_PD,0)) as DPD
		,CONVERT(NUMERIC(18,2),SUM(CASE WHEN ISNULL(EP.QTD_ESTOQUE,0) = 0 THEN 1 ELSE 0 END)) / CONVERT(NUMERIC(18,2),COUNT(EP.COD_PRODUTO)) as RUPTURA
	FROM	
		BI.dbo.BI_CAD_PRODUTO AS CP
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR_PRODUTO AS CFP
			ON CP.COD_PRODUTO = CFP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_ESTOQUE_PRODUTO_DIA AS EP
			ON CP.COD_PRODUTO = EP.COD_PRODUTO
		INNER JOIN BI.DBO.BI_CAD_SEMANA AS S
			ON EP.DATA = S.DATA
	WHERE 1=1
		AND CFP.COD_FORNECEDOR = @COD_FORNECEDOR
		AND CONVERT(DATE,EP.DATA) BETWEEN CONVERT(DATE,@DATA_P2_INI) AND CONVERT(DATE,@DATA_P2_FIM)
		--AND CP.FORA_LINHA = 'N'
	GROUP BY
		S.SEMANA_454
		,EP.COD_LOJA
		,CP.COD_PRODUTO
		
	-- -----------------------------------------------------------
	-- P1 - UPDATE
	-- -----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VLR_DPD_P1 = T.VLR_DPD_P1
		,MAIN.RUPTURA_P1 = T.RUPTURA_P1
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN @TAB_DPD_FORNECEDOR_P1 AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
			AND MAIN.SEMANA = T.SEMANA
	
	-- -----------------------------------------------------------
	-- P2 - UPDATE
	-- -----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VLR_DPD_P2 = T.VLR_DPD_P2
		,MAIN.RUPTURA_P2 = T.RUPTURA_P2
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN @TAB_DPD_FORNECEDOR_P2 AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
			AND MAIN.SEMANA = T.SEMANA

-- ############################################################################################################################################
-- Final
-- ############################################################################################################################################
	SELECT
		SEMANA
		,COD_FORNECEDOR
		,NO_FORNECEDOR
		,COD_LOJA
		,NO_LOJA
		,NO_DEPARTAMENTO
		,NO_SECAO
		,NO_GRUPO
		,COD_PRODUTO
		,NO_PRODUTO
		-- ----------------------------------------------------------------------
		-- SQL
		-- ----------------------------------------------------------------------
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VLR_VENDA_P1,0)) AS VLR_VENDA_P1
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VLR_VENDA_P2,0)) AS VLR_VENDA_P2
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VLR_QUEBRA_P1*-1,0)) AS VLR_QUEBRA_P1
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VLR_QUEBRA_P2*-1,0)) AS VLR_QUEBRA_P2	
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VLR_ENTRADA_P1,0)) AS VLR_ENTRADA_P1
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VLR_ENTRADA_P2,0)) AS VLR_ENTRADA_P2		
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VLR_DPD_P1,0)) AS VLR_DPD_P1
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(VLR_DPD_P2,0)) AS VLR_DPD_P2		
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(RUPTURA_P1,0)) AS RUPTURA_P1
		,BI.dbo.fn_FormataVlr_Excel(ISNULL(RUPTURA_P2,0)) AS RUPTURA_P2
		-- ----------------------------------------------------------------------
		-- MATHEMATICA
		-- ----------------------------------------------------------------------
		--,ISNULL(VLR_VENDA_P1,0) AS VLR_VENDA_P1
		--,ISNULL(VLR_VENDA_P2,0) AS VLR_VENDA_P2
		--,ISNULL(VLR_QUEBRA_P1*-1,0) AS VLR_QUEBRA_P1
		--,ISNULL(VLR_QUEBRA_P2*-1,0) AS VLR_QUEBRA_P2	
		--,ISNULL(VLR_ENTRADA_P1,0) AS VLR_ENTRADA_P1
		--,ISNULL(VLR_ENTRADA_P2,0) AS VLR_ENTRADA_P2
		--,ISNULL(VLR_DPD_P1,0) AS VLR_DPD_P1
		--,ISNULL(VLR_DPD_P2,0) AS VLR_DPD_P2		
		--,ISNULL(RUPTURA_P1,0) AS RUPTURA_P1
		--,ISNULL(RUPTURA_P2,0) AS RUPTURA_P2
	FROM
		@TAB_LINHA_FORNECEDOR
	WHERE 1=1
		AND (VLR_VENDA_P1 IS NOT NULL OR VLR_VENDA_P2 IS NOT NULL)
		OR (VLR_QUEBRA_P1 IS NOT NULL OR VLR_QUEBRA_P2 IS NOT NULL)
	ORDER BY
		NO_DEPARTAMENTO
		,NO_SECAO
		,NO_GRUPO
		,NO_PRODUTO