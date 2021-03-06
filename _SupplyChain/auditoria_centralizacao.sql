-- -------------------------------------------------------------------------------------------------------------------------------------
-- Buscando pedidos prontos para centralização (integrados AX OK)
-- -------------------------------------------------------------------------------------------------------------------------------------
	declare @Tbl_Pedidos_Centralizar as table
	(
		DATAAREAID [varchar](20) NULL,
		SALESID [varchar](20) NULL,
		CUSTACCOUNT [varchar](20) NULL ,
		Validado int
	)
	Insert into @Tbl_Pedidos_Centralizar (DATAAREAID , SALESID , CUSTACCOUNT )
		exec integracoes.dbo.AX2009_INTEGRACAO_05_5_Ordens_para_Centralizar
		
	update @Tbl_Pedidos_Centralizar set SALESID = REPLACE(salesid,'P_','')

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Buscando fornecedores distintos
-- -------------------------------------------------------------------------------------------------------------------------------------
	declare @TAB_FORN_FILA_CENTRALIZAR as table
	(
		COD_FORNECEDOR int
		,PEDIDOS_PENDENTES INT
	)
	INSERT INTO @TAB_FORN_FILA_CENTRALIZAR
		SELECT A.COD_FORNECEDOR, COUNT(DISTINCT T.SALESID) AS PEDIDOS_PENDENTES
		from
			BI.dbo.COMPRAS_PEDIDOS AS P
			INNER JOIN [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A
				ON P.ID_AGENDA = A.ID
			INNER JOIN @Tbl_Pedidos_Centralizar AS T
				ON P.COD_PEDIDO = T.SALESID	
		WHERE 1=1
			AND CONVERT(DATE,P.DATA) >= CONVERT(dATE,GETDATE()-1)	
		GROUP BY
			A.COD_FORNECEDOR

-- -------------------------------------------------------------------------------------------------------------------------------------
-- Buscando fornecedores que foram centralizados com pedidos pendentes de centralização (TRETA)
-- -------------------------------------------------------------------------------------------------------------------------------------
/*
	SELECT DISTINCT A.COD_FORNECEDOR, P.MARCHE_PURCHIDREF, FC.PEDIDOS_PENDENTES
	from
		BI.dbo.COMPRAS_PEDIDOS AS P
		INNER JOIN [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A
			ON P.ID_AGENDA = A.ID
		INNER JOIN @TAB_FORN_PARA_CENTRALIZAR AS FC
			ON A.COD_FORNECEDOR = FC.COD_FORNECEDOR
	WHERE 1=1
		AND P.TIPO_PEDIDO = 1
		AND P.FLG_CENTRALIZADO = 1
		AND CONVERT(DATE,P.DATA) >= CONVERT(dATE,GETDATE()-3)
		and ISNULL(P.MARCHE_PURCHIDREF,'') <> ''
		AND P.QTD_EMBALAGEM > 0
		AND COD_PEDIDO IS NOT NULL
		AND
		(
			isnull(P.FLG_ERRO_FORNECEDOR_PRINCIPAL,0) = 0
			AND isnull(P.FLG_ERRO_TIPO_ABASTECIMENTO,0) = 0
			AND isnull(P.FLG_ERRO_SEM_CUSTO,0) = 0
			AND isnull(P.FLG_COMPRA,1) = 1
			AND P.FLG_BLOQUEADO_SUPPLY IS NULL
			AND P.FLG_ERRO_CONVERSAO_UNIDADE IS NULL
		)
*/
-- -------------------------------------------------------------------------------------------------------------------------------------
-- FUCKING AEWSOME COMMAND
-- -------------------------------------------------------------------------------------------------------------------------------------
/*
	select distinct
		CONVERT(DATE,P.DATA) as DATA
		,A.COD_FORNECEDOR
		,P.COD_LOJA
		,P.COD_PEDIDO
		--,P.COD_PRODUTO
		,(case
			when ISNULL(P.MARCHE_PURCHIDREF,'') <> '' THEN 'Pedido já centralizado'
			when T.SALESID IS NOT NULL THEN 'Pronto para centralização'
			when T.SALESID IS NULL THEN 'Não está pronto para centralização'
			ELSE 'Erro não classificado'
		END) AS FLG_FILA_CENTRALIZACAO
	from
		BI.dbo.COMPRAS_PEDIDOS AS P
		INNER JOIN [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A
			ON P.ID_AGENDA = A.ID
		LEFT JOIN @Tbl_Pedidos_Centralizar AS T
			ON P.COD_PEDIDO = T.SALESID	
	WHERE 1=1
		AND P.TIPO_PEDIDO = 1
		AND P.FLG_CENTRALIZADO = 1
		AND CONVERT(DATE,P.DATA) >= CONVERT(dATE,GETDATE()-3)
		AND P.QTD_EMBALAGEM > 0
		AND COD_PEDIDO IS NOT NULL
		AND
		(
			isnull(P.FLG_ERRO_FORNECEDOR_PRINCIPAL,0) = 0
			AND isnull(P.FLG_ERRO_TIPO_ABASTECIMENTO,0) = 0
			AND isnull(P.FLG_ERRO_SEM_CUSTO,0) = 0
			AND isnull(P.FLG_COMPRA,1) = 1
			AND P.FLG_BLOQUEADO_SUPPLY IS NULL
			AND P.FLG_ERRO_CONVERSAO_UNIDADE IS NULL
		)
		--AND ID_SIMULADO = 977
	ORDER BY
		CONVERT(DATE,P.DATA)
		,A.COD_FORNECEDOR
		,P.COD_PEDIDO
*/	
-- -------------------------------------------------------------------------------------------------------------------------------------
-- FUCKING AEWSOME COMMAND 2
-- -------------------------------------------------------------------------------------------------------------------------------------
	declare @TAB_FORN_CHECK_CENTRALIZAR as table
	(
		COD_FORNECEDOR int
		,DATA DATE
		,PEDIDOS_TOTAL INT
		,PEDIDOS_JA_CENTRALIZADOS INT
		,PEDIDOS_PRONTO_CENTRALIZACAO INT
		,PEDIDOS_PENDENTES_INTEGRAR INT		
	)	
	insert into @TAB_FORN_CHECK_CENTRALIZAR
		select 
			A.COD_FORNECEDOR
			,convert(date,P.DATA)
			,COUNT(DISTINCT P.COD_PEDIDO) AS PEDIDOS_TOTAL
			,COUNT(DISTINCT CASE WHEN ISNULL(P.MARCHE_PURCHIDREF,'') <> '' THEN P.COD_PEDIDO ELSE NULL END) AS PEDIDOS_JA_CENTRALIZADOS
			,ISNULL(FC.PEDIDOS_PENDENTES,0) AS PEDIDOS_PRONTO_CENTRALIZACAO
			,COUNT(DISTINCT CASE WHEN T.SALESID	IS NULL AND ISNULL(P.MARCHE_PURCHIDREF,'') = '' THEN P.COD_PEDIDO ELSE NULL END) AS PEDIDOS_PENDENTES_INTEGRAR		
		from
			BI.dbo.COMPRAS_PEDIDOS AS P
			INNER JOIN [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A
				ON P.ID_AGENDA = A.ID
			LEFT JOIN @TAB_FORN_FILA_CENTRALIZAR AS FC
				ON A.COD_FORNECEDOR = FC.COD_FORNECEDOR
			LEFT JOIN @Tbl_Pedidos_Centralizar AS T
				ON P.COD_PEDIDO = T.SALESID	
		WHERE 1=1
			--AND T.SALESID IS NULL
			AND P.TIPO_PEDIDO = 1
			AND P.FLG_CENTRALIZADO = 1
			AND CONVERT(DATE,P.DATA) >= CONVERT(dATE,GETDATE()-1)
			AND P.QTD_EMBALAGEM > 0
			AND P.COD_PEDIDO IS NOT NULL
			AND
			(
				isnull(P.FLG_ERRO_FORNECEDOR_PRINCIPAL,0) = 0
				AND isnull(P.FLG_ERRO_TIPO_ABASTECIMENTO,0) = 0
				AND isnull(P.FLG_ERRO_SEM_CUSTO,0) = 0
				AND isnull(P.FLG_COMPRA,1) = 1
				AND P.FLG_BLOQUEADO_SUPPLY IS NULL
				AND P.FLG_ERRO_CONVERSAO_UNIDADE IS NULL
			)
		GROUP BY
			A.COD_FORNECEDOR
			,convert(date,P.DATA)
			,FC.PEDIDOS_PENDENTES 
	
	
	SELECT
		COD_FORNECEDOR
		,DATA
		,PEDIDOS_TOTAL
		,PEDIDOS_JA_CENTRALIZADOS
		,PEDIDOS_PRONTO_CENTRALIZACAO
		,PEDIDOS_PENDENTES_INTEGRAR		
	FROM @TAB_FORN_CHECK_CENTRALIZAR  where 1=1 AND PEDIDOS_JA_CENTRALIZADOS > 0 AND (PEDIDOS_PRONTO_CENTRALIZACAO > 0 OR PEDIDOS_PENDENTES_INTEGRAR > 0)

/*

-- -------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------------------------------------------
	select distinct
		CONVERT(DATE,P.DATA) as DATA
		,A.COD_FORNECEDOR
		,P.COD_LOJA
		,P.COD_PEDIDO
		--,P.COD_PRODUTO
		,(case when T.SALESID IS NOT NULL THEN 'Pronto para centralização' ELSE 'Não está pronto para centralização' END) AS FLG_FILA_CENTRALIZACAO
	from
		BI.dbo.COMPRAS_PEDIDOS AS P
		INNER JOIN [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A
			ON P.ID_AGENDA = A.ID
		LEFT JOIN @Tbl_Pedidos_Centralizar AS T
			ON P.COD_PEDIDO = T.SALESID	
	WHERE 1=1
		AND P.TIPO_PEDIDO = 1
		AND CONVERT(DATE,P.DATA) >= CONVERT(dATE,GETDATE()-3)
		and ISNULL(P.MARCHE_PURCHIDREF,'') = ''
		AND P.QTD_EMBALAGEM > 0
		AND COD_PEDIDO IS NOT NULL
		AND
		(
			isnull(P.FLG_ERRO_FORNECEDOR_PRINCIPAL,0) = 0
			AND isnull(P.FLG_ERRO_TIPO_ABASTECIMENTO,0) = 0
			AND isnull(P.FLG_ERRO_SEM_CUSTO,0) = 0
			AND isnull(P.FLG_COMPRA,1) = 1
			AND P.FLG_BLOQUEADO_SUPPLY IS NULL
			AND P.FLG_ERRO_CONVERSAO_UNIDADE IS NULL
		)
		--AND ID_SIMULADO = 977
	ORDER BY
		CONVERT(DATE,P.DATA)
		,P.COD_PEDIDO
		
		
--SELECT DISTINCT COD_PEDIDO FROM COMPRAS_PEDIDOS WHERE ID_SIMULADO = 978 and ISNULL(MARCHE_PURCHIDREF,'') = ''
*/