DECLARE @DT_INI AS DATE = CONVERT(DATE,'20140224')
DECLARE @DT_FIM AS DATE = CONVERT(DATE,'20140224')

SELECT
	PDV.COD_LOJA
	,PDV.COD_PRODUTO
	--,PDV.M03AH
	,PDV.DATA
	,PDV.TIPO
	,PDV.VLRCUPOM
	,BASE_TI.TIPO
	,BASE_TI.VLRCUPOM
	,(PDV.VLRCUPOM - BASE_TI.VLRCUPOM) AS DIFF
FROM

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
(
	SELECT 
		'ZAN_M03' AS TIPO
		,M00ZA AS COD_LOJA
		,CB.COD_PRODUTO
		--,M03AH
		,CONVERT(DATE,M00AF) AS DATA
		,(SUM([M03AP])-SUM(M03AQ))/COUNT(distinct M03AH) AS VLRCUPOM
	FROM
		ZEUSRETAIL.DBO.ZAN_M03 AS C WITH (NOLOCK)
			LEFT JOIN AX2009_INTEGRACAO.dbo.TAB_CODIGO_BARRA AS CB ON (CONVERT(DOUBLE PRECISION,M03AH) = CONVERT(DOUBLE PRECISION,CB.COD_EAN))
	WHERE 1 = 1
		AND M00ZA IN (1)
		AND M03AE IN(1110,1111,1112,1113,1114,147,1147) 
		AND CONVERT(DATE,M00AF) BETWEEN CONVERT(DATE,@DT_INI) AND CONVERT(DATE,@DT_FIM)
	GROUP BY
		M00ZA 
		,CONVERT(DATE,M00AF)
		,CB.COD_PRODUTO
		--,M03AH
) AS PDV LEFT JOIN
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
(	
	SELECT
		'BI_ANAL_TICKET' AS TIPO
		,COD_lOJA
		,COD_PRODUTO
		,CONVERT(DATE,DATA) AS DATA
		,SUM(VALOR) AS VLRCUPOM
	FROM
		dw.dbo.BI_ANAL_TICKET with (NOLOCK) 
	WHERE 1 = 1
		AND DATA >= @DT_INI
		AND DATA <= @DT_FIM
		and COD_PRODUTO is not NULL
		AND COD_LOJA IN (1)
	GROUP BY
		COD_lOJA
		,CONVERT(DATE,DATA)
		,COD_PRODUTO
) AS BASE_TI ON (PDV.COD_LOJA = BASE_TI.COD_LOJA AND PDV.COD_PRODUTO = BASE_TI.COD_PRODUTO)
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*(	
	SELECT
		'BASE_BI' AS TIPO
		,COD_LOJA AS COD_LOJA
		,COD_PRODUTO
		,CONVERT(DATE,DATA) AS DATA
		,SUM(VALOR_TOTAL) AS VLRCUPOM
	FROM
		BI.dbo.BI_VENDA_PRODUTO AS VP WITH (NOLOCK)
	WHERE 1 = 1
		AND COD_LOJA IN (1)
		AND CONVERT(DATE,DATA) BETWEEN CONVERT(DATE,@DT_INI) AND CONVERT(DATE,@DT_FIM)
	GROUP BY
		COD_LOJA 
		,CONVERT(DATE,DATA)
		,COD_PRODUTO
) AS BASE_BI*/ 
WHERE 1 = 1
	AND PDV.VLRCUPOM <> BASE_TI.VLRCUPOM

--SELECT TOP 50 * FROM ZEUSRETAIL.DBO.ZAN_M03

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @DT_INI AS DATE = CONVERT(DATE,'20140125')
DECLARE @DT_FIM AS DATE = CONVERT(DATE,'20140125')

select 
	'BI_ANAL_TICKET' as BASE
	,SUM(VALOR) AS VLR_TOTAL
from dw.dbo.BI_ANAL_TICKET
WHERE 1 = 1
AND DATA >= @DT_INI
AND DATA <= @DT_FIM
and COD_PRODUTO is not NULL
AND COD_LOJA IN (1)

union all
select
	'BI_ANAL_MOVTO_CAIXA' as BASE
	,SUM(VALOR_TOTAL)
from dw.dbo.BI_ANAL_MOVTO_CAIXA
WHERE 1 = 1
AND DATA >= @DT_INI
AND DATA <= @DT_FIM
AND COD_LOJA IN (1)

union all
SELECT
	'Zan_M03' as BASE
	,SUM(M03AP - M03AQ)	 -- Valor Total
FROM  [ZeusRetail].dbo.Zan_M03 with (NOLOCK)
where 1 = 1
AND M00AF >= @DT_INI
AND M00AF <= @DT_FIM
AND M00ZA IN (1)
AND M03AE IN(1110,1111,1112,1113,1114,147,1147) 
GROUP BY M00ZA , M00AF

union all
SELECT 
	'Zan_M01' as BASE
	,Sum(M02AK - M02AL)	 -- Valor Total
FROM  [ZeusRetail].dbo.Zan_M02 with (NOLOCK)
where 1 = 1
AND M00AF >= @DT_INI
AND M00AF <= @DT_FIM
AND M00ZA IN (1)
AND M02AE IN(1110,1111,1112,1113,1114,147,1147) 
GROUP BY M00ZA , M00AF

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @DT_INI AS DATE = CONVERT(DATE,'20130101')
DECLARE @DT_FIM AS DATE = CONVERT(DATE,'20140101')
	
	SELECT
		*
	FROM
	(
	SELECT 
		'ZAN_M02' AS BASE
		,M00ZA AS COD_LOJA
		,CONVERT(DATE,M00AF) AS DATA
		,M00AC AS CAIXA
		,M00AD AS CUPOM
		,M02AK - M02AL AS VALOR_TOTAL	 -- VALOR TOTAL
	FROM  [ZEUSRETAIL].DBO.ZAN_M02 WITH (NOLOCK)
	WHERE 1 = 1
		AND M00AF >= @DT_INI
		AND M00AF <= @DT_FIM
		AND M00ZA IN (1)
		AND M02AE IN(1110,1111,1112,1113,1114,147,1147) 
	) AS M02
		LEFT JOIN
	(
	SELECT
		'BI_ANAL_MOVTO_CAIXA' AS BASE
		,COD_LOJA
		,CONVERT(DATE,DATA) AS DATA
		,CAIXA
		,CUPOM
		,VALOR_TOTAL
	FROM DW.DBO.BI_ANAL_MOVTO_CAIXA
	WHERE 1 = 1
		AND DATA >= @DT_INI
		AND DATA <= @DT_FIM
		AND COD_LOJA IN (1)
	) AS MOVTO_CAIXA ON (M02.COD_LOJA = MOVTO_CAIXA.COD_LOJA AND M02.DATA = MOVTO_CAIXA.DATA AND M02.CAIXA = MOVTO_CAIXA.CAIXA AND M02.CUPOM = MOVTO_CAIXA.CUPOM)
	WHERE 1 = 1
		AND MOVTO_CAIXA.BASE IS NULL
	

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @DT_INI AS DATE = CONVERT(DATE,'20140224')
	DECLARE @DT_FIM AS DATE = CONVERT(DATE,'20140224')

	SELECT * FROM [ZEUSRETAIL].DBO.ZAN_M02 WITH (NOLOCK)
	WHERE 1 = 1
		AND M00AF >= @DT_INI
		AND M00AF <= @DT_FIM
		AND M00ZA IN (1)
		AND M02AE IN(1110,1111,1112,1113,1114,147,1147) 
		AND M00AC = 21
		AND M00AD = 181720
	
	
	
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RELOAD DW ANAL_TICKET E MOVTO_CAIXA (BUSCA CUPONS NÃO INTEGRADOS POR DIA)
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @DT_INI AS DATE = CONVERT(DATE,'20140224');
	DECLARE @DT_FIM AS DATE = CONVERT(DATE,'20140224');
	DECLARE @COD_LOJA INT;
	DECLARE @DATA DATE;

	DECLARE DW_CUPOM_CURSOR CURSOR FOR 	
	-- -------------------------------------------------------------------------
	-- SELECT DO CURSOR BUSCANDO LOJAS/DATAS COM CUPONS NÃO CARREGADOS
	-- -------------------------------------------------------------------------
		SELECT DISTINCT
			M02.COD_LOJA
			,CONVERT(DATE,M02.DATA) AS DATA
		FROM
		(
		SELECT 
			'ZAN_M02' AS BASE
			,M00ZA AS COD_LOJA
			,CONVERT(DATE,M00AF) AS DATA
			,M00AC AS CAIXA
			,M00AD AS CUPOM
			,M02AK - M02AL AS VALOR_TOTAL	 -- VALOR TOTAL
		FROM  [ZEUSRETAIL].DBO.ZAN_M02 WITH (NOLOCK)
		WHERE 1 = 1
			AND M00AF >= @DT_INI
			AND M00AF <= @DT_FIM
			--AND M00ZA IN (1)
			AND M02AE IN(1110,1111,1112,1113,1114,147,1147) 
		) AS M02
			LEFT JOIN
		(
		SELECT
			'BI_ANAL_MOVTO_CAIXA' AS BASE
			,COD_LOJA
			,CONVERT(DATE,DATA) AS DATA
			,CAIXA
			,CUPOM
			,VALOR_TOTAL
		FROM DW.DBO.BI_ANAL_MOVTO_CAIXA
		WHERE 1 = 1
			AND DATA >= @DT_INI
			AND DATA <= @DT_FIM
			--AND COD_LOJA IN (1)
		) AS MOVTO_CAIXA ON (M02.COD_LOJA = MOVTO_CAIXA.COD_LOJA AND M02.DATA = MOVTO_CAIXA.DATA AND M02.CAIXA = MOVTO_CAIXA.CAIXA AND M02.CUPOM = MOVTO_CAIXA.CUPOM)
		WHERE 1 = 1
			AND MOVTO_CAIXA.BASE IS NULL	
	
	OPEN DW_CUPOM_CURSOR

	FETCH NEXT FROM DW_CUPOM_CURSOR 
	INTO @COD_LOJA, @DATA

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- -------------------------------------------------------------------------
		-- LOOP DO CURSOR RODANDO A PROC PARA CADA DIA/LOJA QUE PRECISAR
		-- -------------------------------------------------------------------------
		EXEC [INTEGRACOES].[dbo].[DW_CARGA_MOVTO_PDV_01] @DATA, @DATA, @COD_LOJA
		
		FETCH NEXT FROM DW_CUPOM_CURSOR 
		INTO @COD_LOJA, @DATA
	END 
	CLOSE DW_CUPOM_CURSOR;
	DEALLOCATE DW_CUPOM_CURSOR;	
	
	
