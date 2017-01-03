-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select --top 10
	CP.NO_SECAO
	,SUM(CUPOM_ITEM.M03AP) AS VENDA_SECAO
	--,SUM(CASE WHEN CAD_META.COD_METADADO = 3 AND VLR_METADADO = 1 THEN CUPOM_ITEM.M03AP ELSE NULL END) AS VENDA_IMPORTADO
	--,SUM(CASE WHEN CAD_META.COD_METADADO = 4 AND VLR_METADADO = 1 THEN CUPOM_ITEM.M03AP ELSE NULL END) AS VENDA_IMPORTACAO_PROPRIA
from
	[ZeusRetail].[dbo].[Zan_M01] as CUPOM INNER JOIN [ZeusRetail].[dbo].[Zan_M03] as CUPOM_ITEM ON (CUPOM.M00AD = CUPOM_ITEM.M00AD AND CUPOM.M00ZA = CUPOM_ITEM.M00ZA AND CUPOM.M00AC = CUPOM_ITEM.M00AC)
		LEFT JOIN [AX2009_INTEGRACAO].[dbo].[TAB_CODIGO_BARRA] AS CB ON (cast(CUPOM_ITEM.M03AH as double precision) = cast(cb.COD_EAN as double precision))
			LEFT JOIN BI_CAD_PRODUTO AS CP ON (cast(CB.COD_PRODUTO as double precision)= cast(CP.COD_PRODUTO as double precision))
				--LEFT JOIN CADASTRO_CAD_PRODUTO_METADADOS AS CAD_META ON (CB.COD_PRODUTO = CAD_META.COD_PRODUTO)
WHERE 1 = 1
	AND CONVERT(DATE,CUPOM.M00AF) >= CONVERT(DATE,GETDATE()-360)
	AND CUPOM.M00ZA <> 7
	--AND CUPOM.M00AC = 14
	--AND CUPOM.M00AD = 120778
GROUP BY
	CP.NO_SECAO
ORDER BY
	CP.NO_SECAO


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select --top 10
	CP.NO_SECAO
	,SUM(CUPOM_ITEM.M03AP) AS VENDA_SECAO_IMPORTADO
	--,SUM(CASE WHEN CAD_META.COD_METADADO = 3 AND VLR_METADADO = 1 THEN CUPOM_ITEM.M03AP ELSE NULL END) AS VENDA_IMPORTADO
	--,SUM(CASE WHEN CAD_META.COD_METADADO = 4 AND VLR_METADADO = 1 THEN CUPOM_ITEM.M03AP ELSE NULL END) AS VENDA_IMPORTACAO_PROPRIA
from
	[ZeusRetail].[dbo].[Zan_M01] as CUPOM INNER JOIN [ZeusRetail].[dbo].[Zan_M03] as CUPOM_ITEM ON (CUPOM.M00AD = CUPOM_ITEM.M00AD AND CUPOM.M00ZA = CUPOM_ITEM.M00ZA AND CUPOM.M00AC = CUPOM_ITEM.M00AC)
		LEFT JOIN [AX2009_INTEGRACAO].[dbo].[TAB_CODIGO_BARRA] AS CB ON (cast(CUPOM_ITEM.M03AH as double precision) = cast(cb.COD_EAN as double precision))
			LEFT JOIN BI_CAD_PRODUTO AS CP ON (cast(CB.COD_PRODUTO as double precision)= cast(CP.COD_PRODUTO as double precision))
				LEFT JOIN CADASTRO_CAD_PRODUTO_METADADOS AS CAD_META ON (CB.COD_PRODUTO = CAD_META.COD_PRODUTO)
WHERE 1 = 1
	AND CONVERT(DATE,CUPOM.M00AF) >= CONVERT(DATE,GETDATE()-360)
	AND CAD_META.COD_METADADO = 3 AND CAD_META.VLR_METADADO = 1
	AND CUPOM.M00ZA <> 7
	--AND CUPOM.M00AC = 14
	--AND CUPOM.M00AD = 120778
GROUP BY
	CP.NO_SECAO
ORDER BY
	CP.NO_SECAO


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select --top 10
	CP.NO_SECAO
	,SUM(CUPOM_ITEM.M03AP) AS VENDA_SECAO_IMPORTACAO_PROPRIA
	--,SUM(CASE WHEN CAD_META.COD_METADADO = 3 AND VLR_METADADO = 1 THEN CUPOM_ITEM.M03AP ELSE NULL END) AS VENDA_IMPORTADO
	--,SUM(CASE WHEN CAD_META.COD_METADADO = 4 AND VLR_METADADO = 1 THEN CUPOM_ITEM.M03AP ELSE NULL END) AS VENDA_IMPORTACAO_PROPRIA
from
	[ZeusRetail].[dbo].[Zan_M01] as CUPOM INNER JOIN [ZeusRetail].[dbo].[Zan_M03] as CUPOM_ITEM ON (CUPOM.M00AD = CUPOM_ITEM.M00AD AND CUPOM.M00ZA = CUPOM_ITEM.M00ZA AND CUPOM.M00AC = CUPOM_ITEM.M00AC)
		LEFT JOIN [AX2009_INTEGRACAO].[dbo].[TAB_CODIGO_BARRA] AS CB ON (cast(CUPOM_ITEM.M03AH as double precision) = cast(cb.COD_EAN as double precision))
			LEFT JOIN BI_CAD_PRODUTO AS CP ON (cast(CB.COD_PRODUTO as double precision)= cast(CP.COD_PRODUTO as double precision))
				LEFT JOIN CADASTRO_CAD_PRODUTO_METADADOS AS CAD_META ON (CB.COD_PRODUTO = CAD_META.COD_PRODUTO)
WHERE 1 = 1
	AND CONVERT(DATE,CUPOM.M00AF) >= CONVERT(DATE,GETDATE()-360)
	AND CAD_META.COD_METADADO = 4 AND CAD_META.VLR_METADADO = 1
	AND CUPOM.M00ZA <> 7
	--AND CUPOM.M00AC = 14
	--AND CUPOM.M00AD = 120778
GROUP BY
	CP.NO_SECAO
ORDER BY
	CP.NO_SECAO
	
	