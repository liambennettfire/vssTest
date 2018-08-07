SET QUOTED_IDENTIFIER ON 
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'convert_char_to_unicode')
	BEGIN
		PRINT 'Dropping Procedure convert_char_to_unicode'
		DROP  Procedure  convert_char_to_unicode
	END

GO

PRINT 'Creating Procedure convert_char_to_unicode'
GO



CREATE     PROCEDURE dbo.convert_char_to_unicode
			     @i_html varchar(8000)
				

AS

BEGIN 
DECLARE 
@v_length int,
@v_loop int,
@v_cnt int,
@v_char char(200),
@v_char_converted char(20),
@v_unicode varchar(20)
	


select @v_cnt = count(*)
from temp_blob
where  keyid = 1

if @v_cnt > 0 begin
	update temp_blob
	set htmldata = ''
	where keyid = 1
end else begin
	insert into temp_blob
	values(1, '')
end 


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

	update temp_blob
	set htmldata = @i_html
	where keyid = 1


 END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.convert_char_to_unicode TO PUBLIC
go




