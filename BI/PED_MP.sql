-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_PED_BI AS TABLE
(
	COD_FORNECEDOR INT
	,COD_LOJA INT
	,COD_PRODUTO INT
	,QTD_PEDIDO_BI NUMERIC(8,3)
	,QTD_ESTOQUE NUMERIC(8,3)
)

INSERT INTO @TAB_PED_BI
SELECT
	COD_FORNECEDOR
	,COD_LOJA
	,COD_PRODUTO
	,QTD_EMBALAGEM AS QTD_PEDIDO_BI
	,QTD_ESTOQUE
FROM [BI].[dbo].[COMPRAS_PEDIDOS] as P
where 1 = 1
and COD_FORNECEDOR = 16384
and CONVERT(date, P.data) >=  CONVERT(date, '20131201')
--AND COD_PEDIDO = 299956


DECLARE @TAB_PED_ZEUS AS TABLE
(
	COD_FORNECEDOR INT
	,COD_LOJA INT
	,COD_PRODUTO INT
	,QTD_PEDIDO_ZEUS NUMERIC(8,3)
)

INSERT INTO @TAB_PED_ZEUS
SELECT
	COD_PARCEIRO
	,COD_LOJA
	,COD_PRODUTO
	,QTD_PEDIDO AS QTD_PEDIDO_ZEUS
FROM [192.168.0.6].[ZEUS_RTG].[DBO].[TAB_PEDIDO_PRODUTO]
WHERE 1 = 1
	AND COD_PARCEIRO = 16384
	--AND NUM_PEDIDO = @COD_PEDIDO 


SELECT
	PB.COD_FORNECEDOR
	,PB.COD_LOJA
	,PB.COD_PRODUTO
	,PB.QTD_PEDIDO_BI
	,PZ.QTD_PEDIDO_ZEUS
	,PB.QTD_ESTOQUE
FROM 
	@TAB_PED_BI AS PB INNER JOIN @TAB_PED_ZEUS AS PZ ON (PB.COD_FORNECEDOR = PZ.COD_FORNECEDOR AND PB.COD_LOJA = PZ.COD_LOJA AND PB.COD_PRODUTO = PZ.COD_PRODUTO)

--##############--##############--##############--##############--##############--##############--##############--##############--##############--##############--##############--##############--##############


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT
SUM(QTD_PRODUTO)
FROM [BI].[dbo].[COMPRAS_PEDIDOS] as P INNER JOIN [BI].[dbo].[COMPRAS_PEDIDOS_LOJA] AS PJ ON (P.COD_LOJA = PJ.COD_LOJA AND P.COD_PRODUTO = PJ.COD_PRODUTO AND CONVERT(DATE,P.[DATA]) = CONVERT(DATE,PJ.[DATA]))
where 1 = 1
and COD_FORNECEDOR = 16384
and CONVERT(date, P.data) >=  CONVERT(date, '20131201')
AND COD_PEDIDO = 299956



SELECT SUM(QTD_PEDIDO) FROM [192.168.0.6].[ZEUS_RTG].[DBO].[TAB_PEDIDO_PRODUTO] WHERE NUM_PEDIDO = 299956 AND COD_PARCEIRO = 16384




-- -----------------------------------------------------------------------------------
SELECT 
convert(varchar(10),[DATA],103) AS DATA
,[COD_LOJA]
,l.[COD_PRODUTO]
,DESCRICAO
,dbo.fn_FormataVlr_Excel([QTD_PRODUTO])as QTD_PRODUTO
,[CRACHA]

FROM [BI].[dbo].[COMPRAS_PEDIDOS_LOJA] as l
inner join [BI].dbo.BI_CAD_PRODUTO as c
on l.COD_PRODUTO=c.COD_PRODUTO

WHERE 1=1 
AND COD_GRUPO_PEDIDO=8
AND DATA =CONVERT (date, GETDATE()) 
order by COD_LOJA