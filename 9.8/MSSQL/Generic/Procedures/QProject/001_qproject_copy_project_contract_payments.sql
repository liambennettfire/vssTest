if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_project_contract_payments') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_copy_project_contract_payments
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_copy_project_contract_payments
  (@i_copy_projectkey     integer,
  @i_copy2_projectkey     integer,
  @i_new_projectkey       integer,
  @i_userid               varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/***************************************************************************************
**  Name: qproject_copy_project_contract_payments
**  Desc: This stored procedure handles copying Contract payment information.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Colman
**  Date: 6 Jun 2015
****************************************************************************************/

DECLARE
  @v_count  INT,
  @v_error  INT,
  @v_approved_status  INT
	
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_copy_projectkey IS NULL OR @i_copy_projectkey = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Copy projectkey not passed to copy payments.'
    RETURN
  END

  IF @i_new_projectkey IS NULL OR @i_new_projectkey = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'New projectkey not passed to copy payments: copy_projectkey=' + CAST(@i_copy_projectkey AS VARCHAR)   
    RETURN
  END
   
/* 5/8/12 - KW - From case 17842:
  Royalty Rates: If there is an approved P&L for i_copy_projectkey, copy the royalty rates from the most recent 
  approved stage P&L for i_copy_projectkey; else copy from i_copy_projectkey taqprojectroyalty and taqprojectroyaltyrates tables. 
  If neither exist, copy from i_copy2_projectkey approved P&L and if that doesn’t exist copy from the taqprojectroyalty 
  and taqprojectroyaltyrates tables. */
  
  SELECT @v_approved_status = clientdefaultvalue
  FROM clientdefaults
  WHERE clientdefaultid = 61
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get P&L Final Approval Status from clientdefaults table.'
    RETURN
  END
  
  IF @v_approved_status IS NULL
    SET @v_approved_status = 0
	
      -- Copy payment info from @i_copy_projectkey
  EXEC qproject_copy_paymentinfo @i_copy_projectkey, @i_new_projectkey, @v_approved_status, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  IF @o_error_code < 0
    RETURN
  
  -- If second projectkey is passed in and no payment info was copied from @i_copy_projectkey, copy from @i_copy2_projectkey
  IF @i_copy2_projectkey > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM taqprojectpayments
    WHERE taqprojectkey = @i_new_projectkey
    
    IF @v_count = 0
      EXEC qproject_copy_paymentinfo @i_copy2_projectkey, @i_new_projectkey, @v_approved_status, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
  END  
  
END
GO

GRANT EXEC ON qproject_copy_project_contract_payments TO PUBLIC
GO
