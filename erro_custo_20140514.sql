DECLARE @TAB_CUSTO_BI AS TABLE
(
	COD_FORNECEDOR INT
	,COD_PRODUTO INT
	,VLR_EMB_COMPRA FLOAT
	,QTD_EMB_COMPRA FLOAT
	,DTA_GRAVACAO DATE
)

INSERT INTO @TAB_CUSTO_BI
SELECT
	COD_FORNECEDOR
	,COD_PRODUTO
	,VLR_EMB_COMPRA
	,QTD_EMB_COMPRA
	,DTA_GRAVACAO
FROM
	[192.168.0.13].BI.DBO.VW_CUSTOS_ATIVOS
	
SELECT
	ZEUS.COD_LOJA
	,ZEUS.COD_FORNECEDOR
	,ZEUS.COD_PRODUTO
	,ZEUS.VAL_CUSTO_EMBALAGEM
	,ZEUS.QTD_EMBALAGEM_COMPRA
	,BI.VLR_EMB_COMPRA
	,BI.QTD_EMB_COMPRA
FROM
	ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS ZEUS INNER JOIN @TAB_CUSTO_BI AS BI ON (ZEUS.COD_FORNECEDOR = BI.COD_FORNECEDOR AND ZEUS.COD_PRODUTO = BI.COD_PRODUTO)
WHERE 1 = 1
	AND (CONVERT(NUMERIC(10,2),ZEUS.VAL_CUSTO_EMBALAGEM) <> CONVERT(NUMERIC(10,2),BI.VLR_EMB_COMPRA))
	AND CONVERT(DATE,BI.DTA_GRAVACAO) <= CONVERT(DATE,GETDATE()-10)

/*
UPDATE ZEUS
SET
	ZEUS.VAL_CUSTO_EMBALAGEM = BI.VLR_EMB_COMPRA
	,ZEUS.QTD_EMBALAGEM_COMPRA = BI.QTD_EMB_COMPRA
FROM
	ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS ZEUS INNER JOIN @TAB_CUSTO_BI AS BI ON (ZEUS.COD_FORNECEDOR = BI.COD_FORNECEDOR AND ZEUS.COD_PRODUTO = BI.COD_PRODUTO)
WHERE 1 = 1
	AND (CONVERT(NUMERIC(10,2),ZEUS.VAL_CUSTO_EMBALAGEM) <> CONVERT(NUMERIC(10,2),BI.VLR_EMB_COMPRA))
	AND CONVERT(DATE,BI.DTA_GRAVACAO) <= CONVERT(DATE,GETDATE()-10)
*/