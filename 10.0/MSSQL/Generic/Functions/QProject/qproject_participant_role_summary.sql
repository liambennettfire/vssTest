if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_participant_role_summary') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_participant_role_summary
GO

CREATE FUNCTION qproject_participant_role_summary
    ( @i_taqprojectkey as integer,
      @i_taqprojectcontactkey as integer) 

RETURNS varchar(256)

/******************************************************************************
**  File: qproject_participant_role_summary.sql
**  Name: qproject_participant_role_summary
**  Desc: This returns a string which gives a summary of the roles which
**        the participant has in the project. 
**
**
**    Auth: James Weber
**    Date: 31 May 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:      Description:
**    --------  --------     -------------------------------------------
**    04/12/18  Colman       50857 - Performance improvement
*******************************************************************************/

BEGIN 
  DECLARE @finalValue varchar(256)

  SELECT @finalValue = COALESCE(@finalValue + ', ', '') + g.datadesc
  FROM taqprojectcontact c, taqprojectcontactrole r, gentables g
  WHERE c.taqprojectkey = @i_taqprojectkey
    AND c.taqprojectcontactkey = @i_taqprojectcontactkey
    AND c.taqprojectkey = r.taqprojectkey
    AND c.taqprojectcontactkey = r.taqprojectcontactkey
    AND g.tableid = 285
    AND g.datacode = r.rolecode

  RETURN ISNULL(@finalValue, '')

END
GO

GRANT EXEC ON dbo.qproject_participant_role_summary TO public
GO
