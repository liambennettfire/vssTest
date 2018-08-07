
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
	@i_printingkey int,
	@i_sortorder Int,
	@v_column	VARCHAR(1)
)
RETURNS VARCHAR(250)
AS
/*  	JSD 4-25-2016 Function was modified to include printingkey and sortorder.  
	Additionally going off the globalcontact table for values rather than the person table

		Parameter Options
		@i_bookkey

		@i_rolecode
			RoleType from gentables

			D = returns the display name
			F = returns the first name
			L = returns the middle name
			S = returns the short name 
			E = returns the external code 1
			C = Complete Name (nameabbrev + firstname + mi + lastname + suffix)
			@i_printingkey
			@i_sortorder
												*/

BEGIN

	DECLARE @RETURN			VARCHAR(80)
	DECLARE @v_desc			VARCHAR(80)
	DECLARE	@i_globalcontactkey	INT
	DECLARE @v_nameabbrev			VARCHAR(255)
	DECLARE @v_firstname			VARCHAR(255)
	DECLARE @v_middlename			VARCHAR(255)
	DECLARE @v_lastname			VARCHAR(255)
	DECLARE @v_suffix			VARCHAR(255)
	



	SELECT @v_column = UPPER(@v_column)
	

		BEGIN
			SELECT @i_globalcontactkey = globalcontactkey
			FROM 	rpt_resync_sortorder_bookcontact_View
			WHERE 	bookcontactkey = bookcontactkey
					AND	bookkey = @i_bookkey
					AND rolecode = @i_rolecode 
					AND printingkey=@i_printingkey
					and new_sort_order=@i_sortorder 

					
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

--	IF @v_column = 'T'
--		BEGIN
--			SELECT @v_desc = RTRIM(LTRIM(title))
--			FROM globalcontact
--			WHERE globalcontactkey = @i_globalcontactkey
--		END

	IF @v_column = 'S'
-- temporarily return lastname as the short name doesn't yet exist in
-- the early version of 7.0 this function written against. to be changed in next release
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(shortname))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

	IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(externalcode1))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

	
	IF @v_column = 'C' 
	BEGIN
		SELECT @v_nameabbrev = g.datadesc
		FROM	gentables g, globalcontact a
		WHERE	g.tableid = 210
			AND a.globalcontactkey = @i_globalcontactkey
			AND a.accreditationcode = g.datacode


		SELECT @v_firstname = firstname,
			@v_middlename = middlename,
			@v_lastname = lastname,
			@v_suffix = suffix
		FROM globalcontact
		WHERE globalcontactkey = @i_globalcontactkey

		SELECT @v_desc =  
			CASE 
				WHEN @v_nameabbrev IS NULL THEN  ''
				WHEN @v_nameabbrev IS NOT NULL THEN @v_nameabbrev + ' '
						ELSE ''
				END

			+CASE 
				WHEN @v_firstname IS  NULL THEN ''
    					ELSE @v_firstname
  				END

  				+CASE 
				WHEN @v_middlename IS NULL and @v_firstname is NOT NULL THEN ' '
				WHEN @v_middlename IS NULL and @v_firstname is NULL THEN ''
				WHEN @v_middlename is NOT NULL and @v_firstname is NOT NULL THEN ' '+@v_middlename+ ' '
    					ELSE ''
  				END

  				+ @v_lastname

  				+ CASE 
				WHEN @v_suffix IS NOT NULL THEN ' ' + @v_suffix
		        	ELSE ''
				END

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