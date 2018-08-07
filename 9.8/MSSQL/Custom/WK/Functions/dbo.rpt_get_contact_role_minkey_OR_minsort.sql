if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[rpt_get_contact_role_minkey_OR_minsort]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[rpt_get_contact_role_minkey_OR_minsort]
GO
CREATE FUNCTION [dbo].[rpt_get_contact_role_minkey_OR_minsort]
		(@i_globalcontactkey	INT,
		 @v_column	VARCHAR(1))
	RETURNS VARCHAR(255)

/*	The purpose of the rpt_get_contact_role function is to return a 
specific description column from gentables for a Role assigned to a 
contact based on min key role. If key role does not exist the function
returns the role type with minimum sortorder. 

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	
AS
BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_rolecode	INT
	

	SET @i_rolecode = NULL

	IF EXISTS (Select * FROM globalcontactrole WHERE globalcontactkey = @i_globalcontactkey and keyind = 1)
		BEGIN
				Select TOP 1 @i_rolecode = rolecode FROM globalcontactrole WHERE globalcontactkey = @i_globalcontactkey and keyind = 1 ORDER BY sortorder
		END 
	ELSE
		BEGIN
			Select TOP 1 @i_rolecode = rolecode FROM globalcontactrole WHERE globalcontactkey = @i_globalcontactkey  ORDER BY sortorder
		END

	IF @i_rolecode = NULL
		RETURN ''
		
	IF @v_column = 'D'
	BEGIN
		SELECT @v_desc = LTRIM(RTRIM(datadesc))
	     FROM gentables  
		 WHERE tableid = 285
			AND datacode = @i_rolecode
	END
	ELSE IF @v_column = 'E'
	BEGIN
		SELECT @v_desc = LTRIM(RTRIM(externalcode))
	 	 FROM	gentables  
		WHERE tableid = 285
		  AND datacode = @i_rolecode
	END
	ELSE IF @v_column = 'S'
	BEGIN
		SELECT @v_desc = LTRIM(RTRIM(datadescshort))
  		  FROM gentables  
		 WHERE  tableid = 285
		 	AND datacode = @i_rolecode
	END
	ELSE IF @v_column = 'B'
	BEGIN
		SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
		  FROM gentables  
		WHERE tableid = 285
		  AND datacode = @i_rolecode
	END
	ELSE IF @v_column = '1'
	BEGIN
		SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
		  FROM gentables  
		 WHERE tableid = 285
			AND datacode = @i_rolecode
	END
	ELSE IF @v_column = '2'
	BEGIN
		SELECT @v_desc = LTRIM(RTRIM(datadesc))
		  FROM gentables  
		 WHERE tableid = 285
			AND datacode = @i_rolecode
	END
	
	IF LEN(@v_desc) > 0
	BEGIN
		SELECT @RETURN = @v_desc
	END
	ELSE
	BEGIN
		SELECT @RETURN = ''
	END
	
	RETURN @RETURN

END
