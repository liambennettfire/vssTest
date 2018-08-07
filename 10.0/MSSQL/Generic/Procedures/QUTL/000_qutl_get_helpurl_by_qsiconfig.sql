if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_helpurl_by_qsiconfig') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_helpurl_by_qsiconfig
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_helpurl_by_qsiconfig
 (@i_configobjectkey	 integer,
  @i_configdetailkey	 integer,
  @i_relationshiptabcode integer,
  @i_itemtypecode		 integer,
  @i_usageclasscode		 integer,
  @o_error_code			 integer output,
  @o_error_desc			 varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qutl_get_helpurl_by_qsiconfig
**  Desc: This stored procedure returns the most specific helpurl it can find based off the
**		  provided parameters (checks qsiconfigdetailtabs, qsiconfigdetail, qsiconfigobjects, and clientdefaults)
**  Auth: Dustin Miller
**  Date: 5 January 2018
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:   Author: Description:
**  ------  ------  ------------
**  
*****************************************************************************************************/

DECLARE @v_helpurl VARCHAR(2000)
DECLARE @v_windowid INT

BEGIN

	SET @o_error_code = 0
	SET @o_error_desc = ''

	SET @v_helpurl = NULL

	IF COALESCE(@i_relationshiptabcode, 0) > 0 AND COALESCE(@i_configdetailkey, 0) > 0
	BEGIN
		SELECT @v_helpurl = helpurl
		FROM qsiconfigdetailtabs
		WHERE configdetailkey = @i_configdetailkey
		  AND relationshiptabcode = @i_relationshiptabcode
	END
	IF @v_helpurl IS NULL AND COALESCE(@i_configobjectkey, 0) > 0 AND COALESCE(@i_configdetailkey, 0) > 0
	BEGIN
		SELECT @v_helpurl = helpurl
		FROM qsiconfigdetail
		WHERE configobjectkey = @i_configobjectkey
		  AND configdetailkey = @i_configdetailkey

		  IF @v_helpurl IS NULL AND COALESCE(@i_itemtypecode, 0) > 0 AND COALESCE(@i_usageclasscode, 0) > 0
		  BEGIN
			SELECT TOP 1 @v_helpurl = cd.helpurl
			FROM qsiconfigobjects co
			JOIN qsiconfigdetail cd
			ON (co.configobjectkey = cd.configobjectkey)
			WHERE co.configobjectkey = @i_configobjectkey
			  AND co.itemtypecode = @i_itemtypecode
			  AND cd.usageclasscode = @i_usageclasscode
			  AND cd.helpurl IS NOT NULL
		  END
	END
	IF @v_helpurl IS NULL AND COALESCE(@i_configobjectkey, 0) > 0
	BEGIN
		SELECT @v_helpurl = helpurl
		FROM qsiconfigobjects
		WHERE configobjectkey = @i_configobjectkey

		IF @v_helpurl IS NULL
		BEGIN
			SELECT @v_windowid = windowid
			FROM qsiconfigobjects
			WHERE configobjectkey = @i_configobjectkey

			IF COALESCE(@v_windowid, 0) > 0
			BEGIN
				SELECT @v_helpurl = helpurl
				FROM qsiwindows
				WHERE windowid = @v_windowid
			END
		END
	END
	IF @v_helpurl IS NULL
	BEGIN
		SELECT @v_helpurl = stringvalue
		FROM clientdefaults
		WHERE clientdefaultid = 94
	END

	SELECT @v_helpurl AS helpurl
END 

GO

GRANT EXEC ON qutl_get_helpurl_by_qsiconfig TO PUBLIC
GO