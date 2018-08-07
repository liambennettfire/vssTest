if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_misc_keywords_value') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_misc_keywords_value
GO

CREATE FUNCTION dbo.qtitle_get_misc_keywords_value
(
  @i_bookkey as integer
) 
RETURNS VARCHAR(4000)

/*******************************************************************************************************
**  Name: qtitle_get_misc_keywords_value
**  Desc: This function returns the misc keywords value.
**
**  Auth: Alan Katzen
**  Date: January 18 2017
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_misckey INT, 
    @v_misctext Varchar(4000),
    @v_elofieldid INT
    
  IF COALESCE(@i_bookkey, 0) = 0 BEGIN
	  RETURN '' 
  END    
  
	SET @v_misctext = NULL

	SELECT @v_elofieldid = datacode
	  FROM gentables
	 WHERE tableid = 560
	   AND eloquencefieldtag = 'DPIDXBIZKEYWORDS'

	SELECT @v_misckey = misckey
	  FROM bookmiscitems
	 WHERE eloquencefieldidcode = @v_elofieldid

	IF EXISTS(SELECT 1 FROM bookmisc WHERE bookkey = @i_bookkey AND misckey = @v_misckey) BEGIN
		SELECT @v_misctext = textvalue
		  FROM bookmisc
		 WHERE bookkey = @i_bookkey
		   AND misckey = @v_misckey
  END
  
  return coalesce(@v_misctext, '')
END
GO

GRANT EXEC ON dbo.qtitle_get_misc_keywords_value TO public
GO
