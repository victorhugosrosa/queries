SET NOCOUNT ON
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_ANALISE_LINHA AS TABLE
(
	[COD_LOJA] INT
	,[COD_PRODUTO] INT
	,[FORA_LINHA] VARCHAR(10)
	,[DTA_GRAVACAO] date
)

INSERT INTO @TAB_ANALISE_LINHA
	SELECT
		[COD_LOJA]
		,[COD_PRODUTO]
		,[FORA_LINHA]
		,[DTA_GRAVACAO]
		--,FLG_ATIVO 
	FROM [BI].[dbo].[BI_AUDITORIA_LINHA]
	WHERE 1=1
		--AND FLG_ATIVO = 0
		--AND COD_PRODUTO IN (995264,1001988)
		--AND COD_LOJA = 22
	ORDER BY
		[COD_LOJA]
		,[COD_PRODUTO]
		,[DTA_GRAVACAO]
			
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @COD_LOJA AS INT;
	DECLARE @COD_PRODUTO AS INT;	
	DECLARE @FORA_LINHA AS VARCHAR(50);
	DECLARE @DTA_GRAVACAO AS DATE;
	
	DECLARE @COD_LOJA_OLD AS INT;
	DECLARE @COD_PRODUTO_OLD AS INT;
	DECLARE @FORA_LINHA_OLD AS VARCHAR(50);
	
	DECLARE nome_cursor CURSOR FOR 
		SELECT
			[COD_LOJA]
			,[COD_PRODUTO]
			,[FORA_LINHA]
			,[DTA_GRAVACAO]
		FROM
			@TAB_ANALISE_LINHA
		
	OPEN nome_cursor
	FETCH NEXT FROM nome_cursor 
	INTO @COD_LOJA, @COD_PRODUTO, @FORA_LINHA, @DTA_GRAVACAO	

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------			
			IF (@COD_LOJA = @COD_LOJA_OLD AND @COD_PRODUTO = @COD_PRODUTO_OLD AND @FORA_LINHA = @FORA_LINHA_OLD)
			BEGIN
				DELETE FROM [BI].[dbo].[BI_AUDITORIA_LINHA] WHERE COD_LOJA = @COD_LOJA AND COD_PRODUTO = @COD_PRODUTO AND DTA_GRAVACAO = @DTA_GRAVACAO
				--SELECT @COD_LOJA, @COD_PRODUTO, @FORA_LINHA, @DTA_GRAVACAO
			END
			
			SET @COD_LOJA_OLD = @COD_LOJA
			SET @COD_PRODUTO_OLD = @COD_PRODUTO
			SET @FORA_LINHA_OLD = @FORA_LINHA
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------
		FETCH NEXT FROM nome_cursor 
		INTO @COD_LOJA, @COD_PRODUTO, @FORA_LINHA, @DTA_GRAVACAO
	END 
	CLOSE nome_cursor;
	DEALLOCATE nome_cursor;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE [BI].[dbo].[BI_AUDITORIA_LINHA] SET FLG_ATIVO = 0
	
	DECLARE @TAB_MAX_DATA_AUD AS TABLE
	(
		COD_LOJA INT
		,COD_PRODUTO INT
		,DATA_MAX DATE
	)

	INSERT INTO @TAB_MAX_DATA_AUD
	SELECT
		[COD_LOJA]
		,[COD_PRODUTO]
		,MAX([DTA_GRAVACAO])
	FROM [BI].[dbo].[BI_AUDITORIA_LINHA]  
	GROUP BY
		[COD_LOJA]
		,[COD_PRODUTO]
		
	UPDATE AL
	SET
		AL.FLG_ATIVO = 1
	FROM
		[BI].[dbo].[BI_AUDITORIA_LINHA] AS AL
		INNER JOIN @TAB_MAX_DATA_AUD AS DMAX
			ON 1=1
			AND AL.COD_LOJA = DMAX.COD_LOJA
			AND AL.COD_PRODUTO = DMAX.COD_PRODUTO
			AND AL.DTA_GRAVACAO = DMAX.DATA_MAX