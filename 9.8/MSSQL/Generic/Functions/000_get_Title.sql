
/****** Object:  UserDefinedFunction [dbo].[get_Title]    Script Date: 03/24/2009 13:18:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_Title') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.get_Title
GO
CREATE FUNCTION [dbo].[get_Title] (
		@i_bookkey	INT,
		@v_part		VARCHAR(1))
	
/*	get_Title returns various forms of the Title field depending on the parameter below

PARAMETER @v_part
		F = Full Title = Title Prefix + Title
		S = Title Search = Title + ' , ' + Title Prefix
		T = Title
		P = Title Prefix
		U = Title Upper
		C = Concatenated with SubTitle --- added by fpt 7/11/05
*/
	RETURNS VARCHAR(255)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_title		VARCHAR(255)
	DECLARE @v_subtitle		VARCHAR(255)
	DECLARE @v_title_prefix		VARCHAR(3)

	IF @v_part = 'F'
		BEGIN
			SELECT @v_title_prefix = ltrim(rtrim(titleprefix))
			FROM bookdetail
			WHERE bookkey = @i_bookkey

			IF @v_title_prefix <> ''
				BEGIN
					SELECT @RETURN = @v_title_prefix +' '+ ltrim(rtrim(b.title))
					FROM book b LEFT OUTER JOIN bookdetail bd ON b.bookkey = bd.bookkey
					WHERE b.bookkey = @i_bookkey
				END
			ELSE
				BEGIN
					SELECT @RETURN = ltrim(rtrim(b.title))
					FROM book b 
					WHERE b.bookkey = @i_bookkey
				END
					

		END
	
	IF @v_part = 'S'
		BEGIN

			SELECT @v_title_prefix = ltrim(rtrim(titleprefix))
			FROM bookdetail
			WHERE bookkey = @i_bookkey

			IF @v_title_prefix <> ''
				BEGIN
					SELECT @RETURN = ltrim(rtrim(b.title))+', '+ ltrim(rtrim(bd.titleprefix))
					FROM book b LEFT OUTER JOIN bookdetail bd ON b.bookkey = bd.bookkey
					WHERE b.bookkey = @i_bookkey
				END


			ELSE
				BEGIN
					SELECT @RETURN = ltrim(rtrim(b.title))
					FROM book b 
					WHERE b.bookkey = @i_bookkey
				END
		END

	IF @v_part = 'T'
		BEGIN
			SELECT @RETURN = title
			FROM book
			WHERE bookkey = @i_bookkey
		END


	IF @v_part = 'P'
		BEGIN
			SELECT @RETURN = titleprefix
			FROM bookdetail
			WHERE bookkey = @i_bookkey
		END

	IF @v_part = 'U'
		BEGIN
			SELECT @RETURN = UPPER(title)
			FROM book
			WHERE bookkey = @i_bookkey
		END

	IF @v_part = 'C'
		BEGIN
			SELECT @v_title_prefix = ltrim(rtrim(titleprefix))
			FROM bookdetail
			WHERE bookkey = @i_bookkey

			IF @v_title_prefix <> ''
				BEGIN
					SELECT @RETURN = @v_title_prefix +' '+ ltrim(rtrim(b.title))
					FROM book b LEFT OUTER JOIN bookdetail bd ON b.bookkey = bd.bookkey
					WHERE b.bookkey = @i_bookkey
				END
			ELSE
				BEGIN
					SELECT @RETURN = ltrim(rtrim(b.title))
					FROM book b 
					WHERE b.bookkey = @i_bookkey
				END
				
			SELECT @v_subtitle = dbo.rpt_get_sub_title(@i_bookkey)	
			IF @v_subtitle <> ''
				BEGIN
					SELECT @RETURN = @RETURN + ': ' + @v_subtitle
				END
			

		END


	IF @v_part NOT IN('F','S','T','P','U','C')
		BEGIN
			SELECT @RETURN = '-1'
		END

  RETURN @RETURN
END
go
Grant Exec on dbo.get_Title to Public
go