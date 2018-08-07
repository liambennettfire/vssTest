
/****** Object:  UserDefinedFunction [dbo].[rpt_get_book_comment]    Script Date: 03/24/2009 13:02:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_book_comment') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_book_comment
GO
CREATE FUNCTION [dbo].[rpt_get_book_comment] 
            	(@i_bookkey 	INT,
	@v_commenttypecode	INT, 
	@v_commenttypesubcode	INT, 
            	@v_type	INT)
		
 
/*	Darci   08222006
	The rpt_get_book_comment function is used to retrieve the comment from the book comments table.  The @v_type is used to distinquish
	between the different comment formats to return.  
        The parameters are for the book key, comment type code, comment type subcode, and comment format type.  
	@v_commenttypecode & @v_commenttypesubcode - tableid 284 on gentables and subgentables
		@v_commenttypecode
			1 - Marketing
			3 - Editorial
			4 - Title
			5 - Publicity
			6 - Project
		@v_commenttypesubcode - main ones
			1 - 4 - Book Summary
			1 - 28 - Series Summary
			3 - 7 - Brief Description
			3 - 10 - Author Bio
			3 - 45 - Series Description
			3 - 49 - CIP Summary
			4 - 1 - Editorial Notes
			4 - 2 - Production Notes
			4 - 8 - Comments
			4 - 13 - Word Count
			4 - 23 - Development House
			4 - 39 - Archive Code 
	@v_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite
*/
RETURNS VARCHAR(8000)
AS  
BEGIN 
	
	DECLARE @v_text		VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)
 
/*  GET comment formats			*/
	IF @v_type = 1
		BEGIN
			SELECT @v_text = LTRIM(RTRIM(REPLACE(CAST(commenttext AS VARCHAR(8000)), char(13) + char(10), ' ')))
  			FROM bookcomments (nolock)
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @v_commenttypecode
				AND commenttypesubcode = @v_commenttypesubcode
		END
	IF @v_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments (nolock)
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @v_commenttypecode
				AND commenttypesubcode = @v_commenttypesubcode
		END
	IF @v_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments (nolock)
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @v_commenttypecode
				AND commenttypesubcode = @v_commenttypesubcode
		END
	IF @v_text is NOT NULL
		BEGIN
			SELECT @RETURN = LTRIM(RTRIM(@v_text))
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''	
		END
RETURN @RETURN
END
go
Grant All on dbo.rpt_get_book_comment to Public
go