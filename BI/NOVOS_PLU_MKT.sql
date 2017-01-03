DECLARE @TAB_MKT_NEW AS TABLE
(
	NO_DEPARTAMENTO VARCHAR(50)
	,NO_SECAO VARCHAR(50)
	,NO_GRUPO VARCHAR(50)
	,DESCRICAO VARCHAR(50)
	,COD_PRODUTO INT
	,FLG_MARCA_PROPRIA INT
	,PESADO VARCHAR(5)
	,VLR_TOTAL NUMERIC(18,2)
	,QTD_TOTAL NUMERIC(18,2)
	,QTD_LOJAS_VENDA INT
)

INSERT INTO @TAB_MKT_NEW
	SELECT
		CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,CP.DESCRICAO AS NO_PRODUTO
		,CP.COD_PRODUTO
		,CP.FLG_MARCA_PROPRIA
		,CP.PESADO
		,SUM(VP.VALOR_TOTAL) AS VLR_TOTAL
		,SUM(VP.QTDE_PRODUTO) AS QTD_TOTAL
		,COUNT(DISTINCT VP.COD_LOJA) QTD_LOJAS_VENDA
	FROM
		BI.dbo.BI_VENDA_PRODUTO AS VP
		INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP
			ON VP.COD_PRODUTO = CP.COD_PRODUTO	
	WHERE 1 = 1
		AND VP.COD_PRODUTO IN (SELECT DISTINCT [ITEMID] FROM [BI].[dbo].[CADASTRO_CAD_PRODUTO_NOVO] WHERE FLG_PRODUTO_NOVO = 1 AND CONVERT(DATE,DTA_GRAVACAO) between CONVERT(DATE,'20150701') and CONVERT(DATE,'20150731') )
		AND VP.COD_LOJA <> 7
	GROUP BY
		CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,CP.DESCRICAO
		,CP.COD_PRODUTO
		,CP.FLG_MARCA_PROPRIA
		,CP.PESADO
	ORDER BY
		CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,CP.DESCRICAO

SELECT
	NO_DEPARTAMENTO
	,NO_SECAO
	,NO_GRUPO
	,DESCRICAO 
	,COD_PRODUTO
	,FLG_MARCA_PROPRIA 
	,PESADO
	,BI.DBO.fn_FormataVlr_Excel(VLR_TOTAL) AS VLR_TOTAL
	,BI.DBO.fn_FormataVlr_Excel(QTD_TOTAL) AS QTD_TOTAL
	,QTD_LOJAS_VENDA
	,(SELECT COUNT(DISTINCT COD_LOJA) FROM BI_LINHA_PRODUTOS AS LP WHERE LP.COD_PRODUTO = TM.COD_PRODUTO AND LP.FORA_LINHA = 'N') AS QTD_LOJAS_LINHA
FROM
	@TAB_MKT_NEW AS TM