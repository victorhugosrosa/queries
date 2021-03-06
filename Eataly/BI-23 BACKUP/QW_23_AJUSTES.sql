USE [BI]
GO
/****** Object:  StoredProcedure [dbo].[QW_23_AJUSTES]    Script Date: 10/14/2016 19:33:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[QW_23_AJUSTES]
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @DATA_INI AS DATE = '2016-08-01'
	DECLARE @DATA_FIM AS DATE = GETDATE()-1
	
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_AJUSTE_ESTOQUE AS TABLE
	(
		COD_LOJA INT
		,DATA DATE
		,TIPO_AJUSTE VARCHAR(50)
		,COD_RESTAURANTE INT
		,COD_AJUSTE INT
		,DES_AJUSTE VARCHAR(50)
		,COD_PRODUTO INT
		,QTD_AJUSTE NUMERIC(18,2)
		,VAL_CUSTO_MED NUMERIC(18,2)
		,VAL_CUSTO_REP NUMERIC(18,2)
	)
	INSERT INTO @TAB_AJUSTE_ESTOQUE
		SELECT
			T.COD_LOJA
			,T.DTA_AJUSTE
			,'Transferencia' AS TIPO_AJUSTE
			,NULL			
			,T.COD_AJUSTE
			,TA.DES_AJUSTE
			,T.COD_PRODUTO
			,T.QTD_AJUSTE*-1
			,T.VAL_CUSTO_MED
			,T.VAL_CUSTO_REP			
		FROM
			[192.168.0.6].ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS T
			INNER JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_TIPO_AJUSTE AS TA
				ON 1=1
				AND T.COD_AJUSTE = TA.COD_AJUSTE		
		WHERE 1=1
			AND T.COD_LOJA = 33
			AND T.COD_AJUSTE IN (250,251,252,253,254,255,256,257,258,259,260,/*pizza261,*/262,263,264,495,496, /*NEW*/498,499,500,501,502,503,504,505,506,507,509,510,511,512,513,514,515,516,517,518,519,520,521,523,524,525)
			AND CONVERT(DATE,T.DTA_AJUSTE) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
			and t.cod_produto not in (1036025,1023870) --barril chopp
		/*
		UNION ALL
		
		SELECT
			T.COD_LOJA
			,T.DTA_AJUSTE
			,'Quebra' AS TIPO_AJUSTE
			,NULL			
			,T.COD_AJUSTE
			,TA.DES_AJUSTE
			,T.COD_PRODUTO
			,T.QTD_AJUSTE*-1
			,T.VAL_CUSTO_MED
			,T.VAL_CUSTO_REP			
		FROM
			[192.168.0.6].ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS T
			INNER JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_TIPO_AJUSTE AS TA
				ON 1=1
				AND T.COD_AJUSTE = TA.COD_AJUSTE		
		WHERE 1=1
			AND T.COD_LOJA = 33
			AND T.COD_AJUSTE IN (414,428,442,456,470,422,436,450,464,478,418,432,446,460,474,423,437,451,465,479,424,438,452,466,480,421,435,449,463,477,425,439,453,467,481)
			AND CONVERT(DATE,T.DTA_AJUSTE) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		*/	
		UPDATE @TAB_AJUSTE_ESTOQUE
		SET
			COD_RESTAURANTE = 			
			(CASE
				WHEN COD_AJUSTE = 250 THEN 101
				WHEN COD_AJUSTE = 251 THEN 102
				WHEN COD_AJUSTE = 252 THEN 103
				WHEN COD_AJUSTE = 253 THEN 104
				WHEN COD_AJUSTE = 254 THEN 107
				WHEN COD_AJUSTE = 255 THEN 106
				WHEN COD_AJUSTE = 256 THEN 105
				WHEN COD_AJUSTE = 257 THEN 116
				WHEN COD_AJUSTE = 258 THEN 109
				WHEN COD_AJUSTE = 259 THEN 110
				WHEN COD_AJUSTE = 260 THEN 111
				WHEN COD_AJUSTE = 261 THEN 111
				WHEN COD_AJUSTE = 262 THEN 113
				WHEN COD_AJUSTE = 263 THEN 114
				WHEN COD_AJUSTE = 264 THEN 115	
			/*NEW*/
				WHEN COD_AJUSTE = 498 THEN 102
				WHEN COD_AJUSTE = 499 THEN 103
				WHEN COD_AJUSTE = 500 THEN 104
				WHEN COD_AJUSTE = 501 THEN 107
				WHEN COD_AJUSTE = 502 THEN 106
				WHEN COD_AJUSTE = 503 THEN 105
				WHEN COD_AJUSTE = 504 THEN 116
				WHEN COD_AJUSTE = 505 THEN 109
				WHEN COD_AJUSTE = 506 THEN 110
				WHEN COD_AJUSTE = 507 THEN 111
				WHEN COD_AJUSTE = 509 THEN 113
				WHEN COD_AJUSTE = 510 THEN 114
				WHEN COD_AJUSTE = 511 THEN 115
				WHEN COD_AJUSTE = 512 THEN 102
				WHEN COD_AJUSTE = 513 THEN 103
				WHEN COD_AJUSTE = 514 THEN 104
				WHEN COD_AJUSTE = 515 THEN 107
				WHEN COD_AJUSTE = 516 THEN 106
				WHEN COD_AJUSTE = 517 THEN 105
				WHEN COD_AJUSTE = 518 THEN 116
				WHEN COD_AJUSTE = 519 THEN 109
				WHEN COD_AJUSTE = 520 THEN 110
				WHEN COD_AJUSTE = 521 THEN 111
				WHEN COD_AJUSTE = 523 THEN 113
				WHEN COD_AJUSTE = 524 THEN 114
				WHEN COD_AJUSTE = 525 THEN 115
				
				ELSE NULL
			END)
		
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	DECLARE @TAB_AJUSTE_ESTOQUE_29 AS TABLE
	(
		COD_PRODUTO INT
		,ANO_454 INT
		,SEMANA_454 INT
		,VAL_CUSTO_MED NUMERIC(18,2)
		,VAL_CUSTO_REP NUMERIC(18,2)
		
	)
	INSERT INTO @TAB_AJUSTE_ESTOQUE_29
		SELECT
			COD_PRODUTO
			,s.ANO_454
			,s.SEMANA_454
			,MAX(VAL_CUSTO_MED)
			,MAX(VAL_CUSTO_rep)
		FROM
			[192.168.0.6].ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS A
			INNER JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_TIPO_AJUSTE AS B
				ON 1=1
				AND A.COD_AJUSTE = B.COD_AJUSTE	
			inner join BI.dbo.BI_CAD_SEMANA as s
				on convert(date,a.dta_ajuste) = convert(date,s.DATA)
		WHERE 1=1
			AND A.COD_LOJA = 29
			and A.COD_AJUSTE in (269/*manual*/,281/*auto*/)
			AND CONVERT(DATE,A.DTA_AJUSTE) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			COD_PRODUTO
			,s.ANO_454
			,s.SEMANA_454
			
	/*
	DECLARE @TAB_AJUSTE_ESTOQUE_29 AS TABLE
	(
		DATA DATE
		,COD_PRODUTO INT
		,VAL_CUSTO_MED NUMERIC(18,2)
		,VAL_CUSTO_REP NUMERIC(18,2)
		,QTD_AJUSTE NUMERIC(18,2)		
	)
	INSERT INTO @TAB_AJUSTE_ESTOQUE_29
		SELECT
			DATEADD(D,-1,A.DTA_AJUSTE) AS DATA_VENDA
			,A.COD_PRODUTO
			,AVG(A.VAL_CUSTO_MED) AS VAL_CUSTO_MED
			,AVG(A.VAL_CUSTO_REp) AS VAL_CUSTO_REP
			,sum(A.QTD_AJUSTE*-1) AS QTD_AJUSTE		
		FROM
			[192.168.0.6].ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS A
			INNER JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_TIPO_AJUSTE AS B
				ON 1=1
				AND A.COD_AJUSTE = B.COD_AJUSTE		
		WHERE 1=1
			AND A.COD_LOJA = 29
			and A.COD_AJUSTE in (269/*manual*/,281/*auto*/)
			AND CONVERT(DATE,A.DTA_AJUSTE) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			DATEADD(D,-1,A.DTA_AJUSTE)
			,A.COD_PRODUTO
		ORDER BY
			DATEADD(D,-1,A.DTA_AJUSTE)		
	*/
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_ULT_CUSTO_TAB AS TABLE
	(
		COD_PRODUTO INT
		,VLR_EMB_COMPRA NUMERIC(18,2)
	)
	INSERT INTO @TAB_ULT_CUSTO_TAB
		SELECT
			COD_PRODUTO
			,VLR_EMB_COMPRA
		FROM
		(
			SELECT
				COD_PRODUTO
				,VLR_EMB_COMPRA
				,RANK() OVER (PARTITION BY COD_PRODUTO ORDER BY DTA_GRAVACAO DESC) AS SEQ
			FROM
				VW_CUSTOS_ATIVOS
			WHERE 1=1
				and COD_FORNECEDOR = 102856
				--and COD_PRODUTO = 686556
		) AS X
		WHERE SEQ = 1
	
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	SELECT
		A.COD_LOJA
		,CONVERT(DATE,A.DATA) AS DATA
		,A.TIPO_AJUSTE
		,A.COD_RESTAURANTE
		,A.COD_AJUSTE
		,A.DES_AJUSTE
		,A.COD_PRODUTO
		,SUM(A.QTD_AJUSTE) AS QTD_AJUSTE
		,max(CASE WHEN A.VAL_CUSTO_MED = 0 THEN (CASE WHEN A.VAL_CUSTO_REP = 0 THEN isnull(PC33.CUSTO,PC29.CUSTO) ELSE A.VAL_CUSTO_REP END) ELSE A.VAL_CUSTO_MED END) AS VAL_CUSTO_MED
		,max(CASE WHEN A.VAL_CUSTO_REP = 0 THEN isnull(PC33.CUSTO,PC29.CUSTO) ELSE A.VAL_CUSTO_REP END) AS VAL_CUSTO_REP
	FROM
		@TAB_AJUSTE_ESTOQUE AS A
		INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
			ON A.DATA = S.DATA
		left join BI.dbo.BI_CAD_PRODUTO AS CP
			ON A.COD_PRODUTO = CP.COD_PRODUTO
		LEFT JOIN DW.dbo.PRODUTO_CUSTOS AS PC33
			ON 1=1
			AND PC33.COD_LOJA = 33
			AND A.COD_PRODUTO = PC33.COD_PRODUTO	
		LEFT JOIN DW.dbo.PRODUTO_CUSTOS AS PC29
			ON 1=1
			AND PC29.COD_LOJA = 29
			AND A.COD_PRODUTO = PC29.COD_PRODUTO	
		--LEFT JOIN BI.dbo.BI_LINHA_PRODUTOS AS LP
		--	ON 1=1
		--	AND A.COD_LOJA = LP.COD_LOJA
		--	AND A.COD_PRODUTO = LP.COD_PRODUTO	
	WHERE 1=1
		--AND A.COD_RESTAURANTE IN (SELECT DISTINCT COD_RESTAURANTE FROM BI.dbo.BI_CAD_RESTAURANTE WHERE TIPO_RESTAURANTE = 'FTS')	
		AND A.COD_RESTAURANTE not IN (105,107,112)
		and CP.COD_DEPARTAMENTO NOT IN (2,9) 
		AND CP.COD_SECAO NOT IN (58)
		
		
	GROUP BY
		A.COD_LOJA
		,CONVERT(DATE,A.DATA)
		,A.TIPO_AJUSTE
		,A.COD_RESTAURANTE
		,A.COD_AJUSTE
		,A.DES_AJUSTE
		,A.COD_PRODUTO	
	
	UNION ALL

	SELECT		
		COD_LOJA
		,DATA
		,'Transferencia'
		,COD_RESTAURANTE
		,281 AS COD_AJUSTE
		,'TRANSFERENCIA AUTOMATICA' As DES_AJUSTE
		,COD_PRODUTO
		,CASE WHEN SUM(QTD_AJUSTE) < 0 THEN 0 ELSE SUM(QTD_AJUSTE) END AS QTD_AJUSTE
		,max(VAL_CUSTO_MED)
		,max(VAL_CUSTO_REP)	
	FROM
(	
	SELECT		
		VI.COD_LOJA
		,CONVERT(DATE,VI.DATA) AS DATA
		,'Transferencia' AS TIPO
		,VI.COD_RESTAURANTE
		,281 AS COD_AJUSTE
		,'TRANSFERENCIA AUTOMATICA' As DES_AJUSTE
		,DEPARA.COD_PRODUTO
		,SUM(VI.QUANTIDADE*ISNULL(VI.Quantidade_Dividida,1)) AS QTD_AJUSTE
		,max(CASE
			WHEN ISNULL(T.VAL_CUSTO_MED,0) = 0 THEN 
				(CASE WHEN ISNULL(T.VAL_CUSTO_REP,0) = 0 THEN isnull(PC33.CUSTO_ENTRADA,(case when isnull(PC29.CUSTO_ENTRADA,0) = 0 then UT.VLR_EMB_COMPRA else PC29.CUSTO end) ) ELSE T.VAL_CUSTO_REP END)
			ELSE T.VAL_CUSTO_MED
			END) AS VAL_CUSTO_MED
		,max(CASE WHEN ISNULL(T.VAL_CUSTO_REP,0) = 0 THEN isnull(PC33.CUSTO_ENTRADA,PC29.CUSTO_ENTRADA) ELSE T.VAL_CUSTO_REP END) AS VAL_CUSTO_REP
	FROM
		[DW].[dbo].[TAB_CHEFFSOLUTION_CUPOM_ITENS] AS VI
		INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
			ON VI.DATA = S.DATA
		LEFT JOIN BI.dbo.BI_CAD_RESTAURANTE AS CR
			ON 1=1
			AND VI.COD_LOJA = CR.COD_LOJA
			AND VI.COD_RESTAURANTE = CR.COD_RESTAURANTE
		
		LEFT JOIN [BI].[dbo].[CAD_DE_PARA_CHEFF] AS DEPARA
			ON 1=1
			AND VI.COD_PRODUTO_CHEFF = DEPARA.COD_PRODUTO_CHEFF
			AND VI.COD_RESTAURANTE = DEPARA.COD_RESTAURANTE
		LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON DEPARA.COD_PRODUTO = CP.COD_PRODUTO
		LEFT JOIN @TAB_AJUSTE_ESTOQUE_29 AS T
			ON 1=1
			AND DEPARA.COD_PRODUTO = T.COD_PRODUTO
			AND S.ANO_454 = T.ANO_454
			AND S.SEMANA_454 = T.SEMANA_454
		LEFT JOIN DW.dbo.PRODUTO_CUSTOS AS PC33
			ON 1=1
			AND PC33.COD_LOJA = 33
			AND DEPARA.COD_PRODUTO = PC33.COD_PRODUTO	
		LEFT JOIN DW.dbo.PRODUTO_CUSTOS AS PC29
			ON 1=1
			AND PC29.COD_LOJA = 29
			AND DEPARA.COD_PRODUTO = PC29.COD_PRODUTO
		LEFT JOIN @TAB_ULT_CUSTO_TAB AS UT
			ON 1=1
			AND DEPARA.COD_PRODUTO = UT.COD_PRODUTO
	WHERE 1=1
		AND CONVERT(DATE,VI.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		AND VI.COD_LOJA IN (33)
		AND VI.COD_RESTAURANTE not IN (105,107,112)
		--AND VI.COD_RESTAURANTE IN (SELECT DISTINCT COD_RESTAURANTE FROM BI.dbo.BI_CAD_RESTAURANTE WHERE TIPO_RESTAURANTE = 'FTS')	
		and 
		(
		CP.COD_DEPARTAMENTO IN (2,9) 
		OR
		(CP.COD_DEPARTAMENTO = 16 AND COD_SECAO = 58)
		)
	GROUP BY
		VI.COD_LOJA
		,CONVERT(DATE,VI.DATA)
		,VI.COD_RESTAURANTE
		,DEPARA.COD_PRODUTO
	/*
	-- -----------------------------------------------------------------------------
	-- AJUSTE NEGATIVO GARRAFAS
	-- -----------------------------------------------------------------------------
	UNION ALL
	SELECT		
		VI.COD_LOJA
		,CONVERT(DATE,VI.DATA) AS DATA
		,'Transferencia'
		,VI.COD_RESTAURANTE
		,281 AS COD_AJUSTE
		,'TRANSFERENCIA AUTOMATICA - Ajuste(-) Taca' As DES_AJUSTE
		,DP.COD_PRODUTO_GR
		,-1*SUM(VI.QUANTIDADE*ISNULL(VI.Quantidade_Dividida,1)) /4 AS QTD_AJUSTE
		,max(CASE
			WHEN ISNULL(T.VAL_CUSTO_MED,0) = 0 THEN 
				(CASE WHEN ISNULL(T.VAL_CUSTO_REP,0) = 0 THEN isnull(PC33.CUSTO_ENTRADA,(case when isnull(PC29.CUSTO_ENTRADA,0) = 0 then UT.VLR_EMB_COMPRA else PC29.CUSTO end) ) ELSE T.VAL_CUSTO_REP END)
			ELSE T.VAL_CUSTO_MED
			END)
		,max(CASE WHEN ISNULL(T.VAL_CUSTO_REP,0) = 0 THEN isnull(PC33.CUSTO_ENTRADA,PC29.CUSTO_ENTRADA) ELSE T.VAL_CUSTO_REP END)	
	FROM
		[DW].[dbo].[TAB_CHEFFSOLUTION_CUPOM_ITENS] AS VI
		INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
			ON VI.DATA = S.DATA
		LEFT JOIN BI.dbo.BI_CAD_RESTAURANTE AS CR
			ON 1=1
			AND VI.COD_LOJA = CR.COD_LOJA
			AND VI.COD_RESTAURANTE = CR.COD_RESTAURANTE
		
		LEFT JOIN [BI].[dbo].[CAD_DE_PARA_CHEFF] AS DEPARA
			ON 1=1
			AND VI.COD_PRODUTO_CHEFF = DEPARA.COD_PRODUTO_CHEFF
			AND VI.COD_RESTAURANTE = DEPARA.COD_RESTAURANTE
		LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON DEPARA.COD_PRODUTO = CP.COD_PRODUTO
		INNER JOIN BI.dbo.CADASTRO_DEPARA_VINHO AS DP
			ON 1=1
			AND DEPARA.COD_PRODUTO = DP.COD_PRODUTO_TC
		LEFT JOIN DW.dbo.PRODUTO_CUSTOS AS PC
			ON 1=1
			AND DP.COD_PRODUTO_GR = PC.COD_PRODUTO
			AND PC.COD_LOJA = 29
		-- ---------
		LEFT JOIN @TAB_AJUSTE_ESTOQUE_29 AS T
			ON 1=1
			AND DP.COD_PRODUTO_GR = T.COD_PRODUTO
			AND S.ANO_454 = T.ANO_454
			AND S.SEMANA_454 = T.SEMANA_454
		LEFT JOIN DW.dbo.PRODUTO_CUSTOS AS PC33
			ON 1=1
			AND PC33.COD_LOJA = 33
			AND DP.COD_PRODUTO_GR = PC33.COD_PRODUTO	
		LEFT JOIN DW.dbo.PRODUTO_CUSTOS AS PC29
			ON 1=1
			AND PC29.COD_LOJA = 29
			AND DP.COD_PRODUTO_GR = PC29.COD_PRODUTO
		LEFT JOIN @TAB_ULT_CUSTO_TAB AS UT
			ON 1=1
			AND DP.COD_PRODUTO_GR = UT.COD_PRODUTO
	WHERE 1=1
		AND CONVERT(DATE,VI.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		AND VI.COD_LOJA IN (33)
		AND VI.COD_RESTAURANTE not IN (105,107,112)
		--and depara.COD_PRODUTO = @cod_produto
	GROUP BY
		VI.COD_LOJA
		,CONVERT(DATE,VI.DATA)
		,VI.COD_RESTAURANTE
		,DP.COD_PRODUTO_GR
	*/
) as tab_transf
GROUP BY
	COD_LOJA
	,DATA
	,COD_RESTAURANTE
	,COD_PRODUTO


	-- -----------------------------------------------------------------------------
	-- TACAS COM CUSTO 1/4 DA GARRAFA
	-- -----------------------------------------------------------------------------
	UNION ALL
	SELECT		
		VI.COD_LOJA
		,CONVERT(DATE,VI.DATA) AS DATA
		,'Transferencia'
		,VI.COD_RESTAURANTE
		,281 AS COD_AJUSTE
		,'TRANSFERENCIA AUTOMATICA - 1/4 GARRAFA' As DES_AJUSTE
		,DEPARA.COD_PRODUTO
		,SUM(VI.QUANTIDADE*ISNULL(VI.Quantidade_Dividida,1)) AS QTD_AJUSTE
		,max(PC.CUSTO_ENTRADA/4)
		,max(PC.CUSTO_ENTRADA/4)
	FROM
		[DW].[dbo].[TAB_CHEFFSOLUTION_CUPOM_ITENS] AS VI
		INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
			ON VI.DATA = S.DATA
		LEFT JOIN BI.dbo.BI_CAD_RESTAURANTE AS CR
			ON 1=1
			AND VI.COD_LOJA = CR.COD_LOJA
			AND VI.COD_RESTAURANTE = CR.COD_RESTAURANTE
		
		LEFT JOIN [BI].[dbo].[CAD_DE_PARA_CHEFF] AS DEPARA
			ON 1=1
			AND VI.COD_PRODUTO_CHEFF = DEPARA.COD_PRODUTO_CHEFF
			AND VI.COD_RESTAURANTE = DEPARA.COD_RESTAURANTE
		LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON DEPARA.COD_PRODUTO = CP.COD_PRODUTO
		INNER JOIN BI.dbo.CADASTRO_DEPARA_VINHO AS DP
			ON 1=1
			AND DEPARA.COD_PRODUTO = DP.COD_PRODUTO_TC
		LEFT JOIN DW.dbo.PRODUTO_CUSTOS AS PC
			ON 1=1
			AND DP.COD_PRODUTO_GR = PC.COD_PRODUTO
			AND PC.COD_LOJA = 29
	
	WHERE 1=1
		AND CONVERT(DATE,VI.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		AND VI.COD_LOJA IN (33)
		AND VI.COD_RESTAURANTE not IN (105,107,112)
		--and depara.COD_PRODUTO = @cod_produto
	GROUP BY
		VI.COD_LOJA
		,CONVERT(DATE,VI.DATA)
		,VI.COD_RESTAURANTE
		,DEPARA.COD_PRODUTO


	UNION ALL
	
	SELECT 
		INV.COD_LOJA
		,CONVERT(DATE,DTA_INVENTARIO) AS DATA
		,'Inventory'
		,97
		,1
		,'Inventory'
		,1
		,1
		,(case when SUM((INVI.QTD_INVENTARIO-CONG.QTD_ESTOQUE_CONGELADO) * (INVI.VAL_CUSTO_REP)) > 0
			then SUM((INVI.QTD_INVENTARIO-CONG.QTD_ESTOQUE_CONGELADO) * (INVI.VAL_CUSTO_REP))
			else SUM((INVI.QTD_INVENTARIO-CONG.QTD_ESTOQUE_CONGELADO) * (INVI.VAL_CUSTO_REP))*-1
		end) AS VAL_DIF
		,(case when SUM((INVI.QTD_INVENTARIO-CONG.QTD_ESTOQUE_CONGELADO) * (INVI.VAL_CUSTO_REP)) > 0
			then SUM((INVI.QTD_INVENTARIO-CONG.QTD_ESTOQUE_CONGELADO) * (INVI.VAL_CUSTO_REP))
			else SUM((INVI.QTD_INVENTARIO-CONG.QTD_ESTOQUE_CONGELADO) * (INVI.VAL_CUSTO_REP))*-1
		end) AS VAL_DIF
	FROM 
		[192.168.0.6].zeus_rtg.dbo.TAB_INVENTARIO  INV 
		INNER JOIN [192.168.0.6].zeus_rtg.dbo.TAB_INVENTARIO_ITEM INVI 
			ON INVI.COD_INVENTARIO = INV.COD_INVENTARIO
		INNER JOIN [192.168.0.6].zeus_rtg.dbo.TAB_PRODUTO_CONGELADO CONG 
			ON 1=1
			AND CONG.COD_PRODUTO = INVI.COD_PRODUTO
			AND CONG.COD_INVENTARIO = INVI.COD_INVENTARIO
	WHERE 1=1
		AND INV.COD_LOJA = 33
		AND CONVERT (DATE,DTA_INVENTARIO) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
	GROUP BY
		INV.COD_LOJA
		,CONVERT(DATE,DTA_INVENTARIO)
		
	UNION ALL
	
	SELECT
		T.COD_LOJA		
		,CONVERT(DATE,T.DTA_AJUSTE) AS DATA
		,'Eliminations'		
		,98 AS COD_RESTAURANTE
		,2
		,'Eliminations'	
		,1
		,1
		,SUM((T.QTD_AJUSTE)*T.VAL_CUSTO_REP)*-1 AS VAL_CUSTO_MED
		,SUM((T.QTD_AJUSTE)*T.VAL_CUSTO_REP)*-1 AS VAL_CUSTO_REP				
	FROM
		[192.168.0.6].ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS T
		INNER JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_TIPO_AJUSTE AS TA
			ON 1=1
			AND T.COD_AJUSTE = TA.COD_AJUSTE	
	WHERE 1=1
		AND T.COD_LOJA = 33
		AND T.COD_AJUSTE IN (494)
		AND CONVERT(DATE,T.DTA_AJUSTE) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
	GROUP BY
		T.COD_LOJA		
		,CONVERT(DATE,T.DTA_AJUSTE)

	UNION ALL
	
	--CUSTO VENCHI
	SELECT		
		VI.COD_LOJA
		,CONVERT(DATE,VI.DATA) AS DATA
		,'Transferencia'
		,VI.COD_RESTAURANTE
		,3 AS COD_AJUSTE
		,'CUSTO VENCHI' As DES_AJUSTE
		,1
		,1
		,(sum(VI.VALOR_TOTAL)-(SUM(VI.VALOR_TOTAL)-sum(ValorTotalSemImposto)))*0.75  as VLR_TOTAL_PRODUTO	
		,(sum(VI.VALOR_TOTAL)-(SUM(VI.VALOR_TOTAL)-sum(ValorTotalSemImposto)))*0.75 as VLR_TOTAL_PRODUTO	
	FROM
		[DW].[dbo].[TAB_CHEFFSOLUTION_CUPOM_ITENS] AS VI
		LEFT JOIN BI.dbo.BI_CAD_RESTAURANTE AS CR
			ON 1=1
			AND VI.COD_LOJA = CR.COD_LOJA
			AND VI.COD_RESTAURANTE = CR.COD_RESTAURANTE
		
		LEFT JOIN [BI].[dbo].[CAD_DE_PARA_CHEFF] AS DEPARA
			ON 1=1
			AND VI.COD_PRODUTO_CHEFF = DEPARA.COD_PRODUTO_CHEFF
			AND VI.COD_RESTAURANTE = DEPARA.COD_RESTAURANTE
		LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON DEPARA.COD_PRODUTO = CP.COD_PRODUTO
	WHERE 1=1
		AND CONVERT(DATE,VI.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		AND VI.COD_LOJA IN (33)
		AND VI.COD_RESTAURANTE IN (105,107,112)	--venchi
	GROUP BY
		VI.COD_LOJA
		,CONVERT(DATE,VI.DATA)
		,VI.COD_RESTAURANTE
	
	UNION ALL
	
	--CUSTO ROSSOPOMODORO
	SELECT		
		VI.COD_LOJA
		,CONVERT(DATE,VI.DATA) AS DATA
		,'Transferencia'
		,96 AS COD_RESTAURANTE
		,4 AS COD_AJUSTE
		,'CUSTO ROSSOPOMODORO' As DES_AJUSTE
		,1
		,1
		--,sum(isnull(VI.ValorTotalSemImposto,VI.VALOR_TOTAL*0.968))*0.213*0.7 as VLR_TOTAL_PRODUTO
		,(sum(isnull(VI.ValorTotalSemImposto,VI.VALOR_TOTAL*0.968))*0.7)-(sum(isnull(VI.ValorTotalSemImposto,VI.VALOR_TOTAL*0.968))*0.7*0.0365) as VLR_TOTAL_PRODUTO	
		,(sum(isnull(VI.ValorTotalSemImposto,VI.VALOR_TOTAL*0.968))*0.7)-(sum(isnull(VI.ValorTotalSemImposto,VI.VALOR_TOTAL*0.968))*0.7*0.0365) as VLR_TOTAL_PRODUTO	
	FROM
		[DW].[dbo].[TAB_CHEFFSOLUTION_CUPOM_ITENS] AS VI
		LEFT JOIN BI.dbo.BI_CAD_RESTAURANTE AS CR
			ON 1=1
			AND VI.COD_LOJA = CR.COD_LOJA
			AND VI.COD_RESTAURANTE = CR.COD_RESTAURANTE
		
		LEFT JOIN [BI].[dbo].[CAD_DE_PARA_CHEFF] AS DEPARA
			ON 1=1
			AND VI.COD_PRODUTO_CHEFF = DEPARA.COD_PRODUTO_CHEFF
			AND VI.COD_RESTAURANTE = DEPARA.COD_RESTAURANTE
		LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON DEPARA.COD_PRODUTO = CP.COD_PRODUTO
	WHERE 1=1
		AND CONVERT(DATE,VI.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		AND VI.COD_LOJA IN (33)
		AND VI.COD_RESTAURANTE IN (111)	--ROSSO
		AND DEPARA.COD_PRODUTO IN (SELECT TPM.COD_PRODUTO FROM CADASTRO_CAD_PRODUTO_METADADOS TPM WHERE TPM.COD_METADADO = 48 AND TPM.VLR_METADADO = 1)
	GROUP BY
		VI.COD_LOJA
		,CONVERT(DATE,VI.DATA)
		
		
		
	

END
