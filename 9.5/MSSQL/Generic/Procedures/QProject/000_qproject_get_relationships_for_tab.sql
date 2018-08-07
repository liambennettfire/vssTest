 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qproject_get_relationships_for_tab')
  BEGIN
    PRINT 'Dropping Procedure qproject_get_relationships_for_tab'
    DROP  Procedure  qproject_get_relationships_for_tab
  END

GO

PRINT 'Creating Procedure qproject_get_relationships_for_tab'
GO

CREATE PROCEDURE qproject_get_relationships_for_tab
 (@i_qsicode              integer,
  @i_shownorelationship   integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_relationships_for_tab
**  Desc: This stored procedure returns gentable values for project relationships
**        by relationship tab.
**
**  Auth: Alan Katzen
**  Date: March 4 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_gentablesrelationshipkey INT

  SELECT @v_gentablesrelationshipkey = COALESCE(gentablesrelationshipkey,0)
    FROM gentablesrelationships
   WHERE gentable1id = 582
     and gentable2id = 583

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing gentablesrelationships: gentable1id = 582 / gentable2id = 583'
    RETURN  
  END 

  IF @v_gentablesrelationshipkey <= 0 BEGIN
    RETURN
  END

  IF @i_shownorelationship = 1 BEGIN
    -- need to show relationships for passed qsicode and the
    -- relationships that have no gentable relationships defined
    SELECT *, COALESCE(alternatedesc1, datadesc) bestdesc from gentables
     WHERE tableid = 582
       AND upper(COALESCE(deletestatus,'N')) = 'N'
       AND ((datacode in (SELECT distinct code1 FROM gentablesrelationshipdetail
                           WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey
                             AND code2 in (SELECT datacode FROM gentables
                                            WHERE tableid = 583
                                              AND qsicode = @i_qsicode))) OR
            (datacode not in (SELECT distinct code1 FROM gentablesrelationshipdetail
                               WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey)))
  END
  ELSE BEGIN
    SELECT *, COALESCE(alternatedesc1, datadesc) bestdesc from gentables
     WHERE tableid = 582
       AND upper(COALESCE(deletestatus,'N')) = 'N'
       AND (datacode in (SELECT distinct code1 FROM gentablesrelationshipdetail
                          WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey
                            AND code2 in (SELECT datacode FROM gentables
                                           WHERE tableid = 583
                                             AND qsicode = @i_qsicode)))
  END 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'could not get gentables based on gentable relationship mapping: ' + 
	CONVERT(varchar, @v_gentablesrelationshipkey) 
  END 
GO

GRANT EXEC ON qproject_get_relationships_for_tab TO PUBLIC
GO
