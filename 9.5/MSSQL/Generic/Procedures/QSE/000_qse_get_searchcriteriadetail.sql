IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_searchcriteriadetail')
BEGIN
  PRINT 'Dropping Procedure qse_get_searchcriteriadetail'
  DROP PROCEDURE  qse_get_searchcriteriadetail
END
GO

PRINT 'Creating Procedure qse_get_searchcriteriadetail'
GO

CREATE PROCEDURE qse_get_searchcriteriadetail
(
  @i_SearchTypeCode   INT,
  @i_SearchCriteriaKey  INT,
  @o_error_code   INT OUT,
  @o_error_desc   VARCHAR(2000) OUT 
)
AS

BEGIN
  DECLARE 
    @ErrorValue INT,
    @SQLString  NVARCHAR(4000)

  SET NOCOUNT ON

  -- When SearchCriteriaKey is passed, retrieve values for THAT SearchCriteriaKey only.
  -- Otherwise, when NULL or ZERO SearchCriteriaKey is passed, don't narrow down the results and retrieve all values.

  -- Build and EXECUTE the dynamic SELECT statement
  SET @SQLString = N' SELECT d.parentcriteriakey, 
      d.sortorder,
      c.searchcriteriakey,
      c.description,
      c.datatypecode,
      c.defaultoperator,
      c.gentableid,
      c.allowmultiplerowsind,
      c.allowrangeind,
      c.allowbestind,
      c.stripdashesind,
      c.detailcriteriaind,
      c.parentcriteriaind,
      c.useshortdescind,
      c.allowmultiplevaluesind,
      c.multvalueseparator,
      c.misckey,
      m.datacode,
      g.subgenallowed,
      g.sub2genallowed,
      t.tablename,
      t.columnname,
      t.subgencolumnname,
      t.subgen2columnname,
      t.secondtablename,
      t.secondcolumnname,
      t.bestcolumnname,
      dd.sourcetable,
      dd.datacolumn,
      dd.displaycolumn,
      dd.sortstring,
      dd.useorgfilterind
  FROM qse_searchcriteria c 
      LEFT OUTER JOIN gentablesdesc g ON c.gentableid = g.tableid 
      LEFT OUTER JOIN bookmiscitems m ON c.misckey = m.misckey, 
      qse_searchtypecriteria t
      LEFT OUTER JOIN qse_searchotherdropdown dd ON t.searchcriteriakey = dd.searchcriteriakey AND dd.dropdownlevel = 1,   
      qse_searchcriteriadetail d
  WHERE c.searchcriteriakey = d.detailcriteriakey AND
      c.searchcriteriakey = t.searchcriteriakey AND      
      t.searchtypecode = ' + CONVERT(VARCHAR, @i_SearchTypeCode)

  -- When SearchCriteriaKey is passed, add a whereclause to the retrieve
  -- only the row for the passed searchcriteriakey.
  IF @i_SearchCriteriaKey > 0
  BEGIN
    SET @SQLString = @SQLString + N' AND d.parentcriteriakey = ' + CONVERT(VARCHAR, @i_SearchCriteriaKey)
  END
      
  SET @SQLString = @SQLString + N' ORDER BY d.sortorder, c.description'

  EXECUTE sp_executesql @SQLString

END
GO

GRANT EXEC ON qse_get_searchcriteriadetail TO PUBLIC
GO

