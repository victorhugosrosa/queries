-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CRIANDO A TABELA
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE [BI].[dbo].[BI_LINHA_PRODUTOS];

INSERT INTO [BI].[dbo].[BI_LINHA_PRODUTOS]
SELECT
	LOJA.COD_LOJA
	,LOJA.COD_PRODUTO
	,PROD.COD_SECAO
	,PROD.COD_GRUPO
	,(CASE WHEN LOJA.FORA_LINHA = 'N' AND LOJA.INATIVO = 'N' AND PROD.FORA_LINHA = 'N' THEN 'N' ELSE 'S' END) AS FORA_LINHA
    ,(CASE PROD.STATUS WHEN 0 THEN 'S' ELSE 'N' END) AS ENVIA_PDV
    ,ISNULL(E.CLASSIF_PRODUTO_LOJA,'Z') AS CLASSIF_PRODUTO_LOJA
    ,NULL AS QTDE_PRODUTO_1ANO
    ,NULL AS VALOR_TOTAL_1ANO
FROM
	[192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_LOJA AS LOJA WITH (NOLOCK) INNER JOIN [192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO AS PROD WITH (NOLOCK) ON (LOJA.COD_PRODUTO = PROD.COD_PRODUTO)
		LEFT JOIN BI.DBO.COMPRAS_ESTATISTICA_PRODUTO AS E ON (E.COD_PRODUTO = LOJA.COD_PRODUTO AND E.COD_LOJA = LOJA.COD_LOJA)
WHERE 1 = 1
	AND PROD.COD_SECAO NOT IN (6,10,37,40,41,15,35,19,99,9,16,20)
	AND LOJA.COD_LOJA NOT IN (5,8,11,14,15,16);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CRIANDO A TEMPORARIA COM VENDA DE 360 DIAS
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TABLE_1ANO AS TABLE
(
	COD_LOJA INT
	,COD_PRODUTO INT
	,QTDE_PRODUTO_1ANO NUMERIC(18,2)
	,VALOR_TOTAL_1ANO NUMERIC(18,2)
);

INSERT INTO @TABLE_1ANO
SELECT
	LINHA.[COD_LOJA]
	,LINHA.[COD_PRODUTO]
	,SUM(VP.QTDE_PRODUTO)AS QTDE_PRODUTO_1ANO
	,SUM(VP.VALOR_TOTAL) AS VALOR_TOTAL_1ANO
FROM
	[BI].[dbo].[BI_LINHA_PRODUTOS] as LINHA 
		LEFT JOIN [BI].[dbo].[BI_VENDA_PRODUTO] AS VP ON (LINHA.COD_LOJA = VP.COD_LOJA AND LINHA.COD_PRODUTO = VP.COD_PRODUTO)
where 1 = 1
	--AND LINHA.COD_LOJA = 1
	AND CONVERT(DATE,VP.DATA) >= CONVERT(DATE,GETDATE()-360)
	AND CONVERT(DATE,VP.DATA) < CONVERT(DATE,GETDATE())
GROUP BY
	LINHA.[COD_LOJA]
	,LINHA.[COD_PRODUTO]

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ATUALIZANDO A TABELA
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE LINHA
SET
	LINHA.QTDE_PRODUTO_1ANO = VP.QTDE_PRODUTO_1ANO
	,LINHA.VALOR_TOTAL_1ANO = VP.VALOR_TOTAL_1ANO
FROM
	[BI].[dbo].[BI_LINHA_PRODUTOS] as LINHA 
		LEFT JOIN @TABLE_1ANO AS VP ON (LINHA.COD_LOJA = VP.COD_LOJA AND LINHA.COD_PRODUTO = VP.COD_PRODUTO);


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
SELECT * FROM [BI].[dbo].[BI_LINHA_PRODUTOS]



