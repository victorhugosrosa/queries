DECLARE @CONTADOR AS INT;
DECLARE @COD_PRODUTO AS INT;
DECLARE @COD_FORNECEDOR AS INT;
DECLARE @NO_PRODUTO AS VARCHAR(50);
DECLARE @FL AS VARCHAR(50);

DECLARE nome_cursor CURSOR FOR 
	SELECT TOP 1000 COD_PRODUTO, DESCRICAO, FORA_LINHA FROM BI_CAD_PRODUTO
	
OPEN nome_cursor
FETCH NEXT FROM nome_cursor 
INTO @COD_PRODUTO, @NO_PRODUTO, @FL

WHILE @@FETCH_STATUS = 0
BEGIN
	-- -------------------------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------	
		SET @CONTADOR = 1
		PRINT @NO_PRODUTO
		
		DECLARE nome_cursor2 CURSOR FOR 
			SELECT COD_FORNECEDOR FROM BI_CAD_FORNECEDOR_PRODUTO WHERE COD_PRODUTO = @COD_PRODUTO		
		OPEN nome_cursor2
		FETCH NEXT FROM nome_cursor2 
		INTO @COD_FORNECEDOR

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- -------------------------------------------------------------------------------------
			-- -------------------------------------------------------------------------------------
				PRINT '      ' + CONVERT(VARCHAR,@COD_FORNECEDOR)
				PRINT @CONTADOR
				SET @CONTADOR = @CONTADOR + 1
				
			-- -------------------------------------------------------------------------------------
			-- -------------------------------------------------------------------------------------
			FETCH NEXT FROM nome_cursor2 
			INTO @COD_FORNECEDOR
		END 
		CLOSE nome_cursor2;
		DEALLOCATE nome_cursor2;
	-- -------------------------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------
    FETCH NEXT FROM nome_cursor 
    INTO @COD_PRODUTO, @NO_PRODUTO, @FL
END 
CLOSE nome_cursor;
DEALLOCATE nome_cursor;