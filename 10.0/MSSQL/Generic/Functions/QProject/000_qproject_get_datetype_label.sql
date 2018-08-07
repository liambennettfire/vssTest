IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_dateype_label') )
DROP FUNCTION dbo.qproject_get_dateype_label
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE FUNCTION dbo.qproject_get_dateype_label 
	(
		@v_datetypecode as integer
	)
RETURNS varchar(100)

/*******************************************************************************************************
**  Name: [qproject_get_dateype_label]
**  Desc: This function returns the varchar for the datetypecode passed from the datetype table
**
**  Auth: Jon Hess
**  Date: July 7, 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_dateLabel   varchar(100)
    
  SELECT @v_count = count (*)
    FROM datetype
   WHERE datetypecode = @v_datetypecode
  
  IF @v_count = 0
    RETURN NULL   

  SELECT @v_dateLabel = COALESCE(datelabel,description)
    FROM datetype
   WHERE datetypecode = @v_datetypecode
    
 RETURN @v_dateLabel
  
END