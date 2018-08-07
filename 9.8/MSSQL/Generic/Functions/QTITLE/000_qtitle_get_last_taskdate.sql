IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_last_taskdate') )
DROP FUNCTION dbo.qtitle_get_last_taskdate
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION [dbo].[qtitle_get_last_taskdate]
(
  @i_bookkey as integer,
  @i_printingkey as integer,
  @i_datetypecode as integer
) 
RETURNS datetime


/*******************************************************************************************************
**  Name: [qtitle_get_last_taskdate]
**  Desc: This function returns the date for a specific task.
**
**  Auth: Alan Katzen
**  Date: September 11, 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_date   datetime
    
  SET @v_date = null
  
  IF @i_bookkey > 0 BEGIN
    SELECT @v_count = COUNT(*)
      FROM taqprojecttask
     WHERE bookkey = @i_bookkey 
       AND datetypecode = @i_datetypecode
    
    IF @v_count = 0
      RETURN NULL   
    
    SELECT @v_date = MAX( activedate )
		  FROM taqprojecttask
	  WHERE (bookkey = @i_bookkey) AND (datetypecode = @i_datetypecode)
  END
  
  RETURN @v_date
  
END
