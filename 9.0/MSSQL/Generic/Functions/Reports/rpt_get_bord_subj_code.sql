
/****** Object:  UserDefinedFunction [dbo].[rpt_get_bord_subj_code]    Script Date: 03/24/2009 13:03:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_bord_subj_code') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_bord_subj_code
GO
CREATE FUNCTION [dbo].[rpt_get_bord_subj_code] 
            	(@i_bookkey 	INT,
            	@i_type	INT)
		

 
/*      The rpt_get_rpt_get_bordsubjcode function is used to retrieve the comment from the book comments table.  The @i_type is used to distinquish
	between the different comment formats to return.  The comment type code and comment subtype code are initialized in the function rather 
	then passed as parameters.  This was done becuase these codes are "mostly" consistent across implementations because Brief Description 
	is an eloquence enabled commenttype

        The parameters are for the book key and comment format type.  

	@i_type
		1 = Plain Text
		2 = HTML
		3 = HTML Lite


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_commenttypecode	INT
	DECLARE @i_commenttypesubcode	INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  INITIALIZE Comment Types		*/
	SELECT @i_commenttypecode = 1
	SELECT @i_commenttypesubcode = 45
 

/*  GET comment formats			*/
	IF @i_type = 1
		BEGIN
			SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 2
		BEGIN
			SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

	IF @i_type = 3
		BEGIN
			SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
  			FROM bookcomments
			WHERE bookkey = @i_bookkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
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
Grant All on dbo.rpt_get_bord_subj_code to Public
go