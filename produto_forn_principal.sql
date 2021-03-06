/****** Script for SelectTopNRows command from SSMS  ******/
SELECT a.[COD_FORNECEDOR]
		,cf.DESCRICAO as NO_FORN
      ,a.[COD_PRODUTO]
      ,cp.DESCRICAO AS NO_PROD
      ,[DTA_GRAVACAO]
  FROM [BI].[dbo].[SUPPLY_PRODUTO_FORN_PRINCIPAL_AUTO] as a
  inner join BI.dbo.BI_CAD_PRODUTO as cp
	on a.COD_PRODUTO = cp.COD_PRODUTO
  inner join BI.dbo.BI_CAD_FORNECEDOR as cf
	on a.[COD_FORNECEDOR] = cf.[COD_FORNECEDOR]
  
  
 order by
	[COD_PRODUTO]
	,[COD_FORNECEDOR]