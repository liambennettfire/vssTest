IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_list_creators')
BEGIN
  DROP PROCEDURE  qse_get_list_creators
END
GO

CREATE PROCEDURE qse_get_list_creators
(
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS

/************************************************************************************
**  Name: qse_get_list_creators
**  Desc: This stored procedure returns a list of all list creators 
**        (qse_searchlist.userkey/cratedbyuserid).
**
**  Auth: Kate
**  Date: 4 August 2006
************************************************************************************/

BEGIN
  DECLARE 
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT DISTINCT userkey, createdbyuserid
  FROM qse_searchlist
  WHERE createdbyuserid is not null
  and userkey >= 0
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access qse_searchlist table.'
    RETURN
  END

END
GO

GRANT EXEC ON qse_get_list_creators TO PUBLIC
GO
