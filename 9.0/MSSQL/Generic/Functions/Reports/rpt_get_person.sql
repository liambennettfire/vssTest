
/****** Object:  UserDefinedFunction [dbo].[rpt_get_person]    Script Date: 03/24/2009 13:12:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_person') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_person
GO
CREATE FUNCTION [dbo].[rpt_get_person](
	@i_bookkey	INT,
	@i_rolecode	INT,
	@v_column	VARCHAR(1)
)
RETURNS VARCHAR(80)
AS
/*  	Parameter Options
		@i_bookkey

		@i_rolecode
			RoleType from gentables

		@v_column
			D = returns the display name
			F = returns the first name
			L = returns the middle name
			T = returns the title
			S = returns the short name
			E = returns the external code
												*/

BEGIN

	DECLARE @RETURN			VARCHAR(80)
	DECLARE @v_desc			VARCHAR(80)
	DECLARE @i_filterkey		INT
	DECLARE	@i_bookcontactkey	INT
	DECLARE @i_sortorder		INT
	DECLARE @i_count		INT


	SELECT @v_column = UPPER(@v_column)


		BEGIN
			SELECT @i_bookcontactkey = br.bookcontactkey
			FROM 	bookcontactrole br, bookcontact bc
			WHERE 	br.bookcontactkey = bc.bookcontactkey
					AND	bc.bookkey = @i_bookkey
					AND br.rolecode = @i_rolecode 


--FROM 	bookcontactrole
			--WHERE 	bookkey = @i_bookkey
				--	AND rolecode = @i_rolecode 
		END	

	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(displayname))
			FROM person
			WHERE contributorkey = @i_bookcontactkey
		END

	IF @v_column = 'F'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(firstname))
			FROM person
			WHERE contributorkey = @i_bookcontactkey
		END

	IF @v_column = 'L'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(lastname))
			FROM person
			WHERE contributorkey = @i_bookcontactkey
		END

	IF @v_column = 'M'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(middlename))
			FROM person
			WHERE contributorkey = @i_bookcontactkey
		END

	IF @v_column = 'T'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(title))
			FROM person
			WHERE contributorkey = @i_bookcontactkey
		END

	IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(shortname))
			FROM person
			WHERE contributorkey = @i_bookcontactkey
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(externalcode))
			FROM person
			WHERE contributorkey = @i_bookcontactkey
		END


	IF LEN(@v_desc)> 0
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
Grant All on dbo.rpt_get_person to Public
go