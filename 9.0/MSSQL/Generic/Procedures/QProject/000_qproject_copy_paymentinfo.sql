if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_paymentinfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_copy_paymentinfo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_copy_paymentinfo
  (@i_from_projectkey integer,
  @i_new_projectkey   integer,
  @i_approved_status  integer,
  @i_userid           varchar(30),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/***************************************************************************************
**  Name: qproject_copy_paymentinfo
**  Desc: This stored procedure is called from qproject_copy_project_contract_payment
**        and handles copying Contract royalty payment information.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Colman
**  Date: 30 Jun 2015
****************************************************************************************/

DECLARE
    @v_newpaymentkey  INT,
	@v_copy_plstage   INT,
	@v_copy_plversion INT,  
	@v_count          INT,
	@v_error          INT,
	@v_lastind        TINYINT,
	@v_paymentkey     INT,
	@v_taqprojectkey  INT,
	@v_paymenttype	  INT,
	@v_datetypecode	  INT,
	@v_dateoffsetcode INT,
	@v_paymentamount  FLOAT,
	@v_taqtaskkey	  INT,
	@v_date	          DATETIME,
	@v_originaldate	  DATETIME,
	@v_reviseddate    DATETIME,
	@v_note	          VARCHAR(50),
	@v_payeecontactkey INT,
	@v_pmtstatuscode  INT,
	@v_invoicenumber  VARCHAR(50),
	@v_invoicesent    DATETIME,
	@v_checknumber    VARCHAR(50),
	@v_amount         FLOAT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Check if at least one approved p&l version exists for this project
  SELECT @v_count = COUNT(*)
  FROM taqversion
  WHERE taqprojectkey = @i_from_projectkey AND 
    plstatuscode = @i_approved_status
    
  IF @v_count > 0
  BEGIN
    -- Copy royalty information from the approved version for the most recent stage for this project
    SELECT TOP 1 @v_copy_plstage = v.plstagecode, @v_copy_plversion = v.taqversionkey
    FROM taqversion v, gentables g
    WHERE v.plstagecode = g.datacode AND
      g.tableid = 562 AND 
      v.taqprojectkey = @i_from_projectkey AND
      v.plstatuscode = @i_approved_status
    ORDER BY g.sortorder DESC
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error getting approved version for the most recent P&L stage (taqprojectkey=' + CONVERT(VARCHAR, @i_from_projectkey) + ').'
      RETURN
    END
    SELECT @v_count = COUNT(*)
    FROM taqversionroyaltyadvance
    WHERE taqprojectkey = @i_from_projectkey
    
    IF @v_count > 0
    BEGIN
      -- Copy from taqversionroyaltyadvance table
      DECLARE payments_cur CURSOR FOR
        SELECT  datetypecode, dateoffsetcode, amount
        FROM taqversionroyaltyadvance s
        WHERE taqprojectkey = @i_from_projectkey AND
        s.plstagecode = @v_copy_plstage AND
        s.taqversionkey = @v_copy_plversion

      OPEN payments_cur 	

      FETCH NEXT FROM payments_cur 
      INTO @v_datetypecode, @v_dateoffsetcode, @v_amount

      WHILE (@@FETCH_STATUS = 0)
      BEGIN

        EXEC get_next_key @i_userid, @v_newpaymentkey OUTPUT

        INSERT INTO taqprojectpayments
          (paymentkey, taqprojectkey, datetypecode, dateoffsetcode, paymentamount, lastuserid, lastmaintdate )
        VALUES
          (@v_newpaymentkey, @i_new_projectkey, @v_datetypecode, @v_dateoffsetcode, @v_amount, @i_userid, getdate())
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0
        BEGIN
          SET @o_error_desc = 'Insert into taqprojectpayments table failed 2 (Error ' + CONVERT(VARCHAR, @v_error) + ').'
          GOTO CURSOR_ERROR
        END

        FETCH NEXT FROM payments_cur INTO @v_datetypecode, @v_dateoffsetcode, @v_amount
      END           
      CLOSE payments_cur 
      DEALLOCATE payments_cur
	END
  END
  ELSE 
  BEGIN
  -- No approved p&l versions exist for this project
    SELECT @v_count = COUNT(*)
    FROM taqprojectpayments
    WHERE taqprojectkey = @i_from_projectkey
    
    IF @v_count > 0
    BEGIN
      -- Copy from taqprojectpayments table
      DECLARE payments_cur CURSOR FOR
        SELECT paymentkey, taqprojectkey, paymenttype, datetypecode, dateoffsetcode, paymentamount, taqtaskkey, date, originaldate, 
		       reviseddate, note, payeecontactkey, pmtstatuscode, invoicenumber, invoicesent, checknumber
        FROM taqprojectpayments
        WHERE taqprojectkey = @i_from_projectkey

      OPEN payments_cur 	

      FETCH NEXT FROM payments_cur 
      INTO @v_paymentkey, @v_taqprojectkey, @v_paymenttype, @v_datetypecode, @v_dateoffsetcode, @v_paymentamount, @v_taqtaskkey, @v_date, 
	       @v_originaldate, @v_reviseddate, @v_note, @v_payeecontactkey, @v_pmtstatuscode, @v_invoicenumber, @v_invoicesent, @v_checknumber

      WHILE (@@FETCH_STATUS = 0)
      BEGIN
		SET @v_taqtaskkey = NULL
		
		IF COALESCE(@v_datetypecode, 0) > 0 BEGIN
			IF EXISTS(SELECT * FROM taqprojecttask WHERE taqprojectkey = @i_new_projectkey AND datetypecode = @v_datetypecode) BEGIN
				SELECT TOP(1) @v_taqtaskkey = taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_new_projectkey AND datetypecode = @v_datetypecode
			END
		END
		
        EXEC get_next_key @i_userid, @v_newpaymentkey OUTPUT

        INSERT INTO taqprojectpayments
          (paymentkey, taqprojectkey, paymenttype, datetypecode, dateoffsetcode, paymentamount, taqtaskkey, date, originaldate, 
		   reviseddate, note, payeecontactkey, pmtstatuscode, invoicenumber, invoicesent, checknumber, lastuserid, lastmaintdate )
        VALUES
          (@v_newpaymentkey, @i_new_projectkey, @v_paymenttype, @v_datetypecode, @v_dateoffsetcode, @v_paymentamount, @v_taqtaskkey, @v_date, 
	       @v_originaldate, @v_reviseddate, @v_note, @v_payeecontactkey, @v_pmtstatuscode, @v_invoicenumber, @v_invoicesent, @v_checknumber,  @i_userid, getdate())
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0
        BEGIN
          SET @o_error_desc = 'Insert into taqprojectpayments table failed 2 (Error ' + CONVERT(VARCHAR, @v_error) + ').'
          GOTO CURSOR_ERROR
        END

        FETCH NEXT FROM payments_cur 
        INTO @v_paymentkey, @v_taqprojectkey, @v_paymenttype, @v_datetypecode, @v_dateoffsetcode, @v_paymentamount, @v_taqtaskkey, @v_date, 
	         @v_originaldate, @v_reviseddate, @v_note, @v_payeecontactkey, @v_pmtstatuscode, @v_invoicenumber, @v_invoicesent, @v_checknumber
      END          
      CLOSE payments_cur 
      DEALLOCATE payments_cur
    END
  END
 
  RETURN
  
  CURSOR_ERROR:
  CLOSE payments_cur 
  DEALLOCATE payments_cur      
  SET @o_error_code = -1
  RETURN
END
GO

GRANT EXEC ON qproject_copy_paymentinfo TO PUBLIC
GO
