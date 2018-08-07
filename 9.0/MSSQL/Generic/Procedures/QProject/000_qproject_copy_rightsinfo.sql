if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_rightsinfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_copy_rightsinfo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_copy_rightsinfo
  (@i_from_projectkey integer,
  @i_new_projectkey   integer,
  @i_userid           varchar(30),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/***************************************************************************************
**  Name: qproject_copy_rightsinfo
**  Desc: This stored procedure is called from qproject_copy_project_contract_rights
**        and handles copying Contract rights and territory information.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Kate W.
**  Date: 10 May 2012
****************************************************************************************/

DECLARE
  @v_approvalnote VARCHAR(255),
  @v_authorpercent  INT,
  @v_autoformatdescind  TINYINT,
  @v_autolanguagedescind  TINYINT,
  @v_autoterritorydescind TINYINT,
  @v_consultationnote VARCHAR(255),
  @v_contractterritory  INT,
  @v_currentterritory INT,
  @v_description  VARCHAR(2000),
  @v_error  INT,
  @v_exclusivecode  INT,
  @v_formatdesc VARCHAR(2000),
  @v_forsalehistory VARCHAR(2000),
  @v_itemtype INT,
  @v_languagedesc VARCHAR(2000),
  @v_newrightskey  INT,
  @v_newterritoryrightskey  INT,
  @v_note VARCHAR(255),
  @v_notforsalehistory  VARCHAR(2000),
  @v_rightsdesc VARCHAR(2000),
  @v_rightskey  INT,
  @v_rightslanguagetype INT,
  @v_rightsnote VARCHAR(255),
  @v_rightspermission INT,
  @v_rightstype INT,
  @v_singlecountry  INT,
  @v_singlecountrygroup INT,
  @v_subrightssalecode  INT,
  @v_territoryrightskey INT,
  @v_updatedind TINYINT
	
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
     
  DECLARE rights_cur CURSOR FOR
    SELECT rightskey, rightsdescription, updatedaftercreateind, rightstypecode, rightspermissioncode, 
      autoformatdescind, formatdesc, rightslanguagetypecode, languagedesc, autolanguagedescind, 
      subrightssalecode, rightsnote, approvalnote, consultationnote, authorsubrightspercent
    FROM taqprojectrights  
    WHERE taqprojectkey = @i_from_projectkey

  OPEN rights_cur 	

  FETCH NEXT FROM rights_cur 
  INTO @v_rightskey, @v_rightsdesc, @v_updatedind, @v_rightstype, @v_rightspermission,
    @v_autoformatdescind, @v_formatdesc, @v_rightslanguagetype, @v_languagedesc, @v_autolanguagedescind,
    @v_subrightssalecode, @v_rightsnote, @v_approvalnote, @v_consultationnote, @v_authorpercent

  WHILE (@@FETCH_STATUS = 0)
  BEGIN

    EXEC get_next_key @i_userid, @v_newrightskey OUTPUT
    
    INSERT INTO taqprojectrights
      (rightskey, taqprojectkey, rightsdescription, updatedaftercreateind, rightstypecode, rightspermissioncode, 
      autoformatdescind, formatdesc, rightslanguagetypecode, languagedesc, autolanguagedescind, 
      subrightssalecode, rightsnote, approvalnote, consultationnote, authorsubrightspercent, lastuserid, lastmaintdate)
    VALUES
      (@v_newrightskey, @i_new_projectkey, @v_rightsdesc, @v_updatedind, @v_rightstype, @v_rightspermission,
      @v_autoformatdescind, @v_formatdesc, @v_rightslanguagetype, @v_languagedesc, @v_autolanguagedescind,
      @v_subrightssalecode, @v_rightsnote, @v_approvalnote, @v_consultationnote, @v_authorpercent, @i_userid, getdate())
      
    SELECT @v_error = @@ERROR
    IF @v_error <> 0
    BEGIN
      SET @o_error_desc = 'Insert into taqprojectrights table failed (Error ' + CONVERT(VARCHAR, @v_error) + ').'
      GOTO CURSOR_ERROR
    END
      
    INSERT INTO taqprojectrightsformat
      (rightskey, mediacode, formatcode, lastuserid, lastmaintdate)
    SELECT
      @v_newrightskey, mediacode, formatcode, @i_userid, getdate()
    FROM taqprojectrightsformat
    WHERE rightskey = @v_rightskey
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0
    BEGIN
      SET @o_error_desc = 'Insert into taqprojectrightsformat table failed (Error ' + CONVERT(VARCHAR, @v_error) + ').'
      GOTO CURSOR_ERROR
    END    
     
    INSERT INTO taqprojectrightslanguage
      (rightskey, languagecode, excludeind, lastuserid, lastmaintdate)
    SELECT
      @v_newrightskey, languagecode, excludeind, @i_userid, getdate()
    FROM taqprojectrightslanguage
    WHERE rightskey = @v_rightskey
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0
    BEGIN
      SET @o_error_desc = 'Insert into taqprojectrightslanguage table failed (Error ' + CONVERT(VARCHAR, @v_error) + ').'
      GOTO CURSOR_ERROR
    END
        
    DECLARE territoryrights_cur CURSOR FOR
      SELECT territoryrightskey, itemtype, currentterritorycode, contractterritorycode, description, autoterritorydescind,
        exclusivecode, singlecountrycode, singlecountrygroupcode, note, forsalehistory, notforsalehistory
      FROM territoryrights
      WHERE taqprojectkey = @i_from_projectkey AND rightskey = @v_rightskey
      
    OPEN territoryrights_cur 	

    FETCH NEXT FROM territoryrights_cur 
    INTO @v_territoryrightskey, @v_itemtype, @v_currentterritory, @v_contractterritory, @v_description, @v_autoterritorydescind,
      @v_exclusivecode, @v_singlecountry, @v_singlecountrygroup, @v_note, @v_forsalehistory, @v_notforsalehistory    

    WHILE (@@FETCH_STATUS = 0)
    BEGIN

      EXEC get_next_key @i_userid, @v_newterritoryrightskey OUTPUT   
      
      /* 5/10/12 - KW - From case 17842:
      On the territoryrights and territoryrightcountries table, “updated with subrights” information should not be copied.
      This includes the updatewithsubrightsind on territoryrights, and nonexclusivesubrightsoldind and exclusivesubrightsoldind
      on territoryrightcountries. */
      INSERT INTO territoryrights
        (territoryrightskey, itemtype, taqprojectkey, rightskey, bookkey, 
        currentterritorycode, contractterritorycode, description, autoterritorydescind, exclusivecode, 
        singlecountrycode, singlecountrygroupcode, note, forsalehistory, notforsalehistory, lastuserid, lastmaintdate)
      VALUES
        (@v_newterritoryrightskey, @v_itemtype, @i_new_projectkey, @v_newrightskey, NULL, 
        @v_currentterritory, @v_contractterritory, @v_description, @v_autoterritorydescind, @v_exclusivecode, 
        @v_singlecountry, @v_singlecountrygroup, @v_note, @v_forsalehistory, @v_notforsalehistory, @i_userid, getdate())
   
      SELECT @v_error = @@ERROR
      IF @v_error <> 0
      BEGIN
        CLOSE territoryrights_cur
        DEALLOCATE territoryrights_cur
        SET @o_error_desc = 'Insert into territoryrights table failed (Error ' + CONVERT(VARCHAR, @v_error) + ').'
        GOTO CURSOR_ERROR
      END
       
      INSERT INTO territoryrightcountries
        (territoryrightskey, countrycode, itemtype, taqprojectkey, rightskey, bookkey, 
        forsaleind, contractexclusiveind, currentexclusiveind, lastuserid, lastmaintdate)
      SELECT
        @v_newterritoryrightskey, countrycode, itemtype, @i_new_projectkey, @v_newrightskey, NULL, 
        forsaleind, contractexclusiveind, currentexclusiveind, @i_userid, getdate()
      FROM territoryrightcountries
      WHERE territoryrightskey = @v_territoryrightskey
      
      SELECT @v_error = @@ERROR
      IF @v_error <> 0
      BEGIN
        CLOSE territoryrights_cur
        DEALLOCATE territoryrights_cur
        SET @o_error_desc = 'Insert into territoryrightscountries table failed (Error ' + CONVERT(VARCHAR, @v_error) + ').'
        GOTO CURSOR_ERROR
      END
              
      FETCH NEXT FROM territoryrights_cur 
      INTO @v_territoryrightskey, @v_itemtype, @v_currentterritory, @v_contractterritory, @v_description, @v_autoterritorydescind,
        @v_exclusivecode, @v_singlecountry, @v_singlecountrygroup, @v_note, @v_forsalehistory, @v_notforsalehistory
    END

    CLOSE territoryrights_cur 
    DEALLOCATE territoryrights_cur
          
    FETCH NEXT FROM rights_cur 
    INTO @v_rightskey, @v_rightsdesc, @v_updatedind, @v_rightstype, @v_rightspermission,
      @v_autoformatdescind, @v_formatdesc, @v_rightslanguagetype, @v_languagedesc, @v_autolanguagedescind,
      @v_subrightssalecode, @v_rightsnote, @v_approvalnote, @v_consultationnote, @v_authorpercent
  END

  CLOSE rights_cur 
  DEALLOCATE rights_cur
  
  RETURN
  
  CURSOR_ERROR:
  CLOSE rights_cur
  DEALLOCATE rights_cur
  SET @o_error_code = -1
  RETURN
  
END
GO

GRANT EXEC ON qproject_copy_rightsinfo TO PUBLIC
GO
