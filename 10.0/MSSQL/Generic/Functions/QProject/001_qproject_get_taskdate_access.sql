IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskdate_access') )
DROP FUNCTION dbo.qproject_get_taskdate_access
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION [dbo].[qproject_get_taskdate_access]
(
  @i_userkey as integer,
  @i_projectkey as integer,
  @i_datetypecode as integer
) 
RETURNS integer


/*******************************************************************************************************
**  Name: [qproject_get_taskdate_access]
**  Desc: This function returns the user's access level to a specific task.  Checks for printing project.
**        Returns no access if tasks does not exist.
**
**  Auth: Colman
**  Date: May 11, 2016
********************************************************************************************************
**  Change History
********************************************************************************************************
**  Date:      Author:    Case #:   Description:
**  --------   --------   -------   --------------------------------------
**  06/07/18   Colman     50971     Implemented availsecurityobjectkey.firstprintingind support
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
  
  IF @i_projectkey > 0 BEGIN
    SELECT @v_itemtype = searchitemcode,@v_usageclass = usageclasscode
      FROM taqproject
     WHERE taqprojectkey = @i_projectkey
     
    IF @v_itemtype = 14 BEGIN
      -- printing project - need to get dates based on bookkey/printingkey
      SELECT @v_bookkey = bookkey, @v_printingkey = printingkey
        FROM taqprojectprinting_view
       WHERE taqprojectkey = @i_projectkey
       
      IF EXISTS (SELECT 1
        FROM taqprojecttask
       WHERE bookkey = @v_bookkey 
         AND printingkey = @v_printingkey
         AND datetypecode = @i_datetypecode
      )
        SET @v_accesscode = dbo.qutl_check_gentable_value_security_by_status(cast(@i_userkey as varchar),'tasktracking',323,@i_datetypecode,@v_bookkey,@v_printingkey,0)
      
    END
    ELSE BEGIN
      IF EXISTS (SELECT 1
        FROM taqprojecttask
       WHERE taqprojectkey = @i_projectkey 
         AND datetypecode = @i_datetypecode
      )
        SET @v_accesscode = dbo.qutl_check_gentable_value_security(cast(@i_userkey as varchar),'tasktracking',323,@i_datetypecode,@v_printingkey)

    END
    
  END
  
  RETURN @v_accesscode
  
END
go

GRANT EXEC ON dbo.[qproject_get_taskdate_access] TO public
GO