if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_add_countrygroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_add_countrygroup
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_add_countrygroup
 (@i_groupname						varchar(40),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_add_countrygroup
**  Desc: This procedure adds a new country group relation with the given name
**
**	Auth: Dustin Miller
**	Date: May 14 2012
*******************************************************************************/

  DECLARE @v_newdatacode		INT,
					@v_duplicatecount	INT,
					@v_lockresult			INT,
					@v_error					INT,
          @v_rowcount				INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT @v_duplicatecount = COUNT(*)
	FROM gentables
	WHERE tableid=633
		AND LOWER(datadesc) = LOWER(@i_groupname)
		
	IF @v_duplicatecount = 0
	BEGIN
		BEGIN TRANSACTION
		EXEC @v_lockresult = sp_getapplock @Resource = 'qcontract_add_countrygroup', @LockMode = 'Exclusive', @LockTimeout = 3000 --Time to wait for the lock
		IF @v_lockresult <> 0
		BEGIN
		 ROLLBACK TRANSACTION
		 SET @o_error_code = -1
		 SET @o_error_desc = 'Error. There is already a Country Group with that name (group name=' + @i_groupname + ')'
		END
		ELSE BEGIN
			SELECT @v_newdatacode = MAX(datacode) + 1
			FROM gentables
			WHERE tableid=633
			
			IF @v_newdatacode IS NULL
			BEGIN
				SET @v_newdatacode = 1
			END
			
			INSERT INTO gentables
			(tableid, datadesc, datadescshort, tablemnemonic, lockbyqsiind, datacode)
			VALUES
			(633, @i_groupname, 'World', 'CTRYGRP', 1, @v_newdatacode)
			
			COMMIT TRANSACTION
			SELECT @v_newdatacode AS datacode
		END
	END
	ELSE BEGIN
		SET @o_error_code = -1
    SET @o_error_desc = 'Error. There is already a Country Group with that name (group name=' + @i_groupname + ')'
    RETURN  
	END
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error inserting country group to gentables (group name=' + @i_groupname + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_add_countrygroup TO PUBLIC
GO