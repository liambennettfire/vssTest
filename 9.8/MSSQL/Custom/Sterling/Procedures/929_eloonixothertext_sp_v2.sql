if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloonixothertext_sp_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloonixothertext_sp_v2]
GO

CREATE proc dbo.eloonixothertext_sp_v2 @i_bookkey int, 
@c_texttypecode varchar (10),
@c_elofieldtag varchar (100),
@i_websitekey int



/*******************************************************/
/*	                                                 */
/*	    Author   : PBM                                    */
/*	    Creation Date   : 5/9/06                   */
/*	    Comments :Outputs ONIX Other Text Repeating group  */
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

if @i_count = 0 /* stop processing if no rows exist */
return 0

/** Test the Text Pointer - if invalid (zero) then exit **/
select @i_pointervalid=0

select @i_pointervalid = TEXTVALID ('bookcomments_ext.commentbody', TEXTPTR(commentbody))
from bookcomments_ext 
where bookkey=@i_bookkey and printingkey=1 and commenttypecode=@i_commenttypecode and
commenttypesubcode=@i_commenttypesubcode
and commentstyle = 1

if @i_pointervalid=0 or @i_pointervalid is null

begin
print 'here'
	select @c_errormessage='Text Ptr Invalid for  Bookkey ' + 
	convert (varchar (10), @i_bookkey) + 
	' Commenttypecode ' + 	convert (varchar (10), @i_commenttypecode) +
	' Commenttypesubcode ' + 	convert (varchar (10), @i_commenttypesubcode)
	print @c_errormessage
	return 0
end

/*truncate the temporary text table */

truncate table elotemptext

insert into eloonixfeed (feedtext) values ('<othertext>')
insert into eloonixfeed (feedtext) 
values ('<d102>' + @c_texttypecode +'</d102>')



insert into elotemptext (tempkey,feedtext) 
select 1,commentbody
from bookcomments_ext 
where bookkey=@i_bookkey and printingkey=1 and commenttypecode=@i_commenttypecode and
commenttypesubcode=@i_commenttypesubcode
and commentstyle = 1

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

if @i_pointervalid=0 or @i_pointervalid is null
begin
	select @c_errormessage='Text Ptr Invalid for  temp text in output comment Bookkey ' + 
	convert (varchar (10), @i_bookkey) + 
	' Commenttypecode ' + 	convert (varchar (10), @i_commenttypecode) +
	' Commenttypesubcode ' + 	convert (varchar (10), @i_commenttypesubcode)
	print @c_errormessage
	return 0
end


select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1

/* Insert prefix in front of text d104 Text */

updatetext elotemptext.feedtext @tp_textpointer 0 0 '<d104><![CDATA['

/* Append postfix to end of text */
 
updatetext elotemptext.feedtext @tp_textpointer NULL 0 ']]></d104>'

/* Move the text from the temporary table to eloonixfeed */

insert into eloonixfeed (feedtext) select feedtext from elotemptext

insert into eloonixfeed (feedtext) 
values ('</othertext>')

/* Clear out the temporary table */

truncate table elotemptext

return 0
GO



