--itens queja estao na preco_venda
select *
FROM [BI].[dbo].[BI_PRECO_PRE_VENDA] as pre left join [BI].[dbo].[BI_PRECO_VENDA] as venda on
(
	pre.[COD_LOJA] = venda.[COD_LOJA]
	and pre.[COD_PRODUTO]= venda.[COD_PRODUTO]
	and pre.[TIPO] = venda.[TIPO]
	and pre.[DTA_INI] = venda.[DTA_INI]
)
where 1=1
and venda.COD_PRODUTO is not null
AND CONVERT(DATE,pre.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE())
and FLG_REPROVADO is null

--itens faltam ir para a preco_venda
select *
FROM [BI].[dbo].[BI_PRECO_PRE_VENDA] as pre left join [BI].[dbo].[BI_PRECO_VENDA] as venda on
(
pre.[COD_LOJA] = venda.[COD_LOJA]
and pre.[COD_PRODUTO]= venda.[COD_PRODUTO]
and pre.[TIPO] = venda.[TIPO]
and pre.[DTA_INI] = venda.[DTA_INI]
and pre.[DTA_FIM] = venda.[DTA_FIM]
)
where venda.COD_PRODUTO is null
AND CONVERT(DATE,pre.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE())
and FLG_REPROVADO is null
-- #####################################################################################################################################################################
-- VERIFICANDO ERROS
-- #####################################################################################################################################################################

-- -----------------------------------------------------------------------------------------------------------------
-- VERIFICAR PRE_VENDA
-- -----------------------------------------------------------------------------------------------------------------
SELECT
	[COD_LOJA]
	,[COD_PRODUTO]
	,[TIPO]
	,[DTA_INI]
	,[DTA_FIM]
	,[DESCRICAO]
	,[VALOR]
	,[RECID]
	,[DTA_GRAVACAO]
	,[INAtivo]
	,[COD_USUARIO]
	,[DESCRICAO_CURTA]
	,[APLICA_SIMILAR]
FROM [BI].[dbo].[BI_PRECO_PRE_VENDA]
WHERE 1 = 1
	AND CONVERT(DATE,[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE())
	AND COD_LOJA = 12
	AND COD_PRODUTO = 55772
	AND CONVERT(DATE,DTA_INI) = CONVERT(DATE,'2015-03-10')
	--and FLG_REPROVADO is null


/*	
UPDATE [BI].[dbo].[BI_PRECO_PRE_VENDA]
SET [FLG_REPROVADO] = 1
Where 1 = 1 AND COD_PRODUTO = 1019096 AND CONVERT(DATE,[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE())
and tipo = 0
AND CONVERT(DATE,DTA_INI) = CONVERT(DATE,'2015-03-10')
*/
-- -----------------------------------------------------------------------------------------------------------------
-- VERIFICAR VENDA [A OFICIAL]
-- -----------------------------------------------------------------------------------------------------------------
SELECT
	[COD_LOJA]
	,[COD_PRODUTO]
	,[TIPO]
	,[DTA_INI]
	,[DTA_FIM]
	,[DESCRICAO]
	,[VALOR]
	,[RECID]
	,[DTA_GRAVACAO]
	,[INATIVO]
	,[COD_USUARIO]
	,[DESCRICAO_CURTA]
	,[APLICA_SIMILAR]
FROM [BI].[dbo].[BI_PRECO_VENDA]
WHERE 1 = 1
	--AND CONVERT(DATE,[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE())
	AND COD_LOJA = 12
	AND COD_PRODUTO = 55772
	AND CONVERT(DATE,DTA_INI) = CONVERT(DATE,'2015-03-10')


-- #####################################################################################################################################################################
-- LIMPANDO VENDA
-- #####################################################################################################################################################################

--DELETE FROM [BI].[dbo].[BI_PRECO_VENDA] WHERE CONVERT(DATE,[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE()) and DESCRICAO not like '%novo%'

-- #####################################################################################################################################################################
-- RODANDO POR PARTES
-- #####################################################################################################################################################################

		-- -----------------------------------------------------------
		-- EXPLODE PRODUTOS SIMILARES
		-- -----------------------------------------------------------
		DECLARE @TAB_PRECO_VENDA_1 AS TABLE
		(
			[COD_LOJA] [int],
			[COD_PRODUTO_V] [int],
			[COD_PRODUTO_S] [int],
			[COD_PRODUTO_SS] [int],
			[TIPO] [int],
			[DTA_INI] [date],
			[DTA_FIM] [date],
			[DESCRICAO] [varchar](50),
			[VALOR] [float],
			[RECID] [int],
			[DTA_GRAVACAO] [datetime],
			[Inativo] [bit],
			[COD_USUARIO] [int],
			[DESCRICAO_CURTA] [varchar](50),
			[APLICA_SIMILAR] [bit],
			[COD_PRODUTO_SIMILAR] [INT],
			COD_FORNECEDOR INT
		);

		INSERT INTO @TAB_PRECO_VENDA_1
		SELECT  DISTINCT
			V.[COD_LOJA]
			,V.COD_PRODUTO
			,SS.COD_PRODUTO
			,(CASE WHEN SS.[COD_PRODUTO] IS NULL THEN V.[COD_PRODUTO] ELSE SS.[COD_PRODUTO] END) AS COD_PRODUTO
			,V.[TIPO]
			,V.[DTA_INI]
			,V.[DTA_FIM]
			,V.[DESCRICAO]
			,V.[VALOR]
			,V.[RECID]
			,V.[DTA_GRAVACAO]
			,V.[Inativo]
			,(CASE WHEN V.[COD_USUARIO] IS NULL THEN 999 ELSE V.[COD_USUARIO] END)
			,V.[DESCRICAO_CURTA]
			,V.[APLICA_SIMILAR]
			,S.[COD_PRODUTO_SIMILAR]
			,CP.COD_FORNECEDOR
		FROM
			[BI].[dbo].[BI_PRECO_PRE_VENDA] V LEFT JOIN [BI].[dbo].[CADASTRO_DEPARA_PRODUTO_SIMILAR] S ON (V.COD_PRODUTO = S.COD_PRODUTO)
				LEFT JOIN [BI].[dbo].[CADASTRO_DEPARA_PRODUTO_SIMILAR] SS ON (S.COD_PRODUTO_SIMILAR = SS.COD_PRODUTO_SIMILAR)
					LEFT JOIN [BI].[dbo].[BI_CAD_PRODUTO] CP ON ((CASE WHEN SS.[COD_PRODUTO] IS NULL THEN V.[COD_PRODUTO] ELSE SS.[COD_PRODUTO] END) = CP.COD_PRODUTO)
		WHERE 1 = 1
			AND V.APLICA_SIMILAR = 1
			and V.FLG_REPROVADO IS NULL
			--AND CP.FORA_LINHA = 'N'
			AND CONVERT(DATE,V.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE()-1)
			AND NOT EXISTS (SELECT COD_PRODUTO FROM [BI].[dbo].[BI_PRECO_VENDA] AS TVS WHERE TVS.COD_PRODUTO = V.COD_PRODUTO AND TVS.COD_LOJA = V.COD_LOJA  AND CONVERT(DATE,TVS.DTA_INI) <> CONVERT(DATE,V.DTA_INI) AND  CONVERT(DATE,TVS.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE()-1) AND TVS.VALOR = V.VALOR);;
		
		-- -----------------------------------------------------------------
		-- DELETANDO PRODUTOS EXPANDIDOS FL
		-- -----------------------------------------------------------------
			DELETE V
			FROM
				@TAB_PRECO_VENDA_1 AS V
				LEFT JOIN [BI].[dbo].[BI_LINHA_PRODUTOS] AS LP
						ON 1=1
						AND V.COD_LOJA = LP.COD_LOJA
						AND V.COD_PRODUTO_SS = LP.COD_PRODUTO
			WHERE 1=1
				AND V.COD_PRODUTO_V <> V.COD_PRODUTO_S
				AND V.TIPO IN (1,2)
				AND LP.FORA_LINHA = 'S'	

		INSERT INTO [BI].[dbo].[BI_PRECO_VENDA]
		SELECT DISTINCT
			T.[COD_LOJA],
			T.[COD_PRODUTO_SS],
			T.[TIPO],
			T.[DTA_INI],
			T.[DTA_FIM],
			T.[DESCRICAO],
			T.[VALOR],
			--[RECID],
			GETDATE(),
			T.[Inativo],
			T.[COD_USUARIO],
			T.[DESCRICAO_CURTA],
			T.[APLICA_SIMILAR],
			T.[COD_PRODUTO_SIMILAR], null, null, null	
		FROM
			@TAB_PRECO_VENDA_1 AS T
				--LEFT JOIN [BI].[dbo].[BI_PRECO_BLOQUEADO_EXPANDIDO] AS B_PROD ON (T.COD_PRODUTO_SS = B_PROD.COD_PRODUTO AND T.COD_LOJA = B_PROD.COD_LOJA)
				--LEFT JOIN [BI].[dbo].[BI_PRECO_BLOQUEADO_EXPANDIDO] AS B_FORN ON (T.COD_FORNECEDOR = B_FORN.COD_FORNECEDOR AND T.COD_LOJA = B_FORN.COD_LOJA)
		WHERE 1 = 1
			--AND B_PROD.COD_LOJA IS NULL
			--AND B_FORN.COD_LOJA IS NULL;
	

		-- -----------------------------------------------------------
		-- OFERTA PRODUTOS NÃO SIMILARES
		-- -----------------------------------------------------------
		DECLARE @TAB_PRECO_VENDA_0 AS TABLE
		(
			[COD_LOJA] [int],
			[COD_PRODUTO_V] [int],
			[TIPO] [int],
			[DTA_INI] [date],
			[DTA_FIM] [date],
			[DESCRICAO] [varchar](50),
			[VALOR] [float],
			[RECID] [int],
			[DTA_GRAVACAO] [datetime],
			[Inativo] [bit],
			[COD_USUARIO] [int],
			[DESCRICAO_CURTA] [varchar](50),
			[APLICA_SIMILAR] [bit],
			COD_FORNECEDOR INT
		);

		INSERT INTO @TAB_PRECO_VENDA_0
		SELECT  DISTINCT
			V.[COD_LOJA]
			,V.COD_PRODUTO
			,V.[TIPO]
			,V.[DTA_INI]
			,V.[DTA_FIM]
			,V.[DESCRICAO]
			,V.[VALOR]
			,V.[RECID]
			,V.[DTA_GRAVACAO]
			,V.[Inativo]
			,(CASE WHEN V.[COD_USUARIO] IS NULL THEN 999 ELSE V.[COD_USUARIO] END)
			,V.[DESCRICAO_CURTA]
			,V.[APLICA_SIMILAR]
			,CP.COD_FORNECEDOR
		FROM
			[BI].[dbo].[BI_PRECO_PRE_VENDA] V LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP ON (V.COD_PRODUTO = CP.COD_PRODUTO)
			left join
			(
			SELECT TVS.COD_LOJA, TVS.COD_PRODUTO, TVS.TIPO, CONVERT(DATE,TVS.DTA_INI) AS DTA_INI, TVS.VALOR FROM [BI].[dbo].[BI_PRECO_VENDA] AS TVS WHERE CONVERT(DATE,TVS.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE()-1)
			) AS JA_TEM
			ON 1=1
				AND V.COD_LOJA = JA_TEM.COD_LOJA
				AND V.COD_PRODUTO = JA_TEM.COD_PRODUTO
				AND V.TIPO = JA_TEM.TIPO
				AND V.DTA_INI = JA_TEM.DTA_INI
			
			
		WHERE 1 = 1
			AND V.APLICA_SIMILAR = 0
			and V.FLG_REPROVADO IS NULL
			and JA_TEM.COD_LOJA IS NULL
			AND CONVERT(DATE,V.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE()-1)
			--AND NOT EXISTS (SELECT COD_PRODUTO FROM [BI].[dbo].[BI_PRECO_VENDA] AS TVS WHERE TVS.TIPO = V.TIPO AND TVS.COD_PRODUTO = V.COD_PRODUTO AND TVS.COD_LOJA = V.COD_LOJA AND CONVERT(DATE,TVS.DTA_INI) <> CONVERT(DATE,V.DTA_INI) AND CONVERT(DATE,TVS.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE()-1) and TVS.VALOR = V.VALOR);


		INSERT INTO [BI].[dbo].[BI_PRECO_VENDA]
		SELECT DISTINCT
			T.[COD_LOJA],
			T.[COD_PRODUTO_V],
			T.[TIPO],
			T.[DTA_INI],
			T.[DTA_FIM],
			T.[DESCRICAO],
			T.[VALOR],
			--[RECID],
			GETDATE(),
			T.[Inativo],
			T.[COD_USUARIO],
			T.[DESCRICAO_CURTA],
			T.[APLICA_SIMILAR],
			NULL, null, null, null
		FROM
			@TAB_PRECO_VENDA_0 AS T
		WHERE 1 = 1;
		
	
	
	
	
	
	
	
	
	-- -----------------------------------------------------------
		-- OFERTA PRODUTOS NÃO SIMILARES
		-- -----------------------------------------------------------
		DECLARE @TAB_PRECO_VENDA_0 AS TABLE
		(
			[COD_LOJA] [int],
			[COD_PRODUTO_V] [int],
			[TIPO] [int],
			[DTA_INI] [date],
			[DTA_FIM] [date],
			[DESCRICAO] [varchar](50),
			[VALOR] [float],
			[RECID] [int],
			[DTA_GRAVACAO] [datetime],
			[Inativo] [bit],
			[COD_USUARIO] [int],
			[DESCRICAO_CURTA] [varchar](50),
			[APLICA_SIMILAR] [bit],
			COD_FORNECEDOR INT
		);

		INSERT INTO @TAB_PRECO_VENDA_0
		SELECT  DISTINCT
			V.[COD_LOJA]
			,V.COD_PRODUTO
			,V.[TIPO]
			,V.[DTA_INI]
			,V.[DTA_FIM]
			,V.[DESCRICAO]
			,V.[VALOR]
			,V.[RECID]
			,V.[DTA_GRAVACAO]
			,V.[Inativo]
			,(CASE WHEN V.[COD_USUARIO] IS NULL THEN 999 ELSE V.[COD_USUARIO] END)
			,V.[DESCRICAO_CURTA]
			,V.[APLICA_SIMILAR]
			,CP.COD_FORNECEDOR
		FROM
			[BI].[dbo].[BI_PRECO_PRE_VENDA] V LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP ON (V.COD_PRODUTO = CP.COD_PRODUTO)
		WHERE 1 = 1
			AND V.APLICA_SIMILAR = 0
			and V.FLG_REPROVADO IS NULL
			AND CONVERT(DATE,V.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE())
			AND NOT EXISTS (SELECT COD_PRODUTO FROM [BI].[dbo].[BI_PRECO_VENDA] AS TVS WHERE TVS.TIPO = V.TIPO AND TVS.COD_PRODUTO = V.COD_PRODUTO AND TVS.COD_LOJA = V.COD_LOJA AND CONVERT(DATE,TVS.DTA_INI) <> CONVERT(DATE,V.DTA_INI) AND CONVERT(DATE,TVS.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE()));
	
	
		-- -----------------------------------------------------------
		-- PRODUTOS COM OFERTA DIFERENTES DA EXPLOSÃO DO SIMILAR
		-- -----------------------------------------------------------
		DECLARE @TAB_PRECO_VENDA_PRIORIDADE AS TABLE
		(
			[COD_LOJA] [int],
			[COD_PRODUTO_V] [int],
			[TIPO] [int],
			[DTA_INI] [date],
			[DTA_FIM] [date],
			[DESCRICAO] [varchar](50),
			[VALOR] [float],
			[RECID] [int],
			[DTA_GRAVACAO] [datetime],
			[Inativo] [bit],
			[COD_USUARIO] [int],
			[DESCRICAO_CURTA] [varchar](50),
			[APLICA_SIMILAR] [bit]
		);

		INSERT INTO @TAB_PRECO_VENDA_PRIORIDADE
		SELECT  DISTINCT
			V.[COD_LOJA]
			,V.COD_PRODUTO
			,V.[TIPO]
			,V.[DTA_INI]
			,V.[DTA_FIM]
			,V.[DESCRICAO]
			,V.[VALOR]
			,V.[RECID]
			,V.[DTA_GRAVACAO]
			,V.[Inativo]
			,(CASE WHEN V.[COD_USUARIO] IS NULL THEN 999 ELSE V.[COD_USUARIO] END)
			,V.[DESCRICAO_CURTA]
			,V.[APLICA_SIMILAR]
		FROM
			[BI].[dbo].[BI_PRECO_PRE_VENDA] V 
		WHERE 1 = 1
			AND V.APLICA_SIMILAR = 0
			and V.FLG_REPROVADO IS NULL
			AND CONVERT(DATE,V.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE())
			AND EXISTS (SELECT COD_PRODUTO FROM [BI].[dbo].[BI_PRECO_VENDA] AS TVS WHERE TVS.COD_PRODUTO = V.COD_PRODUTO AND TVS.COD_LOJA = V.COD_LOJA AND CONVERT(DATE,TVS.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE()))
			AND NOT EXISTS (SELECT [COD_PRODUTO_V] FROM @TAB_PRECO_VENDA_0 AS TPVZ WHERE TPVZ.[COD_PRODUTO_V] = V.COD_PRODUTO AND TPVZ.DTA_INI = V.DTA_INI AND TPVZ.COD_LOJA = V.COD_LOJA AND CONVERT(DATE,TPVZ.[DTA_GRAVACAO]) = CONVERT(DATE,GETDATE()));

		UPDATE PV
		SET
			PV.[TIPO] = TPVP.[TIPO],
			PV.[DTA_INI] = TPVP.[DTA_INI],
			PV.[DTA_FIM] = TPVP.[DTA_FIM],
			PV.[DESCRICAO] = TPVP.[DESCRICAO],
			PV.[VALOR] = TPVP.[VALOR],
			PV.[Inativo] = TPVP.[Inativo],
			PV.[COD_USUARIO] = TPVP.[COD_USUARIO],
			PV.[DESCRICAO_CURTA] = TPVP.[DESCRICAO_CURTA]
		FROM
			[BI].[dbo].[BI_PRECO_VENDA] AS PV INNER JOIN @TAB_PRECO_VENDA_PRIORIDADE AS TPVP ON (PV.COD_LOJA = TPVP.COD_LOJA AND PV.COD_PRODUTO = TPVP.COD_PRODUTO_V  AND CONVERT(DATE,PV.[DTA_GRAVACAO]) = CONVERT(DATE,TPVP.[DTA_GRAVACAO]));

	