
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_set_csupdatetracker_outbox') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcs_set_csupdatetracker_outbox
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcs_set_csupdatetracker_outbox
 (@i_datetimeval    datetime, 
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS
BEGIN

	DECLARE	@CountVar INT
	DECLARE @error_var    INT
  DECLARE @rowcount_var INT

/******************************************************************************
**  File: 
**  Name: qcs_set_csupdatetracker_outbox
**  Desc: 
**
**
**    Auth: Jon Hess
**    Date: 13 December 2010
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

    -- update timestamp on csupdatetracker
    SELECT @CountVar = count(*)
      FROM csupdatetracker    

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get outboxtitlesupdated from csupdatetracker'
    return
  END  

    IF @CountVar > 0 
     BEGIN
      UPDATE csupdatetracker
        SET outboxtitlesupdated = @i_datetimeval
     END  
     
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to set outboxtitlesupdated from csupdatetracker'
    return
  END      
END
  
GO
GRANT EXEC ON qcs_set_csupdatetracker_outbox TO PUBLIC
GO