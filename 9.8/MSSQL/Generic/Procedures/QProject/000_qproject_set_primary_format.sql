if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_set_primary_format') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_set_primary_format
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_set_primary_format
 (@i_projectkey   integer,
  @i_formatkey		integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/********************************************************************************
**  Name: qproject_set_primary_format
**  Desc: This stored procedure sets the specified project format to primary 
**	Note: THIS PROCEDURE DOES NOT ENSURE THAT ONLY ONE PRIMARY FORMAT EXISTS FOR ANY PROJECT!
**
**    Auth: Dustin Miller
**    Date: December 13, 2011
*********************************************************************************/

  DECLARE @ErrorValue    INT
  DECLARE @RowcountValue INT
  DECLARE @TitleRoleCode INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @ErrorValue = 0
  SET @RowcountValue = 0

  BEGIN
		UPDATE taqprojecttitle
		SET primaryformatind=1
		WHERE taqprojectkey=@i_projectkey AND
			taqprojectformatkey=@i_formatkey
		
		SELECT @ErrorValue = @@ERROR, @RowcountValue = @@ROWCOUNT  
		IF @ErrorValue <> 0
		BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Could not update table taqproject format'
			RETURN
		END
  END
  
GO

GRANT EXEC ON qproject_set_primary_format TO PUBLIC
GO