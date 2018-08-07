if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_rightskey_from_bookkey') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_rightskey_from_bookkey
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_rightskey_from_bookkey
 (@i_bookkey							integer,
	@i_mediatypecode				integer, --pass 0 if you want the function to find it for you
  @i_mediatypesubcode			integer, --pass 0 if you want the function to find it for you
  @i_languagecode					integer, --pass 0 if you want the function to find it for you
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_rightskey_from_bookkey
**  Desc: This procedure retrieves all associated contract project keys associated with the given book key
**
**	Auth: Dustin Miller
**	Date: May 23 2012
*******************************************************************************/
	DECLARE @v_error			INT,
          @v_rowcount		INT
	
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT [dbo].qcontract_get_rightskey_from_contract_title(@i_bookkey,@i_mediatypecode,@i_mediatypesubcode,@i_languagecode) AS rightskey

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning rightskey from bookkey details (bookkey=' + cast(@i_bookkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qtitle_get_rightskey_from_bookkey TO PUBLIC
GO