IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_list_org_info')
  DROP PROCEDURE  qse_get_list_org_info
GO

CREATE PROCEDURE qse_get_list_org_info
(
  @i_ListKey      INT,
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS

/************************************************************************************
**  Name: qse_get_list_org_info
**  Desc: This stored procedure returns list orgentry information for given listkey.
**
**  Auth: Kate
**  Date: 18 June 2009
************************************************************************************/

BEGIN
  DECLARE 
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT o.orgleveldesc, o.orglevelkey, s.orgentrykey
  FROM orglevel o LEFT OUTER JOIN qse_searchlistorglevel S ON o.orglevelkey = s.orglevelkey AND s.listkey = @i_ListKey
  ORDER BY o.orglevelkey
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access qse_searchlistorglevel table.'
    RETURN
  END

END
GO

GRANT EXEC ON qse_get_list_org_info TO PUBLIC
GO
