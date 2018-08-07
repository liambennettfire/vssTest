if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_copy_royalties') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_copy_royalties
GO

CREATE PROCEDURE qcontract_copy_royalties (  
  @i_projectkey           integer,
  @i_fromroletypecode     integer, 
  @i_fromglobalcontactkey integer,
  @i_roletypecode         integer, 
  @i_globalcontactkey     integer,
  @i_userid               varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/*********************************************************************************************************
**  Name: qcontract_copy_royalties
**  Desc: Copies all royalty rows for all formats for a particular roletypecode/globalcontactkey
**  Case: 42178
**
**  Auth: Colman
**  Date: January 13 2017
********************************************************************************************************
**  Change History
**********************************************************************************************************
**  Date:       Author:      Case #:   Description:
**  --------    --------     -------   --------------------------------------
**********************************************************************************************************/

DECLARE
  @v_count INT,  
  @v_cur_royaltykey INT,
  @v_mediacode INT, 
  @v_formatcode INT,
  @v_error  INT,
  @v_lastthresholdind TINYINT,
  @v_pricetypeforroyalty INT,
  @v_royaltykey INT,
  @v_royaltyratekey INT,
  @v_royaltyrate FLOAT,
  @v_saleschannelcode INT,
  @v_threshold INT
    
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
    -- *** Loop through version royalty sales channel records for this format ***
    DECLARE royalty_cur CURSOR FOR
      SELECT royaltykey, mediacode, formatcode, saleschannelcode, pricetypeforroyalty
      FROM taqprojectroyalty
      WHERE taqprojectkey = @i_projectkey AND
            roletypecode = @i_fromroletypecode AND
            globalcontactkey = @i_fromglobalcontactkey

    OPEN royalty_cur

    FETCH royalty_cur INTO @v_cur_royaltykey, @v_mediacode, @v_formatcode, @v_saleschannelcode, @v_pricetypeforroyalty

    WHILE (@@FETCH_STATUS=0)
    BEGIN

      -- generate new royaltykey
      EXEC get_next_key @i_userid, @v_royaltykey OUTPUT

      -- taqprojectroyalty
      INSERT INTO taqprojectroyalty
        (royaltykey, taqprojectkey, mediacode, formatcode,
        saleschannelcode, pricetypeforroyalty, lastuserid, lastmaintdate, roletypecode, globalcontactkey)
      VALUES
        (@v_royaltykey, @i_projectkey, @v_mediacode, @v_formatcode,
        @v_saleschannelcode, @v_pricetypeforroyalty, @i_userid, getdate(), @i_roletypecode, @i_globalcontactkey)

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE royalty_cur
        DEALLOCATE royalty_cur
        SET @o_error_desc = 'Could not insert into taqprojectroyalty table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END

    -- Copy royalty rates
      -- *** Loop through royalty rates for this sales channel and copy one at a time with new key ***
      DECLARE royaltyrates_cur CURSOR FOR
        SELECT royaltyrate, threshold, lastthresholdind
        FROM taqprojectroyaltyrates
        WHERE royaltykey = @v_cur_royaltykey

      OPEN royaltyrates_cur

      FETCH royaltyrates_cur INTO @v_royaltyrate, @v_threshold, @v_lastthresholdind

      WHILE (@@FETCH_STATUS=0)
      BEGIN

        -- generate new royaltyratekey
        EXEC get_next_key @i_userid, @v_royaltyratekey OUTPUT

        -- taqprojectroyaltyrates
        INSERT INTO taqprojectroyaltyrates
          (royaltyratekey, royaltykey, royaltyrate, threshold, lastthresholdind, lastuserid, lastmaintdate)
        VALUES
          (@v_royaltyratekey, @v_royaltykey, @v_royaltyrate, @v_threshold, @v_lastthresholdind, @i_userid, getdate())

        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          CLOSE royaltyrates_cur
          DEALLOCATE royaltyrates_cur        
          CLOSE royalty_cur
          DEALLOCATE royalty_cur
          SET @o_error_desc = 'Could not insert into taqprojectroyaltyrates table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END      

        FETCH royaltyrates_cur 
        INTO @v_royaltyrate, @v_threshold, @v_lastthresholdind
      END

      CLOSE royaltyrates_cur
      DEALLOCATE royaltyrates_cur

      FETCH royalty_cur INTO @v_cur_royaltykey, @v_mediacode, @v_formatcode, @v_saleschannelcode, @v_pricetypeforroyalty
    END

    CLOSE royalty_cur
    DEALLOCATE royalty_cur
  
  RETURN

RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN
  
END
GO

GRANT EXEC ON qcontract_copy_royalties TO PUBLIC
GO
