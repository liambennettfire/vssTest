if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_misc_type_by_misckey') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_misc_type_by_misckey
GO

CREATE FUNCTION dbo.qtitle_get_misc_type_by_misckey
(
  @i_bookkey as integer,
  @i_misckey as integer
) 
RETURNS VARCHAR(255)

/******************************************************************************
**  Name: qtitle_get_misc_type_by_misckey
**  Desc: This function returns the miscellaneous item type based on
**        Misc Item Admin Setup
**
**  Auth: Dustin Miller
**  Date: March 22 2017
*******************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_datacode INT,
    @v_error  INT,
    @v_fieldformat  VARCHAR(40),
    @v_floatvalue FLOAT,
    @v_formatted_value  VARCHAR(255),
    @v_longvalue  INT,
    @v_misctype INT,
    @v_misc_name  VARCHAR(40),
    @v_misc_value VARCHAR(255),
    @v_rowcount INT,
    @v_textvalue  VARCHAR(255)
    
  /* First check if this misc results column is actually configured - i.e. mapped to a misc item */
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey
  
  IF @v_count = 0
    RETURN NULL   /* this column is not configured - return NULL */
  
  SELECT @v_misctype = misctype
  FROM bookmiscitems 
  WHERE misckey = @i_misckey

  RETURN @v_misctype
  
END
GO

GRANT EXEC ON dbo.qtitle_get_misc_type_by_misckey TO public
GO
