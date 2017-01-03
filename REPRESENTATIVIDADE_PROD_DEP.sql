-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_DEP
-- -------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_VENDA_DEP AS TABLE
(
	NO_DEPARTAMENTO VARCHAR(50)
	,NO_SECAO VARCHAR(50)
	,NO_GRUPO VARCHAR(50)
	,VLR_TOTAL_1ANO NUMERIC(18,2)
)

INSERT INTO @TAB_VENDA_DEP
	SELECT --TOP 10
		CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,SUM(VLR_TOTAL_1ANO) AS VLR_TOTAL_1ANO
	FROM
		BI_LINHA_PRODUTOS AS LP
		INNER JOIN BI_CAD_PRODUTO AS CP
			ON 1=1
			AND LP.COD_PRODUTO = CP.COD_PRODUTO
	WHERE 1=1
		AND COD_LOJA IN (7,13)
		AND LP.FORA_LINHA = 'N'
	GROUP BY
		CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- @TAB_VENDA_PROD
-- -------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_VENDA_PROD AS TABLE
(
	NO_DEPARTAMENTO VARCHAR(50)
	,NO_SECAO VARCHAR(50)
	,NO_GRUPO VARCHAR(50)
	,COD_PRODUTO INT
	,NO_PRODUTO VARCHAR(50)
	,VLR_TOTAL_1ANO NUMERIC(18,2)
)

INSERT INTO @TAB_VENDA_PROD
	SELECT --TOP 10
		CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,CP.COD_PRODUTO
		,CP.DESCRICAO AS NO_PRODUTO
		,SUM(LP.VLR_TOTAL_1ANO) AS VLR_TOTAL_1ANO
	FROM
		BI_LINHA_PRODUTOS AS LP
		INNER JOIN BI_CAD_PRODUTO AS CP
			ON 1=1
			AND LP.COD_PRODUTO = CP.COD_PRODUTO
			AND LP.FORA_LINHA = 'N'
	WHERE 1=1
		AND COD_LOJA IN (7,13)
	GROUP BY
		CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,CP.COD_PRODUTO
		,CP.DESCRICAO
	ORDER BY
		CP.NO_DEPARTAMENTO
		,CP.NO_SECAO
		,CP.NO_GRUPO
		,SUM(LP.VLR_TOTAL_1ANO) DESC

-- -------------------------------------------------------------------------------------------------------------------------------------------
--
-- -------------------------------------------------------------------------------------------------------------------------------------------
	SELECT
		VP.NO_DEPARTAMENTO
		,VP.NO_SECAO
		,VP.NO_GRUPO
		,VP.COD_PRODUTO
		,VP.NO_PRODUTO
		,BI.dbo.fn_FormataVlr_Excel(VP.VLR_TOTAL_1ANO) AS VENDA_PROD
		,BI.dbo.fn_FormataVlr_Excel(VD.VLR_TOTAL_1ANO) AS VENDA_DEP
		,BI.dbo.fn_FormataVlr_Excel(VP.VLR_TOTAL_1ANO/VD.VLR_TOTAL_1ANO) AS PERC_PROD_DEP
	FROM
		@TAB_VENDA_PROD AS VP
		INNER JOIN @TAB_VENDA_DEP AS VD
			ON 1=1
			AND VP.NO_DEPARTAMENTO = VD.NO_DEPARTAMENTO
			AND VP.NO_SECAO = VD.NO_SECAO
			AND VP.NO_GRUPO = VD.NO_GRUPO
	ORDER BY
		VP.NO_DEPARTAMENTO
		,VP.NO_SECAO
		,VP.NO_GRUPO
		,PERC_PROD_DEP DESC