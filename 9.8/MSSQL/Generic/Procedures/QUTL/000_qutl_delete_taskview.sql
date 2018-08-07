IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_delete_taskview')
BEGIN
  PRINT 'Dropping Procedure qutl_delete_taskview'
  DROP  Procedure  qutl_delete_taskview
END
GO

PRINT 'Creating Procedure qutl_delete_taskview'
GO

CREATE PROCEDURE qutl_delete_taskview
 (@i_taskviewkey        integer,
  @i_userid             integer,
  @i_taskviewind        integer,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_delete_taskview
**  Desc: Delete a taskview (or group) from the database.
**
**              
**    Return values: 
**
**    Called by:   
**              
**    Parameters:
**    Input              
**    ----------         
**    taskviewkey - Key of TaskView Being Deleted - Required
**    userkey - userkey of user deleting project - NOT Required 
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Lisa Cormier
**    Date: 05/30/09
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    
*******************************************************************************/
  
  DECLARE @QsiView integer
  DECLARE @ErrMsgPrefix varchar(30)
  
  if ( @i_taskviewind = 1 )
    SELECT @ErrMsgPrefix = 'Unable to Delete TaskView: '
  ELSE
    SELECT @ErrMsgPrefix = 'Unable to Delete TaskGroup: '
 
  -- verify projectkey is filled in
  IF @i_taskviewkey IS NULL OR @i_taskviewkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = @ErrMsgPrefix + ' taskviewkey is empty.'
    RETURN
  END 

  -- Make sure this is not a Firebrand controlled taskview.  Users should not be able to
  -- delete that.
  SELECT @QsiView = ( select isNull(lockbyfirebrandind, 0) from taskview where taskviewkey = @i_taskviewkey )
  
  IF ( @QsiView = 1 )
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = @ErrMsgPrefix + ' locked by Firebrand.'
    RETURN
  END    

  BEGIN TRANSACTION

  delete from taskviewfields where taskviewkey = @i_taskviewkey
  delete from taskviewdatetype where taskviewkey = @i_taskviewkey
  delete from taskview where taskviewkey = @i_taskviewkey  

  COMMIT
  
  -- delete this taskview from any existing lists of taskviews (for all users)
  DELETE FROM qse_searchresults
  WHERE key1 = @i_taskviewkey AND
    listkey IN (SELECT listkey FROM qse_searchlist 
                WHERE searchtypecode in (19,20) AND saveascriteriaind = 0)

  ExitHandler:

GO

GRANT EXEC ON qutl_delete_taskview TO PUBLIC
GO
