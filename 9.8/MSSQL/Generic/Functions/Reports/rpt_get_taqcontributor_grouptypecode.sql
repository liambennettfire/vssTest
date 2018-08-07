IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_taqcontributor_grouptypecode') )
DROP FUNCTION dbo.rpt_get_taqcontributor_grouptypecode
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.rpt_get_taqcontributor_grouptypecode(
	@i_taqprojectkey INT,
	@i_rolecode	INT
)
RETURNS INT
AS

BEGIN

	DECLARE @RETURN			VARCHAR(80)
	DECLARE @v_grouptypecode			INT
	DECLARE @i_filterkey		INT
	DECLARE	@i_globalcontactkey	INT
	DECLARE @i_sortorder		INT
	DECLARE @i_count		INT

	BEGIN
			SELECT @i_globalcontactkey = bc.globalcontactkey
			FROM 	taqprojectcontactrole br, taqprojectcontact bc
			WHERE 	br.taqprojectcontactkey = bc.taqprojectcontactkey
					AND	bc.taqprojectkey = @i_taqprojectkey
					AND br.rolecode = @i_rolecode 
	END	

  SELECT @v_grouptypecode = grouptypecode
    FROM globalcontact
	 WHERE globalcontactkey = @i_globalcontactkey

	IF @v_grouptypecode = NULL 
     SELECT @v_grouptypecode = 0

	SELECT @RETURN = @v_grouptypecode
	
RETURN @RETURN
END

go

Grant all on rpt_get_taqcontributor_grouptypecode To public
go

