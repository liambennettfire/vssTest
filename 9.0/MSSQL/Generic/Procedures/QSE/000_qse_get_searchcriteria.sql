IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_searchcriteria')
BEGIN
  PRINT 'Dropping Procedure qse_get_searchcriteria'
  DROP PROCEDURE  qse_get_searchcriteria
END
GO

PRINT 'Creating Procedure qse_get_searchcriteria'
GO

CREATE PROCEDURE qse_get_searchcriteria
(
  @i_SearchTypeCode     INT,
  @i_SearchCriteriaKey  INT,
  @i_ParentCriteriaKey  INT,
  @i_QueryStrCriteria	BIT,
  @o_error_code			INT OUT,
  @o_error_desc			VARCHAR(2000) OUT 
)
AS

BEGIN
  DECLARE 
    @ErrorValue			INT,
    @SQLString			NVARCHAR(4000)

  SET NOCOUNT ON

  -- When SearchCriteriaKey is passed, retrieve values for THAT SearchCriteriaKey only.
  -- Otherwise, when NULL or ZERO SearchCriteriaKey is passed, don't narrow down the results and retrieve all values.

  -- Build and EXECUTE the dynamic SELECT statement
  SET @SQLString = N'SELECT COALESCE(d.parentcriteriakey,0) parentcriteriakey,
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
         c.querystring,
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
         dd.useorgfilterind,
         m.allowchangesforalltitlesinlistind   
    FROM qse_searchcriteria c
        LEFT OUTER JOIN gentablesdesc g ON c.gentableid = g.tableid 
        LEFT OUTER JOIN qse_searchcriteriadetail d ON c.searchcriteriakey = d.detailcriteriakey 
        LEFT OUTER JOIN bookmiscitems m ON c.misckey = m.misckey, 
        qse_searchtypecriteria t 
        LEFT OUTER JOIN qse_searchotherdropdown dd ON t.searchcriteriakey = dd.searchcriteriakey AND dd.dropdownlevel = 1
    WHERE c.searchcriteriakey = t.searchcriteriakey AND
        t.searchtypecode = ' + CONVERT(VARCHAR, @i_SearchTypeCode) 


  -- When SearchCriteriaKey is passed, add a whereclause to the retrieve
  -- only the row for the passed searchcriteriakey.
  IF @i_SearchCriteriaKey > 0
    SET @SQLString = @SQLString + N' AND c.searchcriteriakey = ' + CONVERT(VARCHAR, @i_SearchCriteriaKey)
  
  IF @i_ParentCriteriaKey > 0
    SET @SQLString = @SQLString + N' AND d.parentcriteriakey = ' + CONVERT(VARCHAR, @i_ParentCriteriaKey)
  
  IF @i_QueryStrCriteria > 0
    SET @SQLString = @SQLString + N' AND c.querystring IS NOT NULL'
      
  SET @SQLString = @SQLString + N' ORDER BY c.description'

  EXECUTE sp_executesql @SQLString

END
GO

GRANT EXEC ON qse_get_searchcriteria TO PUBLIC
GO
