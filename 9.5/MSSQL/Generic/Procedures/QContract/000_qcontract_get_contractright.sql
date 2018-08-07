if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_contractright') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_contractright
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_contractright
 (@i_projectkey						integer,
  @i_rightskey						integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_contractright
**  Desc: This procedure returns data for the contracts rights detail of a given contract
**
**	Auth: Dustin Miller
**	Date: April 27 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT t.taqprojecttitle, r.*,t.externalcode
	FROM taqprojectrights r,taqproject t
	WHERE t.taqprojectkey = r.taqprojectkey
	    AND r.rightskey = @i_rightskey
		AND r.taqprojectkey = @i_projectkey

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning contract rights details (projectkey=' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_contractright TO PUBLIC
GO