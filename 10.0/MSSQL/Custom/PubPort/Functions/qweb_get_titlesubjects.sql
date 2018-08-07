SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_titlesubjects]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_titlesubjects]
GO

CREATE FUNCTION qweb_get_titlesubjects(@bookkey  INT)
  RETURNS @titlesubjects TABLE(
    bookkey        INT,
    subjecttype      VARCHAR(40),
    subjectcode      VARCHAR(40),
    subjectdesc      VARCHAR(600),
    subjectsubcode      VARCHAR(40),
    subjectsubdesc      VARCHAR(600),
    sortorder      INT)
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
  @subjectsubdesc      VARCHAR(520),
  @categorytableid    INT,
  @categorycode      INT,
  @categorydesc      VARCHAR(40),
  @categorydescshort    VARCHAR(40),
  @categorysubcode    INT,
  @categorysubdesc    VARCHAR(40),
  @categorysubdescshort    VARCHAR(40),
  @categorysub2code    INT,
  @categorysub2desc    VARCHAR(40),
  @categorysub2descshort    VARCHAR(40),
  @tabledesc      VARCHAR(40)

SET @bisaccategorycode = 0
SET @bisaccategorysubcode =0
SET @subjectcode =''
SET @subjectdesc =''
SET @sortorder = 0

SELECT @isbn10 = isbn10
  FROM isbn
  WHERE bookkey = @bookkey

DECLARE c_bisac  CURSOR FOR
  SELECT  bisaccategorycode,bisaccategorysubcode,sortorder
  FROM   bookbisaccategory 
  WHERE   bookkey = @bookkey 
    and bisaccategorycode>0
    and bisaccategorysubcode>0
  ORDER BY sortorder
FOR READ ONLY

OPEN c_bisac

FETCH NEXT FROM c_bisac
  INTO @bisaccategorycode,@bisaccategorysubcode,@sortorder

SELECT @cstatus = @@FETCH_STATUS

WHILE @cstatus <>-1
  BEGIN
    IF @cstatus <>-2
      BEGIN
        SET @subjectdesc = ''
        SET @subjectcode = ''

        SELECT @subjectcode = datacode,
               @subjectdesc = dbo.proper_case(LTRIM(RTRIM(datadesc)))
          FROM gentables
          WHERE tableid = 339
            AND datacode = @bisaccategorycode

        SELECT @subjectsubcode = datasubcode,
            @subjectsubdesc = datadesc
          FROM subgentables
          WHERE tableid = 339
            AND datacode = @bisaccategorycode
            AND datasubcode = @bisaccategorysubcode

/* INSERT BISAC Subject Codes  */
        INSERT INTO @titlesubjects(bookkey,subjecttype,subjectcode,subjectdesc,subjectsubcode,subjectsubdesc,sortorder)
          VALUES (@bookkey,'BISAC Subject',@subjectcode,@subjectdesc,@subjectsubcode,@subjectsubdesc,@sortorder)

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


/*  GET SUBJECT CATEGORIES      */
DECLARE c_subject CURSOR FOR
  SELECT  categorytableid,categorycode,categorysubcode,categorysub2code,sortorder
     FROM   booksubjectcategory 
    WHERE   bookkey = @bookkey AND categorytableid in (412,413,414,431)
    ORDER BY sortorder
  FOR READ ONLY

OPEN c_subject

FETCH NEXT FROM c_subject
  INTO @categorytableid,@categorycode,@categorysubcode,@categorysub2code,@sortorder

SELECT @cstatus = @@FETCH_STATUS

WHILE @cstatus <>-1
  BEGIN
    IF @cstatus <>-2
      BEGIN
        SET @tabledesc = ''
        SET @subjectdesc = ''
        SET @subjectcode = ''
        SET @categorydesc = ''
        SET @categorydescshort = ''
        SET @categorysubdesc = ''
        SET @categorysubdescshort = ''
        SET @categorysub2desc = ''
        SET @categorysub2descshort = ''        

        SELECT @tabledesc = dbo.proper_case(LTRIM(RTRIM(tabledesclong)))
          FROM gentablesdesc
          WHERE tableid = @categorytableid


        SELECT @categorydesc = datadesc,
               @categorydescshort = datadescshort
          FROM gentables
          WHERE tableid = @categorytableid
            AND datacode = @categorycode


        SELECT @categorysubdesc = datadesc,
            @categorysubdescshort = datadescshort
          FROM subgentables
          WHERE tableid = @categorytableid
            AND datacode = @categorycode
            AND datasubcode = @categorysubcode

        SELECT @categorysub2desc = datadesc,
          @categorysub2descshort = datadescshort
          FROM sub2gentables
          WHERE tableid = @categorytableid
            AND datacode = @categorycode
            AND datasubcode = @categorysubcode
            AND datasub2code = @categorysub2code

        SELECT @subjectcode = COALESCE(@categorydescshort,'')+COALESCE(@categorysubdescshort,'')+COALESCE(@categorysub2descshort,'')

        SELECT @subjectdesc = 
          CASE
            WHEN COALESCE(@categorysub2desc,'')<>''  THEN @categorydesc+'\'+@categorysubdesc+'\'+@categorysub2desc
            WHEN COALESCE(@categorysubdesc,'')<>''  THEN @categorydesc+'\'+@categorysubdesc
            WHEN COALESCE(@categorydesc,'')<>''  THEN @categorydesc
            ELSE
                ''
          END

/* INSERT Subject Category Codes  */
        INSERT INTO @titlesubjects(bookkey,subjecttype,subjectcode,subjectdesc,subjectsubcode,subjectsubdesc,sortorder)
          VALUES (@bookkey,@tabledesc,@subjectcode,@subjectdesc,@subjectsubcode,@subjectsubdesc,@sortorder)

        SET @sortorder = 0
     
      END

    FETCH NEXT FROM c_subject
      INTO @categorytableid,@categorycode,@categorysubcode,@categorysub2code,@sortorder

    SELECT @cstatus = @@FETCH_STATUS

  END

CLOSE c_subject
DEALLOCATE c_subject

RETURN
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

