SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_addl_edition_description') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_addl_edition_description
GO

CREATE FUNCTION [dbo].[rpt_get_addl_edition_description] 
			(@i_bookkey	INT)

RETURNS	VARCHAR(120)

/*  
Created by Ben Todd 2011/05/03

The purpose of the rpt_get_addl_edition_description function is to return a value for additionaleditinfo.

Parameters

*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(500)
	DECLARE @v_desc			VARCHAR(500)
	DECLARE @v_edition_add_info		VARCHAR(120)
/* Begin Edition Procedure */
	BEGIN
		SELECT @v_edition_add_info = additionaleditinfo
		  FROM bookdetail
		 WHERE bookkey = @i_bookkey
	
		SELECT @v_desc =  
			CASE 
				WHEN @v_edition_add_info IS  NULL THEN ''
				WHEN @v_edition_add_info = '' THEN ''
				WHEN @v_edition_add_info IS NOT NULL or @v_edition_add_info <> '' and @v_desc = ''
				THEN @v_edition_add_info
            	ELSE ''
	        END
	END
	IF LEN(@v_desc) > 0
	BEGIN
		SELECT @RETURN = LTRIM(RTRIM(@v_desc))
	END
	ELSE
	BEGIN
		SELECT @RETURN = ''
	END
RETURN @RETURN
END
GO

GRANT ALL ON rpt_get_addl_edition_description TO PUBLIC
Go


