-- -----------------------------------------------------------------------------------------------------------------------
-- FULL
-- -----------------------------------------------------------------------------------------------------------------------
SELECT
*
FROM 
	[DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO] AS P
WHERE 1 = 1
	AND CONVERT(DATE,P.DATA_CRIACAO) >= CONVERT(DATE,GETDATE()-180)
	AND P.IDPEDIDO <> 9999999
	AND P.IDSTATUS_PED <> 2
	and P.IDPEDIDO = 2655

SELECT
	PITEM.*
FROM 
	[DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO] AS P
	INNER JOIN [DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO_ITEM] AS PITEM
		ON 1=1
		AND P.IDPEDIDO = PITEM.IDPEDIDO
WHERE 1 = 1
	AND CONVERT(DATE,P.DATA_CRIACAO) >= CONVERT(DATE,GETDATE()-180)
	AND P.IDPEDIDO <> 9999999
	AND P.IDSTATUS_PED <> 2
	and P.IDPEDIDO = 2655

-- -----------------------------------------------------------------------------------------------------------------------
-- SOMA 1
-- -----------------------------------------------------------------------------------------------------------------------
SELECT
	SUM(P.TOTAL)
FROM 
	[DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO] AS P
WHERE 1 = 1
	AND CONVERT(DATE,P.DATA_CRIACAO) >= CONVERT(DATE,GETDATE()-180)
	AND P.IDPEDIDO <> 9999999
	AND P.IDSTATUS_PED <> 2
	and P.IDPEDIDO = 2655

SELECT
	SUM((CASE WHEN PITEM.PRECO_CESTA_SEM_DESC = 0.01 THEN 0 ELSE PITEM.PRECO_CESTA_SEM_DESC END) * PITEM.QUANTIDADE) + (SUM(P.VALOR_FRETE)/COUNT(PITEM.IDPRODUTO)) - (SUM(P.VALOR_DESCONTO)/COUNT(PITEM.IDPRODUTO))
FROM 
	[DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO] AS P
	INNER JOIN [DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO_ITEM] AS PITEM
		ON 1=1
		AND P.IDPEDIDO = PITEM.IDPEDIDO
WHERE 1 = 1
	AND CONVERT(DATE,P.DATA_CRIACAO) >= CONVERT(DATE,GETDATE()-180)
	AND P.IDPEDIDO <> 9999999
	AND P.IDSTATUS_PED <> 2
	and P.IDPEDIDO = 2655

-- -----------------------------------------------------------------------------------------------------------------------
-- SOMA FULL
-- -----------------------------------------------------------------------------------------------------------------------
SELECT
	SUM(P.TOTAL)--/COUNT(PITEM.IDPRODUTO)
FROM 
	[DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO] AS P
	--INNER JOIN [DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO_ITEM] AS PITEM
	--	ON 1=1
	--	AND P.IDPEDIDO = PITEM.IDPEDIDO
WHERE 1 = 1
	AND CONVERT(DATE,P.DATA_CRIACAO) >= CONVERT(DATE,GETDATE()-180)
	AND P.IDPEDIDO <> 9999999
	AND P.IDSTATUS_PED <> 2


--1925190.03

SELECT
	SUM(PITEM.PRECO_CESTA_SEM_DESC * PITEM.QUANTIDADE) + (SUM(P.VALOR_FRETE)/COUNT(PITEM.IDPRODUTO)) - (SUM(P.VALOR_DESCONTO)/COUNT(PITEM.IDPRODUTO))
	,SUM(P.TOTAL)
FROM 
	[DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO] AS P
	INNER JOIN [DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO_ITEM] AS PITEM
		ON 1=1
		AND P.IDPEDIDO = PITEM.IDPEDIDO
WHERE 1 = 1
	AND CONVERT(DATE,P.DATA_CRIACAO) >= CONVERT(DATE,GETDATE()-180)
	AND P.IDPEDIDO <> 9999999
	AND P.IDSTATUS_PED <> 2

-- -----------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------	
	
--SELECT
--	SUM(P.TOTAL)
--FROM 
--	[DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO] AS P
--WHERE 1 = 1
--	AND CONVERT(DATE,P.DATA_CRIACAO) >= CONVERT(DATE,GETDATE()-180)
--	AND P.IDPEDIDO <> 9999999
--	AND P.IDSTATUS_PED <> 2

--SELECT
--*
--FROM
--	DBCestanatal.dbo.VW_QLIK_PEDIDO AS P
--WHERE 1=1

--SELECT
--	*
--FROM
--	[DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO] AS P
--	INNER JOIN [DBCESTANATAL].[DBO].[VW_QLIK_PEDIDO_ITEM] AS PITEM
--		ON 1=1
--		AND P.IDPEDIDO = PITEM.IDPEDIDO
--WHERE 1 = 1
--	AND P.IDPEDIDO <> 9999999

