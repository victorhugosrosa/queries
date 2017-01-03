-- ---------------------------------------------------------------------------------------------------------------------------
-- VLR_ULTIMA_ENTRADA
-- ---------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_AUDITORIA_CUSTO AS TABLE
	(
		COD_LOJA INT
		,COD_PRODUTO INT
		,COD_FORNECEDOR INT
		,DTA_ENTRADA DATE
		,VLR_ULTIMA_ENTRADA NUMERIC(18,2)
		,VLR_TABELA_FORN NUMERIC(18,2)
		,VLR_TABELA_ORBIS NUMERIC(18,2)
		,PV_ORBIS NUMERIC(18,2)
		,PV_LOJA NUMERIC(18,2)
		,PRIMARY KEY (COD_LOJA, COD_PRODUTO, COD_FORNECEDOR)
	)
	INSERT INTO @TAB_AUDITORIA_CUSTO
	(
		COD_LOJA
		,COD_PRODUTO
		,COD_FORNECEDOR
		,DTA_ENTRADA
		,VLR_ULTIMA_ENTRADA
	)
		SELECT
			COD_LOJA
			,COD_PRODUTO
			,COD_FORNECEDOR
			,DTA_ENTRADA
			,VAL_CUSTO_REP
		FROM
		(	
			SELECT DISTINCT
				COD_LOJA
				,COD_PRODUTO
				,COD_FORNECEDOR
				,DTA_ENTRADA
				,VAL_CUSTO_REP
				,RANK() over (partition by cod_loja, COD_PRODUTO ORDER BY DTA_ENTRADA DESC, VAL_CUSTO_REP DESC) AS SEQ
			FROM
				[DW].[dbo].[vw_MARCHE_ENTRADAS] with(nolock)
			WHERE 1=1
				AND COD_LOJA = 5
		) as x
		WHERE 1=1
			AND SEQ = 1		
			--AND COD_PRODUTO = 52382
			--AND COD_FORNECEDOR = 1022		

-- ---------------------------------------------------------------------------------------------------------------------------
-- VLR_TABELA_FORN
-- ---------------------------------------------------------------------------------------------------------------------------
	UPDATE TC
	SET
		TC.VLR_TABELA_FORN = C.VLR_EMB_COMPRA
	FROM
		@TAB_AUDITORIA_CUSTO AS TC
		INNER JOIN BI.dbo.VW_CUSTOS_ATIVOS AS C
			ON 1=1
			AND TC.COD_PRODUTO = C.COD_PRODUTO
			AND TC.COD_FORNECEDOR = C.COD_FORNECEDOR

-- ---------------------------------------------------------------------------------------------------------------------------
-- VLR_TABELA_ORBIS
-- ---------------------------------------------------------------------------------------------------------------------------
	UPDATE TC
	SET
		TC.VLR_TABELA_ORBIS = C.VLR_EMB_COMPRA
	FROM
		@TAB_AUDITORIA_CUSTO AS TC
		INNER JOIN BI.dbo.VW_CUSTOS_ATIVOS AS C
			ON 1=1
			AND TC.COD_PRODUTO = C.COD_PRODUTO
			AND C.COD_FORNECEDOR = 18055

-- ---------------------------------------------------------------------------------------------------------------------------
-- FINAL
-- ---------------------------------------------------------------------------------------------------------------------------
	SELECT
	*
	FROM
		@TAB_AUDITORIA_CUSTO