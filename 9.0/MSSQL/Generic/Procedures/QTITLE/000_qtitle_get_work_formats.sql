if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_work_formats') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_work_formats 
GO

CREATE PROCEDURE qtitle_get_work_formats
 (@i_bookkey      integer,
  @i_dropdownuse  tinyint,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_get_work_formats
**  Desc: This stored procedure gets all formats of specific work.
**
**  Auth: Kate Wiewiora
**  Date: 21 August 2009
************************************************************************************************/

DECLARE 
  @v_error  INT  
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_dropdownuse = 1
    SELECT b.bookkey,
      b.title + ' / ' + 
      CASE
        WHEN c.productnumber IS NULL THEN '(none)'
        WHEN LTRIM(RTRIM(c.productnumber)) = '' THEN '(none)'
        ELSE c.productnumber
      END + ' / ' + 
      c.formatname workformatinfo
    FROM book b,  
      coretitleinfo c
    WHERE 
      b.bookkey = c.bookkey AND
      c.printingkey = 1 AND
      c.workkey = (SELECT workkey FROM book where bookkey = @i_bookkey)
    ORDER BY b.linklevelcode ASC  
  ELSE
    SELECT b.bookkey,  
      b.workkey,   
      b.title,   
      b.linklevelcode,
      b.propagatefrombookkey,  
      CASE 
        WHEN b.propagatefrombookkey > 0 THEN 
          (SELECT c.title + ' / ' + 
            CASE
              WHEN productnumber IS NULL THEN '(none)'
              WHEN LTRIM(RTRIM(productnumber)) = '' THEN '(none)'
              ELSE productnumber
            END + ' / ' + 
            c.formatname
          FROM coretitleinfo c WHERE c.bookkey = b.propagatefrombookkey AND c.printingkey=1)
        ELSE NULL
      END propagateinfo,
      bd.simulpubind,   
      p.productnumber,   
      g.datadesc + '/' + s.datadesc formatdesc,
      CASE b.bookkey
        WHEN b.workkey THEN 1
        ELSE 0
      END primaryind,
      CASE b.bookkey
        WHEN @i_bookkey THEN 1
        ELSE 0
      END isthistitle,
      CASE
        WHEN (SELECT COUNT(*) FROM book WHERE propagatefrombookkey = b.bookkey) > 0 THEN 1
        ELSE 0
      END ispropagating,      
      ( SELECT bisacstatuscode FROM coretitleinfo c where bookkey = b.bookkey AND c.printingkey = 1 ) as bisacstatuscode,
      ( SELECT editiondescription FROM bookdetail WHERE bookkey = b.bookkey  ) as edition,
      ( SELECT itemnumber FROM coretitleinfo c WHERE bookkey = b.bookkey AND c.printingkey = 1 ) as itemnumber,
      COALESCE((SELECT TOP 1 p.taqprojectkey FROM taqproject p WHERE p.workkey = b.workkey AND p.searchitemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode=9)),
      COALESCE((SELECT TOP 1 t.taqprojectkey FROM taqprojecttitle t WHERE b.bookkey = t.bookkey AND t.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode=1)),0)) workprojectkey,
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT isbn FROM isbn WHERE isbn.bookkey = b.bookkey)  
      END isbnvalue, 
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT isbn10 FROM isbn WHERE isbn.bookkey = b.bookkey)  
      END isbn10value, 
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT ean FROM isbn WHERE isbn.bookkey = b.bookkey)  
      END eanvalue, 
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT ean13 FROM isbn WHERE isbn.bookkey = b.bookkey)  
      END ean13value, 
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT gtin FROM isbn WHERE isbn.bookkey = b.bookkey)  
      END gtinvalue, 
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT gtin14 FROM isbn WHERE isbn.bookkey = b.bookkey)  
      END gtin14value, 
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT lccn FROM isbn WHERE isbn.bookkey = b.bookkey)  
      END lccnvalue, 
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT dsmarc FROM isbn WHERE isbn.bookkey = b.bookkey)  
      END dsmarcvalue, 
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT itemnumber FROM isbn WHERE isbn.bookkey = b.bookkey)  
      END itemnumbervalue, 
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT upc FROM isbn WHERE isbn.bookkey = b.bookkey)  
      END upcvalue,
      CASE 
        WHEN b.bookkey > 0 THEN (SELECT c.bestpubdate FROM coretitleinfo c WHERE c.bookkey = b.bookkey AND c.printingkey=1)
        ELSE NULL
      END pubdate          
    FROM book b, 
      productnumber p,  
      bookdetail bd
      LEFT OUTER JOIN gentables g ON bd.mediatypecode = g.datacode AND g.tableid = 312
      LEFT OUTER JOIN subgentables s ON bd.mediatypecode = s.datacode AND bd.mediatypesubcode = s.datasubcode AND s.tableid = 312      
      WHERE b.bookkey = p.bookkey AND
      b.bookkey = bd.bookkey AND
      b.workkey = (SELECT workkey FROM book where bookkey = @i_bookkey)
    ORDER BY isthistitle DESC, p.productnumber ASC
 
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve work formats.'
  END
  
END
GO

GRANT EXEC ON qtitle_get_work_formats TO PUBLIC
GO
