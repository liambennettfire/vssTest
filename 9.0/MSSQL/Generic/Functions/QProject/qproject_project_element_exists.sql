if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_project_element_exists') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qproject_project_element_exists
GO

CREATE FUNCTION qproject_project_element_exists
    ( @i_taqprojectkey as integer,
      @i_elementtypecode as integer,
      @i_elementtypesubcode as integer) 

RETURNS int

/******************************************************************************
**  File: qproject_project_element_exists.sql
**  Name: qproject_project_element_exists
**  Desc: This function returns 1 if elements exist,0 if they don't exist,
**        and -1 for an error. 
**
**
**    Auth: Alan Katzen
**    Date: 20 August 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_count = 0

  IF @i_elementtypesubcode > 0 BEGIN
    -- element with a subtype
    SELECT @i_count = count(taqprojectkey)
      FROM taqprojectelement
     WHERE taqprojectkey = @i_taqprojectkey and
           taqelementtypecode = @i_elementtypecode and
           taqelementtypesubcode = @i_elementtypesubcode
  END
  ELSE BEGIN
    -- element with no subtype
    SELECT @i_count = count(taqprojectkey)
      FROM taqprojectelement
     WHERE taqprojectkey = @i_taqprojectkey and
           taqelementtypecode = @i_elementtypecode 
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 
  BEGIN
    SET @i_count = -1
  END 

  -- return 1 or 0 so that object can set params 
  IF @i_count > 0 BEGIN
    SET @i_count = 1
  END

  RETURN @i_count
END
GO

GRANT EXEC ON dbo.qproject_project_element_exists TO public
GO
