select --top 100
	M00ZA
	,SUM(M03AP)
FROM  [ZeusRetail].dbo.Zan_M03 with (NOLOCK)
where 1 = 1
--and M00ZA = 13
and CONVERT (date, M00AF) between CONVERT (date, '20130901') and CONVERT (date, '20130930')
and CAST(M03AH AS DOUBLE PRECISION) IN
(
	select
		CAST(COD_EAN AS DOUBLE PRECISION)
	FROM
		[AX2009_INTEGRACAO].[dbo].[TAB_CODIGO_BARRA] AS CB inner join [BI].DBO.[BI_CAD_PRODUTO] AS P on (cb.cod_produto = p.cod_produto)
	where 1 = 1
		and p.cod_secao = 25
)
group by
	M00ZA
order by M00ZA