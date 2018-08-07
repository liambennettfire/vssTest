if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_work_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_copy_work_info
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_copy_work_info
 (@i_bookkey         integer,
  @i_tablename       varchar(100),
  @i_columnname      varchar(100),
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_copy_work_info
**  Desc: This stored procedure calls the copy_work_info procedure to propagate
**        data to related works. 
**
**    If tablename and columnname are not passed in, then ALL work level fields 
**    will be propagated.     
**
**    Returns -1 for an error
**           
**    Auth: Alan Katzen
**    Date: 17 December 2007
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_bookkey_from INT,
          @v_bookkey_to INT

  IF @i_bookkey > 0 BEGIN
    SET @v_bookkey_from = @i_bookkey
  END
  ELSE BEGIN
    -- nothing to do - bookkey is not filled in
    RETURN    
  END

  -- need to find all related bookkeys
  DECLARE work_cur CURSOR FOR
   SELECT bookkey
     FROM book 
    WHERE propagatefrombookkey = @v_bookkey_from
  
  OPEN work_cur
  FETCH NEXT FROM work_cur INTO @v_bookkey_to
  WHILE (@@FETCH_STATUS <> -1) BEGIN
    EXECUTE copy_work_info @v_bookkey_from,@v_bookkey_to,@i_tablename,@i_columnname

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error executing stored procedure copy_work_info: bookkey from = ' + cast(@v_bookkey_from AS VARCHAR) + 
                          ' bookkey to = ' + cast(@v_bookkey_to AS VARCHAR) +
                          ' tablename = ' + COALESCE(@i_tablename,'') + 
                          ' columnname = ' + COALESCE(@i_columnname,'')
      GOTO finished
    END 

    FETCH NEXT FROM work_cur INTO @v_bookkey_to
  END

  finished:
  CLOSE work_cur
  DEALLOCATE work_cur
GO
GRANT EXEC ON qtitle_copy_work_info TO PUBLIC
GO


