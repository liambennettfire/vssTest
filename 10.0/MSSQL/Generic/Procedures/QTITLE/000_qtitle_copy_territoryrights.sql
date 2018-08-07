if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_territoryrights') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_territoryrights 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_territoryrights
 (@i_to_bookkey           integer,
  @i_from_bookkey         integer,
  @i_userid               varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_copy_territoryrights
**  Desc: Copies territory rights from one title to another
**
**  Auth: Colman
**  Date: 02/16/2018
**  Case: 48060
************************************************************************************************
**  Change History
************************************************************************************************
**  Date:       Author:   Case:  Description:
**  ----------  --------  -----  ---------------------------------------------------------------
**  03/29/2018  Colman    50565  Copy title territories button is not working
************************************************************************************************/

DECLARE 
  @v_error  INT,
  @v_id INT, 
  @v_sortorder INT,
  @v_nextsortorder INT,
  @v_sortorder_varchar VARCHAR(20),
  @v_historyorder INT,
  @v_sql NVARCHAR(4000)
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- exec qutl_trace 'qtitle_copy_territoryrights',
    -- '@i_to_bookkey', @i_to_bookkey, NULL,
    -- '@i_from_bookkey', @i_from_bookkey, NULL

  IF EXISTS (
    SELECT 1 FROM territoryrights
    WHERE bookkey = @i_from_bookkey
  )
  BEGIN
    EXECUTE copy_work_info @i_from_bookkey,
      @i_to_bookkey,
      'territoryrights',
      'dummy',
      1                 -- Force the copy whether or not territoryrights is set to propagate

    
    IF @o_error_code <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to copy territoryrights: ' + @o_error_desc
      RETURN
    END
  END
END

GO

GRANT EXEC ON qtitle_copy_territoryrights TO PUBLIC
GO