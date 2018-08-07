if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_configdetail_viewtype') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_configdetail_viewtype
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_configdetail_viewtype
 (@i_configobjectid varchar(100),
  @i_windowviewkey integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qutl_get_configdetail_viewtype
**  Desc: This stored procedure returns the allowed and current viewtype (list = 1 or tile = 2)
**        for the given configobject and windowviewkey.
**
**  Auth: Dustin Miller
**  Date: 25 August 2016
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:   Author: Description:
**  ------  ------  ------------
**  
*****************************************************************************************************/

DECLARE @v_configobjectkey INT,
		@v_allowedviewtype INT,
		@v_viewtype INT

BEGIN

	SET @o_error_code = 0
	SET @o_error_desc = ''

	SET @v_allowedviewtype = NULL
	SET @v_viewtype = NULL

	SELECT @v_configobjectkey = o.configobjectkey, @v_allowedviewtype = o.allowedviewtype
	FROM qsiconfigobjects o
	WHERE o.configobjectid = @i_configobjectid

	SELECT @v_viewtype = d.viewtype
	FROM qsiconfigdetail d
	WHERE d.configobjectkey = @v_configobjectkey
	  AND d.qsiwindowviewkey = @i_windowviewkey

	SET @o_error_code = @@ERROR
	IF @o_error_code <> 0
	BEGIN
		SET @o_error_code = 1
		SET @o_error_desc = 'Unable to retrieve allowedviewtype and viewtype values for the given configobject and windowviewkey.'
	END

	SET @v_allowedviewtype = COALESCE(@v_allowedviewtype, 3)
	IF @v_viewtype IS NULL
	BEGIN
		IF @v_allowedviewtype = 2
		BEGIN
			SET @v_viewtype = 2
		END
		ELSE BEGIN
			SET @v_viewtype = 1
		END
	END

	SELECT @v_allowedviewtype AS allowedviewtype, @v_viewtype AS viewtype

END 

GO

GRANT EXEC ON qutl_get_configdetail_viewtype TO PUBLIC
GO