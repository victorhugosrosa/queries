DECLARE @DATA_INI AS DATE = GETDATE()-7--'2015-10-01'
DECLARE @DATA_FIM AS DATE = GETDATE()-1--'2015-10-31'
	
	DECLARE @COD_LOJA AS INT = 1

	DECLARE @TAB_DATES AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,ZANTHUS_VLR NUMERIC(18,2)
		,DW_VLR NUMERIC(18,2)
		,BI_VLR NUMERIC(18,2)
		,ZANTHUS_QTD NUMERIC(18,2)
		,DW_QTD NUMERIC(18,2)
		,BI_QTD NUMERIC(18,2)
		,PRIMARY KEY (COD_LOJA, DATA)
	)

	DECLARE @TAB_CUPOM_CANCELADO AS TABLE
	(
		M00AF DATE
		,M00ZA INT
		,M00AC INT
		,M00AD INT
	)

	DECLARE @TAB_DATES_DW AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,VLR_VENDA NUMERIC(18,2)
		,QTD_VENDA NUMERIC(18,2)
	)

WHILE @COD_LOJA <= 35
BEGIN
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATAS DISPONIVEIS
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
	--DELETE FROM @TAB_DATES
	INSERT INTO @TAB_DATES (COD_LOJA, DATA)
		SELECT
			L.COD_LOJA
			,S.DATA
		FROM
			BI.DBO.BI_CAD_SEMANA AS S
			INNER JOIN BI.dbo.BI_CAD_LOJA2 AS L
				ON 1=1
		WHERE 1=1
			AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
			AND L.COD_LOJA = @COD_LOJA
			--AND CONVERT(DATE,DATA) = '2015-10-07'
		ORDER BY
			DATA DESC
			
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATAS NA ZANTHUS
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
	DELETE FROM @TAB_CUPOM_CANCELADO
	INSERT INTO @TAB_CUPOM_CANCELADO
	SELECT
		M00AF, M00ZA, M00AC, M00AD-1
	FROM ZeusRetail.dbo.Zan_M01
	WHERE 1=1
		AND CONVERT(DATE,M00AF) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		AND M01AE = 147
		AND M00ZA = @COD_LOJA
	
	DECLARE @TAB_DATES_ZANTHUS AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,VLR_VENDA NUMERIC(18,2)
		,QTD_VENDA NUMERIC(18,2)
	)
	INSERT INTO @TAB_DATES_ZANTHUS
		SELECT
			M01.M00ZA
			,CONVERT(DATE,M01.M00AF)
			,SUM(M01.M01AK) AS Venda
			,COUNT(CASE WHEN M01AE <> 147 THEN M01.M00AD ELSE NULL END) AS Tickets
			--,COUNT(DISTINCT CONVERT(VARCHAR,M00AF,112)+ RIGHT('000'+ CONVERT(VARCHAR,M00ZA),3) + RIGHT('000'+ CONVERT(VARCHAR,M00AC),3) + RIGHT('00000000'+ CONVERT(VARCHAR,M00AD),8))  AS Tickets
		FROM
			ZeusRetail.dbo.Zan_M01 AS M01
			LEFT JOIN @TAB_CUPOM_CANCELADO AS CANC
				ON 1=1
				AND M01.M00AF = CANC.M00AF
				AND M01.M00ZA = CANC.M00ZA
				AND M01.M00AC = CANC.M00AC
				AND M01.M00AD = CANC.M00AD
		WHERE 1=1
			AND CANC.M00AD IS NULL
			AND CONVERT(DATE,M01.M00AF) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
			and M01AK > 0.01
			AND M01ZZA03 <> 9
			AND M01.M00ZA = @COD_LOJA
			and cupom_cancelamento = 0
		GROUP BY
			M01.M00ZA
			,CONVERT(DATE,M01.M00AF)

	UPDATE D
	SET
		D.ZANTHUS_VLR = Z.VLR_VENDA
		,D.ZANTHUS_QTD = Z.QTD_VENDA
	FROM
		@TAB_DATES AS D
		INNER JOIN @TAB_DATES_ZANTHUS AS Z
			ON D.DATA = Z.DATA
			AND D.COD_LOJA = Z.COD_LOJA

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATAS NO DW
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
	DELETE FROM @TAB_DATES_DW
	INSERT INTO @TAB_DATES_DW
		SELECT
			COD_LOJA
			,CONVERT(DATE,DATA)
			,SUM(VALOR_TOTAL)
			--,COUNT(CUPOM)
			,COUNT(DISTINCT CONVERT(VARCHAR,DATA,112)+ RIGHT('000'+ CONVERT(VARCHAR,COD_LOJA),3) + RIGHT('000'+ CONVERT(VARCHAR,CAIXA),3) + RIGHT('00000000'+ CONVERT(VARCHAR,CUPOM),8))  AS Tickets
		FROM 
			DW.DBO.BI_ANAL_MOVTO_CAIXA
		WHERE 1=1
			AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
			AND COD_LOJA = @COD_LOJA
		GROUP BY
			COD_LOJA
			,CONVERT(DATE,DATA)

	UPDATE D
	SET
		D.DW_VLR = DW.VLR_VENDA
		,D.DW_QTD = DW.QTD_VENDA
	FROM
		@TAB_DATES AS D
		INNER JOIN @TAB_DATES_DW AS DW
			ON D.DATA = DW.DATA
			AND D.COD_LOJA = DW.COD_LOJA

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATAS NO BI
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_DATES_BI AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,VLR_VENDA NUMERIC(18,2)
		,QTD_VENDA NUMERIC(18,2)
	)
	INSERT INTO @TAB_DATES_BI
		SELECT
			COD_LOJA
			,CONVERT(DATE,DATA)
			,SUM(VALOR_TOTAL)
			,SUM(QTDE_CUPOM)	
		FROM 
			BI.DBO.BI_VENDA_CUPOM
		WHERE 1=1
			AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
			AND COD_LOJA NOT IN (8,33)
			AND COD_LOJA = @COD_LOJA
		GROUP BY
			COD_LOJA
			,CONVERT(DATE,DATA)		

	UPDATE D
	SET
		D.BI_VLR = BI.VLR_VENDA
		,D.BI_QTD = BI.QTD_VENDA
	FROM
		@TAB_DATES AS D
		INNER JOIN @TAB_DATES_BI AS BI
			ON D.DATA = BI.DATA
			AND D.COD_LOJA = BI.COD_LOJA

PRINT @COD_LOJA
SET @COD_LOJA = @COD_LOJA + 1
END
	
	DELETE FROM @TAB_DATES WHERE COD_LOJA NOT IN (SELECT DISTINCT COD_LOJA FROM BI.dbo.BI_CAD_LOJA2 WHERE FLG_LOJA = 1 AND COD_LOJA <> 8)
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
	--
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT
			D.COD_LOJA
			,DATA
			,ZANTHUS_VLR
			,DW_VLR
			,BI_VLR
			,ZANTHUS_QTD
			,DW_QTD
			,BI_QTD
			,'Critica de Valor' AS [_]
			,ZANTHUS_VLR - DW_VLR AS [Vlr Falta DW]--[Z VS DW]
			,ZANTHUS_VLR - BI_VLR AS [Vlr Falta BI]--[Z VS BI]
			,DW_VLR - BI_VLR AS [DW VS BI]
			,'Critica de Quantidade' AS [_]
			,ZANTHUS_QTD - DW_QTD AS [Cupom Falta DW]--[Z VS DW]
			,ZANTHUS_QTD - BI_QTD AS [Cupom Falta BI]--[Z VS BI]
			,DW_QTD - BI_QTD AS [DW VS BI]
		FROM
			@TAB_DATES AS D
		WHERE 1=1
			AND (ZANTHUS_VLR - DW_VLR <> 0 OR ZANTHUS_VLR - BI_VLR <> 0 OR DW_VLR - BI_VLR <> 0)
		ORDER BY
			COD_LOJA
			,DATA

--SELECT COD_LOJA, COUNT(DISTINCT DATA) FROM DW.DBO.BI_ANAL_MOVTO_CAIXA WHERE CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,GETDATE()-90) AND CONVERT(DATE,GETDATE()-1) GROUP BY COD_LOJA
--SELECT COD_LOJA, COUNT(DISTINCT DATA) FROM BI.DBO.BI_VENDA_CUPOM WHERE CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,GETDATE()-90) AND CONVERT(DATE,GETDATE()-1) GROUP BY COD_LOJA
/*
		SELECT * FROM ZeusRetail.dbo.Zan_M01
		WHERE 1=1
			AND CONVERT(DATE,M00AF) = '2015-10-29'
			and M01AK > 0.01
			AND M01ZZA03 <> 9
			AND M00ZA = 1
			AND M01AK = 2.66


		SELECT * FROM ZeusRetail.dbo.Zan_M01
		WHERE 1=1
			AND CONVERT(DATE,M00AF) = '2015-12-02'
			and M01AK > 0.01
			AND M01ZZA03 <> 9
			AND M00ZA = 27
			AND M01AK = 63.84
			
*/
