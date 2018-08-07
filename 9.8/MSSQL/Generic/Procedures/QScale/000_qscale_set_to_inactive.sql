if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_set_to_inactive') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_set_to_inactive
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_set_to_inactive
 (@i_projectkey               integer,
  @o_error_code               integer output,
  @o_error_desc               varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_set_to_inactive
**  Desc: This stored procedure will check the given scale for duplicates,
**				and set the status to pending if any duplicates are found
**
**    Auth: Dustin Miller
**    Date: August 1, 2012
*******************************************************************************/

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
	DECLARE @v_statuscode	INT
	
	SELECT @v_statuscode = datacode
	FROM gentables
	WHERE tableid = 522
		AND qsicode = 4
		
	UPDATE taqproject
	SET taqprojectstatuscode = @v_statuscode
	WHERE taqprojectkey = @i_projectkey
	
	IF @@ERROR <> 0
	BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error occurred while updating the scales status code (projectkey=' + CONVERT(VARCHAR, @i_projectkey) + ').'
    RETURN
  END
END

GO
GRANT EXEC ON qscale_set_to_inactive TO PUBLIC
GO