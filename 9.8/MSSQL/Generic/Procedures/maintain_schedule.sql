SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[maintain_schedule]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[maintain_schedule]
GO


CREATE PROCEDURE maintain_schedule (@sbookkey INT)

AS 
	
DECLARE @v_ElementKey   INT,
        @v_Task         INT,
        @v_Sort         INT,
        @v_Date         DATETIME

DECLARE c_Schedules CURSOR FOR 
        SELECT elementkey
          FROM bookelement
         WHERE bookkey = @sbookkey
   
OPEN c_Schedules
   
FETCH c_Schedules INTO @v_ElementKey
WHILE (@@FETCH_STATUS >= 0)
   BEGIN
      /* Get the last scheduled completed task */
      DECLARE c_Last CURSOR FOR
        SELECT datetypecode, actualdate, sortorder
          FROM task
         WHERE elementkey = @v_ElementKey AND
               actualdate IS NOT NULL AND
               taskschedule = 1
      ORDER BY actualdate DESC, sortorder DESC          

      SELECT @v_Task = NULL
      SELECT @v_Date = NULL
  
      OPEN c_Last
       
      FETCH c_Last INTO @v_Task, @v_Date, @v_Sort

      UPDATE element 
         SET lasttaskdonecode = @v_Task,
             completiondate = @v_Date
       WHERE elementkey = @v_ElementKey
         
      CLOSE c_Last 
      DEALLOCATE c_Last
         
      /* Get the next scheduled task to complete */
      DECLARE c_Next CURSOR FOR
        SELECT datetypecode, estimateddate, sortorder
          FROM task
         WHERE elementkey = @v_ElementKey AND
               actualdate IS NULL AND
               taskschedule = 1
      ORDER BY estimateddate ASC, sortorder ASC
         
      SELECT @v_Task = NULL
      SELECT @v_Date = NULL
        
      OPEN c_Next
      
      FETCH c_Next INTO @v_Task, @v_Date, @v_Sort

      UPDATE element 
         SET nexttaskduecode = @v_Task,
             startdate = @v_Date
       WHERE elementkey = @v_ElementKey          
      
      CLOSE c_Next   
      DEALLOCATE c_Next

      FETCH c_Schedules INTO @v_ElementKey
     
   END /* Check fetch status on c_Schedules */
     
      
CLOSE c_Schedules
DEALLOCATE c_Schedules

SELECT elementkey
           FROM bookelement
           WHERE bookkey = @sbookkey
RETURN




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[maintain_schedule]  TO [public]
GO

