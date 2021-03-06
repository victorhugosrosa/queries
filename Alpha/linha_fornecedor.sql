DECLARE @TAB_PROD_FORN AS TABLE
(
	COD_FORNECEDOR INT
	,COD_PRODUTO INT
	,DES_REFERENCIA VARCHAR(30)
	,VAL_CUSTO_EMBALAGEM NUMERIC(8,2)
	,QTD_EMBALAGEM_COMPRA NUMERIC(8,2)
);

INSERT INTO @TAB_PROD_FORN
	SELECT DISTINCT
		PF.COD_FORNECEDOR
		,PF.COD_PRODUTO
		,PF.DES_REFERENCIA
		,PF.VAL_CUSTO_EMBALAGEM
		,PF.QTD_EMBALAGEM_COMPRA
	FROM
		[192.168.0.6].ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS PF
	WHERE 1 = 1
		AND PF.COD_FORNECEDOR = 875

SELECT DISTINCT
	PF.COD_FORNECEDOR
	,PF.COD_PRODUTO
	,CP.DESCRICAO
	,PF.DES_REFERENCIA
	,CB.COD_EAN
	,PF.VAL_CUSTO_EMBALAGEM
	,PF.QTD_EMBALAGEM_COMPRA
	,CC.NO_COMPRADOR	
FROM
	@TAB_PROD_FORN AS PF
		INNER JOIN [AX2009_INTEGRACAO].dbo.[TAB_CODIGO_BARRA_PRINCIPAL] AS CB ON (PF.COD_PRODUTO = CB.COD_PRODUTO)
		INNER JOIN [BI].dbo.[BI_CAD_PRODUTO] AS CP ON (PF.COD_PRODUTO = CP.COD_PRODUTO)
		LEFT JOIN BI.dbo.COMPRAS_CAD_COMPRADOR AS CC ON (CP.COD_USUARIO = CC.COD_USUARIO)
WHERE 1 = 1
