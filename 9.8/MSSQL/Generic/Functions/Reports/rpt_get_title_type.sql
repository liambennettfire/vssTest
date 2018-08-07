
/****** Object:  UserDefinedFunction [dbo].[rpt_get_title_type]    Script Date: 03/24/2009 13:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_title_type') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_title_type
GO
CREATE FUNCTION [dbo].[rpt_get_title_type]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))
RETURNS VARCHAR(255)
/*	The purpose of the rpt_get_book_type function is to return a specific description column from gentables for  Title Type

	Parameter Options -
		@v_column
			D = Data Description
			E = External code
			S = Short Description
			B = BISAC Data Code
			T = Eloquence Field Tag
			1 = Alternative Description 1
			2 = Alternative Deccription 2
*/	
AS
BEGIN
	DECLARE @RETURN				VARCHAR(255)
	DECLARE @v_desc				VARCHAR(255)
	DECLARE @i_datacode		INT
	
	SELECT @i_datacode = titletypecode 
	FROM	coretitleinfo (nolock) 				
	WHERE	bookkey = @i_bookkey 
	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	gentables (nolock)  
			WHERE  tableid = 132
					AND datacode = @i_datacode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(externalcode))
			FROM	gentables (nolock)  
			WHERE  tableid = 132
					AND datacode = @i_datacode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadescshort))
			FROM	gentables (nolock)  
			WHERE  tableid = 132
					AND datacode = @i_datacode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(bisacdatacode))
			FROM	gentables (nolock)  
			WHERE  tableid = 132
					AND datacode = @i_datacode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc1))
			FROM	gentables (nolock)  
			WHERE  tableid = 132
					AND datacode = @i_datacode
		
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	gentables (nolock)  
			WHERE  tableid = 132
					AND datacode = @i_datacode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
RETURN @RETURN
END

go
Grant All on dbo.rpt_get_title_type to Public
go