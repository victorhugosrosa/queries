SET NOCOUNT ON;
DECLARE @DT_INI DATE = CONVERT(DATE,'20140701')
DECLARE @DT_FIM DATE = CONVERT(DATE,'20140731')
DECLARE @COD_LOJA INT = 1

-- --------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------
DECLARE @TAB_VENDA AS TABLE
(
	COD_LOJA INT
	,DATA DATE
	,COD_PRODUTO INT
	,VLR_VENDA NUMERIC(18,2)
	,QTD_VENDA NUMERIC(18,2)
)
INSERT INTO @TAB_VENDA
	SELECT
		V.COD_LOJA
		,V.DATA
		,DP.COD_PRODUTO_ORG
		,SUM(V.[VALOR_TOTAL])
		,SUM(V.QTDE_PRODUTO)
	FROM
		[BI].[DBO].[BI_VENDA_PRODUTO] AS V
		INNER JOIN [BI].DBO.COMPRAS_DEPARA_PRODUTO AS DP
			ON 1 = 1
			AND V.COD_PRODUTO = DP.COD_PRODUTO_DST
	WHERE 1=1
		--AND V.COD_LOJA = @COD_LOJA
		AND V.COD_LOJA IN (1,2,3,6,7,9,12,13,17,18,20,21,22,23,24,25)
		AND DP.FLG_PRODUCAO = 1
		AND (DP.OBS <> 'ITEM FEIJOADA' OR DP.OBS IS NULL)
		AND DP.NO_PLANOGRAMA IS NOT NULL
		AND CONVERT(DATE,DATA) BETWEEN @DT_INI AND @DT_FIM
	GROUP BY
		V.COD_LOJA
		,V.DATA
		,DP.COD_PRODUTO_ORG

-- --------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------
DECLARE @TAB_AJUSTE AS TABLE
(
	COD_LOJA INT
	,DATA DATE
	,COD_PRODUTO INT
	,QTD_QUEBRA NUMERIC(18,2)
	,VLR_REP NUMERIC(18,2)
	,VLR_QUEBRA NUMERIC(18,2)
)
INSERT INTO @TAB_AJUSTE
	SELECT  
		E.COD_LOJA
		,DTA_AJUSTE AS DATA
		,DP.COD_PRODUTO_ORG
		,ROUND(SUM(-1*[QTD_AJUSTE]),2) AS QTD
		,ROUND(AVG([VAL_CUSTO_REP]),2) AS [VLR REP]
		,SUM(-1*[QTD_AJUSTE]*[VAL_CUSTO_REP]) AS [VLR QUEBRA]
	FROM
		[192.168.0.6].ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS E
		INNER JOIN BI.DBO.BI_CAD_PRODUTO AS P
			ON P.COD_PRODUTO = E.COD_PRODUTO
		INNER JOIN [BI].DBO.COMPRAS_DEPARA_PRODUTO AS DP
			ON 1 = 1
			AND E.COD_PRODUTO = DP.COD_PRODUTO_DST
	WHERE 1=1
		--AND E.COD_LOJA = @COD_LOJA
		AND E.COD_LOJA IN (1,2,3,6,7,9,12,13,17,18,20,21,22,23,24,25)
		AND CONVERT(DATE,[DTA_AJUSTE]) BETWEEN @DT_INI AND @DT_FIM
		AND COD_AJUSTE IN (51,3,108,120,121,122,123,124)
		AND DP.FLG_PRODUCAO = 1
		AND (DP.OBS <> 'ITEM FEIJOADA' OR DP.OBS IS NULL)
		AND DP.NO_PLANOGRAMA IS NOT NULL
	GROUP BY
		E.COD_LOJA
		,DTA_AJUSTE
		,DP.COD_PRODUTO_ORG

-- --------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------
SELECT
	TAB.*
	,CP.DESCRICAO
FROM
	BI.dbo.BI_CAD_PRODUTO AS CP
	INNER JOIN
(
	SELECT
		(CASE WHEN V.COD_LOJA IS NULL THEN Q.COD_LOJA ELSE V.COD_LOJA END) AS COD_LOJA
		,(CASE WHEN V.DATA IS NULL THEN Q.DATA ELSE V.DATA END) AS DATA
		,(CASE WHEN V.COD_PRODUTO IS NULL THEN Q.COD_PRODUTO ELSE V.COD_PRODUTO END) AS COD_PRODUTO
		,bi.dbo.fn_FormataVlr_Excel(ISNULL(Q.QTD_QUEBRA,0)) AS QTD
		,bi.dbo.fn_FormataVlr_Excel(ISNULL(Q.QTD_QUEBRA/NULLIF(V.[QTD_VENDA],0),0)) AS [QKG%]
		,bi.dbo.fn_FormataVlr_Excel(ISNULL(V.[QTD_VENDA],0)) AS [QTD VENDA]
		--V.DATA
		--,V.COD_PRODUTO
		--,ISNULL(Q.QTD_QUEBRA,0) AS QTD
		--,ISNULL(Q.QTD_QUEBRA/NULLIF(V.[QTD_VENDA],0),0) AS [QKG%]
		--,ISNULL(V.[QTD_VENDA],0) AS [QTD VENDA]
	FROM
		@TAB_VENDA AS V
		FULL JOIN @TAB_AJUSTE AS Q
			ON 1 = 1
			AND V.DATA = Q.DATA
			AND V.COD_PRODUTO = Q.COD_PRODUTO
			AND V.COD_LOJA = Q.COD_LOJA
) AS TAB	
		ON TAB.COD_PRODUTO = CP.COD_PRODUTO


/*


SELECT V.DATA
	  ,ISNULL(Q.QTD,0) AS QTD
	  --,Q.[VLR REP]
	  --,Q.[VLR QUEBRA]
	  --,ISNULL(V.[VLR VENDA],0) AS [VLR VENDA]
	  --,ISNULL(Q.[VLR QUEBRA]/NULLIF(V.[VLR VENDA],0),0) AS [Q%]
	  ,ISNULL(Q.[QTD]/NULLIF(V.[QTD VENDA],0),0) AS [QKG%]
	  ,ISNULL(V.[QTD VENDA],0) AS [QTD VENDA]
	  
FROM 
(
SELECT   DTA_AJUSTE AS DATA
		,ROUND(SUM(-1*[QTD_AJUSTE]),2) AS QTD
		,ROUND(AVG([VAL_CUSTO_REP]),2) AS [VLR REP]
		,SUM(-1*[QTD_AJUSTE]*[VAL_CUSTO_REP]) AS [VLR QUEBRA]
		
		
	FROM [192.168.0.6].ZEUS_RTG.DBO.TAB_AJUSTE_ESTOQUE AS E
		 INNER JOIN BI.DBO.BI_CAD_PRODUTO AS P
		 ON P.COD_PRODUTO = E.COD_PRODUTO
			 INNER JOIN
		 [BI].DBO.COMPRAS_DEPARA_PRODUTO AS DP
			ON E.COD_PRODUTO = DP.COD_PRODUTO_DST
			AND E.COD_LOJA = @CODLOJA

	WHERE 1=1
	AND CONVERT(DATE,[DTA_AJUSTE]) BETWEEN @DTINI AND @DTFIM
	--AND COD_AJUSTE IN (3,108,120,121,122,123,124) --TRANSFERENCIAS DE QUEBRA (SEM RENDIMENTO)
	AND COD_AJUSTE IN (3,108,120,121,122,123,124)
	AND COD_LOJA = @CODLOJA
GROUP BY  DTA_AJUSTE
) AS Q

FULL JOIN 

(
	SELECT V.DATA
		  ,SUM(V.[VALOR_TOTAL]) AS [VLR VENDA]
		  ,SUM(V.QTDE_PRODUTO) AS [QTD VENDA]
	  FROM [BI].[DBO].[BI_VENDA_PRODUTO] AS V
		   INNER JOIN
		   [BI].DBO.COMPRAS_DEPARA_PRODUTO AS DP
		       ON V.COD_PRODUTO = DP.COD_PRODUTO_DST
		       AND V.COD_LOJA = @CODLOJA
	  WHERE 1=1
	AND DP.FLG_PRODUCAO = 1
	AND (DP.OBS <> 'ITEM FEIJOADA' OR DP.OBS IS NULL)
	AND DP.NO_PLANOGRAMA IS NOT NULL

	AND CONVERT(DATE,DATA) BETWEEN @DTINI AND @DTFIM
	  GROUP BY DATA
) AS V
ON V.DATA = Q.DATA

*/

--SELECT * FROM [BI].DBO.COMPRAS_DEPARA_PRODUTO WHERE COD_PRODUTO_DST = 32667