	DECLARE @DT_INICIO DATE = '20150305'
	DECLARE @DT_TERMINO DATE = '20150307'

	DELETE FROM [BI].[dbo].BI_VENDA_CUPOM
	WHERE 1 = 1
	AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DT_INICIO) AND CONVERT(DATE,@DT_TERMINO)
	AND COD_LOJA = 8
	
	INSERT INTO [BI].[dbo].BI_VENDA_CUPOM
			   ([COD_LOJA]
			   ,[DATA]
			   ,[QTDE_CUPOM]
			   ,[VALOR_TOTAL]
			   ,[CUPOM_MEDIO] 
			   ,TIPO)		
	
	SELECT
		8 AS [COD_LOJA] 
		,C.DATA AS [DATA] 
		,COUNT(DISTINCT C.NUMERO_CUPOM) AS [QTDE_CUPOM]
		,SUM(I.TOTAL) AS [VALOR_TOTAL]
		,AVG(I.TOTAL) AS [CUPOM_MEDIO]
		,2 AS TIPO
	FROM
		[192.168.0.6].Alltec.dbo.CUPONS_FISCAIS AS C
		INNER JOIN [192.168.0.6].Alltec.dbo.ITENS_CUPONS AS I
			ON 1=1
			AND C.COD_LOJA_ALLTEC = I.COD_LOJA_ALLTEC
			AND C.NUMERO_CUPOM = I.NUMERO_CUPOM
			AND CONVERT(DATE,C.DATA) = CONVERT(DATE,I.DATA)
	WHERE 1 = 1
		AND CONVERT(DATE,C.DATA) BETWEEN CONVERT(DATE,@DT_INICIO) AND CONVERT(DATE,@DT_TERMINO)
	GROUP BY
		C.DATA
		
		
	-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DELETE FROM [BI].[dbo].BI_VENDA_PRODUTO
	WHERE 1 = 1
	AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DT_INICIO) AND CONVERT(DATE,@DT_TERMINO)
	AND COD_LOJA = 8
			
	INSERT INTO [BI].[dbo].BI_VENDA_PRODUTO
			   ([COD_LOJA]
			   ,[DATA]
			   ,[COD_PRODUTO]
			   ,[TIPO_VENDA]
			   ,[QTDE_PRODUTO]
			   ,[VALOR_TOTAL]
			   ,[VALOR_UNITARIO]
			   ,[QTDE_DEMANDA]
			   ,[COD_CLIENTE])
	select
		8 AS COD_LOJA
		,ALTEC.DATA
		,isnull(PROD.PLU,999999) AS COD_PRODUTO
		,2 AS TIPO_VENDA 
		,SUM(QTDE) AS QTDE_PRODUTO
		,SUM(TOTAL) AS VALOR_TOTAL
		,0 AS VALOR_UNITARIO
		,COUNT(QTDE) AS QTDE_DEMANDA
		,0 AS COD_CLIENTE
	from
		[192.168.0.6].Alltec.dbo.ITENS_CUPONS as ALTEC left outer join [192.168.0.6].Alltec.dbo.PRODUTO as PROD	on (PROD.CODPRODUTO = ALTEC.PRODUTO	AND PROD.COD_LOJA = ALTEC.COD_lOJA)
	WHERE 1 = 1
		AND CONVERT(DATE,ALTEC.DATA) BETWEEN CONVERT(DATE,@DT_INICIO) AND CONVERT(DATE,@DT_TERMINO)
	GROUP BY
		ALTEC.DATA
		,PROD.PLU