if exists (select * from dbo.sysobjects where id = object_id(N'dbo.bookverificationmessage_insert') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.bookverificationmessage_insert
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE bookverificationmessage_insert
 (@i_bookkey  INT,
  @i_verificationtypecode  INT,
  @i_messagetypecode  INT,
  @i_message  VARCHAR(255),
  @i_username VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT,
  @i_messagecategoryqsicode INT = NULL)
AS

/******************************************************************************
**  Name: bookverificationmessage_insert
**  Desc: 
**
**  Auth: Kate
**  Date: 19 August 2011
*******************************************************************************/

DECLARE
  @v_error  INT,
  @v_nextkey  INT,
  @v_rowcount INT,
  @v_messagecategory INT
  
BEGIN
  
  SELECT @v_messagecategory = datacode FROM gentables WHERE tableid=675 AND qsicode=@i_messagecategoryqsicode
  
  EXEC get_next_key @i_username, @v_nextkey OUT

  INSERT INTO bookverificationmessage
    (messagekey, bookkey, verificationtypecode, messagetypecode, message, messagecategorycode, lastmaintuser, lastmaintdate)
  VALUES
    (@v_nextkey, @i_bookkey, @i_verificationtypecode, @i_messagetypecode, @i_message, @v_messagecategory, @i_username, getdate())

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error inserting into bookverificationmessage table (bookkey=' + CONVERT(VARCHAR, @i_bookkey) +
      + ', verificationtypecode=' + CONVERT(VARCHAR, @i_verificationtypecode) + ', messagetypecode=' + CONVERT(VARCHAR, @i_messagetypecode) + ')'
    RETURN
  END
  
END
GO

GRANT EXEC ON bookverificationmessage_insert TO PUBLIC
GO
