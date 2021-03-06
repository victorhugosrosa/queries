PEDIDO_AUTO:
SELECT DISTINCT
	convert(varchar,COD_PEDIDO) AS NUM_PEDIDO
	,(CASE WHEN P.FLG_AUTOMATICO = 1 THEN 'Automatico' ELSE 'Manual' END) as FLG_AUTOMATICO
	,(CASE WHEN P.FLG_CENTRALIZADO = 1 THEN 'Auto/Cross' ELSE (CASE WHEN P.ID_AGENDA IS NULL THEN 'Manual/Entrega Direta' ELSE 'Auto/Entrega Direta' END) END) as FLG_CENTRALIZADO
	,CF2.COD_FORNECEDOR as COD_FORNECEDOR_CENTRALIZADO
	,CF2.DESCRICAO as NO_FORNECEDOR_CENTRALIZADO
	,ISNULL(P.FLG_INTEGRADO_AX,0) AS FLG_INTEGRADO_AX
    ,P.MARCHE_PURCHIDREF
    ,(CASE WHEN P.FLG_INTEGRADO_PURCHTABLE = 1 THEN 'Centralizado' ELSE 'N�o centralizado' END) AS FLG_INTEGRADO_PURCHTABLE
FROM
	BI.DBO.COMPRAS_PEDIDOS AS P
	LEFT JOIN [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A
		ON P.ID_AGENDA = A.ID
	LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF2
		ON A.COD_FORNECEDOR = CF2.COD_FORNECEDOR
WHERE 1=1
	AND P.COD_PEDIDO IS NOT NULL
	AND CONVERT(DATE,DATA) between CONVERT(DATE,'2016-01-01') AND CONVERT(DATE,GETDATE())

UNION ALL	

SELECT DISTINCT
	P.MARCHE_PURCHIDREF AS NUM_PEDIDO
	,(CASE WHEN P.FLG_AUTOMATICO = 1 THEN 'Automatico' ELSE 'Manual' END) as FLG_AUTOMATICO
	,(CASE WHEN P.FLG_CENTRALIZADO = 1 THEN 'Auto/Cross' ELSE (CASE WHEN P.ID_AGENDA IS NULL THEN 'Manual/Entrega Direta' ELSE 'Auto/Entrega Direta' END) END) as FLG_CENTRALIZADO
	,CF2.COD_FORNECEDOR as COD_FORNECEDOR_CENTRALIZADO
	,CF2.DESCRICAO as NO_FORNECEDOR_CENTRALIZADO
	,ISNULL(P.FLG_INTEGRADO_AX,0) AS FLG_INTEGRADO_AX
	,P.MARCHE_PURCHIDREF
    ,(CASE WHEN P.FLG_INTEGRADO_PURCHTABLE = 1 THEN 'Centralizado' ELSE 'N�o centralizado' END) AS FLG_INTEGRADO_PURCHTABLE
FROM
	BI.DBO.COMPRAS_PEDIDOS AS P
	LEFT JOIN [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_AUTO] AS A
		ON P.ID_AGENDA = A.ID
	LEFT JOIN BI.DBO.BI_CAD_FORNECEDOR AS CF2
		ON A.COD_FORNECEDOR = CF2.COD_FORNECEDOR
WHERE 1=1
	AND ISNULL(p.MARCHE_PURCHIDREF,'') <> ''
	AND P.COD_PEDIDO IS NOT NULL
	AND CONVERT(DATE,DATA) between CONVERT(DATE,'2016-01-01') AND CONVERT(DATE,GETDATE());