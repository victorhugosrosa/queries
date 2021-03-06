	-- -----------------------------------------------------------------------------------
	-- Venda de 1 Ano (Para ponderar e para filtrar apenas itens pesqusiados com venda)
	-- -----------------------------------------------------------------------------------
	DECLARE @TAB_1ANO AS TABLE
	(
		COD_PRODUTO INT 
		,QTD_VENDA_1ANO NUMERIC(18,2)
		,VLR_VENDA_1ANO NUMERIC(18,2)
	)
	INSERT INTO @TAB_1ANO
	SELECT
		COD_PRODUTO
		,SUM(QTDE_PRODUTO_1ANO)
		,SUM(VLR_TOTAL_1ANO)
	FROM
		[BI].[dbo].BI_LINHA_PRODUTOS as LP
	where 1 = 1
		AND COD_LOJA not in (5,7)
		AND COD_DEPARTAMENTO not in (4)
		--AND COD_PRODUTO = 153713
	GROUP BY
		COD_PRODUTO

	-- -----------------------------------------------------------------------------------
	-- Site
	-- -----------------------------------------------------------------------------------
	DECLARE @TAB_PRECO_PA AS TABLE
	(
		DATA DATE
		,COD_PRODUTO INT
		,VLR_VENDA NUMERIC(18,2)
		,VLR_VENDA_PESQUISA NUMERIC(18,2)
		,VLR_VENDA_1ANO NUMERIC(18,2)
	)
	
	INSERT INTO @TAB_PRECO_PA
	SELECT
		CONVERT(DATE,EXT.DATA_EXTRACAO) AS DATA
		,EXT.COD_PRODUTO		
		,EXT.VLR_VENDA_MARCHE AS VLR_VENDA
		,EXT.VLR_PRODUTO AS VLR_VENDA_PESQUISA
		,T1.VLR_VENDA_1ANO
	FROM
		[BI].[DBO].[BI_PRECOS_TERCEIROS] AS EXT
		INNER JOIN BI.dbo.BI_CAD_SEMANA AS S
			ON EXT.DATA_EXTRACAO = S.DATA		
		INNER JOIN @TAB_1ANO AS T1
			ON (EXT.COD_PRODUTO = T1.COD_PRODUTO AND T1.QTD_VENDA_1ANO>0)
	WHERE 1=1
		AND EXT.COD_PRODUTO IS NOT NULL
		AND T1.VLR_VENDA_1ANO > 0
		AND CONVERT(DATE,DATA_EXTRACAO) >= CONVERT(DATE,GETDATE()-28)
		AND PROMOCAO = 0
		--AND EXT.COD_PRODUTO = 153713
		
	-- -----------------------------------------------------------------------------------
	-- 
	-- -----------------------------------------------------------------------------------
	SELECT
		DATA
		--,COD_PRODUTO
		--,VLR_VENDA
		--,VLR_VENDA_PESQUISA
		--,VLR_VENDA_1ANO
		,BI.dbo.fn_FormataVlr_Excel((sum(VLR_VENDA_1ANO*VLR_VENDA)/sum(VLR_VENDA_PESQUISA*VLR_VENDA_1ANO))-1) AS [∆% Preço]
	FROM
		@TAB_PRECO_PA AS T
		INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON T.COD_PRODUTO = CP.COD_PRODUTO
	WHERE 1=1
		AND CP.COD_DEPARTAMENTO NOT IN (21,8)
		--AND CONVERT(DATE,DATA) = '2015-09-01'
	GROUP BY
		DATA
		--,COD_PRODUTO
		--,VLR_VENDA
		--,VLR_VENDA_PESQUISA
		--,VLR_VENDA_1ANO
	ORDER BY
		DATA DESC
		
	-- -----------------------------------------------------------------------------------
	-- 
	-- -----------------------------------------------------------------------------------
	SELECT
		DATA
		--,COD_PRODUTO
		--,VLR_VENDA
		--,VLR_VENDA_PESQUISA
		--,VLR_VENDA_1ANO
		,NO_DEPARTAMENTO
		,NO_COMPRADOR
		,BI.dbo.fn_FormataVlr_Excel(sum(VLR_VENDA_1ANO*VLR_VENDA)) AS [VLR_VENDA_PD]
		,BI.dbo.fn_FormataVlr_Excel(sum(VLR_VENDA_PESQUISA*VLR_VENDA_1ANO)) AS [VLR_VENDA_PESQUISA_PD]
		--,BI.dbo.fn_FormataVlr_Excel((sum(VLR_VENDA_1ANO*VLR_VENDA)/sum(VLR_VENDA_PESQUISA*VLR_VENDA_1ANO))-1) AS [∆% Preço]
	FROM
		@TAB_PRECO_PA AS T
		INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON T.COD_PRODUTO = CP.COD_PRODUTO
		INNER JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC
			ON CP.COD_USUARIO = CC.COD_USUARIO
	WHERE 1=1
		AND CP.COD_DEPARTAMENTO NOT IN (21,8)
		AND CONVERT(DATE,DATA) = CONVERT(DATE,GETDATE())
	GROUP BY
		DATA
		,NO_DEPARTAMENTO
		,NO_COMPRADOR
		--,COD_PRODUTO
		--,VLR_VENDA
		--,VLR_VENDA_PESQUISA
		--,VLR_VENDA_1ANO
	ORDER BY
		DATA DESC