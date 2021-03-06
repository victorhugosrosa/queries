USE [BI]
GO
/****** Object:  StoredProcedure [dbo].[SUPPLY_STOCK_DATA_READ_DEV]    Script Date: 05/11/2017 17:00:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ---------------------------------------------------------------------------------------------------------------------------------------
-- VERSÂO DE PRODUÇÃO PEDIDOS AUTOMATICOS
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- EXEC [SUPPLY_STOCK_DATA_READ_DEV] 444,'1,2,3,6,7,9,10,12,13,17,18,19,20,21,30,31', NULL, NULL, 1
-- EXEC [SUPPLY_STOCK_DATA_READ_DEV] 103419, '1,2,3,6,7,9,10,12,13,17,18,19,20,21,30,31', NULL, NULL, 3
-- EXEC [SUPPLY_STOCK_DATA_READ_DEV] 18055, '18,21,22,25', NULL, NULL, 2
-- EXEC [SUPPLY_STOCK_DATA_READ_DEV] 103585, '3', '4', '44;45;47;48;46', 4

--exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  '1', 18055 , null , null , 0 , 101870
--exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  '1', 102778 , null , null , 1

--select * from compras_agenda_pedido_auto where tipo = 1 and flg_ativo = 1 and id = 108

ALTER PROCEDURE [dbo].[SUPPLY_STOCK_DATA_READ_DEV]
	 @FORN [INT]
	,@ARRAY_LOJAS VARCHAR(80)
	,@ARRAY_DEP VARCHAR(80) = NULL
	,@ARRAY_SECAO VARCHAR(80) = NULL
	,@TIPO_PEDIDO INT = NULL
	,@ID_AGENDA INT = NULL
	
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;
	/* @TIPO_PEDIDO
		1 Normal
		2 CD-Loja
		3 CD-Forn	
		4 FLV
	*/
	DECLARE @ID_ROTINA AS INT = 1
	DECLARE @DATA_INI_ROTINA AS DATETIME = GETDATE()
	DECLARE @TEMPO AS NUMERIC(18,4)
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
	
	DECLARE @FORN_PEDIDO AS INT = @FORN
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Verificando se é centralizado
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	if @TIPO_PEDIDO = 1
	BEGIN
		IF EXISTS
		(
			SELECT TOP 1 1 FROM AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL WITH(NOLOCK)
			WHERE 1=1
			--AND FORNECEDOR_CD = @FORN
			AND COD_FornecedoR = @FORN
			AND ModelArmazenagem = 1
			AND COD_LOJA = 5
			--AND COD_LOJA IN ( select ITEM from [dbo].[fnSplit](@ARRAY_LOJAS,',') )
		)
		BEGIN
			
			SELECT TOP 1 @FORN_PEDIDO = COD_Fornecedor  FROM AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL WITH(NOLOCK) 
			WHERE 1=1
			AND FORNECEDOR_CD = @FORN
			AND COD_Fornecedor = 18055
			AND ModelArmazenagem = 0
			AND COD_LOJA IN ( select ITEM from [dbo].[fnSplit](@ARRAY_LOJAS,',') )

			exec integracoes.dbo.CADASTRO_AUTOMATICO_50
			exec integracoes.dbo.CADASTRO_AUTOMATICO_60 @FORN
			
		END
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
		,[QTD_EST_ATUAL]  NUMERIC(18,4)
		,[QTD_EMBALAGEM_COMPRA] NUMERIC(18,4)
		,[QTD_MULTIPLO_EMB] NUMERIC(18,4) --QTD_MINIMA_COMPRA
		,[AVG_QTD_U30D_PD] NUMERIC(18,4)
		,[QTD_QUEBRA_3M] NUMERIC(18,4)--QTD_QUEBRA_PERC_3M
		,[ABC] VARCHAR(5)
		,[VAL_CUSTO_EMBALAGEM] NUMERIC(18,4)
		,[DES_UNIDADE_VENDA]   VARCHAR(10)
		,[DES_UNIDADE_COMPRA]  VARCHAR(10)
		--CAMPOS NAO USADOS
		,ITEMID INT
		,COD_FORNECEDOR INT
		,DES_REFERENCIA VARCHAR(50)
		,FORA_MIX VARCHAR(5)
		,ENVIA_PDV VARCHAR(5)
		,QTD_EST_CD NUMERIC(18,4)
		,COD_FORNECEDOR_PREFERENCIAL INT
		,TIPO_ABASTECIMENTO INT
		,FLG_COMPRA INT
		,QTD_ESTOQUE_CD NUMERIC(18,4)
		,QTD_CAMADA_PLT INT NULL
		,QTD_CX_CAMADA_PLT INT NULL
		,ERRO_CENTRALIZACAO VARCHAR(1000)
		,FORNECEDOR_PRINCIPAL INT NULL
		,FLG_ERRO_TIPO_ABASTECIMENTO INT
		,FLG_ERRO_SEM_CUSTO INT
		,FLG_ERRO_CONVERSAO_UNIDADE INT
		,FLG_BLOQUEADO_SUPPLY INT
		,FLG_ERRO_SEM_REFERENCIA INT
		,QTD_EST_TRANSITO NUMERIC(18,4)
		
		,FLG_PICKING_UN INT NULL
		,QTD_EMBALAGEM_FORN NUMERIC(18,4) NULL
		,QTD_MULTIPLO_FORN NUMERIC(18,4) NULL		
	)
	CREATE CLUSTERED INDEX IX_TBRETORNOCALC ON #TAB_RETORNO (COD_LOJA, COD_PRODUTO)
	
	-- #####################################################################################################################################################################
	-- INSERT
	-- #####################################################################################################################################################################
		IF @FORN_PEDIDO = 18055 AND @FORN <> 18055 AND @TIPO_PEDIDO = 1 --CENTRALIZADO
			BEGIN
				PRINT 'SELECT CENTRALIZADO'
				INSERT INTO #TAB_RETORNO (ITEMID, COD_FORNECEDOR , COD_PRODUTO ,COD_LOJA , DES_REFERENCIA , FORA_MIX , ENVIA_PDV , QTD_EST_CD , COD_FORNECEDOR_PREFERENCIAL , TIPO_ABASTECIMENTO)
				exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  @ARRAY_LOJAS, @FORN_PEDIDO , @ARRAY_DEP , @ARRAY_SECAO , 0 , @FORN
			END
					
		IF @TIPO_PEDIDO = 2 --CD->LOJA
			BEGIN
				PRINT 'SELECT CD->LOJA'
				INSERT INTO #TAB_RETORNO (ITEMID,COD_FORNECEDOR , COD_PRODUTO ,COD_LOJA , DES_REFERENCIA , FORA_MIX , ENVIA_PDV , QTD_EST_CD , COD_FORNECEDOR_PREFERENCIAL , TIPO_ABASTECIMENTO)
				exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  @ARRAY_LOJAS, @FORN_PEDIDO , @ARRAY_DEP , @ARRAY_SECAO , 1
			END
		
		IF @TIPO_PEDIDO = 3 --CD->FORN
			BEGIN
				PRINT 'SELECT CD->FORN'
				INSERT INTO #TAB_RETORNO (ITEMID,COD_FORNECEDOR , COD_PRODUTO ,COD_LOJA , DES_REFERENCIA , FORA_MIX , ENVIA_PDV , QTD_EST_CD , COD_FORNECEDOR_PREFERENCIAL , TIPO_ABASTECIMENTO)
				exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  @ARRAY_LOJAS, @FORN , @ARRAY_DEP , @ARRAY_SECAO , 0
			END
		
		IF @FORN_PEDIDO <> 18055 AND @FORN <> 18055 AND @TIPO_PEDIDO = 1 --NORMAL
			BEGIN
				PRINT 'SELECT NORMAL'
				INSERT INTO #TAB_RETORNO (ITEMID,COD_FORNECEDOR , COD_PRODUTO ,COD_LOJA , DES_REFERENCIA , FORA_MIX , ENVIA_PDV , QTD_EST_CD , COD_FORNECEDOR_PREFERENCIAL , TIPO_ABASTECIMENTO)
				exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  @ARRAY_LOJAS, @FORN_PEDIDO , @ARRAY_DEP , @ARRAY_SECAO , 0 
			END		
		
		IF @TIPO_PEDIDO = 4 --FLV
			BEGIN
				PRINT 'SELECT FLV'
				INSERT INTO #TAB_RETORNO (ITEMID,COD_FORNECEDOR , COD_PRODUTO ,COD_LOJA , DES_REFERENCIA , FORA_MIX , ENVIA_PDV , QTD_EST_CD , COD_FORNECEDOR_PREFERENCIAL , TIPO_ABASTECIMENTO)
				exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  @ARRAY_LOJAS, @FORN_PEDIDO , @ARRAY_DEP , @ARRAY_SECAO , 0 
			END
		
		DELETE FROM #TAB_RETORNO WHERE FORA_MIX <> 'N'
		
		
		print master.dbo.FN_TEMPO_DE_PROCESSO(@DEBUG , @DEBUG_HORA , ' Insert inicial ')  
		set @DEBUG_HORA = getdate()
		
		select @QTD_LINHAS = COUNT(cod_produto) from #TAB_RETORNO	
		print 'Linhas na tabela Inicio: ' + convert(varchar,@QTD_LINHAS)

	--SELECT 9, * FROM #TAB_RETORNO AS L WHERE 1=1 --and COD_PRODUTO = 583831
	
	-- #####################################################################################################################################################################
	-- Removendo Produtos QUE NAO SÃO CENTRALIZADOS
	-- #####################################################################################################################################################################		
	IF @FORN_PEDIDO = 18055 and @TIPO_PEDIDO = 1
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
			
			
			--UPDATE L
			--SET
			--	L.FLG_ERRO_TIPO_ABASTECIMENTO = 1
			DELETE L
			FROM
				#TAB_RETORNO AS L 
				LEFT JOIN #TAB_PROD_CENTRALIZADO AS PC
					ON 1=1
					AND L.COD_LOJA = PC.COD_LOJA
					AND L.COD_PRODUTO = PC.COD_PRODUTO			
			WHERE 1=1
				AND PC.COD_PRODUTO IS NULL
				
			PRINT 'delete caso nao centralizado' + CONVERT(VARCHAR,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
			SET @DATA_INI_PROC = GETDATE()
			
			select @QTD_LINHAS = COUNT(cod_produto) from #TAB_RETORNO	
			print 'Linhas na tabela - delete caso nao centralizado: ' + convert(varchar,@QTD_LINHAS)
				
		END
	
	--SELECT 8, * FROM #TAB_RETORNO AS L WHERE 1=1 --and COD_PRODUTO = 583831

	-- #####################################################################################################################################################################
	-- CHECK WMS ERROR
	-- #####################################################################################################################################################################				
		IF @FORN_PEDIDO = 18055 and @TIPO_PEDIDO = 1
		BEGIN
			EXEC WMS.DBO.WMS_CHECKLIST_CENTRALIZACAO @FORN
		
			UPDATE L
			SET
				L.ERRO_CENTRALIZACAO = WMS_CHECK.MENSAGEM
			FROM
				#TAB_RETORNO AS L 
				INNER JOIN [WMS].[dbo].[TAB_CHECKLIST_CENTRALIZACAO] AS WMS_CHECK
					ON 1=1
					AND WMS_CHECK.FORNECEDOR_CODIGO = @FORN
					AND WMS_CHECK.LOJA_FORNECEDOR_PRINCIPAL = @FORN_PEDIDO
					AND L.COD_PRODUTO = WMS_CHECK.itemid
			WHERE 1=1
				AND WMS_CHECK.MENSAGEM IS NOT NULL				
			
			PRINT 'marcando produtos centralizado e com erro' + CONVERT(VARCHAR,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
			SET @DATA_INI_PROC = GETDATE()

			--select @QTD_LINHAS = COUNT(cod_produto) from #TAB_RETORNO	
			--print 'Linhas na tabela - delete caso centralizado e com erro: ' + convert(varchar,@QTD_LINHAS)				
		END
	
	--SELECT 7, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 583831
		
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
			,R.QTD_EMBALAGEM_FORN = UNID.MARCHEQTDEMBALAGEM
			,R.QTD_MULTIPLO_FORN = UNID.MARCHEMULTIPLO
		FROM
			AX2009_INTEGRACAO.DBO.TAB_PRODUTO_REFERENCIA   AS UNID WITH (NOLOCK) INNER JOIN #TAB_RETORNO AS R ON (UNID.COD_FORNECEDOR = @FORN_PEDIDO AND UNID.ITEMID = R.COD_PRODUTO)
		WHERE 1 = 1
		
		IF @TIPO_PEDIDO <> 4
		BEGIN
			UPDATE R
			SET 
				R.QTD_EST_ATUAL = L.QTD_ESTOQUE
			FROM
				BI.DBO.VW_ESTOQUE_ATUAL AS L --WITH (NOLOCK) Alterado por Frade: 09/06/2015
				INNER JOIN #TAB_RETORNO AS R ON (R.COD_LOJA =  L.COD_LOJA AND cast(R.COD_PRODUTO as double precision) =  L.COD_PRODUTO )		
			WHERE 1 = 1		
		END
		
		IF @TIPO_PEDIDO = 4
		BEGIN
			UPDATE R
			SET 
				R.QTD_EST_ATUAL = L.QTD_ESTOQUE
			FROM
				BI.DBO.COMPRAS_ESTOQUE_FLV AS L --WITH (NOLOCK) Alterado por Frade: 09/06/2015
				INNER JOIN #TAB_RETORNO AS R ON (R.COD_LOJA =  L.COD_LOJA AND cast(R.COD_PRODUTO as double precision) =  L.COD_PRODUTO )		
			WHERE 1 = 1	
		END
		
PRINT 'Tempo - Updates AX: ' + CONVERT(VARCHAR,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
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

PRINT 'Tempo - Updates BI: ' + CONVERT(VARCHAR,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
SET @DATA_INI_PROC = GETDATE()

	-- ----------------------
	-- ZEUS
	-- ----------------------
		IF OBJECT_ID('TEMPDB.DBO.#TAB_FORN_ZEUS') IS NOT NULL DROP TABLE #TAB_FORN_ZEUS
		CREATE TABLE #TAB_FORN_ZEUS
		(
			COD_LOJA INT
			,COD_PRODUTO INT
			,VAL_CUSTO_EMBALAGEM NUMERIC(18,4)
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
		
PRINT 'Tempo - Updates Zeus: ' + CONVERT(VARCHAR,DATEDIFF(S,@DATA_INI_PROC,GETDATE())	)
SET @DATA_INI_PROC = GETDATE()
	
	-- ------------------------------------------------------------------------------
	-- ESTOQUE CD
	-- ------------------------------------------------------------------------------
	DECLARE @TAB_ESTOQUE_CD AS TABLE
	(
		COD_PRODUTO INT
		,QTD_ESTOQUE_CD NUMERIC(18,4)
	)
	
	INSERT INTO @TAB_ESTOQUE_CD
	select CD_PRODUTO, SUM(CONVERT(NUMERIC(18,4),QT_ESTOQUE)) from WMS.dbo.V_ESTOQUE_ERP group by CD_PRODUTO
		
	UPDATE R
		SET 
			 R.QTD_ESTOQUE_CD = T.QTD_ESTOQUE_CD
			 --,R.QTD_EST_ATUAL = L.[QTD_EST_ATUAL]
		FROM 
			#TAB_RETORNO AS R
			INNER JOIN @TAB_ESTOQUE_CD AS T
				ON 1=1
				AND R.COD_PRODUTO = T.COD_PRODUTO

PRINT 'Tempo - Updates Est CD: ' + CONVERT(VARCHAR,DATEDIFF(S,@DATA_INI_PROC,GETDATE())	)
SET @DATA_INI_PROC = GETDATE()

	-- #####################################################################################################################################################################
	-- Produtos Sem referência no fornecedor principal
	-- #####################################################################################################################################################################
		IF @TIPO_PEDIDO = 1
		BEGIN
			UPDATE R
			SET
				FLG_ERRO_SEM_REFERENCIA = 1
			FROM
				#TAB_RETORNO AS R
				LEFT JOIN AX2009_INTEGRACAO.DBO.TAB_PRODUTO_REFERENCIA AS UNID WITH (NOLOCK)
					ON 1=1
					AND UNID.COD_FORNECEDOR = @FORN
					AND UNID.ITEMID = R.COD_PRODUTO
			WHERE 1=1
				AND UNID.COD_PRODUTO IS NULL	
				
			PRINT 'Marcando produtos centralizado sem referencia fornecedor principal: ' + CONVERT(VARCHAR,DATEDIFF(S,@DATA_INI_PROC,GETDATE())	)
			SET @DATA_INI_PROC = GETDATE()
		END	
	
	-- #####################################################################################################################################################################
	-- Produtos Sem Custo
	-- #####################################################################################################################################################################	
		-- ATUALIZANDO CUSTO PARA ATUALIZADO DO BI QUANDO FOR ZERO NO ZEUS AINDA (nao integrado)
		UPDATE R
		SET 
			 R.VAL_CUSTO_EMBALAGEM = L.VLR_EMB_COMPRA
		FROM 
			#TAB_RETORNO AS R
			INNER JOIN BI.dbo.VW_CUSTOS_ATIVOS AS L
				ON 1=1
				--AND R.COD_LOJA = L.COD_LOJA
				AND R.COD_PRODUTO = L.COD_PRODUTO	
				AND L.COD_FORNECEDOR = @FORN_PEDIDO
		WHERE 1=1
			AND isnull(R.VAL_CUSTO_EMBALAGEM,0) = 0
			
		-- ATUALIZANDO CUSTO PARA ATUALIZADO DO BI QUANDO FOR ZERO NO ZEUS AINDA (nao integrado)
		UPDATE R
		SET 
			 R.VAL_CUSTO_EMBALAGEM = L.VLR_EMB_COMPRA
		FROM 
			#TAB_RETORNO AS R
			INNER JOIN BI.dbo.VW_CUSTOS_ATIVOS2 AS L
				ON 1=1
				--AND R.COD_LOJA = L.COD_LOJA
				AND R.COD_PRODUTO = L.COD_PRODUTO	
				AND L.COD_FORNECEDOR = @FORN
		WHERE 1=1
			AND isnull(R.VAL_CUSTO_EMBALAGEM,0) = 0

		update #TAB_RETORNO set FLG_ERRO_SEM_CUSTO = 1 where isnull(VAL_CUSTO_EMBALAGEM,0) = 0 
		--DELETE FROM  #TAB_RETORNO where isnull(VAL_CUSTO_EMBALAGEM,0) = 0 
		
		-- -------------------------------------------------------------------------------------------
		-- SE NAO POSSUIR CUSTO NO BI
		-- -------------------------------------------------------------------------------------------
		UPDATE R
		SET
			FLG_ERRO_SEM_CUSTO = 2			
		FROM 
			#TAB_RETORNO AS R
			LEFT JOIN BI.dbo.VW_CUSTOS_ATIVOS AS L
				ON 1=1
				--AND R.COD_LOJA = L.COD_LOJA
				AND R.COD_PRODUTO = L.COD_PRODUTO	
				AND L.COD_FORNECEDOR = @FORN_PEDIDO
		WHERE 1=1
			AND L.VLR_EMB_COMPRA IS NULL		

	--SELECT 6, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 583831

PRINT 'Produtos Sem Custo'
PRINT DATEDIFF(S,@DATA_INI_PROC,GETDATE())
SET @DATA_INI_PROC = GETDATE()
	
	-- #####################################################################################################################################################################
	-- Removendo Produtos XD quando for CD->Lojas
	-- #####################################################################################################################################################################
	IF @TIPO_PEDIDO IN (2,3)
	BEGIN
		UPDATE L
		SET
			L.FLG_ERRO_TIPO_ABASTECIMENTO = 1
		--DELETE L
		FROM
			#TAB_RETORNO AS L 
			INNER JOIN AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL AS AFP
				ON 1=1
				AND AFP.COD_LOJA = 5
				AND L.COD_PRODUTO = AFP.COD_PRODUTO
		WHERE 1=1
			and afp.ModelArmazenagem = 1
		
		
		PRINT 'Removendo Produtos XD quando for tipo (2,3):  ' + convert(varchar,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
		SET @DATA_INI_PROC = GETDATE()
	
	END
	
	--SELECT 5, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 583831
	
	-- #####################################################################################################################################################################
	-- Removendo Produtos SEM ESTOQUE quando for CD->Lojas
	-- #####################################################################################################################################################################
	IF @TIPO_PEDIDO = 2
	BEGIN
		DELETE L
		FROM
			#TAB_RETORNO AS L 
		WHERE 1=1
			and L.QTD_ESTOQUE_CD <= 0
		
		
		PRINT 'Removendo Produtos SEM ESTOQUE quando for tipo (2):  ' + convert(varchar,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
		SET @DATA_INI_PROC = GETDATE()
	
	END
	
	--SELECT 4, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 583831
	
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
			
PRINT 'Criando tabela com apenas NOTAVEL E ULTRA' + convert(varchar,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
SET @DATA_INI_PROC = GETDATE()

	--SELECT 3, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 583831

	-- #####################################################################################################################################################################
	-- Mantendo apenas itens 'A1','A2','A3','B' para compras
	-- #####################################################################################################################################################################
	IF @TIPO_PEDIDO in (1,3)
	BEGIN
		--LIBERANDO COMPRA DE TUDO.
		UPDATE #TAB_RETORNO SET FLG_COMPRA = 1
		
	/*
		--Liberando Hortus
		UPDATE #TAB_RETORNO SET FLG_COMPRA = 1 WHERE COD_LOJA in (7,29)
		
		--Liberando 'A1','B', 'C' SUPPLY
		update R
		set
			FLG_COMPRA = 1
		from
			#TAB_RETORNO AS R 
			INNER JOIN BI.DBO.[SUPPLY_PRODUTO_ABC_LOJA] AS CP
				ON 1=1
				AND R.COD_PRODUTO = CP.COD_PRODUTO
				AND CP.COD_LOJA = 0
		where 1=1
			--AND R.COD_LOJA not in (7,29)
			AND CP.ABC_LOJA IN ('A','B','C','D')
	*/
						
						/* REGRA ANTIGA DESATIVADA 22/11
						--Bloqueando ADEGA para todas as lojas menos HortuS			
						update R
						set
							FLG_COMPRA = NULL
						from
							#TAB_RETORNO AS R 
							INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
								ON 1=1
								AND R.COD_PRODUTO = CP.COD_PRODUTO
							INNER JOIN BI.DBO.BI_LINHA_PRODUTOS AS LP
								ON 1=1
								AND R.COD_PRODUTO = LP.COD_PRODUTO
								AND R.COD_LOJA = LP.COD_LOJA
						where 1=1
							AND R.COD_LOJA not in (7,29)
							AND CP.COD_DEPARTAMENTO = 2
							--AND LP.CLASSIF_PRODUTO_LOJA NOT IN ('A1','A2','A3')
							AND LP.CLASSIF_PRODUTO_LOJA NOT IN ('A1','A2','A3','B') --Mudança 27/10
						
						update R
						set
							FLG_COMPRA = NULL
						from
							#TAB_RETORNO AS R 
							INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
								ON 1=1
								AND R.COD_PRODUTO = CP.COD_PRODUTO
							INNER JOIN BI.DBO.[SUPPLY_PRODUTO_ABC_LOJA] AS LP
								ON 1=1
								AND R.COD_PRODUTO = LP.COD_PRODUTO
								AND R.COD_LOJA = LP.COD_LOJA
						where 1=1
							AND R.COD_LOJA not in (7,29)
							AND CP.COD_DEPARTAMENTO = 2
							--AND ISNULL(LP.ABC_LOJA,'Z') NOT IN ('A1','A2','A3')
							AND ISNULL(LP.ABC_LOJA,'Z') NOT IN ('A1','A2','A3','B') --Mudança 27/10
						

									--select 'Bloqueando ADEGA', COD_PRODUTO, COD_LOJA,FLG_COMPRA FROM #TAB_RETORNO WHERE COD_PRODUTO = 13754
						
						
						--Liberando 'A1','A2','A3'		
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
							--AND LP.CLASSIF_PRODUTO_LOJA IN ('A1','A2','A3')
							AND LP.CLASSIF_PRODUTO_LOJA IN ('A1','A2','A3','B') --Mudança 09/11
						
									--select 'Liberando A',COD_PRODUTO, COD_LOJA, FLG_COMPRA FROM #TAB_RETORNO WHERE COD_PRODUTO = 13754
									
					/*	--se bloquear adega novamente, descomentar			
							--Liberando 'B'	(menos adega)
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
								and LP.COD_DEPARTAMENTO not in (2)
								AND LP.CLASSIF_PRODUTO_LOJA IN ('B')
					*/
						
									--select 'Liberando B',COD_PRODUTO, COD_LOJA, FLG_COMPRA FROM #TAB_RETORNO WHERE COD_PRODUTO = 13754		
						
						--Liberando 'A1','A2','A3'	SUPPLY
						update R
						set
							FLG_COMPRA = 1
						from
							#TAB_RETORNO AS R 
							INNER JOIN BI.DBO.[SUPPLY_PRODUTO_ABC_LOJA] AS CP
								ON 1=1
								AND R.COD_PRODUTO = CP.COD_PRODUTO
								AND R.COD_LOJA = CP.COD_LOJA
						where 1=1
							AND R.COD_LOJA not in (7,29)
							AND CP.ABC_LOJA IN ('A1','A2','A3')

									--select 'Liberando A supply',COD_PRODUTO, COD_LOJA,FLG_COMPRA FROM #TAB_RETORNO WHERE COD_PRODUTO = 13754
									
						--Liberando 'B'	SUPPLY
						update R
						set
							FLG_COMPRA = 1
						from
							#TAB_RETORNO AS R 
							INNER JOIN BI.DBO.[SUPPLY_PRODUTO_ABC_LOJA] AS CP
								ON 1=1
								AND R.COD_PRODUTO = CP.COD_PRODUTO
								AND R.COD_LOJA = CP.COD_LOJA
						where 1=1
							AND R.COD_LOJA not in (7,29)
							AND R.COD_DEPARTAMENTO NOT IN (2)
							AND CP.ABC_LOJA IN ('B')

									--select 'Liberando B supply',COD_PRODUTO, COD_LOJA,FLG_COMPRA FROM #TAB_RETORNO WHERE COD_PRODUTO = 13754
									

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

									--select 'Liberando Notavel',COD_PRODUTO, COD_LOJA,FLG_COMPRA FROM #TAB_RETORNO WHERE COD_PRODUTO = 13754
						*/
		
		--NUNCA COMENTAR ISSO.
		update R
		set
			FLG_COMPRA = 0
		from
			#TAB_RETORNO AS R 
		where 1=1
			and FLG_COMPRA is null
		
		--DELETE FROM #TAB_RETORNO WHERE FLG_COMPRA IS NULL		
		
		
		PRINT 'Buscando apenas NOTAVEL E ULTRA A1,A2,A3,B ' + convert(varchar,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
		SET @DATA_INI_PROC = GETDATE()
		
	END
	ELSE
	BEGIN
		UPDATE #TAB_RETORNO SET FLG_COMPRA = 1
	END

	--SELECT 2, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 583831
	
	-- #####################################################################################################################################################################
	-- fornecedor principal
	-- #####################################################################################################################################################################
	IF @TIPO_PEDIDO in (1,3)
	BEGIN
		--DELETE L
		UPDATE L
			SET L.FORNECEDOR_PRINCIPAL = AFP.FORNECEDOR_COMPRAS
		FROM
			#TAB_RETORNO AS L
			LEFT JOIN AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL AS AFP
				ON 1=1
				AND L.COD_LOJA = AFP.COD_LOJA
				AND L.COD_PRODUTO = AFP.COD_PRODUTO	
				--AND AFP.FORNECEDOR_COMPRAS = @FORN
		WHERE 1=1
			--AND AFP.COD_LOJA IS NULL			
		
		PRINT 'Buscando apenas produtos com fornecedor principal para tipos (1,3):  ' + convert(varchar,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
		SET @DATA_INI_PROC = GETDATE()
		
	END

select @QTD_LINHAS = COUNT(cod_produto) from #TAB_RETORNO WHERE FLG_COMPRA = 1	
print 'Linhas na tabela Final: ' + convert(varchar,@QTD_LINHAS)
	
	--SELECT 1, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 583831
	
	-- #####################################################################################################################################################################
	-- CONVERSÃO UNIDADE
	-- #####################################################################################################################################################################
	
		--Não possui conversão
		UPDATE L
		SET
			L.FLG_ERRO_CONVERSAO_UNIDADE = 1
		FROM
			#TAB_RETORNO AS L
			LEFT JOIN AX2009_INTEGRACAO.DBO.TAB_PRODUTO_CONVERSAO_UNIDADE AS CU
				ON 1=1
				AND L.COD_PRODUTO = CU.COD_PRODUTO
				AND L.DES_UNIDADE_COMPRA = CU.DE
		WHERE 1=1
			AND L.DES_UNIDADE_COMPRA = 'CX'
			AND CU.DE IS NULL	
		
		/*
		SELECT top 10 * FROM AX2009_INTEGRACAO.DBO.TAB_PRODUTO_UNIDADES WHERE UNIDADE_COMPRA <> UNIDADE_VENDA
		
		select * fROM SMA_AX50_SP1_DB_PROD.DBO.INVENTTABLEMODULE WHERE 1 = 1 AND MODULETYPE = 1 AND DATAAREAID = 'BAR' and ITEMID = 1029965
		select * from AX2009_INTEGRACAO.DBO.TAB_PRODUTO_REFERENCIA WHERE itemid = 1029965
		
		SELECT * FROM AX2009_INTEGRACAO.DBO.TAB_PRODUTO_CONVERSAO_UNIDADE WHERE ITEMID = 1029965
		*/
		
	-- #####################################################################################################################################################################
	-- BLOQUEIO COMPRA SUPPLY
	-- #####################################################################################################################################################################
		
		--LOJA ESPECIFICA
		UPDATE L
		SET
			L.FLG_BLOQUEADO_SUPPLY = 1
		FROM
			#TAB_RETORNO AS L
			INNER JOIN [BI].[dbo].[SUPPLY_PRODUTO_BLOQUEADO_LOJA_AUTO] PBS
				ON 1=1
				AND L.COD_PRODUTO = PBS.COD_PRODUTO
				AND PBS.TIPO_PEDIDO = @TIPO_PEDIDO
				AND L.COD_LOJA = PBS.COD_LOJA
		WHERE 1=1
			
		--LOJAS ZERO
		UPDATE L
		SET
			L.FLG_BLOQUEADO_SUPPLY = 1
		FROM
			#TAB_RETORNO AS L
			INNER JOIN [BI].[dbo].[SUPPLY_PRODUTO_BLOQUEADO_LOJA_AUTO] PBS
				ON 1=1
				AND L.COD_PRODUTO = PBS.COD_PRODUTO
				AND PBS.TIPO_PEDIDO = @TIPO_PEDIDO
				AND PBS.COD_LOJA = 0
		WHERE 1=1
	
	-- #####################################################################################################################################################################
	-- ESTOQUE EM TRANSITO
	-- #####################################################################################################################################################################
		DECLARE @TEMP_ESTOQUE_TRANSITO AS TABLE
		(
			COD_LOJA INT
			,COD_FORNECEDOR INT
			,COD_PRODUTO INT
			,QTD_ESTOQUE_TRANSITO NUMERIC(18,4)
			,PRIMARY KEY (COD_LOJA, COD_FORNECEDOR, COD_PRODUTO)
		)
		INSERT INTO @TEMP_ESTOQUE_TRANSITO
			EXEC BI.DBO.SUPPLY_ESTOQUE_TRANSITO @ID_AGENDA
			
		UPDATE L
		SET
			L.QTD_EST_TRANSITO = ET.QTD_ESTOQUE_TRANSITO
		FROM
			#TAB_RETORNO AS L
			INNER JOIN @TEMP_ESTOQUE_TRANSITO ET
				ON 1=1
				AND L.COD_PRODUTO = ET.COD_PRODUTO
				AND L.COD_LOJA = ET.COD_LOJA
				AND ET.COD_FORNECEDOR = @FORN
		WHERE 1=1
	
	-- #####################################################################################################################################################################
	-- PICKING UNITARIO
	-- #####################################################################################################################################################################		
	IF @ID_AGENDA IN (1392,1400,1479,1480,1506)
	BEGIN
	
		UPDATE R
		SET 
			R.FLG_PICKING_UN = PU.PickingUnitario
		FROM
			#TAB_RETORNO AS R	
			INNER JOIN AX2009_INTEGRACAO.[dbo].[TAB_PRODUTO_FORNECEDOR_PREFERENCIAL] AS PU
				ON 1=1
				AND R.COD_LOJA = PU.COD_LOJA
				AND R.COD_PRODUTO = PU.COD_PRODUTO
		WHERE 1 = 1		

		UPDATE R
		SET 
			R.QTD_EMBALAGEM_COMPRA = 1
			,R.QTD_MULTIPLO_EMB = 1
		FROM
			#TAB_RETORNO AS R	
		WHERE 1 = 1		
			AND FLG_PICKING_UN = 1
	END

	-- #####################################################################################################################################################################
	-- FINAL SELECT
	-- #####################################################################################################################################################################	
	IF @TIPO_PEDIDO <> 4
	BEGIN
		SELECT
		--|||Essenciais|||
			 L.COD_LOJA
			,L.COD_PRODUTO
			,ISNULL(L.QTD_EST_ATUAL,0) AS QTD_EST_ATUAL
			
			--alterado para 0 dia 21/10 a pedido do adilson			
			--,0 as QTD_EST_TRANSITO
			,ISNULL(L.QTD_EST_TRANSITO,0) as QTD_EST_TRANSITO
			
			--,isnull(E.AVG_QTD_U90D_PD,0) as AVG_QTD_U30D_PD
			--AVG_VLR_ROBIN_PD
			--,(CASE WHEN E.AVG_VLR_ROBIN_PD IS NULL THEN isnull(E.AVG_QTD_U180D_PD,0) ELSE E.AVG_VLR_ROBIN_PD END) as AVG_QTD_U30D_PD
			,isnull((SELECT Max(v) FROM (VALUES (E.AVG_QTD_U30D_PD), (E.AVG_QTD_U90D_PD)) AS value(v)),0) as AVG_QTD_U30D_PD --alterado 23/03/2017
			--,(SELECT Max(v) FROM (VALUES (E.AVG_QTD_U30D_PD), (E.AVG_QTD_U90D_PD), (E.AVG_QTD_U180D_PD)) AS value(v)) as AVG_QTD_U30D_PD --Pega maior das tres médias
			,isnull(L.QTD_EMBALAGEM_COMPRA,1) AS QTD_EMB_COMPRA
			,isnull(L.QTD_MULTIPLO_EMB,1) as QTD_MULT_EMB
			,P.[DIA_SS] as QTD_SS_DIAS -- Os nullos são tratados no Mathematica, pois veem da agenda executada
			,isnull(P.[FAT_SZ],1) as FAT_SAZ
			,isnull(P.[QTD_EXP],0) as QTD_MIN_UN
									
		--|||Acessórios|||
			,ISNULL(E.QTD_QUEBRA_PERC_3M,0) AS QTD_QUEBRA_3M
			,L.COD_DEPARTAMENTO
			,L.COD_SECAO
			--,ISNULL(E.CLASSIF_PRODUTO_LOJA, 'Z') AS ABC_VLR
			,ISNULL(PABC.ABC_LOJA, 'Z') AS ABC_VLR
			,NULLIF(L.[VAL_CUSTO_EMBALAGEM],0) AS [VAL_CUSTO_EMBALAGEM]
			,L.DES_UNIDADE_VENDA
			,L.DES_UNIDADE_COMPRA
			,@FORN_PEDIDO AS FORN_PRINCIPAL_AX
			,isnull(L.QTD_ESTOQUE_CD,0) as QTD_ESTOQUE_CD 
			,isnull(L.QTD_CAMADA_PLT,1) as QTD_CAMADA_PLT
			,isnull(L.QTD_CX_CAMADA_PLT,1) as QTD_CX_CAMADA_PLT
			,L.FLG_COMPRA
			,L.ERRO_CENTRALIZACAO
			--,(CASE WHEN PB.COD_PRODUTO IS NOT NULL THEN 'PLU BLOQUEADO PARA COMPRA AUTOMATICA' ELSE '' END) AS POSSUI_BLOQUEIO_SUPPLY
			,(CASE WHEN @FORN_PEDIDO = 18055 AND @FORN <> 18055 THEN 1 ELSE 0 END) AS FLG_CENTRALIZADO
			,L.FORNECEDOR_PRINCIPAL as FORNECEDOR_PRINCIPAL_PROD
			,(CASE WHEN L.FORNECEDOR_PRINCIPAL <> @FORN THEN 1 ELSE 0 END) AS FLG_ERRO_FORNECEDOR_PRINCIPAL
			,ISNULL(L.FLG_ERRO_TIPO_ABASTECIMENTO,0) AS FLG_ERRO_TIPO_ABASTECIMENTO
			,ISNULL(L.FLG_ERRO_SEM_CUSTO,0) AS FLG_ERRO_SEM_CUSTO
			,@TIPO_PEDIDO AS TIPO_PEDIDO
			,L.DES_UNIDADE_COMPRA
			,L.FLG_ERRO_CONVERSAO_UNIDADE
			,L.FLG_BLOQUEADO_SUPPLY
			,L.FLG_ERRO_SEM_REFERENCIA
			
			,L.FLG_PICKING_UN
			,L.QTD_EMBALAGEM_FORN
			,L.QTD_MULTIPLO_FORN
		FROM
			#TAB_RETORNO AS L
			--INNER JOIN AX2009_INTEGRACAO.DBO.TAB_PRODUTO_FORNECEDOR_PREFERENCIAL AS AFP
			--	ON 1=1
			--	AND L.COD_LOJA = AFP.COD_LOJA
			--	AND L.COD_PRODUTO = AFP.COD_PRODUTO	
			--	AND AFP.FORNECEDOR_COMPRAS = @FORN
			LEFT JOIN DBO.COMPRAS_ESTATISTICA_PRODUTO AS E
				ON 1=1
				AND L.COD_LOJA = E.COD_LOJA
				AND L.COD_PRODUTO = E.COD_PRODUTO
			--LEFT JOIN BI.DBO.COMPRAS_DNV_CALCULADORA AS DNV
			--	ON 1=1
			--	AND DNV.COD_LOJA = L.COD_LOJA
			--	AND DNV.COD_PRODUTO = L.COD_PRODUTO
			--	AND DNV.DATA_GRAVACAO = CONVERT(DATE,GETDATE())
			LEFT JOIN [BI].[dbo].[COMPRA_PRODUTO_PARAMETRO] AS P
				ON 1=1
				AND L.COD_LOJA = P.COD_LOJA
				AND L.COD_PRODUTO = P.COD_PRODUTO
			LEFT JOIN BI.DBO.[SUPPLY_PRODUTO_ABC_LOJA] AS PABC
				ON 1=1
				AND L.COD_LOJA = PABC.COD_LOJA
				AND L.COD_PRODUTO = PABC.COD_PRODUTO	
			--LEFT JOIN [BI].[dbo].[SUPPLY_PRODUTO_BLOQUEADO_LOJA_AUTO] AS PB
			--	ON 1=1
			--	--AND L.COD_LOJA = PB.COD_LOJA
			--	AND L.COD_PRODUTO = PB.COD_PRODUTO					
		WHERE 1=1
			--AND PB.COD_PRODUTO IS NULL
			and L.VAL_CUSTO_EMBALAGEM <> 0
			and L.QTD_EMBALAGEM_COMPRA <> 0
		ORDER BY
			E.CLASSIF_PRODUTO_LOJA
	END
	
	IF @TIPO_PEDIDO = 4
	BEGIN
		SELECT
		--|||Essenciais|||
			 L.COD_LOJA
			,L.COD_PRODUTO
			,ISNULL(L.QTD_EST_ATUAL,0) AS QTD_EST_ATUAL
			,0 as QTD_EST_TRANSITO
			,isnull(EF.AVG_QTD_VENDA,0) as AVG_QTD_U30D_PD
			,isnull(L.QTD_EMBALAGEM_COMPRA,1) AS QTD_EMB_COMPRA
			,isnull(L.QTD_MULTIPLO_EMB,1) as QTD_MULT_EMB
			,P.[DIA_SS] as QTD_SS_DIAS -- Os nullos são tratados no Mathematica, pois veem da agenda executada
			,isnull(P.[FAT_SZ],1) as FAT_SAZ
			,isnull(P.[QTD_EXP],0) as QTD_MIN_UN
									
		--|||Acessórios|||
			--,ISNULL(E.QTD_QUEBRA_PERC_3M,0) AS QTD_QUEBRA_3M
			,L.COD_DEPARTAMENTO
			,L.COD_SECAO
			,ISNULL(E.CLASSIF_PRODUTO_LOJA, 'Z') AS ABC_VLR
			--,ISNULL(PABC.ABC_LOJA, 'Z') AS ABC_VLR
			,NULLIF(L.[VAL_CUSTO_EMBALAGEM],0) AS [VAL_CUSTO_EMBALAGEM]
			,L.DES_UNIDADE_VENDA
			,L.DES_UNIDADE_COMPRA
			,@FORN_PEDIDO AS FORN_PRINCIPAL_AX
			,isnull(L.QTD_ESTOQUE_CD,0) as QTD_ESTOQUE_CD 
			,isnull(L.QTD_CAMADA_PLT,1) as QTD_CAMADA_PLT
			,isnull(L.QTD_CX_CAMADA_PLT,1) as QTD_CX_CAMADA_PLT
			,L.FLG_COMPRA
			,L.ERRO_CENTRALIZACAO
			,0 AS FLG_CENTRALIZADO
			,L.FORNECEDOR_PRINCIPAL AS FORNECEDOR_PRINCIPAL_PROD
			,(CASE WHEN L.FORNECEDOR_PRINCIPAL <> @FORN THEN 1 ELSE 0 END) AS FLG_ERRO_FORNECEDOR_PRINCIPAL
			,0 AS FLG_ERRO_TIPO_ABASTECIMENTO
			,0 AS FLG_ERRO_SEM_CUSTO
			,FLG_COMPRA
			,@TIPO_PEDIDO AS TIPO_PEDIDO
			--,(CASE
			--	WHEN @TIPO_PEDIDO = 1 THEN '1 Normal'
			--	WHEN @TIPO_PEDIDO = 2 THEN '2 CD-Loja'
			--	WHEN @TIPO_PEDIDO = 3 THEN '3 CD-Forn'
			--	WHEN @TIPO_PEDIDO = 4 THEN '4 FLV'
			--END) AS TIPO_PEDIDO
			,L.DES_UNIDADE_COMPRA
			,null as FLG_ERRO_CONVERSAO_UNIDADE
			,L.FLG_BLOQUEADO_SUPPLY
			,L.FLG_ERRO_SEM_REFERENCIA
			,NULL AS FLG_PICKING_UN
			,NULL AS QTD_EMBALAGEM_FORN
			,NULL AS QTD_MULTIPLO_FORN
		FROM
			#TAB_RETORNO AS L
			LEFT JOIN DBO.COMPRAS_ESTATISTICA_PRODUTO_FLV AS EF
				ON 1=1
				AND L.COD_LOJA = EF.COD_LOJA
				AND L.COD_PRODUTO = EF.COD_PRODUTO
				AND EF.DIA_SEMANA = datepart(dw, GETDATE())
			LEFT JOIN [BI].[dbo].[COMPRA_PRODUTO_PARAMETRO] AS P
				ON 1=1
				AND L.COD_LOJA = P.COD_LOJA
				AND L.COD_PRODUTO = P.COD_PRODUTO
			LEFT JOIN DBO.COMPRAS_ESTATISTICA_PRODUTO AS E
				ON 1=1
				AND L.COD_LOJA = E.COD_LOJA
				AND L.COD_PRODUTO = E.COD_PRODUTO		
		WHERE 1=1
	END
	
	SET @TEMPO = DATEDIFF(S,@DATA_INI_ROTINA,GETDATE())
	
	EXEC BI.DBO.BI_LOG 
		@ID_ROTINA
		,@DATA_INI_ROTINA
		,@TEMPO
		,@PARAMETROS_ROTINA
END


