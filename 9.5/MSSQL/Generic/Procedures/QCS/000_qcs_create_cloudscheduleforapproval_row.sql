IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_create_cloudscheduleforapproval_row')
  BEGIN
    PRINT 'Dropping Procedure qcs_create_cloudscheduleforapproval_row'
    DROP  Procedure  qcs_create_cloudscheduleforapproval_row
  END

GO

PRINT 'Creating Procedure qcs_create_cloudscheduleforapproval_row'
GO

CREATE PROCEDURE qcs_create_cloudscheduleforapproval_row
 (@i_bookkey                integer,
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcs_create_cloudscheduleforapproval_row
**  Desc: 
**
**              
**    Return values: 
**
**    Called by:  Called when Send to Eloquence is checked in TM 
**              
**    Parameters:
**    Input              
**    ----------         
**    bookkey - bookkey of title - Required
**    requestedapprovaldate - Required -for now it will be current date
**      so will not be passed in - in future it might change
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
 DECLARE @v_csdisttemplatekey INT
 DECLARE @v_count INT
 DECLARE @v_userid VARCHAR(30)
 DECLARE @v_error  INT
 DECLARE @v_rowcount INT
 DECLARE @v_elo_in_cloud INT

 SET @v_csdisttemplatekey = 0
 SET @v_count = 0
 SET @o_error_code = 0
 SET @o_error_desc = ''
 SET @v_userid = ''

 -- verify that all required values are filled in
 IF @i_bookkey IS NULL OR @i_bookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update cloudscheduleforapproval: bookkey is empty.'
    RETURN
 END 
 
 SELECT @v_csdisttemplatekey = templatekey
   FROM csdistributiontemplate
  WHERE eloquencefieldtag = 'CLD_DTMP_STDELO'  /* this was supplied by Catherine */

 IF @v_csdisttemplatekey IS NULL OR @v_csdisttemplatekey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update cloudscheduleforapproval: No Standard Eloquence Distribution template is available.'
    RETURN
 END 

 SELECT @v_count = COUNT(*)FROM clientdefaults WHERE clientdefaultid = 70
 IF @v_count = 1  BEGIN
   SELECT @v_userid = stringvalue FROM clientdefaults WHERE clientdefaultid = 70
 END

 IF @v_count = 0 OR (@v_userid IS NULL OR @v_userid = '') BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update cloudscheduleforapproval: userid not filled in clientdefaults for User ID for Cloud Approval Jobs (defaultid = 70) .'
    RETURN
 END

 SELECT @v_count = 0

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
   SELECT @v_count = 0

   SELECT @v_count = COUNT(*)
     FROM cloudscheduleforapproval
    WHERE bookkey = @i_bookkey

   IF @v_count = 0 BEGIN
      INSERT INTO cloudscheduleforapproval (bookkey,requestedapprovaldate, csdisttemplatekey, lastuserid, lastmaintdate)
        VALUES(@i_bookkey, getdate(), @v_csdisttemplatekey, @v_userid, getdate())

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Error inserting to cloudscheduleforapproval table (bookkey=' + CAST(@i_bookkey AS VARCHAR) + ' )'  
      END
   END
 END
GO 

GRANT EXEC ON qcs_create_cloudscheduleforapproval_row TO PUBLIC
GO