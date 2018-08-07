SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloonixothertext_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloonixothertext_sp]
GO



CREATE proc dbo.eloonixothertext_sp @i_bookkey int, 
@c_texttypecode varchar (10),
@c_elofieldtag varchar (100)



/*******************************************************/
/*	                                                 */
/*	    Author   : DSL                                    */
/*	    Creation Date   : 9/14/00                   */
/*	    Comments :Outputs ONIX Other Text Repeating group  */
/** Modified 4/25/02 to remove CDATA tag and send text as html **/
/** Backup of this procedure prior to changes can be found in */
/** k:\exports\applications\onix\backup04252002 **/
/*                                                            */
/* CT - Modified 9/17/02 to reinsert the CDATA tag, per B&N and other client's request  */
/*******************************************************/     


AS 
DECLARE @i_commenttypecode int
DECLARE @i_commenttypesubcode int
DECLARE @i_countplain int
DECLARE @i_counthtml int
DECLARE @i_textlength int
DECLARE @i_returncode int
DECLARE @c_errormessage varchar (255)
DECLARE @c_checknulltext varchar (255)
DECLARE @c_feedstring varchar (8000)
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

select @c_checknulltext = convert (varchar (255),feedtext) from elotemptext

if @c_checknulltext = NULL
begin 
	return 0
end
else
begin
	/* Modified 9/17/02 - CT - insert CDATA tag to Output text*/
	insert into eloonixfeed (feedtext) values ('<othertext>')

	insert into eloonixfeed (feedtext) 
	values ('<d102>' + @c_texttypecode +'</d102>')

	insert into eloonixfeed (feedtext) values ('<d103>02</d103>')

	exec @i_returncode = elooutputformattedtext_sp '<d104>','</d104>'
	if @i_returncode=-1
	begin
		rollback tran
		/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
		return -1  /** Fatal SQL Error **/
	end

	insert into eloonixfeed (feedtext) 
	values ('</othertext>')
end /* end of else statement  */
return 0

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

