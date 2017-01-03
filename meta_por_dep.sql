

SELECT
	YEAR(m.DATA) as ano
	,month(m.DATA) as mes
	,l.[COD_LOJA]
	,l.NO_LOJA
	,DES_DEP.NO_DEPARTAMENTO
	,BI.dbo.fn_FormataVlr_Excel(SUM(m.[VLR_META])) as [Meta]
FROM 
	[BI].[dbo].[BI_VENDA_META_GRUPO] as m
	INNER JOIN BI.dbo.BI_CAD_LOJA2 as l
		ON 1=1
		and l.COD_LOJA = m.COD_LOJA
		and l.FLG_LOJA = 1
	INNER JOIN
	(
		SELECT DISTINCT 
			COD_DEPARTAMENTO
			,NO_DEPARTAMENTO
		FROM
			[BI].[dbo].[BI_CAD_HIERARQUIA_PRODUTO]
	) AS DES_DEP ON M.COD_DEPARTAMENTO = DES_DEP.COD_DEPARTAMENTO
	
where 1=1 
	and m.DATA between convert(date,'20150101') and convert(date,'20151231')
group by
	YEAR(m.DATA)
	,month(m.DATA)
	,l.[COD_LOJA]
	,l.NO_LOJA
	,DES_DEP.NO_DEPARTAMENTO
order by
	YEAR(m.DATA)
	,month(m.DATA)
	,l.[COD_LOJA]
	,l.NO_LOJA
	,DES_DEP.NO_DEPARTAMENTO
