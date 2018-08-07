IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_taskdate_access') )
DROP FUNCTION dbo.qtitle_get_taskdate_access
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION [dbo].[qtitle_get_taskdate_access]
(
  @i_userkey as integer,
  @i_bookkey as integer,  
  @i_printingkey as integer,
  @i_datetypecode as integer
) 
RETURNS integer


/*******************************************************************************************************
**  Name: [qtitle_get_taskdate_access]
**  Desc: This function returns the user's access level to a specific task.
**        Returns no access if tasks does not exist.
**
**  Auth: Uday A. Khisty
**  Date: June 27, 2016
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_date   datetime,
    @v_itemtype int,
    @v_usageclass int,
    @v_bookkey int,
    @v_printingkey int,
    @v_accesscode int
    
  SET @v_accesscode = 0
  
  IF @i_bookkey > 0 AND @i_printingkey > 0 BEGIN     
      SELECT @v_count = COUNT(*)
        FROM taqprojecttask
       WHERE bookkey = @i_bookkey  
         AND printingkey = @i_printingkey
         AND datetypecode = @i_datetypecode
         
      IF @v_count > 0
        SET @v_accesscode = dbo.qutl_check_gentable_value_security_by_status(cast(@i_userkey as varchar),'tasktracking',323,@i_datetypecode,@i_bookkey,@i_printingkey,0)
    
  END
  
  RETURN @v_accesscode
  
END
go

GRANT EXEC ON dbo.[qtitle_get_taskdate_access] TO public
GO