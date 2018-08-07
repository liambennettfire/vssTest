if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_participant_by_role_names') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_project_participant_by_role_names
GO

CREATE PROCEDURE qproject_get_project_participant_by_role_names
 (@i_projectkey   integer,
  @i_rolecode     integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*********************************************************************************
**  Name: qproject_get_project_participant_by_role_names
**  Desc: Gets all the Names for the role in Project Participant by Role Section
**
**  Auth: Uday Khisty
**  Date: August 21, 2014
**********************************************************************************/
  
DECLARE
	@v_catcode		INT,
	@v_rolecode		INT,
	@v_contactkey	INT,
	@v_name				VARCHAR(255),
    @v_error			INT,
    @v_rowcount		INT,
    @v_count      INT,
    @v_itemtypecode INT,
    @v_usageclasscode INT,
    @v_qsicode INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_qsicode = -1
  
  IF @i_projectkey > 0 BEGIN
	  SELECT @v_itemtypecode = searchitemcode, @v_usageclasscode= usageclasscode 
	  FROM coreprojectinfo 
	  WHERE projectkey = @i_projectkey
	  
	  SELECT @v_qsicode = qsicode 
	  FROM subgentables 
	  WHERE tableid = 550 AND datacode = @v_itemtypecode AND datasubcode = @v_usageclasscode
  END
  
   DECLARE @contact_results_table TABLE
    (
		globalcontactkey	INT,
		displayname	VARCHAR(255)
	)

   DECLARE @contact_results_table_working TABLE
	(
		globalcontactkey	INT,
		displayname	VARCHAR(255)
	)
		
   DELETE FROM @contact_results_table	
   DELETE FROM @contact_results_table_working	
	
   SELECT @v_rolecode = datacode 
   FROM gentables 
   WHERE tableid = 285 AND qsicode = 15
   
   IF @i_rolecode = @v_rolecode BEGIN
	  IF @v_qsicode = 40 BEGIN -- Printing
		INSERT INTO @contact_results_table
		SELECT DISTINCT g.globalcontactkey, g.displayname 
		FROM taqversionspeccategory t 
		JOIN globalcontact g ON g.globalcontactkey = t.vendorcontactkey AND g.activeind = 1 WHERE t.taqprojectkey IN
		(
		  @i_projectkey
		) AND COALESCE(t.vendorcontactkey, 0) > 0 
		ORDER BY g.displayname asc   		
	  END
	  ELSE BEGIN
		INSERT INTO @contact_results_table
		SELECT DISTINCT g.globalcontactkey, g.displayname 
		FROM taqversionspeccategory t 
		JOIN globalcontact g ON g.globalcontactkey = t.vendorcontactkey AND g.activeind = 1 WHERE t.taqprojectkey IN
		(
		SELECT taqprojectkey1 from taqprojectrelationship WHERE taqprojectkey2 = @i_projectkey
		UNION
		SELECT taqprojectkey2 from taqprojectrelationship WHERE taqprojectkey1 = @i_projectkey
		) AND COALESCE(t.vendorcontactkey, 0) > 0 
		ORDER BY g.displayname asc    	  
	  END	   
   END
   
	-- Contacts for the Role that are from Participants
   DELETE FROM @contact_results_table_working
	--now going to add non-duped new records
   	
   IF @v_qsicode = 40 BEGIN -- Printing   	
	   INSERT INTO @contact_results_table_working
	   SELECT DISTINCT t.globalcontactkey, g.displayname FROM taqprojectcontact t 
	   JOIN taqprojectcontactrole r ON t.taqprojectcontactkey = r.taqprojectcontactkey AND r.rolecode = @i_rolecode 
	   JOIN globalcontact g ON g.globalcontactkey = t.globalcontactkey AND g.activeind = 1
	   WHERE t.taqprojectkey IN
		(
		  @i_projectkey
		) 
	   ORDER BY g.displayname asc  
   END
   ELSE BEGIN 
	   INSERT INTO @contact_results_table_working
	   SELECT DISTINCT t.globalcontactkey, g.displayname FROM taqprojectcontact t 
	   JOIN taqprojectcontactrole r ON t.taqprojectcontactkey = r.taqprojectcontactkey AND r.rolecode = @i_rolecode 
	   JOIN globalcontact g ON g.globalcontactkey = t.globalcontactkey AND g.activeind = 1
	   WHERE t.taqprojectkey IN
		(
		 SELECT taqprojectkey1 FROM taqprojectrelationship WHERE taqprojectkey2 = @i_projectkey
		 UNION
		 SELECT taqprojectkey2 FROM taqprojectrelationship WHERE taqprojectkey1 = @i_projectkey
		 UNION 
		 SELECT @i_projectkey
		) 
	   ORDER BY g.displayname asc     
   END 
   
   INSERT INTO @contact_results_table
   SELECT w.* 
   FROM @contact_results_table_working w
   LEFT JOIN @contact_results_table t ON w.globalcontactkey=t.globalcontactkey
   where t.globalcontactkey IS NULL

   --- Contacts for the role with Key Indicator Set
   DELETE FROM @contact_results_table_working
 
   INSERT INTO @contact_results_table_working
   SELECT DISTINCT g.globalcontactkey, g.displayname 
   FROM globalcontact g JOIN globalcontactrole r ON g.globalcontactkey = r.globalcontactkey AND g.activeind = 1
   AND keyind = 1 AND r.rolecode = @i_rolecode ORDER BY displayname ASC

   INSERT INTO @contact_results_table
   SELECT w.* 
   FROM @contact_results_table_working w
   LEFT JOIN @contact_results_table t ON w.globalcontactkey=t.globalcontactkey
   where t.globalcontactkey IS NULL

   --- Remaining Contacts for the role
   DELETE FROM @contact_results_table_working

   INSERT INTO @contact_results_table_working
   SELECT DISTINCT g.globalcontactkey, g.displayname
   FROM globalcontact g JOIN globalcontactrole r ON g.globalcontactkey = r.globalcontactkey AND g.activeind = 1
   AND COALESCE(keyind, 0) = 0 AND r.rolecode = @i_rolecode ORDER BY displayname ASC

   INSERT INTO @contact_results_table
   SELECT w.* 
   FROM @contact_results_table_working w
   LEFT JOIN @contact_results_table t ON w.globalcontactkey=t.globalcontactkey
   where t.globalcontactkey IS NULL

   DELETE FROM @contact_results_table_working
   
   SELECT * FROM @contact_results_table

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access globalcontact/globalcontactrole/taqversionspeccategory/taqprojectcontactrole table (qproject_get_project_participant_by_role_names).'
    END  
END
go

GRANT EXEC ON qproject_get_project_participant_by_role_names TO PUBLIC
go
