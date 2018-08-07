SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[elooutputformattedtext_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[elooutputformattedtext_sp]
GO




CREATE proc dbo.elooutputformattedtext_sp 
    @c_prefix varchar (255), 
    @c_postfix varchar (255),
    @i_format int



/*******************************************************/
/*	                                                 */
/*	    Author   : DSL                                    */
/*	    Creation Date   : 9/14/00                   */
/*	    Comments :Outputs well formed XML text with the specified  */
/** Prefix and Postfix. Text to be output must be in elotemptext **/
/*******************************************************/     


AS 

DECLARE @i_count int
DECLARE @i_textlength int
DECLARE @c_errormessage varchar (255)
DECLARE @c_feedstring varchar (8000)
DECLARE @c_tempstring varchar (8000)
DECLARE @tp_textpointer varbinary(16)

-- print 'Beginning of : elo_output_formatted_text_new_sp'

select @i_count=count (*) from elotemptext


if @i_count = 0  /* stop processing if no rows exist */
return 0

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
if @i_format = 1
begin
    -- print 'Formatting'
    select @c_tempstring = replace (substring (feedtext,1,7000), '&','&amp;') from elotemptext
    insert into elotempstring1 select replace (@c_tempstring, '<','&lt;')
    select @c_tempstring = replace (substring (feedtext,7001,7000), '&','&amp;') from elotemptext
    insert into elotempstring2 select replace (@c_tempstring, '<','&lt;')
    select @c_tempstring = replace (substring (feedtext,14001,7000), '&','&amp;') from elotemptext
    insert into elotempstring3 select replace (@c_tempstring, '<','&lt;')
    select @c_tempstring = replace (substring (feedtext,21001,7000), '&','&amp;') from elotemptext
    insert into elotempstring4 select replace (@c_tempstring, '<','&lt;')
    select @c_tempstring = replace (substring (feedtext,28001,7000), '&','&amp;') from elotemptext
    insert into elotempstring5 select replace (@c_tempstring, '<','&lt;')
    select @c_tempstring = replace (substring (feedtext,34001,7000), '&','&amp;') from elotemptext
    insert into elotempstring6 select replace (@c_tempstring, '<','&lt;')
    select @c_tempstring = replace (substring (feedtext,41001,7000), '&','&amp;') from elotemptext
    insert into elotempstring7 select replace (@c_tempstring, '<','&lt;')
    select @c_tempstring = replace (substring (feedtext,48001,7000), '&','&amp;') from elotemptext
    insert into elotempstring8 select replace (@c_tempstring, '<','&lt;')
end
else
begin
    -- print 'Not Formatting'
    insert into elotempstring1 select substring (feedtext,1,7000)     from elotemptext
    insert into elotempstring2 select substring (feedtext,7001,7000)  from elotemptext
    insert into elotempstring3 select substring (feedtext,14001,7000) from elotemptext
    insert into elotempstring4 select substring (feedtext,21001,7000) from elotemptext
    insert into elotempstring5 select substring (feedtext,28001,7000) from elotemptext
    insert into elotempstring6 select substring (feedtext,34001,7000) from elotemptext
    insert into elotempstring7 select substring (feedtext,41001,7000) from elotemptext
    insert into elotempstring8 select substring (feedtext,48001,7000) from elotemptext
end
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

truncate table elotemptext

return 0


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

