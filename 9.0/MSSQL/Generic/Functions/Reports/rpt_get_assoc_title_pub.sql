
/****** Object:  UserDefinedFunction [dbo].[rpt_get_assoc_title_pub]    Script Date: 03/24/2009 11:46:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_assoc_title_pub') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_assoc_title_pub
GO
CREATE FUNCTION [dbo].[rpt_get_assoc_title_pub]
		(@i_bookkey	INT,
		@i_order	INT,
		@i_type		INT)

RETURNS VARCHAR(80)



AS

BEGIN

	DECLARE @RETURN			VARCHAR(80)
	DECLARE @v_pub		VARCHAR(80)
	DECLARE @i_assocbookkey		INT
	DECLARE @origpubcode 		INT
	DECLARE @assocorigpub		VARCHAR(40)

	SELECT @i_assocbookkey = associatetitlebookkey,
		@origpubcode = origpubhousecode
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey 
			AND sortorder = @i_order	
			AND associationtypecode = @i_type

	IF @i_assocbookkey > 0
		BEGIN
			SELECT @v_pub = dbo.rpt_get_group_level_2(@i_assocbookkey,'F')
			FROM bookdetail
			WHERE bookkey = @i_assocbookkey
		END
	ELSE
	IF @i_assocbookkey =0
		BEGIN
			SELECT @v_pub = datadesc
			FROM gentables
			WHERE tableid = 126 AND datacode = @origpubcode
		END

	IF LEN(@v_pub) > 0
		BEGIN
			SELECT @RETURN = @v_pub
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END
	

RETURN @RETURN


END
go
Grant All on dbo.rpt_get_assoc_title_pub to Public
go