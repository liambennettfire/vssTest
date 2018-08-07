if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_delete_version_royalties') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_delete_version_royalties
GO

CREATE PROCEDURE qpl_delete_version_royalties
 (@i_projectkey       integer,
  @i_plstage          integer,
  @i_plversion        integer,
  @i_roletypecode     integer,
  @i_globalcontactkey integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*********************************************************************************************************************
**  Name: qpl_delete_version_royalties
**  Desc: This stored procedure deletes the given P&L Version royalties by contributor
**  Case: 42178
**
**  Auth: Colman
**  Date: January 13 2017
**
***********************************************************************************************************************
**	Change History
***********************************************************************************************************************
**	Date      Author  Description
**	--------  ------  -----------
**********************************************************************************************************************/
  
DECLARE
  @v_count	INT,
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
  
  IF @i_plversion IS NULL OR @i_plversion <= 0 BEGIN
    SET @o_error_desc = 'Invalid taqversionkey.'
    GOTO RETURN_ERROR
  END
  
  -- ***** BEGIN TRANSACTION ****  
  BEGIN TRANSACTION
  SET @v_isopentrans = 1
       
  -- TAQVERSIONROYALTYRATES
  DELETE FROM taqversionroyaltyrates
  WHERE taqversionroyaltykey IN
    (SELECT taqversionroyaltykey
     FROM taqversionroyaltysaleschannel
     WHERE taqprojectkey = @i_projectkey 
      AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
      AND roletypecode = @i_roletypecode AND globalcontactkey = @i_globalcontactkey)
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionroyaltyrates table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONROYALTYSALESCHANNEL
  DELETE FROM taqversionroyaltysaleschannel
  WHERE taqprojectkey = @i_projectkey 
    AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
    AND roletypecode = @i_roletypecode AND globalcontactkey = @i_globalcontactkey
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionroyaltysaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  -- TAQVERSIONROYALTYADVANCE
  DELETE FROM taqversionroyaltyadvance
  WHERE taqprojectkey = @i_projectkey 
    AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
    AND roletypecode = @i_roletypecode AND globalcontactkey = @i_globalcontactkey
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting from taqversionroyaltyadvance table (Error ' + cast(@v_error AS VARCHAR) + ').'
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

GRANT EXEC ON qpl_delete_version_royalties TO PUBLIC
GO
