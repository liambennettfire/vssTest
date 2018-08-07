if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_royaltyinfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_copy_royaltyinfo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_copy_royaltyinfo
  (@i_from_projectkey integer,
  @i_new_projectkey   integer,
  @i_approved_status  integer,
  @i_userid           varchar(30),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/***************************************************************************************
**  Name: qproject_copy_royaltyinfo
**  Desc: This stored procedure is called from qproject_copy_project_contract_royalty
**        and handles copying Contract royalty information.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Kate W.
**  Date: 8 May 2012
****************************************************************************************/

DECLARE
  @v_copy_plstage INT,
  @v_copy_plversion INT,  
  @v_count  INT,
  @v_error  INT,
  @v_lastind TINYINT,
  @v_mediatype  INT,
  @v_mediasubtype INT,
  @v_newroyaltykey INT,
  @v_newroyaltyratekey  INT,
  @v_pricetypeforroyalty  INT,
  @v_royaltykey INT,
  @v_royaltyrate  FLOAT,
  @v_saleschannelcode INT,
  @v_threshold  INT
	
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
      
    DECLARE royaltyformat_cur CURSOR FOR
      SELECT f.mediatypecode, f.mediatypesubcode, s.taqversionroyaltykey, s.saleschannelcode, s.pricetypeforroyalty
      FROM taqversionroyaltysaleschannel s, taqversionformat f
      WHERE s.taqprojectformatkey = f.taqprojectformatkey AND
        s.taqprojectkey = @i_from_projectkey AND
        s.plstagecode = @v_copy_plstage AND
        s.taqversionkey = @v_copy_plversion

    OPEN royaltyformat_cur 	

    FETCH NEXT FROM royaltyformat_cur 
    INTO @v_mediatype, @v_mediasubtype, @v_royaltykey, @v_saleschannelcode, @v_pricetypeforroyalty

    WHILE (@@FETCH_STATUS = 0)
    BEGIN

      EXEC get_next_key @i_userid, @v_newroyaltykey OUTPUT

      INSERT INTO taqprojectroyalty
        (royaltykey, taqprojectkey, mediacode, formatcode, saleschannelcode, pricetypeforroyalty, lastuserid, lastmaintdate)
      VALUES
        (@v_newroyaltykey, @i_new_projectkey, @v_mediatype, @v_mediasubtype, @v_saleschannelcode, @v_pricetypeforroyalty, @i_userid, getdate())
        
      SELECT @v_error = @@ERROR
      IF @v_error <> 0
      BEGIN
        SET @o_error_desc = 'Insert into taqprojectroyalty table failed 1 (Error ' + CONVERT(VARCHAR, @v_error) + ').'
        GOTO CURSOR_ERROR
      END
      
      DECLARE royaltyrates_cur CURSOR FOR
        SELECT royaltyrate, threshold, lastthresholdind 
        FROM taqversionroyaltyrates
        WHERE taqversionroyaltykey = @v_royaltykey

      OPEN royaltyrates_cur 	

      FETCH NEXT FROM royaltyrates_cur INTO @v_royaltyrate, @v_threshold, @v_lastind

      WHILE (@@FETCH_STATUS = 0)
      BEGIN
        EXEC get_next_key @i_userid, @v_newroyaltyratekey OUTPUT
        
        INSERT INTO taqprojectroyaltyrates
          (royaltyratekey, royaltykey, royaltyrate, threshold, lastthresholdind, lastuserid, lastmaintdate)
        VALUES
          (@v_newroyaltyratekey, @v_newroyaltykey, @v_royaltyrate, @v_threshold, @v_lastind, @i_userid, getdate())
          
        SELECT @v_error = @@ERROR
        IF @v_error <> 0
        BEGIN
          CLOSE royaltyrates_cur 
          DEALLOCATE royaltyrates_cur        
          SET @o_error_desc = 'Insert into taqprojectroyaltyrates table failed 1 (Error ' + CONVERT(VARCHAR, @v_error) + ').'
          GOTO CURSOR_ERROR
        END
          
        FETCH NEXT FROM royaltyrates_cur INTO @v_royaltyrate, @v_threshold, @v_lastind
      END

      CLOSE royaltyrates_cur 
      DEALLOCATE royaltyrates_cur
      
      FETCH NEXT FROM royaltyformat_cur 
      INTO @v_mediatype, @v_mediasubtype, @v_royaltykey, @v_saleschannelcode, @v_pricetypeforroyalty
    END

    CLOSE royaltyformat_cur 
    DEALLOCATE royaltyformat_cur
    
    RETURN
  END -- END Copy royalty information from the approved version for the most recent stage
  
  ELSE
  BEGIN
    -- Check if royalty info exists at the project level for this project
    SELECT @v_count = COUNT(*)
    FROM taqprojectroyalty
    WHERE taqprojectkey = @i_from_projectkey
    
    IF @v_count > 0
    BEGIN
      -- Copy from taqprojectroyalty/taqprojectroyaltyrates tables
      DECLARE royaltyformat_cur CURSOR FOR
        SELECT mediacode, formatcode, royaltykey, saleschannelcode, pricetypeforroyalty
        FROM taqprojectroyalty
        WHERE taqprojectkey = @i_from_projectkey

      OPEN royaltyformat_cur 	

      FETCH NEXT FROM royaltyformat_cur 
      INTO @v_mediatype, @v_mediasubtype, @v_royaltykey, @v_saleschannelcode, @v_pricetypeforroyalty

      WHILE (@@FETCH_STATUS = 0)
      BEGIN

        EXEC get_next_key @i_userid, @v_newroyaltykey OUTPUT

        INSERT INTO taqprojectroyalty
          (royaltykey, taqprojectkey, mediacode, formatcode, saleschannelcode, pricetypeforroyalty, lastuserid, lastmaintdate)
        VALUES
          (@v_newroyaltykey, @i_new_projectkey, @v_mediatype, @v_mediasubtype, @v_saleschannelcode, @v_pricetypeforroyalty, @i_userid, getdate())
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0
        BEGIN
          SET @o_error_desc = 'Insert into taqprojectroyalty table failed 2 (Error ' + CONVERT(VARCHAR, @v_error) + ').'
          GOTO CURSOR_ERROR
        END
                
        DECLARE royaltyrates_cur CURSOR FOR
          SELECT royaltyrate, threshold, lastthresholdind 
          FROM taqprojectroyaltyrates
          WHERE royaltykey = @v_royaltykey

        OPEN royaltyrates_cur 	

        FETCH NEXT FROM royaltyrates_cur INTO @v_royaltyrate, @v_threshold, @v_lastind

        WHILE (@@FETCH_STATUS = 0)
        BEGIN
          EXEC get_next_key @i_userid, @v_newroyaltyratekey OUTPUT
          
          INSERT INTO taqprojectroyaltyrates
            (royaltyratekey, royaltykey, royaltyrate, threshold, lastthresholdind, lastuserid, lastmaintdate)
          VALUES
            (@v_newroyaltyratekey, @v_newroyaltykey, @v_royaltyrate, @v_threshold, @v_lastind, @i_userid, getdate())
            
          SELECT @v_error = @@ERROR
          IF @v_error <> 0
          BEGIN
            CLOSE royaltyrates_cur
            DEALLOCATE royaltyrates_cur
            SET @o_error_desc = 'Insert into taqprojectroyaltyrates table failed 2 (Error ' + CONVERT(VARCHAR, @v_error) + ').'
            GOTO CURSOR_ERROR
          END
                    
          FETCH NEXT FROM royaltyrates_cur INTO @v_royaltyrate, @v_threshold, @v_lastind
        END

        CLOSE royaltyrates_cur 
        DEALLOCATE royaltyrates_cur
        
        FETCH NEXT FROM royaltyformat_cur 
        INTO @v_mediatype, @v_mediasubtype, @v_royaltykey, @v_saleschannelcode, @v_pricetypeforroyalty
      END

      CLOSE royaltyformat_cur 
      DEALLOCATE royaltyformat_cur
      
    END
  END
  
  RETURN
  
  CURSOR_ERROR:
  CLOSE royaltyformat_cur 
  DEALLOCATE royaltyformat_cur      
  SET @o_error_code = -1
  RETURN
  
END
GO

GRANT EXEC ON qproject_copy_royaltyinfo TO PUBLIC
GO
