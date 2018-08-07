if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionclientvalues') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionclientvalues
GO

CREATE PROCEDURE qpl_get_taqversionclientvalues (  
  @i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/************************************************************************************
**  Name: qpl_get_taqversionclientvalues
**  Desc: This stored procedure returns all P&L Client Values for the given version.
**
**  Auth: Kate
**  Date: November 11 2009
*************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   

  SELECT g.datacode, g.datadesc, v.clientvalue
  FROM gentables g 
    LEFT OUTER JOIN taqversionclientvalues v ON v.clientvaluecode = g.datacode AND 
      v.taqprojectkey = @i_projectkey AND
      v.plstagecode = @i_plstage AND
      v.taqversionkey = @i_versionkey
  WHERE g.tableid = 614 AND g.deletestatus = 'N'
  ORDER BY g.sortorder, g.datadesc

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access gentables/taqversionclientvalues tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqversionclientvalues TO PUBLIC
GO
