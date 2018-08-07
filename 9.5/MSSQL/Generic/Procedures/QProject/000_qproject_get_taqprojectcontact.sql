if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taqprojectcontact') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taqprojectcontact
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_taqprojectcontact
 (@i_projectkey           integer,
  @i_globalcontactkey     integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_taqprojectcontact
**  Desc: This procedure returns taqprojectcontact info for given projectkey 
**        and globalcontactkey.
**
**	Auth: Kate
**	Date: 9 April 2009
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SELECT *
  FROM taqprojectcontact
  WHERE taqprojectkey = @i_projectkey AND
    globalcontactkey = @i_globalcontactkey

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning taqprojectcontact information (taqprojectkey=' + cast(@i_projectkey as varchar) + ', globalcontactkey=' + cast(@i_globalcontactkey as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qproject_get_taqprojectcontact TO PUBLIC
GO


