IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_relatedworks]') AND type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_relatedworks]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_relatedworks]    Script Date: 07/16/2008 10:25:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_relatedworks]
		(@i_copy_projectkey integer,
		@i_copy2_projectkey integer,
		@i_new_projectkey		integer,
		@i_userid				    VARCHAR(30),
		@o_error_code			  integer output,
		@o_error_desc			  VARCHAR(2000) output)
AS

/******************************************************************************
**  Name: qproject_copy_project_relatedworks
**  Desc: 
**		If you call this procedure FROM anyplace other than qproject_copy_project,
**		you must do your own transaction/commit/rollbacks on return FROM this procedure.
**
**    Auth: Colman
**    Date: 2/27/2017
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:     Description:
**    --------     --------    --------------------------------------------------------------------------------------
**    03/22/2017   Colman      43991 Duplicate related works after copying a contract 
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE 
  @v_copy_projectkey INT,
  @v_contract_to_work INT,
	@v_itemtype INT,
	@v_usageclass INT,
  @v_taqprojectrelationshipkey INT, 
  @v_taqprojectkey1 INT, 
  @v_taqprojectkey2 INT, 
  @v_tmp_taqprojectkey1 INT,
  @v_tmp_taqprojectkey2 INT,
  @v_projectname2 VARCHAR(255), 
  @v_relationshipcode1 SMALLINT, 
  @v_relationshipcode2 SMALLINT, 
  @v_project2status VARCHAR(100), 
  @v_project2participants VARCHAR(100), 
  @v_relationshipaddtldesc VARCHAR(100), 
  @v_keyind TINYINT, 
  @v_sortorder INT, 
  @v_indicator1 TINYINT, 
  @v_indicator2 TINYINT, 
  @v_quantity1 INT, 
  @v_quantity2 INT, 
  @v_decimal1 DECIMAL(14, 4), 
  @v_decimal2 DECIMAL(14, 4),
  @error_var    INT

IF @i_copy_projectkey IS NULL OR @i_copy_projectkey = 0
BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key NOT passed to copy related works'
	RETURN
END

IF @i_new_projectkey IS NULL OR @i_new_projectkey = 0
BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key NOT passed to copy related works: taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
END

-- only want to copy relationships FOR relationship types that are defined 
-- FOR the new project
SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
FROM taqproject
WHERE taqprojectkey = @i_new_projectkey

IF @v_usageclass IS NULL 
BEGIN
  SET @v_usageclass = 0
END

-- Get relationship codes
SELECT @v_contract_to_work = datacode 
FROM  gentables 
WHERE tableid = 582 
  AND qsicode = 16 -- Work (FOR Contract)

-- Table variable to loop through the two copy from keys
DECLARE @v_copyfromkeys table(idx INT identity(1,1), id INT)

INSERT INTO @v_copyfromkeys (id)
    SELECT @i_copy_projectkey union
    SELECT @i_copy2_projectkey

DECLARE @v_copyfromkeys_idx INT
DECLARE @v_copyfromkeys_count INT

SELECT @v_copyfromkeys_idx = min(idx) - 1, @v_copyfromkeys_count = max(idx) 
FROM @v_copyfromkeys

WHILE @v_copyfromkeys_idx < @v_copyfromkeys_count
BEGIN
  SELECT @v_copyfromkeys_idx = @v_copyfromkeys_idx + 1
  SELECT @v_copy_projectkey = id FROM @v_copyfromkeys WHERE idx = @v_copyfromkeys_idx
  
  IF ISNULL(@v_copy_projectkey, 0) = 0
    CONTINUE

  DECLARE relationship_cur CURSOR FOR 
    SELECT taqprojectkey1, taqprojectkey2, projectname2, relationshipcode1, relationshipcode2, project2status, project2participants, 
      relationshipaddtldesc, keyind, sortorder, indicator1, indicator2, quantity1, quantity2, decimal1, decimal2
    FROM taqprojectrelationship
    WHERE (   (taqprojectkey1 = @v_copy_projectkey AND relationshipcode2 = @v_contract_to_work)
           OR (taqprojectkey2 = @v_copy_projectkey AND relationshipcode1 = @v_contract_to_work))
      AND NOT EXISTS (
        SELECT 1 FROM projectrelationshipview
        WHERE taqprojectkey = @v_copy_projectkey
          AND relatedprojectkey = @i_new_projectkey
          AND relationshipcode = @v_contract_to_work)
      AND relationshipcode1 IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(582, @v_itemtype, @v_usageclass))

  OPEN relationship_cur
  FETCH FROM relationship_cur INTO
    @v_taqprojectkey1, @v_taqprojectkey2, @v_projectname2, @v_relationshipcode1, @v_relationshipcode2, @v_project2status, @v_project2participants, 
    @v_relationshipaddtldesc, @v_keyind, @v_sortorder, @v_indicator1, @v_indicator2, @v_quantity1, @v_quantity2, @v_decimal1, @v_decimal2

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    SELECT @v_tmp_taqprojectkey1 = 
    CASE WHEN @v_taqprojectkey1 = @v_copy_projectkey
      THEN @i_new_projectkey
      ELSE @v_taqprojectkey1
    END

    SELECT @v_tmp_taqprojectkey2 = 
    CASE WHEN @v_taqprojectkey2 = @v_copy_projectkey
      THEN @i_new_projectkey
      ELSE @v_taqprojectkey2
    END

    IF NOT EXISTS 
      (SELECT 1 FROM taqprojectrelationship 
       WHERE taqprojectkey1 = @v_tmp_taqprojectkey1
         AND taqprojectkey2 = @v_tmp_taqprojectkey2
         AND relationshipcode1 = @v_relationshipcode1
         AND relationshipcode2 = @v_relationshipcode2)
    BEGIN
      EXEC get_next_key @i_userid, @v_taqprojectrelationshipkey OUTPUT

      INSERT INTO taqprojectrelationship
        (taqprojectrelationshipkey, 
        taqprojectkey1,
        taqprojectkey2, 
        projectname2, relationshipcode1, relationshipcode2, 
        project2status, project2participants, relationshipaddtldesc, 
        keyind, sortorder, 
        indicator1, indicator2, quantity1, quantity2, decimal1, decimal2, lastuserid, lastmaintdate)
      VALUES
       (@v_taqprojectrelationshipkey, 
        @v_tmp_taqprojectkey1,
        @v_tmp_taqprojectkey2,
        @v_projectname2, @v_relationshipcode1, @v_relationshipcode2, 
        @v_project2status, @v_project2participants, @v_relationshipaddtldesc, 
        @v_keyind, @v_sortorder, 
        @v_indicator1, @v_indicator2, @v_quantity1, @v_quantity2, @v_decimal1, @v_decimal2, @i_userid, getdate())

      SELECT @error_var = @@ERROR
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'INSERT INTO taqprojectrelationship failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@v_copy_projectkey AS VARCHAR)   
        CLOSE relationship_cur
        DEALLOCATE relationship_cur
        RETURN
      END 
    END
    FETCH FROM relationship_cur INTO
      @v_taqprojectkey1, @v_taqprojectkey2, @v_projectname2, @v_relationshipcode1, @v_relationshipcode2, @v_project2status, @v_project2participants, 
      @v_relationshipaddtldesc, @v_keyind, @v_sortorder, @v_indicator1, @v_indicator2, @v_quantity1, @v_quantity2, @v_decimal1, @v_decimal2
  END

  CLOSE relationship_cur
  DEALLOCATE relationship_cur

END
