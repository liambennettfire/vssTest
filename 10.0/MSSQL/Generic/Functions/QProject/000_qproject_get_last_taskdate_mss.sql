IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_last_taskdate') )
DROP FUNCTION dbo.qproject_get_last_taskdate
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION [dbo].[qproject_get_last_taskdate]
(
  @i_projectkey as integer,
  @i_datetypecode as integer
) 
RETURNS datetime


/*******************************************************************************************************
**  Name: [qproject_get_last_taskdate]
**  Desc: This function returns the date for a specific task.
**
**  Auth: Jon Hess
**  Date: July 7, 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_date   datetime
    
  SET @v_date = null
  
  IF ISNULL(@i_projectkey, 0) > 0 AND ISNULL(@i_datetypecode, 0) > 0 BEGIN
    -- SELECT @v_count = COUNT(*)
      -- FROM taqprojecttask
     -- WHERE taqprojectkey = @i_projectkey 
       -- AND datetypecode = @i_datetypecode
    
    -- IF @v_count = 0
      -- RETURN NULL   
    
    SELECT @v_date = MAX( activedate )
		  FROM taqprojecttask
	  WHERE (taqprojectkey = @i_projectkey) AND (datetypecode = @i_datetypecode)
  END
  
  RETURN @v_date
  
END
GO

GRANT EXEC ON dbo.qproject_get_last_taskdate TO public
GO