IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qproject_status_requires_verification') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_status_requires_verification
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_status_requires_verification
 (@i_itemtype        integer, 
  @i_usageclass      integer,
  @i_statuscode      integer,
  @o_resultcode      integer output,
  @o_error_code      integer output,
  @o_error_desc      VARCHAR(2000) output)
AS


/******************************************************************************
**  Name: qproject_status_requires_verification
**  Desc: This stored procedure returns verification info FOR a project status 
**        by itemtype/usageclass. 
**          
**    Auth: Colman
**    Date: 2/21/2017
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:         Author:       Description:
**    ----------    ----------    ---------------------------------------------
**
*******************************************************************************/

  DECLARE @error_var INT,
          @v_projectstatus_table INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_resultcode = 0
  SET @v_projectstatus_table = 522

  IF EXISTS (
    SELECT 1
      FROM gentablesitemtype gi
     WHERE gi.tableid = @v_projectstatus_table AND
           gi.itemtypecode = @i_itemtype AND
           (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0) AND
           (@i_statuscode = 0 OR gi.datacode = @i_statuscode) AND
           ISNULL(gi.relateddatacode,0) > 0)
  BEGIN
    SET @o_resultcode = 1
  END

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'qproject_status_requires_verification failed'
  END 

GO
GRANT EXEC ON qproject_status_requires_verification TO PUBLIC
GO
