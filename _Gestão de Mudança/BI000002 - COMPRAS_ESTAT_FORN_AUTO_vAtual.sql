USE [BI]
GO
/****** Object:  StoredProcedure [dbo].[COMPRAS_ESTAT_FORN_AUTO]    Script Date: 02/16/2016 11:48:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ---------------------------------------------------------------------------------------------------------------------------------------
-- VERSÂO DE PRODUÇÃO PEDIDOS AUTOMATICOS
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- EXEC [COMPRAS_ESTAT_FORN_AUTO] 444,'1,2,3,6,7,9,10,12,13,17,18,19,20,21,30'
-- EXEC [COMPRAS_ESTAT_FORN_AUTO] 1022, '1,2,3,6,7,9,10,12,13,17,18,19,20,21,30,31'
-- EXEC [COMPRAS_ESTAT_FORN_AUTO] 103241, '1'

--exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  '1', 18055 , null , null , 0 , 1022

ALTER PROCEDURE [dbo].[COMPRAS_ESTAT_FORN_AUTO]
	 @FORN [INT]
	,@ARRAY_LOJAS VARCHAR(80)
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ID_ROTINA AS INT = 1
	DECLARE @DATA_INI_ROTINA AS DATETIME = GETDATE()
	DECLARE @TEMPO AS NUMERIC(18,2)
	DECLARE @PARAMETROS_ROTINA AS VARCHAR(150)
	SET @PARAMETROS_ROTINA = 
		'@FORN: ' + CONVERT(VARCHAR(10),@FORN)
		+ ' | @COD_LOJA: ' + @ARRAY_LOJAS	
	
	DECLARE @QTD_LINHAS as int	
	declare @DEBUG as int = 1
    declare @DEBUG_HORA as Datetime = getdate()
    declare @DEBUG_HORA_FIM as Datetime = getdate()
    Declare @MensagemdeErro as varchar(max)
    Declare @NumeroErro as int
	
	DECLARE @DEBUGTEMPO AS INT = 1
	
	DECLARE @DATA_INI_PROC AS DATETIME
	SET @DATA_INI_PROC = GETDATE()

	DECLARE @ARRAY_DEP AS VARCHAR(80) = NULL
	DECLARE @ARRAY_SECAO AS VARCHAR(80) = NULL
	
	DECLARE @FORN_PEDIDO AS INT = @FORN
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Verificando se é centralizado
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	IF EXISTS
	(
		SELECT TOP 1 1 FROM AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL WITH(NOLOCK)
		WHERE 1=1
		AND FORNECEDOR_CD = @FORN
		AND COD_FornecedoR = 18055
		AND ModelArmazenagem = 0
		AND COD_LOJA IN ( select ITEM from [dbo].[fnSplit](@ARRAY_LOJAS,',') )
	)
	BEGIN
		
		SELECT TOP 1 @FORN_PEDIDO = COD_Fornecedor  FROM AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL WITH(NOLOCK) 
		WHERE 1=1
		AND FORNECEDOR_CD = @FORN
		AND COD_Fornecedor = 18055
		AND ModelArmazenagem = 0
		AND COD_LOJA IN ( select ITEM from [dbo].[fnSplit](@ARRAY_LOJAS,',') )

	END
	
	PRINT '@FORN: ' + CONVERT(VARCHAR,@FORN)
	PRINT '@FORN_PEDIDO: ' + CONVERT(VARCHAR,@FORN_PEDIDO)
	
	--exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  @ARRAY_LOJAS, @FORN_PEDIDO , @ARRAY_DEP , @ARRAY_SECAO , 0 , @FORN
	-- #####################################################################################################################################################################
	-- CREATE TEMPORARY TABLE
	-- #####################################################################################################################################################################
	IF OBJECT_ID('TEMPDB.DBO.#TAB_RETORNO') IS NOT NULL DROP TABLE #TAB_RETORNO
	
	CREATE TABLE  #TAB_RETORNO
	(
		[COD_LOJA] INT
		,[COD_PRODUTO] INT
		,[COD_DEPARTAMENTO] INT
		,[COD_SECAO] INT 		
		,[QTD_EST_ATUAL]  NUMERIC(18,3)
		,[QTD_EMBALAGEM_COMPRA] NUMERIC(18,3)
		,[QTD_MULTIPLO_EMB] NUMERIC(18,3) --QTD_MINIMA_COMPRA
		,[AVG_QTD_U30D_PD] NUMERIC(18,3)
		,[QTD_QUEBRA_3M] NUMERIC(18,3)--QTD_QUEBRA_PERC_3M
		,[ABC] VARCHAR(5)
		,[VAL_CUSTO_EMBALAGEM] NUMERIC(18,3)
		,[DES_UNIDADE_VENDA]   VARCHAR(10)
		,[DES_UNIDADE_COMPRA]  VARCHAR(10)
		--CAMPOS NAO USADOS
		,ITEMID INT
		,COD_FORNECEDOR INT
		,DES_REFERENCIA VARCHAR(50)
		,FORA_MIX VARCHAR(5)
		,ENVIA_PDV VARCHAR(5)
		,QTD_EST_CD NUMERIC(18,2)
		,COD_FORNECEDOR_PREFERENCIAL INT
		,TIPO_ABASTECIMENTO INT
		,FLG_COMPRA INT
	)
	CREATE CLUSTERED INDEX IX_TBRETORNOCALC ON #TAB_RETORNO (COD_LOJA, COD_PRODUTO)
	
	-- #####################################################################################################################################################################
	-- INSERT
	-- #####################################################################################################################################################################
		IF @FORN_PEDIDO = 18055
			BEGIN
				INSERT INTO #TAB_RETORNO (ITEMID, COD_FORNECEDOR , COD_PRODUTO ,COD_LOJA , DES_REFERENCIA , FORA_MIX , ENVIA_PDV , QTD_EST_CD , COD_FORNECEDOR_PREFERENCIAL , TIPO_ABASTECIMENTO)
				exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  @ARRAY_LOJAS, @FORN_PEDIDO , @ARRAY_DEP , @ARRAY_SECAO , 0 , @FORN
			END
		ELSE
			BEGIN
				INSERT INTO #TAB_RETORNO (ITEMID,COD_FORNECEDOR , COD_PRODUTO ,COD_LOJA , DES_REFERENCIA , FORA_MIX , ENVIA_PDV , QTD_EST_CD , COD_FORNECEDOR_PREFERENCIAL , TIPO_ABASTECIMENTO)
				exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  @ARRAY_LOJAS, @FORN_PEDIDO , @ARRAY_DEP , @ARRAY_SECAO , 0 
			END
		
		DELETE FROM #TAB_RETORNO WHERE FORA_MIX <> 'N'
		
		
		print master.dbo.FN_TEMPO_DE_PROCESSO(@DEBUG , @DEBUG_HORA , ' Insert inicial ')  
		set @DEBUG_HORA = getdate()
		
		select @QTD_LINHAS = COUNT(cod_produto) from #TAB_RETORNO	
		print 'Linhas na tabela Inicio: ' + convert(varchar,@QTD_LINHAS)
		
--PRINT 'Insert inicial'
--PRINT DATEDIFF(S,@DATA_INI_PROC,GETDATE())
--SET @DATA_INI_PROC = GETDATE()

	-- #####################################################################################################################################################################
	-- Removendo Produtos QUE NAO SÃO CENTRALIZADOS
	-- #####################################################################################################################################################################		
	IF @FORN_PEDIDO = 18055
		BEGIN
			IF OBJECT_ID('TEMPDB.DBO.#TAB_PROD_CENTRALIZADO') IS NOT NULL DROP TABLE #TAB_PROD_CENTRALIZADO
			CREATE TABLE #TAB_PROD_CENTRALIZADO
			(
				[COD_LOJA] INT
				,[COD_PRODUTO] INT
			)
			CREATE CLUSTERED INDEX IX_TAB_PROD_CENTRALIZADO ON #TAB_PROD_CENTRALIZADO (COD_LOJA,COD_PRODUTO)
			
			INSERT INTO #TAB_PROD_CENTRALIZADO	
				SELECT
					COD_LOJA
					,COD_PRODUTO
				FROM AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL WITH(NOLOCK)
				WHERE 1=1
					AND FORNECEDOR_CD = @FORN
					AND COD_Fornecedor = 18055
					AND ModelArmazenagem = 0
			
			DELETE L
			FROM
				#TAB_RETORNO AS L 
				LEFT JOIN #TAB_PROD_CENTRALIZADO AS PC
					ON 1=1
					AND L.COD_LOJA = PC.COD_LOJA
					AND L.COD_PRODUTO = PC.COD_PRODUTO			
			WHERE 1=1
				AND PC.COD_PRODUTO IS NULL
		END

PRINT 'delete caso nao centralizado'
PRINT DATEDIFF(S,@DATA_INI_PROC,GETDATE())
SET @DATA_INI_PROC = GETDATE()

select @QTD_LINHAS = COUNT(cod_produto) from #TAB_RETORNO	
print 'Linhas na tabela - delete caso nao centralizado: ' + convert(varchar,@QTD_LINHAS)

	-- #####################################################################################################################################################################
	-- CHECK WMS ERROR
	-- #####################################################################################################################################################################				
		IF @FORN_PEDIDO = 18055
		BEGIN
			EXEC WMS.DBO.WMS_CHECKLIST_CENTRALIZACAO @FORN
		
			DELETE L
			FROM
				#TAB_RETORNO AS L 
				INNER JOIN [WMS].[dbo].[TAB_CHECKLIST_CENTRALIZACAO] AS WMS_CHECK
					ON 1=1
					AND WMS_CHECK.FORNECEDOR_CODIGO = @FORN
					AND WMS_CHECK.LOJA_FORNECEDOR_PRINCIPAL = @FORN_PEDIDO
					AND L.COD_PRODUTO = WMS_CHECK.itemid
			WHERE 1=1
				AND WMS_CHECK.MENSAGEM IS NOT NULL		
		END
		
PRINT 'delete caso centralizado e com erro'
PRINT DATEDIFF(S,@DATA_INI_PROC,GETDATE())
SET @DATA_INI_PROC = GETDATE()	

select @QTD_LINHAS = COUNT(cod_produto) from #TAB_RETORNO	
print 'Linhas na tabela - delete caso centralizado e com erro: ' + convert(varchar,@QTD_LINHAS)
		
	-- #####################################################################################################################################################################
	-- UPDATES
	-- #####################################################################################################################################################################				
	
	-- ----------------------
	-- AX
	-- ----------------------
		UPDATE R
		SET
			R.DES_UNIDADE_COMPRA = COMPRA.UNITID	
		FROM
			SMA_AX50_SP1_DB_PROD.DBO.INVENTTABLEMODULE AS COMPRA WITH (NOLOCK) INNER JOIN #TAB_RETORNO AS R ON (R.COD_PRODUTO = COMPRA.[ITEMID])
		WHERE 1 = 1
			AND COMPRA.MODULETYPE = 1
			AND COMPRA.DATAAREAID = 'BAR'
		
		UPDATE R
		SET
			R.DES_UNIDADE_VENDA = VENDA.UNITID	
		FROM
			SMA_AX50_SP1_DB_PROD.DBO.INVENTTABLEMODULE AS VENDA WITH (NOLOCK) INNER JOIN #TAB_RETORNO AS R ON (R.COD_PRODUTO = VENDA.[ITEMID])
		WHERE 1 = 1
			AND VENDA.MODULETYPE = 2
			AND VENDA.DATAAREAID = 'BAR'

		UPDATE R
		SET 
			R.QTD_EMBALAGEM_COMPRA = UNID.MARCHEQTDEMBALAGEM
			,R.QTD_MULTIPLO_EMB  = UNID.MARCHEMULTIPLO
			,R.DES_UNIDADE_COMPRA  = UNID.MARCHEUNITID
		FROM
			AX2009_INTEGRACAO.DBO.TAB_PRODUTO_REFERENCIA   AS UNID WITH (NOLOCK) INNER JOIN #TAB_RETORNO AS R ON (UNID.COD_FORNECEDOR = @FORN_PEDIDO AND UNID.ITEMID = R.COD_PRODUTO)
		WHERE 1 = 1
		
		UPDATE R
		SET 
			R.QTD_EST_ATUAL = L.QTD_ESTOQUE
		FROM
			BI.DBO.VW_ESTOQUE_ATUAL AS L --WITH (NOLOCK) Alterado por Frade: 09/06/2015
			INNER JOIN #TAB_RETORNO AS R ON (R.COD_LOJA =  L.COD_LOJA AND cast(R.COD_PRODUTO as double precision) =  L.COD_PRODUTO )		
		WHERE 1 = 1		
	
PRINT 'Updates AX'
PRINT DATEDIFF(S,@DATA_INI_PROC,GETDATE())
SET @DATA_INI_PROC = GETDATE()

	-- ----------------------
	-- BI
	-- ----------------------
		UPDATE R
		SET
			R.COD_DEPARTAMENTO = CP.COD_DEPARTAMENTO
			,R.COD_SECAO = CP.COD_SECAO
		FROM
			#TAB_RETORNO AS R INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP ON (R.COD_PRODUTO = CP.COD_PRODUTO)	

PRINT 'Updates BI'
PRINT DATEDIFF(S,@DATA_INI_PROC,GETDATE())	
SET @DATA_INI_PROC = GETDATE()

	-- ----------------------
	-- ZEUS
	-- ----------------------
		IF OBJECT_ID('TEMPDB.DBO.#TAB_FORN_ZEUS') IS NOT NULL DROP TABLE #TAB_FORN_ZEUS
		CREATE TABLE #TAB_FORN_ZEUS
		(
			COD_LOJA INT
			,COD_PRODUTO INT
			,VAL_CUSTO_EMBALAGEM NUMERIC(18,2)
		)
		CREATE CLUSTERED INDEX IX_TAB_FORN_ZEUS ON #TAB_FORN_ZEUS (COD_LOJA,COD_PRODUTO)
	
		INSERT INTO #TAB_FORN_ZEUS
		SELECT
			P.COD_LOJA
			,P.COD_PRODUTO
			,p.VAL_CUSTO_EMBALAGEM
			--,L.QTD_EST_ATUAL
		FROM
			[192.168.0.6].[ZEUS_RTG].[DBO].[TAB_PRODUTO_FORNECEDOR] AS P WITH (NOLOCK)
				INNER JOIN [192.168.0.6].[ZEUS_RTG].[DBO].[TAB_PRODUTO_LOJA] AS L WITH (NOLOCK)
					ON 1=1
					AND P.COD_LOJA = L.COD_LOJA
					AND P.COD_PRODUTO = L.COD_PRODUTO
		WHERE 1=1
			AND P.[COD_LOJA] IN ( select ITEM from [dbo].[fnSplit](@ARRAY_LOJAS,',') )
			AND P.COD_FORNECEDOR = @FORN_PEDIDO
		
		UPDATE R
		SET 
			 R.VAL_CUSTO_EMBALAGEM = L.VAL_CUSTO_EMBALAGEM
			 --,R.QTD_EST_ATUAL = L.[QTD_EST_ATUAL]
		FROM 
			#TAB_RETORNO AS R
			INNER JOIN #TAB_FORN_ZEUS AS L
				ON 1=1
				AND R.COD_LOJA = L.COD_LOJA
				AND R.COD_PRODUTO = L.COD_PRODUTO		
		
PRINT 'Updates Zeus'
PRINT DATEDIFF(S,@DATA_INI_PROC,GETDATE())	
SET @DATA_INI_PROC = GETDATE()
					
	-- #####################################################################################################################################################################
	-- Removendo Produtos Sem Custo
	-- 03/09
	-- Marcelo Frade
	-- #####################################################################################################################################################################	
		delete from #TAB_RETORNO where isnull(VAL_CUSTO_EMBALAGEM,0) = 0 

PRINT 'Delete Sem Custo'
PRINT DATEDIFF(S,@DATA_INI_PROC,GETDATE())
SET @DATA_INI_PROC = GETDATE()

	-- #####################################################################################################################################################################
	-- Limitando compra para apenas produtos A1, A2, NOTAVEL E ULTRA
	-- #####################################################################################################################################################################
		DECLARE @TAB_PRODUTOS_N_UN AS TABLE
		(
			COD_PRODUTO INT
		)

		INSERT INTO @TAB_PRODUTOS_N_UN
		SELECT DISTINCT
			COD_PRODUTO
		FROM
			BI.DBO.CADASTRO_CAD_PRODUTO_METADADOS AS PM
		WHERE 1=1 
			AND COD_METADADO IN (16,17) AND VLR_METADADO = '1'
			
PRINT 'Buscando apenas NOTAVEL E ULTRA' + convert(varchar,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
SET @DATA_INI_PROC = GETDATE()


	-- #####################################################################################################################################################################
	-- Mantendo apenas itens 'A1','A2','A3','B' para compras
	-- #####################################################################################################################################################################
	
	--Liberando Hortus
	UPDATE #TAB_RETORNO SET FLG_COMPRA = 1 WHERE COD_LOJA in (7,29)
	
	--Liberando 'A1','A2','A3','B'
	/*
	update R
	set
		FLG_COMPRA = 1
	from
		#TAB_RETORNO AS R 
		INNER JOIN BI.dbo.BI_LINHA_PRODUTOS AS LP
			ON 1=1
			AND R.COD_LOJA = LP.COD_LOJA
			AND R.COD_PRODUTO = LP.COD_PRODUTO
	where 1=1
		AND R.COD_LOJA <> 7
		AND LP.CLASSIF_PRODUTO_LOJA IN ('A1','A2','A3','B')
	*/

	update R
	set
		FLG_COMPRA = 1
	from
		#TAB_RETORNO AS R 
		INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON R.COD_PRODUTO = CP.COD_PRODUTO
	where 1=1
		AND R.COD_LOJA not in (7,29)
		AND CP.[CLASSIF_PRODUTO_SUPPLY] IN ('A1','A2','A3','B')

	--Liberando Notavel e ultra
	update R
	set
		FLG_COMPRA = 1
	from
		#TAB_RETORNO AS R 
		INNER JOIN @TAB_PRODUTOS_N_UN AS NT
			ON 1=1
			AND R.COD_PRODUTO = NT.COD_PRODUTO
	where 1=1
	
	--Bloqueando ADEGA para todas as lojas menos Hortus
	update R
	set
		FLG_COMPRA = NULL
	from
		#TAB_RETORNO AS R 
		INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON 1=1
			AND R.COD_PRODUTO = CP.COD_PRODUTO
		INNER JOIN BI.dbo.BI_LINHA_PRODUTOS AS LP
			ON 1=1
			AND R.COD_PRODUTO = LP.COD_PRODUTO
			AND R.COD_LOJA = LP.COD_LOJA
	where 1=1
		AND R.COD_LOJA not in (7,29)
		AND CP.COD_DEPARTAMENTO = 2
		AND LP.CLASSIF_PRODUTO_LOJA NOT IN ('A1','A2','A3')

	DELETE FROM #TAB_RETORNO WHERE FLG_COMPRA IS NULL
	
	
PRINT 'Buscando apenas NOTAVEL E ULTRA A1,A2,A3,B ' + convert(varchar,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
SET @DATA_INI_PROC = GETDATE()

select @QTD_LINHAS = COUNT(cod_produto) from #TAB_RETORNO	
print 'Linhas na tabela Final: ' + convert(varchar,@QTD_LINHAS)
	

	-- #####################################################################################################################################################################
	-- FINAL SELECT
	-- #####################################################################################################################################################################	
		SELECT
			--|||Essenciais|||
			 L.COD_LOJA
			,L.COD_PRODUTO
			,ISNULL(L.QTD_EST_ATUAL,0) AS QTD_EST_ATUAL
			,0 as QTD_EST_TRANSITO
			--,isnull(E.AVG_QTD_U180D_ESTOQUE_PD,0) as AVG_QTD_U30D_PD
			,isnull(E.AVG_QTD_U90D_PD,0) as AVG_QTD_U30D_PD
			,isnull(L.QTD_EMBALAGEM_COMPRA,1) AS QTD_EMB_COMPRA
			,isnull(L.QTD_MULTIPLO_EMB,1) as QTD_MULT_EMB
			,P.[DIA_SS] as QTD_SS_DIAS -- Os nullos são tratados no Mathematica, pois veem da agenda executada
			,isnull(P.[FAT_SZ],1) as FAT_SAZ
			,isnull(P.[QTD_EXP],0) as QTD_MIN_UN						
			--|||Acessórios|||
			,ISNULL(E.QTD_QUEBRA_PERC_3M,0) AS QTD_QUEBRA_3M
			,L.COD_DEPARTAMENTO
			,L.COD_SECAO
			,ISNULL(E.CLASSIF_PRODUTO_LOJA, 'Z') AS ABC_VLR
			,L.[VAL_CUSTO_EMBALAGEM]
			,L.DES_UNIDADE_VENDA
			,L.DES_UNIDADE_COMPRA
			--,(CASE WHEN @FORN = 102778 THEN isnull(afp.COD_Fornecedor,@FORN) ELSE @FORN END) as FORN_PRINCIPAL_AX
			,@FORN_PEDIDO AS FORN_PRINCIPAL_AX
			,(CASE
				WHEN afp.ModelArmazenagem = 0 THEN 'Direto'
				WHEN afp.ModelArmazenagem = 1 THEN 'CrossDocking'
				WHEN afp.ModelArmazenagem = 2 THEN 'Armazenagem'
				WHEN afp.ModelArmazenagem = 3 THEN 'PickingUnitario'
			END) AS TIPO_ABASTECIMENTO
			--,PB.COD_PRODUTO AS BLOQ_LOJA
			--,PBF.COD_PRODUTO AS BLOQ_FORN
			,L.FLG_COMPRA
		FROM
			#TAB_RETORNO AS L
			INNER JOIN [BI].[dbo].[SUPPLY_PRODUTO_FORN_PRINCIPAL_AUTO] AS PFP
				ON 1=1
				AND PFP.COD_FORNECEDOR = @FORN
				AND L.COD_PRODUTO = PFP.COD_PRODUTO
			--LEFT JOIN @TAB_PRODUTOS_N_UN AS NOTAVEL_ULTRA
			--	ON L.COD_PRODUTO = NOTAVEL_ULTRA.COD_PRODUTO
			LEFT JOIN DBO.COMPRAS_ESTATISTICA_PRODUTO AS E
				ON 1=1
				AND L.COD_LOJA = E.COD_LOJA
				AND L.COD_PRODUTO = E.COD_PRODUTO
			LEFT JOIN BI.DBO.COMPRAS_DNV_CALCULADORA AS DNV
				ON 1=1
				AND DNV.COD_LOJA = L.COD_LOJA
				AND DNV.COD_PRODUTO = L.COD_PRODUTO
				AND DNV.DATA_GRAVACAO = CONVERT(DATE,GETDATE())
			LEFT JOIN [BI].[dbo].[COMPRA_PRODUTO_PARAMETRO] AS P
				ON 1=1
				AND L.COD_LOJA = P.COD_LOJA
				AND L.COD_PRODUTO = P.COD_PRODUTO			
			LEFT JOIN [BI].[dbo].[SUPPLY_PRODUTO_BLOQUEADO_LOJA_AUTO] AS PB
				ON 1=1
				--AND L.COD_LOJA = PB.COD_LOJA
				AND L.COD_PRODUTO = PB.COD_PRODUTO
			--LEFT JOIN [BI].[dbo].[SUPPLY_PRODUTO_BLOQUEADO_FORN_AUTO] AS PBF
			--	ON 1=1
			--	AND PBF.COD_FORNECEDOR = @FORN
			--	AND L.COD_PRODUTO = PBF.COD_PRODUTO			
			LEFT JOIN AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL AS AFP
				ON 1=1
				AND L.COD_LOJA = AFP.COD_LOJA
				AND L.COD_PRODUTO = AFP.COD_PRODUTO			
		WHERE 1=1
			--AND NOTAVEL_ULTRA.COD_PRODUTO IS NOT NULL OR E.CLASSIF_PRODUTO_LOJA IN ('A1','A2','A3','B')
			AND PB.COD_PRODUTO IS NULL
		ORDER BY
			E.CLASSIF_PRODUTO_LOJA
	
	SET @TEMPO = DATEDIFF(S,@DATA_INI_ROTINA,GETDATE())
	
	EXEC BI.DBO.BI_LOG 
		@ID_ROTINA
		,@DATA_INI_ROTINA
		,@TEMPO
		,@PARAMETROS_ROTINA
END
