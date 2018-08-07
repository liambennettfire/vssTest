
/****** Object:  UserDefinedFunction [dbo].[rpt_get_taqcontributor]    Script Date: 03/24/2009 13:17:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_taqcontributor') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_taqcontributor
GO
CREATE FUNCTION [dbo].[rpt_get_taqcontributor](
	@i_taqprojectkey INT,
	@i_rolecode	INT,
	@v_column	VARCHAR(1)
)
RETURNS VARCHAR(80)
AS
/*  	Parameter Options
		@i_taqprojectkey

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
	DECLARE	@i_globalcontactkey	INT
	DECLARE @i_sortorder		INT
	DECLARE @i_count		INT


	SELECT @v_column = UPPER(@v_column)


		BEGIN
			SELECT @i_globalcontactkey = bc.globalcontactkey
			FROM 	taqprojectcontactrole br, taqprojectcontact bc
			WHERE 	br.taqprojectcontactkey = bc.taqprojectcontactkey
					AND	bc.taqprojectkey = @i_taqprojectkey
					AND br.rolecode = @i_rolecode 


--FROM 	bookcontactrole
			--WHERE 	bookkey = @i_bookkey
				--	AND rolecode = @i_rolecode 
		END	

	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(displayname))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

	IF @v_column = 'F'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(firstname))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

	IF @v_column = 'L'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(lastname))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

	IF @v_column = 'M'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(middlename))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

/*	IF @v_column = 'T'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(title))
			FROM globalcontact
			WHERE globalcontactkey = @i_taqprojectcontactkey
		END
*/
	IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(shortname))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

/*	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(externalcode))
			FROM globalcontact
			WHERE globalcontactkey = @i_taqprojectcontactkey
		END
*/

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
Grant All on dbo.rpt_get_taqcontributor to Public
go