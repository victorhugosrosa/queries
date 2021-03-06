

	DECLARE @TAB_AJUSTE_META_U15D AS TABLE
	(
		COD_LOJA INT
		,PERC_AJUSTE_META_U15D NUMERIC(8,4)
	)
	
	INSERT INTO @TAB_AJUSTE_META_U15D
	SELECT
		VC.COD_LOJA
		,SUM(VC.VALOR_TOTAL)/SUM(VM.VLR_META) as PERC_AJUSTE_META_U15D
	FROM
		BI.dbo.BI_VENDA_CUPOM  AS VC
		LEFT JOIN BI.DBO.BI_VENDA_META AS VM
			ON 1=1
			AND VC.COD_LOJA = VM.COD_LOJA
			AND VC.DATA = VM.DATA
	WHERE 1=1
		AND CONVERT(DATE,VC.DATA) BETWEEN CONVERT(DATE,GETDATE()-30) AND CONVERT(DATE,GETDATE()-1)
	GROUP BY
		VC.COD_LOJA
		
	
	SELECT
		EM.COD_LOJA
		,EM.ANO
		,EM.MES
		,BI.dbo.fn_FormataVlr_Excel(EM.META_ESTOQUE) AS META_ESTOQUE
		,BI.dbo.fn_FormataVlr_Excel((CASE WHEN MES >= MONTH(GETDATE()) THEN EM.META_ESTOQUE*AM.PERC_AJUSTE_META_U15D ELSE EM.AJUSTE_ESTOQUE END)) AS AJUSTE_ESTOQUE
	FROM
		BI_ESTOQUE_META AS EM
		INNER JOIN @TAB_AJUSTE_META_U15D AS AM
			ON EM.COD_LOJA = AM.COD_LOJA
	WHERE 1=1
	ORDER BY
		EM.COD_LOJA
		,EM.ANO
		,EM.MES