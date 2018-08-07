if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_filelocations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_filelocations
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_filelocations
 (@i_projectkey           integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_filelocations
**  Desc: This procedure returns all filelocations for a project.  
**
**	Auth: Kate
**	Date: 6 January 2009
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SELECT fl.*, dbo.get_gentables_desc(587,fl.stagecode,'long') stagedesc,
    dbo.get_gentables_desc(595,fl.locationtypecode,'long') locationtypedesc,
    COALESCE(dbo.get_gentables_desc(354,fl.filetypecode,'short'), dbo.get_gentables_desc(354,fl.filetypecode,'long')) filetypedesc,
    dbo.get_gentables_desc(357,fl.filestatuscode,'long') statusdesc,
    CASE WHEN DATALENGTH(fl.notes) > 10 THEN
      CAST(fl.notes AS VARCHAR(10)) + '...'
      ELSE fl.notes
    END AS filelocationnotes,
    CASE WHEN fl.filelocationkey > 0 THEN
      '~\' + dbo.qutl_get_filelocation_rootpath(fl.filelocationkey,'logical') + '\' + pathname
      ELSE pathname
    END AS fullpathname 
  FROM filelocation fl
  WHERE taqprojectkey = @i_projectkey
  ORDER BY fl.sortorder

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning file locations for project (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qproject_get_filelocations TO PUBLIC
GO


