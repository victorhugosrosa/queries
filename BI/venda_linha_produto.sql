-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VENDA GERAL
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @VENDA_GERAL AS TABLE
(
	COD_LOJA INT
	,ANO INT
	,MES INT
	,NO_DEPARTAMENTO VARCHAR(50)
	,VALOR_TOTAL NUMERIC(12,3)
	,QTDE_PRODUTO NUMERIC(12,3)
)

INSERT INTO @VENDA_GERAL
SELECT
	VP.COD_LOJA
	,YEAR(VP.DATA) AS ANO
	,MONTH(VP.DATA) AS MES
	,'GERAL'
	,SUM(VP.VALOR_TOTAL) AS VALOR_TOTAL
	,SUM(VP.QTDE_PRODUTO) AS QTDE_PRODUTO
FROM
	BI_VENDA_PRODUTO AS VP INNER JOIN BI_LINHA_PRODUTOS LP ON (VP.COD_PRODUTO = LP.COD_PRODUTO AND VP.COD_LOJA = LP.COD_LOJA)
		LEFT JOIN BI_CAD_PRODUTO AS CP ON (LP.COD_PRODUTO = CP.COD_PRODUTO)
WHERE 1 = 1
	and CONVERT(DATE,VP.DATA) >= CONVERT(DATE,'20130801')
	and CONVERT(DATE,VP.DATA) < CONVERT(DATE,'20140201')
group by
	VP.COD_LOJA
	,YEAR(VP.DATA)
	,MONTH(VP.DATA)
ORDER BY
	VP.COD_LOJA
	,YEAR(VP.DATA)
	,MONTH(VP.DATA)

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VENDA ACOUGUE
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @VENDA_ACOUGUE AS TABLE
(
	COD_LOJA INT
	,ANO INT
	,MES INT
	,NO_DEPARTAMENTO VARCHAR(50)
	,VALOR_TOTAL NUMERIC(10,3)
	,QTDE_PRODUTO NUMERIC(10,3)
)

INSERT INTO @VENDA_ACOUGUE
SELECT
	VP.COD_LOJA
	,YEAR(VP.DATA) AS ANO
	,MONTH(VP.DATA) AS MES
	,CP.NO_DEPARTAMENTO
	,SUM(VP.VALOR_TOTAL) AS VALOR_TOTAL
	,SUM(VP.QTDE_PRODUTO) AS QTDE_PRODUTO
FROM
	BI_VENDA_PRODUTO AS VP INNER JOIN BI_LINHA_PRODUTOS LP ON (VP.COD_PRODUTO = LP.COD_PRODUTO AND VP.COD_LOJA = LP.COD_LOJA)
		LEFT JOIN BI_CAD_PRODUTO AS CP ON (LP.COD_PRODUTO = CP.COD_PRODUTO)
WHERE 1 = 1
	AND (CP.COD_DEPARTAMENTO = 5)
	--OR (CG.COD_DEPARTAMENTO = 1)
	and CONVERT(DATE,VP.DATA) >= CONVERT(DATE,'20130801')
	and CONVERT(DATE,VP.DATA) < CONVERT(DATE,'20140201')
group by
	VP.COD_LOJA
	,YEAR(VP.DATA)
	,MONTH(VP.DATA)
	,CP.NO_DEPARTAMENTO
ORDER BY
	VP.COD_LOJA
	,YEAR(VP.DATA)
	,MONTH(VP.DATA)

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUEBRA GERAL
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @QUEBRA_GERAL AS TABLE
(
	COD_LOJA INT
	,ANO INT
	,MES INT
	,NO_DEPARTAMENTO VARCHAR(50)
	,VALOR_QUEBRA NUMERIC(12,3)
)

INSERT INTO @QUEBRA_GERAL
SELECT
	[COD_LOJA]
	,YEAR([DTA_AJUSTE]) AS ANO
	,MONTH([DTA_AJUSTE]) AS MES
	,'GERAL'
	,SUM(-1*[QTD_AJUSTE]*[VAL_CUSTO_REP]) AS VLR_CUSTO_REP_TOTAL
FROM
	[192.168.0.6].ZEUS_RTG.DBO.[TAB_AJUSTE_ESTOQUE]
WHERE 1=1
	AND CONVERT(DATE,[DTA_AJUSTE]) >= CONVERT(DATE,'20130801')
	AND CONVERT(DATE,[DTA_AJUSTE]) < CONVERT(DATE,'20140201')
	AND COD_AJUSTE IN (3,51,108,120,121,122,123,124,154)
GROUP BY
	[COD_LOJA]
	,YEAR([DTA_AJUSTE])
	,MONTH([DTA_AJUSTE])
ORDER BY
	[COD_LOJA]
	,YEAR([DTA_AJUSTE])
	,MONTH([DTA_AJUSTE])

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUEBRA ACOUGUE
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @QUEBRA_ACOUGUE AS TABLE
(
	COD_LOJA INT
	,ANO INT
	,MES INT
	,NO_DEPARTAMENTO VARCHAR(50)
	,VALOR_QUEBRA NUMERIC(12,3)
)

INSERT INTO @QUEBRA_ACOUGUE
SELECT
	[COD_LOJA]
	,YEAR([DTA_AJUSTE]) AS ANO
	,MONTH([DTA_AJUSTE]) AS MES
	,CP.NO_DEPARTAMENTO
	,SUM(-1*[QTD_AJUSTE]*[VAL_CUSTO_REP]) AS VLR_CUSTO_REP_TOTAL
FROM
	[192.168.0.6].ZEUS_RTG.DBO.[TAB_AJUSTE_ESTOQUE] AS AJU INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP ON (AJU.COD_PRODUTO = CP.COD_PRODUTO)
WHERE 1=1
	AND CONVERT(DATE,[DTA_AJUSTE]) >= CONVERT(DATE,'20130801')
	AND CONVERT(DATE,[DTA_AJUSTE]) < CONVERT(DATE,'20140201')
	AND COD_AJUSTE IN (3,51,108,120,121,122,123,124,154)
	AND (CP.COD_DEPARTAMENTO = 5)
GROUP BY
	[COD_LOJA]
	,YEAR([DTA_AJUSTE])
	,MONTH([DTA_AJUSTE])
	,CP.NO_DEPARTAMENTO
ORDER BY
	[COD_LOJA]
	,YEAR([DTA_AJUSTE])
	,MONTH([DTA_AJUSTE])


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	VG.COD_LOJA
	,VG.ANO
	,VG.MES
	,VG.NO_DEPARTAMENTO
	,dbo.fn_FormataVlr_Excel(VG.VALOR_TOTAL) AS VALOR_TOTAL_G
	,dbo.fn_FormataVlr_Excel(VG.QTDE_PRODUTO) AS QTDE_PRODUTO_G
	,VA.NO_DEPARTAMENTO
	,dbo.fn_FormataVlr_Excel(VA.VALOR_TOTAL) AS VALOR_TOTAL_A
	,dbo.fn_FormataVlr_Excel(VA.QTDE_PRODUTO) AS QTDE_PRODUTO_A
	,QG.NO_DEPARTAMENTO
	,dbo.fn_FormataVlr_Excel(QG.VALOR_QUEBRA) AS VALOR_QUEBRA_G
	,QA.NO_DEPARTAMENTO
	,dbo.fn_FormataVlr_Excel(QA.VALOR_QUEBRA) AS VALOR_QUEBRA_A
FROM
	@VENDA_GERAL AS VG LEFT JOIN @VENDA_ACOUGUE AS VA ON (VG.COD_LOJA = VA.COD_LOJA AND VG.ANO = VA.ANO AND VG.MES = VA.MES)
		LEFT JOIN @QUEBRA_GERAL AS QG ON (VG.COD_LOJA = QG.COD_LOJA AND VG.ANO = QG.ANO AND VG.MES = QG.MES)
			LEFT JOIN @QUEBRA_ACOUGUE AS QA ON (VG.COD_LOJA = QA.COD_LOJA AND VG.ANO = QA.ANO AND VG.MES = QA.MES)