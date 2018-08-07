if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_digital_asset_status_history') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_digital_asset_status_history
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_digital_asset_status_history
 (@i_elementkey           integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_digital_asset_status_history
**  Desc: This stored procedure returns the status history for a specific  
**        digital asset.
** 
**    Auth: Alan Katzen
**    Date: 16 August 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_taskviewkey INT
          
          
  -- get taskviewkey for Asset Status History - qsicode = 2
  SET @v_taskviewkey = -1
  SELECT @v_taskviewkey = taskviewkey 
    FROM taskview
   WHERE qsicode = 2

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing taskview for qsicode = 2: elementkey = ' + cast(@i_elementkey AS VARCHAR)  
  END 
    
  SELECT tpt.*, dbo.get_gentables_desc(593,d.csstatuscode,'long') statusdesc
    FROM taqprojecttask tpt, taskviewdatetype tvd, datetype d
   WHERE tpt.datetypecode = tvd.datetypecode
     AND tpt.datetypecode = d.datetypecode
     AND tpt.taqelementkey = @i_elementkey
     AND tvd.taskviewkey = @v_taskviewkey
     AND tpt.actualind = 1
ORDER BY tpt.activedate desc
   
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing taqprojecttask: elementkey = ' + cast(@i_elementkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_digital_asset_status_history TO PUBLIC
GO



