
/****** Object:  UserDefinedFunction [dbo].[rpt_get_contact_role]    Script Date: 08/06/2015 12:22:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_contact_role]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_contact_role]
GO


/****** Object:  UserDefinedFunction [dbo].[rpt_get_contact_role]    Script Date: 08/06/2015 12:22:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_contact_role]
		(@i_globalcontactkey	INT,
		 @i_sortorder int,
		 @v_column	VARCHAR(1))
	RETURNS VARCHAR(255)

/*	The purpose of the rpt_get_contact_role function is to return a 
specific description column from gentables for a Role assigned to a 
contact based on sort order passed

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
	DECLARE @i_cursorrolecode int
	DECLARE @i_role_cursor_status int
	DECLARE @i_count int

	DECLARE cursor_role CURSOR 
	FOR
		SELECT  rolecode
		FROM	globalcontactrole
		WHERE	globalcontactkey = @i_globalcontactkey

	OPEN cursor_role
	
	FETCH NEXT FROM cursor_role INTO @i_cursorrolecode
	
	select @i_count=0
		
	select @i_role_cursor_status = @@FETCH_STATUS
	
	while (@i_role_cursor_status<>-1 )
	begin
		IF (@i_role_cursor_status<>-2)
		begin
			select @i_count = @i_count + 1
			if @i_count = @i_sortorder
			begin
				select @i_rolecode=@i_cursorrolecode
			end
		end /* End If status statement */
		
		FETCH NEXT FROM cursor_role INTO @i_cursorrolecode
		select @i_role_cursor_status = @@FETCH_STATUS
	end /** End Cursor While **/
	
	close cursor_role
	deallocate cursor_role
		
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

GO


