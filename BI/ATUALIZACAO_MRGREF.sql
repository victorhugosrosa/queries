-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARGEM SUBGRUPO TODAS AS LOJAS
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE LP
	SET
		LP.VLR_MRGREF = MR_SUB.VLR_MRGREF
	FROM
		[BI].[dbo].[BI_LINHA_PRODUTOS] AS LP INNER JOIN [BI].[dbo].[BI_PRECO_MRGREF_SUBGRUPO] AS MR_SUB
			ON (LP.COD_DEPARTAMENTO = MR_SUB.COD_DEPARTAMENTO AND LP.COD_SECAO = MR_SUB.COD_SECAO AND LP.COD_GRUPO = MR_SUB.COD_GRUPO AND LP.COD_SUBGRUPO = MR_SUB.COD_SUBGRUPO)
	WHERE 1 = 1
		AND MR_SUB.COD_LOJA = 0;
	
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARGEM SUBGRUPO LOJAS ESPECÍFICAS
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE LP
	SET
		LP.VLR_MRGREF = MR_SUB.VLR_MRGREF
	FROM
		[BI].[dbo].[BI_LINHA_PRODUTOS] AS LP INNER JOIN [BI].[dbo].[BI_PRECO_MRGREF_SUBGRUPO] AS MR_SUB
			ON (LP.COD_DEPARTAMENTO = MR_SUB.COD_DEPARTAMENTO AND LP.COD_SECAO = MR_SUB.COD_SECAO AND LP.COD_GRUPO = MR_SUB.COD_GRUPO AND LP.COD_SUBGRUPO = MR_SUB.COD_SUBGRUPO)
	WHERE 1 = 1
		AND MR_SUB.COD_LOJA = LP.COD_LOJA;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARGEM METADADO TODAS AS LOJAS
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE LP
	SET
		LP.VLR_MRGREF = MR_META.VLR_MRGREF
	FROM
		[BI].[dbo].[BI_LINHA_PRODUTOS] AS LP INNER JOIN [BI].[dbo].[CADASTRO_CAD_PRODUTO_METADADOS] AS CPM ON (LP.COD_PRODUTO = CPM.COD_PRODUTO)
			INNER JOIN [BI].[dbo].[BI_PRECO_MRGREF_METADADO] AS MR_META
			ON (LP.COD_DEPARTAMENTO = MR_META.COD_DEPARTAMENTO AND LP.COD_SECAO = MR_META.COD_SECAO AND LP.COD_GRUPO = MR_META.COD_GRUPO AND LP.COD_SUBGRUPO = MR_META.COD_SUBGRUPO AND CPM.COD_METADADO = MR_META.COD_METADADO AND CPM.VLR_METADADO = MR_META.VLR_METADADO)
	WHERE 1 = 1
		AND MR_META.COD_LOJA = 0;
		
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARGEM METADADO LOJAS ESPECÍFICAS
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE LP
	SET
		LP.VLR_MRGREF = MR_META.VLR_MRGREF
	FROM
		[BI].[dbo].[BI_LINHA_PRODUTOS] AS LP INNER JOIN [BI].[dbo].[CADASTRO_CAD_PRODUTO_METADADOS] AS CPM ON (LP.COD_PRODUTO = CPM.COD_PRODUTO)
			INNER JOIN [BI].[dbo].[BI_PRECO_MRGREF_METADADO] AS MR_META
			ON (LP.COD_DEPARTAMENTO = MR_META.COD_DEPARTAMENTO AND LP.COD_SECAO = MR_META.COD_SECAO AND LP.COD_GRUPO = MR_META.COD_GRUPO AND LP.COD_SUBGRUPO = MR_META.COD_SUBGRUPO AND CPM.COD_METADADO = MR_META.COD_METADADO AND CPM.VLR_METADADO = MR_META.VLR_METADADO)
	WHERE 1 = 1
		AND MR_META.COD_LOJA = LP.COD_LOJA;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARGEM PRODUTO TODAS AS LOJAS
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE LP
	SET
		LP.VLR_MRGREF = MR_PROD.VLR_MRGREF
	FROM
		[BI].[dbo].[BI_LINHA_PRODUTOS] AS LP INNER JOIN [BI].[dbo].[BI_PRECO_MRGREF_PRODUTO] AS MR_PROD
			ON (LP.COD_PRODUTO = MR_PROD.COD_PRODUTO)
	WHERE 1 = 1
		AND MR_PROD.COD_LOJA = 0;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARGEM PRODUTO LOJAS ESPECÍFICAS
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE LP
	SET
		LP.VLR_MRGREF = MR_PROD.VLR_MRGREF
	FROM
		[BI].[dbo].[BI_LINHA_PRODUTOS] AS LP INNER JOIN [BI].[dbo].[BI_PRECO_MRGREF_PRODUTO] AS MR_PROD
			ON (LP.COD_PRODUTO = MR_PROD.COD_PRODUTO)
	WHERE 1 = 1
		AND MR_PROD.COD_LOJA = LP.COD_LOJA;


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE BI_CAD_PRODUTO
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TAB_REF AS TABLE
	(
		COD_PRODUTO INT
		,VLR_MRGREF_MED NUMERIC(8,2)
		,VLR_MRGREF_MAX NUMERIC(8,2)
		,VLR_MRGREF_MIN NUMERIC(8,2)
	)
	
	INSERT INTO @TAB_REF 
	SELECT
		COD_PRODUTO
		,AVG(VLR_MRGREF)
		,MAX(VLR_MRGREF)
		,MIN(VLR_MRGREF)
	FROM
		[BI].[dbo].[BI_LINHA_PRODUTOS] AS LP
	GROUP BY
		COD_PRODUTO
		
	
	UPDATE CP
	SET
		CP.VLR_MRGREF_MED = REF.VLR_MRGREF_MED
		,CP.VLR_MRGREF_MAX = REF.VLR_MRGREF_MAX
		,CP.VLR_MRGREF_MIN =  REF.VLR_MRGREF_MIN
	FROM 
		[BI].[dbo].[BI_CAD_PRODUTO] AS CP INNER JOIN @TAB_REF AS REF ON (CP.COD_PRODUTO = REF.COD_PRODUTO)
