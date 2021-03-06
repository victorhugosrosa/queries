USE [BI]
GO
/****** Object:  StoredProcedure [dbo].[QW_RUPTURA]    Script Date: 09/20/2013 17:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[QW_RUPTURA]
	@dataIni [varchar](8),
	@dataFim [varchar](8)
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;

	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- PRODUTOS EM LINHA DA LOJA
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TEMP_LINHA_LOJA AS TABLE
	(
		[COD_LOJA] [INT]
		,[COD_PRODUTO] [INT]
		,DESCRICAO VARCHAR(50)
		,COD_SECAO [INT]
		,COD_GRUPO [INT]
		,CLASSIF_PRODUTO_LOJA VARCHAR(10)
	);

	INSERT INTO @TEMP_LINHA_LOJA
	SELECT DISTINCT
		SB.COD_LOJA
		,CAST(SB.CODIGO AS INT)
		,P.DESCRICAO
		,P.COD_SECAO
		,P.COD_GRUPO
		,ISNULL(E.CLASSIF_PRODUTO_LOJA,'SEM_CLASS')
	FROM
		[BI].[dbo].[VW_BI_SUPERBASE] AS SB LEFT JOIN BI.DBO.BI_CAD_PRODUTO AS P ON (P.COD_PRODUTO = SB.CODIGO)
			LEFT JOIN BI.DBO.COMPRAS_ESTATISTICA_PRODUTO AS E ON (E.COD_PRODUTO = SB.CODIGO AND E.COD_LOJA = SB.COD_LOJA)
	where 1=1
		AND SB.[PROIBIDO_COMPRA] = 'N'
		AND SB.[FORA_MIX] = 'N'
		AND SB.[FORA_LINHA] = 'N'
		AND SB.COD_SECAO NOT IN (6,10,37,40,41,15,35,19,99,9,16,20)
		AND SB.TIPO_PRODUTO <> 'SAZONAL'
		AND SB.IPV = 'N'
		AND P.PESADO = 'N';
		
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- PRODUTOS EM MOVIMENTO DA LOJA
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @TEMP_PRODUTO_MOV AS TABLE
	(
		DTA_MOVIMENTO [DATE]
		,[COD_LOJA] [INT]
		,[COD_PRODUTO] [INT]
		,QTD_ESTOQUE [INT]
		,RUPTURA [INT]
		,NEGATIVO [INT]
	);

	INSERT INTO @TEMP_PRODUTO_MOV
	SELECT DISTINCT
		CONVERT(DATE,M.DTA_MOVIMENTO) AS DTA_MOVIMENTO
		,M.COD_LOJA
		,CAST(M.COD_PRODUTO AS INT)
		,CAST(M.QTD_ESTOQUE	AS INTEGER) AS QTD_ESTOQUE
		,(CASE WHEN M.QTD_ESTOQUE =0 THEN 1 ELSE 0 END) AS RUPTURA
		,(CASE WHEN M.QTD_ESTOQUE <0 THEN 1 ELSE 0 END) AS NEGATIVO
	FROM
		[192.168.0.6].[ZEUS_RTG].[DBO].[TAB_PRODUTO_MOVIMENTO] AS M 
	WHERE 1 = 1
		AND M.COD_LOJA IN (1,2,3,6,7,9,13,12,17,18,19,20,10,4)
		AND CONVERT(DATE,M.DTA_MOVIMENTO) BETWEEN CONVERT(DATE,@dataIni) AND CONVERT(DATE,@dataFim);

	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- PRODUTOS EM LINHA DA LOJA - ANALISE MOVIMENTO [GERAÇÃO TXT]
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT --TOP 100
		ISNULL(MOV.DTA_MOVIMENTO,CONVERT(DATE,@dataIni)) AS DTA_MOVIMENTO
		,LINHA.COD_LOJA
		,LINHA.COD_PRODUTO
		,LINHA.DESCRICAO
		,LINHA.COD_SECAO
		,LINHA.COD_GRUPO
		,LINHA.CLASSIF_PRODUTO_LOJA
		,ISNULL(MOV.QTD_ESTOQUE,0) AS QTD_ESTOQUE
		,ISNULL(MOV.RUPTURA,0) AS RUPTURA
		,ISNULL(MOV.NEGATIVO,0) AS NEGATIVO
	FROM
		@TEMP_LINHA_LOJA AS LINHA LEFT OUTER JOIN @TEMP_PRODUTO_MOV AS MOV ON (LINHA.COD_LOJA = MOV.COD_LOJA AND LINHA.COD_PRODUTO = MOV.COD_PRODUTO)
	WHERE 1 = 1;	
	
END



