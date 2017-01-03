DECLARE @DTA_INI AS DATE = GETDATE()-30;
DECLARE @DTA_FIM AS DATE = GETDATE()-1;
DECLARE @DTA_ESTOQUE AS DATE = GETDATE()-1;
DECLARE @COD_PRODUTO AS INT = NULL;
DECLARE @COD_SECAO AS INT = 21;
DECLARE @COD_GRUPO AS INT = NULL;

-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- PROD
-- ------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_PROD AS TABLE
(
	COD_SECAO INT
	,COD_GRUPO INT
	,COD_PRODUTO INT
	,DESCRICAO VARCHAR(50)
);

INSERT INTO @TAB_PROD
SELECT
	CP.COD_SECAO
	,CP.COD_GRUPO
	,CP.COD_PRODUTO
	,CP.DESCRICAO
FROM
	BI.DBO.BI_CAD_PRODUTO AS CP 
WHERE 1 = 1
	AND CP.COD_PRODUTO = (CASE WHEN @COD_PRODUTO IS NULL THEN CP.COD_PRODUTO ELSE @COD_PRODUTO END)
	AND CP.COD_SECAO = (CASE WHEN @COD_SECAO IS NULL THEN CP.COD_SECAO ELSE @COD_SECAO END)
	AND CP.COD_GRUPO = (CASE WHEN @COD_GRUPO IS NULL THEN CP.COD_GRUPO ELSE @COD_GRUPO END);
	
	
-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- FORN_ULT_COMPRA
-- ------------------------------------------------------------------------------------------------------------------------------------------------	
DECLARE @TAB_FORN AS TABLE
(
	COD_LOJA INT
	,COD_PRODUTO INT
	,COD_FORNECEDOR INT
);

INSERT INTO @TAB_FORN
SELECT
	COD_LOJA
	,COD_PRODUTO
	,COD_FORN_ULT_COMPRA
FROM
	[192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_LOJA
WHERE 1=1
	AND COD_FORN_ULT_COMPRA IS NOT NULL;

-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- VENDA
-- ------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_VENDA AS TABLE
(
	COD_LOJA INT
	,COD_PRODUTO INT
	,QTD_VENDA NUMERIC(12,3)
);

INSERT INTO @TAB_VENDA
SELECT
	COD_LOJA
	,VP.COD_PRODUTO
	,SUM(QTDE_PRODUTO)
FROM
	BI.DBO.BI_VENDA_PRODUTO AS VP INNER JOIN @TAB_PROD AS CP ON (VP.COD_PRODUTO = CP.COD_PRODUTO)
WHERE 1 = 1
	AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DTA_INI) AND CONVERT(DATE,@DTA_FIM)
GROUP BY
	COD_LOJA
	,VP.COD_PRODUTO;


-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- ESTOQUE
-- ------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_ESTOQUE AS TABLE
(
	COD_LOJA INT
	,COD_PRODUTO INT
	,QTD_ESTOQUE NUMERIC(12,3)
);

INSERT INTO @TAB_ESTOQUE
SELECT
	COD_LOJA
	,MOV.COD_PRODUTO
	,QTD_ESTOQUE
FROM
	bi.dbo.BI_TESTE_MOVIMENTO_PRODUTOS AS MOV INNER JOIN @TAB_PROD AS CP ON (MOV.COD_PRODUTO = CP.COD_PRODUTO)
WHERE 1 = 1
	AND CONVERT(DATE,DTA_MOVIMENTO) = CONVERT(DATE,@DTA_ESTOQUE);


--DELETE @TAB_ESTOQUE
--FROM
--	@TAB_ESTOQUE AS EST LEFT JOIN @TAB_PROD AS PROD ON (EST.COD_PRODUTO = PROD.COD_PRODUTO)
--WHERE 1 = 1
--	AND PROD.COD_PRODUTO IS NULL;


-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- SELECT
-- ------------------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT
	CP.COD_SECAO
	,CP.COD_GRUPO
	,CP.COD_PRODUTO
	,CF.DESCRICAO
	,VEN.QTD_VENDA
	,EST.QTD_ESTOQUE
	,PF.VAL_CUSTO_EMBALAGEM
	,PF.DES_UNIDADE_COMPRA
	,PF.QTD_EMBALAGEM_COMPRA
FROM
	@TAB_PROD AS CP LEFT JOIN @TAB_FORN AS FORN ON (CP.COD_PRODUTO = FORN.COD_PRODUTO)
		LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF ON (FORN.COD_FORNECEDOR = CF.COD_FORNECEDOR)
		LEFT JOIN AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR AS PF ON (CP.COD_PRODUTO = PF.COD_PRODUTO AND FORN.COD_FORNECEDOR = PF.COD_FORNECEDOR)
		LEFT JOIN @TAB_ESTOQUE AS EST ON (CP.COD_PRODUTO = EST.COD_PRODUTO)
		LEFT JOIN @TAB_VENDA AS VEN ON (CP.COD_PRODUTO = VEN.COD_PRODUTO)
WHERE 1 = 1
ORDER BY
	CP.COD_SECAO
	,CP.COD_PRODUTO;


--SELECT TOP 100 * FROM AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR



