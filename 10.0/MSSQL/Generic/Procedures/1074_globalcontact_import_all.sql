--exec globalcontact_import_all
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.globalcontact_import_all') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.globalcontact_import_all
end
go

create PROCEDURE [dbo].globalcontact_import_all 
AS

DECLARE 
@i_globalcontactrequestkey int,
@v_retcode int,
@i_newglobalcontactkey int,
@v_message varchar(6000),
@v_errormsg  varchar(6000)

BEGIN 

DECLARE cursor_newcontact INSENSITIVE CURSOR
FOR
select globalcontactrequestkey
from globalcontact_import
where processedind = 0
and relatedprojectimportkey is null
FOR READ ONLY

OPEN cursor_newcontact
FETCH NEXT FROM cursor_newcontact
INTO @i_globalcontactrequestkey
while (@@FETCH_STATUS<>-1 ) begin
	IF (@@FETCH_STATUS<>-2)
	begin
		exec globalcontact_import_sp @i_globalcontactrequestkey, @i_newglobalcontactkey output, @v_retcode output, @v_message output, 0
	FETCH NEXT FROM cursor_newcontact INTO @i_globalcontactrequestkey
	end
end


close cursor_newcontact
deallocate cursor_newcontact


END

