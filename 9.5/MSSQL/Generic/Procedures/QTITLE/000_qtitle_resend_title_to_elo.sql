if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_resend_title_to_elo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_resend_title_to_elo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_resend_title_to_elo
 (@i_bookkey  integer,
  @i_userid 	varchar(30),
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS
BEGIN

/******************************************************************************
**  Name: qtitle_resend_title_to_elo
**  Desc: This will resend the selected bookkey to eloquence
**       
**                       
**  Auth: Kusum Basra
**  Date: 26 March 2013
**
*******************************************************************************/
 DECLARE
	@v_count	int

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_count = 0

  SELECT @v_count = COUNT(*)
    FROM bookedipartner
   WHERE bookkey = @i_bookkey	
    
  -- previously been sent to eloquence
  IF @v_count > 0 
  BEGIN

    EXECUTE qtitle_update_bookedistatus @i_bookkey, 1, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
	  IF @o_error_code < 0 BEGIN
		  -- Error
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to update bookedistatus.'
	  	RETURN
		END
  END
END
go

GRANT EXEC ON qtitle_resend_title_to_elo TO PUBLIC 
GO