if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_misc_related_title_info') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.get_misc_related_title_info
GO

CREATE FUNCTION dbo.get_misc_related_title_info
(
  @i_projectkey as integer,
  @i_misckey as integer
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: get_misc_related_title_info
**  Desc: This function returns the miscellaneous calculated value for specific related title misc values.
**        'Related Title Pub Date' and 'Related Title Author'
**
**  Auth: Colman
**  Date: 9/27/2016
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count         INT,
    @v_return_value  VARCHAR(1000),
    @v_misc_name     VARCHAR(40),
    @v_bookkey       INT,
    @v_author_name   VARCHAR(1000),
    @o_error_code    INT,
    @o_error_desc    VARCHAR(2000)
    
  SET @v_return_value = NULL
  SET @o_error_code = 0
  
  /* First check if this misc results column is actually configured - i.e. mapped to a misc item */
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey and activeind = 1
  
  IF @v_count = 0
    RETURN NULL   /* this column is not configured */
    
  SELECT @v_misc_name = miscname
  FROM bookmiscitems 
  WHERE misckey = @i_misckey and activeind = 1

	SELECT @v_count = count(*)
    FROM taqprojecttitle
   WHERE taqprojectkey = @i_projectkey 
  
  IF @v_count > 1
  BEGIN
    IF @v_misc_name = 'Related Title Author'
      SET @v_return_value = 'Multiple Titles'
  END
  ELSE IF @v_count = 1
  BEGIN
    IF @v_misc_name = 'Related Title Pub Date'
      SELECT @v_return_value = bestpubdate 
      FROM coretitleinfo 
      WHERE bookkey = (SELECT bookkey FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey) AND printingkey = 1
    ELSE IF @v_misc_name = 'Related Title Author'
      SELECT @v_return_value = authorname 
      FROM coretitleinfo 
      WHERE bookkey = (SELECT bookkey FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey) AND printingkey = 1
  END

  RETURN @v_return_value
  
END
GO

GRANT EXEC ON dbo.get_misc_related_title_info TO public
GO
