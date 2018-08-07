SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[elo_output_comment_new_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[elo_output_comment_new_sp]
GO



CREATE proc dbo.elo_output_comment_new_sp 
    @i_bookkey int, 
    @c_elofieldtag varchar (100),
    @c_prefix varchar (255),
    @c_postfix varchar (255),
    @i_format int


/*******************************************************/
/*	                                                 */
/*	    Author   : DSL                                    */
/*	    Creation Date   : 9/14/00                   */
/*	    Comments :Outputs the plain text comment  */
/*	              for the given bookkey and eloquence field tag */
/*******************************************************/

AS 
DECLARE @i_commenttypecode int
DECLARE @i_commenttypesubcode int
DECLARE @i_count int
DECLARE @i_countplain int
DECLARE @i_counthtml int
DECLARE @i_returncode int
DECLARE @c_errormessage varchar (255)
DECLARE @tp_textpointer varbinary(16)

select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag=@c_elofieldtag

if @i_commenttypecode=0
begin
/*select @c_errormessage='Eloquence Field Tag ' + @c_elofieldtag + '
not found for comment in subgentables' */
/*exec eloprocesserror_sp @i_bookkey,@@error,'WARNING',@c_errormessage*/
return 0
end

select @i_counthtml=count (*) from bookcommenthtml
where bookkey=@i_bookkey and printingkey=1 and commenttypecode=@i_commenttypecode and
commenttypesubcode=@i_commenttypesubcode

select @i_countplain=count (*) from bookcomments 
where bookkey=@i_bookkey and printingkey=1 and commenttypecode=@i_commenttypecode and
commenttypesubcode=@i_commenttypesubcode

if @i_counthtml = 0 and @i_countplain = 0 /* stop processing if no rows exist */
return 0

/*truncate the temporary text table */

truncate table elotemptext


if @i_counthtml > 0 /** try for html first **/
begin
	insert into elotemptext (tempkey,feedtext) 
	select 1,commenttext
	from bookcommenthtml
	where bookkey=@i_bookkey and printingkey=1 and commenttypecode=@i_commenttypecode and
	commenttypesubcode=@i_commenttypesubcode
end
else if @i_countplain > 0 /** html doesn't exist - try for plain text **/
begin
	insert into elotemptext (tempkey,feedtext) 
	select 1,commenttext
	from bookcomments 
	where bookkey=@i_bookkey and printingkey=1 and commenttypecode=@i_commenttypecode and
	commenttypesubcode=@i_commenttypesubcode
end


exec @i_returncode = elo_output_formatted_text_new_sp @c_prefix, @c_postfix, @i_format
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

return 0

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

