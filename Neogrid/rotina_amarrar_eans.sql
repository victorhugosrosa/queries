DECLARE @TEMP_EAN_NEOGRID AS TABLE
(
	COD_FORNECEDOR INT NOT NULL,
	COD_PRODUTO INT NOT NULL,
	COD_EAN VARCHAR(20)
);

INSERT INTO @TEMP_EAN_NEOGRID (COD_FORNECEDOR,COD_PRODUTO)
SELECT DISTINCT
	F.COD_FORNECEDOR
	,PF.COD_PRODUTO
FROM
	ZEUS_RTG.DBO.TAB_FORNECEDOR AS F INNER JOIN ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS PF ON (F.COD_FORNECEDOR = PF.COD_FORNECEDOR)
	LEFT JOIN
	(
		--ROTINA INCLUIDA EM 20/05/2013
		SELECT  COD_FORNECEDOR,COD_PRODUTO , TIPO_EAN  ,  COD_EAN AS COD_EAN 
		 FROM [192.168.0.13].AX2009_INTEGRACAO.DBO.TAB_CODIGO_BARRA_NEOGRID
		 WHERE 1 =1
		 AND COD_FORNECEDOR IS NOT NULL
	)  AS NEO ON (PF.COD_PRODUTO collate Latin1_General_CI_AS  = NEO.COD_PRODUTO)
WHERE FLG_LIBERADO_NEOGRID = 1 AND NEO.COD_PRODUTO IS NULL;;

-- -------------------------------------------------------------
-- DEFININDO CODIGO DE BARRA NEOGRID COMO PRIORITARIO
-- -------------------------------------------------------------
UPDATE EAN
	SET COD_EAN = PROD.COD_EAN
FROM
	@TEMP_EAN_NEOGRID AS EAN INNER JOIN
	(
		--ROTINA INCLUIDA EM 20/05/2013
		SELECT  COD_FORNECEDOR,COD_PRODUTO , TIPO_EAN  ,  COD_EAN AS COD_EAN 
		 FROM [192.168.0.13].AX2009_INTEGRACAO.DBO.TAB_CODIGO_BARRA_NEOGRID
		 WHERE 1 =1
		 AND COD_FORNECEDOR IS NOT NULL
	)  AS PROD
		ON CAST(EAN.COD_PRODUTO AS DOUBLE PRECISION)= CAST(PROD.COD_PRODUTO AS DOUBLE PRECISION) AND EAN.COD_FORNECEDOR = PROD.COD_FORNECEDOR
WHERE 1 = 1				

-- -------------------------------------------------------------
-- DEFININDO CODIGO DE BARRA EAN COMO PRIORITARIO PARA OS QUE N�O POSSUEM NEOGRID
-- SEM O CODIGO DO FORNECEDOR 09/10/2013 - FRADE
-- -------------------------------------------------------------
UPDATE EAN
	SET COD_EAN = PROD.COD_EAN
FROM
	@TEMP_EAN_NEOGRID AS EAN INNER JOIN
	(
		--ROTINA INCLUIDA EM 20/05/2013
		SELECT  COD_FORNECEDOR,COD_PRODUTO , TIPO_EAN  ,  COD_EAN AS COD_EAN 
		 FROM [192.168.0.13].AX2009_INTEGRACAO.DBO.TAB_CODIGO_BARRA_NEOGRID
		 WHERE 1 =1
	)  AS PROD
		ON CAST(EAN.COD_PRODUTO AS DOUBLE PRECISION)= CAST(PROD.COD_PRODUTO AS DOUBLE PRECISION)
WHERE 1 = 1		
AND ISNULL(EAN.COD_EAN,'') ='' 


-- -------------------------------------------------------------
-- DEFININDO CODIGO DE BARRA EAN COMO PRIORITARIO PARA OS QUE N�O POSSUEM NEOGRID
-- CODIGO DE BARRA EAN CADASTRADO 09/10/2013 - FRADE
-- -------------------------------------------------------------
UPDATE EAN
	SET COD_EAN = PROD.COD_EAN
FROM
	@TEMP_EAN_NEOGRID AS EAN INNER JOIN
	(
	
		SELECT COD_PRODUTO , TIPO_EAN  ,  MAX(COD_EAN) AS COD_EAN
		FROM
			ZEUS_RTG.DBO.TAB_CODIGO_BARRA  AS PROD										
		WHERE 1 = 1
			AND LEN(CAST(PROD.COD_EAN AS NUMERIC(13)) ) >= 8
			AND PROD.TIPO_EAN = 'EAN13'
			AND ISNUMERIC(PROD.COD_EAN) = 1
		GROUP  BY COD_PRODUTO  , TIPO_EAN												
	
	)  AS PROD
		ON CAST(EAN.COD_PRODUTO AS DOUBLE PRECISION)= CAST(PROD.COD_PRODUTO AS DOUBLE PRECISION)
WHERE 1 = 1
	AND LEN(CAST(PROD.COD_EAN AS NUMERIC(13)) ) >= 8
	AND PROD.TIPO_EAN = 'EAN13'
	AND ISNULL(EAN.COD_EAN,'') ='' 

-- -------------------------------------------------------------
-- PRODUTOS COM CODIGO DE BARRA EM BRANCO OU NULL UTILIZAR CODIGO DE BARRA NORMAL
-- PEGA UM COD EAN NA TABELA
-- -------------------------------------------------------------
UPDATE EAN
	SET COD_EAN = PROD.COD_EAN
FROM
	@TEMP_EAN_NEOGRID AS EAN INNER JOIN
	(
	
		SELECT COD_PRODUTO , TIPO_EAN  ,  MAX(COD_EAN) AS COD_EAN
		FROM
			ZEUS_RTG.DBO.TAB_CODIGO_BARRA  AS PROD										
		WHERE 1 = 1
			AND LEN(CAST(PROD.COD_EAN AS NUMERIC(13)) ) >= 8
			AND PROD.TIPO_EAN = 'EAN13'
			AND ISNUMERIC(PROD.COD_EAN) = 1
		GROUP  BY COD_PRODUTO  , TIPO_EAN												
	
	)  AS PROD
		ON CAST(EAN.COD_PRODUTO AS DOUBLE PRECISION)= CAST(PROD.COD_PRODUTO AS DOUBLE PRECISION)
WHERE 1 = 1
	AND LEN(CAST(PROD.COD_EAN AS NUMERIC(13)) ) >= 8
	AND PROD.TIPO_EAN = 'EAN13'
	AND ISNULL(EAN.COD_EAN,'') ='' 

-- -------------------------------------------------------------
-- EAN TAB_PRODUTO_FORNECEDOR PARA QUEM N�O ESTIVER NA CODIGO BARRAS
-- -------------------------------------------------------------
UPDATE EAN
	SET EAN.COD_EAN = RIGHT(PROD.COD_EAN_FORNECEDOR, 13)
FROM
	@TEMP_EAN_NEOGRID AS EAN INNER JOIN
	ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS PROD
		ON CAST(EAN.COD_PRODUTO AS DOUBLE PRECISION) = CAST(PROD.COD_PRODUTO AS DOUBLE PRECISION)  AND PROD.COD_FORNECEDOR = EAN.COD_FORNECEDOR
WHERE 1 = 1
	AND ISNULL(PROD.COD_EAN_FORNECEDOR,'') <> ''
	AND EAN.COD_EAN IS NULL
	AND LEN(CAST(ISNULL(EAN.COD_EAN,0) AS NUMERIC(13)) ) < 8
	AND ISNUMERIC(EAN.COD_EAN) = 1
			

-- -------------------------------------------------------------
-- ALTERANDO COD EAN PARA CODIGO DE REFERENCIA PARA OS PRODUTOS
-- QUE N�O POSSUEM CODIGO DE BARRA
-- -------------------------------------------------------------							
IF EXISTS (
	   SELECT 1 
	   FROM @TEMP_EAN_NEOGRID
	   WHERE 1 =1 
	   AND ISNULL(COD_EAN,'') = ''
	   )
BEGIN  
	
			UPDATE CODIGOS
			SET CODIGOS.COD_EAN = ''
			FROM ZEUS_RTG.DBO.TAB_PRODUTO AS PROD WITH (NOLOCK) ,
				 ZEUS_RTG.DBO.TAB_PRODUTO_FORNECEDOR AS FORN WITH (NOLOCK),
				 @TEMP_EAN_NEOGRID  AS CODIGOS
			WHERE 1 =1
			AND CAST(PROD.COD_PRODUTO  AS DOUBLE PRECISION) = CAST(FORN.COD_PRODUTO AS DOUBLE PRECISION)
			AND CAST(CODIGOS.COD_FORNECEDOR  AS DOUBLE PRECISION)= CAST(FORN.COD_FORNECEDOR AS DOUBLE PRECISION)
			AND CAST(FORN.COD_PRODUTO  AS DOUBLE PRECISION)= CAST(CODIGOS.COD_PRODUTO AS DOUBLE PRECISION)
			AND CODIGOS.COD_EAN IS NULL

END

SELECT *
FROM
	@TEMP_EAN_NEOGRID as TEMP_NEO  inner JOIN [192.168.0.13].[BI].[dbo].[CADASTRO_ALTERAR_PRODUTO_FORNECEDOR] as ALT ON (TEMP_NEO.COD_PRODUTO = ALT.COD_PRODUTO AND TEMP_NEO.COD_FORNECEDOR = ALT.COD_FORNECEDOR)
where TEMP_NEO.COD_EAN is not null and TEMP_NEO.COD_EAN <> ''

SELECT *
FROM
	@TEMP_EAN_NEOGRID as TEMP_NEO  left JOIN [192.168.0.13].[BI].[dbo].[CADASTRO_ALTERAR_PRODUTO_FORNECEDOR] as ALT ON (TEMP_NEO.COD_PRODUTO = ALT.COD_PRODUTO AND TEMP_NEO.COD_FORNECEDOR = ALT.COD_FORNECEDOR)
where ALT.COD_NEO IS NULL and TEMP_NEO.COD_EAN is not null

insert into [192.168.0.13].[BI].[dbo].[CADASTRO_ALTERAR_PRODUTO_FORNECEDOR]
SELECT
	TEMP_NEO.COD_FORNECEDOR
	,TEMP_NEO.COD_PRODUTO
	,NULL,NULL,NULL,NULL
	,TEMP_NEO.COD_EAN
FROM
	@TEMP_EAN_NEOGRID as TEMP_NEO  left JOIN [192.168.0.13].[BI].[dbo].[CADASTRO_ALTERAR_PRODUTO_FORNECEDOR] as ALT ON (TEMP_NEO.COD_PRODUTO = ALT.COD_PRODUTO AND TEMP_NEO.COD_FORNECEDOR = ALT.COD_FORNECEDOR)
where ALT.COD_NEO IS NULL and TEMP_NEO.COD_EAN is not null