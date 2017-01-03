DECLARE @TEMP_ANALISE_FORN AS TABLE
(
	[COD_LOJA] [INT],
	[COD_FORNECEDOR] [INT],
	[COD_PRODUTO] [INT],
	[QTD_PEDIDA] [INT],
	[QTD_RECEBIDA] [INT]
);

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PRODUTO FORNECEDOR
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO @TEMP_ANALISE_FORN
SELECT DISTINCT
	F.COD_LOJA
	,F.COD_FORNECEDOR
	,F.COD_PRODUTO
	,NULL
	,NULL
FROM
	ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS F INNER JOIN [192.168.0.13].[BI].[dbo].[VW_BI_SUPERBASE] AS P ON (F.COD_LOJA=P.COD_LOJA AND F.COD_PRODUTO = P.CODIGO)
WHERE 1 = 1
	AND [PROIBIDO_COMPRA] = 'N'
	AND [FORA_MIX] = 'N'
	AND [FORA_LINHA] = 'N'
	AND COD_SECAO IN (24,26,23,50,31,7,22,21,42,29,33,30,27)
	AND TIPO_PRODUTO <> 'SAZONAL'
	AND IPV = 'N';

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PEDIDOS
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TEMP_TAB_PEDIDO AS TABLE
(
	[COD_LOJA] [INT],
	[COD_FORNECEDOR] [INT],
	[COD_PRODUTO] [INT],
	[QTD_PEDIDA] [INT]
);

INSERT INTO @TEMP_TAB_PEDIDO 
SELECT --TOP 100
	PED_PROD.COD_LOJA
	,PED_PROD.COD_PARCEIRO
	,PED_PROD.COD_PRODUTO
	,SUM(PED_PROD.QTD_EMBALAGEM*PED_PROD.QTD_PEDIDO) AS QTD_PEDIDO
FROM
	ZEUS_RTG.DBO.VW_MARCHE_PEDIDOS_PROD AS PED_PROD INNER JOIN ZEUS_RTG.DBO.VW_MARCHE_PEDIDOS AS PED ON (PED.COD_LOJA = PED_PROD.COD_LOJA AND PED.NUM_PEDIDO = PED_PROD.NUM_PEDIDO AND PED.COD_PARCEIRO = PED_PROD.COD_PARCEIRO)
WHERE 1 = 1
	AND CONVERT(DATE,PED_PROD.DTA_EMISSAO) >= CONVERT(DATE,'20130901')
GROUP BY
	PED_PROD.COD_LOJA
	,PED_PROD.COD_PARCEIRO
	,PED_PROD.COD_PRODUTO;

UPDATE TAB_FULL
SET
	TAB_FULL.[QTD_PEDIDA] = TAB_PED.[QTD_PEDIDA]
FROM
	@TEMP_ANALISE_FORN AS TAB_FULL INNER JOIN @TEMP_TAB_PEDIDO AS TAB_PED ON (TAB_FULL.COD_LOJA = TAB_PED.COD_LOJA AND TAB_FULL.COD_FORNECEDOR = TAB_PED.COD_FORNECEDOR AND TAB_FULL.COD_PRODUTO = TAB_PED.COD_PRODUTO);

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RECEBIMENTO
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TEMP_TAB_RECEBIMENTO AS TABLE
(
	[COD_LOJA] [INT],
	[COD_FORNECEDOR] [INT],
	[COD_PRODUTO] [INT],
	[QTD_RECEBIDA] [INT]
);

INSERT INTO @TEMP_TAB_RECEBIMENTO
SELECT --TOP 100
	COD_LOJA
	,COD_FORNECEDOR
	,COD_PRODUTO
	,SUM(QTD_EMBALAGEM*QTD_ENTRADA)
FROM
	ZEUS_RTG.DBO.VW_MARCHE_ENTRADAS
WHERE 1 = 1
	AND CONVERT(DATE,DTA_EMISSAO) >= CONVERT(DATE,'20130901')
GROUP BY
	COD_LOJA
	,COD_FORNECEDOR
	,COD_PRODUTO;

UPDATE TAB_FULL
SET
	TAB_FULL.[QTD_RECEBIDA] = TAB_REC.[QTD_RECEBIDA]
FROM
	@TEMP_ANALISE_FORN AS TAB_FULL INNER JOIN @TEMP_TAB_RECEBIMENTO AS TAB_REC ON (TAB_FULL.COD_LOJA = TAB_REC.COD_LOJA AND TAB_FULL.COD_FORNECEDOR = TAB_REC.COD_FORNECEDOR AND TAB_FULL.COD_PRODUTO = TAB_REC.COD_PRODUTO);


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RECEBIMENTO
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM @TEMP_ANALISE_FORN

-- ========================================================================================================================================================================================
-- ========================================================================================================================================================================================
-- ========================================================================================================================================================================================
-- ========================================================================================================================================================================================
-- ========================================================================================================================================================================================
-- ========================================================================================================================================================================================
-- ========================================================================================================================================================================================
-- ========================================================================================================================================================================================
/*	
SELECT TOP 10 * FROM ZEUS_RTG.DBO.VW_MARCHE_PEDIDOS
SELECT TOP 10 * FROM ZEUS_RTG.DBO.VW_MARCHE_PEDIDOS_PROD
SELECT TOP 10 * FROM ZEUS_RTG.DBO.VW_MARCHE_ENTRADAS
*/

/*
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LINHA PRODUTO
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT --TOP 10
	[COD_LOJA]
	,[CODIGO]	
FROM
	[192.168.0.13].[BI].[dbo].[VW_BI_SUPERBASE]
where 1=1
	AND [PROIBIDO_COMPRA] = 'N'
	AND [FORA_MIX] = 'N'
	AND [FORA_LINHA] = 'N'
	AND COD_SECAO IN (24,26,23,50,31,7,22,21,42,29,33,30,27)
	AND TIPO_PRODUTO <> 'SAZONAL'
	AND IPV = 'N'
*/
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	


select top 5 * from ZEUS_RTG.DBO.VW_MARCHE_PEDIDOS 
select top 5 * from ZEUS_RTG.DBO.VW_MARCHE_ENTRADAS