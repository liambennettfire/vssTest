if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taqprojectverification') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taqprojectverification
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_taqprojectverification
 (@i_projectkey      integer,
  @i_itemtype        integer,
  @i_usageclass      integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_get_taqprojectverification
**  Desc: This stored procedure returns info from the taqprojectverification 
**        table for an itemtype/usageclass. 
**          
**        NOTE: 0 projectkey will return all verification types from gentables
**   
**    Auth: Alan Katzen
**    Date: 2 February 2012
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT,
          @v_initial_status INT

  IF @i_projectkey > 0 BEGIN
    SELECT g.alternatedesc1 storedprocname, 
           '' imagename,  
           COALESCE(g.gen1ind, 0) updatestatusind, v.verificationstatuscode origverificationstatuscode, 
           CASE 
             WHEN g.alternatedesc1 IS NULL OR LTRIM(RTRIM(g.alternatedesc1)) = '' THEN 0
             ELSE 1
           END AS storedprocnameexists,
           v.*
      FROM taqprojectverification v, gentables g, gentablesitemtype gi
     WHERE v.verificationtypecode = g.datacode and
           g.tableid = gi.tableid and
           g.datacode = gi.datacode and
           gi.itemtypecode = @i_itemtype and
           (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0) and
           v.taqprojectkey = @i_projectkey and
           g.tableid = 628 
  END
  ELSE BEGIN
    SELECT @v_initial_status = COALESCE(datacode,0)
      FROM gentables
     WHERE tableid = 513 and
           qsicode = 1

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 or @rowcount_var = 0 BEGIN
      SET @v_initial_status = 0
    END 

    SELECT g.alternatedesc1 storedprocname,  
           '' imagename,  
           COALESCE(g.gen1ind, 0) updatestatusind, @v_initial_status origverificationstatuscode, 
           CASE 
             WHEN g.alternatedesc1 IS NULL OR LTRIM(RTRIM(g.alternatedesc1)) = '' THEN 0
             ELSE 1
           END AS storedprocnameexists,
           @v_initial_status verificationstatuscode, g.datacode verificationtypecode, 0 taqprojectkey,
           null lastmaintdate
      FROM gentables g, gentablesitemtype gi
     WHERE g.tableid = gi.tableid and
           g.datacode = gi.datacode and
           gi.itemtypecode = @i_itemtype and
           (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0) and
           g.tableid = 628
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR) 
  END 

GO
GRANT EXEC ON qproject_get_taqprojectverification TO PUBLIC
GO


