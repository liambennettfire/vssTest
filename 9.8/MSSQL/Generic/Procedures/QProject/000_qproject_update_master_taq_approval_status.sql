IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_update_master_taq_approval_status]') AND type in (N'P', N'PC'))
BEGIN
  DROP PROCEDURE [dbo].[qproject_update_master_taq_approval_status]
END
GO

CREATE PROCEDURE [dbo].[qproject_update_master_taq_approval_status]
    (@i_master_projectkey integer,
     @i_userid            varchar(30),
     @o_error_code        integer output,
     @o_error_desc        varchar(2000) output)
AS
/******************************************************************************
**  Name: qproject_update_master_taq_approval_status
**  Desc: 
**  Auth: Colman
**  Date: 2/6/2018
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  -----     ------    -------------------------------------------
*******************************************************************************/
BEGIN
  DECLARE 
      @v_work_projectkey    INT,
      @v_projectstatuscode    INT,
      @v_masterprojrelcode  INT,
      @v_masterworkrelcode  INT,
      @v_projapprovedstatus  INT,
      @v_partiallyapprovedstatus  INT,
      @v_newstatus  INT,
      @v_masterworkitemtype  INT,
      @v_masterworkusageclass  INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_projapprovedstatus = datacode
  FROM gentables
  WHERE tableid = 522
    AND qsicode = 1

  IF ISNULL(@v_projapprovedstatus, 0) <= 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to determine Acquisition Approved Status Code'
    RETURN
  END

  SELECT @v_partiallyapprovedstatus = datacode
  FROM gentables
  WHERE tableid = 522
    AND qsicode = 24

  IF ISNULL(@v_partiallyapprovedstatus, 0) <= 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to determine Acquisition Partially Approved Status Code'
    RETURN
  END

  SELECT @v_masterprojrelcode = datacode
  FROM gentables
  WHERE tableid = 582
    AND qsicode = 14

  SELECT @v_masterworkrelcode = datacode
  FROM gentables
  WHERE tableid = 582
    AND qsicode = 15

  IF ISNULL(@v_masterprojrelcode, 0) <= 0 OR ISNULL(@v_masterworkrelcode, 0) <= 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to determine Master Acquisition/Master Work relationship codes'
    RETURN
  END

  SELECT @v_projectstatuscode = taqprojectstatuscode
  FROM taqproject
  WHERE taqprojectkey = @i_master_projectkey

  -- If any subordinate acquisitions are approved
  IF EXISTS (
    SELECT 1 FROM projectrelationshipview rv
    JOIN taqproject p ON p.taqprojectkey = rv.taqprojectkey 
      AND p.taqprojectstatuscode IN (SELECT datacode FROM gentables WHERE tableid=522 and gen2ind=1)  -- Locked statuses
    WHERE relationshipcode = (SELECT datacode FROM gentables WHERE tableid=582 AND qsicode=32)            -- Master to Subordinate Acquisition
      AND rv.relatedprojectkey = @i_master_projectkey
  )
  BEGIN
      -- If all subordinate acquistions are approved, update Master status to Approved, otherwise Partially Approved
      IF NOT EXISTS (
        SELECT 1 FROM projectrelationshipview rv
        JOIN taqproject p ON p.taqprojectkey = rv.taqprojectkey 
          AND p.taqprojectstatuscode NOT IN (SELECT datacode FROM gentables WHERE tableid=522 and gen2ind=1)  -- Locked statuses
        WHERE relationshipcode = (SELECT datacode FROM gentables WHERE tableid=582 AND qsicode=32)            -- Master to Subordinate Acquisition
          AND rv.relatedprojectkey = @i_master_projectkey
      )
        SET @v_projectstatuscode = @v_projapprovedstatus
      ELSE
        SET @v_projectstatuscode = @v_partiallyapprovedstatus
      
      UPDATE taqproject
      SET taqprojectstatuscode = @v_projectstatuscode, lastuserid = @i_userid, lastmaintdate = getdate()
      WHERE taqprojectkey = @i_master_projectkey
  END
END
      
GO

GRANT EXEC ON qproject_update_master_taq_approval_status TO PUBLIC
GO

