if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pltemplate_formats') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_pltemplate_formats
GO

CREATE PROCEDURE qpl_get_pltemplate_formats (  
  @i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_orgfilter    VARCHAR(MAX),  
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_pltemplate_formats
**  Desc: This stored procedure returns all formats for the active P&L template
**        based on given version's criteria.
**
**  Auth: Kate
**  Date: November 2 2011
**************************************************************************************/

DECLARE
  @v_active_status  INT,
  @v_error  INT,
  @v_pltype INT,
  @v_plsubtype  INT,
  @v_relstrategy  INT,
  @v_sql  NVARCHAR(4000),
  @v_templatekey  INT

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_active_status = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 3

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not get active P&L Status from gentables 522.'
    SET @o_error_code = -1
    RETURN
  END
  
  SELECT @v_pltype = pltypecode, @v_plsubtype = pltypesubcode, @v_relstrategy = releasestrategycode
  FROM taqversion
  WHERE taqprojectkey = @i_projectkey AND
    plstagecode = @i_plstage AND
    taqversionkey = @i_versionkey
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not get P&L Version details from taqversion.'
    SET @o_error_code = -1
    RETURN
  END    

  EXEC qpl_get_pltemplate_key @i_orgfilter, @v_active_status, @v_pltype, @v_plsubtype, @v_relstrategy, 
    @v_templatekey OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

  IF @o_error_code < 0
    RETURN
          
  SELECT f.taqprojectformatkey, p.taqprojecttitle + ' -- ' + g.datadesc + '/' + s.datadesc fullformatdesc
  FROM taqversionformat f, taqproject p, gentables g, subgentables s
  WHERE f.taqprojectkey = p.taqprojectkey AND
    f.mediatypecode = s.datacode AND
    f.mediatypesubcode = s.datasubcode AND
    g.tableid = s.tableid AND
    g.datacode = s.datacode AND
    g.tableid = 312 AND
    f.taqprojectkey = @v_templatekey AND
    f.plstagecode = 0 AND 
    f.taqversionkey = 1
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not get P&L Template formats from taqversionformat.'
    SET @o_error_code = -1
    RETURN
  END
  
END
GO

GRANT EXEC ON qpl_get_pltemplate_formats TO PUBLIC
GO


