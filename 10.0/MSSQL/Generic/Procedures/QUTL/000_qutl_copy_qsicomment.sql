if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_copy_qsicomments') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_copy_qsicomments 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_copy_qsicomments
 (@i_new_commentkey   integer,
  @i_from_commentkey  integer,
  @i_userid           varchar(30),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qutl_copy_qsicomments
**  Desc: This stored procedure will copy qsicomments record from one commentkey to another.
**        NOTE: The new commentkey must be generated prior to calling this procedure, 
**        and should exist on qsicomments table already as a dummy row (blank comments).
**
**  Auth: Kate Wiewiora
**  Date: 23 July 2012
************************************************************************************************/

DECLARE 
  @v_error  INT,
  @v_count INT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  DELETE FROM qsicomments 
  WHERE commentkey = @i_new_commentkey

  INSERT INTO qsicomments
    (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, 
    invalidhtmlind, releasetoeloquenceind, lastuserid, lastmaintdate)
  SELECT @i_new_commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, 
    invalidhtmlind, 0, @i_userid, getdate()
  FROM qsicomments
  WHERE commentkey = @i_from_commentkey
       
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Unable to copy qsicomments: commentkey=' + cast(@i_from_commentkey AS VARCHAR)
    RETURN
  END

END
GO

GRANT EXEC ON qutl_copy_qsicomments TO PUBLIC
GO
