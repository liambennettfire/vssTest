if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_next_history_order') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_next_history_order
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_next_history_order
 (@i_bookkey              integer,
  @i_printingkey          integer,
  @i_tablename            varchar(80),
  @i_userid               varchar(30),
  @o_history_order        integer output,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_next_history_order
**  Desc: This stored procedure returns the next history order
** 
**    Auth: Alan Katzen
**    Date: 21 July 2011
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_history_order = 0
  
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_history_order INT,
          @v_count INT

  SET @v_history_order = 0
     
  -- make sure row exists on bookorderhistory
  SELECT @v_count = count(*)
    FROM bookorderhistory
   WHERE bookkey = @i_bookkey
     AND printingkey = @i_printingkey
     AND lower(tablename) = lower(@i_tablename)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting next history order: bookkey = ' + cast(@i_bookkey AS VARCHAR) +
                        '/printingkey = ' + cast(@i_printingkey AS VARCHAR) + 
                        '/tablename = ' + @i_tablename  
    SET @o_history_order = -1
    return
  END 
  
  IF @v_count <= 0 BEGIN
    INSERT INTO bookorderhistory (bookkey,printingkey,tablename,historyorder,lastuserid,lastmaintdate)
    VALUES (@i_bookkey,@i_printingkey,lower(@i_tablename),0,@i_userid,getdate())

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error inserting into bookorderhistory: bookkey = ' + cast(@i_bookkey AS VARCHAR) +
                          '/printingkey = ' + cast(@i_printingkey AS VARCHAR) + 
                          '/tablename = ' + @i_tablename  
      SET @o_history_order = -1
      return
    END 
  END
  
  UPDATE bookorderhistory 
     SET historyorder = historyorder + 1, 
         lastuserid = @i_userid, 
         lastmaintdate = getdate()
   WHERE bookkey = @i_bookkey
     AND printingkey = @i_printingkey
     AND lower(tablename) = lower(@i_tablename)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting next history order (update): bookkey = ' + cast(@i_bookkey AS VARCHAR) +
                        '/printingkey = ' + cast(@i_printingkey AS VARCHAR) + 
                        '/tablename = ' + @i_tablename  
    SET @o_history_order = -1
    return
  END 

  SELECT @v_history_order = historyorder 
    FROM bookorderhistory
   WHERE bookkey = @i_bookkey
     AND printingkey = @i_printingkey
     AND lower(tablename) = lower(@i_tablename)
       
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting next history order (select): bookkey = ' + cast(@i_bookkey AS VARCHAR) +
                        '/printingkey = ' + cast(@i_printingkey AS VARCHAR) + 
                        '/tablename = ' + @i_tablename  
    SET @o_history_order = -1
    return
  END 

  SET @o_history_order = @v_history_order
  return
   
GO
GRANT EXEC ON qtitle_get_next_history_order TO PUBLIC
GO



