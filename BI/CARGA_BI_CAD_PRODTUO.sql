-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- HIERARQUIA DE PRODUTOS FROM AX
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_HIERARQUIA AS TABLE
	(
		COD_DEPARTAMENTO INT
		,NO_DEPARTAMENTO VARCHAR(50)
		,COD_SECAO INT
		,NO_SECAO VARCHAR(50)
		,COD_GRUPO INT
		,NO_GRUPO VARCHAR(50)
		,COD_SUBGRUPO INT
		,NO_SUBGRUPO VARCHAR(50)
	)

	INSERT INTO @TAB_HIERARQUIA
	SELECT 
		CAST([AX_UNIDNEG_CODIGO] AS INT) AS ZEUS_COD_DEPARTAMENTO
		,[AX_UNIDNEG_DESCRICAO]
		,CAST([AX_SECAO_CODIGO] AS INT) AS ZEUS_COD_SECAO
		,[AX_SECAO_DESCRICAO]
		,RIGHT([AX_GRUPO_CODIGO],(LEN([AX_GRUPO_CODIGO]) - (CHARINDEX([AX_SECAO_CODIGO],[AX_GRUPO_CODIGO]) + LEN([AX_SECAO_CODIGO])-1))) AS ZEUS_COD_GRUPO	
		,[AX_GRUPO_DESCRICAO]
		,CAST(LEFT([AX_SUBGRUPO_CODIGO],LEN([AX_SUBGRUPO_CODIGO]) - (LEN(RIGHT([AX_GRUPO_CODIGO],(LEN([AX_GRUPO_CODIGO]) - (CHARINDEX([AX_SECAO_CODIGO],[AX_GRUPO_CODIGO]) + LEN([AX_SECAO_CODIGO])-1)))) + LEN(CAST([AX_SECAO_CODIGO] AS INT)))) AS INT) AS ZEUS_COD_SUBGRUPO	
		,[AX_SUBGRUPO_DESCRICAO]
	FROM
		AX2009_INTEGRACAO.DBO.TAB_HIERARQUIA_PRODUTO;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INSERT BI_CAD_PRODUTO
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE BI.DBO.BI_CAD_PRODUTO
		
	INSERT INTO BI.DBO.BI_CAD_PRODUTO
	SELECT
		P.[COD_PRODUTO]
		,H.[COD_DEPARTAMENTO]
		,P.[COD_SECAO]
		,P.[COD_GRUPO]
		,P.[COD_SUB_GRUPO]
		,H.[NO_DEPARTAMENTO]
		,H.[NO_SECAO]
		,H.[NO_GRUPO]
		,H.[NO_SUBGRUPO]
		,P.[DES_PRODUTO]
		,P.[FORA_LINHA]
		,P.[DTA_CADASTRO]
		,P.IPV AS [PESADO]
		,P.DES_UNIDADE_COMPRA AS [UNIDADE_COMPRA]
		,P.DES_UNIDADE_VENDA AS [UNIDADE_VENDA]
		, 0 AS [FLG_MARCA_PROPRIA]
		,NULL AS [COD_FORNECEDOR]
		,NULL AS [CLASSIF_PRODUTO]
		,NULL AS [COD_PRODUTO_SIMILAR]
	FROM
	AX2009_INTEGRACAO.DBO.TAB_PRODUTO_SIMPLIFICADO AS P LEFT JOIN @TAB_HIERARQUIA AS H ON (P.COD_SECAO = H.COD_SECAO AND P.COD_GRUPO = H.COD_GRUPO AND P.COD_SUB_GRUPO = H.COD_SUBGRUPO)
	WHERE 1 = 1
	AND P.COD_SECAO IS NOT NULL;
	
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE BI_CAD_PRODUTO
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE CAD
	SET
		CAD.COD_PRODUTO_SIMILAR = DEPARA.COD_PRODUTO_SIMILAR
	FROM [BI].[dbo].[BI_CAD_PRODUTO] AS CAD INNER JOIN [BI].[dbo].[CADASTRO_DEPARA_PRODUTO_SIMILAR] AS DEPARA ON (CAD.COD_PRODUTO = DEPARA.COD_PRODUTO);

	-- --------------------------------------------------------
	-- Fornecedor Principal
	-- --------------------------------------------------------		
	UPDATE BI_CAD_PRODUTO
	set COD_FORNECEDOR = b.COD_FORNECEDOR 
	from BI_CAD_PRODUTO a inner join VW_PRODUTO_FORNECEDOR_PRINCIPAL b
	on (a.cod_produto = b.cod_produto)


	declare @tab_forn as table
	(
		COD_FORNECEDOR int
		,COD_PRODUTO int
	)

	insert into @tab_forn
	select COD_FORNECEDOR,COD_PRODUTO from 
		(
		SELECT [COD_FORNECEDOR]
			  ,1*COD_PRODUTO AS COD_PRODUTO
			  ,RANK() over (partition by  COD_PRODUTO order by sum([VAL_TABELA_LIQ]) desc) as r
		 FROM [192.168.0.6].[Zeus_rtg].[dbo].[vw_MARCHE_ENTRADAS]
		 where 1=1
		 group by [COD_FORNECEDOR]
				 ,COD_PRODUTO
		) as s
	where  r = 1

	UPDATE CP
	SET
		CP.COD_FORNECEDOR = TEMP.COD_FORNECEDOR
	FROM
		BI_CAD_PRODUTO AS CP INNER JOIN @tab_forn AS TEMP ON (CP.COD_PRODUTO = TEMP.COD_PRODUTO)
	WHERE 1 = 1
		AND CP.COD_FORNECEDOR IS NULL
		
		
	declare @tab_forn_new as table
	(
		COD_FORNECEDOR int
		,COD_PRODUTO int
	)

	insert into @tab_forn_new
	select COD_FORNECEDOR,COD_PRODUTO from 
		(
		SELECT [COD_FORNECEDOR]
			  ,1*COD_PRODUTO AS COD_PRODUTO
			  ,RANK() over (partition by  COD_PRODUTO order by cod_fornecedor desc) as r
		 FROM AX2009_INTEGRACAO.dbo.TAB_PRODUTO_FORNECEDOR
		 where 1=1
		 group by [COD_FORNECEDOR]
				 ,COD_PRODUTO
		) as s
	where  r = 1


	UPDATE CP
	SET
		CP.COD_FORNECEDOR = TEMP.COD_FORNECEDOR
	FROM
		BI_CAD_PRODUTO AS CP INNER JOIN @tab_forn_new AS TEMP ON (CP.COD_PRODUTO = TEMP.COD_PRODUTO)
	WHERE 1 = 1
		AND CP.COD_FORNECEDOR IS NULL


