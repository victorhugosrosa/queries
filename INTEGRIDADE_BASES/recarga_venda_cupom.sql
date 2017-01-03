DECLARE @DATA_INI AS DATE = '2016-05-01'
DECLARE @DATA_FIM AS DATE = '2016-08-31'

DECLARE @COD_LOJA AS INT
DECLARE @DATA AS DATE
DECLARE @VALOR AS NUMERIC(18,3)

WHILE @DATA_INI <= @DATA_FIM
BEGIN
	--EXEC BI.DBO.[CARGA_BI_VENDA_CUPOM_POR_LOJA] @DATA_INI, @DATA_INI, 33	
	--EXEC BI.DBO.[CARGA_BI_VENDA_CUPOM_POR_LOJA] @DATA_INI, @DATA_INI, 8

	DECLARE nome_cursor CURSOR FOR 
		SELECT
			COD_LOJA
			,CONVERT(DATE,DATA) as dta
			,SUM(VALOR_TOTAL) as vlr_total
		FROM DW.dbo.BI_ANAL_MOVTO_CAIXA
		WHERE 1 = 1
			AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			COD_LOJA
			,DATA
						
		EXCEPT
		
		SELECT
			COD_LOJA
			,CONVERT(DATE,DATA)  as dta
			,SUM(VALOR_TOTAL) as vlr_total
		FROM BI.dbo.BI_VENDA_cupom
		WHERE 1 = 1
			AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			COD_LOJA
			,DATA
		
	OPEN nome_cursor
	FETCH NEXT FROM nome_cursor 
	INTO @COD_LOJA, @DATA, @VALOR

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------	
			PRINT 'Recarregando: Loja[' + convert(varchar,@COD_LOJA) + '] Data['+ convert(varchar,@DATA,101) + ']'
			EXEC BI.DBO.[CARGA_BI_VENDA_CUPOM_POR_LOJA] @DATA, @DATA, @COD_LOJA		
			EXEC BI.[dbo].[CARGA_BI_VENDA_CUPOM_CAPA_POR_LOJA] @DATA, @DATA, @COD_LOJA	
		-- -------------------------------------------------------------------------------------
		-- -------------------------------------------------------------------------------------
		FETCH NEXT FROM nome_cursor 
		INTO @COD_LOJA, @DATA, @VALOR
	END 
	CLOSE nome_cursor;
	DEALLOCATE nome_cursor;
	
	SET @DATA_INI = DATEADD(d,1,@DATA_INI)

END



		
		
		
		
		
		
		
		
		
		
			
		
		
		
		