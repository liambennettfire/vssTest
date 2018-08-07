IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_list_info')
BEGIN
  DROP PROCEDURE  qse_get_list_info
END
GO

CREATE PROCEDURE qse_get_list_info
(
  @i_ListKey      INT,
  @i_UserKey      INT,
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS

/************************************************************************************
**  Name: qse_get_list_info
**  Desc: This stored procedure returns list information for given listkey.
**
**  Auth: Kate
**  Date: 4 August 2006
************************************************************************************/

BEGIN
  DECLARE 
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT *,
    CASE
      WHEN userkey = @i_UserKey THEN 1
      WHEN userkey IN (SELECT accesstouserkey FROM qsiprivateuserlist WHERE primaryuserkey = @i_UserKey) THEN 1
      ELSE 0
    END c_teamowned
  FROM qse_searchlist
  WHERE listkey = @i_ListKey
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access qse_searchlist table.'
    RETURN
  END
  IF @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Record was not found on qse_searchlist table (listkey=' + CONVERT(VARCHAR, @i_ListKey) + ').'
    RETURN  
  END

END
GO

GRANT EXEC ON qse_get_list_info TO PUBLIC
GO
