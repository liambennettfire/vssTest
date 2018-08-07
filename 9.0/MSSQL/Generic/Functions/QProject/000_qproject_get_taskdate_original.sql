if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskdate_original') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_taskdate_original
GO

CREATE FUNCTION dbo.qproject_get_taskdate_original
(
  @i_projectkey as integer,
  @i_datetypecode as integer
) 
RETURNS datetime

/*******************************************************************************************************
**  Name: qproject_get_taskdate_original
**  Desc: This function returns the original date for a specific task.
**
**  Auth: Alan Katzen
**  Date: April 2, 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_date   datetime
    
  SELECT @v_count = COUNT(*)
    FROM taqprojecttask
   WHERE taqprojectkey = @i_projectkey 
     AND datetypecode = @i_datetypecode
  
  IF @v_count = 0
    RETURN NULL   
  
  SELECT @v_date = originaldate
    FROM taqprojecttask
   WHERE taqprojectkey = @i_projectkey 
     AND datetypecode = @i_datetypecode

  RETURN @v_date
  
END
GO

GRANT EXEC ON dbo.qproject_get_taskdate_original TO public
GO
