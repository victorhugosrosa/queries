--DECLARE @DT_INI AS DATE = '20140801'

DECLARE @COD_LOJA AS INT = 1
DECLARE @DT_FIM AS DATE = '20140810'

DECLARE @TRI AS INT
DECLARE @DT_1TRI AS DATE
DECLARE @DT_2TRI AS DATE
DECLARE @DT_3TRI AS DATE
DECLARE @DT_4TRI AS DATE
DECLARE @DT_INI_T AS DATE
DECLARE @DT_FIM_T AS DATE

SELECT @DT_1TRI = CONVERT(VARCHAR,YEAR(@DT_FIM)) + '0101'
SELECT @DT_2TRI = CONVERT(VARCHAR,YEAR(@DT_FIM)) + '0401'
SELECT @DT_3TRI = CONVERT(VARCHAR,YEAR(@DT_FIM)) + '0701'
SELECT @DT_4TRI = CONVERT(VARCHAR,YEAR(@DT_FIM)) + '1001'

SELECT @TRI =
	(CASE
		WHEN @DT_FIM >= @DT_1TRI AND @DT_FIM < @DT_2TRI THEN 1
		WHEN @DT_FIM >= @DT_2TRI AND @DT_FIM < @DT_3TRI THEN 2
		WHEN @DT_FIM >= @DT_3TRI AND @DT_FIM < @DT_4TRI THEN 3
		WHEN @DT_FIM >= @DT_4TRI THEN 4
	END)
	
IF (@TRI = 1)
BEGIN
	SET @DT_INI_T = @DT_1TRI
	SET @DT_FIM_T = DATEADD(D,-1,@DT_2TRI)
END

IF (@TRI = 2)
BEGIN
	SET @DT_INI_T = @DT_2TRI
	SET @DT_FIM_T = DATEADD(D,-1,@DT_3TRI)
END

IF (@TRI = 3)
BEGIN
	SET @DT_INI_T = @DT_3TRI
	SET @DT_FIM_T = DATEADD(D,-1,@DT_4TRI)
END

IF (@TRI = 4)
BEGIN
	SET @DT_INI_T = @DT_4TRI
	SET @DT_FIM_T = CONVERT(VARCHAR,YEAR(@DT_FIM)) + '1231'
END
	
SELECT 
	 M00ZA AS CodLoja
	--,CONVERT(DATE,M00AF) AS DATA
	,IFUNC.CADASTRO AS CodOp--,M01AH AS CODOP
	,FZ.[NOME] AS NomeOp
	,SUM(M01AK) AS VlrCupom
	,SUM(CASE WHEN [M01AV] = '0' THEN 0 ELSE M01AK END) AS VlrCupomCli
	,COUNT(M00AD) AS QtdCupom
	,SUM(CASE WHEN [M01AV] = '0' THEN 0 ELSE 1 END) AS QtdCupomCli
	,SUM(CASE WHEN [M01BV] = '0' THEN 0 ELSE 1 END)  AS QtdNfp
FROM  ZEUSRETAIL.DBO.ZAN_M01 AS C WITH (NOLOCK)
	LEFT JOIN [ZEUSRETAIL].[DBO].[TAB_FUNCIONARIO] AS FZ WITH (NOLOCK)
	ON 1=1
	AND FZ.COD_FUNCIONARIO = C.M01AH
	LEFT JOIN [192.168.0.6].INTRANET.DBO.TAB_FUNCIONARIOS AS IFUNC WITH (NOLOCK)
	ON (FZ.COD_FUNCIONARIO = IFUNC.ID_SISTEMA)
WHERE 1 = 1
	AND M00ZA IN (@COD_LOJA)
	AND CONVERT(DATE,M00AF) BETWEEN CONVERT(DATE,@DT_INI_T) AND CONVERT(DATE,@DT_FIM_T)
	--AND M00AD IN (323787)
GROUP BY 
	M00ZA 
	--,M00AF
	,IFUNC.CADASTRO
	,FZ.[NOME]
	,M01AH
ORDER BY 1,2