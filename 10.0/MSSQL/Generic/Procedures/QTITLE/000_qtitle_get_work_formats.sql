if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_work_formats') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_work_formats 
GO

CREATE PROCEDURE qtitle_get_work_formats
 (@i_bookkey      integer,
  @i_dropdownuse  tinyint,
  @i_assoctabcode integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_get_work_formats
**  Desc: This stored procedure gets all formats of specific work.
**
**  Auth: Kate Wiewiora
**  Date: 21 August 2009
**
**	3-23-17	- DM - Case 41362
**  2-20-18 - CO - Case 49595 Create new formats from Contract summary changes
************************************************************************************************/

DECLARE 
  @v_error  INT,
  @v_itemtypecode INT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_itemtypecode = datacode
  FROM gentables
  WHERE tableid = 550
    AND qsicode = 1

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
      b.usageclasscode,
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
      END pubdate,
	  tc.miscitem1label,
	  tc.miscitemkey1,
	  CASE
		WHEN tc.miscitemkey1 IS NOT NULL THEN dbo.qtitle_get_misc_value_by_misckey(b.bookkey, tc.miscitemkey1)
		ELSE NULL
	  END miscitemvalue1,
		CASE
		WHEN tc.miscitemkey1 IS NOT NULL THEN dbo.qtitle_get_misc_type_by_misckey(b.bookkey, tc.miscitemkey1)
		ELSE NULL
	  END miscitemtype1,
		CASE
		WHEN tc.miscitemkey1 IS NOT NULL THEN dbo.qtitle_get_misc_datacode_value(b.bookkey, tc.miscitemkey1)
		ELSE NULL
	  END miscitemdatacode1,
	  tc.miscitem2label,
	  tc.miscitemkey2,
	  CASE
		WHEN tc.miscitemkey2 IS NOT NULL THEN dbo.qtitle_get_misc_value_by_misckey(b.bookkey, tc.miscitemkey2)
		ELSE NULL
	  END miscitemvalue2,
		CASE
		WHEN tc.miscitemkey2 IS NOT NULL THEN dbo.qtitle_get_misc_type_by_misckey(b.bookkey, tc.miscitemkey2)
		ELSE NULL
	  END miscitemtype2,
		CASE
		WHEN tc.miscitemkey2 IS NOT NULL THEN dbo.qtitle_get_misc_datacode_value(b.bookkey, tc.miscitemkey2)
		ELSE NULL
	  END miscitemdatacode2,
	  tc.miscitem3label,
	  tc.miscitemkey3,
	  CASE
		WHEN tc.miscitemkey3 IS NOT NULL THEN dbo.qtitle_get_misc_value_by_misckey(b.bookkey, tc.miscitemkey3)
		ELSE NULL
	  END miscitemvalue3,
		CASE
		WHEN tc.miscitemkey3 IS NOT NULL THEN dbo.qtitle_get_misc_type_by_misckey(b.bookkey, tc.miscitemkey3)
		ELSE NULL
	  END miscitemtype3,
		CASE
		WHEN tc.miscitemkey3 IS NOT NULL THEN dbo.qtitle_get_misc_datacode_value(b.bookkey, tc.miscitemkey3)
		ELSE NULL
	  END miscitemdatacode3,
	  tc.miscitem4label,
	  tc.miscitemkey4,
	  CASE
		WHEN tc.miscitemkey4 IS NOT NULL THEN dbo.qtitle_get_misc_value_by_misckey(b.bookkey, tc.miscitemkey4)
		ELSE NULL
	  END miscitemvalue4,
		CASE
		WHEN tc.miscitemkey4 IS NOT NULL THEN dbo.qtitle_get_misc_type_by_misckey(b.bookkey, tc.miscitemkey4)
		ELSE NULL
	  END miscitemtype4,
		CASE
		WHEN tc.miscitemkey4 IS NOT NULL THEN dbo.qtitle_get_misc_datacode_value(b.bookkey, tc.miscitemkey4)
		ELSE NULL
	  END miscitemdatacode4,
	  tc.miscitem5label,
	  tc.miscitemkey5,
	  CASE
		WHEN tc.miscitemkey5 IS NOT NULL THEN dbo.qtitle_get_misc_value_by_misckey(b.bookkey, tc.miscitemkey5)
		ELSE NULL
	  END miscitemvalue5,
		CASE
		WHEN tc.miscitemkey5 IS NOT NULL THEN dbo.qtitle_get_misc_type_by_misckey(b.bookkey, tc.miscitemkey5)
		ELSE NULL
	  END miscitemtype5,
		CASE
		WHEN tc.miscitemkey5 IS NOT NULL THEN dbo.qtitle_get_misc_datacode_value(b.bookkey, tc.miscitemkey5)
		ELSE NULL
	  END miscitemdatacode5,
	  tc.miscitem6label,
	  tc.miscitemkey6,
	  CASE
		WHEN tc.miscitemkey6 IS NOT NULL THEN dbo.qtitle_get_misc_value_by_misckey(b.bookkey, tc.miscitemkey6)
		ELSE NULL
	  END miscitemvalue6,
		CASE
		WHEN tc.miscitemkey6 IS NOT NULL THEN dbo.qtitle_get_misc_type_by_misckey(b.bookkey, tc.miscitemkey6)
		ELSE NULL
	  END miscitemtype6,
		CASE
		WHEN tc.miscitemkey6 IS NOT NULL THEN dbo.qtitle_get_misc_datacode_value(b.bookkey, tc.miscitemkey6)
		ELSE NULL
	  END miscitemdatacode6,
	  tc.date1label,
	  tc.datetypecode1,
	  CASE
		WHEN tc.datetypecode1 IS NOT NULL THEN (SELECT activedate FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode1)
		ELSE NULL
	  END datevalue1,
		CASE
		WHEN tc.datetypecode1 IS NOT NULL THEN
			(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode1)
		ELSE NULL
	  END datetaskkey1,
	  tc.date2label,
	  tc.datetypecode2,
	  CASE
		WHEN tc.datetypecode2 IS NOT NULL THEN (SELECT activedate FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode2)
		ELSE NULL
	  END datevalue2,
		CASE
		WHEN tc.datetypecode2 IS NOT NULL THEN
			(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode2)
		ELSE NULL
	  END datetaskkey2,
	  tc.date3label,
	  tc.datetypecode3,
	  CASE
		WHEN tc.datetypecode3 IS NOT NULL THEN (SELECT activedate FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode3)
		ELSE NULL
	  END datevalue3,
		CASE
		WHEN tc.datetypecode3 IS NOT NULL THEN
			(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey =b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode3)
		ELSE NULL
	  END datetaskkey3,
	  tc.date4label,
	  tc.datetypecode4,
	  CASE
		WHEN tc.datetypecode4 IS NOT NULL THEN (SELECT activedate FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode4)
		ELSE NULL
	  END datevalue4,
		CASE
		WHEN tc.datetypecode4 IS NOT NULL THEN
			(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode4)
		ELSE NULL
	  END datetaskkey4,
	  tc.date5label,
	  tc.datetypecode5,
	  CASE
		WHEN tc.datetypecode5 IS NOT NULL THEN (SELECT activedate FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode5)
		ELSE NULL
	  END datevalue5,
		CASE
		WHEN tc.datetypecode5 IS NOT NULL THEN
			(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode5)
		ELSE NULL
	  END datetaskkey5,
	  tc.date6label,
	  tc.datetypecode6,
	  CASE
		WHEN tc.datetypecode6 IS NOT NULL THEN (SELECT activedate FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode6)
		ELSE NULL
	  END datevalue6,
		CASE
		WHEN tc.datetypecode6 IS NOT NULL THEN
			(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = b.bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode6)
		ELSE NULL
	  END datetaskkey6
    FROM book b
      JOIN productnumber p
	  ON b.bookkey = p.bookkey
      JOIN bookdetail bd
	  ON b.bookkey = bd.bookkey
      LEFT OUTER JOIN gentables g ON bd.mediatypecode = g.datacode AND g.tableid = 312
      LEFT OUTER JOIN subgentables s ON bd.mediatypecode = s.datacode AND bd.mediatypesubcode = s.datasubcode AND s.tableid = 312   
	  LEFT OUTER JOIN titlerelationshiptabconfig tc ON tc.relationshiptabcode = @i_assoctabcode AND tc.itemtypecode = @v_itemtypecode AND (tc.usageclass = 0 OR tc.usageclass = b.usageclasscode)
      WHERE b.workkey = (SELECT workkey FROM book where bookkey = @i_bookkey)
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