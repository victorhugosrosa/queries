SET NOCOUNT ON;

declare @tab_xml as table
(
	num_danfe varchar(50)
	,infCpl varchar(1000)
)

declare @strXML varchar(MAX)  
declare @num_danfe varchar(50)
declare @parentid as int

declare @intDocRet integer  

/*
select @num_danfe = num_danfe, @strXML = CONVERT(varchar(max),arq_xml) from NFe.dbo.TAB_RECEBIMENTO_NFE where num_danfe = '35140564904295000103550080004669971634720509'

EXEC sp_xml_preparedocument @intDocRet OUTPUT, @strXML;

select
	@parentid = id
from openxml (@intDocRet, '/',3)
WHERE LOCALNAME = 'infCpl'

select
	*
from openxml (@intDocRet, '/',3)
WHERE parentid = @parentid
*/

DECLARE XML_cursor CURSOR FOR 
	select
		num_danfe
		,CONVERT(varchar(max),arq_xml)
	from
		NFe.dbo.TAB_RECEBIMENTO_NFE
	where 1 = 1
		and num_danfe = '35140564904295000103550080004669971634720509'
		--and convert(date,dta_gravacao) >= convert(date,getdate()-1)
		

	OPEN XML_cursor

FETCH NEXT FROM XML_cursor 
INTO @num_danfe, @strXML

WHILE @@FETCH_STATUS = 0
BEGIN
	-- ------------------------------------------------------------------------------------
    EXEC sp_xml_preparedocument @intDocRet OUTPUT, @strXML;

	select
		@parentid = id
	from openxml (@intDocRet, '/',3)
	WHERE LOCALNAME = 'infCpl'

	insert into @tab_xml
	select
		@num_danfe as danfe
		,text as infCpl
	from openxml (@intDocRet, '/',3)
	WHERE parentid = @parentid    
	-- ------------------------------------------------------------------------------------
	
    FETCH NEXT FROM XML_cursor 
    INTO @num_danfe, @strXML
END 
CLOSE XML_cursor;
DEALLOCATE XML_cursor;


select * from @tab_xml