if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_delete_version') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_delete_version
GO

CREATE PROCEDURE qpl_delete_version
 (@i_projectkey     integer,
  @i_plstage        integer,
  @i_plversion      integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  Name: qpl_delete_version
**  Desc: This stored procedure deletes the given P&L Version and all associated data.
**
**  Auth: Kate
**  Date: November 8 2007
**
**  Updates:
**	case #29966 - JR
**  Date: 1/8/15
*****************************************************************************************************/
  
DECLARE
  @v_error  INT,
  @v_isopentrans	TINYINT,
  @v_categorykey	INT
    
BEGIN

  SET @v_isopentrans = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
  
  /*case #29966 */
  --IF @i_plstage IS NULL OR @i_plstage <= 0 BEGIN
  --  SET @o_error_desc = 'Invalid plstagecode.'
  --  GOTO RETURN_ERROR
  --END

  IF @i_plversion IS NULL OR @i_plversion <= 0 BEGIN
    SET @o_error_desc = 'Invalid taqversionkey.'
    GOTO RETURN_ERROR
  END
  
  -- ***** BEGIN TRANSACTION ****  
  BEGIN TRANSACTION
  SET @v_isopentrans = 1
       
  -- TAQVERSIONSUBRIGHTSYEAR
  DELETE FROM taqversionsubrightsyear
  WHERE subrightskey IN 
    (SELECT subrightskey 
     FROM taqversionsubrights
     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionsubrightsyear table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END    
      
  -- TAQVERSIONSUBRIGHTS
  DELETE FROM taqversionsubrights
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionsubrights table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END

 -- TAQVERSIONMARKETCHANNELYEAR
  DELETE FROM taqversionmarketchannelyear
  WHERE targetmarketkey IN 
    (SELECT targetmarketkey 
     FROM taqversionmarket
     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionmarketchannelyear table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END    
      
  -- TAQVERSIONMARKET
  DELETE FROM taqversionmarket
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionmarket table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END

  -- TAQVERSIONCOSTS
  DELETE FROM taqversioncosts
  WHERE taqversionformatyearkey IN
    (SELECT taqversionformatyearkey
     FROM taqversionformatyear
     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversioncosts table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONCOSTMESSAGES  
  DELETE FROM taqversioncostmessages
  WHERE taqversionformatyearkey IN
    (SELECT taqversionformatyearkey
     FROM taqversionformatyear
     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversioncostmessages table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONINCOME
  DELETE FROM taqversionincome
  WHERE taqversionformatyearkey IN
    (SELECT taqversionformatyearkey
     FROM taqversionformatyear
     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionincome table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONFORMATYEAR
  DELETE FROM taqversionformatyear
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion 
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionformatyear table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONADDTLUNITSYEAR
  DELETE FROM taqversionaddtlunitsyear
  WHERE addtlunitskey IN
    (SELECT addtlunitskey
     FROM taqversionaddtlunits
     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionaddtlunitsyear table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END  
  
  -- TAQVERSIONADDTLUNITS
  DELETE FROM taqversionaddtlunits
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion 
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionaddtlunits table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONROYALTYRATES
  DELETE FROM taqversionroyaltyrates
  WHERE taqversionroyaltykey IN
    (SELECT taqversionroyaltykey
     FROM taqversionroyaltysaleschannel
     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionroyaltyrates table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONROYALTYSALESCHANNEL
  DELETE FROM taqversionroyaltysaleschannel
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion 
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionroyaltysaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONSPECCATEGORY / TAQVERSIONSPECITEMS
  DECLARE speccategory_cursor CURSOR FOR
	SELECT taqversionspecategorykey
	FROM taqversionspeccategory
	WHERE taqprojectkey = @i_projectkey 
		AND plstagecode = @i_plstage 
		AND taqversionkey = @i_plversion

	OPEN speccategory_cursor

	FETCH speccategory_cursor
	INTO @v_categorykey

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		DELETE FROM taqversionspecitems
		WHERE taqversionspecategorykey = @v_categorykey
		
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
			SET @o_error_desc = 'Error deleting from taqversionspecitems table (Error ' + cast(@v_error AS VARCHAR) + ').'
			GOTO RETURN_ERROR
		END
		
		DELETE FROM taqversionspecnotes
		WHERE taqversionspecategorykey = @v_categorykey
		
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
			SET @o_error_desc = 'Error deleting from taqversionspecnotes table (Error ' + cast(@v_error AS VARCHAR) + ').'
			GOTO RETURN_ERROR
		END
				
		DELETE FROM taqversionspeccategory
		WHERE taqversionspecategorykey = @v_categorykey
		
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
			SET @o_error_desc = 'Error deleting from taqversionspeccategory table (Error ' + cast(@v_error AS VARCHAR) + ').'
			GOTO RETURN_ERROR
		END  
		
		FETCH speccategory_cursor
		INTO @v_categorykey
	END

	CLOSE speccategory_cursor
	DEALLOCATE speccategory_cursor 
  
  -- TAQVERSIONSALESUNIT
  DELETE FROM taqversionsalesunit
  WHERE taqversionsaleskey IN
    (SELECT taqversionsaleskey
     FROM taqversionsaleschannel
     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion)
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionsalesunit table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONSALESCHANNEL
  DELETE FROM taqversionsaleschannel
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion 
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END  
  
  -- TAQVERSIONFORMAT
  DELETE FROM taqversionformat
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion 
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionformat table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONCLIENTVALUES
  DELETE FROM taqversionclientvalues
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionclientvalues table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONCOMMENTS
  DELETE FROM taqversioncomments
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversioncomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END

  -- TAQVERSIONROYALTYADVANCE
  DELETE FROM taqversionroyaltyadvance
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionroyaltyadvance table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONFORMATCOMPLETE
  DELETE FROM taqversionformatcomplete
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionformatcomplete table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONCOMPLETE
  DELETE FROM taqversioncomplete
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversioncomplete table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQPLSUMMARYITEMS
  DELETE FROM taqplsummaryitems
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqplsummaryitems table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END  
    
  -- TAQVERSION at the end
  DELETE FROM taqversion
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion 
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversion table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  IF @v_isopentrans = 1
    COMMIT TRANSACTION
    
  RETURN  


RETURN_ERROR:  
  IF @v_isopentrans = 1
    ROLLBACK TRANSACTION
    
  SET @o_error_code = -1
  RETURN
  
END
GO

GRANT EXEC ON qpl_delete_version TO PUBLIC
GO
