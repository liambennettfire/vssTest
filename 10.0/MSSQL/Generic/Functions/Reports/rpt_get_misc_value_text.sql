if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_misc_value_text') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_misc_value_text
GO

CREATE FUNCTION dbo.rpt_get_misc_value_text
(
  @i_bookkey as integer,
  @v_misckey as integer
) 
RETURNS VARCHAR(4000)

/******************************************************************************
**  Name: rpt_get_misc_value_gentable_text
**  Desc: This function returns the text value from bookmisc table
for the bookkey and misckey passed. 


**
**  Auth: Tolga Tuncer
**  Date: 17 February 2012
*******************************************************************************/



BEGIN
 
DECLARE @Return VARCHAR(4000)
SET @Return = NULL 

Select @Return = bm.textvalue  
from bookmisc bm 
where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey 

	
--If @Return is NULL 
--	SET @Return = ''
  
RETURN @Return
  
END
GO
GRANT EXEC ON dbo.rpt_get_misc_value_text TO PUBLIC
GO