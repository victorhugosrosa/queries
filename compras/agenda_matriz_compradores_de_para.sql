

DECLARE @COMPRADOR_DE AS INT = 100058
DECLARE @COMPRADOR_PARA AS INT = 100066

INSERT INTO [BI].[dbo].[COMPRAS_AGENDA_PEDIDO_MATRIZ]
(
	[COD_FORNECEDOR]
	,[COD_COMPRADOR]
	,[DATA_BASE]
	,[VLR_FREQ]
	,[VLR_LEAD_TIME]
	,[VLR_DPD]
	,[OBSERVACAO]
	,[NO_CONTATO]
	,[MAIL_CONTATO]
	,[TEL_CONTATO]
	,[VLR_PEDIDO_MIN]
	,[FLG_BLOQUEADO]
)
SELECT [COD_FORNECEDOR]
      ,@COMPRADOR_PARA
      ,[DATA_BASE]
      ,[VLR_FREQ]
      ,[VLR_LEAD_TIME]
      ,[VLR_DPD]
      ,[OBSERVACAO]
      ,[NO_CONTATO]
      ,[MAIL_CONTATO]
      ,[TEL_CONTATO]
      ,[VLR_PEDIDO_MIN]
      ,[FLG_BLOQUEADO]
FROM
	[BI].[dbo].[COMPRAS_AGENDA_PEDIDO_MATRIZ]
WHERE 1=1
	AND COD_COMPRADOR = @COMPRADOR_DE