DECLARE @COD_INV AS VARCHAR(20) = '012_19022014'
DECLARE @COD_LOJA AS INT = 12
DECLARE @DTA_INV_ROT AS DATE = CONVERT(DATE,'20140219')
DECLARE @DTA_INV_GERAL AS DATE

-- -----------------------------------------------------------------------------------------------------------------------------
-- ULTIMA DATA DO INVENTARIO GERAL DA LOJA
-- -----------------------------------------------------------------------------------------------------------------------------
SELECT
	@DTA_INV_GERAL = MAX(DTA_INVENTARIO)
FROM 
	[192.168.0.6].ZEUS_RTG.DBO.TAB_INVENTARIO
WHERE 1 = 1
	AND DES_INVENTARIO LIKE '%INV. GERAL%'
	AND COD_LOJA = @COD_LOJA
GROUP BY
	COD_LOJA

-- -----------------------------------------------------------------------------------------------------------------------------
-- PUXANDO ITENS A SEREM ANALISADOS
-- -----------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_PROD AS TABLE
(
	COD_PRODUTO INT
)

INSERT INTO @TAB_PROD
SELECT DISTINCT
	COD_PRODUTO
FROM
	[192.168.0.6].Zeus_rtg.dbo.TAB_AJUSTE_ESTOQUE
WHERE 1 = 1
	AND COD_AJUSTE IN (199,300)
	AND COD_LOJA = @COD_LOJA
	AND CONVERT(DATE,DTA_AJUSTE) = @DTA_INV_ROT

-- -----------------------------------------------------------------------------------------------------------------------------
-- PUXANDO QUEBRAS DOS ITENS
-- -----------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_QUEBRA AS TABLE
(
	COD_PRODUTO INT
	,COD_AJUSTE INT
	,QTD_QUEBRA NUMERIC(12,3)
	--,VLR_CUSTO_REP NUMERIC(12,3)
	,VLR_QUEBRA NUMERIC(12,3)
)

INSERT INTO @TAB_QUEBRA
SELECT
	AE.COD_PRODUTO
	,AE.COD_AJUSTE
	,SUM(AE.QTD_AJUSTE) as QTD_AJUSTE
	--,SUM([VAL_CUSTO_REP]) AS VLR_CUSTO_REP
	,SUM([QTD_AJUSTE]*[VAL_CUSTO_REP]) AS VLR_QUEBRA
FROM
	[192.168.0.6].Zeus_rtg.dbo.TAB_AJUSTE_ESTOQUE AS AE INNER JOIN @TAB_PROD AS TP ON (AE.COD_PRODUTO = TP.COD_PRODUTO)
WHERE 1 = 1
	AND AE.COD_AJUSTE IN (51,120,121,122,123,124,154,155)
	AND AE.COD_LOJA = @COD_LOJA
	AND CONVERT(DATE,AE.DTA_AJUSTE) BETWEEN CONVERT(DATE,@DTA_INV_GERAL) AND CONVERT(DATE,@DTA_INV_ROT)
GROUP BY
	AE.COD_PRODUTO
	,AE.COD_AJUSTE

-- -----------------------------------------------------------------------------------------------------------------------------
-- PUXANDO VENDA DOS ITENS
-- -----------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_VENDA AS TABLE
(
	COD_PRODUTO INT
	,QTD_VENDA NUMERIC(12,3)
	,VLR_VENDA NUMERIC(12,3)
)

INSERT INTO @TAB_VENDA
SELECT
	VP.COD_PRODUTO
	,sum(VP.QTDE_PRODUTO) as QTD_VENDA
	,sum(VP.VALOR_TOTAL) as VLR_VENDA
FROM
	BI.DBO.BI_VENDA_PRODUTO AS VP INNER JOIN @TAB_PROD AS TP ON (VP.COD_PRODUTO = TP.COD_PRODUTO)
WHERE 1 = 1
	AND VP.COD_LOJA = @COD_LOJA
	AND CONVERT(DATE,VP.DATA) BETWEEN CONVERT(DATE,@DTA_INV_GERAL) AND CONVERT(DATE,@DTA_INV_ROT)
GROUP BY
	VP.COD_PRODUTO
	

-- -----------------------------------------------------------------------------------------------------------------------------
-- PUXANDO INVENTARIO ROTATIVO
-- -----------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_INV_ROT AS TABLE
(
	COD_PRODUTO INT
	--,COD_AJUSTE INT
	,QTD_AJUSTE_IR NUMERIC(12,3)
	,VLR_CUSTO_REP_IR NUMERIC(12,3)
	,VLR_AJUSTE_IR NUMERIC(12,3)
)

INSERT INTO @TAB_INV_ROT
SELECT
	AE.COD_PRODUTO
	--,AE.COD_AJUSTE
	,SUM(AE.QTD_AJUSTE) as QTD_AJUSTE
	,SUM([VAL_CUSTO_REP]) AS VLR_CUSTO_REP
	,SUM([QTD_AJUSTE]*[VAL_CUSTO_REP]) AS VLR_AJUSTE_IR
FROM
	[192.168.0.6].Zeus_rtg.dbo.TAB_AJUSTE_ESTOQUE AS AE INNER JOIN @TAB_PROD AS TP ON (AE.COD_PRODUTO = TP.COD_PRODUTO)
WHERE 1 = 1
	AND AE.COD_AJUSTE IN (199,300)
	AND AE.COD_LOJA = @COD_LOJA
	AND CONVERT(DATE,AE.DTA_AJUSTE) = CONVERT(DATE,@DTA_INV_ROT)
GROUP BY
	AE.COD_PRODUTO
	--,AE.COD_AJUSTE


SELECT
	@COD_INV AS COD_INV
	,@COD_LOJA AS COD_LOJA
	,Q.COD_PRODUTO
	,dbo.fn_FormataVlr_Excel(Q.COD_AJUSTE)
	,dbo.fn_FormataVlr_Excel(Q.QTD_QUEBRA)
	,dbo.fn_FormataVlr_Excel(Q.VLR_QUEBRA)
FROM
	@TAB_QUEBRA AS Q;


SELECT
	@COD_INV AS COD_INV
	,@COD_LOJA AS COD_LOJA
	,IR.COD_PRODUTO
	,dbo.fn_FormataVlr_Excel(IR.QTD_AJUSTE_IR)
	,dbo.fn_FormataVlr_Excel(IR.VLR_CUSTO_REP_IR)
	,dbo.fn_FormataVlr_Excel(IR.VLR_AJUSTE_IR)
FROM
	@TAB_INV_ROT AS IR;


SELECT
	@COD_INV AS COD_INV
	,@COD_LOJA AS COD_LOJA
	,V.COD_PRODUTO
	,dbo.fn_FormataVlr_Excel(V.QTD_VENDA)
	,dbo.fn_FormataVlr_Excel(V.VLR_VENDA)
FROM
	@TAB_VENDA AS V;

select 
	COD_AJUSTE
	,DES_AJUSTE
from [192.168.0.6].Zeus_rtg.dbo.TAB_TIPO_AJUSTE WHERE COD_AJUSTE IN (51,120,121,122,123,124,154,155)