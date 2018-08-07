if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_misc_value_numeric') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_misc_value_numeric
GO


CREATE FUNCTION dbo.rpt_get_misc_value_numeric
(
  @i_bookkey as integer,
  @v_misckey as integer
) 
RETURNS int

/******************************************************************************
**  Name: rpt_get_misc_value_numeric
**  Desc: This function returns the longvalue from bookmisc table
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
 
DECLARE @Return int
SET @Return = NULL 

Select @Return = longvalue  
from bookmisc bm 
where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey 


RETURN @Return
  
END
GO
GRANT EXEC ON dbo.rpt_get_misc_value_numeric TO PUBLIC
GO