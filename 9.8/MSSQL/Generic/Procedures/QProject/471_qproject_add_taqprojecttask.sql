if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_add_taqprojecttask') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_add_taqprojecttask
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_add_taqprojecttask
  (@i_projectkey  integer,
  @i_taqelementkey  integer,
  @i_globalcontactkey integer,
  @i_rolecode integer,
  @i_datetypecode integer,
  @i_keyind integer,
  @i_userid varchar(30),
  @i_taskviewkey integer,
  @i_bookkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_add_taqprojecttask
**  Desc: This stored procedure adds a new row to taqprojecttask table.
**
**    Auth: Kate
**    Date: 10/7/04
********************************************************************************
**    Change History
********************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   04/06/2016   Kusum        36178     Keys Table at S&S Getting Close to Max Value
**   
******************************************************************************************/


  DECLARE
    @v_count  INT,
    @v_creationdatecode  INT,
    @v_itemtype INT,
    @v_usageclass INT,
    @v_keyind TINYINT,
    @v_taqtaskkey INT,
    @v_error  INT,
    @v_rowcount INT ,
    @v_rolecode INT,
    @v_rolecode2 INT,
    @v_globalcontactkey INT,
    @v_globalcontactkey2 INT,
    @v_cnt INT,
    @v_printingkey INT,
    @v_projectkeylist varchar(max),
    @v_bookkeylist  varchar(max),
    @v_projectkey INT,
    @v_bookkey INT,
    @v_qsicode_project INT,
    @v_use_bookkey_printingkey_instead_of_projectkey INT,
    @o_taqtaskkey   INT,
    @o_returncode   INT,
    @o_restrictioncode INT,
    @v_restriction_value INT  

  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_returncode = 0
  
  SET @v_projectkey = @i_projectkey
  SET @v_bookkey = @i_bookkey
  SET @v_qsicode_project = 0
  SET @v_use_bookkey_printingkey_instead_of_projectkey = 0
  SET @v_taqtaskkey = NULL
    
  /* Get the client datetypecode for Creation Date (qsicode=10) */  
  SELECT @v_count = COUNT(*)
  FROM datetype WHERE qsicode = 10
  
  SET @v_creationdatecode = 0
  IF @v_count > 0
    SELECT @v_creationdatecode = datetypecode
    FROM datetype WHERE qsicode = 10
  
  SET @v_printingkey = null
  IF @i_bookkey > 0 BEGIN
    SET @v_printingkey = 1
  END
  
  SET @v_projectkeylist = ''
  IF @i_projectkey > 0 BEGIN
    SET @v_projectkeylist = CAST(@i_projectkey as VARCHAR)
  END
  
  SET @v_bookkeylist = ''
  IF @i_bookkey > 0 BEGIN
    SET @v_bookkeylist = CAST(@i_bookkey as VARCHAR)
  END  
  
  IF COALESCE(@v_projectkey, 0) > 0 BEGIN
      SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
      FROM taqproject
      WHERE taqprojectkey = @v_projectkey	
      
	  SELECT @v_qsicode_project = COALESCE(qsicode, 0)
	  FROM subgentables  
	  WHERE tableid = 550 AND datacode = @v_itemtype AND datasubcode = @v_usageclass 
	  
	  IF @v_qsicode_project = 40 BEGIN -- Printing
		IF EXISTS (SELECT * FROM taqprojectprinting_view WHERE taqprojectkey = @v_projectkey) BEGIN
			SELECT @v_bookkey = bookkey, @v_printingkey = printingkey  FROM taqprojectprinting_view WHERE taqprojectkey = @v_projectkey
			SET @v_projectkey = NULL
			SET @v_use_bookkey_printingkey_instead_of_projectkey = 1		
		END
	  END     
  END  
  
 -- IF @v_qsicode_project = 40 AND @v_projectkey IS NOT NULL BEGIN
	--RETURN
 -- END
    
  IF (COALESCE(@v_projectkey, 0) > 0 AND @i_datetypecode IS NOT NULL) BEGIN
	 exec dbo.qutl_check_for_restrictions @i_datetypecode, NULL, NULL, @v_projectkey, NULL, NULL, NULL,
	 @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
	   RETURN
	 END
	 IF (@o_returncode > 0 AND @o_restrictioncode = 3 AND @i_keyind = 0) BEGIN
	   SET @o_returncode = 0
	 END
  END 
  ELSE IF (COALESCE(@v_bookkey, 0) > 0 AND @i_datetypecode IS NOT NULL) BEGIN
	 exec dbo.qutl_check_for_restrictions @i_datetypecode, @v_bookkey, @v_printingkey, NULL, NULL, NULL, NULL,
	 @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
	   RETURN
	 END
	 IF (@o_returncode > 0 AND @o_restrictioncode = 3 AND @i_keyind = 0) BEGIN
	   SET @o_returncode = 0
	 END
  END    
  
  IF @o_returncode <> 0 BEGIN
	RETURN
  END 
  
  /* Generate new taqtaskkey for taqprojecttask table */
  EXEC get_next_key 'taqprojecttask', @v_taqtaskkey OUTPUT
  
  IF @v_taqtaskkey IS NOT NULL BEGIN  
    SET @v_globalcontactkey = @i_globalcontactkey
    SET @v_rolecode = @i_rolecode

    SET @v_globalcontactkey2 = null
    SET @v_rolecode2 = null
            
    /***** ADD new row to TAQPROJECTTASK table ****/
    IF @i_taskviewkey > 0 AND @i_datetypecode > 0 BEGIN      
      IF @v_rolecode = 0 BEGIN
        SET @v_rolecode = null
      END

      SELECT @v_rolecode = COALESCE(@v_rolecode,rolecode),
             @v_rolecode2 = COALESCE(rolecode2,0)
        FROM taskviewdatetype
       WHERE taskviewkey = @i_taskviewkey
         AND datetypecode = @i_datetypecode
    
      -- If there is only 1 contact for the role, auto select that one         
      IF COALESCE(@v_globalcontactkey,0) <= 0 BEGIN
        IF @v_rolecode > 0 BEGIN
          SELECT @v_cnt = count(*)
            FROM dbo.qproject_build_task_contactlist(@v_projectkeylist,'',@v_bookkeylist,@v_rolecode)
            
          IF @v_cnt = 1 BEGIN
            SELECT @v_globalcontactkey = contactkey
              FROM dbo.qproject_build_task_contactlist(@v_projectkeylist,'',@v_bookkeylist,@v_rolecode)
              
            SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
            IF @v_error <> 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'error retrieving default contact for role'
              RETURN  
            END   
          END            
        END
      END
      
      IF @v_rolecode2 > 0 BEGIN
        SELECT @v_cnt = count(*)
          FROM dbo.qproject_build_task_contactlist(@v_projectkeylist,'',@v_bookkeylist,@v_rolecode2)
          
        IF @v_cnt = 1 BEGIN
          SELECT @v_globalcontactkey2 = contactkey
            FROM dbo.qproject_build_task_contactlist(@v_projectkeylist,'',@v_bookkeylist,@v_rolecode2)
            
          SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
          IF @v_error <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'error retrieving default contact for role2'
            RETURN  
          END   
        END            
      END        
   
      INSERT INTO taqprojecttask (taqtaskkey,taqprojectkey,taqelementkey,bookkey,printingkey,
             globalcontactkey,rolecode,rolecode2,globalcontactkey2,scheduleind,stagecode,duration,
             datetypecode,activedate,actualind,keyind,originaldate,taqtasknote,
             decisioncode,paymentamt,taqtaskqty,sortorder,lastuserid,lastmaintdate, lag)
      SELECT @v_taqtaskkey,@v_projectkey,@i_taqelementkey,@v_bookkey,@v_printingkey,@v_globalcontactkey,
             COALESCE(@v_rolecode,tvd.rolecode),@v_rolecode2,@v_globalcontactkey2,tvd.scheduleind,tvd.stagecode,
			 CASE
				WHEN COALESCE(tvd.duration, 0) = 0 THEN 
				     d.defaultduration
				ELSE tvd.duration
			 END duration,              
             @i_datetypecode,tvd.defaultdate,0,@i_keyind,tvd.defaultdate,tvd.defaultnote,tvd.decisioncode,
             tvd.paymentamt,tvd.defaultqty,tvd.sortorder,@i_userid,getdate(), tvd.lag
        FROM taskviewdatetype tvd ,datetype d
       WHERE taskviewkey = @i_taskviewkey
         AND tvd.datetypecode = @i_datetypecode
         AND tvd.datetypecode = d.datetypecode         
    END
    ELSE BEGIN
      IF COALESCE(@v_globalcontactkey,0) <= 0 BEGIN
        -- If there is only 1 contact for the role, auto select that one           
        IF @v_rolecode > 0 BEGIN
          SELECT @v_cnt = count(*)
            FROM dbo.qproject_build_task_contactlist(@v_projectkeylist,'',@v_bookkeylist,@v_rolecode)
            
          IF @v_cnt = 1 BEGIN
            SELECT @v_globalcontactkey = contactkey
              FROM dbo.qproject_build_task_contactlist(@v_projectkeylist,'',@v_bookkeylist,@v_rolecode)
              
            SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
            IF @v_error <> 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'error retrieving default contact for role'
              RETURN  
            END   
          END            
        END
      END    
    
      INSERT INTO taqprojecttask
        (taqtaskkey,
        taqprojectkey,
        taqelementkey,
        globalcontactkey,
        rolecode,
        datetypecode,
        keyind,
        bookkey,
        printingkey,
        lastuserid,
        lastmaintdate)
      VALUES
        (@v_taqtaskkey,
        @v_projectkey,
        @i_taqelementkey,
        @v_globalcontactkey,
        @v_rolecode,
        @i_datetypecode,
        @i_keyind,
        @v_bookkey,
        @v_printingkey,
        @i_userid,
        getdate())
    END
      
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Error inserting to taqprojecttask table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ', datetypecode=' + CAST(@i_datetypecode AS VARCHAR)
    END
    
    -- For Creation Date, also set activedate and keyind
    IF @v_creationdatecode > 0 AND @i_datetypecode = @v_creationdatecode
    BEGIN
      SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
      FROM taqproject
      WHERE taqprojectkey = @i_projectkey
      
      IF @v_itemtype = 5 AND @v_usageclass = 1  --P&L Template
        SET @v_keyind = 1
      ELSE
        SET @v_keyind = 0
        
      IF @v_use_bookkey_printingkey_instead_of_projectkey = 0 BEGIN  
         UPDATE taqprojecttask
         SET activedate = lastmaintdate, actualind = 1, keyind = @v_keyind
         WHERE taqprojectkey = @v_projectkey AND
           datetypecode = @i_datetypecode
      END ELSE BEGIN
         UPDATE taqprojecttask
         SET activedate = lastmaintdate, actualind = 1, keyind = @v_keyind
         WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey AND
           datetypecode = @i_datetypecode      
      END  
    END
   END
   
  ELSE  --@v_taqtaskkey not generated (NULL)
   BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Could not generate new taqtaskkey (taqprojecttask table)'
   END
  
GO

GRANT EXEC ON qproject_add_taqprojecttask TO PUBLIC
GO
