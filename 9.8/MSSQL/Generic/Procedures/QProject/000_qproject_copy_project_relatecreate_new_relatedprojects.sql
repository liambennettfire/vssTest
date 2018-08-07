IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_relatecreate_new_relatedprojects]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_relatecreate_new_relatedprojects]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_relatecreate_new_relatedprojects]
		(@i_copy_projectkey integer,
		@i_copy2_projectkey integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_cleardatagroups_list	varchar(max),
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/**********************************************************************************************************************
**  Name: [qproject_copy_project_relatecreate_new_relatedprojects]
**  Desc: This stored procedure copies the Relates / Create New Related Projects based on
**        gentablesitemtype.indicator1 setup for tableid 582 (ProjectRelationships. 
**         If true, copy the related project and create a new project using the default copy groups for that item type/class. 
**         Then relate it to the original project being created. Set the taqproject.taqprojecttitle on the new related project 
**         to the taqprojecttitle of the project you are copying it for/taqprojecttitle of the original project being created; 
**         set the templateind set to 0. 
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Uday A. Khisty
**    Date: 1 April 2015
***********************************************************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @v_error_var    INT,
    @v_error_desc VARCHAR(2000),
	@v_rowcount_var INT,
	@v_newkeycount	INT,
	@v_tobecopiedkey	INT,
	@v_newkey	INT,
	@v_counter		INT,
	@v_newkeycount2	INT,
	@v_tobecopiedkey2	INT,
	@v_newkey2		INT,
	@v_counter2		INT,
	@v_cleardata		CHAR(1),
	@v_templateInd    INT,
	@v_relationshipcode INT,
	@v_itemtype INT,
	@v_usageclass INT,
	@v_datacode INT,
	@v_datagroup_string VARCHAR(2000),
	@v_taqprojectrelationshipkey INT,
    @v_itemtypecode_relatedproject INT,
    @v_usageclasscode_relatedproject INT,   	
    @v_relatedprojectkey INT,
    @v_new_relatedprojectkey INT,
    @v_projectname VARCHAR(255),
    @v_relatedprojectname VARCHAR(255),
    @v_new_relatedprojectname VARCHAR(255),
	@v_cnt INT,
	@v_maxsort  INT,
	@v_sortorder  INT
	
select @v_templateInd = 0
SET @v_new_relatedprojectname = ''
SET @v_new_relatedprojectkey = 0
SET @v_datagroup_string = ''

if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy related projects'
	RETURN
end

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy related projects: taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

-- only want to copy relationships for relationship types that are defined 
-- for the new project
select @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
from taqproject
where taqprojectkey = @i_new_projectkey

if @v_itemtype is null or @v_itemtype = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'Unable to copy project relationships because item type is not populated: taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

if @v_usageclass is null 
begin
  set @v_usageclass = 0
end

SELECT @v_projectname = COALESCE(t.taqprojecttitle, '') FROM taqproject t WHERE taqprojectkey = @i_new_projectkey

-- Form the datagroup string - list of all Project data Group datacodes (gentable 598) valid for Printing projects -
-- sort on gentablesitemtype.sortorder first, then gentables.sortorder and datadesc
DECLARE datagroup_cur CURSOR FOR
  SELECT i.datacode
  FROM gentablesitemtype i, gentables g 
  WHERE i.tableid = g.tableid AND i.datacode = g.datacode AND g.tableid = 598 
    AND itemtypecode = @v_itemtype AND COALESCE(itemtypesubcode,0) IN (0,@v_usageclass)
    AND g.datacode NOT IN (SELECT datacode FROM gentables WHERE tableid = 598 AND qsicode IN (10, 26))
  ORDER BY i.sortorder, g.sortorder, g.datadesc

OPEN datagroup_cur 

FETCH datagroup_cur INTO @v_datacode

WHILE (@@FETCH_STATUS=0)
BEGIN

  IF @v_datagroup_string = ''
    SET @v_datagroup_string = CONVERT(VARCHAR, @v_datacode)
  ELSE
    SET @v_datagroup_string = @v_datagroup_string + ',' + CONVERT(VARCHAR, @v_datacode)

  FETCH datagroup_cur INTO @v_datacode
END

CLOSE datagroup_cur
DEALLOCATE datagroup_cur

SELECT @v_maxsort = MAX(r.sortorder)
FROM projectrelationshipview r , taqproject t 
WHERE r.taqprojectkey = @i_copy_projectkey
  AND r.relatedprojectkey = t.taqprojectkey

DECLARE copy1_projects_cur CURSOR FOR 
   SELECT DISTINCT r.taqprojectrelationshipkey, r.relatedprojectkey, r.relationshipcode, t.searchitemcode, t.usageclasscode, LTRIM(RTRIM(COALESCE(r.relatedprojectname, ''))) relatedprojectname
	FROM projectrelationshipview r , taqproject t 
    WHERE r.taqprojectkey = @i_copy_projectkey
      AND r.relatedprojectkey = t.taqprojectkey
     AND NOT EXISTS(SELECT * FROM projectrelationshipview r , taqproject t 
					WHERE r.taqprojectkey = @i_copy_projectkey AND  r.relatedprojectkey = t.taqprojectkey
					AND r.relatedprojectkey = @i_new_projectkey)
	  
OPEN copy1_projects_cur 

FETCH copy1_projects_cur INTO @v_taqprojectrelationshipkey, @v_relatedprojectkey, @v_relationshipcode, @v_itemtypecode_relatedproject, @v_usageclasscode_relatedproject, @v_relatedprojectname

WHILE @@fetch_status = 0 BEGIN
  -- verify if relationshipcode is allowed for itemtype/usageclass
  SELECT @v_cnt = count(*)
    FROM gentablesitemtype
   WHERE tableid = 582
     and datacode = @v_relationshipcode
     and itemtypecode = @v_itemtype
     and itemtypesubcode in (@v_usageclass,0)
     and datacode not in (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode IN (14,15,16,17)) -- do not copy work relationships

  IF @v_cnt > 0 BEGIN
	IF EXISTS(SELECT * from gentablesitemtype WHERE tableid = 582 AND datacode = @v_relationshipcode AND itemtypecode = @v_itemtype AND itemtypesubcode IN (@v_usageclass, 0) AND indicator1 = 1) BEGIN
	     
	    SET @v_new_relatedprojectname = ''
	    IF @v_projectname <> '' BEGIN
			SET @v_new_relatedprojectname = @v_projectname
			
			IF @v_relatedprojectname <> '' BEGIN
				SET	@v_new_relatedprojectname = LEFT(@v_new_relatedprojectname + ' / ' + @v_relatedprojectname, 255)
			END
	    END
	    ELSE BEGIN
			SET @v_new_relatedprojectname = @v_relatedprojectname
	    END
	    
		SET @v_error_var = 0
		SET @v_error_desc = ''
	    SET @v_new_relatedprojectkey = 0 
	    
		EXEC qproject_copy_project @v_relatedprojectkey, 0, 0, @v_datagroup_string, '', 0, 0, 0, @i_userid, @v_new_relatedprojectname, 
		  @v_new_relatedprojectkey OUTPUT, @v_error_var OUTPUT, @v_error_desc OUTPUT

		IF @v_error_var <> 0 BEGIN
		  SET @o_error_code = @v_error_var
		  SET @o_error_desc = 'Failed to copy from project ' + CONVERT(VARCHAR, @i_copy_projectkey) + ': ' + @v_error_desc
		  RETURN
		END		

	   IF @v_new_relatedprojectkey > 0 BEGIN
		  EXEC get_next_key @i_userid, @v_newkey OUTPUT

		  INSERT INTO taqprojectrelationship
			  (taqprojectrelationshipkey, 
			  taqprojectkey1,
			  taqprojectkey2, 
			  projectname2, relationshipcode1, relationshipcode2, 
			  project2status, project2participants, relationshipaddtldesc, 
			  keyind, sortorder, 
			  indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, lastuserid, lastmaintdate)
		  SELECT @v_newkey, 
			  CASE WHEN taqprojectkey1 = @i_copy_projectkey
				  THEN @i_new_projectkey
				  ELSE @v_new_relatedprojectkey
			  END, 
			  CASE WHEN taqprojectkey2 = @i_copy_projectkey
				  THEN @i_new_projectkey
				  ELSE @v_new_relatedprojectkey
			  END, 			  
			  CASE WHEN taqprojectkey2 = @i_copy_projectkey
				  THEN @v_projectname
				  ELSE @v_new_relatedprojectname
			  END projectname2, 			  
			  relationshipcode1, relationshipcode2, 
			  project2status, project2participants, relationshipaddtldesc, 
			  keyind, sortorder, 
			  indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, @i_userid, getdate()
		  FROM taqprojectrelationship tpr
		  WHERE (taqprojectkey1 = @i_copy_projectkey or taqprojectkey2 = @i_copy_projectkey)
			  and taqprojectrelationshipkey = @v_taqprojectrelationshipkey

		  SELECT @v_error_var = @@ERROR, @v_rowcount_var = @@ROWCOUNT
		  IF @v_error_var <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'copy/insert into taqprojectrelationship failed (' + cast(@v_error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
			  RETURN
		  END 	
	   END		
	END  
	ELSE BEGIN
	  EXEC get_next_key @i_userid, @v_newkey OUTPUT

	  INSERT INTO taqprojectrelationship
		  (taqprojectrelationshipkey, 
		  taqprojectkey1,
		  taqprojectkey2, 
		  projectname2, relationshipcode1, relationshipcode2, 
		  project2status, project2participants, relationshipaddtldesc, 
		  keyind, sortorder, 
		  indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, lastuserid, lastmaintdate)
	  SELECT @v_newkey, 
		  CASE WHEN taqprojectkey1 = @i_copy_projectkey
			  THEN @i_new_projectkey
			  ELSE taqprojectkey1
		  END, 
		  CASE WHEN taqprojectkey2 = @i_copy_projectkey
			  THEN @i_new_projectkey
			  ELSE taqprojectkey2
		  END, 
		  projectname2, relationshipcode1, relationshipcode2, 
		  project2status, project2participants, relationshipaddtldesc, 
		  keyind, sortorder, 
		  indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, @i_userid, getdate()
	  FROM taqprojectrelationship tpr
	  WHERE (taqprojectkey1 = @i_copy_projectkey or taqprojectkey2 = @i_copy_projectkey)
		  and taqprojectrelationshipkey = @v_taqprojectrelationshipkey

	  SELECT @v_error_var = @@ERROR, @v_rowcount_var = @@ROWCOUNT
	  IF @v_error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'copy/insert into taqprojectrelationship failed (' + cast(@v_error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
		  RETURN
	  END 		
	END    
  END
	 		 
  FETCH copy1_projects_cur INTO @v_taqprojectrelationshipkey, @v_relatedprojectkey, @v_relationshipcode, @v_itemtypecode_relatedproject, @v_usageclasscode_relatedproject, @v_relatedprojectname
END --@@fetch_status = 0 for copy1_projects_cur

CLOSE copy1_projects_cur 
DEALLOCATE copy1_projects_cur 	
	
IF @i_copy2_projectkey > 0
BEGIN

  -- First, get all in-house related projects
	DECLARE copy2_projects_cur CURSOR FOR 
	   SELECT DISTINCT r1.taqprojectrelationshipkey, r1.relatedprojectkey, r1.relationshipcode, t1.searchitemcode, t1.usageclasscode, LTRIM(RTRIM(COALESCE(r1.relatedprojectname, ''))) relatedprojectname
		FROM projectrelationshipview r1 , taqproject t1 
		WHERE r1.taqprojectkey = @i_copy2_projectkey
		  AND r1.relatedprojectkey = t1.taqprojectkey AND
		  NOT EXISTS (SELECT * FROM projectrelationshipview r2
				WHERE r1.relationshipcode = r2.relationshipcode AND 
				  r2.taqprojectkey = @i_copy_projectkey)
				 AND NOT EXISTS(SELECT * FROM projectrelationshipview r , taqproject t 
								WHERE r.taqprojectkey = @i_copy2_projectkey AND  r.relatedprojectkey = t.taqprojectkey
								AND r.relatedprojectkey = @i_new_projectkey)				  
		  
	OPEN copy2_projects_cur 

	FETCH copy2_projects_cur INTO @v_taqprojectrelationshipkey, @v_relatedprojectkey, @v_relationshipcode, @v_itemtypecode_relatedproject, @v_usageclasscode_relatedproject, @v_relatedprojectname

	WHILE @@fetch_status = 0 BEGIN
	  -- verify if relationshipcode is allowed for itemtype/usageclass
	  SELECT @v_cnt = count(*)
		FROM gentablesitemtype
	   WHERE tableid = 582
		 and datacode = @v_relationshipcode
		 and itemtypecode = @v_itemtype
		 and itemtypesubcode in (@v_usageclass,0)
		 and datacode not in (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode IN (14,15,16,17)) -- do not copy work relationships

	  IF @v_cnt > 0 BEGIN
		IF EXISTS(SELECT * from gentablesitemtype WHERE tableid = 582 AND datacode = @v_relationshipcode AND itemtypecode = @v_itemtype AND itemtypesubcode IN (@v_usageclass, 0) AND indicator1 = 1) BEGIN
		
			SET @v_new_relatedprojectname = ''
			IF @v_projectname <> '' BEGIN
				SET @v_new_relatedprojectname = @v_projectname
				
				IF @v_relatedprojectname <> '' BEGIN
					SET	@v_new_relatedprojectname = LEFT(@v_new_relatedprojectname + '/' + @v_relatedprojectname, 255)
				END
			END
			ELSE BEGIN
				SET @v_new_relatedprojectname = @v_relatedprojectname
			END
			
		   SET @v_error_var = 0
		   SET @v_error_desc = ''
	       SET @v_new_relatedprojectkey = 0 
	       
			EXEC qproject_copy_project @v_relatedprojectkey, 0, 0, @v_datagroup_string, '', 0, 0, 0, @i_userid, @v_new_relatedprojectname, 
			  @v_new_relatedprojectkey OUTPUT, @v_error_var OUTPUT, @v_error_desc OUTPUT

			IF @v_error_var <> 0 BEGIN
			  SET @o_error_code = @v_error_var
			  SET @o_error_desc = 'Failed to copy from project ' + CONVERT(VARCHAR, @i_copy2_projectkey) + ': ' + @v_error_desc
			  RETURN
			END		

		   IF @v_new_relatedprojectkey > 0 BEGIN
			  EXEC get_next_key @i_userid, @v_newkey OUTPUT

			  INSERT INTO taqprojectrelationship
				  (taqprojectrelationshipkey, 
				  taqprojectkey1,
				  taqprojectkey2, 
				  projectname2, relationshipcode1, relationshipcode2, 
				  project2status, project2participants, relationshipaddtldesc, 
				  keyind, sortorder, 
				  indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, lastuserid, lastmaintdate)
			  SELECT @v_newkey, 
				  CASE WHEN taqprojectkey1 = @i_copy2_projectkey
					  THEN @i_new_projectkey
					  ELSE @v_new_relatedprojectkey
				  END, 
				  CASE WHEN taqprojectkey2 = @i_copy2_projectkey
					  THEN @i_new_projectkey
					  ELSE @v_new_relatedprojectkey
				  END, 
				  projectname2, relationshipcode1, relationshipcode2, 
				  project2status, project2participants, relationshipaddtldesc, 
				  keyind, sortorder, 
				  indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, @i_userid, getdate()
			  FROM taqprojectrelationship tpr
			  WHERE (taqprojectkey1 = @i_copy2_projectkey or taqprojectkey2 = @i_copy2_projectkey)
				  and taqprojectrelationshipkey = @v_taqprojectrelationshipkey

			  SELECT @v_error_var = @@ERROR, @v_rowcount_var = @@ROWCOUNT
			  IF @v_error_var <> 0 BEGIN
				  SET @o_error_code = -1
				  SET @o_error_desc = 'copy/insert into taqprojectrelationship failed (' + cast(@v_error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
				  RETURN
			  END 	
		   END		
		END  
		ELSE BEGIN
		  EXEC get_next_key @i_userid, @v_newkey OUTPUT

		  INSERT INTO taqprojectrelationship
			  (taqprojectrelationshipkey, 
			  taqprojectkey1,
			  taqprojectkey2, 
			  projectname2, relationshipcode1, relationshipcode2, 
			  project2status, project2participants, relationshipaddtldesc, 
			  keyind, sortorder, 
			  indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, lastuserid, lastmaintdate)
		  SELECT @v_newkey, 
			  CASE WHEN taqprojectkey1 = @i_copy2_projectkey
				  THEN @i_new_projectkey
				  ELSE taqprojectkey1
			  END, 
			  CASE WHEN taqprojectkey2 = @i_copy2_projectkey
				  THEN @i_new_projectkey
				  ELSE taqprojectkey2
			  END, 
			  projectname2, relationshipcode1, relationshipcode2, 
			  project2status, project2participants, relationshipaddtldesc, 
			  keyind, sortorder, 
			  indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, @i_userid, getdate()
		  FROM taqprojectrelationship tpr
		  WHERE (taqprojectkey1 = @i_copy2_projectkey or taqprojectkey2 = @i_copy2_projectkey)
			  and taqprojectrelationshipkey = @v_taqprojectrelationshipkey

		  SELECT @v_error_var = @@ERROR, @v_rowcount_var = @@ROWCOUNT
		  IF @v_error_var <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'copy/insert into taqprojectrelationship failed (' + cast(@v_error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
			  RETURN
		  END 		
		END    
	  END
		 	
	  SET @v_sortorder = @v_sortorder + 1		 		  
	  FETCH copy2_projects_cur INTO @v_taqprojectrelationshipkey, @v_relatedprojectkey, @v_relationshipcode, @v_itemtypecode_relatedproject, @v_usageclasscode_relatedproject, @v_relatedprojectname
	END --@@fetch_status = 0 for copy2_projects_cur

	CLOSE copy2_projects_cur 
	DEALLOCATE copy2_projects_cur 

  -- Now get related outside titles joining only on project name (per Susan)
  SELECT @v_newkeycount = COUNT(*), @v_tobecopiedkey = MIN(r1.taqprojectrelationshipkey)
  FROM taqprojectrelationship r1
  WHERE (r1.taqprojectkey1 = @i_copy2_projectkey OR r1.taqprojectkey2 = @i_copy2_projectkey) AND
    (r1.taqprojectkey1 = 0 OR r1.taqprojectkey2 = 0) AND
    NOT EXISTS (SELECT * FROM taqprojectrelationship r2
                WHERE r1.projectname2 = r2.projectname2 AND
                  (r2.taqprojectkey1 = @i_copy_projectkey OR r2.taqprojectkey2 = @i_copy_projectkey))
	 AND NOT EXISTS(SELECT * FROM projectrelationshipview r , taqproject t 
	WHERE r.taqprojectkey = @i_copy2_projectkey AND  r.relatedprojectkey = t.taqprojectkey
	AND r.relatedprojectkey = @i_new_projectkey)	

  SET @v_counter = 1

  WHILE @v_counter <= @v_newkeycount
  BEGIN

    SELECT @v_relationshipcode = 
      CASE 
        WHEN taqprojectkey1 = @i_copy2_projectkey THEN relationshipcode1
        ELSE relationshipcode2
      END
    FROM taqprojectrelationship
    WHERE (taqprojectkey1 = @i_copy2_projectkey OR taqprojectkey2 = @i_copy2_projectkey) AND
      taqprojectrelationshipkey = @v_tobecopiedkey

    -- verify if relationshipcode is allowed for itemtype/usageclass
    SELECT @v_cnt = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 582 AND
      datacode = @v_relationshipcode AND
      itemtypecode = @v_itemtype AND itemtypesubcode IN (@v_usageclass,0) AND
      datacode NOT IN (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode IN (14,15,16,17)) -- do not copy work relationships

    IF @v_cnt > 0 BEGIN
	    EXEC get_next_key @i_userid, @v_newkey OUTPUT

	    INSERT INTO taqprojectrelationship
		    (taqprojectrelationshipkey, 
		    taqprojectkey1,
		    taqprojectkey2, 
		    projectname2, relationshipcode1, relationshipcode2, project2status, project2participants, relationshipaddtldesc,
		    keyind, sortorder, indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, lastuserid, lastmaintdate)
	    SELECT @v_newkey, 
		    CASE 
		      WHEN taqprojectkey1 = @i_copy2_projectkey THEN @i_new_projectkey
			    ELSE taqprojectkey1
		    END, 
		    CASE 
		      WHEN taqprojectkey2 = @i_copy2_projectkey THEN @i_new_projectkey
			    ELSE taqprojectkey2
		    END, 
		    CASE WHEN taqprojectkey2 = @i_copy_projectkey
			    THEN @v_projectname
			    ELSE @v_new_relatedprojectname
		    END projectname2, 		    
		    relationshipcode1, relationshipcode2, project2status, project2participants, relationshipaddtldesc, 
		    keyind, @v_sortorder, indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, @i_userid, getdate()
	    FROM taqprojectrelationship
	    WHERE (taqprojectkey1 = @i_copy2_projectkey OR taqprojectkey2 = @i_copy2_projectkey) AND
        taqprojectrelationshipkey = @v_tobecopiedkey

	    SELECT @v_error_var = @@ERROR, @v_rowcount_var = @@ROWCOUNT
	    IF @v_error_var <> 0 BEGIN
		    SET @o_error_code = -1
		    SET @o_error_desc = 'Copy/insert into taqprojectrelationship failed (' + cast(@v_error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
		    RETURN
	    END 
    END
    
	  SET @v_counter = @v_counter + 1
	  SET @v_sortorder = @v_sortorder + 1
                   
    SELECT @v_tobecopiedkey = MIN(r1.taqprojectrelationshipkey)
    FROM taqprojectrelationship r1
    WHERE (r1.taqprojectkey1 = @i_copy2_projectkey OR r1.taqprojectkey2 = @i_copy2_projectkey) AND
      (r1.taqprojectkey1 = 0 OR r1.taqprojectkey2 = 0) AND
      r1.taqprojectrelationshipkey > @v_tobecopiedkey AND
      NOT EXISTS (SELECT * FROM taqprojectrelationship r2
                  WHERE r1.projectname2 = r2.projectname2 AND
                    (r2.taqprojectkey1 = @i_copy_projectkey OR r2.taqprojectkey2 = @i_copy_projectkey))                 		
  END
END --IF @i_copy2_projectkey > 0

RETURN