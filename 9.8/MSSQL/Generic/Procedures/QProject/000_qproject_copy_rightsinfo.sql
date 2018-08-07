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

/****************************************************************************************************************************
**  Name: qproject_copy_rightsinfo
**  Desc: This stored procedure is called from qproject_copy_project_contract_rights
**        and handles copying Contract rights and territory information.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Kate W.
**  Date: 10 May 2012
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/16/2016   Uday			   Case 37359 Allow "Copy from Project" to be a different class from project being created 
*****************************************************************************************************************************/

DECLARE
  @v_approvalnote VARCHAR(255),
  @v_authorpercent  FLOAT,
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
  @v_updatedind TINYINT,
  @v_newprojectitemtype INT,
  @v_newprojectusageclass INT    
	
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- only want to copy elements types that are defined for the new project
  IF (@i_new_projectkey > 0)
  BEGIN
    SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
    FROM taqproject
    WHERE taqprojectkey = @i_new_projectkey

    IF @v_newprojectitemtype is null or @v_newprojectitemtype = 0
    BEGIN
	    SET @o_error_code = -1
	    SET @o_error_desc = 'Unable to copy royaltyinfo because item type is not populated: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
	    RETURN
    END

    IF @v_newprojectusageclass is null 
      SET @v_newprojectusageclass = 0
  END     
     
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
  
    IF (@v_rightstype IS NOT NULL AND @v_rightstype NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(157, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_rightstype = NULL	
    END  
    
    IF (@v_rightspermission IS NOT NULL AND @v_rightspermission NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(463, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_rightspermission = NULL	
    END  
    
    IF (@v_rightslanguagetype IS NOT NULL AND @v_rightslanguagetype NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(631, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_rightslanguagetype = NULL	
    END    
    
    IF (@v_subrightssalecode IS NOT NULL AND @v_subrightssalecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(632, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_subrightssalecode = NULL	
    END        

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
    WHERE rightskey = @v_rightskey AND
		mediacode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(312, @v_newprojectitemtype, @v_newprojectusageclass)) AND
       (COALESCE(formatcode, 0) = 0 OR formatcode IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(312, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = mediacode))			  
    
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
    WHERE rightskey = @v_rightskey AND
		(COALESCE(languagecode, 0) = 0 OR languagecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(318, @v_newprojectitemtype, @v_newprojectusageclass)))    
    
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
    
      IF (@v_itemtype IS NOT NULL AND @v_itemtype NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(550, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	     SET @v_itemtype = NULL	
      END      
    
      IF (@v_currentterritory IS NOT NULL AND @v_currentterritory NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(634, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	     SET @v_currentterritory = NULL	
      END      
      
      IF (@v_contractterritory IS NOT NULL AND @v_contractterritory NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(634, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	     SET @v_contractterritory = NULL	
      END      
      
      IF (@v_exclusivecode IS NOT NULL AND @v_exclusivecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(574, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	     SET @v_exclusivecode = NULL	
      END        
      
      IF (@v_singlecountry IS NOT NULL AND @v_singlecountry NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(114, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	     SET @v_singlecountry = NULL	
      END   
      
      IF (@v_singlecountrygroup IS NOT NULL AND @v_singlecountrygroup NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(633, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	     SET @v_singlecountrygroup = NULL	
      END              

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
        @v_newterritoryrightskey, countrycode, 
		CASE
		  WHEN (COALESCE(itemtype, 0) = 0 OR itemtype NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(550, @v_newprojectitemtype, @v_newprojectusageclass)))
		  THEN NULL 
		  ELSE itemtype		  
		END as itemtype,         
        @i_new_projectkey, @v_newrightskey, NULL, 
        forsaleind, contractexclusiveind, currentexclusiveind, @i_userid, getdate()
      FROM territoryrightcountries
      WHERE territoryrightskey = @v_territoryrightskey AND
            (countrycode = 0 OR countrycode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(114, @v_newprojectitemtype, @v_newprojectusageclass)))            
      
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
