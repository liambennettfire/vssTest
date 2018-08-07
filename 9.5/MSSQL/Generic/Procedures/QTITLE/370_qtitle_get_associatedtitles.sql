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
**	 
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
      END publisherdescription  
    FROM associatedtitles a
      LEFT OUTER JOIN gentables g1 ON a.mediatypecode = g1.datacode AND g1.tableid = 312
      LEFT OUTER JOIN subgentables s ON a.mediatypecode = s.datacode AND a.mediatypesubcode = s.datasubcode AND s.tableid = 312
      LEFT OUTER JOIN coretitleinfo c ON a.associatetitlebookkey = c.bookkey AND c.printingkey = 1
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
      END publisherdescription 
 
    FROM associatedtitles a
      LEFT OUTER JOIN gentables g1 ON a.mediatypecode = g1.datacode AND g1.tableid = 312
      LEFT OUTER JOIN subgentables s ON a.mediatypecode = s.datacode AND a.mediatypesubcode = s.datasubcode AND s.tableid = 312
      LEFT OUTER JOIN coretitleinfo c ON a.associatetitlebookkey = c.bookkey AND c.printingkey = 1
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