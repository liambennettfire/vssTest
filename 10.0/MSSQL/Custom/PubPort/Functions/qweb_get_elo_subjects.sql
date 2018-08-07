SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_titlesubjects]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_titlesubjects]
GO

CREATE FUNCTION qweb_get_titlesubjects(@bookkey  INT)
RETURNS @titlesubjects TABLE(
      subjecttype      VARCHAR(40),
      subjectcode      VARCHAR(40),
      subjectsubcode      VARCHAR(40),
      subjectdesc      VARCHAR(600),
      subjectsubdesc      VARCHAR(600))
AS
BEGIN
DECLARE @isbn10        VARCHAR(20),
  @cstatus      INT,
  @sortorder      INT,
  @bisacsubject      VARCHAR(25),
  @bisaccategorycode    INT,
  @bisaccategorysubcode    INT,
  @subjectcode      VARCHAR(40),
  @subjectsubcode      VARCHAR(40),
  @subjectdesc      VARCHAR(520),
  @subjectsubdesc      VARCHAR(520)


SET @bisaccategorycode = 0
SET @bisaccategorysubcode =0
SET @subjectcode =''
SET @subjectdesc =''
SET @sortorder = 0

SELECT @isbn10 = isbn10
FROM isbn
WHERE bookkey = @bookkey

DECLARE c_bisac  CURSOR FOR
  SELECT distinct bisaccategorycode,bisaccategorysubcode
  FROM   bookbisaccategory 
  ORDER BY sortorder
FOR READ ONLY

OPEN c_bisac

FETCH NEXT FROM c_bisac
INTO @bisaccategorycode,@bisaccategorysubcode

SELECT @cstatus = @@FETCH_STATUS

WHILE @cstatus <>-1
  BEGIN
    IF @cstatus <>-2
      BEGIN
        SET @subjectdesc = ''
        SET @subjectcode = ''

        SELECT @subjectdesc = dbo.proper_case(LTRIM(RTRIM(datadesc)))
        FROM gentables
        WHERE tableid = 339
            AND datacode = @bisaccategorycode

        SELECT @subjectcode = bisacdatacode,
          @subjectsubdesc = LTRIM(RTRIM(datadesc))
        FROM subgentables
        WHERE tableid = 339
            AND datacode = @bisaccategorycode
            AND datasubcode = @bisaccategorysubcode

/* INSERT BISAC Subject Codes  */
        INSERT INTO @subjects(bookkey,isbn,subjecttype,subjectcode,subjectdesc,sortorder)
        VALUES ('BISAC Subject',@subjectcode,@subjectsubcode,@subjectdesc,@subjectsubdesc)

        SET @subjectcode =''
        SET @subjectdesc =''
        SET @sortorder = 0

      END

    FETCH NEXT FROM c_bisac
    INTO @bisaccategorycode,@bisaccategorysubcode,@sortorder

    SELECT @cstatus = @@FETCH_STATUS

  END

CLOSE c_bisac
DEALLOCATE c_bisac



RETURN
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

