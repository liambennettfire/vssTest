if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskdate') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_taskdate
GO

CREATE FUNCTION dbo.qproject_get_taskdate
(
  @i_projectkey as integer,
  @i_datetypecode as integer,
  @i_actualind as tinyint
) 
RETURNS datetime

/*******************************************************************************************************
**  Name: qproject_get_taskdate
**  Desc: This function returns the date for a specific task.
**
**  Auth: Alan Katzen
**  Date: April 2, 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_date   datetime,
    @v_actualind tinyint
    
  SELECT @v_count = COUNT(*)
    FROM taqprojecttask
   WHERE taqprojectkey = @i_projectkey 
     AND datetypecode = @i_datetypecode
  
  IF @v_count = 0
    RETURN NULL   
  
  SELECT @v_date = activedate,@v_actualind = COALESCE(actualind,0)
    FROM taqprojecttask
   WHERE taqprojectkey = @i_projectkey 
     AND datetypecode = @i_datetypecode

  IF @i_actualind = 1 BEGIN
    IF @v_actualind <> 1 BEGIN
      RETURN NULL   
    END
  END
      
  RETURN @v_date
  
END
GO

GRANT EXEC ON dbo.qproject_get_taskdate TO public
GO
