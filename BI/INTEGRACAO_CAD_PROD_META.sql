-- =============================================================================================================================================
-- ATUALIZAÇÃO METADADOS TABELA [CADASTRO_CAD_PRODUTO_METADADOS]
-- =============================================================================================================================================

-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARCA
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	CAST([ITEMID] AS INT) AS COD_PRODUTO
	,6 AS COD_METADADO
	,GETDATE() AS DTA_GRAVACAO
	,MAX([MDT_NO_MARCA]) AS VLR_METADADO
FROM
	[BI].[dbo].[CADASTRO_CAD_PRODUTO_NOVO] AS PN
WHERE 1 = 1
	AND (MDT_NO_MARCA IS NOT NULL)
	AND [ITEMID] > 0
	AND NOT EXISTS (SELECT 1 FROM [BI].[dbo].[CADASTRO_CAD_PRODUTO_METADADOS] AS PM WHERE COD_METADADO = 6 AND PN.ITEMID = PM.COD_PRODUTO)
GROUP BY
	[ITEMID]
	
	
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- PAIS
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	CAST([ITEMID] AS INT) AS COD_PRODUTO
	,8 AS COD_METADADO
	,GETDATE() AS DTA_GRAVACAO
	,MAX([MDT_NO_PAIS_ORG]) AS VLR_METADADO
FROM
	[BI].[dbo].[CADASTRO_CAD_PRODUTO_NOVO] AS PN
WHERE 1 = 1
	AND ([MDT_NO_PAIS_ORG] IS NOT NULL)
	AND [ITEMID] > 0
	AND NOT EXISTS (SELECT 1 FROM [BI].[dbo].[CADASTRO_CAD_PRODUTO_METADADOS] AS PM WHERE COD_METADADO = 8 AND PN.ITEMID = PM.COD_PRODUTO)
GROUP BY
	[ITEMID]
	
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- UNI_MEDIDA
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	CAST([ITEMID] AS INT) AS COD_PRODUTO
	,20 AS COD_METADADO
	,GETDATE() AS DTA_GRAVACAO
	,MAX([MDT_UNI_MEDIDA]) AS VLR_METADADO
FROM
	[BI].[dbo].[CADASTRO_CAD_PRODUTO_NOVO] AS PN
WHERE 1 = 1
	AND ([MDT_UNI_MEDIDA] IS NOT NULL)
	AND [ITEMID] > 0
	AND NOT EXISTS (SELECT 1 FROM [BI].[dbo].[CADASTRO_CAD_PRODUTO_METADADOS] AS PM WHERE COD_METADADO = 20 AND PN.ITEMID = PM.COD_PRODUTO)
GROUP BY
	[ITEMID]
	
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- QTD_UNI_MEDIDA
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	CAST([ITEMID] AS INT) AS COD_PRODUTO
	,21 AS COD_METADADO
	,GETDATE() AS DTA_GRAVACAO
	,MAX([MDT_QTD_UNI_MEDIDA]) AS VLR_METADADO
FROM
	[BI].[dbo].[CADASTRO_CAD_PRODUTO_NOVO] AS PN
WHERE 1 = 1
	AND ([MDT_QTD_UNI_MEDIDA] IS NOT NULL)
	AND [ITEMID] > 0
	AND NOT EXISTS (SELECT 1 FROM [BI].[dbo].[CADASTRO_CAD_PRODUTO_METADADOS] AS PM WHERE COD_METADADO = 21 AND PN.ITEMID = PM.COD_PRODUTO)
GROUP BY
	[ITEMID]


/*
SELECT TOP 1000
	[ITEMID]
	,[MDT_NO_MARCA]
	,[MDT_UNI_MEDIDA]
	,[MDT_QTD_UNI_MEDIDA]
	,[MDT_NO_PAIS_ORG]
	,[DTA_GRAVACAO]
	,[FLG_INTEGRADO]
FROM [BI].[dbo].[CADASTRO_CAD_PRODUTO_NOVO]
WHERE 1 = 1
	AND (MDT_NO_MARCA IS NOT NULL OR MDT_UNI_MEDIDA IS NOT NULL OR MDT_NO_PAIS_ORG IS NOT NULL)
	AND DTA_GRAVACAO >= GETDATE()-10


select * from BI..CADASTRO_CAD_METADADOS

delete from BI..[CADASTRO_CAD_PRODUTO_METADADOS] where convert(date,dta_gravacao) >= convert(date,getdate())
select * from BI..[CADASTRO_CAD_PRODUTO_METADADOS] where convert(date,dta_gravacao) >= convert(date,getdate())


TRUNCATE TABLE BI..[CADASTRO_CAD_PRODUTO_METADADOS_TESTE]
select * from BI..[CADASTRO_CAD_PRODUTO_METADADOS_TESTE]
*/	


SELECT TOP 100
*
FROM
	BI.DBO.BI_CAD_PRODUTO
	

-- =============================================================================================================================================
-- ATUALIZAÇÃO METADADOS TABELA CAD_PRODUTO
-- =============================================================================================================================================

-- ------------------------------------------------
-- MARCAS
-- ------------------------------------------------
UPDATE CP
SET
	CP.MDT_NO_MARCA = PMETA.VLR_METADADO
FROM
	BI.DBO.BI_CAD_PRODUTO AS CP INNER JOIN BI.DBO.CADASTRO_CAD_PRODUTO_METADADOS AS PMETA ON (CP.COD_PRODUTO = PMETA.COD_PRODUTO)
WHERE 1 = 1
	AND PMETA.COD_METADADO = 6

-- ------------------------------------------------
-- PAIS
-- ------------------------------------------------
UPDATE CP
SET
	CP.MDT_NO_PAIS_ORG = PMETA.VLR_METADADO
FROM
	BI.DBO.BI_CAD_PRODUTO AS CP INNER JOIN BI.DBO.CADASTRO_CAD_PRODUTO_METADADOS AS PMETA ON (CP.COD_PRODUTO = PMETA.COD_PRODUTO)
WHERE 1 = 1
	AND PMETA.COD_METADADO = 8
	
-- ------------------------------------------------
-- UNI MEDIDA
-- ------------------------------------------------
UPDATE CP
SET
	CP.MDT_UNI_MEDIDA = PMETA.VLR_METADADO
FROM
	BI.DBO.BI_CAD_PRODUTO AS CP INNER JOIN BI.DBO.CADASTRO_CAD_PRODUTO_METADADOS AS PMETA ON (CP.COD_PRODUTO = PMETA.COD_PRODUTO)
WHERE 1 = 1
	AND PMETA.COD_METADADO = 20
	
-- ------------------------------------------------
-- QTD UNI MEDIDA
-- ------------------------------------------------
UPDATE CP
SET
	CP.MDT_QTD_UNI_MEDIDA = PMETA.VLR_METADADO
FROM
	BI.DBO.BI_CAD_PRODUTO AS CP INNER JOIN BI.DBO.CADASTRO_CAD_PRODUTO_METADADOS AS PMETA ON (CP.COD_PRODUTO = PMETA.COD_PRODUTO)
WHERE 1 = 1
	AND PMETA.COD_METADADO = 21