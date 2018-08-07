if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_project_contract_tasks') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_copy_project_contract_tasks
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_copy_project_contract_tasks
  (@i_copy_projectkey     integer,
  @i_copy2_projectkey     integer,
  @i_new_projectkey       integer,
  @i_userid               varchar(30),
  @i_copydatagroups_list	varchar(max),
  @i_cleardatagroups_list	varchar(max),  
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/***************************************************************************************************************************
**  Name: qproject_copy_project_contract_tasks
**  Desc: This stored procedure handles copying Contract tasks.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Kate W.
**  Date: 5 May 2012
******************************************************************************************************************************
**    Change History
******************************************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   -------------------------------------------------------------------------------------
**   04/06/2016   Kusum        36178     Keys Table at S&S Getting Close to Max Value
**   05/13/2016   Uday		   37359     Allow "Copy from Project" to be a different class from project being created     
******************************************************************************************************************************/

DECLARE
  @v_cleardata  CHAR(1),
  @v_copycontacts CHAR(1),
  @v_counter  INT,
  @v_elementkey INT,
  @v_error INT,
  @v_maxsort  INT,
  @v_new_elementkey INT,
  @v_newkey INT,
  @v_newkeycount  INT,
  @v_sortorder  INT,
  @v_tobecopiedkey  INT,
  @taqprojecttaskoverride_rowcount INT,
  @keyind_var INT,
  @datetypecode INT,
  @o_taqtaskkey   INT,
  @o_returncode   INT,
  @o_restrictioncode INT,
  @v_restriction_value_title INT,
  @v_restriction_value_work  INT,
  @elementtypesubcode_var INT,
  @v_copy_projectkey INT,
  @v_copy2_projectkey INT,
  @v_itemtypecode INT,
  @v_itemtypecode_contract INT,
  @v_userkey  INT,
  @v_count int,  
  @v_newprojectitemtype   INT,
  @v_newprojectusageclass	INT	    
	
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SET @v_copy_projectkey = @i_copy_projectkey
  SET @v_copy2_projectkey = @i_copy2_projectkey

  IF @v_copy_projectkey IS NULL OR @v_copy_projectkey = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Copy projectkey not passed to copy P&L Version.'
    RETURN
  END

  IF @i_new_projectkey IS NULL OR @i_new_projectkey = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'New projectkey not passed to copy P&L Version: copy_projectkey=' + CAST(@v_copy_projectkey AS VARCHAR)   
    RETURN
  END
  
  SET @v_cleardata = dbo.find_integer_in_comma_delim_list(@i_cleardatagroups_list,8)  --Tasks (8)
  SET @v_copycontacts = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,9)  --Contacts (9)  
  
  SELECT @v_itemtypecode_contract = datacode
  FROM gentables WHERE tableid = 550 AND qsicode = 10
  
  IF COALESCE(@i_copy_projectkey, 0) > 0 BEGIN
	SELECT @v_itemtypecode = searchitemcode FROM taqproject WHERE taqprojectkey = @i_copy_projectkey
	
	IF @v_itemtypecode = @v_itemtypecode_contract BEGIN
		SET @v_copy_projectkey = @i_copy2_projectkey
		SET @v_copy2_projectkey = @i_copy_projectkey
	END
  END
  
  -- Get the userkey for the passed User ID
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE userid = @i_userid
	  
  SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
  IF @v_error <> 0 OR @v_count = 0
  BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'Could not get userkey from qsiusers table for UserID: ' + CONVERT(VARCHAR, @i_userid)
	RETURN
  END

  -- only want to copy items types that are defined for the new project
  IF (@i_new_projectkey > 0)
  BEGIN
	SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
	FROM taqproject
	WHERE taqprojectkey = @i_new_projectkey

	IF @v_newprojectitemtype is null or @v_newprojectusageclass = 0
	BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Unable to copy elements because item type is not populated: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
	  RETURN
	END
	  
	IF @v_newprojectusageclass is null 
	  SET @v_newprojectusageclass = 0
  END  
  
  /* 5/7/12 - KW - From case 17842:
  Contract Tasks: copy from i_copy_projectkey all tasks that exist in the Contract Information Tasks view (qsicode=5);  
  add all non-existing tasks (based on date type, element type/subtype, role) from i_copy2_projectkey */
  
  -- First, copy all elements/element tasks for Contract Information Tasks taskview (qsicode=5)
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,7) = 'Y' --Elements (7)
  BEGIN   
    DECLARE contractelements_cur CURSOR FOR
      SELECT DISTINCT taqelementkey 
      FROM taqprojecttask
      WHERE taqprojectkey = @v_copy_projectkey AND
        taqelementkey > 0 AND
        datetypecode IN (SELECT datetypecode FROM taskviewdatetype 
                         WHERE taskviewkey = (SELECT taskviewkey FROM taskview WHERE qsicode = 5)) AND
		datetypecode IN (SELECT DISTINCT datetypecode FROM dbo.qutl_get_datetype_itemtype_filtering(@v_userkey, 'tasktracking', 0, 0, @v_newprojectitemtype, @v_newprojectusageclass))                         

    OPEN contractelements_cur 	

    FETCH NEXT FROM contractelements_cur INTO @v_elementkey

    WHILE (@@FETCH_STATUS = 0)
    BEGIN  
	    EXEC qproject_copy_project_element 
			    @v_copy_projectkey, @v_copy2_projectkey, null, null, @v_elementkey, @i_new_projectkey, null, null, 
			    @i_userid, @i_copydatagroups_list, @i_cleardatagroups_list,
			    @v_new_elementkey OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

	    IF @o_error_code <> 0 BEGIN
        SET @o_error_desc = 'Copy contract elements/element tasks failed (taqprojectkey=' + CAST(@v_copy_projectkey AS VARCHAR) + ', taqelementkey=' + CAST(@v_elementkey AS VARCHAR) + ')'
        RETURN
      END

      FETCH NEXT FROM contractelements_cur INTO @v_elementkey
    END

    CLOSE contractelements_cur 
    DEALLOCATE contractelements_cur
  END
  
  -- Now copy the non-element tasks for Contract Information Tasks taskview (qsicode=5)
  SELECT @v_newkeycount = COUNT(*), @v_tobecopiedkey = MIN(taqtaskkey), @v_maxsort = MAX(sortorder)
  FROM taqprojecttask
  WHERE taqprojectkey = @v_copy_projectkey AND
    taqelementkey IS NULL AND
    datetypecode IN (SELECT datetypecode FROM taskviewdatetype 
                     WHERE taskviewkey = (SELECT taskviewkey FROM taskview WHERE qsicode = 5)) AND
    datetypecode IN (SELECT DISTINCT datetypecode FROM dbo.qutl_get_datetype_itemtype_filtering(@v_userkey, 'tasktracking', 0, 0, @v_newprojectitemtype, @v_newprojectusageclass))

  SET @v_counter = 1
  WHILE @v_counter <= @v_newkeycount
  BEGIN
	select @taqprojecttaskoverride_rowcount = count(*)
	from taqprojecttaskoverride
	where taqtaskkey = @v_tobecopiedkey

    SET @o_returncode = 0
    SET @o_taqtaskkey = 0
    SET @datetypecode = NULL

    SELECT @datetypecode = datetypecode, @keyind_var = keyind 
	 FROM taqprojecttask
	 WHERE taqprojectkey = @v_copy_projectkey
	  and taqtaskkey = @v_tobecopiedkey
	  and taqelementkey is null

    SELECT @v_restriction_value_work = 1
    select @v_restriction_value_work = relateddatacode
	from gentablesitemtype
    where tableid = 323
	 and datacode = @datetypecode
	 and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
	 and itemtypecode = (select searchitemcode from coreprojectinfo where projectkey = @i_new_projectkey)
	 and itemtypesubcode in (select usageclasscode from coreprojectinfo where projectkey = @i_new_projectkey)

	IF (@i_new_projectkey IS NOT NULL AND @i_new_projectkey > 0 AND @datetypecode IS NOT NULL) BEGIN
	   exec dbo.qutl_check_for_restrictions @datetypecode, NULL, NULL, @i_new_projectkey, NULL, NULL, NULL, 
         @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
	   IF @o_error_code <> 0 BEGIN
	      SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
		  RETURN
	   END
	   IF (@o_returncode = 3 AND @v_restriction_value_work = 3 AND @keyind_var  = 0) BEGIN
		  SET @o_returncode = 0
	   END
	END 

	if (@taqprojecttaskoverride_rowcount = 0 AND @o_returncode = 0)
	begin
		EXEC get_next_key 'taqprojecttask', @v_newkey OUTPUT

		INSERT INTO taqprojecttask
		  (taqtaskkey, taqprojectkey, taqelementkey, bookkey, orgentrykey, 
		  globalcontactkey, rolecode, globalcontactkey2, rolecode2, 
		  scheduleind, stagecode, duration, datetypecode, keyind, 
		  activedate, actualind, originaldate, 
		  taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, taqprojectformatkey,
		  lastuserid, lastmaintdate, lockind, transactionkey)
		SELECT @v_newkey, @i_new_projectkey, NULL, bookkey, orgentrykey, 
		  CASE WHEN @v_copycontacts = 'N' THEN NULL ELSE globalcontactkey END, 
		  CASE
			WHEN (COALESCE(rolecode, 0) = 0 OR rolecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE rolecode		  
		  END as rolecode, 
		  CASE WHEN @v_copycontacts = 'N' THEN NULL ELSE globalcontactkey2 END, 
		  CASE
			WHEN (COALESCE(rolecode2, 0) = 0 OR rolecode2 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE rolecode2				
		  END as rolecode2, 
		  scheduleind, 
		  CASE
			WHEN (COALESCE(stagecode, 0) = 0 OR stagecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(587, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE stagecode				
		  END as stagecode, 
		  duration, datetypecode, keyind, 
		  CASE WHEN @v_cleardata = 'Y' THEN NULL ELSE activedate END, 
		  CASE WHEN @v_cleardata = 'Y' THEN NULL ELSE actualind END, 
		  CASE WHEN @v_cleardata = 'Y' THEN NULL ELSE originaldate END,
		  taqtasknote, 
		  CASE
			WHEN (COALESCE(decisioncode, 0) = 0 OR decisioncode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(533, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE decisioncode		  
		  END as decisioncode, 
		  paymentamt, taqtaskqty, sortorder, taqprojectformatkey,
		  @i_userid, getdate(), lockind, transactionkey
		FROM taqprojecttask
		WHERE taqprojectkey = @v_copy_projectkey AND taqtaskkey = @v_tobecopiedkey

		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Copy/insert into taqprojecttask failed (' + cast(@v_error AS VARCHAR) + '): taqprojectkey=' + cast(@v_copy_projectkey AS VARCHAR)   
		  RETURN
		END 
	END

    SET @v_counter = @v_counter + 1
    
    SELECT @v_tobecopiedkey = MIN(taqtaskkey)
    FROM taqprojecttask
    WHERE taqprojectkey = @v_copy_projectkey AND
      taqtaskkey > @v_tobecopiedkey AND
      taqelementkey IS NULL AND
      datetypecode IN (SELECT datetypecode FROM taskviewdatetype 
                       WHERE taskviewkey = (SELECT taskviewkey FROM taskview WHERE qsicode = 5)) AND
      datetypecode IN (SELECT DISTINCT datetypecode FROM dbo.qutl_get_datetype_itemtype_filtering(@v_userkey, 'tasktracking', 0, 0, @v_newprojectitemtype, @v_newprojectusageclass))    
  END
  
  -- Finally, if second projectkey is passed in, copy all tasks from i_copy2_projectkey not already copied above
  -- (based on date type, element type/subtype, role)
  -- NOTE: need to process element tasks and non-element tasks in 2 separate steps
  IF @v_copy2_projectkey > 0
  BEGIN
    -- element tasks
    IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,7) = 'Y' --Elements (7)
    BEGIN   
      DECLARE otherelements_cur CURSOR FOR
        SELECT DISTINCT t1.taqelementkey 
        FROM taqprojecttask t1 
	        JOIN taqprojectelement e1 ON t1.taqprojectkey = e1.taqprojectkey AND t1.taqelementkey = e1.taqelementkey
        WHERE t1.taqprojectkey = @v_copy2_projectkey AND 
          t1.taqelementkey > 0 AND
          NOT EXISTS (SELECT * FROM taqprojecttask t2 
                        JOIN taqprojectelement e2 ON t2.taqprojectkey = e2.taqprojectkey AND t2.taqelementkey = e2.taqelementkey
                      WHERE t1.datetypecode = t2.datetypecode AND
                        (t1.rolecode = t2.rolecode OR (t1.rolecode is null and t2.rolecode is null)) AND
                        e1.taqelementtypecode = e2.taqelementtypecode AND
                        e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
                        t2.taqelementkey > 0 AND
                        t2.taqprojectkey = @v_copy_projectkey) AND
         datetypecode IN (SELECT DISTINCT datetypecode FROM dbo.qutl_get_datetype_itemtype_filtering(@v_userkey, 'tasktracking', 0, 0, @v_newprojectitemtype, @v_newprojectusageclass))                            

      OPEN otherelements_cur 	

      FETCH NEXT FROM otherelements_cur INTO @v_elementkey

      WHILE (@@FETCH_STATUS = 0)
      BEGIN  
	      EXEC qproject_copy_project_element 
			      @v_copy_projectkey, @v_copy2_projectkey, null, null, @v_elementkey, @i_new_projectkey, null, null, 
			      @i_userid, @i_copydatagroups_list, @i_cleardatagroups_list,
			      @v_new_elementkey OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

	      IF @o_error_code <> 0 BEGIN
          SET @o_error_desc = 'Copy contract elements/element tasks failed (taqprojectkey=' + CAST(@v_copy2_projectkey AS VARCHAR) + ', taqelementkey=' + CAST(@v_elementkey AS VARCHAR) + ')'
          RETURN
        END

        FETCH NEXT FROM otherelements_cur INTO @v_elementkey
      END

      CLOSE otherelements_cur 
      DEALLOCATE otherelements_cur
    END
    
    -- non-element tasks
    SELECT @v_newkeycount = COUNT(*), @v_tobecopiedkey = MIN(t1.taqtaskkey)
    FROM taqprojecttask t1
    WHERE t1.taqprojectkey = @v_copy2_projectkey AND
      t1.taqelementkey IS NULL AND
      NOT EXISTS (SELECT * FROM taqprojecttask t2 
                  WHERE t1.datetypecode = t2.datetypecode AND
                    (t1.rolecode = t2.rolecode OR (t1.rolecode IS NULL AND t2.rolecode IS NULL)) AND
                    t2.taqprojectkey = @i_new_projectkey) AND
    datetypecode IN (SELECT DISTINCT datetypecode FROM dbo.qutl_get_datetype_itemtype_filtering(@v_userkey, 'tasktracking', 0, 0, @v_newprojectitemtype, @v_newprojectusageclass))                                               
                    
    SET @v_counter = 1
    
    WHILE @v_counter <= @v_newkeycount
    BEGIN
	  select @taqprojecttaskoverride_rowcount = count(*)
	  from taqprojecttaskoverride
	  where taqtaskkey = @v_tobecopiedkey

      SET @o_returncode = 0
      SET @o_taqtaskkey = 0
      SET @datetypecode = NULL

      SELECT @datetypecode = datetypecode, @keyind_var = keyind 
		  FROM taqprojecttask
		  WHERE taqprojectkey = @v_copy2_projectkey
			and taqtaskkey = @v_tobecopiedkey
			and taqelementkey is null

      SELECT @v_restriction_value_work = 1
      select @v_restriction_value_work = relateddatacode
	  from gentablesitemtype
      where tableid = 323
	   and datacode = @datetypecode
	   and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
	   and itemtypecode = (select searchitemcode from coreprojectinfo where projectkey = @i_new_projectkey)
	   and itemtypesubcode in (select usageclasscode from coreprojectinfo where projectkey = @i_new_projectkey)

	  IF (@i_new_projectkey IS NOT NULL AND @i_new_projectkey > 0 AND @datetypecode IS NOT NULL) BEGIN
	     exec dbo.qutl_check_for_restrictions @datetypecode, NULL, NULL, @i_new_projectkey, NULL, NULL, NULL, 
           @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
	     IF @o_error_code <> 0 BEGIN
		    SET @o_error_code = -1
		    SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
		    RETURN
	     END
	     IF (@o_returncode = 3 AND @v_restriction_value_work = 3 AND @keyind_var  = 0) BEGIN
		    SET @o_returncode = 0
	     END
	  END 

	  if (@taqprojecttaskoverride_rowcount = 0 AND @o_returncode = 0)
	  begin
		  EXEC get_next_key 'taqprojecttask', @v_newkey OUTPUT

		  INSERT INTO taqprojecttask
			(taqtaskkey, taqprojectkey, taqelementkey, bookkey, orgentrykey, 
			globalcontactkey, rolecode, globalcontactkey2, rolecode2, 
			scheduleind, stagecode, duration, datetypecode, keyind, 
			activedate, actualind, originaldate, 
			taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, taqprojectformatkey,
			lastuserid, lastmaintdate, lockind, transactionkey)
		  SELECT @v_newkey, @i_new_projectkey, NULL, bookkey, orgentrykey, 
			CASE WHEN @v_copycontacts = 'N' THEN NULL ELSE globalcontactkey END, 
		    CASE
			  WHEN (COALESCE(rolecode, 0) = 0 OR rolecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			  THEN NULL 
			  ELSE rolecode		  
		    END as rolecode, 
			CASE WHEN @v_copycontacts = 'N' THEN NULL ELSE globalcontactkey2 END, 
		    CASE
			  WHEN (COALESCE(rolecode2, 0) = 0 OR rolecode2 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			  THEN NULL 
			  ELSE rolecode2				
		    END as rolecode2,  
			scheduleind, 
		    CASE
			  WHEN (COALESCE(stagecode, 0) = 0 OR stagecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(587, @v_newprojectitemtype, @v_newprojectusageclass)))
			  THEN NULL 
			  ELSE stagecode				
		    END as stagecode, 
			duration, datetypecode, keyind, 
			CASE WHEN @v_cleardata = 'Y' THEN NULL ELSE activedate END, 
			CASE WHEN @v_cleardata = 'Y' THEN NULL ELSE actualind END, 
			CASE WHEN @v_cleardata = 'Y' THEN NULL ELSE originaldate END,
			taqtasknote, 
		    CASE
			  WHEN (COALESCE(decisioncode, 0) = 0 OR decisioncode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(533, @v_newprojectitemtype, @v_newprojectusageclass)))
			  THEN NULL 
			  ELSE decisioncode		  
		    END as decisioncode, 
			paymentamt, taqtaskqty, @v_sortorder, taqprojectformatkey,
			@i_userid, getdate(), lockind, transactionkey
		  FROM taqprojecttask
		  WHERE taqprojectkey = @v_copy2_projectkey AND taqtaskkey = @v_tobecopiedkey

		  SELECT @v_error = @@ERROR
		  IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Copy/insert into taqprojecttask failed (' + cast(@v_error AS VARCHAR) + '): taqprojectkey=' + cast(@v_copy2_projectkey AS VARCHAR)   
			RETURN
		  END
	  end 

      SET @v_counter = @v_counter + 1
      SET @v_sortorder = @v_sortorder + 1
        
      SELECT @v_tobecopiedkey = MIN(taqtaskkey)
      FROM taqprojecttask t1
      WHERE t1.taqprojectkey = @v_copy2_projectkey AND
        t1.taqtaskkey > @v_tobecopiedkey AND
        t1.taqelementkey IS NULL AND
        NOT EXISTS (SELECT * FROM taqprojecttask t2 
                    WHERE t1.datetypecode = t2.datetypecode AND
                      (t1.rolecode = t2.rolecode OR (t1.rolecode IS NULL AND t2.rolecode IS NULL)) AND
                      t2.taqprojectkey = @i_new_projectkey) AND
       datetypecode IN (SELECT DISTINCT datetypecode FROM dbo.qutl_get_datetype_itemtype_filtering(@v_userkey, 'tasktracking', 0, 0, @v_newprojectitemtype, @v_newprojectusageclass))                                                    
    END    
  END

END
GO

GRANT EXEC ON qproject_copy_project_contract_tasks TO PUBLIC
GO
