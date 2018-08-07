if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_taskoverride_exists_for_element') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qproject_taskoverride_exists_for_element
GO

CREATE FUNCTION qproject_taskoverride_exists_for_element
    ( @i_taqtaskkey as integer,
      @i_taqelementkey as integer) 

RETURNS int

/******************************************************************************
**  File: qproject_taskoverride_exists_for_element.sql
**  Name: qproject_taskoverride_exists_for_element
**  Desc: This function returns 1 if a task override row exists for this 
**        taqtaskkey/elementkey,0 if it doesn't exist, and -1 for an error. 
**
**    Auth: Alan Katzen
**    Date: 27 August 2012
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @v_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @v_count = 0

  IF @i_taqtaskkey > 0 AND @i_taqelementkey > 0 BEGIN
    SELECT @v_count = count(*)
      FROM taqprojecttaskoverride
     WHERE taqtaskkey = @i_taqtaskkey and
           taqelementkey = @i_taqelementkey 
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 
  BEGIN
    SET @v_count = -1
  END 

  IF @v_count > 0 BEGIN
    SET @v_count = 1
  END

  RETURN @v_count
END
GO

GRANT EXEC ON dbo.qproject_taskoverride_exists_for_element TO public
GO
