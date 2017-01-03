		SELECT
			LJ.COD_LOJA
			,PT.ORDERACCOUNT AS COD_FORNECEDOR
			,CONVERT(dATE,PT.CREATEDDATETIME) AS DATA
			,DATEADD(D,F_LT.DIAS_LEAD_TIME,PT.CREATEDDATETIME) AS DTA_ENTREGA_PREVISTA
			,PT.PURCHID AS COD_PEDIDO
			,PL.ITEMID AS COD_PRODUTO
			,PL.QTYORDERED AS QTD_PEDIDO --PL.PURCHQTY
			,PL.LineAmount AS VLR_TOTAL_PEDIDO
			,PT.PURCHSTATUS
		FROM
			SMA_AX50_SP1_DB_PROD.dbo.PURCHTABLE AS PT
			INNER JOIN SMA_AX50_SP1_DB_PROD.dbo.PURCHLINE AS PL
				ON 1=1
				AND PT.DATAAREAID = PL.DATAAREAID
				AND PT.PURCHID = PL.PURCHID
			LEFT JOIN INTEGRACOES.DBO.TAB_LOJA AS LJ
				ON LJ.DATAAREAID = PT.DATAAREAID 
			LEFT JOIN
			(SELECT DISTINCT COD_FORNECEDOR, MIN(DIAS_LEAD_TIME) AS DIAS_LEAD_TIME FROM COMPRAS_AGENDA_PEDIDO_AUTO WHERE FLG_ATIVO = 1 AND TIPO = 1 GROUP BY COD_FORNECEDOR) AS F_LT
				ON PT.ORDERACCOUNT = F_LT.COD_FORNECEDOR
		WHERE 1 = 1
			AND PT.DATAAREAID = 'ORB'
			AND PT.PURCHID LIKE 'CD%0773'