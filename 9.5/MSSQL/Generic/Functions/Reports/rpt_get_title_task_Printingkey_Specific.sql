/****** Object:  UserDefinedFunction [dbo].[rpt_get_title_task_Printingkey_Specific]    Script Date: 04/13/2015 12:52:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_title_task_Printingkey_Specific]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_title_task_Printingkey_Specific]
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_title_task_Printingkey_Specific]    Script Date: 04/13/2015 12:52:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--sp_helptext rpt_get_title_task_Printingkey_Specific    
    
        
      
      
CREATE FUNCTION [dbo].[rpt_get_title_task_Printingkey_Specific]         
             (@i_bookkey  INT,        
             @i_datetypecode int,     
   @i_Printingkey int,       
    @v_datetype varchar)        
          
        
 /** Returns the date for the passed bookkey and datetypecode, selecting the column        
specified in 3rd parameter @v_datetype. This function is for Version 7 and         
retrieves date from new scheduling table taqprojecttask, rather than the original        
task table  **/        
        
    -- v_datetype = 'O' = original        
    -- v_datetype = 'A' = active actual       
    -- v_datetype = 'B' = best 
    -- v_datetype = 'E' = active          
        
RETURNS datetime        
        
AS          
        
        
        
BEGIN         
        
        
DECLARE @d_date as datetime        
DECLARE @RETURN as datetime        
        
Select @d_date =         
 case         
 when @v_datetype = 'O' THEN originaldate        
 when @v_datetype = 'A' and actualind =1 THEN activedate 
 when @v_datetype = 'E' THEN activedate       
 when @v_datetype = 'B' and originaldate is not null and activedate is not null THEN activedate        
 when @v_datetype = 'B' and originaldate is null and activedate is not null THEN activedate        
 when @v_datetype = 'B' and originaldate is not null and activedate is null THEN originaldate        
 end        
FROM taqprojecttask        
WHERE bookkey = @i_bookkey         
 AND datetypecode = @i_datetypecode        
 AND printingkey=@i_Printingkey    
         
        
If @v_datetype is null        
  BEGIN        
   SELECT @RETURN = ''        
  END         
Else         
  BEGIN        
   SELECT @RETURN = @d_date        
  END        
          
        
RETURN @RETURN        
        
END        
GO


GRANT EXEC ON [dbo].[rpt_get_title_task_Printingkey_Specific] to PUBLIC
GO