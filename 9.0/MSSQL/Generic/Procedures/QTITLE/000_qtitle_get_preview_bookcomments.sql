if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_preview_bookcomments') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_preview_bookcomments
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_preview_bookcomments
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/****************************************************************************************************
**  Name: qtitle_get_preview_bookcomments
**  Desc: This stored procedure returns fragment of the commenttext for preview purposes
**        on Copy From Title.
**
**  Auth: Kate
**  Date: 08/02/12
*****************************************************************************************************/

DECLARE
  @v_error INT,
  @v_itemtype INT,
  @v_usageclass INT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Get Item Type and Usage Class for the passed title
  SELECT @v_itemtype = itemtypecode, @v_usageclass = usageclasscode 
  FROM coretitleinfo
  WHERE bookkey = @i_bookkey AND printingkey = 1  
  
  SELECT c.commenttypecode, c.commenttypesubcode, s.datadesc,
  CASE 
    WHEN LEN(CONVERT(VARCHAR(570), c.commenttext)) = 570 THEN CONVERT(VARCHAR(570), c.commenttext) + '(...)'
    ELSE CONVERT(VARCHAR(570), c.commenttext) 
  END commenttext
  FROM bookcomments c, subgentables s, gentablesitemtype i
  WHERE c.commenttypecode = s.datacode AND
    c.commenttypesubcode = s.datasubcode AND
    s.tableid = i.tableid AND
    s.datacode = i.datacode AND
    s.datasubcode = i.datasubcode AND
    s.tableid = 284 AND 
    (s.deletestatus is null OR upper(s.deletestatus) = 'N') and
    c.bookkey = @i_bookkey AND 
    i.itemtypecode = @v_itemtype AND
    COALESCE(i.itemtypesubcode,0) IN (@v_usageclass,0) AND
    c.commenttext IS NOT NULL    
    
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error retrieving bookcomments for bookkey=' + CONVERT(VARCHAR, @i_bookkey) + '.'
  END
  
END
GO

GRANT EXEC ON qtitle_get_preview_bookcomments TO PUBLIC
GO
