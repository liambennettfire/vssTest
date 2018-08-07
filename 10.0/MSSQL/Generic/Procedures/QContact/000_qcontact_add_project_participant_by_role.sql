if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_add_project_participant_by_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_add_project_participant_by_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcontact_add_project_participant_by_role
  (@i_projectkey integer,
  @i_globalcontactkey integer, 
  @i_keyind tinyint,
  @i_addresskey integer, 
  @i_participantnote VARCHAR(2000), 
  @i_generictext varchar(50),
  @i_sortorder smallint, 
  @i_rolecode integer, 
  @i_globalcontactrelationshipkey int, 
  @i_quantity integer, 
  @i_indicator tinyint, 
  @i_shippingmethodcode integer, 
  @i_activedate datetime,
  @i_participantbyroledatacode integer,
  @i_taqversionformatkey integer,
  @i_userid varchar(30),
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_add_project_participant_by_role
**  Desc: This stored procedure adds record for Project Participant by Role Section
**
**    Auth: Uday A. Khisty
**    Date: 09/04/14
**
FYI: Addition of task date with restrictions to be done
**
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:          Author:        Description:
**  -----------    -----------    -------------------------------------------
**  02/11/2014     Kusum          Case 31547
**  10/19/2016     Colman         Case 40069 Participant by Role Enhancements (Shipping Locations)
**  05/03/2018     Colman         Case 50385 Add text field to Participant by Role section 
**  06/27/2018     Colman         Case 51811 add date to uniqueness check for shipping locations 
*******************************************************************************/

DECLARE
  @v_userkey INT,
  @v_error  INT,
  @v_rowcount INT,    
  @v_taqprojectcontactkey INT,
  @v_datetypecode INT,
  @v_taskkeyindicator INT,
  @v_elementtypesubcode_var INT,
  @v_taqprojectcontactrolekey INT,
  @v_itemtypecode_for_printing INT,
  @v_usageclasscode_for_printing INT, 
  @v_itemtypecode INT,
  @v_usageclasscode INT, 
  @v_bookkey INT,
  @v_printingkey INT,
  @v_taqtaskkey INT,
  @o_taqtaskkey   INT,
  @o_returncode   INT,
  @o_restrictioncode INT,
  @v_restriction_value_title INT,
  @v_restriction_value_work  INT,
  @v_shipping_location_rolecode  INT,
  @v_shipping_location_rarely_used_rolecode  INT,
  @v_count INT  
  
BEGIN

  -- declare @activedate varchar(max)
  -- set @activedate = cast(@i_activedate as varchar)
  -- exec qutl_trace 'qcontact_add_project_participant_by_role',
    -- '@i_projectkey', @i_projectkey, NULL,
    -- '@i_globalcontactkey', @i_globalcontactkey, NULL,
    -- '@i_rolecode', @i_rolecode, NULL,
    -- '@i_globalcontactrelationshipkey', @i_globalcontactrelationshipkey, NULL,
    -- '@i_activedate', NULL, @activedate,
    -- '@i_participantbyroledatacode', @i_participantbyroledatacode, NULL,
    -- '@i_taqversionformatkey', @i_taqversionformatkey, NULL,
    -- '@i_indicator', @i_indicator, NULL,
    -- '@i_keyind', @i_keyind, NULL

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  SET @v_bookkey = 0
  SET @v_printingkey = 0
  /** Get userkey for the given userid passed **/
  SELECT @v_userkey = userkey
    FROM qsiusers
    WHERE Upper(userid) = Upper(@i_userid)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1  
    SET @o_error_desc = 'Error getting userkey for userid ' + CAST(@i_userid AS VARCHAR) + '.'
  END  
  
  SELECT @v_itemtypecode = searchitemcode, @v_usageclasscode = usageclasscode 
    FROM coreprojectinfo 
    WHERE projectkey = @i_projectkey    
  
  SELECT @v_itemtypecode_for_printing = datacode, @v_usageclasscode_for_printing = datasubcode 
    FROM subgentables 
    where tableid = 550 AND qsicode = 40  

  SELECT @v_shipping_location_rolecode = datacode
    FROM gentables
    WHERE tableid = 285 AND qsicode = 17  
    
  SELECT @v_shipping_location_rarely_used_rolecode = datacode
    FROM gentables
    WHERE tableid = 285 AND qsicode = 18  
  
  SELECT @v_datetypecode = relateddatacode, @v_taskkeyindicator = indicator1 
  FROM gentablesitemtype 
  WHERE tableid = 636 
    AND datacode = @i_participantbyroledatacode 
    AND datasubcode = 11 
    AND itemtypecode = @v_itemtypecode 
    AND itemtypesubcode IN (0, @v_usageclasscode) 
    
  IF @v_itemtypecode = @v_itemtypecode_for_printing BEGIN
    SELECT @v_bookkey = bookkey, @v_printingkey = printingkey 
    FROM taqprojectprinting_view 
    WHERE taqprojectkey = @i_projectkey
  END    

  select * from qsiusers where userid = @i_userid
  IF (@i_rolecode = @v_shipping_location_rolecode) OR (@i_rolecode = @v_shipping_location_rarely_used_rolecode) 
  BEGIN
    IF NOT EXISTS (SELECT 1
      FROM dbo.qproject_get_participants_by_role_fn(@v_userkey, @i_projectkey, @i_participantbyroledatacode, NULL, NULL)
        WHERE globalcontactkey = @i_globalcontactkey
          AND globalcontactrelationshipkey = @i_globalcontactrelationshipkey
          AND shippingmethodcode = @i_shippingmethodcode
          AND COALESCE(taqversionformatkey,0) = @i_taqversionformatkey
          AND activedate = @i_activedate)
    BEGIN
      EXEC get_next_key @i_userid, @v_taqprojectcontactkey OUTPUT
        
      INSERT INTO taqprojectcontact
        (taqprojectcontactkey, taqprojectkey, globalcontactkey, participantnote, 
        keyind, sortorder, lastuserid, lastmaintdate, addresskey)
      VALUES(@v_taqprojectcontactkey, @i_projectkey, @i_globalcontactkey, @i_participantnote,
        @i_keyind, @i_sortorder, @i_userid, GETDATE(), @i_addresskey)
          
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Insert into taqprojectcontact failed (' + cast(@v_error AS VARCHAR) + '): globalcontactkey=' + cast(@i_globalcontactkey AS VARCHAR)   
        RETURN
      END       

      EXEC get_next_key @i_userid, @v_taqprojectcontactrolekey OUTPUT

      INSERT INTO taqprojectcontactrole
        (taqprojectcontactrolekey, taqprojectcontactkey, taqprojectkey, rolecode, activeind,
        quantity, shippingmethodcode, globalcontactrelationshipkey, indicator, taqversionformatkey, generictext, lastuserid, lastmaintdate)
      VALUES(@v_taqprojectcontactrolekey, @v_taqprojectcontactkey, @i_projectkey, @i_rolecode, 1,
        @i_quantity, @i_shippingmethodcode, @i_globalcontactrelationshipkey, @i_indicator, @i_taqversionformatkey, @i_generictext, @i_userid, GETDATE())  
            
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Copy into taqprojectcontactrole failed (' + cast(@v_error AS VARCHAR) + '): taqprojectcontactkey=' + cast(@v_taqprojectcontactkey AS VARCHAR)
        RETURN
      END  
    END
  END --IF @i_rolecode =   @v_shipping_location_rolecode OR @v_shipping_location_rarely_used_rolecode
  ELSE
  BEGIN
    IF EXISTS(SELECT * FROM taqprojectcontact WHERE taqprojectkey = @i_projectkey AND globalcontactkey = @i_globalcontactkey) 
    BEGIN
      SELECT TOP(1) @v_taqprojectcontactkey = taqprojectcontactkey 
      FROM taqprojectcontact 
      WHERE taqprojectkey = @i_projectkey AND globalcontactkey = @i_globalcontactkey

      UPDATE taqprojectcontact 
      SET keyind = @i_keyind, participantnote = @i_participantnote, sortorder = @i_sortorder, lastuserid = @i_userid, lastmaintdate = GETDATE(), addresskey = @i_addresskey
      WHERE taqprojectcontactkey = @v_taqprojectcontactkey

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Update of taqprojectcontact failed (' + cast(@v_error AS VARCHAR) + '): globalcontactkey=' + cast(@i_globalcontactkey AS VARCHAR)   
        RETURN
      END        
    END
    ELSE BEGIN
      EXEC get_next_key @i_userid, @v_taqprojectcontactkey OUTPUT
          
      INSERT INTO taqprojectcontact
        (taqprojectcontactkey, taqprojectkey, globalcontactkey, participantnote, 
        keyind, sortorder, lastuserid, lastmaintdate, addresskey)
      VALUES(@v_taqprojectcontactkey, @i_projectkey, @i_globalcontactkey, @i_participantnote,
        @i_keyind, @i_sortorder, @i_userid, GETDATE(), @i_addresskey)
            
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Insert into taqprojectcontact failed (' + cast(@v_error AS VARCHAR) + '): globalcontactkey=' + cast(@i_globalcontactkey AS VARCHAR)   
        RETURN
      END                      
    END

    IF NOT EXISTS (SELECT * FROM taqprojectcontactrole WHERE taqprojectcontactkey = @v_taqprojectcontactkey AND 
           taqprojectkey = @i_projectkey AND rolecode = @i_rolecode) 
    BEGIN
      EXEC get_next_key @i_userid, @v_taqprojectcontactrolekey OUTPUT

      INSERT INTO taqprojectcontactrole
        (taqprojectcontactrolekey, taqprojectcontactkey, taqprojectkey, rolecode, activeind,
        quantity, shippingmethodcode, globalcontactrelationshipkey, indicator, taqversionformatkey, generictext, lastuserid, lastmaintdate)
      VALUES (@v_taqprojectcontactrolekey, @v_taqprojectcontactkey, @i_projectkey, @i_rolecode, 1,
        @i_quantity, @i_shippingmethodcode, @i_globalcontactrelationshipkey, @i_indicator, @i_taqversionformatkey, @i_generictext, @i_userid, GETDATE())  
          
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Copy into taqprojectcontactrole failed (' + cast(@v_error AS VARCHAR) + '): taqprojectcontactkey=' + cast(@v_taqprojectcontactkey AS VARCHAR)
        RETURN
      END  
    END
  END  
  -- FOR NOW we are not doing "Ship Date" - So we are not showing the column.
  
--IF COALESCE(@v_bookkey,0) > 0 AND COALESCE(@v_printingkey, 0) > 0 BEGIN  // For Title
--    SELECT @v_itemtypecode = itemtypecode, @v_usageclasscode = usageclasscode 
--    FROM coretitleinfo 
--    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey   
    
--      select @v_restriction_value_title = relateddatacode
--      from gentablesitemtype
--      where tableid = 323
--        and datacode = @v_datetypecode
--        and COALESCE(datasubcode,0) in (@v_elementtypesubcode_var,0)
--        and itemtypecode = @v_itemtypecode
--        and itemtypesubcode in (@v_usageclasscode, 0)
      
--      IF (@i_new_bookkey IS NOT NULL AND @i_new_bookkey > 0 AND @datetypecode IS NOT NULL) BEGIN
--        exec dbo.qutl_check_for_restrictions @datetypecode, @v_bookkey, @v_printingkey, NULL, NULL, NULL, NULL, 
--          @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
--        IF @o_error_code <> 0 BEGIN
--          SET @o_error_code = -1
--          SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
--          GOTO ExitHandler
--        END
--        IF (@o_returncode = 2 AND @v_restriction_value_title = 3 AND @keyind_var  = 0) BEGIN
--          SET @o_returncode = 0
--        END
--      END     
      
--      IF @o_returncode = 0 BEGIN 
--        IF @insert_in_taqprojecttask = 1 BEGIN
--          INSERT INTO taqprojecttask
--            (taqtaskkey, taqprojectkey, taqelementkey, bookkey, printingkey, orgentrykey, 
--            globalcontactkey, rolecode, globalcontactkey2, rolecode2, 
--            scheduleind, stagecode, duration, datetypecode, keyind,
--            activedate, actualind, originaldate, 
--            taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, 
--            taqprojectformatkey, lastuserid, lastmaintdate, lockind,
--            startdate,startdateactualind,lag, transactionkey)
--          VALUES()  

--          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
--          IF @error_var <> 0 BEGIN
--            SET @o_error_code = -1
--            SET @o_error_desc = 'copy/insert into taqprojecttask failed (' + cast(@error_var AS VARCHAR) + '): taqtaskkey = ' + cast(@tobecopiedkey AS VARCHAR)   
--            GOTO ExitHandler
--          END 
--        END     
--END
--ELSE BEGIN  // for Project
  
--END
  
END
GO

GRANT EXEC ON qcontact_add_project_participant_by_role TO PUBLIC
GO


