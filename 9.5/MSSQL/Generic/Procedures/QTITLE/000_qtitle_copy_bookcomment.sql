if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_bookcomment') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_bookcomment 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_bookcomment
 (@i_new_bookkey          integer,
  @i_from_bookkey         integer,
  @i_commenttypecode      integer,
  @i_commenttypesubcode   integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_copy_bookcomment
**  Desc: This stored procedure will copy bookcomments record from one title to another.
**
**  Auth: Kate Wiewiora
**  Date: 3 August 2012
************************************************************************************************/

DECLARE 
  @v_error  INT,
  @v_count INT,
  @v_lastuserid VARCHAR(30),
  @v_lastmaintdate  DATETIME
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_lastuserid = lastuserid, @v_lastmaintdate = lastmaintdate
  FROM bookcomments
  WHERE bookkey = @i_new_bookkey AND 
    printingkey = 1 AND
    commenttypecode = @i_commenttypecode  AND
    commenttypesubcode = @i_commenttypesubcode  

  DELETE FROM bookcomments 
  WHERE bookkey = @i_new_bookkey AND
    printingkey = 1 AND
    commenttypecode = @i_commenttypecode AND
    commenttypesubcode = @i_commenttypesubcode

  INSERT INTO bookcomments
    (bookkey, printingkey, commenttypecode, commenttypesubcode, commentstring, 
    commenttext, commenthtml, commenthtmllite, invalidhtmlind, releasetoeloquenceind, lastuserid, lastmaintdate)
  SELECT @i_new_bookkey, 1, commenttypecode, commenttypesubcode, commentstring, 
    commenttext, commenthtml, commenthtmllite, invalidhtmlind, 0, @v_lastuserid, @v_lastmaintdate
  FROM bookcomments
  WHERE bookkey = @i_from_bookkey AND
    printingkey = 1 AND
    commenttypecode = @i_commenttypecode AND
    commenttypesubcode = @i_commenttypesubcode
       
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Unable to copy bookcomments: bookkey' + cast(@i_from_bookkey AS VARCHAR) + ', printingkey=1, ' + 
      'commenttypecode=' + cast(@i_commenttypecode as VARCHAR) + ', commenttypesubcode=' + cast(@i_commenttypesubcode as VARCHAR) + '.'
    RETURN
  END

END
GO

GRANT EXEC ON qtitle_copy_bookcomment TO PUBLIC
GO