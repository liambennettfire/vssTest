IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_delete_cloudscheduleforapproval_row')
  BEGIN
    PRINT 'Dropping Procedure qcs_delete_cloudscheduleforapproval_row'
    DROP  Procedure  qcs_delete_cloudscheduleforapproval_row
  END

GO

PRINT 'Creating Procedure qcs_delete_cloudscheduleforapproval_row'
GO

CREATE PROCEDURE qcs_delete_cloudscheduleforapproval_row
 (@i_bookkey                integer,
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcs_delete_cloudscheduleforapproval_row
**  Desc: 
**
**              
**    Return values: 
**
**    Called by:  Called when Send to Eloquence is unchecked in TM or
**      Never Send to Eloquence is checked
**              
**    Parameters:
**    Input              
**    ----------         
**    bookkey - bookkey of title - Required
**    
**    userid - Userid of user causing write to cloudscheduleforapproval  
**      - for now this will be retreived from the clientdefaults 
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Kusum Basra
**    Date: 04/04/2013
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    
**                             
*******************************************************************************/
 DECLARE @v_count INT
 DECLARE @v_error  INT
 DECLARE @v_rowcount INT
 DECLARE @v_elo_in_cloud INT

-- SET @v_csdisttemplatekey = 0
 SET @v_count = 0
 SET @o_error_code = 0
 SET @o_error_desc = ''

 -- verify that all required values are filled in
 IF @i_bookkey IS NULL OR @i_bookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to delete from cloudscheduleforapproval: bookkey is empty.'
    RETURN
 END 


 SELECT @v_count = COUNT(*)
   FROM clientoptions
  WHERE optionid = 111

 IF @v_count = 1 BEGIN
   SELECT @v_elo_in_cloud = optionvalue
     FROM clientoptions
    WHERE optionid = 111
 END
 ELSE BEGIN
    SET @v_elo_in_cloud = 0
 END
 
 IF @v_elo_in_cloud = 1 BEGIN
   SELECT @v_count = COUNT(*)
     FROM cloudscheduleforapproval
    WHERE bookkey = @i_bookkey

   IF @v_count = 1 BEGIN
      DELETE FROM cloudscheduleforapproval 
        WHERE bookkey = @i_bookkey

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Error deleting from cloudscheduleforapproval table (bookkey=' + CAST(@i_bookkey AS VARCHAR)  
      END
   END
 END
GO 

GRANT EXEC ON qcs_delete_cloudscheduleforapproval_row TO PUBLIC
GO