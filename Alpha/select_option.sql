/****** Script for SelectTopNRows command from SSMS  ******/
SELECT
	'<option value="' + CONVERT(VARCHAR(5),CC.COD_CONCORRENTE) + '">'
	+ CC.BANDEIRA + '-' + CC.ENDERECO
	+'</option>'
FROM
	[BI].[dbo].[BI_PRECO_MARCHE_CONCORRENTE] AS MC LEFT JOIN [BI].[dbo].[BI_PRECO_CAD_CONCORRENTES] AS CC ON (MC.COD_CONCORRENTE = CC.COD_CONCORRENTE)
WHERE 1 = 1
	and MC.COD_LOJA = 7
ORDER BY
	MC.COD_LOJA


