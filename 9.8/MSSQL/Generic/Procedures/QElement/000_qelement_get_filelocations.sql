if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_filelocations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qelement_get_filelocations
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qelement_get_filelocations
 (@i_elementkey           integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS
/******************************************************************************
**  File: qelement_get_filelocations
**  Name: qelement_get_filelocations
**  Desc: This procedure returns all filelocations for an element.  
**
**    Auth: Alan Katzen
**    Date: 29 May 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT,
          @rowcount_var INT
   
  SET @error_var = 0
  SET @rowcount_var = 0
       
  SELECT fl.*, dbo.get_gentables_desc(587,fl.stagecode,'long') stagedesc,
    dbo.get_gentables_desc(595,fl.locationtypecode,'long') locationtypedesc,
    COALESCE(dbo.get_gentables_desc(354,fl.filetypecode,'short'),dbo.get_gentables_desc(354,fl.filetypecode,'long')) filetypedesc,
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
  WHERE taqelementkey = @i_elementkey
ORDER BY fl.sortorder

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error returning file locations for element (elementkey = ' + cast(@i_elementkey as varchar) + ')'
    RETURN  
  END 
  
ExitHandler:

GO
GRANT EXEC ON qelement_get_filelocations TO PUBLIC
GO


