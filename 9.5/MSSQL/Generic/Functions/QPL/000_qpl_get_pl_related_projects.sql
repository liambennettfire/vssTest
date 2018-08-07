if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pl_related_projects') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_get_pl_related_projects
GO

CREATE FUNCTION dbo.qpl_get_pl_related_projects (
  @i_projectkey as integer ) 
RETURNS @related_projects TABLE (
  projectkey INT,
  is_master TINYINT,
  jointacctgind TINYINT)

/******************************************************************************************************************
**  Name: qpl_get_pl_related_projects
**  Desc: This function returns a list of all P&L-related projects:
**        - if the passed projectkey is the Master project, the related projects are all of their "subordinates"
**        - if the passed projectkey is not a Master project, the related projects are any of its Master projects 
**          (there could be multiple), plus all of their subordinates
**        In all cases, the related projects are those where relationshipcode has P&L Relationship set to true
**        (gen1ind=1 for gentable 582). Jointacctgind=1 if taqprojectrelationship.indicator1=1 OR indicator2=1 
**        (i.e. Joint Royalty or Joint Production).
**
**  Auth: Kate Wiewiora
**  Date: February 9 2016
********************************************************************************************************************/

BEGIN
  DECLARE 
	@v_count INT,
	@v_is_master TINYINT,
	@v_jointacctgind TINYINT,
    @v_related_projectkey INT,
    @v_subordinate_projectkey INT

  -- NOTE: The first 2 parts of the union are for related subordinate projects (relationships both ways), when @i_projectkey is the Master project.
  -- The last 2 parts of the union are for the related master project (relationships both ways), when @i_projectkey is the subordinate project.
  INSERT INTO @related_projects   
  SELECT taqprojectkey2, 0, CASE WHEN indicator1 = 1 OR indicator2 = 1 THEN 1 ELSE 0 END
  FROM taqprojectrelationship 
  WHERE taqprojectkey1 = @i_projectkey 
    AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1) 
    AND relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
  UNION
  SELECT taqprojectkey1, 0, CASE WHEN indicator1 = 1 OR indicator2 = 1 THEN 1 ELSE 0 END
  FROM taqprojectrelationship
  WHERE taqprojectkey2 = @i_projectkey
    AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
    AND relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
  UNION
  SELECT taqprojectkey1, 1, CASE WHEN indicator1 = 1 OR indicator2 = 1 THEN 1 ELSE 0 END
  FROM taqprojectrelationship 
  WHERE taqprojectkey2 = @i_projectkey
    AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
    AND relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
  UNION
  SELECT taqprojectkey2, 1, CASE WHEN indicator1 = 1 OR indicator2 = 1 THEN 1 ELSE 0 END
  FROM taqprojectrelationship
  WHERE taqprojectkey1 = @i_projectkey
    AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
    AND relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)

  -- Loop through all related projects and if the related project is a Master project, include any of its subordinates in the temp table
  -- not already included in the above unions
  DECLARE directly_relatedprojects_cur CURSOR FOR
  SELECT projectkey, is_master
  FROM @related_projects

  OPEN directly_relatedprojects_cur 

  FETCH directly_relatedprojects_cur INTO @v_related_projectkey, @v_is_master

  WHILE (@@FETCH_STATUS=0)
  BEGIN

    IF @v_is_master = 1
    BEGIN
      DECLARE subordinates_cur CURSOR FOR
        SELECT taqprojectkey2, CASE WHEN indicator1 = 1 OR indicator2 = 1 THEN 1 ELSE 0 END
        FROM taqprojectrelationship 
        WHERE taqprojectkey1 = @v_related_projectkey 
          AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1) 
          AND relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
        UNION
        SELECT taqprojectkey1, CASE WHEN indicator1 = 1 OR indicator2 = 1 THEN 1 ELSE 0 END
        FROM taqprojectrelationship
        WHERE taqprojectkey2 = @v_related_projectkey
          AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
          AND relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
    
      OPEN subordinates_cur 

      FETCH subordinates_cur INTO @v_subordinate_projectkey, @v_jointacctgind

      WHILE (@@FETCH_STATUS=0)
      BEGIN
        SELECT @v_count = COUNT(*)
        FROM @related_projects
        WHERE projectkey = @v_subordinate_projectkey

        IF @v_count = 0 AND @v_subordinate_projectkey <> @i_projectkey
          INSERT INTO @related_projects (projectkey, is_master, jointacctgind)
          VALUES (@v_subordinate_projectkey, 0, @v_jointacctgind)

        FETCH subordinates_cur INTO @v_subordinate_projectkey, @v_jointacctgind
      END

      CLOSE subordinates_cur
      DEALLOCATE subordinates_cur

    END --@v_is_master=1

    FETCH directly_relatedprojects_cur INTO @v_related_projectkey, @v_is_master
  END

  CLOSE directly_relatedprojects_cur
  DEALLOCATE directly_relatedprojects_cur
  
  RETURN
          
END
GO

GRANT SELECT ON dbo.qpl_get_pl_related_projects TO PUBLIC
GO
