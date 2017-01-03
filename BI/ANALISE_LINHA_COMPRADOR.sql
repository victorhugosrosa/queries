DECLARE @COD_PRODUTO AS INT = 1002367

-- -----------------------------------------------------------------------------------------------
-- VERIFICANDO HIERARQUIA DO PRODUTO
-- -----------------------------------------------------------------------------------------------
SELECT
	[COD_PRODUTO]
	,[COD_DEPARTAMENTO]
	,[COD_SECAO]
	,[COD_GRUPO]
	,[NO_DEPARTAMENTO]
	,[NO_SECAO]
	,[NO_GRUPO]
	,[DESCRICAO]
	,[FORA_LINHA]
	,[COD_USUARIO]
FROM BI_CAD_PRODUTO WHERE COD_PRODUTO = @COD_PRODUTO

-- -----------------------------------------------------------------------------------------------
-- VERIFICANDO QUAL NIVEL FOI ESCOLHIDO PARA DEFINIR O COMPRADOR
-- -----------------------------------------------------------------------------------------------
SELECT
	[COD_PRODUTO]
	,[COD_DEPARTAMENTO]
	,[COD_SECAO]
	,[COD_GRUPO]
	,FORA_LINHA
	,COD_USUARIO
	,USUARIO_TIPO
FROM BI_LINHA_PRODUTOS WHERE COD_PRODUTO = @COD_PRODUTO

-- -----------------------------------------------------------------------------------------------
-- VERIFICANDO PARA QUAL COMPRADOR O GRUPO ESTA AMARRADO
-- -----------------------------------------------------------------------------------------------
SELECT
	'0' AS USUARIO_TIPO
	,[COD_DEPARTAMENTO]
	,[COD_SECAO]
	,[COD_GRUPO]
	,[COD_LOJA]
	,[COD_USUARIO]
FROM COMPRA_GRUPO_COMPRADORES
WHERE 1 = 1 
	AND COD_DEPARTAMENTO = (SELECT COD_DEPARTAMENTO FROM BI_CAD_PRODUTO WHERE COD_PRODUTO = @COD_PRODUTO)
	AND COD_SECAO = (SELECT COD_SECAO FROM BI_CAD_PRODUTO WHERE COD_PRODUTO = @COD_PRODUTO)
	AND COD_GRUPO = (SELECT COD_GRUPO FROM BI_CAD_PRODUTO WHERE COD_PRODUTO = @COD_PRODUTO)

-- -----------------------------------------------------------------------------------------------
-- VVERIFICANDO SE NO GRUPO EXISTE EXCESSÃO DE METADADO
-- -----------------------------------------------------------------------------------------------
SELECT
	'1' AS USUARIO_TIPO
	,[COD_DEPARTAMENTO]
	,[COD_SECAO]
	,[COD_GRUPO]
	,[COD_LOJA]
	,[COD_METADADO]
	,[VLR_METADADO]
	,[COD_USUARIO]
FROM COMPRA_METADADO_COMPRADOR
WHERE 1 = 1 
	AND COD_DEPARTAMENTO = (SELECT COD_DEPARTAMENTO FROM BI_CAD_PRODUTO WHERE COD_PRODUTO = @COD_PRODUTO)
	AND COD_SECAO = (SELECT COD_SECAO FROM BI_CAD_PRODUTO WHERE COD_PRODUTO = @COD_PRODUTO)
	AND COD_GRUPO = (SELECT COD_GRUPO FROM BI_CAD_PRODUTO WHERE COD_PRODUTO = @COD_PRODUTO)

-- -----------------------------------------------------------------------------------------------
-- VVERIFICANDO SE NO GRUPO EXISTE EXCESSÃO DE METADADO
-- -----------------------------------------------------------------------------------------------
SELECT
	'2' AS USUARIO_TIPO
	,[COD_PRODUTO]
	,[COD_LOJA]
	,[COD_USUARIO]
FROM COMPRA_PRODUTO_COMPRADOR WHERE COD_PRODUTO = @COD_PRODUTO

-- -----------------------------------------------------------------------------------------------
-- VERIFICANDO SE O PRODUTO POSSUI O METADADO AMARRADO AO GRUPO
-- -----------------------------------------------------------------------------------------------
SELECT* FROM CADASTRO_CAD_PRODUTO_METADADOS WHERE COD_PRODUTO = @COD_PRODUTO