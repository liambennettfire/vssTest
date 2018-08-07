SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.create_project_comment_record') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.create_project_comment_record 
end
go

create PROCEDURE dbo.create_project_comment_record 
@v_Comment_externalid varchar(30),
@v_comment varchar(8000),
@v_projectimportkey int,
@v_new_projectkey int,
@v_sortorder int,
@v_message varchar(255) output
												
AS
declare 
@v_datacode int,
@v_datasubcode int,
@v_cnt int,
@v_commentkey int

if @v_comment is null or ltrim(rtrim(@v_comment)) = '' begin
	return
end
select @v_datacode = datacode, @v_datasubcode = datasubcode
from subgentables
where tableid = 284 
and externalcode = @v_Comment_externalid

if @v_datacode is null begin
	update project_import
	set processerrormessage = @v_message + ' Comment Type ' + @v_Comment_externalid + ' for ' +  substring(@v_comment, 1, 30) + ' could not be found.'
	where projectimportkey = @v_projectimportkey 
end else begin

	select @v_cnt = count(*)
	from taqprojectcomments
	where taqprojectkey = @v_new_projectkey 
	and commenttypecode = @v_datacode
	and commenttypesubcode = @v_datasubcode

	if @v_cnt > 0 begin
		update qsicomments
		set commenttext = @v_comment
		where commenttypecode = @v_datacode
		and commenttypesubcode = @v_datasubcode
		and commentkey = @v_new_projectkey
	end else begin
		exec get_next_key 'qsidba',@v_commentkey output

		insert into qsicomments(commentkey, Commenttypecode, Commenttypesubcode, commenttext, commenthtml, commenthtmllite, lastmaintdate, lastuserid)
		values(@v_commentkey, @v_datacode, @v_datasubcode, @v_Comment, '<DIV>' + @v_Comment + '</DIV>', '<DIV>' + @v_Comment + '</DIV>', getdate(), 'import')
		
		insert into Taqprojectcomments(taqprojectkey, Commenttypecode, Commenttypesubcode, Commentkey, Sortorder, Lastmaintdate, lastuserid)
		values(@v_new_projectkey, @v_datacode, @v_datasubcode, @v_commentkey, @v_sortorder, getdate(), 'import')

	end
end
