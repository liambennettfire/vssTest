if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_price_validate_activeindanddates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_price_validate_activeindanddates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_price_validate_activeindanddates
 (@i_bookkey     integer,
  @i_messagetype integer,
  @i_validatetype integer,
  @o_error_code               integer       output,
  @o_error_desc               varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_price_validate_activeindanddates
**  Desc: This validates the prices
**  NOTE! THERE IS A SECOND VERSION OF THIS PROCEDURE IN THE C# CODE (PricesEdit.ascx.cs).
**    Important changes should be made in both places!
**           
**
**    Auth: Kusum Basra
**    Date: 4 August 2011
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------------------
**  09/26/17  Colman    Case 47349 - Only the duplicate check matters
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @v_pricetypedesc varchar(40)
DECLARE @v_currencytypedesc  varchar(40)
DECLARE @v_productnumber varchar(30)
DECLARE @v_title varchar(255)

DECLARE @duplicates TABLE
(
  bookkey int, 
  pricetypecode int, 
  currencytypecode int
)

SET @o_error_code = 0
SET @o_error_desc = ''

IF @i_bookkey > 0 
BEGIN
  INSERT INTO @duplicates (bookkey, pricetypecode, currencytypecode)
  SELECT bookkey, pricetypecode, currencytypecode
  FROM bookprice
  WHERE bookkey = @i_bookkey AND activeind = 1
  GROUP BY bookkey, pricetypecode, currencytypecode 
  HAVING (COUNT(*) > 1)

  DECLARE duplicates_cur CURSOR FOR
    SELECT cti.title, cti.productnumber, gpt.datadesc, gct.datadesc
    FROM @duplicates d
      JOIN coretitleinfo cti ON cti.bookkey = d.bookkey AND printingkey = 1
      JOIN gentables gpt ON gpt.tableid = 306 AND gpt.datacode = pricetypecode
      JOIN gentables gct ON gct.tableid = 122 AND gct.datacode = currencytypecode

  OPEN duplicates_cur

  FETCH duplicates_cur INTO @v_title, @v_productnumber, @v_pricetypedesc, @v_currencytypedesc

  IF @@FETCH_STATUS = 0
    SET @o_error_desc = @v_title + ' (' + @v_productnumber + ') has more than one active price for: '

  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF @o_error_code = -1
      SET @o_error_desc = @o_error_desc + ', '
    ELSE
      SET @o_error_code = -1

    SET @o_error_desc = @o_error_desc + @v_pricetypedesc + '/' + @v_currencytypedesc

    FETCH duplicates_cur INTO @v_title, @v_productnumber, @v_pricetypedesc, @v_currencytypedesc
  END

  CLOSE duplicates_cur
  DEALLOCATE duplicates_cur
END
GO

GRANT EXEC ON dbo.qtitle_price_validate_activeindanddates TO PUBLIC
GO