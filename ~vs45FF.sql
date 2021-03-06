/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * FROM [CtrlNfe].[dbo].[NFE_DET]
WHERE num_danfe = '35140504356926000175550010000175281006299140'

select * from CtrlNfe.dbo.NFE_STATUS WHERE num_danfe = '35140504356926000175550010000175281006299140'

--select * from VW_CUSTOS_ATIVOS where COD_PRODUTO = 53709 and COD_FORNECEDOR = 18055 order by DTA_GRAVACAO desc

--select * from [192.168.0.6].zeus_rtg.dbo.tab_produto_fornecedor where COD_PRODUTO = 53709 and COD_FORNECEDOR = 18055 AND COD_LOJA = 9

select * from [192.168.0.6].[ZEUS_RTG].[DBO].[TAB_FORNECEDOR_NOTA] where num_danfe = '35140504356926000175550010000175281006299140'

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------------------------------------------------------------
SELECT
*
FROM
	[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
WHERE 1 = 1
	AND DET.NUM_DANFE = '35140601237159000278550010000114111000106954'
	--AND STA.flg_ErroRecebimento = 1

select * from [192.168.0.6].[ZEUS_RTG].[DBO].[TAB_FORNECEDOR_NOTA] where num_danfe = '35140643453281000140550010000026291800901303'

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------------------------------------------------------------
SELECT
*
FROM
	[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
		LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
WHERE 1 = 1
	AND DET.NUM_DANFE = '35140601237159000278550010000114111000106954'
	and DET.Mensagem is not null
	AND STA.Flg_EntradaZeus is not null
	AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,GETDATE()-1) AND CONVERT(DATE,GETDATE())
	
SELECT *
FROM
	[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
		LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
WHERE 1 = 1
	AND DET.NUM_DANFE = '35140601237159000278550010000114111000106954'
	and DET.Mensagem is not null
	AND STA.DtRecebimento is null
	--AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,GETDATE()-1) AND CONVERT(DATE,GETDATE())
	
	
SELECT TOP 10 * FROM
[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
WHERE 1 = 1
AND Mensagem IS NOT NULL
ORDER BY IDE.DtGravacao Desc




















-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------------------------------------------------------------
SELECT
*
FROM
	[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
		LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
WHERE 1 = 1
	AND DET.NUM_DANFE in
	
	(
	'35140601237159000278550010000114111000106954'
	)
	
	and DET.Mensagem is not null
	AND STA.Flg_EntradaZeus is not null
	--AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,GETDATE()-1) AND CONVERT(DATE,GETDATE())
	
SELECT *
FROM
	[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CTRLNFE].[DBO].[NFE_STATUS] AS STA ON (DET.NUM_DANFE = STA.NUM_DANFE)
		LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
WHERE 1 = 1
	AND DET.NUM_DANFE in
	
	(
	'35140643453281000140550010000026291800901303'
	)
	and DET.Mensagem is not null
	AND STA.DtRecebimento is null
	--AND CONVERT(DATE,IDE.DtGravacao) BETWEEN CONVERT(DATE,GETDATE()-1) AND CONVERT(DATE,GETDATE())
	
	
SELECT TOP 10 * FROM
[CTRLNFE].[DBO].[NFE_DET] AS DET LEFT JOIN [CtrlNfe].[dbo].[NFE_IDE] AS IDE ON (DET.num_danfe = IDE.num_danfe)
WHERE 1 = 1
AND Mensagem IS NOT NULL
ORDER BY IDE.DtGravacao DESC





	
SELECT TOP 10 * FROM
[CTRLNFE].[DBO].[NFE_DET] AS DET
where Cod_fornecedor = 101684
and convert(date,DTA_GRAVACAO) >= '20140501'
and Cod_produto = 55864