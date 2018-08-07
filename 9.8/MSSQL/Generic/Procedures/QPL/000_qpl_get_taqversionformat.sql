if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionformat') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionformat
GO

CREATE PROCEDURE qpl_get_taqversionformat (  
  @i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_formatkey    integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversionformat
**  Desc: This stored procedure returns given version format information.
**
**  Auth: Kate
**  Date: January 7 2008
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  SELECT f.*, g.datadesc + '/' + s.datadesc formatdesc
  FROM taqversionformat f
    LEFT OUTER JOIN gentables g ON g.tableid = 312 AND g.datacode = f.mediatypecode
    LEFT OUTER JOIN subgentables s ON s.tableid = 312 AND s.datacode = f.mediatypecode AND s.datasubcode = f.mediatypesubcode  
  WHERE f.taqprojectkey = @i_projectkey AND
    f.plstagecode = @i_plstage AND 
    f.taqversionkey = @i_versionkey AND
    f.taqprojectformatkey = @i_formatkey

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformat table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversionformat TO PUBLIC
GO
