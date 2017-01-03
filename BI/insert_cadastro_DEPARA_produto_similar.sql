INSERT INTO [BI].[dbo].[CADASTRO_DEPARA_PRODUTO_SIMILAR]
SELECT
	ps.[COD_PRODUTO],
    ps.[COD_PRODUTO_SIMILAR],
    999,
	ps.[DTA_CADASTRO]
from
	[192.168.0.6].[Zeus_rtg].[dbo].[TAB_PRODUTO] as ps LEFT join [192.168.0.6].[Zeus_rtg].[dbo].[TAB_USUARIO] as us on (ps.USUARIO = us.DES_USUARIO)
WHERE 1 = 1
	and ps.[COD_PRODUTO_SIMILAR] is not null