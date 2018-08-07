SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.load_contact_main') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.load_contact_main
end
go
-- exec load_contact_main
create PROCEDURE [dbo].load_contact_main
AS

declare 
@FilePath varchar(8000),
@FileNameMask varchar(10),
@cmd varchar(8000),
@FileName varchar(50),
@v_arch_dir varchar(8000)
begin

TRUNCATE TABLE import_request_spreadsheet

--this needs to be in client defaults
select @FilePath = stringvalue
from clientdefaults
where clientdefaultid = 41

select @v_arch_dir = stringvalue
from clientdefaults
where clientdefaultid = 42

set @FileNameMask = '*.txt'


create table #filenames (fname varchar(250))
select @cmd = 'dir /B ' + @FilePath + @FileNameMask
insert #filenames exec master..xp_cmdshell @cmd

delete #filenames where fname is null or lower(fname) like '%not found%'

while exists (select * from #filenames)
begin
	select @FileName = min(fname) from #filenames
	exec load_contact_from_spreadsheet @FileName, @FilePath, @v_arch_dir
	delete #filenames where fname = @FileName
end

--
end
go