-- -------------------------------------------------------------------------------------------------------------------------------------
-- FRAGMENTOS DA PROC sp_MARCHE_ProcessarPedidosImportados5 (Partes que realizam o update do zeus no bi)
-- -------------------------------------------------------------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------
		--carregando o numero do PEDIDO gerado 
		-- --------------------------------------------------------------------------
		select @PedidoZEus = PedidoZEus 
		from intranet.dbo.Cesta_Compras	with (nolock)
		where 1 = 1 
		and ID = @ID_PEDIDO
		and IDsession = @ID_SESSION 
		and PedidoZEus is not null
		--and CONVERT(varchar , Data , 101) =  CONVERT(varchar , GETDATE() , 101)
		and cast(Data as date) = cast(GETDATE() as date) 

		-- ------------------------------------------------------------------------
		--Atualizando Codigo do pedido no BI
		-- ------------------------------------------------------------------------
		update [192.168.0.13].BI.dbo.COMPRAS_PEDIDOS 
		set COD_PEDIDO = @PedidoZEus
		where ID = @ID_SESSION

-- -------------------------------------------------------------------------------------------------------------------------------------
-- ITENS DUPLCIADOS BI
-- -------------------------------------------------------------------------------------------------------------------------------------
SELECT
	COD_FORNECEDOR
	,COD_LOJA
	,COD_PRODUTO
	,COD_COMPRADOR
	--,ID
	,COUNT(DISTINCT COD_PEDIDO)
FROM
	COMPRAS_PEDIDOS
WHERE 1 = 1
	AND CONVERT(DATE,DATA) = CONVERT(DATE,'20140908')
	AND COD_FORNECEDOR = 16535
GROUP BY
	COD_FORNECEDOR
	,COD_LOJA
	,COD_PRODUTO
	,COD_COMPRADOR
	--,ID
HAVING
	COUNT(DISTINCT COD_PEDIDO) > 1

-- -------------------------------------------------------------------------------------------------------------------------------------
-- ITENS SEM NUMERO DE PEDIDO NO BI
-- -------------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM
	COMPRAS_PEDIDOS
WHERE 1 = 1
	AND CONVERT(DATE,DATA) = CONVERT(DATE,'20140908')
	AND COD_FORNECEDOR = 16535
	AND COD_PEDIDO IS NULL

-- -------------------------------------------------------------------------------------------------------------------------------------
-- ITENS DUPLICADOS ZEUS
-- -------------------------------------------------------------------------------------------------------------------------------------
SELECT
	P.COD_PARCEIRO AS COD_FORNECEDOR
	,P.COD_LOJA
	,PP.COD_PRODUTO
	,P.COD_USUARIO
	--,ID
	,COUNT(DISTINCT P.NUM_PEDIDO) AS QTD_PEDIDOS
FROM
	Zeus_rtg.dbo.TAB_PEDIDO AS P
	INNER JOIN Zeus_rtg.dbo.TAB_PEDIDO_PRODUTO AS PP
		ON 1 = 1
		AND P.NUM_PEDIDO = PP.NUM_PEDIDO
		AND P.COD_LOJA = PP.COD_LOJA
		AND P.COD_PARCEIRO = PP.COD_PARCEIRO
WHERE 1 = 1
	AND CONVERT(DATE,P.DTA_EMISSAO) = CONVERT(DATE,'20140908')
	AND P.COD_PARCEIRO = 16535
GROUP BY
	P.COD_PARCEIRO
	,P.COD_LOJA
	,PP.COD_PRODUTO
	,P.COD_USUARIO
	--,ID
HAVING
	COUNT(DISTINCT P.NUM_PEDIDO) > 1
	
