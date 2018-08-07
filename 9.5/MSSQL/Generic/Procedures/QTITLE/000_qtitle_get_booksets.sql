if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_booksets') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_booksets
GO

CREATE PROCEDURE qtitle_get_booksets
 (@i_bookkey      integer,
  @i_printingkey  integer,
  @i_issuenumber  integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_get_booksets
**  Desc: This stored procedure returns set-related information from booksets table.
**
**  Auth: Kate
**  Date: 5/27/10
*************************************************************************************/

BEGIN

  DECLARE
    @v_error	INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT s.*, g.datadesc settypedesc
  FROM booksets s LEFT OUTER JOIN gentables g ON s.settypecode = g.datacode AND g.tableid = 481 
  WHERE s.bookkey = @i_bookkey AND
    s.printingkey = @i_printingkey AND
    s.issuenumber = @i_issuenumber

  SELECT @v_error = @@ERROR
  IF @v_error <> 0  BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not get set information from booksets.'
  END
  
END
GO

GRANT EXEC ON qtitle_get_booksets TO PUBLIC
GO
