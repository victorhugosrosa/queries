--declare @dt_Ini as date = '20140801'

declare @dt_Fim as date = '20140810'
declare @cod_loja as int = 1
declare @dt_Ini as date =  dw.[dbo].[fn_PrimeiroDiadoMes](convert(date,@dt_Fim)) 


SELECT 
	 M00ZA AS CodLoja
	--,CONVERT(date,M00AF) AS Data
	--,ifunc.cadastro AS CodOp--,M01AH AS CodOp
	--,fz.[Nome] as NomeOp
	,SUM(M01AK) AS VlrCupom
	,sum(case when [M01AV] = '0' then 0 else M01AK end) as VlrCupomCli
	,COUNT(M00AD) AS QtdCupom
	,sum(case when [M01AV] = '0' then 0 else 1 end) as QtdCupomCli
	,sum(case when [M01BV] = '0' then 0 else 1 end)  as QtdNFP
FROM  ZeusRetail.dbo.Zan_M01 as c with (NOLOCK)
	left join [ZeusRetail].[dbo].[tab_funcionario] as fz with (NOLOCK)
	on 1=1
	and fz.cod_funcionario = c.M01AH
	left join [192.168.0.6].intranet.dbo.tab_funcionarios as ifunc with (NOLOCK)
	on (fz.cod_funcionario = ifunc.id_sistema)
where 1 = 1
	AND M00ZA in (@cod_loja)
	and CONVERT(date,M00AF) between convert(date,@dt_Ini) and convert(date,@dt_Fim)
	--AND M00AD IN (323787)
group by 
	M00ZA 
	--,M00AF
	--,ifunc.cadastro
	--,fz.[Nome]
	--,M01AH
Order by 1,2