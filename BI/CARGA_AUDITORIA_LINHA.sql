	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- INSERT INICIAL DA TABELA
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE [BI].[dbo].[BI_AUDITORIA_LINHA];
	
	INSERT INTO [BI].[dbo].[BI_AUDITORIA_LINHA]
	(
		[COD_LOJA]
		,[COD_PRODUTO]
		,[COD_DEPARTAMENTO]
		,[COD_SECAO]
		,[COD_GRUPO]
		,[COD_SUBGRUPO]
		,[FORA_LINHA]
		,[ENVIA_PDV]
		,[DTA_GRAVACAO]
		,[FLG_ATIVO]
	)
	SELECT 
		[COD_LOJA]
		,[COD_PRODUTO]
		,[COD_DEPARTAMENTO]
		,[COD_SECAO]
		,[COD_GRUPO]
		,[COD_SUBGRUPO]
		,[FORA_LINHA]
		,[ENVIA_PDV]
		,GETDATE()
		,1
	FROM
		[BI].[dbo].[BI_LINHA_PRODUTOS] as LP
	WHERE 1 = 1
		--AND [FORA_LINHA] = 'N'

	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- CRIANDO TEMPORARIA PARA VERIFICAR MUDANÇAS DE LINHA
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_AUD AS TABLE
	(
		[COD_LOJA] INT
		,[COD_PRODUTO] INT
		,[FORA_LINHA] VARCHAR(1)
		,[DTA_GRAVACAO] DATE
	)

	INSERT INTO @TAB_AUD
	SELECT
		LP.[COD_LOJA]
		,LP.[COD_PRODUTO]
		,LP.[FORA_LINHA]
		,GETDATE()
	FROM
		[BI].[dbo].[BI_LINHA_PRODUTOS] as LP LEFT JOIN [BI].[dbo].[BI_AUDITORIA_LINHA] AS AL
		ON (1 = 1
		AND LP.[COD_LOJA] = AL.[COD_LOJA]
		AND LP.[COD_PRODUTO] = AL.[COD_PRODUTO]
		)
	WHERE 1 = 1
		AND LP.FORA_LINHA <> AL.FORA_LINHA

	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- MARCANDO COMO INATIVOS NO HISTORICO DE PRODUTOS
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE AL
	SET
		AL.FLG_ATIVO = 0
	FROM
		[BI].[dbo].[BI_AUDITORIA_LINHA] AS AL INNER JOIN @TAB_AUD  AS TEMP
		ON (1 = 1
		AND AL.[COD_LOJA] = TEMP.[COD_LOJA]
		AND AL.[COD_PRODUTO] = TEMP.[COD_PRODUTO]
		)
	WHERE 1 = 1
		AND CONVERT(DATE,AL.DTA_GRAVACAO) < CONVERT(DATE,TEMP.DTA_GRAVACAO)

	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- INSERÇÃO DOS NOVOS REGISTROS
	-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO [BI].[dbo].[BI_AUDITORIA_LINHA]
	(
		[COD_LOJA]
		,[COD_PRODUTO]
		,[COD_DEPARTAMENTO]
		,[COD_SECAO]
		,[COD_GRUPO]
		,[COD_SUBGRUPO]
		,[FORA_LINHA]
		,[ENVIA_PDV]
		,[DTA_GRAVACAO]
		,[FLG_ATIVO]
	)
	SELECT
		LP.[COD_LOJA]
		,LP.[COD_PRODUTO]
		,LP.[COD_DEPARTAMENTO]
		,LP.[COD_SECAO]
		,LP.[COD_GRUPO]
		,LP.[COD_SUBGRUPO]
		,LP.[FORA_LINHA]
		,LP.[ENVIA_PDV]
		,GETDATE()
		,1
	FROM
		[BI].[dbo].[BI_LINHA_PRODUTOS] as LP LEFT JOIN [BI].[dbo].[BI_AUDITORIA_LINHA] AS AL
		ON (1 = 1
		AND LP.[COD_LOJA] = AL.[COD_LOJA]
		AND LP.[COD_PRODUTO] = AL.[COD_PRODUTO]
		)
	WHERE 1 = 1
		AND LP.FORA_LINHA <> AL.FORA_LINHA
		