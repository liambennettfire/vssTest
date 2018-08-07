/****** Object:  UserDefinedFunction [dbo].[find_integer_in_comma_delim_list]    Script Date: 04/01/2009 10:31:31 ******/
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.find_integer_in_comma_delim_list') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.find_integer_in_comma_delim_list
GO

create FUNCTION [dbo].[find_integer_in_comma_delim_list]
    ( @i_code_list as varchar(100),  -- Accept a list of multiple codes concatenated with commas separating values 
		@i_code_to_find	as int) 
    
RETURNS char(1)

-- returns Y if code found in string, N if not found

BEGIN

declare 
	@v_key INT,
	@v_key_string varchar(20),
	@v_startpos INT,
	@v_endpos INT,
	@v_count INT
  
SET @v_startpos = 1     
SET @v_endpos = 0  
SET @v_key_string = ''   
IF datalength(@i_code_list) > 0 BEGIN
-- parse key list
	SET @v_endpos = charindex(',',@i_code_list)
	WHILE @v_endpos > 0 BEGIN
		SET @v_key_string = substring(@i_code_list, @v_startpos, @v_endpos - @v_startpos)
	  
		IF isnumeric(@v_key_string)=1 BEGIN
			if @v_key_string = @i_code_to_find BEGIN
				return 'Y';
			end
		END 
	  
		SET @v_startpos = @v_endpos + 1
		SET @v_endpos = charindex(',',@i_code_list, @v_startpos)    
	END

	-- there is one more key at end with no comma
	SET @v_key_string = substring(@i_code_list, @v_startpos, datalength(@i_code_list))

	IF isnumeric(@v_key_string)=1 BEGIN
		if @v_key_string = @i_code_to_find BEGIN
			return 'Y';
		end
	END  

	return 'N';

END



RETURN 'N';

END

GO

SET QUOTED_IDENTIFIER OFF 
GO

SET ANSI_NULLS ON 
GO

GRANT EXEC ON find_integer_in_comma_delim_list TO PUBLIC
GO