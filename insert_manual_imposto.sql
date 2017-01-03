INSERT INTO [BI].[dbo].[BI_PRECO_IMPOSTOS]
           ([COD_PRODUTO]
           ,[COD_FORNECEDOR]
           ,[IPI_VLR]
           ,[IPI_PERC]
           ,[CST_ICMS_ENTRADA]
           ,[ALIQUOTA_ICMS_ENTRADA]
           ,[REDUCAO_ICMS_ENTRADA]
           ,[IVA]
           ,[PAUTA_GOV]
           ,[CST_ICMS_SAIDA]
           ,[ALIQUOTA_ICMS_SAIDA]
           ,[REDUCAO_ICMS_SAIDA]
           ,[PIS]
           ,[COFINS]
           ,[CREDITA_PISCOFINS]
           ,[COD_CST_PIS_COFINS])
  select
           [ITEMID]--<COD_PRODUTO, int,>
           ,[COD_FORNECEDOR]--<COD_FORNECEDOR, int,>
           ,[IPI_VLR]--<IPI_VLR, numeric(10,3),>
           ,[IPI_ALIQ]--<IPI_PERC, numeric(10,2),>
           ,ICMS_ENT_CST--<CST_ICMS_ENTRADA, int,>
           ,ICMS_ENT_ALIQ--<ALIQUOTA_ICMS_ENTRADA, float,>
           ,ICMS_ENT_REDUCAO--<REDUCAO_ICMS_ENTRADA, float,>
           ,ICMS_ENT_IVA--<IVA, float,>
           ,ICMS_ENT_PAUTA--<PAUTA_GOV, float,>
           ,ICMS_SAI_CST--<CST_ICMS_SAIDA, int,>
           ,ICMS_SAI_ALIQ--<ALIQUOTA_ICMS_SAIDA, float,>
           ,ICMS_SAI_REDUCAO--<REDUCAO_ICMS_SAIDA, float,>
           ,1.65--<PIS, float,>
           ,7.6--<COFINS, float,>
           ,1--<CREDITA_PISCOFINS, bit,>
           ,PIS_COFINS_ENT_CST--<COD_CST_PIS_COFINS, int,>
   FROM
	[BI].[dbo].[CADASTRO_CAD_PRODUTO_NOVO]
	where 1=1 
	and ITEMID =1013823


