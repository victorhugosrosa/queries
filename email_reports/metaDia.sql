
					
	set nocount on
	
	declare @Destinatario as varchar(max)	
		set @Destinatario = 'victor.rosa@marche.com.br'			
		
	declare @HTML_STM varchar(max) = ''
	declare @HTML_ESM varchar(max)  = ''
	declare @HTML_EAT varchar(max)  = ''

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
	
	exec INTEGRACOES.DBO.ALERTAS_EMAIL_20  
	@Destinatario  , 'Meta Lojas 12h' 
	,'STM' , @HTML_STM
	,'ESM' , @HTML_ESM	
	,'Total', ''
	







