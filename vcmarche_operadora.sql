SELECT 
 M00ZA AS CodLoja
--,CONVERT(date,M00AF) AS Data
,dbo.F_ISO_WEEK_OF_YEAR(M00AF) as Semana
,ifunc.cadastro AS CodOp--,M01AH AS CodOp
,fz.[Nome] as NomeOp

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
AND M00ZA in (13)
and CONVERT(date,M00AF) between convert(date,'20140801') and convert(date,'20140831')
--and ifunc.cadastro = 74
and c.M01AH = 74
--AND M00AD IN (323787)
group by  M00ZA 
,dbo.F_ISO_WEEK_OF_YEAR(M00AF)
,ifunc.cadastro
,fz.[Nome]
,M01AH
Order by 1,2


select * from [192.168.0.6].intranet.dbo.tab_funcionarios where nome like '%gorete%'