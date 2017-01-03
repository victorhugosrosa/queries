/*
35140601237159000278550010000114111000106954
35140505402904000914550010015639031001259626
35140600923077000133550010000873921917962407
35140662461140001277550550017048931017048934
35140662461140001277550550017048931017048934
*/

DECLARE @NUM_DANFE AS VARCHAR(50) = '35140662461140001277550550017048931017048934'

SELECT * FROM CTRLNFE.DBO.NFE_STATUS WHERE NUM_DANFE = @NUM_DANFE

--[CTRLNFE_DANFES_05]

	-- -----------------------------------------------------------------------------------------------
	--DANFES QUE J� EFETUARAM RECEBIMENTO MAIS AINDA N�O EFETUARAM ENTRADA DE MERCADORIA
	-- -----------------------------------------------------------------------------------------------
	IF EXISTS
	(
		SELECT 1
		FROM
			CTRLNFE.DBO.NFE_STATUS AS A
		WHERE 1 = 1
			AND FLG_RECEBIMENTO = 1
			AND FLG_ENTRADAZEUS IS NULL
			AND COD_FORNECEDOR IS NOT NULL
			AND NUM_DANFE = @NUM_DANFE
			AND NUM_DANFE NOT IN (SELECT DISTINCT NUM_DANFE FROM [CTRLNFE].[DBO].[NFE_PEDIDOS])
	)
	BEGIN
		PRINT '[CONSULTA CtrlNfe_DANFEs_05] --- DANFE J� EFETUOU RECEBIMENTO MAS N�O ENTRADA DA MERCADORIA'
		PRINT ''
	END
	ELSE
	BEGIN
		PRINT '[CONSULTA CtrlNfe_DANFEs_05] --- NEGA��O - DANFE J� EFETUOU RECEBIMENTO MAS N�O ENTRADA DA MERCADORIA'
		PRINT ''
	END

--[CTRLNFE_DANFES_10]	

	-- ------------------------------------------------------------------------
	--ENTRADA AUTOMATICA CONCLUIDA COM SUCESSO [FLG_ENTRADAAUTOMATICA = 1 , DT_PROCESSAMENTO = A.DATA]
	-- ------------------------------------------------------------------------
	IF EXISTS
	(
		SELECT 1
		FROM
			CTRLNFE.DBO.TAB_CTRL_PROCESSAMENTO AS A WITH (NOLOCK) , CTRLNFE.DBO.NFE_STATUS AS B
		WHERE 1 = 1 
			AND A.DANFE = B.NUM_DANFE
			AND A.DANFE = @NUM_DANFE
			AND B.FLG_ENTRADAAUTOMATICA IS NULL
			AND MSGERROR = 'SEM ERRO'			
	)
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_10] --- ENTRADA AUTOMATICA CONCLUIDA COM SUCESSO  --- [flg_entradaAutomatica = 1]'
		PRINT ''
	END
	ELSE
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_10] --- NEGA��O - ENTRADA AUTOMATICA CONCLUIDA COM SUCESSO  --- [flg_entradaAutomatica = 1]'
		PRINT ''
	END
	
	-- ------------------------------------------------------------------------
	--ENTRADA COM ERRO [FLG_ERROENTRADAAUTOMATICA = 1]
	-- ------------------------------------------------------------------------
	IF EXISTS
	(	
		SELECT 1
		FROM 
			CTRLNFE.DBO.TAB_CTRL_PROCESSAMENTO AS A WITH (NOLOCK) , CTRLNFE.DBO.NFE_STATUS AS B
		WHERE 1 = 1 
			AND A.DANFE = B.NUM_DANFE
			AND A.DANFE = @NUM_DANFE
			AND B.FLG_ENTRADAAUTOMATICA IS NULL
			AND MSGERROR <> 'SEM ERRO'		
	)
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_10] --- ENTRADA COM ERRO  --- [flg_ErroEntradaAutomatica = 1]'
		PRINT ''
	END
	ELSE
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_10] --- NEGA��O - ENTRADA COM ERRO  --- [flg_ErroEntradaAutomatica = 1]'
		PRINT ''
	END
		
	-- -----------------------------------------------------------------------------------------------
	--DANFES QUE J� EFETUARAM ENTRADA [B.FLG_ENTRADAZEUS = 1  , B.DT_ENTRADAZEUS = DTA_ENTRADA]
	-- -----------------------------------------------------------------------------------------------
	IF EXISTS
	(
		SELECT 1
		FROM [192.168.0.6].[ZEUS_RTG].[DBO].VW_MARCHE_ENTRADAS
		WHERE 1 = 1
		AND NUM_DANFE = @NUM_DANFE
		AND ISNULL(NUM_DANFE,'') <> ''
	)
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_10] --- J� EFETUARAM ENTRADA  --- [Flg_EntradaZeus = 1]'
		PRINT ''
	END
	ELSE
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_10] --- NEGA��O - J� EFETUARAM ENTRADA  --- [Flg_EntradaZeus = 1]'
		PRINT ''
	END

--[CTRLNFE_DANFES_20]

	-- -----------------------------------------------------------------------------------
	-- MARCANDO DANFES QUE J� FORAM CORRIGIDAS AS CRITICAS NA PRE-DANFE [FLG_ERROPREDANFE = NULL,FLG_PREDANFE = NULL]
	-- -----------------------------------------------------------------------------------
	IF EXISTS
	(
		SELECT 1
		FROM CTRLNFE.DBO.NFE_STATUS AS A , 
			 -- ------------------------------------------------------------------------------------------
			 --FRADE: ALTERACAO EFETUADA DIA 02/04/2014 
			 --CTRLNFE.DBO.VW_ANALISE_CRITICA_DANFE_V1 AS B
			 -- ------------------------------------------------------------------------------------------
			 --FRADE: ALTERACAO PARA ROTINA V2 EM VIRTUDE DA NECESSIDADE DE SE UTILIZAR O PEDIDO
			 --       COMO REFERENCIA DE CUSTO . AS INFORMACOES DE PEDIDO S�O CARREGADAS NO STEP: 05
			 -- ------------------------------------------------------------------------------------------
			 CTRLNFE.DBO.VW_ANALISE_CRITICA_DANFE_V2 AS B

		WHERE 1 = 1
		AND B.NUM_DANFE = A.NUM_DANFE
		AND B.COD_LOJA = A.COD_LOJA
		AND A.FLG_ERROPREDANFE IS NOT NULL
		AND B.BLOQUEAR = 'N'
		AND B.NUM_DANFE = @NUM_DANFE
	)
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_20] --- J� FORAM CORRIGIDAS AS CRITICAS NA PRE-DANFE  --- [flg_ErroPreDanfe = NULL, flg_preDanfe = NULL]'
		PRINT ''
	END
	ELSE
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_20] --- NEGA��O - J� FORAM CORRIGIDAS AS CRITICAS NA PRE-DANFE  --- [flg_ErroPreDanfe = NULL, flg_preDanfe = NULL]'
		PRINT ''
	END
	
	-- -----------------------------------------------------------------------------------
	-- MARCANDO DANFES QUE JA TIVERAM ENTRARAM NO AUTOMATICO COMO J� ANALISADAS [FLG_ERROPREDANFE = NULL,FLG_PREDANFE = 1] 
	-- -----------------------------------------------------------------------------------
	IF EXISTS
	(
		SELECT 1 FROM CTRLNFE.DBO.NFE_STATUS
		WHERE FLG_PREDANFE IS NULL AND FLG_ERROPREDANFE IS NULL AND FLG_ENTRADAAUTOMATICA IS NOT NULL
		AND NUM_DANFE = @NUM_DANFE
	)
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_20] --- JA TIVERAM ENTRARAM NO AUTOMATICO COMO J� ANALISADAS  --- [flg_ErroPreDanfe = NULL, flg_preDanfe = 1]'
		PRINT ''
	END
	ELSE
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_20] --- NEGA��O - JA TIVERAM ENTRARAM NO AUTOMATICO COMO J� ANALISADAS  --- [flg_ErroPreDanfe = NULL, flg_preDanfe = 1]'
		PRINT ''
	END
		
	-- -----------------------------------------------------------------------------------
	-- MARCANDO DANFES QUE POSSUEM ERRO NA ENTRADA AUTOMATICA PARA REPROCESSAMENTO
	-- POSSUI ERRO NA ENTRADA AUTOMATICA E NAO POSSUI ENTRADA NO ZEUS [FLG_ERROPREDANFE = NULL,	FLG_PREDANFE = NULL]
	-- -----------------------------------------------------------------------------------
	IF EXISTS
	(
		SELECT 1 FROM CTRLNFE.DBO.NFE_STATUS		
		WHERE FLG_ERROENTRADAAUTOMATICA IS NOT NULL AND FLG_ENTRADAZEUS IS  NULL
		AND NUM_DANFE = @NUM_DANFE
	)
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_20] --- MARCANDO DANFES QUE POSSUEM ERRO NA ENTRADA AUTOMATICA PARA REPROCESSAMENTO  --- [flg_ErroPreDanfe = NULL,	flg_preDanfe = NULL]'
		PRINT ''
	END
	ELSE
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_20] --- NEGA��O - MARCANDO DANFES QUE POSSUEM ERRO NA ENTRADA AUTOMATICA PARA REPROCESSAMENTO  --- [flg_ErroPreDanfe = NULL,	flg_preDanfe = NULL]'
		PRINT ''
	END
	
	-- -----------------------------------------------------------------------------------
	-- MARCANDO DANFES QUE ESTAO COM FLAG DE ERRO PRE DANFE PARA REANALISAR, FOR�ANDO REPROCESSAMENTO 
	-- -----------------------------------------------------------------------------------
	
		--REMOVENDO MENSAGEM DE ERRO CTRLNFE.DBO.TAB_CTRL_PROCESSAMENTO [MSGERROR = NULL]
	IF EXISTS
	(	
		SELECT *
		FROM CTRLNFE.DBO.TAB_CTRL_PROCESSAMENTO  AS A , CTRLNFE.DBO.NFE_STATUS AS B
		WHERE 1 = 1
		AND A.DANFE = B.NUM_DANFE
		AND (B.FLG_PREDANFE IS NULL AND B.FLG_ERROPREDANFE IS NULL AND B.FLG_ENTRADAAUTOMATICA IS NULL AND B.FLG_ENTRADAZEUS IS NULL AND FLG_ERROENTRADAAUTOMATICA IS NOT NULL)
		AND A.DANFE = @NUM_DANFE
	)
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_20] --- MARCANDO DANFES QUE ESTAO COM FLAG DE ERRO PRE DANFE PARA REANALISAR, FOR�ANDO REPROCESSAMENTO  --- [MSGERROR = NULL]'
		PRINT ''
	END
	ELSE
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_20] --- NEGA��O - MARCANDO DANFES QUE ESTAO COM FLAG DE ERRO PRE DANFE PARA REANALISAR, FOR�ANDO REPROCESSAMENTO  --- [MSGERROR = NULL]'
		PRINT ''
	END
		
		--DESMARCAR OS ERROR. [FLG_ERROPREDANFE = NULL,	FLG_PREDANFE = NULL]
	IF EXISTS
	(	
		SELECT * FROM CTRLNFE.DBO.NFE_STATUS
		WHERE FLG_PREDANFE IS NULL AND FLG_ERROPREDANFE IS NOT NULL AND FLG_ENTRADAAUTOMATICA IS NULL AND FLG_ENTRADAZEUS IS NULL
		AND NUM_DANFE = @NUM_DANFE
	)
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_20] --- MARCANDO DANFES QUE ESTAO COM FLAG DE ERRO PRE DANFE PARA REANALISAR, FOR�ANDO REPROCESSAMENTO  --- [flg_ErroPreDanfe = NULL,	flg_preDanfe = NULL]'
		PRINT ''
	END
	ELSE
	BEGIN
		PRINT '[UPDATE CtrlNfe_DANFEs_20] --- NEGA��O - MARCANDO DANFES QUE ESTAO COM FLAG DE ERRO PRE DANFE PARA REANALISAR, FOR�ANDO REPROCESSAMENTO  --- [flg_ErroPreDanfe = NULL,	flg_preDanfe = NULL]'
		PRINT ''
	END	
	
	-- ---------------------------------------------------------------------------------------------------------------------------
	--DEFININDO DANFES QUE PRECISAM DE ANALISE DO PRE DANFE
	-- ---------------------------------------------------------------------------------------------------------------------------
	IF EXISTS
	(		
		SELECT 1 FROM  CTRLNFE.DBO.NFE_STATUS	WHERE FLG_PREDANFE IS NULL 
	)
	BEGIN
		PRINT '[CONSULTA CtrlNfe_DANFEs_20] --- PRECISAM DE ANALISE DO PRE DANFE'
		PRINT ''
	END
	ELSE
	BEGIN
		PRINT '[CONSULTA CtrlNfe_DANFEs_20] --- NEGA��O - PRECISAM DE ANALISE DO PRE DANFE'
		PRINT ''
	END	