

	SET NOCOUNT ON;
	DECLARE @DATA_INI AS DATE = CONVERT(DATE,'2015-02-01')
	DECLARE @DATA_FIM AS DATE = CONVERT(DATE,'2016-02-29')--CONVERT(DATE,'2016-02-29')
	
	/*
	CREATE TABLE BI.DBO.TAB_MAX_DATE_AVG 
	(
		ANO INT
		,MES INT
		,COD_LOJA INT
		,COD_PRODUTO INT
		,MAX_DATA DATE
		,MIN_DATA DATE
		,AVG_QTD_U180D NUMERIC(18,2)
		,PRIMARY KEY (ANO, MES, COD_LOJA, COD_PRODUTO)
	)
	*/
	/*
	INSERT INTO BI.DBO.TAB_MAX_DATE_AVG	
		SELECT
			ANO
			,MES
			,COD_LOJA
			,COD_PRODUTO
			,MAX_DATA
			,DATEADD(D,-180,MAX_DATA) AS MIN_DATA	
			,NULL	
		FROM	
		(
			SELECT
				YEAR(VP.DATA) AS ANO
				,MONTH(VP.DATA) AS MES
				,VP.COD_LOJA
				,VP.COD_PRODUTO
				,MAX(VP.DATA) AS MAX_DATA
			FROM
				BI.dbo.BI_VENDA_PRODUTO AS VP
				INNER JOIN BI.DBO.SUPPLY_PRODUTO_RUPTURA AS PR
					ON VP.COD_PRODUTO = PR.COD_PRODUTO
			WHERE 1=1	
				AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DATA_INI) AND CONVERT(DATE,@DATA_FIM)
			GROUP BY
				YEAR(VP.DATA)
				,MONTH(VP.DATA)
				,VP.COD_LOJA
				,VP.COD_PRODUTO
		) AS T
	*/
	
	UPDATE MD
	SET
		AVG_QTD_U180D = (
			SELECT SUM(QTDE_PRODUTO)/180 FROM BI.dbo.BI_VENDA_PRODUTO AS VP
			WHERE 1=1
				AND VP.COD_LOJA = MD.COD_LOJA
				AND VP.COD_PRODUTO = MD.COD_PRODUTO
				AND VP.DATA BETWEEN CONVERT(DATE,MIN_DATA) AND CONVERT(DATE,MAX_DATA)
		)
	FROM
		TAB_MAX_DATE_AVG AS MD
	WHERE 1=1
		and AVG_QTD_U180D is null
	
	
	/*
	--DECLARE @TAB_AVG AS TABLE
	--(
	--	ANO INT
	--	,MES INT
	--	,COD_LOJA INT
	--	,COD_PRODUTO INT
	--	,VLR_TOTAL NUMERIC(18,2)
	--	,QTD_TOTAL NUMERIC(18,2)
	--)
	--INSERT INTO @TAB_AVG		
		SELECT TOP 10
			MD.MAX_DATA
			,VP.COD_LOJA
			,VP.COD_PRODUTO
			,SUM(CASE WHEN CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,MD.MIN_DATA) AND CONVERT(DATE,MD.MAX_DATA) THEN VALOR_TOTAL END) AS VLR_TOTAL
			,SUM(CASE WHEN CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,MD.MIN_DATA) AND CONVERT(DATE,MD.MAX_DATA) THEN QTDE_PRODUTO END) AS QTD_TOTAL
		FROM
			BI.dbo.BI_VENDA_PRODUTO AS VP
			INNER JOIN @TAB_MAX_DATE_AVG AS MD
				ON 1=1
				AND VP.COD_LOJA = MD.COD_LOJA
				AND VP.COD_PRODUTO = MD.COD_PRODUTO
				AND YEAR(VP.DATA) = MD.ANO
				AND MONTH(VP.DATA) = MD.MES
				
		WHERE 1=1	
			AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,'2014-06-01') AND CONVERT(DATE,@DATA_FIM)
		GROUP BY
			MD.MAX_DATA
			,VP.COD_LOJA
			,VP.COD_PRODUTO
			
	*/