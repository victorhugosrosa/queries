SET NOCOUNT ON;

declare @tab_xml as table
(
intCod int
,strNome varchar(50) 
);

declare @strXML varchar(1000)  
set @strXML = '<Tab1><reg intCod="10" strNome="Ana Paula" />'
set @strXML = @strXML + '<reg intCod="20" strNome="Ana Lucia" />'
set @strXML = @strXML + '<reg intCod="30" strNome="Ana 30" />'
set @strXML = @strXML + '<reg intCod="40" strNome="Ana 40" />'
set @strXML = @strXML + '<reg intCod="50" strNome="Ana 50" />'
set @strXML = @strXML + '<reg intCod="60" strNome="Ana 60" />'
set @strXML = @strXML + '</Tab1>'  

declare @cod dec(6)  
declare @nome char(20)  
declare @intDocRet integer  
declare @proc_ret bigint  

execute @proc_ret = sp_xml_preparedocument @intDocRet output, @strXML  
-- este select vai listar todo mundo

insert into @tab_xml
select intCod, strNome
from openxml (@intDocRet, 'Tab1/reg',3)
with (intCod dec(3),strNome char(20))

DECLARE @intCod int, @strNome varchar(50);

PRINT '-------- XML Report --------';

DECLARE XML_cursor CURSOR FOR 

SELECT intCod, strNome
from @tab_xml;

OPEN XML_cursor

FETCH NEXT FROM XML_cursor 
INTO @intCod, @strNome

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '----- Código: ' + convert(varchar(10),@intCod) + '----- Nome: ' + @strNome

    FETCH NEXT FROM XML_cursor 
    INTO @intCod, @strNome
END 
CLOSE XML_cursor;
DEALLOCATE XML_cursor;