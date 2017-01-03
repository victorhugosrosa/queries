/*
select * from [AX2009_INTEGRACAO].DBO.TAB_CODIGO_BARRA WHERE COD_PRODUTO = 1014377 
*/

DECLARE @dt_Ini AS DATE = convert(date,'20140929')
DECLARE @dt_Fim AS DATE = convert(date,'20141005')

select
	M01.M00ZA as COD_LOJA
	--,M01.M00AC
	--,M01.M00AD
	,M01AH AS CodOp
	,fz.[Nome] as NomeOp
	,dbo.fn_FormataVlr_Excel(SUM(M03AP)) AS VALOR
from
	ZeusRetail.dbo.Zan_M01 as M01 with (NOLOCK) INNER JOIN ZeusRetail.dbo.Zan_M03 AS M03 with (NOLOCK) ON (M01.M00ZA = M03.M00ZA AND M01.M00AC = M03.M00AC AND M01.M00AD = M03.M00AD)
		left join [ZeusRetail].[dbo].[tab_funcionario] as fz with (NOLOCK) on (fz.cod_funcionario = M01.M01AH)
		
where 1 = 1
	and CONVERT(date,M01.M00AF) between convert(date,@dt_Ini) and convert(date,@dt_Fim)
	--and CAST(M03.M03AH AS DOUBLE PRECISION) = 7898592941954 --1013360
	and CAST(M03.M03AH AS DOUBLE PRECISION) = 7898592942210 --1014377
	--and M01.M00ZA in (17)
GROUP BY
	M01.M00ZA
	--,M01.M00AC
	--,M01.M00AD
	,M01AH
	,fz.[Nome]
	
