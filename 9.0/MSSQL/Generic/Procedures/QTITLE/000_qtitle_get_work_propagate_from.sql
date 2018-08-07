if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_work_propagate_from') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_work_propagate_from
GO

CREATE PROCEDURE qtitle_get_work_propagate_from
 (@i_bookkey      integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_get_work_propagate_from
**  Desc: This stored procedure gets all titles for a work that are not propagated to 
**        (i.e. they have no propagatefrombookkey), excluding sets.
**
**  Auth: Kate Wiewiora
**  Date: 21 August 2009
************************************************************************************************/

DECLARE 
  @v_error  INT  
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT b.bookkey,
    b.title + ' / ' + 
    CASE
      WHEN c.productnumber IS NULL THEN '(none)'
      WHEN LTRIM(RTRIM(c.productnumber)) = '' THEN '(none)'
      ELSE c.productnumber
    END + ' / ' + 
    c.formatname propagatefrom
  FROM book b,  
    coretitleinfo c
  WHERE 
    b.bookkey = c.bookkey AND
    c.printingkey = 1 AND
    c.workkey = (SELECT workkey FROM book where bookkey = @i_bookkey) AND
    c.linklevelcode <> 30 AND
    (b.propagatefrombookkey IS NULL OR b.propagatefrombookkey = 0)
  ORDER BY b.linklevelcode ASC
 
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve work propagate from information.'
  END
  
END
GO

GRANT EXEC ON qtitle_get_work_propagate_from TO PUBLIC
GO
