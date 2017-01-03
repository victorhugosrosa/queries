	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- VLR_VENDA / AVG_VENDA
	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
		UPDATE EPD
		SET
			EPD.VLR_VENDA = LINHA.VLR_VENDA
			,EPD.VLR_OFERTA = LINHA.VLR_OFERTA
			,EPD.VLR_VCMARCHE = LINHA.VLR_VCMARCHE
			,EPD.AVG_QTD_U30D_PD = ISNULL(EST.AVG_QTD_U30D_PD,0)
			,EPD.AVG_VLR_U30D_PD = ISNULL(EST.AVG_VLR_U30D_PD,0)
			,EPD.VLR_VENDA_U30D_PD = ISNULL(EST.VLR_VENDA_U30D_PD,0)
		FROM
			BI.dbo.BI_ESTOQUE_PRODUTO_DIA as EPD				
			INNER JOIN BI.DBO.BI_LINHA_PRODUTOS AS LINHA
				ON 1=1
				AND EPD.COD_LOJA = LINHA.COD_LOJA
				AND EPD.COD_PRODUTO = LINHA.COD_PRODUTO
			LEFT JOIN BI.DBO.COMPRAS_ESTATISTICA_PRODUTO AS EST
				ON 1=1
				AND EPD.COD_LOJA = EST.COD_LOJA
				AND EPD.COD_PRODUTO = EST.COD_PRODUTO
		WHERE 1=1
			AND CONVERT(DATE,EPD.DATA) between CONVERT(DATE,@DT_INICIO) and CONVERT(DATE,@DT_TERMINO)
	
	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- VLR_CUSTO_UN
	-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
		UPDATE EPD
		SET
			EPD.VLR_CUSTO_UN = L.VAL_CUSTO_REP
		FROM
			BI.dbo.BI_ESTOQUE_PRODUTO_DIA as EPD				
			INNER JOIN INTEGRACOES.DBO.TAB_PRODUTO_LOJA AS L with(nolock)
				ON 1=1
				AND EPD.COD_LOJA = L.COD_LOJA
				AND EPD.COD_PRODUTO = L.COD_PRODUTO
		WHERE 1=1
			AND CONVERT(DATE,EPD.DATA) between CONVERT(DATE,@DT_INICIO) and CONVERT(DATE,@DT_TERMINO)