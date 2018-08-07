
/****** Object:  UserDefinedFunction [dbo].[rpt_get_merchandising_theme]    Script Date: 03/24/2009 13:11:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_merchandising_theme') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_merchandising_theme
GO
CREATE FUNCTION [dbo].[rpt_get_merchandising_theme]
		(@i_bookkey	INT,
		@i_order	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(510)

/*	returns the Merchandising Theme as 
	Parameter Options

		Order
			1 = Returns first Merchandising Theme
			2 = Returns second Merchandising Theme
			3 = Returns third Merchandising Theme
			4
			5
			.
			.
			.
			n			

		Column
			D = Data Description Major/Minor
			E = External code - from subgentables
			S = Short Description - from subgentables
			
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(500)
	DECLARE @v_desc			VARCHAR(500)
	DECLARE @i_categorycode			INT
	DECLARE @i_categorysubcode		INT

	SELECT @i_categorycode = categorycode,
		@i_categorysubcode = categorysubcode
	FROM	booksubjectcategory
	WHERE	bookkey = @i_bookkey and sortorder = @i_order
    and categorytableid=558


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(g.datadesc))+'/'+LTRIM(RTRIM(s.datadesc))
			FROM booksubjectcategory b,gentables g, subgentables s
			WHERE g.tableid = 558 
					AND s.tableid = 558 
					AND g.datacode = @i_categorycode
					AND s.datacode = @i_categorycode
					AND s.datasubcode = @i_categorysubcode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	subgentables  
			WHERE  tableid = 558
					AND datacode = @i_categorycode
					AND datasubcode = @i_categorysubcode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	subgentables  
			WHERE  tableid = 558
					AND datacode = @i_categorycode
					AND datasubcode = @i_categorysubcode
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


go
Grant All on dbo.rpt_get_merchandising_theme to Public
go