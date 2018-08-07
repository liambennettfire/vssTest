IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_check_if_task_exists')
  BEGIN
    PRINT 'Dropping Procedure qutl_check_if_task_exists'
    DROP  Procedure  qutl_check_if_task_exists
  END

GO

PRINT 'Creating Procedure qutl_check_if_task_exists'
GO

CREATE PROCEDURE qutl_check_if_task_exists
 (@i_taskviewkey     integer,
  @i_datetypecode    integer,
  @i_taskviewtriggerkey     integer = 0,  
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  
**  Name:   qutl_check_if_task_exists
**
**  Desc:   Checks if a taskviewdatetype record exists for the input 
**          taskviewkey/datetypecode combination so the user cannot add 
**          a duplicate. Returns the record.
**              
**    Called by:  Controls.Admin.Tasks.AddEditTaskViewTask 
**              
**    Parameters:
**    Input              
**    ----------         
**    tablename - Table Name of table to do count on - Required
**    whereclause - Where clause for select statement (what we should do the count on) - Required
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message or locked message - empty if Not Locked or Locked By This User already
**
**    Auth: Lisa Cormier
**    Date: 3/11/09
**
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    
*******************************************************************************/

DECLARE @error_var varchar(2000)
DECLARE @rowcount_var integer

  SELECT * FROM taskviewdatetype WHERE taskviewkey = @i_taskviewkey and datetypecode = @i_datetypecode and taskviewtriggerkey = COALESCE(@i_taskviewtriggerkey, 0)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check if taskviewdatetype record exists for TV=' + convert(varchar, @i_taskviewkey) + ' DT=' + convert(varchar, @i_datetypecode)
    RETURN
  END 
  
  RETURN 
GO

GRANT EXEC ON qutl_check_if_task_exists TO PUBLIC
GO




















