if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_rightlanguages') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_rightlanguages
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_rightlanguages
 (@i_rightskey						integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_rightlanguages
**  Desc: This procedure returns data for the contracts rightlanguage rows
**
**	Auth: Dustin Miller
**	Date: April 27 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT *
	FROM taqprojectrightslanguage
	WHERE rightskey = @i_rightskey

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning rights language details (rightskey=' + cast(@i_rightskey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_rightlanguages TO PUBLIC
GO