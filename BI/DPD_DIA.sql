-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- DPD
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @TAB_DPD AS TABLE
(
	DATA DATE	
	,COD_PRODUTO INT
	,QTD_ESTOQUE NUMERIC(18,2)
	,AVG_VLR_VENDA NUMERIC(18,2)
	,VLR_VENDA NUMERIC(18,2)
)

INSERT INTO @TAB_DPD
SELECT DISTINCT
	MOV.DATA
	,LINHA.COD_PRODUTO
	,(ISNULL((CASE WHEN MOV.QTD_ESTOQUE < 0 THEN 0 ELSE MOV.QTD_ESTOQUE END),0)) AS QTD_ESTOQUE
	,(EST.AVG_QTD_VENDA*LINHA.VLR_VENDA)/7 AS AVG_VLR_VENDA
	,LINHA.VLR_VENDA
FROM 
	BI.DBO.BI_LINHA_PRODUTOS AS LINHA INNER JOIN BI.dbo.BI_CAD_PRODUTO AS CP ON (LINHA.COD_PRODUTO = CP.COD_PRODUTO)
		INNER JOIN BI.DBO.BI_ESTOQUE_PRODUTO_DIA AS MOV ON (LINHA.COD_LOJA = MOV.COD_LOJA AND LINHA.COD_PRODUTO = MOV.COD_PRODUTO)
		INNER JOIN BI.DBO.COMPRAS_ESTATISTICA_PRODUTO AS EST ON (LINHA.COD_LOJA = EST.COD_LOJA AND LINHA.COD_PRODUTO = EST.COD_PRODUTO)
WHERE 1 = 1
	AND LINHA.COD_LOJA NOT IN (4,10,19)

SELECT
	DATA
	,BI.dbo.fn_FormataVlr_Excel(SUM(QTD_ESTOQUE*VLR_VENDA)/SUM(AVG_VLR_VENDA)) AS DPD
FROM
	@TAB_DPD
GROUP BY
	DATA