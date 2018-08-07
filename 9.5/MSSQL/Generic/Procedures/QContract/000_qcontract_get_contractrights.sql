if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_contractrights') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_contractrights
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_contractrights
 (@i_projectkey						integer,
  @i_subrightsonly        tinyint,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_contractrights
**  Desc: This procedure returns data for the contracts rights of a given contract
**
**	Auth: Dustin Miller
**	Date: April 25 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  IF @i_subrightsonly = 1
    SELECT 100 - authorsubrightspercent pubsubrightspercent, *
    FROM taqprojectrights tp 
      JOIN gentables g ON tp.subrightssalecode = g.datacode AND g.tableid = 632
    WHERE tp.taqprojectkey = @i_projectkey AND COALESCE(g.gen1ind,0) = 1
  ELSE
    SELECT *
    FROM taqprojectrights tp
      JOIN territoryrights tr ON tp.rightskey = tr.rightskey
    WHERE tp.taqprojectkey = @i_projectkey
      AND tr.taqprojectkey = tp.taqprojectkey

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning contract rights details (projectkey=' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_contractrights TO PUBLIC
GO