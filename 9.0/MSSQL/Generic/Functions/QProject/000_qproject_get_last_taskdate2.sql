IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_last_taskdate2') )
DROP FUNCTION dbo.qproject_get_last_taskdate2
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION [dbo].[qproject_get_last_taskdate2]
(
  @i_projectkey as integer,
  @i_datetypecode as integer
) 
RETURNS date


/*******************************************************************************************************
**  Name: [qproject_get_last_taskdate2]
**  Desc: This function returns the date for a specific task.  Checks for printing project.
**
**  Auth: Alan Katzen
**  Date: September 30, 2014
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_date   datetime,
    @v_itemtype int,
    @v_usageclass int,
    @v_bookkey int,
    @v_printingkey int
    
  SET @v_date = null
  
  IF @i_projectkey > 0 BEGIN
    SELECT @v_itemtype = searchitemcode,@v_usageclass = usageclasscode
      FROM taqproject
     WHERE taqprojectkey = @i_projectkey
     
    IF @v_itemtype = 14 BEGIN
      -- printing project - need to get dates based on bookkey/printingkey
      SELECT @v_bookkey = bookkey, @v_printingkey = printingkey
        FROM taqprojectprinting_view
       WHERE taqprojectkey = @i_projectkey
       
      SELECT @v_count = COUNT(*)
        FROM taqprojecttask
       WHERE bookkey = @v_bookkey 
         AND printingkey = @v_printingkey
         AND datetypecode = @i_datetypecode

      IF @v_count = 0
        RETURN NULL   
      
      SELECT @v_date = MAX( activedate )
		    FROM taqprojecttask
	     WHERE bookkey = @v_bookkey 
         AND printingkey = @v_printingkey 
	       AND (datetypecode = @i_datetypecode)     
    END	
    ELSE BEGIN
      SELECT @v_count = COUNT(*)
        FROM taqprojecttask
       WHERE taqprojectkey = @i_projectkey 
         AND datetypecode = @i_datetypecode
         
      IF @v_count = 0
        RETURN NULL   
      
      SELECT @v_date = MAX( activedate )
		    FROM taqprojecttask
	    WHERE (taqprojectkey = @i_projectkey) AND (datetypecode = @i_datetypecode)         
    END
    
  END
  
  RETURN @v_date
  
END
go

GRANT EXEC ON dbo.[qproject_get_last_taskdate2] TO public
GO