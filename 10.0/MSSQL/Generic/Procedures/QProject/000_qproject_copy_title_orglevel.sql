IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_title_orglevel]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_title_orglevel]
/****** Object:  StoredProcedure [dbo].[qproject_copy_title_orglevel]    Script Date: 07/16/2008 10:28:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_title_orglevel]
   (@i_copy_bookkey   INTEGER,
		@i_new_projectkey	INTEGER,
		@i_userid         VARCHAR(30),
		@o_error_code			INTEGER OUTPUT,
		@o_error_desc			VARCHAR(2000) OUTPUT)
AS

/******************************************************************************
**  Name: qproject_copy_title_orgentry
**  Desc: Copy orgentries from a title to a project, deletes any existing entries first
**
**    Auth: Colman
**    Date: 5 August 2016
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------
*****************************************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var    INT

IF @i_copy_bookkey IS NULL OR @i_copy_bookkey = 0
BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'copy bookkey not passed to copy orglevel (' + CAST(@error_var AS VARCHAR) + '): taqprojectkey = ' + CAST(@i_copy_bookkey AS VARCHAR)   
	RETURN
END

IF @i_new_projectkey IS NULL OR @i_new_projectkey = 0
BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy orglevel (' + CAST(@error_var AS VARCHAR) + '): taqprojectkey = ' + CAST(@i_copy_bookkey AS VARCHAR)   
	RETURN
END

IF (SELECT COUNT(*) FROM taqprojectorgentry WHERE taqprojectkey = @i_new_projectkey) > 0
BEGIN
  DELETE FROM taqprojectorgentry
  WHERE taqprojectkey = @i_new_projectkey
  
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Failed to remove existing taqprojectorgentry rows before copy (' + CAST(@error_var AS VARCHAR) + '): new taqprojectkey = ' + CAST(@i_new_projectkey AS VARCHAR)   
	RETURN
  END  
END

INSERT INTO taqprojectorgentry
	(taqprojectkey, orgentrykey, orglevelkey, lastuserid, lastmaintdate)
SELECT @i_new_projectkey, orgentrykey, orglevelkey, @i_userid, getdate()
FROM bookorgentry
WHERE bookkey = @i_copy_bookkey

SELECT @error_var = @@ERROR
IF @error_var <> 0 BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'copy/insert into taqprojectorgentry failed (' + CAST(@error_var AS VARCHAR) + '): taqprojectkey = ' + CAST(@i_copy_bookkey AS VARCHAR)   
	RETURN
END 

RETURN


