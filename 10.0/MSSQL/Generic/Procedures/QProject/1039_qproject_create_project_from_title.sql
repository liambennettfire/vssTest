if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_create_project_from_title') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_create_project_from_title
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_create_project_from_title
 (@i_backgroundprocesskey  integer,
  @o_error_code            integer output,
  @o_standardmsgcode       integer output,
  @o_standardmsgsubcode    integer output,
  @o_error_desc            varchar(2000) output
  )
AS

/*************************************************************************************************************
**  Name: qproject_create_project_from_title
**  Desc:
**  Case: 39202 
** 
**  Auth: Colman
**  Date: July 26, 2016
*************************************************************************************************************
**  Change History
*************************************************************************************************************
**  Date:       Author:   Description:
**  ----------  -------   --------------------------------------
**  09/21/2017  Colman    Case 47283 season doesn’t automatically populate on the publicity campaign when created from title
*************************************************************************************************************/

DECLARE
  @v_bookkey  INT,
  @v_projecttemplatekey INT,
  @v_newprojectkey INT,
  @v_project_itemtype INT,
  @v_project_usageclass INT,
  @v_project_name VARCHAR(255),
  @v_jobtypecode INT,
  @v_datagroupcode INT,
  @v_storedprocname VARCHAR(120),
  @v_cleardatagroupslist VARCHAR(255),
  @v_copydatagroupslist VARCHAR(255),
  @v_autogennameproc VARCHAR(255),
  @v_userid VARCHAR(30),
  @v_projecttype INT,
  @v_projectrole INT,
  @v_titlerole INT,
  @v_seasoncode INT,
  @v_taqprojectformatkey INT
  
BEGIN
  SET @o_error_code = 0
  SET @o_standardmsgcode = 0
  SET @o_standardmsgsubcode = 0
  SET @o_error_desc = ''
  
	SELECT @v_jobtypecode = jobtypecode, @v_storedprocname = storedprocname, @v_bookkey = key1, @v_projecttemplatekey = key2, 
         @v_project_itemtype = integervalue1, @v_project_usageclass = integervalue2, @v_project_name = textvalue1, @v_userid = lastuserid
  FROM backgroundprocess
  WHERE backgroundprocesskey = @i_backgroundprocesskey

  SET @v_newprojectkey = NULL
  SET @v_copydatagroupslist = ''
  SET @v_cleardatagroupslist = ''
  
  DECLARE copydatagroups_cur CURSOR FOR
  SELECT i.datacode FROM gentablesitemtype i
  INNER JOIN gentables g on i.tableid = g.tableid and i.datacode=g.datacode and g.gen2ind=1
  WHERE i.tableid = 598 AND itemtypecode = @v_project_itemtype AND itemtypesubcode in (@v_project_usageclass,0) and i.datacode not in (2,3,18)

	OPEN copydatagroups_cur

	FETCH copydatagroups_cur INTO @v_datagroupcode

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
    IF @v_datagroupcode <> 2  -- Don't copy org entries
    BEGIN
      IF @v_copydatagroupslist <> ''
        SET @v_copydatagroupslist = @v_copydatagroupslist + ','
      SET @v_copydatagroupslist = @v_copydatagroupslist + CAST(@v_datagroupcode AS VARCHAR)
    END
    FETCH copydatagroups_cur INTO @v_datagroupcode
  END

	CLOSE copydatagroups_cur
	DEALLOCATE copydatagroups_cur 	
  
  EXEC qproject_copy_project @v_projecttemplatekey, 0, 0, @v_copydatagroupslist, @v_cleardatagroupslist,
    0, 0, 0, @v_userid, @v_project_name, @v_newprojectkey output, @o_error_code output, @o_error_desc output

  EXEC qproject_copy_title_orglevel @v_bookkey, @v_newprojectkey, @v_userid, @o_error_code output, @o_error_desc output
  
  -- Copy title season to auto-created Marketing Campaign or Publicity Campaign. Hardcoded for HMH
  IF @v_project_itemtype = 3 AND @v_project_usageclass IN (
    SELECT datasubcode FROM subgentables WHERE tableid = 550 AND datacode = 3 AND qsicode IN (9,54)
  ) 
  BEGIN
    SELECT @v_seasoncode = COALESCE(bestseasonkey,0) FROM coretitleinfo WHERE bookkey = @v_bookkey
    IF @v_seasoncode <> 0
      UPDATE taqproject SET seasoncode = @v_seasoncode WHERE taqprojectkey = @v_newprojectkey 
  END
  
  SET @v_autogennameproc = ''
  SELECT @v_autogennameproc = COALESCE(alternatedesc1, '') FROM subgentables WHERE tableid = 550 AND datacode = @v_project_itemtype AND datasubcode = @v_project_usageclass
  IF @v_autogennameproc <> ''
    UPDATE taqproject SET autogeneratenameind = 1 WHERE taqprojectkey = @v_newprojectkey 
    
  EXEC qutl_update_recent_use_list 0, 7, 7, @v_newprojectkey, 0, 0, @o_error_code output, @o_error_desc output
  
  -- Get project type to project/title role mappings
  SELECT @v_projecttype = taqprojecttype FROM taqproject WHERE taqprojectkey = @v_newprojectkey
  SELECT @v_projectrole = code2 FROM gentablesrelationshipdetail WHERE gentablesrelationshipkey = 9 AND code1 = @v_projecttype
  IF @@ROWCOUNT = 0
  BEGIN
    -- Spec says use qsicode = 1 as default but this is 'Work' and that screws things up. 
    -- datacode = 1 is 'Marketing' on HMH (the original customer for this enhancement) and that is what we want.
    SELECT @v_projectrole = datacode FROM gentables WHERE tableid = 604 AND datacode = 1 
    IF @@ROWCOUNT = 0
    BEGIN
      -- Standard system message
      SET @o_error_code = -1
      SET @o_standardmsgcode = 3
      SET @o_standardmsgsubcode = 1
      RETURN
    END
  END
  SELECT @v_titlerole = code2 FROM gentablesrelationshipdetail WHERE gentablesrelationshipkey = 14 AND code1 = @v_projecttype
  IF @@ROWCOUNT = 0
  BEGIN
    -- Default to role of 'Title'
    SELECT @v_titlerole = datacode FROM gentables WHERE tableid = 605 AND qsicode = 1
    IF @@ROWCOUNT = 0
    BEGIN
      -- Standard system message
      SET @o_error_code = -1
      SET @o_standardmsgcode = 3
      SET @o_standardmsgsubcode = 2
      RETURN
    END
  END
  
  -- Relate new project to source title
  EXEC get_next_key 'qsidba', @v_taqprojectformatkey output
  INSERT INTO taqprojecttitle
    (taqprojectformatkey, taqprojectkey, bookkey, printingkey, primaryformatind, 
     projectrolecode, titlerolecode, lastuserid, lastmaintdate)
  VALUES
    (@v_taqprojectformatkey, @v_newprojectkey, @v_bookkey, 1, 0, 
     @v_projectrole, @v_titlerole, @v_userid, getdate())
  
  EXEC CoreProjectInfo_Row_Refresh @v_newprojectkey 	
  
END
GO

GRANT EXEC ON qproject_create_project_from_title TO PUBLIC
GO
