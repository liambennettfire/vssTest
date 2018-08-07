if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_reader_tasks') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_reader_tasks
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_reader_tasks
 (@i_projectkey     integer,
  @i_contactrolekey integer,
  @i_taqelementkey  integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_reader_tasks
**  Desc: This stored procedure returns subject information
**        from the taqprojecttask table. 
**
**    Auth: Kate
**    Date: 5/30/04
*******************************************************************************
*******************************************************************************
**
**	08/26/08 - Lisa see comment below
**  09/12/08 - Lisa needed this to return globalcontactkey for a subsequent
**				update to TaqProjectTask via the application.
**
*******************************************************************************/

  DECLARE @error_var  INT,
      @rowcount_var   INT,
      @v_quote    CHAR(1),
      @SearchSQL  NVARCHAR(4000)

  SET @v_quote = CHAR(39)
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET NOCOUNT ON
  
  -- 08/26/08 Lisa modified @SearchSQL to use taqprojectcontactrole table for taqprojectcontactrolekey
  -- instead of taqprojecttask  see case 05322  NOTE that it is only currently using globalcontactkey
  -- on taqprojecttask, not globalcontactkey2 which is intended for Managers of readers.
  
  SET @SearchSQL = N'select t.taqtaskkey, t.taqprojectkey, cr.taqprojectcontactrolekey,
					t.taqelementkey, t.datetypecode, t.activedate, t.actualind, t.originaldate,
					CASE 
						WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel))= ' + @v_quote + @v_quote + ' 
						THEN d.description
						ELSE d.datelabel
					END datelabel,
					t.paymentamt, t.taqtaskqty, d.sortorder, e.taqelementdesc, e.taqelementnumber,
					pc.globalcontactkey, t.rolecode
					from taqprojectreaderiteration ri
					join taqprojectcontactrole cr on ri.taqprojectkey = cr.taqprojectkey 
												and ri.taqprojectcontactrolekey = cr.taqprojectcontactrolekey
					join taqprojectcontact pc on cr.taqprojectcontactkey = pc.taqprojectcontactkey
					join taqprojecttask t on t.taqprojectkey = ri.taqprojectkey and 
											 t.taqelementkey = ri.taqelementkey and
											  t.globalcontactkey = pc.globalcontactkey
					join taqprojectelement e on t.taqprojectkey = e.taqprojectkey and 
											 t.taqelementkey = e.taqelementkey 
					join datetype d on t.datetypecode = d.datetypecode
					where ri.taqprojectkey = ' + CONVERT(VARCHAR, @i_projectkey) + ' and 
						  cr.taqprojectcontactrolekey = ' + CONVERT(VARCHAR, @i_contactrolekey)

  -- When 0 taqelementkey is passed, all iterations should be displayed
  -- and therefore we will not narrow down by elementkey
  IF @i_taqelementkey > 0
    SET @SearchSQL = @SearchSQL + N' AND ri.taqelementkey = ' + 
      CONVERT(VARCHAR, @i_taqelementkey)
  
  -- Sort tasks by task sortorder and iteration number
  SET @SearchSQL = @SearchSQL + N' ORDER BY e.taqelementnumber DESC, d.sortorder, datelabel'

  PRINT @SearchSQL
  
  -- EXECUTE the dynamic SELECT statement
  EXECUTE sp_executesql @SearchSQL 

GO

GRANT EXEC ON qproject_get_reader_tasks TO PUBLIC
GO
