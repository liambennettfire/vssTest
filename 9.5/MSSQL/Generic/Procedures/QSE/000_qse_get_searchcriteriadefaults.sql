IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_searchcriteriadefaults')
BEGIN
  PRINT 'Dropping Procedure qse_get_searchcriteriadefaults'
  DROP PROCEDURE  qse_get_searchcriteriadefaults
END
GO

PRINT 'Creating Procedure qse_get_searchcriteriadefaults'
GO

CREATE PROCEDURE [dbo].[qse_get_searchcriteriadefaults]
(
  @i_ListKey      INT,
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS

BEGIN
  DECLARE 
    @v_error  INT,
    @v_searchtypecode INT

  SET NOCOUNT ON

  SELECT @v_searchtypecode = searchtypecode
  FROM qse_searchlist
  WHERE listkey = @i_ListKey
  
  -- Retrieve saved Search Criteria for passed ListKey.
  SELECT d.listkey, 
      d.sequence, 
      d.subsequence, 
      d.searchcriteriakey, 
      d.defaultoperator, 
      d.operatordesc, 
      d.numericvalue, 
      d.endnumericvalue, 
      d.stringvalue, 
      d.stringvalueshort, 
      d.datevalue, 
      d.enddatevalue, 
      d.subgennumericvalue, 
      d.subgenstringvalue, 
      d.subgen2numericvalue, 
      d.subgen2stringvalue, 
      d.guidvalue, 
      d.logicaloperator, 
      d.protectlogicaloperator, 
      d.estactbest,
      c.parentcriteriaind,
      c.detailcriteriaind,
      c.datatypecode,
      0 parentcriteriakey
  FROM qse_searchcriteriadefaults d
      LEFT OUTER JOIN qse_searchcriteriadetail det ON d.searchcriteriakey = det.detailcriteriakey,
      qse_searchcriteria c,   
      qse_searchlist l
  WHERE d.listkey = l.listkey AND
      d.searchcriteriakey = c.searchcriteriakey AND
      l.listkey = @i_ListKey AND
      (c.parentcriteriaind = 1 OR c.detailcriteriaind=0)
  UNION
  SELECT d.listkey, 
      d.sequence, 
      d.subsequence, 
      d.searchcriteriakey, 
      d.defaultoperator, 
      d.operatordesc, 
      d.numericvalue, 
      d.endnumericvalue, 
      d.stringvalue, 
      d.stringvalueshort, 
      d.datevalue, 
      d.enddatevalue, 
      d.subgennumericvalue, 
      d.subgenstringvalue, 
      d.subgen2numericvalue, 
      d.subgen2stringvalue, 
      d.guidvalue, 
      d.logicaloperator, 
      d.protectlogicaloperator, 
      d.estactbest,
      c.parentcriteriaind,
      c.detailcriteriaind,
      c.datatypecode,
      COALESCE(det.parentcriteriakey,0) parentcriteriakey
  FROM qse_searchcriteriadefaults d
      LEFT OUTER JOIN qse_searchcriteriadetail det ON d.searchcriteriakey = det.detailcriteriakey AND 
        det.parentcriteriakey = (SELECT searchcriteriakey FROM qse_searchcriteriadefaults d2 WHERE d2.listkey = d.listkey AND d2.sequence = d.sequence AND d2.subsequence = 1),   
      qse_searchcriteria c,   
      qse_searchlist l
  WHERE d.listkey = l.listkey AND
      d.searchcriteriakey = c.searchcriteriakey AND
      l.listkey = @i_ListKey AND
      c.detailcriteriaind = 1
  ORDER BY d.sequence, d.subsequence 

	
  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qse_searchcriteriadefaults/qse_searchlist tables'
    RETURN
  END

END
GO

GRANT EXEC ON qse_get_searchcriteriadefaults TO PUBLIC
GO
