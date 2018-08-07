set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE FUNCTION [dbo].[get_Title] (
		@i_bookkey	INT,
		@v_part		VARCHAR(1))
	
/*	PARAMETER @v_part
		F = Full Title = Title Prefix + Title
		S = Title Search = Title + ' , ' + Title Prefix
		T = Title
		P = Title Prefix
		U = Title Upper
*/
	RETURNS VARCHAR(255)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_title		VARCHAR(255)
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
			SELECT @RETURN = titleupper
			FROM book
			WHERE bookkey = @i_bookkey
		END


	IF @v_part NOT IN('F','S','T','P','U')
		BEGIN
			SELECT @RETURN = '-1'
		END

  RETURN @RETURN
END


