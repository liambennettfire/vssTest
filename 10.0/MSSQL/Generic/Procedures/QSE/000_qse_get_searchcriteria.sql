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

/*************************************************************************************************************************
**  Name: qse_get_searchcriteria
**  Desc: 
**
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:        Author:   Description:
**  ----------   -------   -----------------------------------------------------------------------------------------------
**  04/18/2018   Colman    Case 51433 Custom item type filtering for criteria
**************************************************************************************************************************/

BEGIN
  DECLARE 
    @ErrorValue			INT,
    @SQLString			NVARCHAR(4000),
	@v_windowid_title	INT,
	@v_windowid_project INT    

  SET NOCOUNT ON

  -- When SearchCriteriaKey is passed, retrieve values for THAT SearchCriteriaKey only.
  -- Otherwise, when NULL or ZERO SearchCriteriaKey is passed, don't narrow down the results and retrieve all values.
  
  SELECT @v_windowid_title = windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'productsummary'
  SELECT @v_windowid_project = windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'projectsummary'  

  -- Build and EXECUTE the dynamic SELECT statement
  SET @SQLString = N'SELECT COALESCE(d.parentcriteriakey,0) parentcriteriakey,
         d.sortorder,
         c.searchcriteriakey,
         c.description,
         c.datatypecode,
         c.defaultoperator,
         c.gentableid,
         c.itemtypefilter,
         c.usageclassfilter,
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
         c.fulltextsearchind,
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
         m.allowchangesforalltitlesinlistind,
         CASE
         WHEN t.searchtypecode = ' + CONVERT(VARCHAR, 15) + ' AND EXISTS(SELECT * FROM securityobjectsavailable s WHERE s.windowid = ' + CONVERT(VARCHAR, @v_windowid_title) + ' AND s.criteriakey = c.searchcriteriakey)
			  THEN (SELECT TOP(1) LTRIM(RTRIM(LOWER(COALESCE(s.availobjectid, '''') + COALESCE(''.'' + s.availobjectname, '''')))) FROM securityobjectsavailable s WHERE s.windowid = ' + CONVERT(VARCHAR, @v_windowid_title) + ' AND s.criteriakey = c.searchcriteriakey)
         WHEN t.searchtypecode = ' + CONVERT(VARCHAR, 21) + ' AND EXISTS(SELECT * FROM securityobjectsavailable s WHERE s.windowid = ' + CONVERT(VARCHAR, @v_windowid_project) + ' AND s.criteriakey = c.searchcriteriakey)
			  THEN (SELECT TOP(1) LTRIM(RTRIM(LOWER(COALESCE(s.availobjectid, '''') + COALESCE(''.'' + s.availobjectname, '''')))) FROM securityobjectsavailable s WHERE s.windowid = ' + CONVERT(VARCHAR, @v_windowid_project) + ' AND s.criteriakey = c.searchcriteriakey)
		 ELSE NULL	        
		END as securityobjectname               
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
