-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT TOP 100
		PV.COD_USUARIO
		,PV.COD_LOJA
		,PV.COD_PRODUTO
		,PV.DTA_INI
		,PV.DTA_FIM
		,PV.DESCRICAO
		,PV.VALOR
		,PV.ARREDONDAR
		,'' AS DIAS
		,TA.TIPO_ALTERACAO		
		,CP.DESCRICAO AS NO_PRODUTO
		,CP.COD_SECAO
		,CP.FORA_LINHA
		,'' AS DUPLICADOS
		,TA.TEMPO_LIMITE
		,'' VLR_ARRENDONDADO
		,SIMI.COD_PRODUTO_SIMILAR
		,PV.APLICAR_SIMILAR
		,'' AS DIG
		,'' AS DIA_SEMANA_INI
		,'' AS DIA_SEMANA_FIM	
	FROM
		[BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS] AS PV
		LEFT JOIN [BI].[dbo].[BI_PRECO_TIPO_ALTERACAO] AS TA
			ON PV.DESCRICAO = TA.NO_TIPO_ALTERACAO
		LEFT JOIN [BI].[dbo].[BI_CAD_PRODUTO] AS CP
			ON PV.COD_PRODUTO = CP.COD_PRODUTO
		LEFT JOIN [BI].[dbo].[CADASTRO_DEPARA_PRODUTO_SIMILAR] AS SIMI
			ON 1=1
			AND PV.COD_PRODUTO = SIMI.COD_PRODUTO
	WHERE 1=1
		AND CONVERT(DATE,DTA_GRAVACAO) = CONVERT(DATE,GETDATE()-1)

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF OBJECT_ID('TEMPDB.DBO.#BI_TEMP_CAD_PROD') IS NOT NULL DROP TABLE #BI_TEMP_CAD_PROD
	
	CREATE TABLE #BI_TEMP_CAD_PROD
	(
		COD_LOJA INT
		,COD_PRODUTO INT
		,FORA_LINHA VARCHAR(1)
		,ENVIA_PDV VARCHAR(1)
		,VLR_MRGREF NUMERIC(18,2)
		,VLR_VENDA NUMERIC(18,2)
		,VLR_OFERTA NUMERIC(18,2)
		,VLR_VCMARCHE NUMERIC(18,2)
		,MTD_NOTAVEL INT
		,COD_FORNECEDOR INT
		,NO_FORNECEDOR VARCHAR(50)
	)
	CREATE CLUSTERED INDEX IDX_BI_TEMP_CAD_PROD ON #BI_TEMP_CAD_PROD (COD_LOJA, COD_PRODUTO)

	INSERT INTO #BI_TEMP_CAD_PROD
	SELECT
		LP.COD_LOJA
		,CP.COD_PRODUTO
		,LP.FORA_LINHA
		,LP.ENVIA_PDV
		,LP.VLR_MRGREF
		,LP.VLR_VENDA
		,LP.VLR_OFERTA
		,LP.VLR_VCMARCHE		
		,isnull((SELECT VLR_METADADO FROM CADASTRO_CAD_PRODUTO_METADADOS TPM WHERE TPM.COD_PRODUTO = CP.COD_PRODUTO AND TPM.COD_METADADO = 16),0) AS MTD_NOTAVEL
		,CF.COD_FORNECEDOR
		,CF.DES_FANTASIA
	FROM
		[BI].[dbo].[BI_CAD_PRODUTO] AS CP
		INNER JOIN [BI].[dbo].[BI_LINHA_PRODUTOS] AS LP
			ON 1=1
			AND CP.COD_PRODUTO = LP.COD_PRODUTO
			
		LEFT JOIN [BI].[dbo].[BI_CAD_FORNECEDOR] AS CF
			ON 1=1
			AND CP.COD_FORNECEDOR = CF.COD_FORNECEDOR
		
	WHERE 1=1
		AND CP.COD_PRODUTO IN (SELECT COD_PRODUTO FROM [BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS] WHERE 1=1 AND CONVERT(DATE,DTA_GRAVACAO) = CONVERT(DATE,GETDATE()-1) )

	SELECT * FROM #BI_TEMP_CAD_PROD

	IF OBJECT_ID('TEMPDB.DBO.#BI_TEMP_CAD_PROD') IS NOT NULL DROP TABLE #BI_TEMP_CAD_PROD

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
--SELECT TOP 100 * FROM [BI].[dbo].[BI_LINHA_PRODUTOS] --preco venda/oferta/vcmarche
--SELECT TOP 100 * FROM [BI].[dbo].[COMPRAS_CAD_COMPRADOR]
--SELECT TOP 100 * FROM [BI].[dbo].[CADASTRO_DEPARA_PRODUTO_SIMILAR] --Notaveis
--SELECT TOP 100 * FROM [AX2009_INTEGRACAO].[dbo].[vw_MARCHE_PRODUTO_SITUACAO]
--SELECT TOP 100 * FROM [BI].[dbo].[BI_CAD_FORNECEDOR]

--SELECT TOP 100 * FROM [BI].[dbo].[CADASTRO_CAD_PRODUTO_METADADOS] --Notaveis

SELECT TOP 100 * FROM [BI].[dbo].[BI_PRECO_VENDA] --Prog Fut | Ultima Alteração |
SELECT TOP 100 * FROM [BI].[dbo].[BI_PRECO_BLOQUEADO_EXPANDIDO] --Tabloide |

--////////////////////////////////////////////////////////////////////////////////////////////

SELECT top 100
	[COD_USUARIO]
	,[COD_LOJA]
	,[COD_PRODUTO]
	,[DTA_INI]
	,[DTA_FIM]
	,[DESCRICAO]
	,[VALOR]
	,[ARREDONDAR]
	,[APLICAR_SIMILAR]
	,[DTA_GRAVACAO]
FROM
	[BI].[dbo].[BI_PRECO_PRE_VENDA_COMPRAS]
WHERE 1=1
	AND CONVERT(DATE,DTA_GRAVACAO) = CONVERT(DATE,GETDATE()-1)
	

	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ULTIMA GRAVACAO
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @ULTIMA_GRAVACAO AS TABLE
	(
		[COD_LOJA] [int] NOT NULL,
		[COD_PRODUTO] [int] NOT NULL,
		[DTA_GRAVACAO] [datetime] NULL,
		[DESCRICAO] [varchar](50) NULL,
		[DTA_INI] [date] NOT NULL,
		[COD_USUARIO] [int] NOT NULL
	)

	INSERT INTO @ULTIMA_GRAVACAO
	SELECT 
		pv.[COD_LOJA]
		,pv.[COD_PRODUTO]
		,pv.[DTA_GRAVACAO] 
		,pv.[DESCRICAO] 
		,pv.[DTA_INI] 
		,pv.[COD_USUARIO]     
	FROM 
		[BI].[dbo].[BI_PRECO_PRE_VENDA] as pv
	where 1=1
		and pv.[DTA_GRAVACAO] = (select MAX([DTA_GRAVACAO]) from [BI].[dbo].[BI_PRECO_PRE_VENDA] as tpv where tpv.[COD_LOJA] = pv.[COD_LOJA] and tpv.[COD_PRODUTO] = pv.[COD_PRODUTO])
		and pv.DTA_INI = (select MAX([DTA_INI]) from [BI].[dbo].[BI_PRECO_PRE_VENDA] as tpv where tpv.[COD_LOJA] = pv.[COD_LOJA] and tpv.[COD_PRODUTO] = pv.[COD_PRODUTO])

	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- 
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
SELECT TOP 100 * FROM [BI].[dbo].[BI_CAD_PRODUTO]
SELECT TOP 100 * FROM [BI].[dbo].[BI_LINHA_PRODUTOS] --preco venda/oferta/vcmarche
SELECT TOP 100 * FROM [BI].[dbo].[COMPRAS_CAD_COMPRADOR]

SELECT TOP 100 * FROM [BI].[dbo].[CADASTRO_DEPARA_PRODUTO_SIMILAR] --Notaveis

SELECT TOP 100 * FROM [BI].[dbo].[CADASTRO_CAD_PRODUTO_METADADOS] --Notaveis

SELECT TOP 100 * FROM [BI].[dbo].[BI_PRECO_VENDA] --Prog Fut | Ultima Alteração |
SELECT TOP 100 * FROM [BI].[dbo].[BI_PRECO_BLOQUEADO_EXPANDIDO] --Tabloide |


SELECT TOP 100 * FROM [AX2009_INTEGRACAO].[dbo].[vw_MARCHE_PRODUTO_SITUACAO]


SELECT TOP 100 * FROM [BI].[dbo].[BI_CAD_FORNECEDOR]
*/