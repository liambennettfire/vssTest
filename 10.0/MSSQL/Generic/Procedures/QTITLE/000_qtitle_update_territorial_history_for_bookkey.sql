if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_update_territorial_history_for_bookkey') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_update_territorial_history_for_bookkey
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_update_territorial_history_for_bookkey
 (@i_tablename          varchar(100),
  @i_bookkey            integer,
  @i_printingkey        integer,
  @i_transtype          varchar(25),
  @i_userid							varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_update_territorial_history_for_bookkey
**  Desc: 
**
**  Auth: Dustin Miller
**  Date: 8/13/12
*************************************************************************************/

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
	EXEC qtitle_update_titlehistory @i_tablename, '(multiple)', @i_bookkey, @i_printingkey, 0,
		NULL, @i_transtype, @i_userid, 0, NULL, @o_error_code OUTPUT, @o_error_desc OUTPUT
		
END
GO

GRANT EXEC ON qtitle_update_territorial_history_for_bookkey TO PUBLIC
GO
