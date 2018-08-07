if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionformat_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionformat_list
GO

CREATE PROCEDURE qpl_get_taqversionformat_list (  
  @i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_versionjoin  integer,
  @i_includeshared  tinyint,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***************************************************************************************************************************
**  Name: qpl_get_taqversionformat_list
**  Desc: This stored procedure returns all formats for given projectkey and P&L Level.
**
**  Auth: Kate
**  Date: September 21 2007
****************************************************************************************************************************
**  Change History
****************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**	12/06/16    Dustin    Case 41185
**  11/13/17    Colman    Case 48274 - Use gentables sortorder
**  07/24/18    Colman    TM-584     - Support for "shared cost" formats
****************************************************************************************************************************/

BEGIN

  --exec qutl_trace 'qpl_get_taqversionformat_list',
  --  '@i_projectkey', @i_projectkey, NULL,
  --  '@i_plstage', @i_plstage, NULL,
  --  '@i_versionkey', @i_versionkey, NULL,
  --  '@i_versionjoin', @i_versionjoin, NULL,
  --  '@i_includeshared', @i_includeshared, NULL

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  IF @i_versionjoin = 1
    SELECT f.mediatypesubcode origformat, ISNULL(f.description, s.datadesc) formatdesc, v.avgroyaltyenteredind, 
        f.taqprojectformatkey, f.taqprojectformatkey taqversionformatkey, f.mediatypecode, f.mediatypesubcode, f.sharedposectionind
    FROM taqversionformat f, taqversion v, subgentables s, gentables g
    WHERE f.taqprojectkey = v.taqprojectkey AND
        f.plstagecode = v.plstagecode AND
        f.taqversionkey = v.taqversionkey AND
        f.mediatypecode = s.datacode AND
        f.mediatypesubcode = s.datasubcode AND
        s.tableid = 312 AND
        f.taqprojectkey = @i_projectkey AND
        f.plstagecode = @i_plstage AND 
        f.taqversionkey = @i_versionkey AND
        g.tableid = 312 AND g.datacode = s.datacode AND
        (@i_includeshared = 1 OR ISNULL(f.sharedposectionind, 0) = 0)
      ORDER BY g.sortorder, s.sortorder
  ELSE
    SELECT f.mediatypesubcode origformat, f.description, ISNULL(s.datadesc, f.description) formatdesc, 
      CASE
        WHEN f.description IS NOT NULL THEN f.description
        WHEN f.mediatypesubcode > 0 THEN g.datadesc + '/' + s.datadesc
        WHEN f.mediatypecode > 0 THEN g.datadesc
        ELSE 'System Generated Format'
      END fullformatdesc,
      f.taqprojectformatkey, f.taqprojectformatkey taqversionformatkey, f.mediatypecode, f.mediatypesubcode, f.sharedposectionind, f.formatpercentage, f.formatpercentchangedind
    FROM taqversionformat f
      LEFT OUTER JOIN gentables g ON g.tableid = 312 AND g.datacode = f.mediatypecode
      LEFT OUTER JOIN subgentables s ON s.tableid = 312 AND s.datacode = f.mediatypecode AND s.datasubcode = f.mediatypesubcode
    WHERE f.taqprojectkey = @i_projectkey AND
      f.plstagecode = @i_plstage AND 
      f.taqversionkey = @i_versionkey AND
      (@i_includeshared = 1 OR ISNULL(f.sharedposectionind, 0) = 0)
    ORDER BY g.sortorder, s.sortorder

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformat/subgentables tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversionformat_list TO PUBLIC
GO
