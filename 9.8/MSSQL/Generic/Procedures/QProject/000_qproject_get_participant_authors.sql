if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_participant_authors') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_participant_authors
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_participant_authors
 (@i_projectkey   integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_participant_authors
**  Desc: This stored procedure returns all participants that have roles
**        mapped to at least one TMM Author Type.
**        Used in Author Previous Works tab - Select Authors dialog.
**
**  Auth: Kate W.
**  Date: 7 January 2013
*******************************************************************************/

DECLARE
  @v_error  INT,
  @v_rowcount INT
  
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT DISTINCT c.globalcontactkey, r.rolecode, gc.displayname
  FROM taqprojectcontact c, taqprojectcontactrole r, globalcontact gc, gentablesrelationshipdetail m
  WHERE c.taqprojectcontactkey = r.taqprojectcontactkey AND 
    gc.globalcontactkey = c.globalcontactkey AND
    m.code1 = r.rolecode AND
    m.gentablesrelationshipkey = 2  AND
    c.taqprojectkey = @i_projectkey

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting participant authors: bookdetail (projectkey=' + cast(@i_projectkey AS VARCHAR)   
  END 

END
GO

GRANT EXEC ON qproject_get_participant_authors TO PUBLIC
GO