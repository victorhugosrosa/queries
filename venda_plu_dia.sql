select
*
from
	ZeusRetail.dbo.Zan_M03
where 1=1
	and CONVERT(date,m00af) = CONVERT(date,getdate())
	and convert(double precision,M03AH) = convert(double precision,'4000539671401')