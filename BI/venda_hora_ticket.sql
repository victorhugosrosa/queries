SELECT
	M00ZA AS Loja
	--,M00AF AS Data
	,LEFT ( REPLACE(STR(M01AI, 4, 0), ' ','0'),  2 ) AS Hora
	,bi.dbo.fn_FormataVlr_Excel(SUM(M01AK)) AS [Valor]
	,bi.dbo.fn_FormataVlr_Excel(COUNT(M00AD)) AS [Tickets]
	--,COUNT(DISTINCT M00AF) AS Dias
	,bi.dbo.fn_FormataVlr_Excel(COUNT(M00AD)/COUNT(DISTINCT M00AF)) AS [Tickets/Dia]
	,bi.dbo.fn_FormataVlr_Excel(SUM(M01AK)/COUNT(DISTINCT M00AF)) AS [Valor/Dia]
	--,M00ZA as CodLoja

FROM
	ZeusRetail.dbo.Zan_M01 with (NOLOCK)
where 1 = 1
	and CONVERT(date,M00AF) between CONVERT(date,'20131201') and CONVERT(date,'20131231')
	and M01AK > 0
	and M00ZA = 2
GROUP BY
	M00ZA
	--,M00AF
	,LEFT ( REPLACE(STR(M01AI, 4, 0), ' ','0'),  2 )
ORDER BY 1,2,3,4