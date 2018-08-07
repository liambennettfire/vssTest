SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloamazonoutputcommenthtml_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloamazonoutputcommenthtml_sp]
GO


create proc dbo.eloamazonoutputcommenthtml_sp 
@i_bookkey int, 
@c_elofieldtag varchar (100),
@c_prefix varchar (100),
@c_postfix varchar (200)


/******************************************************	*/
/*	clone of eloamazonoutputcommnet				*/
/*     used to output HTML for Amazon.com                   */
/*	    Author   : CT                                     */
/*	    Creation Date   : 02/22/03				*/
/*	    Comments :Outputs the HTML comment  			*/
/*	              for the given bookkey and eloquence field tag */
/*******************************************************/

AS 
DECLARE @i_commenttypecode int
DECLARE @i_commenttypesubcode int
DECLARE @i_count int
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

select @i_count=count (*) from bookcommenthtml 
where bookkey=@i_bookkey and printingkey=1 and commenttypecode=@i_commenttypecode and
commenttypesubcode=@i_commenttypesubcode

if @i_count = 0 /* stop processing if no rows exist */
return 0

/*truncate the temporary text table */

truncate table elotemptext



insert into elotemptext (tempkey,feedtext) 
select 1,commenttext
from bookcommenthtml 
where bookkey=@i_bookkey and printingkey=1 and commenttypecode=@i_commenttypecode and
commenttypesubcode=@i_commenttypesubcode

select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1

if @c_prefix is not null and @c_prefix <> ''
begin
	/* Insert c_prefix onto front of text in elotemptext. An insert_offest of zero */
	/* means insert in beginning (insert_offset is first zero below. */
	/* Using a NULL here would append to end. */
	updatetext elotemptext.feedtext @tp_textpointer 0 0 @c_prefix
end

if @c_postfix is not null and @c_postfix <> ''
begin
	/* Append c_postfix onto end of text in elotemptext. An insert_offest of NULL */
	/* appends  c_postfix onto end. */
	/* Postfix may contain InsertIllus comment to be appended to main description */
	
	updatetext elotemptext.feedtext @tp_textpointer NULL 0 @c_postfix
end

/* Move the text from the temporary table to eloamazonfeed */

insert into eloamazonfeed (feedtext) select feedtext from elotemptext


/* Clear out the temporary table */

truncate table elotemptext

return 0




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

