DECLARE @TAB_MODEL_ARMAZENAGEM AS TABLE
	(
		COD_PRODUTO INT
		,ModelArmazenagem INT
		,PRIMARY KEY (COD_PRODUTO)
	)
	
	INSERT INTO @TAB_MODEL_ARMAZENAGEM
	SELECT
		COD_PRODUTO
		,ModelArmazenagem
	FROM AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL AS AFP
	WHERE 1=1
		AND AFP.COD_LOJA = 5
		AND AFP.COD_PRODUTO IN (SELECT DISTINCT COD_PRODUTO FROM [BI].[DBO].[COMPRAS_PEDIDOS] AS P WHERE CONVERT(DATE,DATA) = CONVERT(DATE,'2017-02-16') AND FLG_AUTOMATICO = 1)
	

	SELECT --TOP 100
		P.ID_SIMULADO
		,P.ID_AGENDA
		,A.COD_FORNECEDOR
		,CF2.DESCRICAO AS [Desc. Forn. Agenda]
		,P.TIPO_PEDIDO
		,P.COD_PEDIDO
		,P.DATA
		,P.[COD_FORNECEDOR] as [Cod. Forn.]
		,CF.DESCRICAO AS [Desc. Forn.]		
		,P.[COD_LOJA] as [Loja]
		,P.[COD_PRODUTO] as [PLU]
		,CP.DESCRICAO AS [Desc. PLU]
		,CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,[QTD_EMBALAGEM] AS [Pedido]
		,P.[COD_COMPRADOR] as [Cod. Comprador]
		,[QTD_ESTOQUE] AS [Estoque]
		,QTD_ESTOQUE_TRANS AS [Estoque Transito]
		,[VLR_EMB] AS [Valor CX]
		,[VLR_MULTIPLO] AS [Qtde Múltiplo]
		,[QTD_EMB_ORG] AS [Qtde Embalagem]
		,[VLR_REV_TIME] AS [Freq. Pedido]
		,[VLR_LEAD_TIME] AS [Lead time]
		,p.[AVG_QTD_U30D_PD] AS [VMD 180D]
		,[QTD_SS_DIAS] AS [Est. Seg. dias]
		,[FAT_SAZ] AS [% Sazon.]
		,[QTD_MIN_UN] AS [Exposição qtde]
		,E.CLASSIF_PRODUTO_LOJA as [Classif. PLU]
		,PABC.ABC_LOJA as [Classif. Supply] 
		,(CASE
			WHEN afp.ModelArmazenagem = 0 THEN 'Direto'
			WHEN afp.ModelArmazenagem = 1 THEN 'CrossDocking'
			WHEN afp.ModelArmazenagem = 2 THEN 'Armazenagem'
			WHEN afp.ModelArmazenagem = 3 THEN 'PickingUnitario'
		END) AS TIPO_ABASTECIMENTO
		,ISNULL(P.ERRO_CENTRALIZACAO,'') AS ERRO_CENTRALIZACAO
		,P.FLG_CENTRALIZADO
		,P.FORNECEDOR_PRINCIPAL_PROD
		,(CASE WHEN P.FLG_ERRO_FORNECEDOR_PRINCIPAL = 1 THEN 'Alterar no AX campo de Fornecedor na aba de Referencia' else '' end) as FLG_ERRO_FORNECEDOR_PRINCIPAL	
		,(CASE 
			WHEN P.FLG_ERRO_TIPO_ABASTECIMENTO = 1 THEN 
				(CASE
					WHEN P.TIPO_PEDIDO = 3 AND afp.ModelArmazenagem = 1 AND (SELECT TOP 1 1 FROM [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A_TIPO1 WHERE A.COD_FORNECEDOR = A_TIPO1.COD_FORNECEDOR AND A_TIPO1.TIPO = 1 AND A_TIPO1.FLG_ATIVO = 1) = 1 THEN 'Fornecedor possui agenda XD - Não alterar'
					WHEN P.TIPO_PEDIDO = 1 AND afp.ModelArmazenagem IN (0,2) AND (SELECT TOP 1 ID FROM [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A_TIPO1 WHERE A.COD_FORNECEDOR = A_TIPO1.COD_FORNECEDOR AND A_TIPO1.TIPO = 3 AND A_TIPO1.FLG_ATIVO = 1) = 1 THEN 'Fornecedor possui agenda Armazenagem - Não alterar'
					ELSE 'Verificar se o fornecedor possui agenda XD/Abastecimento'
				END)
			ELSE ''
		END) as FLG_ERRO_TIPO_ABASTECIMENTO
		,(CASE WHEN P.FLG_ERRO_SEM_CUSTO = 1 THEN 'produto sem custo na ORBIS 18055' when P.FLG_ERRO_SEM_CUSTO = 2 THEN 'Não possui custo atualizado! Subir custo!' else '' end) as FLG_ERRO_SEM_CUSTO
		,(CASE WHEN isnull(FLG_COMPRA,1) = 1 THEN 'ABC Liberado' else 'ABC bloqueado' end) as FLG_COMPRA	
		,(CASE WHEN P.FLG_ERRO_CONVERSAO_UNIDADE = 1 THEN 'Produto em CX sem conversão de unidade' else '' end) as FLG_ERRO_CONVERSAO_UNIDADE	
		,(CASE WHEN P.FLG_BLOQUEADO_SUPPLY = 1 THEN 'Produto bloqueado para compra pelo Supply' else '' end) as FLG_BLOQUEADO_SUPPLY	
		,(CASE WHEN P.FLG_ERRO_SEM_REFERENCIA = 1 THEN 'Produto bloqueado. Não possui referência no fornecedor principal' else '' end) as FLG_ERRO_SEM_REFERENCIA	
		,(CASE
			WHEN P.FLG_ERRO_FORNECEDOR_PRINCIPAL = 0 AND P.FLG_ERRO_TIPO_ABASTECIMENTO = 0 AND P.FLG_ERRO_SEM_CUSTO = 0 AND P.FLG_COMPRA = 1 and P.FLG_BLOQUEADO_SUPPLY IS NULL AND P.FLG_ERRO_CONVERSAO_UNIDADE IS NULL AND P.FLG_ERRO_SEM_REFERENCIA IS NULL AND P.ERRO_CENTRALIZACAO IS NOT NULL THEN 'Vai gerar Pedido COM ERRO'
			WHEN P.FLG_ERRO_FORNECEDOR_PRINCIPAL = 0 AND P.FLG_ERRO_TIPO_ABASTECIMENTO = 0 AND P.FLG_ERRO_SEM_CUSTO = 0 AND P.FLG_COMPRA = 1 AND P.FLG_BLOQUEADO_SUPPLY IS NULL AND P.FLG_ERRO_CONVERSAO_UNIDADE IS NULL AND P.FLG_ERRO_SEM_REFERENCIA IS NULL AND P.ERRO_CENTRALIZACAO IS NULL THEN 'Vai gerar Pedido'
			ELSE 'Não vai gerar pedido'
		END) AS VAI_GERAR_PEDIDO
		,P.ID AS ID_PEDIDO
		,P.FLG_INTEGRADO_AX
		,P.MARCHE_PURCHIDREF
		--update p set data = getdate() 
		--,ID	delete p
		,QTD_PEDIDO_ORG
		,QTD_EMBALAGEM_FORN
		,QTD_MULTIPLO_FORN
		,FLG_ARREDONDADO 
	FROM
		[BI].[DBO].[COMPRAS_PEDIDOS] AS P
		INNER JOIN BI.DBO.BI_CAD_PRODUTO AS CP
			ON P.COD_PRODUTO = CP.COD_PRODUTO
		INNER JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF
			ON P.COD_FORNECEDOR = CF.COD_FORNECEDOR
		LEFT JOIN [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A
			ON P.ID_AGENDA = A.ID
		LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF2
			ON A.COD_FORNECEDOR = CF2.COD_FORNECEDOR
		LEFT JOIN @TAB_MODEL_ARMAZENAGEM AS AFP
			ON 1=1
			AND P.COD_PRODUTO = AFP.COD_PRODUTO	
		LEFT JOIN BI.DBO.[SUPPLY_PRODUTO_ABC_LOJA] AS PABC
			ON 1=1
			--AND P.COD_LOJA = PABC.COD_LOJA
			AND PABC.COD_LOJA = 0
			AND P.COD_PRODUTO = PABC.COD_PRODUTO	
		LEFT JOIN BI.dbo.COMPRAS_ESTATISTICA_PRODUTO AS E
			ON 1=1
			AND P.COD_LOJA = E.COD_LOJA
			AND P.COD_PRODUTO = E.COD_PRODUTO
	WHERE 1=1
		--AND CONVERT(DATE,DATA) = CONVERT(DATE,@DATA_PEDIDO)
		--AND FLG_AUTOMATICO = 1
		and P.ID_SIMULADO = 20840
		and P.COD_PRODUTO = 1034800
		and p.COD_LOJA = 5
		
		
-- ##########################################################################################################################################################		
--
-- ##########################################################################################################################################################
	select ID , COD_FORNECEDOR , COD_LOJA , COD_PRODUTO , QTD_EMBALAGEM  , 0 , VLR_EMB
	from BI.dbo.COMPRAS_PEDIDOS  with (nolock) 
	where 1 = 1
	
	and ID = '1LBOHFQ3QCHDSN8U9DQK'
	
	and COD_PRODUTO = 1034800
	and COD_LOJA = 5
	
	-- ------------------------------------------------------------------------------------------------------
	AND isnull(FLG_ERRO_FORNECEDOR_PRINCIPAL,0) = 0
	AND isnull(FLG_ERRO_TIPO_ABASTECIMENTO,0)   = 0
	AND isnull(FLG_ERRO_SEM_CUSTO	,0)		  = 0
	AND isnull(FLG_COMPRA,1)	= 1				
	and QTD_EMBALAGEM > 0 -- Incluido Por Frade a pedido do Victor Hoje dia 11/02/2016
	-- ------------------------------------------------------------------------------------------------------
	-- incluido victor 01/06/2016
	and FLG_BLOQUEADO_SUPPLY IS NULL
	AND FLG_ERRO_CONVERSAO_UNIDADE IS NULL
	-- ------------------------------------------------------------------------------------------------------				
	-- incluido victor 22/06/2016
	and isnull(FLG_ERRO_SEM_REFERENCIA,0) = 0
	-- ------------------------------------------------------------------------------------------------------				
	--and cast(Data as date) >=  @Dta_limite_pedido  -- alterado por Frade: 14/06/2016
	-- ------------------------------------------------------------------------------------------------------		

-- ##########################################################################################################################################################		
--
-- ##########################################################################################################################################################
	select * from [192.168.0.6].[Intranet].[dbo].[TAB_IMPORTACAO_PEDIDO] where id = '1LBOHFQ3QCHDSN8U9DQK' and COD_PRODUTO = 1034800
	
	select * from [192.168.0.6].[Intranet].[dbo].Cesta_Compras where idSession = '1LBOHFQ3QCHDSN8U9DQK'
	
	select * from [192.168.0.6].[Intranet].[dbo].Cesta_Compras_Itens where idcesta = 1676798  and plu = 1034800
	
	select * from [192.168.0.6].[zeus_rtg].dbo.tab_pedido_produto where num_pedido = 1440914 and COD_PRODUTO = 1034800
	
	
