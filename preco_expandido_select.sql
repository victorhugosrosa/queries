SELECT
	[COD_LOJA]
	,[COD_FORNECEDOR] 
	,[COD_PRODUTO] ,'' as motivo  
	,case when [COD_MOTIVO]=1 then 'Proibido Alterar PV e PO' else case when [COD_MOTIVO]=2 then 'Proibido Alterar PV' else  case when [COD_MOTIVO]=3 then 'Proibido Alterar PO' else  case when [COD_MOTIVO]=4 then 'Alteração Casada' else case when [COD_MOTIVO]=5 then 'Reajuste só com Pesquisa' else 'Falar com a Nat' end end end end END as MOTIVO  
	,[OBS] ,'' 
	,[DTA_INI]  
	,[DTA_FIM]  
	,[COD_USUARIO]  
FROM
	[BI].[dbo].[BI_PRECO_BLOQUEADO_EXPANDIDO] 
where 1=1



SELECT
	COD_LOJA
	,COD_PRODUTO
	,MIN(DTA_INI) AS DTA_INI
	,MAX(DTA_FIM) AS DTA_FIM
	,STUFF(
	(
		SELECT DISTINCT
			NO_MOTIVO + '-' + UPPER(OBS) + ' (' + CONVERT(VARCHAR,COD_USUARIO) + ')  | ' 
		FROM
			[BI].[DBO].[BI_PRECO_BLOQUEADO_EXPANDIDO] AS TBE
			INNER JOIN [BI].[DBO].[BI_PRECO_BLOQUEADO_MOTIVO] AS TBM
				ON TBE.COD_MOTIVO = TBM.COD_MOTIVO
		WHERE  1=1
			AND TBE.COD_PRODUTO = BE.COD_PRODUTO
			AND TBE.COD_LOJA = BE.COD_LOJA
		for xml path('')
	),1,0,'') MOTIVO_USER
	--,BE.*
FROM
	[BI].[DBO].[BI_PRECO_BLOQUEADO_EXPANDIDO] AS BE
WHERE 1=1
	--AND COD_PRODUTO = 1012414
	--AND COD_LOJA = 6
GROUP BY
	COD_LOJA
	,COD_PRODUTO






select
	COD_LOJA
	,COD_PRODUTO
	,COUNT(DISTINCT COD_MOTIVO)
FROM
	[BI].[dbo].[BI_PRECO_BLOQUEADO_EXPANDIDO] 
group by
	COD_LOJA
	,COD_PRODUTO
having
	COUNT(DISTINCT COD_MOTIVO) > 1