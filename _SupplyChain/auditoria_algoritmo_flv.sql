--SELECT * FROM BI.DBO.COMPRAS_AGENDA_PEDIDO_AUTO WHERE TIPO = 4
-- EXEC [COMPRAS_ESTAT_FORN_DEV] 103585, '3,6,13', '4', '44;45;47;48;46', 4

	DECLARE @FORN [INT] = 103585
	DECLARE @ARRAY_LOJAS VARCHAR(80) = '3,6,13'
	DECLARE @ARRAY_DEP VARCHAR(80) = '4'
	DECLARE @ARRAY_SECAO VARCHAR(80) = '44;45;47;48;46'
	DECLARE @TIPO_PEDIDO INT = 4

	SET NOCOUNT ON;
	/* @TIPO_PEDIDO
		1 Normal
		2 CD-Loja
		3 CD-Forn	
		4 FLV
*/
	
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
		,QTD_ESTOQUE_CD NUMERIC(18,2)
		,QTD_CAMADA_PLT INT NULL
		,QTD_CX_CAMADA_PLT INT NULL
		,ERRO_CENTRALIZACAO VARCHAR(1000)
		,FORNECEDOR_PRINCIPAL INT NULL
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
				exec dw.dbo.sp_Calculadora_Lista_Produtos_Fornecedor  @ARRAY_LOJAS, @FORN , @ARRAY_DEP , @ARRAY_SECAO , 1
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
		
--PRINT 'Insert inicial'
--PRINT DATEDIFF(S,@DATA_INI_PROC,GETDATE())
--SET @DATA_INI_PROC = GETDATE()

	--SELECT 9, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 1032819

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
	
	--SELECT 8, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 1032819


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
	
	--SELECT 7, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 1032819

		
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
		
PRINT 'Tempo - Updates Zeus: ' + CONVERT(VARCHAR,DATEDIFF(S,@DATA_INI_PROC,GETDATE())	)
SET @DATA_INI_PROC = GETDATE()
	
	-- ------------------------------------------------------------------------------
	-- ESTOQUE CD
	-- ------------------------------------------------------------------------------
	DECLARE @TAB_ESTOQUE_CD AS TABLE
	(
		COD_PRODUTO INT
		,QTD_ESTOQUE_CD NUMERIC(18,2)
	)
	
	INSERT INTO @TAB_ESTOQUE_CD
	select CD_PRODUTO, SUM(CONVERT(NUMERIC(18,2),QT_ESTOQUE)) from WMS.dbo.V_ESTOQUE_ERP group by CD_PRODUTO
		
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
	-- Removendo Produtos Sem Custo
	-- 03/09
	-- Marcelo Frade
	-- #####################################################################################################################################################################	
		delete from #TAB_RETORNO where isnull(VAL_CUSTO_EMBALAGEM,0) = 0 

	--SELECT 6, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 1032819

PRINT 'Delete Sem Custo'
PRINT DATEDIFF(S,@DATA_INI_PROC,GETDATE())
SET @DATA_INI_PROC = GETDATE()
	
	-- #####################################################################################################################################################################
	-- Removendo Produtos XD quando for CD->Lojas
	-- #####################################################################################################################################################################
	IF @TIPO_PEDIDO IN (2,3)
	BEGIN
		DELETE L
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
	
	--SELECT 5, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 1032819
	
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
	
	--SELECT 4, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 1032819
	
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

	--SELECT 3, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 1032819

	-- #####################################################################################################################################################################
	-- Mantendo apenas itens 'A1','A2','A3','B' para compras
	-- #####################################################################################################################################################################
	IF @TIPO_PEDIDO in (1,3)
	BEGIN
		--LIBERANDO COMPRA DE TUDO. TESTE VICTOR ROSA 10/03
		UPDATE #TAB_RETORNO SET FLG_COMPRA = 1
		
		
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
			INNER JOIN BI.DBO.[SUPPLY_PRODUTO_ABC_LOJA] AS CP
				ON 1=1
				AND R.COD_PRODUTO = CP.COD_PRODUTO
				AND R.COD_LOJA = CP.COD_LOJA
		where 1=1
			AND R.COD_LOJA not in (7,29)
			AND CP.ABC_LOJA IN ('A1','A2','A3','B')

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
			INNER JOIN BI.DBO.[SUPPLY_PRODUTO_ABC_LOJA] AS LP
				ON 1=1
				AND R.COD_PRODUTO = LP.COD_PRODUTO
				AND R.COD_LOJA = LP.COD_LOJA
		where 1=1
			AND R.COD_LOJA not in (7,29)
			AND CP.COD_DEPARTAMENTO = 2
			AND LP.ABC_LOJA NOT IN ('A1','A2','A3')
				
		DELETE FROM #TAB_RETORNO WHERE FLG_COMPRA IS NULL
		
		
		PRINT 'Buscando apenas NOTAVEL E ULTRA A1,A2,A3,B ' + convert(varchar,DATEDIFF(S,@DATA_INI_PROC,GETDATE()))
		SET @DATA_INI_PROC = GETDATE()
		
	END
	ELSE
	BEGIN
		UPDATE #TAB_RETORNO SET FLG_COMPRA = 1
	END

	--SELECT 2, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 1032819
	
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
	
	--SELECT 1, * FROM #TAB_RETORNO AS L WHERE 1=1 and COD_PRODUTO = 1032819

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
			,0 as QTD_EST_TRANSITO
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
			--,ISNULL(E.CLASSIF_PRODUTO_LOJA, 'Z') AS ABC_VLR
			,ISNULL(PABC.ABC_LOJA, 'Z') AS ABC_VLR
			,L.[VAL_CUSTO_EMBALAGEM]
			,L.DES_UNIDADE_VENDA
			,L.DES_UNIDADE_COMPRA
			,@FORN_PEDIDO AS FORN_PRINCIPAL_AX
			,isnull(L.QTD_ESTOQUE_CD,0) as QTD_ESTOQUE_CD 
			,isnull(L.QTD_CAMADA_PLT,1) as QTD_CAMADA_PLT
			,isnull(L.QTD_CX_CAMADA_PLT,1) as QTD_CX_CAMADA_PLT
			,L.FLG_COMPRA
			,L.ERRO_CENTRALIZACAO
			,(CASE WHEN PB.COD_PRODUTO IS NOT NULL THEN 'PLU BLOQUEADO PARA COMPRA AUTOMATICA' ELSE '' END) AS POSSUI_BLOQUEIO_SUPPLY
			,(CASE WHEN @FORN_PEDIDO = 18055 AND @FORN <> 18055 THEN 1 ELSE 0 END) AS FLG_CENTRALIZADO
			,L.FORNECEDOR_PRINCIPAL as FORNECEDOR_PRINCIPAL_PROD
			,(CASE WHEN L.FORNECEDOR_PRINCIPAL <> @FORN THEN 1 ELSE 0 END) AS FLG_ERRO_FORNECEDOR_PRINCIPAL
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
			LEFT JOIN BI.DBO.COMPRAS_DNV_CALCULADORA AS DNV
				ON 1=1
				AND DNV.COD_LOJA = L.COD_LOJA
				AND DNV.COD_PRODUTO = L.COD_PRODUTO
				AND DNV.DATA_GRAVACAO = CONVERT(DATE,GETDATE())
			LEFT JOIN [BI].[dbo].[COMPRA_PRODUTO_PARAMETRO] AS P
				ON 1=1
				AND L.COD_LOJA = P.COD_LOJA
				AND L.COD_PRODUTO = P.COD_PRODUTO
			LEFT JOIN BI.DBO.[SUPPLY_PRODUTO_ABC_LOJA] AS PABC
				ON 1=1
				AND L.COD_LOJA = PABC.COD_LOJA
				AND L.COD_PRODUTO = PABC.COD_PRODUTO	
			LEFT JOIN [BI].[dbo].[SUPPLY_PRODUTO_BLOQUEADO_LOJA_AUTO] AS PB
				ON 1=1
				--AND L.COD_LOJA = PB.COD_LOJA
				AND L.COD_PRODUTO = PB.COD_PRODUTO					
		WHERE 1=1
			--AND PB.COD_PRODUTO IS NULL
		ORDER BY
			E.CLASSIF_PRODUTO_LOJA
	END
	
	IF @TIPO_PEDIDO = 4
	BEGIN
		SELECT
		--|||Essenciais|||
			 L.COD_LOJA
			,L.COD_PRODUTO
			,CP.DESCRICAO
			,CP.NO_DEPARTAMENTO
			,CP.NO_SECAO
			,ISNULL(E.CLASSIF_PRODUTO_LOJA, 'Z') AS ABC_VLR
			--,ISNULL(L.QTD_EST_ATUAL,0) AS QTD_EST_ATUAL
			--,0 as QTD_EST_TRANSITO
			,BI.DBO.fn_FormataVlr_Excel(isnull(EF.AVG_QTD_VENDA,0)) as VMD_CALCULO_MURTA
			,BI.DBO.fn_FormataVlr_Excel(isnull(E.AVG_QTD_U180D_PD,0)) as AVG_QTD_U180D_PD
			,BI.DBO.fn_FormataVlr_Excel(isnull(E.AVG_QTD_U90D_PD,0)) as AVG_QTD_U90D_PD
			,BI.DBO.fn_FormataVlr_Excel(isnull(E.AVG_QTD_U30D_PD,0)) as AVG_QTD_U30D_PD
			,BI.DBO.fn_FormataVlr_Excel(isnull(L.QTD_EMBALAGEM_COMPRA,1)) AS QTD_EMB_COMPRA
			,BI.DBO.fn_FormataVlr_Excel(isnull(L.QTD_MULTIPLO_EMB,1)) as QTD_MULT_EMB
			,BI.DBO.fn_FormataVlr_Excel(P.[DIA_SS]) as QTD_SS_DIAS -- Os nullos são tratados no Mathematica, pois veem da agenda executada
			,BI.DBO.fn_FormataVlr_Excel(isnull(P.[FAT_SZ],1)) as FAT_SAZ
			,BI.DBO.fn_FormataVlr_Excel(isnull(P.[QTD_EXP],0)) as QTD_MIN_UN									
		--|||Acessórios|||
			--,ISNULL(E.QTD_QUEBRA_PERC_3M,0) AS QTD_QUEBRA_3M
			
			--,ISNULL(PABC.ABC_LOJA, 'Z') AS ABC_VLR
			,BI.DBO.fn_FormataVlr_Excel(L.[VAL_CUSTO_EMBALAGEM]) AS [VAL_CUSTO_EMBALAGEM]
			,BI.DBO.fn_FormataVlr_Excel(CP.DIAS_VALIDADE) AS DIAS_VALIDADE
			--,L.DES_UNIDADE_VENDA
			--,L.DES_UNIDADE_COMPRA
			--,@FORN_PEDIDO AS FORN_PRINCIPAL_AX
			--,isnull(L.QTD_ESTOQUE_CD,0) as QTD_ESTOQUE_CD 
			--,isnull(L.QTD_CAMADA_PLT,1) as QTD_CAMADA_PLT
			--,isnull(L.QTD_CX_CAMADA_PLT,1) as QTD_CX_CAMADA_PLT
			--,L.FLG_COMPRA
			--,L.ERRO_CENTRALIZACAO
			-- AS FLG_CENTRALIZADO
			--,L.FORNECEDOR_PRINCIPAL AS FORNECEDOR_PRINCIPAL_PROD
			--,(CASE WHEN L.FORNECEDOR_PRINCIPAL <> @FORN THEN 1 ELSE 0 END) AS FLG_ERRO_FORNECEDOR_PRINCIPAL		
		FROM
			#TAB_RETORNO AS L
			LEFT JOIN BI.dbo.BI_CAD_PRODUTO AS CP
				ON L.COD_PRODUTO = CP.COD_PRODUTO
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


