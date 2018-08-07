SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloonixformattext_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloonixformattext_sp]
GO



CREATE proc dbo.eloonixformattext_sp @i_bookkey int, 
@c_texttypecode varchar (10),
@c_elofieldtag varchar (100)



/*******************************************************/
/*	                                                 */
/*	    Author   : DSL                                    */
/*	    Creation Date   : 9/14/00                   */
/*	    Comments :Reformats the text in elotemptext to   */
/** create a well formed text field for xml **/
/*******************************************************/     


AS 
DECLARE @i_commenttypecode int
DECLARE @i_commenttypesubcode int
DECLARE @i_countplain int
DECLARE @i_counthtml int
DECLARE @i_textlength int
DECLARE @c_errormessage varchar (255)
DECLARE @c_feedstring varchar (8000)
DECLARE @tp_textpointer varbinary(16)



/*truncate the temporary string tables */

truncate table elotempstring1
truncate table elotempstring2
truncate table elotempstring3
truncate table elotempstring4
truncate table elotempstring5
truncate table elotempstring6
truncate table elotempstring7
truncate table elotempstring8



/** Break up the text field in order to replace the < symbol **/

insert into elotempstring1 select replace (substring (feedtext,1,7000), '<','&lt;') from elotemptext
insert into elotempstring2 select replace (substring (feedtext,7001,7000), '<','&lt;') from elotemptext
insert into elotempstring3 select replace (substring (feedtext,14001,7000), '<','&lt;') from elotemptext
insert into elotempstring4 select replace (substring (feedtext,21001,7000), '<','&lt;') from elotemptext
insert into elotempstring5 select replace (substring (feedtext,28001,7000), '<','&lt;') from elotemptext
insert into elotempstring6 select replace (substring (feedtext,34001,7000), '<','&lt;') from elotemptext
insert into elotempstring7 select replace (substring (feedtext,41001,7000), '<','&lt;') from elotemptext
insert into elotempstring8 select replace (substring (feedtext,48001,7000), '<','&lt;') from elotemptext

truncate table elotemptext /** Clear the table to rebuild it **/

select @i_textlength = 0
select @i_textlength = len (feedstring) from elotempstring1
if @i_textlength > 0
begin
	insert into elotemptext (tempkey,feedtext) 
	select 1,feedstring
	from elotempstring1 
end

select @i_textlength = 0
select @i_textlength = len (feedstring) from elotempstring2
if @i_textlength > 0
begin
	select @c_feedstring = feedstring from elotempstring2
	select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1
	/* Append string to end of text field */
	updatetext elotemptext.feedtext @tp_textpointer NULL 0 @c_feedstring
end

select @i_textlength = 0
select @i_textlength = len (feedstring) from elotempstring3
if @i_textlength > 0
begin
	select @c_feedstring = feedstring from elotempstring3
	select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1
	/* Append string to end of text field */
	updatetext elotemptext.feedtext @tp_textpointer NULL 0 @c_feedstring
end

select @i_textlength = 0
select @i_textlength = len (feedstring) from elotempstring4
if @i_textlength > 0
begin
	select @c_feedstring = feedstring from elotempstring4
	select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1
	/* Append string to end of text field */
	updatetext elotemptext.feedtext @tp_textpointer NULL 0 @c_feedstring
end

select @i_textlength = 0
select @i_textlength = len (feedstring) from elotempstring5
if @i_textlength > 0
begin
	select @c_feedstring = feedstring from elotempstring5
	select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1
	/* Append string to end of text field */
	updatetext elotemptext.feedtext @tp_textpointer NULL 0 @c_feedstring
end


select @i_textlength = 0
select @i_textlength = len (feedstring) from elotempstring6
if @i_textlength > 0
begin
	select @c_feedstring = feedstring from elotempstring6
	select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1
	/* Append string to end of text field */
	updatetext elotemptext.feedtext @tp_textpointer NULL 0 @c_feedstring
end

select @i_textlength = 0
select @i_textlength = len (feedstring) from elotempstring7
if @i_textlength > 0
begin
	select @c_feedstring = feedstring from elotempstring7
	select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1
	/* Append string to end of text field */
	updatetext elotemptext.feedtext @tp_textpointer NULL 0 @c_feedstring
end

select @i_textlength = 0
select @i_textlength = len (feedstring) from elotempstring8
if @i_textlength > 0
begin
	select @c_feedstring = feedstring from elotempstring8
	select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1
	/* Append string to end of text field */
	updatetext elotemptext.feedtext @tp_textpointer NULL 0 @c_feedstring
end

select @i_textlength = 0
select @i_textlength = len (feedstring) from elotempstring9
if @i_textlength > 0
begin
	select @c_feedstring = feedstring from elotempstring9
	select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1
	/* Append string to end of text field */
	updatetext elotemptext.feedtext @tp_textpointer NULL 0 @c_feedstring
end


select @i_textlength = 0
select @i_textlength = len (feedstring) from elotempstring10
if @i_textlength > 0
begin
	select @c_feedstring = feedstring from elotempstring10
	select @tp_textpointer = textptr (feedtext) from elotemptext where tempkey=1
	/* Append string to end of text field */
	updatetext elotemptext.feedtext @tp_textpointer NULL 0 @c_feedstring
end


return 0

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

