if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[elooutputcomment_sp_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[elooutputcomment_sp_v2]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE proc dbo.elooutputcomment_sp_v2
@i_bookkey int, 
@c_elofieldtag varchar (100),
@c_prefix varchar (100),
@c_postfix varchar (255),
@i_websitekey int

/*******************************************************/
/*	                                                 */
/*	    Author   : PBM                                    */
/*	    Creation Date   : 5/9/06                   */
/*	    Comments :Outputs the plain text comment  */
/*	              for the given bookkey and eloquence field tag */
/*******************************************************/

AS 
DECLARE @i_commenttypecode int
DECLARE @i_commenttypesubcode int
DECLARE @i_releaseyesno int
DECLARE @i_count int
DECLARE @i_count1 int
DECLARE @i_count2 int
DECLARE @i_count3 int
DECLARE @c_errormessage varchar (255)
DECLARE @tp_textpointer varbinary(16)
DECLARE @i_pointervalid int
DECLARE @releasetoeloquence int
DECLARE @i_commentstyle int

set  @i_commentstyle = 1

/* 5/20/02 add altcommenttypecode 1 and 2 but do not implement releasetoeloquenceind */

select @i_count1=count (*) 
		from websitecommenttype w, bookcomments b
			where b.commenttypecode=w.commenttypecode
				and b.commenttypesubcode=w.commenttypesubcode
				and bookkey=@i_bookkey 
				and websitekey= @i_websitekey 
				and eloquencefieldtag=@c_elofieldtag

select @i_count2=count (*) 
		from websitecommenttype w, bookcomments b
			where b.commenttypecode=w.alt1commenttypecode
				and b.commenttypesubcode=w.alt1commenttypesubcode
				and bookkey=@i_bookkey 
				and websitekey= @i_websitekey 
				and eloquencefieldtag=@c_elofieldtag

select @i_count3=count (*) 
		from websitecommenttype w, bookcomments b
			where b.commenttypecode=w.alt2commenttypecode
				and b.commenttypesubcode=w.alt2commenttypesubcode
				and bookkey=@i_bookkey 
				and websitekey= @i_websitekey 
				and eloquencefieldtag=@c_elofieldtag


if @i_count1 > 0 
  begin
		select @i_commenttypecode = w.commenttypecode,
			@i_commenttypesubcode = w.commenttypesubcode,
			@i_releaseyesno = ignorereleasetoeloquenceind 
				from websitecommenttype w, bookcomments b
					where b.commenttypecode=w.commenttypecode
						and b.commenttypesubcode=w.commenttypesubcode
						and bookkey=@i_bookkey 
						and websitekey= @i_websitekey 
						and eloquencefieldtag=@c_elofieldtag
  end 


if @i_count2 > 0 and @i_count1 = 0 
  begin
		select @i_commenttypecode = w.alt1commenttypecode,
			  @i_commenttypesubcode =w.alt1commenttypesubcode,
			  @i_releaseyesno = ignorereleasetoeloquenceind 
				from websitecommenttype w, bookcomments b
					where b.commenttypecode=w.alt1commenttypecode
						and b.commenttypesubcode=w.alt1commenttypesubcode
						and bookkey=@i_bookkey 			
						and websitekey= @i_websitekey 
						and eloquencefieldtag=@c_elofieldtag
  end


if @i_count3 > 0 and @i_count2 = 0 and @i_count1 = 0 
  begin
	select @i_commenttypecode=w.alt2commenttypecode,
		@i_commenttypesubcode=w.alt2commenttypesubcode,
		@i_releaseyesno =ignorereleasetoeloquenceind 
			from websitecommenttype w, bookcomments b
				where b.commenttypecode=w.alt2commenttypecode
					and b.commenttypesubcode=w.alt2commenttypesubcode
					and bookkey=@i_bookkey 			
					and websitekey= @i_websitekey 
					and eloquencefieldtag=@c_elofieldtag
  end



/* 5/20/02 original select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag=@c_elofieldtag
*/

if @i_commenttypecode=0
begin
/*select @c_errormessage='Eloquence Field Tag ' + @c_elofieldtag + '
not found for comment in subgentables' */
/*exec eloprocesserror_sp @i_bookkey,@@error,'WARNING',@c_errormessage*/
return 0
end

select @i_count=count (*) from bookcomments 
where bookkey=@i_bookkey and printingkey=1 and commenttypecode=@i_commenttypecode and
commenttypesubcode=@i_commenttypesubcode

if @i_count = 0  /* stop processing if no rows exist */
return 0


/** Test the Text Pointer - if invalid (zero) then exit **/
select @i_pointervalid=0
/** PM CRM 3881 5/9/06	Change to HTML Lite For All Descriptive Copy **/
select @i_pointervalid = TEXTVALID ('bookcomments_ext.commentbody', TEXTPTR(commentbody))
from bookcomments_ext 
where bookkey=@i_bookkey 
and printingkey=1 
and commenttypecode=@i_commenttypecode 
and commenttypesubcode=@i_commenttypesubcode
and commentstyle = @i_commentstyle

select @c_errormessage='Pointer Valid Indicator Location 1 = ' + 
convert (varchar (10), @i_pointervalid) 
/*print @c_errormessage*/

if @i_pointervalid=0 or @i_pointervalid is null
begin
	select @c_errormessage='Text Ptr Invalid in BookComment_ext table for  Bookkey' + 
	convert (varchar (10), @i_bookkey) + 
	' Commenttypecode ' + 	convert (varchar (10), @i_commenttypecode) +
	' Commenttypesubcode ' + 	convert (varchar (10), @i_commenttypesubcode)
	print @c_errormessage
	return 0
end

/*truncate the temporary text table */

delete from elotemptext

/* Copy the comment into the temporary table. The temporary table allows us */
/* to use a key so that we can obtain a correct textptr. eloonixfeed has no key */

insert into elotemptext (tempkey,feedtext) 
select 1,commentbody
from bookcomments_ext 
where bookkey=@i_bookkey 
and printingkey=1 
and commenttypecode=@i_commenttypecode 
and commenttypesubcode=@i_commenttypesubcode
and commentstyle = @i_commentstyle

select @releasetoeloquence = releasetoeloquenceind
	from bookcomments 
		where bookkey=@i_bookkey 
			and printingkey=1
			and commenttypecode = @i_commenttypecode
			and commenttypesubcode = @i_commenttypesubcode

if @releasetoeloquence is null 
  begin 
	select @releasetoeloquence = 0
  end 

/** Test the Text Pointer - if invalid (zero) then exit **/
select @i_pointervalid=0

select @i_pointervalid = TEXTVALID ('elotemptext.feedtext', TEXTPTR(feedtext))
from elotemptext where tempkey=1

select @c_errormessage='Pointer Valid Indicator Location 2 = ' + 
convert (varchar (10), @i_pointervalid) 
/*print @c_errormessage*/

if @i_pointervalid=0 or @i_pointervalid is null
begin
	select @c_errormessage='Text Ptr Invalid for  TempText in output comment Bookkey' + 
	convert (varchar (10), @i_bookkey) + 
	' Commenttypecode ' + 	convert (varchar (10), @i_commenttypecode) +
	' Commenttypesubcode ' + 	convert (varchar (10), @i_commenttypesubcode)
	print @c_errormessage
	return 0
end

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

/* Move the text from the temporary table to eloonixfeed */


insert into eloonixfeed (feedtext) select feedtext from elotemptext


/* Clear out the temporary table */

delete from elotemptext

return 0
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


