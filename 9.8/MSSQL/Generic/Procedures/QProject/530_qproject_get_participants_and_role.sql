if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_participants_and_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_participants_and_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_participants_and_role
 (@i_projectkey           integer,
  @i_keyonly              bit,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS


/******************************************************************************
**  File: qproject_get_participants_and_role.sql
**  Name: qproject_get_participants_and_role
**  Desc: This stored procedure gets the particpants and their roles for the 
**        project.  Use this procedure if you need to show participants and
**        each role as a seperate item.
**
**    Auth: Alan Katzen
**    Date: 26 August 2004
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @error_var = 0
  SET @rowcount_var = 0
  
  IF @i_keyonly is null or @i_keyonly = 0 BEGIN
    select r.taqprojectcontactkey, r.taqprojectcontactrolekey, r.rolecode, p.globalcontactkey, 
      ltrim(rtrim(COALESCE(c.displayname,''))) contactname, ltrim(rtrim(dbo.get_gentables_desc(285,r.rolecode,'long'))) roledesc,
      participantrole = ltrim(rtrim(COALESCE(c.displayname,''))) + COALESCE(' - ' + ltrim(rtrim(dbo.get_gentables_desc(285,r.rolecode,'long'))),'')  
     from taqprojectcontact p, corecontactinfo c, taqprojectcontactrole r
     where p.taqprojectkey = @i_projectkey and
           p.taqprojectkey = r.taqprojectkey and
           p.taqprojectcontactkey = r.taqprojectcontactkey and
           p.globalcontactkey = c.contactkey
     order by p.sortorder, c.displayname
  END
  ELSE BEGIN
    select r.taqprojectcontactkey, r.taqprojectcontactrolekey, r.rolecode, p.globalcontactkey,
      ltrim(rtrim(COALESCE(c.displayname,''))) contactname, ltrim(rtrim(dbo.get_gentables_desc(285,r.rolecode,'long'))) roledesc,
      participantrole = ltrim(rtrim(COALESCE(c.displayname,''))) + COALESCE(' - ' + ltrim(rtrim(dbo.get_gentables_desc(285,r.rolecode,'long'))),'')  
     from taqprojectcontact p, corecontactinfo c, taqprojectcontactrole r
     where p.taqprojectkey = @i_projectkey and
           p.keyind  = 1 and
           p.taqprojectkey = r.taqprojectkey and
           p.taqprojectcontactkey = r.taqprojectcontactkey and
           p.globalcontactkey = c.contactkey
     order by p.sortorder, c.displayname

  END
  
ExitHandler:

 

GO
GRANT EXEC ON qproject_get_participants_and_role TO PUBLIC
GO


