IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_basic_searchcriteria_key')
  DROP PROCEDURE  qse_get_basic_searchcriteria_key
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_listkey')
  DROP PROCEDURE  qse_get_listkey
GO

CREATE PROCEDURE qse_get_listkey
 (@i_ListType     INT,
  @i_UserKey      INT,
  @i_SearchType   INT,
  @i_ListNameUpper  VARCHAR(100),
  @o_ListKey      INT OUT,
  @o_error_code   INT OUT,
  @o_error_desc   VARCHAR(2000) OUT)
AS

/************************************************************************************
**  Name: qse_get_listkey
**  Desc: This stored procedure is used to return a listkey for passed listtype,
**        userkey, and searchtype.
**        NOTE: This procedure cannot be used for User-Defined lists (multiple rows)
**        unless the optional ListName input paramater is also passed.
**
**  Auth: Kate
**  Date: 17 August 2006
************************************************************************************/

BEGIN
  DECLARE 
    @IsNamePassed TINYINT,
    @ListKey			INT,
    @NumberOfRows		INT,
    @ErrorValue			INT,
    @RowcountValue		INT

  SET NOCOUNT ON

  SET @o_ListKey = 0
  SET @o_error_code = 1
  SET @o_error_desc = ''
  
  IF @i_ListNameUpper IS NULL OR LTRIM(RTRIM(@i_ListNameUpper)) = ''  
    SET @IsNamePassed = 0
  ELSE
    SET @IsNamePassed = 1

  IF @IsNamePassed = 1
    SELECT @NumberOfRows = count(*)
    FROM qse_searchlist
    WHERE listtypecode = @i_ListType AND
        userkey = @i_UserKey AND
        searchtypecode = @i_SearchType AND
        UPPER(listdesc) = @i_ListNameUpper
  ELSE
    SELECT @NumberOfRows = count(*)
    FROM qse_searchlist
    WHERE listtypecode = @i_ListType AND
        userkey = @i_UserKey AND
        searchtypecode = @i_SearchType  

  IF @NumberOfRows > 0
  BEGIN
  
    IF @IsNamePassed = 1
      SELECT @ListKey = listkey
      FROM qse_searchlist
      WHERE listtypecode = @i_ListType AND
          userkey = @i_UserKey AND
          searchtypecode = @i_SearchType AND
          UPPER(listdesc) = @i_ListNameUpper
    ELSE
      SELECT @ListKey = listkey
      FROM qse_searchlist
      WHERE listtypecode = @i_ListType AND
          userkey = @i_UserKey AND
          searchtypecode = @i_SearchType

    SELECT @ErrorValue = @@ERROR, @RowcountValue = @@ROWCOUNT
    IF @ErrorValue <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error accessing qse_searchlist table'
      RETURN
    END

    IF @o_error_desc IS NOT NULL AND LTRIM(@o_error_desc) <> '' BEGIN
      PRINT 'ERROR: ' + @o_error_desc
      SET @o_ListKey = -1
      RETURN
    END

    SET @o_ListKey = @ListKey
  END
END
GO

GRANT EXEC ON qse_get_listkey TO PUBLIC
GO
