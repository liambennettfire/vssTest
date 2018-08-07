if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_misc_value_float') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_misc_value_float
GO


CREATE FUNCTION dbo.rpt_get_misc_value_float
(
  @i_bookkey as integer,
  @v_misckey as integer
) 
RETURNS float

/******************************************************************************
**  Name: rpt_get_misc_value_float
**  Desc: This function returns the floatvalue from bookmisc table
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
 
DECLARE @Return float
SET @Return = NULL 

Select @Return = floatvalue   
from bookmisc bm 
where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey 


RETURN @Return
  
END
GO
GRANT EXEC ON dbo.rpt_get_misc_value_float TO PUBLIC
GO