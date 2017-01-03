USE [Alltec]
GO

/****** Object:  UserDefinedFunction [dbo].[ISO_WEEK]    Script Date: 08/21/2013 10:18:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[ISO_WEEK]
(
@Date	datetime
)
returns	 varchar(7)
as
/*
Function F_ISO_WEEK_OF_YEAR returns the
ISO 8601 week of the year for the date passed.
*/
begin

declare @WeekOfYear	 varchar(7)
select @WeekOfYear=
case when right(CONVERT(CHAR(7),@date,120),2) = '01' and myweek >= 52 then
cast(cast(CONVERT(CHAR(4),@date,120) as int)-1 as char(4))+'-'+right('00' + cast(myweek as varchar(2)),2)
when right(CONVERT(CHAR(7),@date,120),2) = '12' and myweek = 1 then
cast(cast(CONVERT(CHAR(4),@date,120) as int)+1 as char(4))+'-'+right('00' + cast(myweek as varchar(2)),2)
else CONVERT(CHAR(4),@date,120)+'-'+right('00' + cast(myweek as varchar(2)),2) end 
--as myweekofyear
from
(
select
-- Compute week of year as (days since start of year/7)+1
-- Division by 7 gives whole weeks since start of year.
-- Adding 1 starts week number at 1, instead of zero.
(datediff(dd,
-- Case finds start of year
case
when	NextYrStart <= @date
then	NextYrStart
when	CurrYrStart <= @date
then	CurrYrStart
else	PriorYrStart
end,@date)/7)+1 as myweek
from
(
select
-- First day of first week of prior year
PriorYrStart =
dateadd(dd,(datediff(dd,-53690,dateadd(yy,-1,aa.Jan4))/7)*7,-53690),
-- First day of first week of current year
CurrYrStart =
dateadd(dd,(datediff(dd,-53690,aa.Jan4)/7)*7,-53690),
-- First day of first week of next year
NextYrStart =
dateadd(dd,(datediff(dd,-53690,dateadd(yy,1,aa.Jan4))/7)*7,-53690)
from
(
select
--Find Jan 4 for the year of the input date
Jan4	= 
dateadd(dd,3,dateadd(yy,datediff(yy,0,@date),0))
) aa
) a
)z

return @WeekOfYear

end

GO