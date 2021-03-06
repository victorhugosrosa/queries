	set nocount on;
	
	declare @Destinatario as varchar(max)	
		set @Destinatario = 'victor.rosa@marche.com.br;caio.furlani@marche.com.br;arthur.almeida@marche.com.br'			
		
	declare @HTML_STM varchar(max) = ''
	declare @HTML_STM_TOTAL varchar(max) = ''
	declare @HTML_ESM varchar(max)  = ''
	declare @HTML_ESM_TOTAL varchar(max)  = ''
	declare @HTML_EAT varchar(max)  = ''
	declare @HTML_EAT_TOTAL varchar(max)  = ''
	declare @HTML_TOTAL varchar(max)  = ''
	
	-- ----------------------------------------------------------------------------
	-- @HTML_STM
	-- ----------------------------------------------------------------------------
	IF OBJECT_ID('tempdb.DBO.#TMP_HTML_STM') IS NOT NULL DROP TABLE #TMP_HTML_STM
	
		SELECT
			L.NO_LOJA as [Loja]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL) AS money), 1) AS [Venda]
			,CONVERT(varchar, CAST(M.VLR_META AS money), 1) AS [Meta]
			,convert(varchar,CONVERT(NUMERIC(18,2),(sum(C.VALOR_TOTAL)/M.VLR_META)*100)) + '%' as [Variacao]
			,CONVERT(NUMERIC(18,0),sum(C.QTDE_CUPOM)) AS [Tickets]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL)/sum(C.QTDE_CUPOM) AS money), 1) AS [TM]	
		-- -----------------------
		INTO #TMP_HTML_STM
		-- -----------------------
		FROM
			BI.dbo.BI_VENDA_CUPOM AS C
			LEFT JOIN BI.dbo.BI_VENDA_META AS M
				ON 1=1
				AND C.COD_LOJA = M.COD_LOJA
				AND C.DATA = M.DATA
			LEFT JOIN BI.dbo.BI_CAD_LOJA2 AS L
				ON 1=1
				AND C.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND CONVERT(DATE,C.DATA) = CONVERT(DATE,GETDATE()-1)
			AND L.CLUSTER = 'STM'
		GROUP BY
			L.NO_LOJA
			,M.VLR_META
			,L.DTA_ABERTURA
		ORDER BY
			L.DTA_ABERTURA

	EXECUTE SystemCenterMonitor.dbo.SaveTableAsHTML 
		@DBFetch = 'select * from tempdb.dbo.#TMP_HTML_STM '
		,@HTML_Retorno = @HTML_STM OutPut 
	
	SET @HTML_STM = REPLACE(@HTML_STM,'<td','<td align="center"')
	
	-- ----------------------------------------------------------------------------
	-- @HTML_STM_TOTAL
	-- ----------------------------------------------------------------------------
	IF OBJECT_ID('tempdb.DBO.#TMP_HTML_STM_TOTAL') IS NOT NULL DROP TABLE #TMP_HTML_STM_TOTAL
	
		SELECT
			'Total' as [Loja]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL) AS money), 1) AS [Venda]
			,CONVERT(varchar, CAST(sum(M.VLR_META) AS money), 1) AS [Meta]
			,convert(varchar,CONVERT(NUMERIC(18,2),(sum(C.VALOR_TOTAL)/sum(M.VLR_META))*100)) + '%' as [Variacao]
			,CONVERT(NUMERIC(18,0),sum(C.QTDE_CUPOM)) AS [Tickets]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL)/sum(C.QTDE_CUPOM) AS money), 1) AS [TM]	
		-- -----------------------
		INTO #TMP_HTML_STM_TOTAL
		-- -----------------------
		FROM
			BI.dbo.BI_VENDA_CUPOM AS C
			LEFT JOIN BI.dbo.BI_VENDA_META AS M
				ON 1=1
				AND C.COD_LOJA = M.COD_LOJA
				AND C.DATA = M.DATA
			LEFT JOIN BI.dbo.BI_CAD_LOJA2 AS L
				ON 1=1
				AND C.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND CONVERT(DATE,C.DATA) = CONVERT(DATE,GETDATE()-1)
			AND L.CLUSTER = 'STM'


	EXECUTE SystemCenterMonitor.dbo.SaveTableAsHTML 
		@DBFetch = 'select * from tempdb.dbo.#TMP_HTML_STM_TOTAL '
		,@HTML_Retorno = @HTML_STM_TOTAL OutPut 
	
	SET @HTML_STM_TOTAL = REPLACE(@HTML_STM_TOTAL,'<td','<td align="center"')
	
	-- ----------------------------------------------------------------------------
	-- @HTML_ESM
	-- ----------------------------------------------------------------------------
	IF OBJECT_ID('tempdb.DBO.#TMP_HTML_ESM') IS NOT NULL DROP TABLE #TMP_HTML_ESM
	
		SELECT
			L.NO_LOJA as [Loja]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL) AS money), 1) AS [Venda]
			,CONVERT(varchar, CAST(M.VLR_META AS money), 1) AS [Meta]
			,convert(varchar,CONVERT(NUMERIC(18,2),(sum(C.VALOR_TOTAL)/M.VLR_META)*100)) + '%' as [Variacao]
			,CONVERT(NUMERIC(18,0),sum(C.QTDE_CUPOM)) AS [Tickets]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL)/sum(C.QTDE_CUPOM) AS money), 1) AS [TM]
		-- -----------------------
		INTO #TMP_HTML_ESM
		-- -----------------------
		FROM
			BI.dbo.BI_VENDA_CUPOM AS C
			LEFT JOIN BI.dbo.BI_VENDA_META AS M
				ON 1=1
				AND C.COD_LOJA = M.COD_LOJA
				AND C.DATA = M.DATA
			LEFT JOIN BI.dbo.BI_CAD_LOJA2 AS L
				ON 1=1
				AND C.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND CONVERT(DATE,C.DATA) = CONVERT(DATE,GETDATE()-1)
			AND L.CLUSTER = 'ESM'
		GROUP BY
			L.NO_LOJA
			,M.VLR_META
			,L.DTA_ABERTURA
		ORDER BY
			L.DTA_ABERTURA
	
	EXECUTE SystemCenterMonitor.dbo.SaveTableAsHTML 
		@DBFetch = 'select * from tempdb.dbo.#TMP_HTML_ESM '
		,@HTML_Retorno = @HTML_ESM OutPut 
	
	SET @HTML_ESM = REPLACE(@HTML_ESM,'<td','<td align="center"')
	
	-- ----------------------------------------------------------------------------
	-- @HTML_ESM_TOTAL
	-- ----------------------------------------------------------------------------
	IF OBJECT_ID('tempdb.DBO.#TMP_HTML_ESM_TOTAL') IS NOT NULL DROP TABLE #TMP_HTML_ESM_TOTAL
	
		SELECT
			'Total' as [Loja]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL) AS money), 1) AS [Venda]
			,CONVERT(varchar, CAST(sum(M.VLR_META) AS money), 1) AS [Meta]
			,convert(varchar,CONVERT(NUMERIC(18,2),(sum(C.VALOR_TOTAL)/sum(M.VLR_META))*100)) + '%' as [Variacao]
			,CONVERT(NUMERIC(18,0),sum(C.QTDE_CUPOM)) AS [Tickets]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL)/sum(C.QTDE_CUPOM) AS money), 1) AS [TM]	
		-- -----------------------
		INTO #TMP_HTML_ESM_TOTAL
		-- -----------------------
		FROM
			BI.dbo.BI_VENDA_CUPOM AS C
			LEFT JOIN BI.dbo.BI_VENDA_META AS M
				ON 1=1
				AND C.COD_LOJA = M.COD_LOJA
				AND C.DATA = M.DATA
			LEFT JOIN BI.dbo.BI_CAD_LOJA2 AS L
				ON 1=1
				AND C.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND CONVERT(DATE,C.DATA) = CONVERT(DATE,GETDATE()-1)
			AND L.CLUSTER = 'ESM'

	EXECUTE SystemCenterMonitor.dbo.SaveTableAsHTML 
		@DBFetch = 'select * from tempdb.dbo.#TMP_HTML_ESM_TOTAL '
		,@HTML_Retorno = @HTML_ESM_TOTAL OutPut 
	
	SET @HTML_ESM_TOTAL = REPLACE(@HTML_ESM_TOTAL,'<td','<td align="center"')
	
		
	-- ----------------------------------------------------------------------------
	-- @HTML_EAT
	-- ----------------------------------------------------------------------------
	IF OBJECT_ID('tempdb.DBO.#TMP_HTML_EAT') IS NOT NULL DROP TABLE #TMP_HTML_EAT
	
		SELECT
			L.NO_LOJA as [Loja]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL) AS money), 1) AS [Venda]
			,CONVERT(varchar, CAST(M.VLR_META AS money), 1) AS [Meta]
			,convert(varchar,CONVERT(NUMERIC(18,2),(sum(C.VALOR_TOTAL)/M.VLR_META)*100)) + '%' as [Variacao]
			,CONVERT(NUMERIC(18,0),sum(C.QTDE_CUPOM)) AS [Tickets]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL)/sum(C.QTDE_CUPOM) AS money), 1) AS [TM]
		-- -----------------------
		INTO #TMP_HTML_EAT
		-- -----------------------
		FROM
			BI.dbo.BI_VENDA_CUPOM AS C
			LEFT JOIN BI.dbo.BI_VENDA_META AS M
				ON 1=1
				AND C.COD_LOJA = M.COD_LOJA
				AND C.DATA = M.DATA
			LEFT JOIN BI.dbo.BI_CAD_LOJA2 AS L
				ON 1=1
				AND C.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND CONVERT(DATE,C.DATA) = CONVERT(DATE,GETDATE()-1)
			AND L.CLUSTER = 'EAT'
		GROUP BY
			L.NO_LOJA
			,M.VLR_META
			,L.DTA_ABERTURA
		ORDER BY
			L.DTA_ABERTURA	
	
	EXECUTE SystemCenterMonitor.dbo.SaveTableAsHTML 
		@DBFetch = 'select * from tempdb.dbo.#TMP_HTML_EAT '
		,@HTML_Retorno = @HTML_EAT OutPut 
	
	SET @HTML_EAT = REPLACE(@HTML_EAT,'<td','<td align="center"')
	
	-- ----------------------------------------------------------------------------
	-- @HTML_EAT_TOTAL
	-- ----------------------------------------------------------------------------
	IF OBJECT_ID('tempdb.DBO.#TMP_HTML_EAT_TOTAL') IS NOT NULL DROP TABLE #TMP_HTML_EAT_TOTAL
	
		SELECT
			'Total' as [Loja]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL) AS money), 1) AS [Venda]
			,CONVERT(varchar, CAST(sum(M.VLR_META) AS money), 1) AS [Meta]
			,convert(varchar,CONVERT(NUMERIC(18,2),(sum(C.VALOR_TOTAL)/sum(M.VLR_META))*100)) + '%' as [Variacao]
			,CONVERT(NUMERIC(18,0),sum(C.QTDE_CUPOM)) AS [Tickets]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL)/sum(C.QTDE_CUPOM) AS money), 1) AS [TM]	
		-- -----------------------
		INTO #TMP_HTML_EAT_TOTAL
		-- -----------------------
		FROM
			BI.dbo.BI_VENDA_CUPOM AS C
			LEFT JOIN BI.dbo.BI_VENDA_META AS M
				ON 1=1
				AND C.COD_LOJA = M.COD_LOJA
				AND C.DATA = M.DATA
			LEFT JOIN BI.dbo.BI_CAD_LOJA2 AS L
				ON 1=1
				AND C.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND CONVERT(DATE,C.DATA) = CONVERT(DATE,GETDATE()-1)
			AND L.CLUSTER = 'EAT'

	EXECUTE SystemCenterMonitor.dbo.SaveTableAsHTML 
		@DBFetch = 'select * from tempdb.dbo.#TMP_HTML_EAT_TOTAL '
		,@HTML_Retorno = @HTML_EAT_TOTAL OutPut 
	
	SET @HTML_EAT_TOTAL = REPLACE(@HTML_EAT_TOTAL,'<td','<td align="center"')
	
	
	-- ----------------------------------------------------------------------------
	-- @HTML_TOTAL
	-- ----------------------------------------------------------------------------
	IF OBJECT_ID('tempdb.DBO.#TMP_HTML_TOTAL') IS NOT NULL DROP TABLE #TMP_HTML_TOTAL
	
		SELECT
			'STM+ESM+EAT' as [Loja]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL) AS money), 1) AS [Venda]
			,CONVERT(varchar, CAST(sum(M.VLR_META) AS money), 1) AS [Meta]
			,convert(varchar,CONVERT(NUMERIC(18,2),(sum(C.VALOR_TOTAL)/sum(M.VLR_META))*100)) + '%' as [Variacao]
			,CONVERT(NUMERIC(18,0),sum(C.QTDE_CUPOM)) AS [Tickets]
			,CONVERT(varchar, CAST(sum(C.VALOR_TOTAL)/sum(C.QTDE_CUPOM) AS money), 1) AS [TM]	
		-- -----------------------
		INTO #TMP_HTML_TOTAL
		-- -----------------------
		FROM
			BI.dbo.BI_VENDA_CUPOM AS C
			LEFT JOIN BI.dbo.BI_VENDA_META AS M
				ON 1=1
				AND C.COD_LOJA = M.COD_LOJA
				AND C.DATA = M.DATA
			LEFT JOIN BI.dbo.BI_CAD_LOJA2 AS L
				ON 1=1
				AND C.COD_LOJA = L.COD_LOJA
		WHERE 1=1
			AND CONVERT(DATE,C.DATA) = CONVERT(DATE,GETDATE()-1)
			AND L.CLUSTER in ('STM','ESM','EAT')

	EXECUTE SystemCenterMonitor.dbo.SaveTableAsHTML 
		@DBFetch = 'select * from tempdb.dbo.#TMP_HTML_TOTAL '
		,@HTML_Retorno = @HTML_TOTAL OutPut 
	
	SET @HTML_TOTAL = REPLACE(@HTML_TOTAL,'<td','<td align="center"')
	
	
	-- ###################################################################################################################################################
	--
	-- ###################################################################################################################################################	
	SET @HTML_STM = @HTML_STM + @HTML_STM_TOTAL
	SET @HTML_ESM = @HTML_ESM + @HTML_ESM_TOTAL
	SET @HTML_EAT = @HTML_EAT + @HTML_EAT_TOTAL
	
	exec INTEGRACOES.DBO.ALERTAS_EMAIL_20  
	@Destinatario  , 'Meta Lojas - Diario -' 
	,'STM' , @HTML_STM
	,'ESM' , @HTML_ESM	
	,'EAT' , @HTML_EAT
	,'Total' , @HTML_TOTAL