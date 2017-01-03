-- ############################################################################################################################################
-- Variables
-- ############################################################################################################################################
	DECLARE @DATA_P1_INI AS DATE = '20121231'
	DECLARE @DATA_P1_FIM AS DATE = '20131229'

	DECLARE @DATA_P2_INI AS DATE = '20131230'
	DECLARE @DATA_P2_FIM AS DATE = '20141228'
	
	DECLARE @COD_FORNECEDOR AS INT = 1999
	
-- ############################################################################################################################################
-- Week Table
-- ############################################################################################################################################
	DECLARE @TAB_SEMANAS AS TABLE
	(
		SEMANA INT
	)
	INSERT INTO @TAB_SEMANAS
		select ITEM from BI.dbo.fnSplit('1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52',',')
		
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
		,QTD_VENDA_P1 NUMERIC(18,2)
		,VLR_VENDA_P2 NUMERIC(18,2)
		,QTD_VENDA_P2 NUMERIC(18,2)
		--,VLR_QUEBRA_P1 NUMERIC(18,2)
		--,QTD_QUEBRA_P1 NUMERIC(18,2)
		--,VLR_QUEBRA_P2 NUMERIC(18,2)
		--,QTD_QUEBRA_P2 NUMERIC(18,2)
		--,VLR_ESTOQUE NUMERIC(18,2)
		--,QTD_ESTOQUE NUMERIC(18,2)
		--,AVG_VLR_U30D_PD NUMERIC(18,2)
		--,DPD NUMERIC(18,2)
		--,RUPTURA BIT
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
		,L.NO_LOJA
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
		,QTD_VENDA_P1 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_VENDA_FORNECEDOR_P1
	SELECT
		S.SEMANA_454
		,VP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(VP.VALOR_TOTAL)
		,SUM(VP.QTDE_PRODUTO)
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
		,QTD_VENDA_P2 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_VENDA_FORNECEDOR_P2
	SELECT
		S.SEMANA_454
		,VP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(VP.VALOR_TOTAL)
		,SUM(VP.QTDE_PRODUTO)
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
		,MAIN.QTD_VENDA_P1 = T.QTD_VENDA_P1
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
		,MAIN.QTD_VENDA_P2 = T.QTD_VENDA_P2
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
/*
	-- -------------------------------------
	-- P1 - INSERT
	-- -------------------------------------
	DECLARE @TAB_QUEBRA_FORNECEDOR_P1 AS TABLE
	(
		SEMANA INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_QUEBRA_P1 NUMERIC(18,2)
		,QTD_QUEBRA_P1 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_QUEBRA_FORNECEDOR_P1
	SELECT
		S.SEMANA_454
		,QP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(QP.VLR_QUEBRA)
		,SUM(QP.QTD_QUEBRA)
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
		,QTD_QUEBRA_P2 NUMERIC(18,2)
		PRIMARY KEY (SEMANA, COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_QUEBRA_FORNECEDOR_P2
	SELECT
		S.SEMANA_454
		,QP.COD_LOJA
		,CP.COD_PRODUTO
		,SUM(QP.VLR_QUEBRA)
		,SUM(QP.QTD_QUEBRA)
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
		,MAIN.QTD_QUEBRA_P1 = T.QTD_QUEBRA_P1
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
		,MAIN.QTD_QUEBRA_P2 = T.QTD_QUEBRA_P2
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN @TAB_QUEBRA_FORNECEDOR_P2 AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
			AND MAIN.SEMANA = T.SEMANA
*/			
-- ############################################################################################################################################
-- Estoque
-- ############################################################################################################################################
/*
	DECLARE @TAB_CUSTO_PROD AS TABLE
	(
		COD_PRODUTO INT
		,VLR_CUSTO NUMERIC(18,2)
	);
	INSERT INTO @TAB_CUSTO_PROD
	SELECT
		COD_PRODUTO
		,(VAL_CUSTO_EMBALAGEM/QTD_EMBALAGEM_COMPRA)
	FROM
		[192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR
	WHERE 1=1
		AND COD_LOJA = 1
		AND COD_FORNECEDOR = @COD_FORNECEDOR
	
	DECLARE @TAB_EST_FORNECEDOR AS TABLE
	(
		COD_LOJA INT
		,COD_PRODUTO INT
		,VLR_ESTOQUE NUMERIC(18,2)
		,QTD_ESTOQUE NUMERIC(18,2)
		PRIMARY KEY (COD_LOJA, COD_PRODUTO)
	);
	INSERT INTO @TAB_EST_FORNECEDOR
	SELECT
		EP.COD_LOJA
		,CP.COD_PRODUTO
		,C.VLR_CUSTO * EP.QTD_ESTOQUE
		,EP.QTD_ESTOQUE		
	FROM	
		BI.dbo.BI_CAD_PRODUTO AS CP
		INNER JOIN BI.dbo.BI_CAD_FORNECEDOR_PRODUTO AS CFP
			ON CP.COD_PRODUTO = CFP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_ESTOQUE_PRODUTO AS EP
			ON CP.COD_PRODUTO = EP.COD_PRODUTO
		INNER JOIN @TAB_CUSTO_PROD AS C
			ON CP.COD_PRODUTO = C.COD_PRODUTO
	WHERE 1=1
		AND CFP.COD_FORNECEDOR = @COD_FORNECEDOR
	
	-- -----------------------------------------------------------
	--
	-- -----------------------------------------------------------
	UPDATE MAIN
	SET
		MAIN.VLR_ESTOQUE = T.VLR_ESTOQUE
		,MAIN.QTD_ESTOQUE = T.QTD_ESTOQUE
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN @TAB_EST_FORNECEDOR AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
*/		
-- ############################################################################################################################################
-- DPD e Ruptura
-- ############################################################################################################################################
/*
	UPDATE MAIN
	SET
		MAIN.AVG_VLR_U30D_PD = T.AVG_VLR_U30D_PD
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN
		INNER JOIN COMPRAS_ESTATISTICA_PRODUTO AS T
			ON 1=1
			AND MAIN.COD_LOJA = T.COD_LOJA
			AND MAIN.COD_PRODUTO = T.COD_PRODUTO
	
	UPDATE MAIN
	SET
		MAIN.DPD = MAIN.VLR_ESTOQUE / NULLIF(MAIN.AVG_VLR_U30D_PD,0)
		,MAIN.RUPTURA = (CASE WHEN ISNULL(QTD_ESTOQUE,0) = 0 THEN 1 ELSE 0 END)
	FROM
		@TAB_LINHA_FORNECEDOR AS MAIN		
*/
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
		,BI.dbo.fn_FormataVlr_Excel(VLR_VENDA_P1) AS VLR_VENDA_P1
		,BI.dbo.fn_FormataVlr_Excel(QTD_VENDA_P1) AS QTD_VENDA_P1
		,BI.dbo.fn_FormataVlr_Excel(VLR_VENDA_P2) AS VLR_VENDA_P2
		,BI.dbo.fn_FormataVlr_Excel(QTD_VENDA_P2) AS QTD_VENDA_P2
		--,BI.dbo.fn_FormataVlr_Excel(VLR_QUEBRA_P1*-1) AS VLR_QUEBRA_P1
		--,BI.dbo.fn_FormataVlr_Excel(QTD_QUEBRA_P1) AS QTD_QUEBRA_P1
		--,BI.dbo.fn_FormataVlr_Excel(VLR_QUEBRA_P2*-1) AS VLR_QUEBRA_P2
		--,BI.dbo.fn_FormataVlr_Excel(QTD_QUEBRA_P2) AS QTD_QUEBRA_P2
		--,BI.dbo.fn_FormataVlr_Excel(VLR_ESTOQUE) AS VLR_ESTOQUE
		--,BI.dbo.fn_FormataVlr_Excel(QTD_ESTOQUE) AS QTD_ESTOQUE
		--,BI.dbo.fn_FormataVlr_Excel(AVG_VLR_U30D_PD) AS AVG_VLR_U30D_PD
		--,BI.dbo.fn_FormataVlr_Excel(DPD) AS DPD
		--,BI.dbo.fn_FormataVlr_Excel(RUPTURA) AS RUPTURA
	FROM @TAB_LINHA_FORNECEDOR
	ORDER BY
		NO_DEPARTAMENTO
		,NO_SECAO
		,NO_GRUPO
		,NO_PRODUTO