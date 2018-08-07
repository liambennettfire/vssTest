IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_relatedprojects]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_relatedprojects]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_relatedprojects]    Script Date: 07/16/2008 10:25:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_relatedprojects]
		(@i_copy_projectkey integer,
		@i_copy2_projectkey integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_cleardatagroups_list	varchar(max),
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_relationships]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var    INT,
	@rowcount_var INT,
	@newkeycount	int,
	@tobecopiedkey	int,
	@newkey	int,
	@counter		int,
	@newkeycount2	int,
	@tobecopiedkey2	int,
	@newkey2		int,
	@counter2		int,
	@cleardata		char(1),
	@templateInd    int,
	@relationshipcode int,
	@itemtype int,
	@usageclass int,
	@v_cnt int,
	@v_maxsort  int,
	@v_sortorder  int
	
select @templateInd = 0

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
select @itemtype = searchitemcode, @usageclass = usageclasscode
from taqproject
where taqprojectkey = @i_new_projectkey

if @itemtype is null or @itemtype = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'Unable to copy project relationships because item type is not populated: taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

if @usageclass is null 
begin
  set @usageclass = 0
end

select @newkeycount = count(*), @tobecopiedkey = min(q.taqprojectrelationshipkey), @v_maxsort = max(sortorder)
from taqprojectrelationship q
where (taqprojectkey1 = @i_copy_projectkey or taqprojectkey2 = @i_copy_projectkey)
     AND NOT EXISTS(SELECT * FROM projectrelationshipview r , taqproject t 
					WHERE r.taqprojectkey = @i_copy_projectkey AND  r.relatedprojectkey = t.taqprojectkey
					AND r.relatedprojectkey = @i_new_projectkey)

set @counter = 1
while @counter <= @newkeycount
begin
  select @relationshipcode = 
    case 
      when taqprojectkey1 = @i_copy_projectkey then relationshipcode1
      else relationshipcode2
    end
  from taqprojectrelationship q
  where (taqprojectkey1 = @i_copy_projectkey or taqprojectkey2 = @i_copy_projectkey) 
    and q.taqprojectrelationshipkey = @tobecopiedkey

  -- verify if relationshipcode is allowed for itemtype/usageclass
  select @v_cnt = count(*)
    from gentablesitemtype
   where tableid = 582
     and datacode = @relationshipcode
     and itemtypecode = @itemtype
     and itemtypesubcode in (@usageclass,0)
     and datacode not in (select datacode from gentables where tableid = 582 and qsicode in (14,15,16,17)) -- do not copy work relationships

  if @v_cnt > 0 begin
	  exec get_next_key @i_userid, @newkey output

	  insert into taqprojectrelationship
		  (taqprojectrelationshipkey, 
		  taqprojectkey1,
		  taqprojectkey2, 
		  projectname2, relationshipcode1, relationshipcode2, 
		  project2status, project2participants, relationshipaddtldesc, 
		  keyind, sortorder, 
		  indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, lastuserid, lastmaintdate)
	  select @newkey, 
		  case when taqprojectkey1 = @i_copy_projectkey
			  then @i_new_projectkey
			  else taqprojectkey1
		  end, 
		  case when taqprojectkey2 = @i_copy_projectkey
			  then @i_new_projectkey
			  else taqprojectkey2
		  end, 
		  projectname2, relationshipcode1, relationshipcode2, 
		  project2status, project2participants, relationshipaddtldesc, 
		  keyind, sortorder, 
		  indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, @i_userid, getdate()
	  from taqprojectrelationship tpr
	  where (taqprojectkey1 = @i_copy_projectkey or taqprojectkey2 = @i_copy_projectkey)
		  and taqprojectrelationshipkey = @tobecopiedkey

	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	  IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'copy/insert into taqprojectrelationship failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
		  RETURN
	  END 
  end
  
	set @counter = @counter + 1

	select @tobecopiedkey = min(q.taqprojectrelationshipkey)
	from taqprojectrelationship q
	where (taqprojectkey1 = @i_copy_projectkey or taqprojectkey2 = @i_copy_projectkey)
		and q.taqprojectrelationshipkey > @tobecopiedkey
end

/* 5/3/12 - KW - From case 17842:
Related Projects (10): copy from i_copy_projectkey; add unique project relationships from i_copy2_projectkey */

IF @i_copy2_projectkey > 0
BEGIN
  -- First, get all in-house related projects
  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(r1.taqprojectrelationshipkey)
  FROM taqprojectrelationship r1
  WHERE (r1.taqprojectkey1 = @i_copy2_projectkey OR r1.taqprojectkey2 = @i_copy2_projectkey) AND
    NOT EXISTS (SELECT * FROM taqprojectrelationship r2
                WHERE r1.relationshipcode1 = r2.relationshipcode1 AND 
                  r1.relationshipcode2 = r2.relationshipcode2 AND 
                 (r2.taqprojectkey1 = @i_copy_projectkey OR r2.taqprojectkey2 = @i_copy_projectkey))
				 AND NOT EXISTS(SELECT * FROM projectrelationshipview r , taqproject t 
								WHERE r.taqprojectkey = @i_copy2_projectkey AND  r.relatedprojectkey = t.taqprojectkey
								AND r.relatedprojectkey = @i_new_projectkey)	                 

  SET @counter = 1
  SET @v_sortorder = @v_maxsort + 1

  WHILE @counter <= @newkeycount
  BEGIN

    SELECT @relationshipcode = 
      CASE 
        WHEN taqprojectkey1 = @i_copy2_projectkey THEN relationshipcode1
        ELSE relationshipcode2
      END
    FROM taqprojectrelationship
    WHERE (taqprojectkey1 = @i_copy2_projectkey OR taqprojectkey2 = @i_copy2_projectkey) AND
      taqprojectrelationshipkey = @tobecopiedkey

    -- verify if relationshipcode is allowed for itemtype/usageclass
    SELECT @v_cnt = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 582 AND
      datacode = @relationshipcode AND
      itemtypecode = @itemtype AND itemtypesubcode IN (@usageclass,0) AND
      datacode NOT IN (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode IN (14,15,16,17)) -- do not copy work relationships

    IF @v_cnt > 0 BEGIN
	    EXEC get_next_key @i_userid, @newkey OUTPUT

	    INSERT INTO taqprojectrelationship
		    (taqprojectrelationshipkey, 
		    taqprojectkey1,
		    taqprojectkey2, 
		    projectname2, relationshipcode1, relationshipcode2, project2status, project2participants, relationshipaddtldesc,
		    keyind, sortorder, indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, lastuserid, lastmaintdate)
	    SELECT @newkey, 
		    CASE 
		      WHEN taqprojectkey1 = @i_copy2_projectkey THEN @i_new_projectkey
			    ELSE taqprojectkey1
		    END, 
		    CASE 
		      WHEN taqprojectkey2 = @i_copy2_projectkey THEN @i_new_projectkey
			    ELSE taqprojectkey2
		    END, 
		    projectname2, relationshipcode1, relationshipcode2, project2status, project2participants, relationshipaddtldesc, 
		    keyind, @v_sortorder, indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, @i_userid, getdate()
	    FROM taqprojectrelationship
	    WHERE (taqprojectkey1 = @i_copy2_projectkey OR taqprojectkey2 = @i_copy2_projectkey) AND
        taqprojectrelationshipkey = @tobecopiedkey

	    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	    IF @error_var <> 0 BEGIN
		    SET @o_error_code = -1
		    SET @o_error_desc = 'Copy/insert into taqprojectrelationship failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
		    RETURN
	    END 
    END
    
	  SET @counter = @counter + 1
	  SET @v_sortorder = @v_sortorder + 1

    SELECT @tobecopiedkey = MIN(r1.taqprojectrelationshipkey)
    FROM taqprojectrelationship r1
    WHERE (r1.taqprojectkey1 = @i_copy2_projectkey OR r1.taqprojectkey2 = @i_copy2_projectkey) AND
      r1.taqprojectrelationshipkey > @tobecopiedkey AND
      NOT EXISTS (SELECT * FROM taqprojectrelationship r2
                  WHERE r1.relationshipcode1 = r2.relationshipcode1 AND 
                    r1.relationshipcode2 = r2.relationshipcode2 AND 
                   (r2.taqprojectkey1 = @i_copy_projectkey OR r2.taqprojectkey2 = @i_copy_projectkey))		
  END

  -- Now get related outside titles joining only on project name (per Susan)
  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(r1.taqprojectrelationshipkey)
  FROM taqprojectrelationship r1
  WHERE (r1.taqprojectkey1 = @i_copy2_projectkey OR r1.taqprojectkey2 = @i_copy2_projectkey) AND
    (r1.taqprojectkey1 = 0 OR r1.taqprojectkey2 = 0) AND
    NOT EXISTS (SELECT * FROM taqprojectrelationship r2
                WHERE r1.projectname2 = r2.projectname2 AND
                  (r2.taqprojectkey1 = @i_copy_projectkey OR r2.taqprojectkey2 = @i_copy_projectkey))
				 AND NOT EXISTS(SELECT * FROM projectrelationshipview r , taqproject t 
								WHERE r.taqprojectkey = @i_copy2_projectkey AND  r.relatedprojectkey = t.taqprojectkey
								AND r.relatedprojectkey = @i_new_projectkey)	                  

  SET @counter = 1

  WHILE @counter <= @newkeycount
  BEGIN

    SELECT @relationshipcode = 
      CASE 
        WHEN taqprojectkey1 = @i_copy2_projectkey THEN relationshipcode1
        ELSE relationshipcode2
      END
    FROM taqprojectrelationship
    WHERE (taqprojectkey1 = @i_copy2_projectkey OR taqprojectkey2 = @i_copy2_projectkey) AND
      taqprojectrelationshipkey = @tobecopiedkey

    -- verify if relationshipcode is allowed for itemtype/usageclass
    SELECT @v_cnt = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 582 AND
      datacode = @relationshipcode AND
      itemtypecode = @itemtype AND itemtypesubcode IN (@usageclass,0) AND
      datacode NOT IN (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode IN (14,15,16,17)) -- do not copy work relationships

    IF @v_cnt > 0 BEGIN
	    EXEC get_next_key @i_userid, @newkey OUTPUT

	    INSERT INTO taqprojectrelationship
		    (taqprojectrelationshipkey, 
		    taqprojectkey1,
		    taqprojectkey2, 
		    projectname2, relationshipcode1, relationshipcode2, project2status, project2participants, relationshipaddtldesc,
		    keyind, sortorder, indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, lastuserid, lastmaintdate)
	    SELECT @newkey, 
		    CASE 
		      WHEN taqprojectkey1 = @i_copy2_projectkey THEN @i_new_projectkey
			    ELSE taqprojectkey1
		    END, 
		    CASE 
		      WHEN taqprojectkey2 = @i_copy2_projectkey THEN @i_new_projectkey
			    ELSE taqprojectkey2
		    END, 
		    projectname2, relationshipcode1, relationshipcode2, project2status, project2participants, relationshipaddtldesc, 
		    keyind, @v_sortorder, indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, @i_userid, getdate()
	    FROM taqprojectrelationship
	    WHERE (taqprojectkey1 = @i_copy2_projectkey OR taqprojectkey2 = @i_copy2_projectkey) AND
        taqprojectrelationshipkey = @tobecopiedkey

	    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	    IF @error_var <> 0 BEGIN
		    SET @o_error_code = -1
		    SET @o_error_desc = 'Copy/insert into taqprojectrelationship failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
		    RETURN
	    END 
    END
    
	  SET @counter = @counter + 1
	  SET @v_sortorder = @v_sortorder + 1
                   
    SELECT @tobecopiedkey = MIN(r1.taqprojectrelationshipkey)
    FROM taqprojectrelationship r1
    WHERE (r1.taqprojectkey1 = @i_copy2_projectkey OR r1.taqprojectkey2 = @i_copy2_projectkey) AND
      (r1.taqprojectkey1 = 0 OR r1.taqprojectkey2 = 0) AND
      r1.taqprojectrelationshipkey > @tobecopiedkey AND
      NOT EXISTS (SELECT * FROM taqprojectrelationship r2
                  WHERE r1.projectname2 = r2.projectname2 AND
                    (r2.taqprojectkey1 = @i_copy_projectkey OR r2.taqprojectkey2 = @i_copy_projectkey))                 		
  END
END --IF @i_copy2_projectkey > 0

RETURN