if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[convert_char_to_unicode_column]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[convert_char_to_unicode_column]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE   PROCEDURE dbo.convert_char_to_unicode_column
			     @i_html varchar(8000)output
				
AS

BEGIN 
DECLARE 
 @v_length int,
 @v_loop int,
 @v_char char(200),
 @v_char_converted char(20),
 @v_unicode varchar(20)

 set @v_length = LEN(@i_html)
 set @v_loop = 1
 WHILE @v_loop <= @v_length
 BEGIN
	set @v_char = SUBSTRING(@i_html,@v_loop,1)
	set @v_loop = @v_loop + 1 
	set @v_unicode = UNICODE(@v_char)
	if @v_unicode > 127 begin
	    set @v_char_converted = '&#' + @v_unicode + ';'
	    set @i_html = REPLACE ( @i_html , @v_char , @v_char_converted )
	    set @v_length = LEN(@i_html)
	end
 END	

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

