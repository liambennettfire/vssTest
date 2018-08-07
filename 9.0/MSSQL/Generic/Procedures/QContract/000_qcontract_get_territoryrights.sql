if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_territoryrights') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_territoryrights
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_territoryrights
 (@i_projectkey						integer,
  @i_rightskey						integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_territoryrights
**  Desc: This procedure returns rows from the territoryrights table for a specific project/right
**
**	Auth: Dustin Miller
**	Date: May 10 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT *
	FROM territoryrights
	WHERE taqprojectkey = @i_projectkey
		AND rightskey = @i_rightskey
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning territoryrights details (projectkey=' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_territoryrights TO PUBLIC
GO