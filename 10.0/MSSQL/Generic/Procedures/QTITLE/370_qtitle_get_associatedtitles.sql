if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_associatedtitles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_associatedtitles
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_associatedtitles
  (@i_bookkey        integer,
  @i_assotypecode   integer,
  @i_summary        tinyint,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/****************************************************************************************
**  Name: qtitle_get_associatedtitles
**  Desc: This stored procedure returns associated titles information
**        from the associatedtitles table. 
**
**  Auth: Alan Katzen
**  Date: 01 April 2004
**
**  9/15/09 - KW - Rewritten for Title Relationships - replacing Title Positioning.
**  4/19/10 - JH - Added 4 columns [bookpos],[lifetodatepointofsale],[yeartodatepointofsale], [previousyearpointofsale] per case 11806
**	9/28/16 - UK - Case 40693  
**	3-23-17	- DM - Case 41362
**  7-20-17 - DK - Added TOP 1 to the date type code sub-selects
****************************************************************************************/

  DECLARE @error_var    INT,
          @rowcount_var INT,
          @pubdate varchar(12)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_summary = 1   --View mode - shorten long title string
    SELECT a.bookkey,
      a.associationtypecode,
      a.associationtypesubcode,   
      a.associatetitlebookkey, 
      a.sortorder,
      COALESCE(g2.gen1ind,0) iselotabind,
      COALESCE(a.releasetoeloquenceind, 0) releasetoeloquenceind, 
      a.productidtype,
      CASE
        WHEN (COALESCE(a.associatetitlebookkey, 0) > 0) THEN
          CASE COALESCE(a.productidtype, 0)
            WHEN 1 THEN c.isbn
            WHEN 2 THEN c.ean
            WHEN 3 THEN (SELECT gtin FROM isbn WHERE bookkey = a.associatetitlebookkey)
            WHEN 4 THEN c.upc
            WHEN 6 THEN c.itemnumber
            WHEN 9 THEN c.eanx
            ELSE NULL
          END
        ELSE a.isbn 
      END productnumber,    
      CASE
        WHEN LEN(COALESCE(c.title, a.title)) > 30 THEN CAST(COALESCE(c.title, a.title) AS VARCHAR(30)) + '...'
        ELSE COALESCE(c.title, a.title)
      END AS title,
      CASE
        WHEN a.authorkey > 0 THEN (SELECT displayname FROM author WHERE authorkey = a.authorkey)
        ELSE COALESCE(c.authorname, a.authorname)
      END authorname,
      COALESCE(a.authorkey,
      CASE (SELECT COUNT(*) FROM bookauthor WHERE bookkey = a.associatetitlebookkey AND primaryind=1)
        WHEN 1 THEN (SELECT authorkey FROM bookauthor WHERE bookkey = a.associatetitlebookkey AND primaryind=1)
        ELSE NULL
      END) authorkey,
      CASE 
        WHEN a.associatetitlebookkey > 0 THEN (SELECT datadesc FROM gentables WHERE tableid = 312 AND datacode = c.mediatypecode) + ' / ' + c.formatname
        ELSE g1.datadesc + ' / ' + s.datadesc
      END formatdesc,      
      COALESCE(c.bisacstatuscode, a.bisacstatus) bisacstatus,  
      CASE
        WHEN a.associatetitlebookkey > 0 THEN (SELECT editiondescription FROM bookdetail WHERE bookkey = a.associatetitlebookkey)
        ELSE a.editiondescription
      END editiondescription, 
      COALESCE(c.bestpubdate, a.pubdate) pubdate,
      COALESCE(c.tmmprice, a.price) price,  
      a.origpubhousecode,
      c.tmmheaderorg2desc coretitlepublisherdesc,
      CASE 
        WHEN a.associatetitlebookkey > 0 THEN dbo.rpt_get_best_page_count(a.associatetitlebookkey, 1)
        ELSE a.pagecount
      END pagecount,
      CASE 
        WHEN a.associatetitlebookkey > 0 THEN dbo.rpt_get_best_insert_illus(a.associatetitlebookkey, 1)
        ELSE a.illustrations
      END illustrations,       
      a.bookpos,
      a.lifetodatepointofsale,
      a.yeartodatepointofsale,
      a.previousyearpointofsale,
      a.quantity, 
      a.volumenumber,
      COALESCE(  a.commentkey1, '-1' ) as commentkey1,
      COALESCE(  a.commentkey2, '-1' ) as commentkey2,
      COALESCE( ( select commenttext from qsicomments where commentkey = Commentkey1 ), '' ) as prosComments,
      COALESCE( ( select commenttext from qsicomments where commentkey = Commentkey2 ), '' ) as consComments,
      a.salesunitgross,
      a.salesunitnet,      
      COALESCE( c.itemnumber, a.itemnumber ) as itemnumber, ISNULL(a.reportind, 0) AS reportind ,
      CASE
        WHEN COALESCE(a.associationtypecode, 0) > 0 THEN (SELECT datadesc FROM subgentables WHERE tableid = 440 AND datacode = a.associationtypecode AND datasubcode = a.associationtypesubcode)
        ELSE NULL
      END relationshipdescription, 
      CASE
        WHEN COALESCE(c.bisacstatuscode, a.bisacstatus) > 0 THEN (SELECT datadesc FROM gentables WHERE tableid = 314 AND datacode = COALESCE(c.bisacstatuscode, a.bisacstatus))
        ELSE NULL
      END bisacstatusdescription,
      CASE
        WHEN COALESCE(a.origpubhousecode, 0) > 0 THEN (SELECT datadesc FROM gentables WHERE tableid = 126 AND datacode = a.origpubhousecode)
        ELSE c.tmmheaderorg2desc
      END publisherdescription,
	  tc.miscitem1label,
	  tc.miscitemkey1,
	  CASE
		WHEN tc.miscitemkey1 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey1)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey1)
			END
		ELSE NULL
	  END miscitemvalue1,
		CASE
		WHEN tc.miscitemkey1 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey1)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey1)
			END
		ELSE NULL
	  END miscitemtype1,
		CASE
		WHEN tc.miscitemkey1 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey1)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey1)
			END
		ELSE NULL
	  END miscitemdatacode1,
	  tc.miscitem2label,
	  tc.miscitemkey2,
	  CASE
		WHEN tc.miscitemkey2 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey2)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey2)
			END
		ELSE NULL
	  END miscitemvalue2,
		CASE
		WHEN tc.miscitemkey2 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey2)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey2)
			END
		ELSE NULL
	  END miscitemtype2,
		CASE
		WHEN tc.miscitemkey2 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey2)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey2)
			END
		ELSE NULL
	  END miscitemdatacode2,
	  tc.miscitem3label,
	  tc.miscitemkey3,
	  CASE
		WHEN tc.miscitemkey3 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey3)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey3)
			END
		ELSE NULL
	  END miscitemvalue3,
		CASE
		WHEN tc.miscitemkey3 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey3)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey3)
			END
		ELSE NULL
	  END miscitemtype3,
		CASE
		WHEN tc.miscitemkey3 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey3)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey3)
			END
		ELSE NULL
	  END miscitemdatacode3,
	  tc.miscitem4label,
	  tc.miscitemkey4,
	  CASE
		WHEN tc.miscitemkey4 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey4)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey4)
			END
		ELSE NULL
	  END miscitemvalue4,
		CASE
		WHEN tc.miscitemkey4 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey4)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey4)
			END
		ELSE NULL
	  END miscitemtype4,
		CASE
		WHEN tc.miscitemkey4 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey4)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey4)
			END
		ELSE NULL
	  END miscitemdatacode4,
	  tc.miscitem5label,
	  tc.miscitemkey5,
	  CASE
		WHEN tc.miscitemkey5 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey5)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey5)
			END
		ELSE NULL
	  END miscitemvalue5,
		CASE
		WHEN tc.miscitemkey5 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey5)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey5)
			END
		ELSE NULL
	  END miscitemtype5,
		CASE
		WHEN tc.miscitemkey5 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey5)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey5)
			END
		ELSE NULL
	  END miscitemdatacode5,
	  tc.miscitem6label,
	  tc.miscitemkey6,
	  CASE
		WHEN tc.miscitemkey6 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey6)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey6)
			END
		ELSE NULL
	  END miscitemvalue6,
		CASE
		WHEN tc.miscitemkey6 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey6)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey6)
			END
		ELSE NULL
	  END miscitemtype6,
		CASE
		WHEN tc.miscitemkey6 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey6)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey6)
			END
		ELSE NULL
	  END miscitemdatacode6,
	  tc.date1label,
	  tc.datetypecode1,
	  CASE
		WHEN tc.datetypecode1 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode1)
				ELSE (SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode1)
			END
		ELSE NULL
	  END datevalue1,
		CASE
		WHEN tc.datetypecode1 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode1)
				ELSE (SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode1)
			END
		ELSE NULL
	  END datetaskkey1,
	  tc.date2label,
	  tc.datetypecode2,
	  CASE
		WHEN tc.datetypecode2 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode2)
				ELSE (SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode2)
			END
		ELSE NULL
	  END datevalue2,
		CASE
		WHEN tc.datetypecode2 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode2)
				ELSE (SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode2)
			END
		ELSE NULL
	  END datetaskkey2,
	  tc.date3label,
	  tc.datetypecode3,
	  CASE
		WHEN tc.datetypecode3 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode3)
				ELSE (SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode3)
			END
		ELSE NULL
	  END datevalue3,
		CASE
		WHEN tc.datetypecode3 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode3)
				ELSE (SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode3)
			END
		ELSE NULL
	  END datetaskkey3,
	  tc.date4label,
	  tc.datetypecode4,
	  CASE
		WHEN tc.datetypecode4 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode4)
				ELSE (SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode4)
			END
		ELSE NULL
	  END datevalue4,
		CASE
		WHEN tc.datetypecode4 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode4)
				ELSE (SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode4)
			END
		ELSE NULL
	  END datetaskkey4,
	  tc.date5label,
	  tc.datetypecode5,
	  CASE
		WHEN tc.datetypecode5 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode5)
				ELSE (SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode5)
			END
		ELSE NULL
	  END datevalue5,
		CASE
		WHEN tc.datetypecode5 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode5)
				ELSE (SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode5)
			END
		ELSE NULL
	  END datetaskkey5,
	  tc.date6label,
	  tc.datetypecode6,
	  CASE
		WHEN tc.datetypecode6 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode6)
				ELSE (SELECT TOP 1 activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode6)
			END
		ELSE NULL
	  END datevalue6,
		CASE
		WHEN tc.datetypecode6 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode6)
				ELSE (SELECT TOP 1 taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode6)
			END
		ELSE NULL
	  END datetaskkey6
    FROM associatedtitles a
      LEFT OUTER JOIN gentables g1 ON a.mediatypecode = g1.datacode AND g1.tableid = 312
      LEFT OUTER JOIN subgentables s ON a.mediatypecode = s.datacode AND a.mediatypesubcode = s.datasubcode AND s.tableid = 312
      LEFT OUTER JOIN coretitleinfo c ON a.associatetitlebookkey = c.bookkey AND c.printingkey = 1
	  LEFT OUTER JOIN titlerelationshiptabconfig tc ON tc.relationshiptabcode = @i_assotypecode AND tc.itemtypecode = c.itemtypecode AND (tc.usageclass = 0 OR tc.usageclass = c.usageclasscode)
      JOIN gentables g2 ON a.associationtypecode = g2.datacode AND g2.tableid = 440
    WHERE a.bookkey = @i_bookkey AND
      a.associationtypecode = @i_assotypecode
    ORDER BY a.sortorder
        
  ELSE  --Edit mode
    SELECT a.bookkey,   
      a.associationtypecode,
      a.associationtypesubcode,   
      a.associatetitlebookkey,   
      a.sortorder,
      COALESCE(g2.gen1ind,0) iselotabind,
      COALESCE(a.releasetoeloquenceind, 0) releasetoeloquenceind,
      a.productidtype,
      CASE
        WHEN (COALESCE(a.associatetitlebookkey, 0) > 0) THEN
          CASE COALESCE(a.productidtype, 0)
            WHEN 1 THEN c.isbn
            WHEN 2 THEN c.ean
            WHEN 3 THEN (SELECT gtin FROM isbn WHERE bookkey = a.associatetitlebookkey)
            WHEN 4 THEN c.upc
            WHEN 6 THEN c.itemnumber
			WHEN 9 THEN c.eanx
            ELSE NULL
          END
        ELSE a.isbn 
      END productnumber,    
      COALESCE(c.title, a.title) title,  
      CASE
        WHEN a.authorkey > 0 THEN (SELECT displayname FROM author WHERE authorkey = a.authorkey)
        ELSE COALESCE(c.authorname, a.authorname)
      END authorname,
      COALESCE(a.authorkey,
      CASE (SELECT COUNT(*) FROM bookauthor WHERE bookkey = a.associatetitlebookkey AND primaryind=1)
        WHEN 1 THEN (SELECT authorkey FROM bookauthor WHERE bookkey = a.associatetitlebookkey AND primaryind=1)
        ELSE NULL
      END) authorkey,
      COALESCE(c.mediatypecode, a.mediatypecode) mediatypecode,   
      COALESCE(c.mediatypesubcode, a.mediatypesubcode) mediatypesubcode,      
      CASE 
        WHEN a.associatetitlebookkey > 0 THEN (SELECT datadesc FROM gentables WHERE tableid = 312 AND datacode = c.mediatypecode) + ' / ' + c.formatname
        ELSE g1.datadesc + ' / ' + s.datadesc
      END formatdesc,
      COALESCE(c.bisacstatuscode, a.bisacstatus) bisacstatus, 
      CASE
        WHEN a.associatetitlebookkey > 0 THEN (SELECT editiondescription FROM bookdetail WHERE bookkey = a.associatetitlebookkey)
        ELSE a.editiondescription
      END editiondescription, 
      COALESCE(c.bestpubdate, a.pubdate) pubdate, 
      COALESCE(c.tmmprice, a.price) price, 
      a.origpubhousecode,
      c.tmmheaderorg2desc coretitlepublisherdesc,
      CASE 
        WHEN a.associatetitlebookkey > 0 THEN dbo.rpt_get_best_page_count(a.associatetitlebookkey, 1)
        ELSE a.pagecount
      END pagecount,
      CASE 
        WHEN a.associatetitlebookkey > 0 THEN dbo.rpt_get_best_insert_illus(a.associatetitlebookkey, 1)
        ELSE a.illustrations
      END illustrations,       
      a.bookpos,
      a.lifetodatepointofsale,
      a.yeartodatepointofsale,
      a.previousyearpointofsale,
      a.quantity, 
      a.volumenumber,
      COALESCE(  a.commentkey1, '-1' ) as commentkey1,
      COALESCE(  a.commentkey2, '-1' ) as commentkey2,
      COALESCE( ( select commenthtmllite from qsicomments where commentkey = Commentkey1 ), '' ) as prosComments,
      COALESCE( ( select commenthtmllite from qsicomments where commentkey = Commentkey2 ), '' ) as consComments,
      a.salesunitgross,
      a.salesunitnet,
      COALESCE( c.itemnumber, a.itemnumber ) as itemnumber, ISNULL(a.reportind, 0) AS reportind,
	  CASE	  
		  WHEN COALESCE(c.title, a.title) IS NOT NULL THEN COALESCE(c.title, a.title) + ' / ' +
			  CASE
				WHEN a.authorkey > 0 THEN (SELECT COALESCE(displayname, '') FROM author WHERE authorkey = a.authorkey)
				ELSE COALESCE(COALESCE(c.authorname, a.authorname), '')
			  END 
		  ELSE 
			  CASE
				WHEN a.authorkey > 0 THEN (SELECT displayname FROM author WHERE authorkey = a.authorkey)
				ELSE COALESCE(c.authorname, a.authorname)
			  END
	  END titleauthorname,
      CASE
        WHEN COALESCE(a.associationtypecode, 0) > 0 THEN (SELECT datadesc FROM subgentables WHERE tableid = 440 AND datacode = a.associationtypecode AND datasubcode = a.associationtypesubcode)
        ELSE NULL
      END relationshipdescription,
      CASE
        WHEN COALESCE(c.bisacstatuscode, a.bisacstatus) > 0 THEN (SELECT datadesc FROM gentables WHERE tableid = 314 AND datacode = COALESCE(c.bisacstatuscode, a.bisacstatus))
        ELSE NULL
      END bisacstatusdescription,
      CASE
        WHEN COALESCE(c.bisacstatuscode, a.bisacstatus) > 0 THEN (SELECT datadesc FROM gentables WHERE tableid = 314 AND datacode = COALESCE(c.bisacstatuscode, a.bisacstatus)) + ' / ' + 
			CASE
				WHEN a.associatetitlebookkey > 0 THEN (SELECT COALESCE(editiondescription, '') FROM bookdetail WHERE bookkey = a.associatetitlebookkey)
				ELSE COALESCE(a.editiondescription, '')
			END
        ELSE 
			CASE
				WHEN a.associatetitlebookkey > 0 THEN (SELECT editiondescription FROM bookdetail WHERE bookkey = a.associatetitlebookkey)
				ELSE a.editiondescription
			END
      END bisacstatuseditiondescription,
      CASE
        WHEN COALESCE(a.origpubhousecode, 0) > 0 THEN (SELECT datadesc FROM gentables WHERE tableid = 126 AND datacode = a.origpubhousecode)
        ELSE c.tmmheaderorg2desc
      END publisherdescription,
	  tc.miscitem1label,
	  tc.miscitemkey1,
	  CASE
		WHEN tc.miscitemkey1 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey1)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey1)
			END
		ELSE NULL
	  END miscitemvalue1,
		CASE
		WHEN tc.miscitemkey1 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey1)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey1)
			END
		ELSE NULL
	  END miscitemtype1,
		CASE
		WHEN tc.miscitemkey1 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey1)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey1)
			END
		ELSE NULL
	  END miscitemdatacode1,
	  tc.miscitem2label,
	  tc.miscitemkey2,
	  CASE
		WHEN tc.miscitemkey2 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey2)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey2)
			END
		ELSE NULL
	  END miscitemvalue2,
		CASE
		WHEN tc.miscitemkey2 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey2)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey2)
			END
		ELSE NULL
	  END miscitemtype2,
		CASE
		WHEN tc.miscitemkey2 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey2)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey2)
			END
		ELSE NULL
	  END miscitemdatacode2,
	  tc.miscitem3label,
	  tc.miscitemkey3,
	  CASE
		WHEN tc.miscitemkey3 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey3)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey3)
			END
		ELSE NULL
	  END miscitemvalue3,
		CASE
		WHEN tc.miscitemkey3 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey3)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey3)
			END
		ELSE NULL
	  END miscitemtype3,
		CASE
		WHEN tc.miscitemkey3 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey3)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey3)
			END
		ELSE NULL
	  END miscitemdatacode3,
	  tc.miscitem4label,
	  tc.miscitemkey4,
	  CASE
		WHEN tc.miscitemkey4 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey4)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey4)
			END
		ELSE NULL
	  END miscitemvalue4,
		CASE
		WHEN tc.miscitemkey4 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey4)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey4)
			END
		ELSE NULL
	  END miscitemtype4,
		CASE
		WHEN tc.miscitemkey4 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey4)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey4)
			END
		ELSE NULL
	  END miscitemdatacode4,
	  tc.miscitem5label,
	  tc.miscitemkey5,
	  CASE
		WHEN tc.miscitemkey5 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey5)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey5)
			END
		ELSE NULL
	  END miscitemvalue5,
		CASE
		WHEN tc.miscitemkey5 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey5)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey5)
			END
		ELSE NULL
	  END miscitemtype5,
		CASE
		WHEN tc.miscitemkey5 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey5)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey5)
			END
		ELSE NULL
	  END miscitemdatacode5,
	  tc.miscitem6label,
	  tc.miscitemkey6,
	  CASE
		WHEN tc.miscitemkey6 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_value_by_misckey(a.associatetitlebookkey, tc.miscitemkey6)
				ELSE dbo.qtitle_get_misc_value_by_misckey(a.bookkey, tc.miscitemkey6)
			END
		ELSE NULL
	  END miscitemvalue6,
		CASE
		WHEN tc.miscitemkey6 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_type_by_misckey(a.associatetitlebookkey, tc.miscitemkey6)
				ELSE dbo.qtitle_get_misc_type_by_misckey(a.bookkey, tc.miscitemkey6)
			END
		ELSE NULL
	  END miscitemtype6,
		CASE
		WHEN tc.miscitemkey6 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				dbo.qtitle_get_misc_datacode_value(a.associatetitlebookkey, tc.miscitemkey6)
				ELSE dbo.qtitle_get_misc_datacode_value(a.bookkey, tc.miscitemkey6)
			END
		ELSE NULL
	  END miscitemdatacode6,
	  tc.date1label,
	  tc.datetypecode1,
	  CASE
		WHEN tc.datetypecode1 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode1)
				ELSE (SELECT activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode1)
			END
		ELSE NULL
	  END datevalue1,
		CASE
		WHEN tc.datetypecode1 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode1)
				ELSE (SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode1)
			END
		ELSE NULL
	  END datetaskkey1,
	  tc.date2label,
	  tc.datetypecode2,
	  CASE
		WHEN tc.datetypecode2 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode2)
				ELSE (SELECT activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode2)
			END
		ELSE NULL
	  END datevalue2,
		CASE
		WHEN tc.datetypecode2 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode2)
				ELSE (SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode2)
			END
		ELSE NULL
	  END datetaskkey2,
	  tc.date3label,
	  tc.datetypecode3,
	  CASE
		WHEN tc.datetypecode3 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode3)
				ELSE (SELECT activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode3)
			END
		ELSE NULL
	  END datevalue3,
		CASE
		WHEN tc.datetypecode3 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode3)
				ELSE (SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode3)
			END
		ELSE NULL
	  END datetaskkey3,
	  tc.date4label,
	  tc.datetypecode4,
	  CASE
		WHEN tc.datetypecode4 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode4)
				ELSE (SELECT activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode4)
			END
		ELSE NULL
	  END datevalue4,
		CASE
		WHEN tc.datetypecode4 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode4)
				ELSE (SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode4)
			END
		ELSE NULL
	  END datetaskkey4,
	  tc.date5label,
	  tc.datetypecode5,
	  CASE
		WHEN tc.datetypecode5 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode5)
				ELSE (SELECT activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode5)
			END
		ELSE NULL
	  END datevalue5,
		CASE
		WHEN tc.datetypecode5 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode5)
				ELSE (SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode5)
			END
		ELSE NULL
	  END datetaskkey5,
	  tc.date6label,
	  tc.datetypecode6,
	  CASE
		WHEN tc.datetypecode6 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT activedate FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode6)
				ELSE (SELECT activedate FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode6)
			END
		ELSE NULL
	  END datevalue6,
		CASE
		WHEN tc.datetypecode6 IS NOT NULL THEN
			CASE
				WHEN a.associatetitlebookkey > 0 THEN
				(SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = a.associatetitlebookkey AND printingkey = 1 AND datetypecode = tc.datetypecode6)
				ELSE (SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey AND printingkey = 1 AND datetypecode = tc.datetypecode6)
			END
		ELSE NULL
	  END datetaskkey6
    FROM associatedtitles a
      LEFT OUTER JOIN gentables g1 ON a.mediatypecode = g1.datacode AND g1.tableid = 312
      LEFT OUTER JOIN subgentables s ON a.mediatypecode = s.datacode AND a.mediatypesubcode = s.datasubcode AND s.tableid = 312
      LEFT OUTER JOIN coretitleinfo c ON a.associatetitlebookkey = c.bookkey AND c.printingkey = 1
	  LEFT OUTER JOIN titlerelationshiptabconfig tc ON tc.relationshiptabcode = @i_assotypecode AND tc.itemtypecode = c.itemtypecode AND (tc.usageclass = 0 OR tc.usageclass = c.usageclasscode)
      JOIN gentables g2 ON a.associationtypecode = g2.datacode AND g2.tableid = 440 
    WHERE a.bookkey = @i_bookkey AND
      a.associationtypecode = @i_assotypecode
    ORDER BY a.sortorder

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_associatedtitles TO PUBLIC
GO