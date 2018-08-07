if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_misc_value_check') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_misc_value_check
GO

CREATE FUNCTION dbo.rpt_get_misc_value_check
(
  @i_bookkey as integer,
  @v_misckey as integer,
  @return_type as varchar(10)
) 
RETURNS VARCHAR(10)

/******************************************************************************
**  Name: rpt_get_misc_value_gentable_text
**  Desc: This function returns the text value from bookmisc table
for the bookkey and misckey passed. 

@return_type,


pass '1' or '0' if you want the return value to be formatted as  '1' or '0'
pass 'Y' or 'N' if you want the return value to be formatted as 'Y' or 'N'
pass 'Yes' or 'No' if you want the return value to be formatted as 'Yes' or 'No'
pass 'x' if you want the return value to be 'x' (true) and ' ' (false)

**
**  Auth: Tolga Tuncer
**  Date: 17 February 2012
*******************************************************************************/



BEGIN
 
DECLARE @Return varchar(55)
SET @Return = ''


If @return_type = '1' or @return_type = '0' 
		BEGIN
			Select @Return = CASE WHEN longvalue = 1 THEN '1' ELSE '0' END
			from bookmisc bm 
			where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey 
			
			IF @Return IS NULL OR @Return = '' 
				SET @Return = '0'
		END
	else If @return_type = 'Y' or @return_type = 'N' 
		begin
			Select @Return = CASE WHEN longvalue = 1 THEN 'Y' ELSE 'N' END
			from bookmisc bm 
			where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey 
			
			IF @Return IS NULL OR @Return = '' 
				SET @Return = 'N'
		end
	else If @return_type = 'Yes' or @return_type = 'No' 
		begin
			Select @Return = CASE WHEN longvalue = 1 THEN 'Yes' ELSE 'No' END
			from bookmisc bm 
			where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey 
			
			IF @Return IS NULL OR @Return = ''  
				SET @Return = 'No'
		end
	else If @return_type = 'X' or @return_type = ' ' 
		begin
			Select @Return = CASE WHEN longvalue = 1 THEN 'X' ELSE ' ' END
			from bookmisc bm 
			where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey 
			
			IF @Return IS NULL OR @Return = ''  
				SET @Return = ' '
		end          
	    
	
--If @Return is NULL 
--	SET @Return = ''
  
RETURN @Return
  
END
GO
GRANT EXEC ON dbo.rpt_get_misc_value_check TO PUBLIC
GO