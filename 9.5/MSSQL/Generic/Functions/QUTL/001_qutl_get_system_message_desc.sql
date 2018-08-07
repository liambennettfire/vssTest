IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qutl_get_system_message_desc') AND xtype in (N'FN', N'IF', N'TF'))
  DROP FUNCTION dbo.qutl_get_system_message_desc
GO

CREATE FUNCTION dbo.qutl_get_system_message_desc
(
  @i_datacode as INT,
  @i_datasubcode as INT
)
RETURNS VARCHAR(2000)

/***************************************************************************************************************
**  Name: qutl_get_system_message_desc
**  Desc: This function takes 2 input parameters - a datacode and datasubcode for tableid 678 (Standard System
**        Messages) and generates an error message
**        The error message presented to the user should look like this:
**        MESSAGECODE (datadescshort-datacode-datasubcode): user friendly message (subgentables_ext.gentext1). 
**        For further information, please see helplink (subgentables_ext.gentext2)
**        If datadescshort does not exist, use datadesc, if gentext1 doesn't exist, use subgentables.datadesc, 
**        If gentext2 doesn't exist, don't show the helplink sentence.
**
**        Example
**        TASK-2-15: You are trying to add a task that is restricted. Only one per Title is allowed. 
**        For further information, please see https://askburnie.firebrandtech.com/posts/648556-task-tracking
**
**        Function returns the formatted error message.
**
**  Auth: Kusum Basra
**  Date: 2 March 2016
****************************************************************************************************************/

BEGIN
	DECLARE 
		@v_formatted_string VARCHAR(2000),
		@v_datadescshort    VARCHAR(20),
		@v_gentext1         VARCHAR(255),
		@v_gentext2         VARCHAR(255),
		@v_datadesc         VARCHAR(120)
		
	SET @v_formatted_string = ''
	
	IF COALESCE(@i_datacode,0) = 0
		RETURN @v_formatted_string
		
	--IF COALESCE(@i_datasubcode,0) = 0
	--	RETURN @v_formatted_string
	
	IF COALESCE(@i_datasubcode,0) > 0 BEGIN
		SELECT @v_datadescshort = COALESCE(datadescshort,''),@v_datadesc = COALESCE(datadesc,'') FROM subgentables WHERE tableid = 678 and datacode = @i_datacode AND datasubcode = @i_datasubcode
		SELECT @v_gentext1 = COALESCE(gentext1,''), @v_gentext2 = COALESCE(gentext2,'') FROM subgentables_ext WHERE tableid = 678 and datacode = @i_datacode AND datasubcode = @i_datasubcode
	END
	ELSE BEGIN
		SELECT @v_datadescshort = ''
		SELECT @v_datadesc =  COALESCE(datadesc,'') FROM gentables WHERE tableid = 678 and datacode = @i_datacode 
		SELECT @v_gentext1 = ''
		SELECT @v_gentext2 = ''
	END
	
	
	IF @v_datadescshort <> ''
		SET @v_formatted_string = @v_datadescshort + '-' + CAST(@i_datacode AS VARCHAR) + '-' + CAST(@i_datasubcode AS VARCHAR) 
	ELSE IF @v_datadesc <> ''
		SET @v_formatted_string = @v_datadesc + '-' + CAST(@i_datacode AS VARCHAR) + '-' + CAST(@i_datasubcode AS VARCHAR) 
		
	IF @v_gentext1 <> ''
		SET @v_formatted_string = @v_formatted_string + ': ' + @v_gentext1 + '.'
	ELSE 
		SET @v_formatted_string = @v_formatted_string + '.'
		
	IF @v_gentext2 <> ''
		SET @v_formatted_string = @v_formatted_string + CHAR(10) +  ' For further information, please see: ' + @v_gentext2

	RETURN @v_formatted_string

END
GO

GRANT EXEC ON dbo.qutl_get_system_message_desc TO public
GO