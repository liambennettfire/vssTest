if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_associatedtitle') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_associatedtitle
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_associatedtitle (
  @i_projectkey INTEGER,
  @i_bookkey INTEGER,
  @i_titlerole INTEGER,
  @i_projectrole INTEGER,
  @i_taqprojectformatkey integer,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS /****************************************************************************************
**  Name: qproject_get_associatedtitles
**  Desc: This stored procedure returns associated title information
**        from the taqprojecttitle table for use with Projects / Title Acquisitions 
**
**  Auth: Jon Hess
**  Date: 12/05/2011
**
**  Created: 12/05/2011 ( Case 14197 )
**	 
****************************************************************************************/

  DECLARE @error_var    INT,
          @rowcount_var INT,
          @pubdate      VARCHAR(12)

  SET @o_error_code = 0
  SET @o_error_desc = ''


  SELECT
  taqprojectformatkey,
  taqprojectkey,
  seasoncode,
  seasonfirmind,
  COALESCE(c.mediatypecode, a.mediatypecode) mediatypecode,   
  COALESCE(c.mediatypesubcode, a.mediatypesubcode) mediatypesubcode, 
  discountcode,
  COALESCE(c.tmmprice, a.price) price,
  initialrun,
  projectdollars,
  marketingplancode,
  primaryformatind,
  a.bookkey,
  COALESCE(c.title, a.title) title,
  (CASE (SELECT
           count(*)
           FROM bookauthor
           WHERE bookkey = a.bookkey
             AND
             primaryind = 1)
     WHEN 1
       THEN
         (SELECT
            authorkey
            FROM bookauthor
            WHERE bookkey = a.bookkey
              AND
              primaryind = 1)
     ELSE
       NULL
   END) authorkey,
  COALESCE(c.authorname, a.authorname) as authorname,
  coalesce ( nullif( a.taqprojectformatdesc, '' ), c.formatname ) as taqprojectformatdesc,
  isbnprefixcode,
  a.lastuserid,
  a.lastmaintdate,
  gtin14,
  lccn,
  dsmarc,
  CASE 
      WHEN a.bookkey > 0 THEN c.itemnumber 
      ELSE a.itemnumber
  END AS itemnumber,
  a.ean13 productnumber,
  a.upc,
  eanprefixcode,
  a.printingkey,
  projectrolecode,
  titlerolecode,
  keyind,
  a.sortorder,
  indicator1,
  indicator2,
  quantity1,
  quantity2,
  relateditem2name,
  relateditem2status,
  relateditem2participants,
  templatekey,
  a.authorname,
  coalesce ( nullif( a.bisacstatus, '' ), c.bisacstatuscode ) as bisacstatus,
  origpubhousecode,
  COALESCE(c.bestpubdate, a.pubdate) pubdate,
  salesunitgross,
  salesunitnet,
  reportind,
  productidtype,
  bookpos,
  lifetodatepointofsale,
  yeartodatepointofsale,
  previousyearpointofsale,
  CASE 
    WHEN a.bookkey > 0 THEN coalesce(dbo.rpt_get_best_page_count(a.bookkey, 1), a.[pagecount])
    ELSE a.pagecount
  END [pagecount],
  CASE
    WHEN a.bookkey > 0
      THEN
        dbo.rpt_get_best_insert_illus(a.bookkey, 1)
    ELSE
      a.illustrations
  END illustrations,
  quantity,
  volumenumber,
  Commentkey1,
  Commentkey2,
  coalesce ( nullif( a.editiondescription, '' ), c.editiondesc ) as editiondescription,
  coalesce(a.commentkey1, '-1') AS commentkey1,
  coalesce(a.commentkey2, '-1') AS commentkey2,
  coalesce((SELECT
              commenthtmllite
              FROM qsicomments
              WHERE commentkey = Commentkey1), '') AS prosComments,
  coalesce((SELECT
              commenthtmllite
              FROM qsicomments
              WHERE commentkey = Commentkey2), '') AS consComments,
  CASE
    WHEN -1 > 0
      THEN
        (SELECT
           datadesc
           FROM gentables
           WHERE tableid = 312
             AND
             datacode = c.mediatypecode) + ' / ' + c.formatname
    ELSE
      g1.datadesc + ' / ' + s.datadesc
  END formatdesc,
  c.tmmheaderorg2desc coretitlepublisherdesc

  FROM taqprojecttitle a
    LEFT OUTER JOIN gentables g1
      ON a.mediatypecode = g1.datacode AND g1.tableid = 312
      LEFT OUTER JOIN subgentables s
        ON a.mediatypecode = s.datacode AND a.mediatypesubcode = s.datasubcode AND s.tableid = 312
        LEFT OUTER JOIN coretitleinfo c
          ON a.bookkey = c.bookkey AND c.printingkey = 1
  WHERE a.taqprojectformatkey = @i_taqprojectformatkey
  ORDER BY a.sortorder
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectKey = ' + cast(@i_projectkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qproject_get_associatedtitle TO PUBLIC
GO