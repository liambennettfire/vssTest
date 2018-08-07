if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqveraddtlunits_by_format') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqveraddtlunits_by_format
GO

CREATE PROCEDURE qpl_get_taqveraddtlunits_by_format (  
  @i_projectkey     integer,
  @i_plstage        integer,
  @i_versionkey     integer,
  @i_formatkey      integer,
  @i_unitqsicode    integer,
  @i_excludeqsicode tinyint,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qpl_get_taqveraddtlunits_by_format
**  Desc: This stored procedure returns taqversionaddtlunits for given version/format.
**
**  @i_unitqsicode - qsicode for Unit Type (gentable 570)
**  @i_excludeqsicode - if FALSE is passed, only records for passed unitqsicode will be returned.
**                    - if TRUE is passed, all records EXCEPT passed qsicode will be returned.
**
**  Auth: Alan Katzen
**  Date: October 30 2007
**************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  IF @i_excludeqsicode = 1 BEGIN
    SELECT u.plunittypesubcode origplunittypesubcode, 0 total, s.subgen1ind, u.*
    FROM taqversionaddtlunits u, subgentables s
    WHERE u.plunittypecode = s.datacode AND
        u.plunittypesubcode = s.datasubcode AND
        s.tableid= 570 AND
        u.taqprojectkey = @i_projectkey AND
        u.plstagecode = @i_plstage AND 
        u.taqversionkey = @i_versionkey AND
        u.taqprojectformatkey = @i_formatkey AND
        u.plunittypecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 570 AND qsicode = @i_unitqsicode)
    ORDER BY u.plunittypecode, u.plunittypesubcode
  END
  ELSE BEGIN    
    SELECT u.plunittypesubcode origplunittypesubcode, 0 total, s.subgen1ind, u.*
    FROM taqversionaddtlunits u, subgentables s
    WHERE u.plunittypecode = s.datacode AND
        u.plunittypesubcode = s.datasubcode AND
        s.tableid= 570 AND
		u.taqprojectkey = @i_projectkey AND
        u.plstagecode = @i_plstage AND 
        u.taqversionkey = @i_versionkey AND
        u.taqprojectformatkey = @i_formatkey AND
        u.plunittypecode IN (SELECT datacode FROM gentables WHERE tableid = 570 AND qsicode = @i_unitqsicode)
    ORDER BY u.plunittypecode, u.plunittypesubcode    
  END  

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformat/taqversionaddtlunits tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqversionformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqveraddtlunits_by_format TO PUBLIC
GO
