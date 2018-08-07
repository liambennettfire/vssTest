if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_associatedtitles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_associatedtitles
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_associatedtitles (
  @i_projectkey INTEGER,
  @i_titlerole INTEGER,
  @i_projectrole INTEGER,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS 
  /****************************************************************************************
**  Name: qproject_get_associatedtitles
**  Desc: This stored procedure returns associated titles information
**        from the taqprojecttitle table for use with Projects / Title Acquisitions 
**
**  Auth: Jon Hess
**  Date: 11/22/2011
**
**  Created: 11/22/2011 ( Case 14197 )
**	 
****************************************************************************************/

  DECLARE @v_error  INT,
          @v_rowcount INT,
          @v_asso_code  INT,
          @v_asso_sub_code  INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_asso_code = 0
  SET @v_asso_sub_code = 0
  
  -- Get associationtypecode from Title Role to Association Type Code gentable relationship
  SELECT @v_rowcount = COUNT(*)
  FROM gentablesrelationshipdetail
  WHERE gentablesrelationshipkey = 15 AND code1 = @i_titlerole
  
  IF @v_rowcount > 0
    SET @v_asso_code = (SELECT TOP 1 code2 FROM gentablesrelationshipdetail 
                        WHERE gentablesrelationshipkey = 15 AND 
                          code1 = @i_titlerole
                        ORDER BY defaultind DESC)
                        
                        
  -- If single associationtypesubcode exists for this associationtypecode, use it; otherwise leave it blank
  SELECT @v_rowcount = COUNT(*)
  FROM subgentables
  WHERE tableid = 440 AND datacode = @v_asso_code
  
  IF @v_rowcount = 1
    SELECT @v_asso_sub_code = datasubcode
    FROM subgentables
    WHERE tableid = 440 AND datacode = @v_asso_code
    
  SELECT a.taqprojectformatkey,
    a.taqprojectkey,    
    COALESCE(a.associationtypecode, @v_asso_code) as associationtypecode,
    COALESCE(a.associationtypesubcode, @v_asso_sub_code) as associationtypesubcode,
    a.seasoncode,
    a.seasonfirmind,
    COALESCE(c.mediatypecode, a.mediatypecode) mediatypecode,   
    COALESCE(c.mediatypesubcode, a.mediatypesubcode) mediatypesubcode, 
    a.discountcode,
    COALESCE(c.tmmprice, a.price) price,
    a.initialrun,
    a.projectdollars,
    a.marketingplancode,
    a.primaryformatind,
    a.bookkey,
    COALESCE(c.title, a.title) title,
    CASE (SELECT COUNT(*) FROM bookauthor WHERE bookkey = a.bookkey AND primaryind = 1)
      WHEN 1 THEN (SELECT authorkey FROM bookauthor WHERE bookkey = a.bookkey AND primaryind = 1)
      ELSE NULL
    END authorkey,
    COALESCE(c.authorname, a.authorname) as authorname,
    COALESCE(NULLIF(a.taqprojectformatdesc,''), c.formatname) as taqprojectformatdesc,
    a.isbnprefixcode,
    a.lastuserid,
    a.lastmaintdate,
    a.gtin14,
    a.lccn,
    a.dsmarc,
    CASE 
      WHEN a.bookkey > 0 THEN c.itemnumber 
      ELSE a.itemnumber
    END AS itemnumber,
    a.ean13 productnumber,
    a.upc,
    a.eanprefixcode,
    a.printingkey,
    a.projectrolecode,
    a.titlerolecode,
    a.keyind,
    a.sortorder,
    a.indicator1,
    a.indicator2,
    a.quantity1,
    a.quantity2,
    a.relateditem2name,
    a.relateditem2status,
    a.relateditem2participants,
    a.templatekey,
    a.authorname,
    COALESCE(NULLIF( a.bisacstatus, ''), c.bisacstatuscode ) AS bisacstatus,
    a.origpubhousecode,
    COALESCE(c.bestpubdate, a.pubdate) pubdate,
    a.salesunitgross,
    a.salesunitnet,
    a.reportind,
    COALESCE(a.productidtype, '1') AS productidtype,
    a.bookpos,
    a.lifetodatepointofsale,
    a.yeartodatepointofsale,
    a.previousyearpointofsale,
    CASE 
      WHEN a.bookkey > 0 THEN COALESCE(dbo.rpt_get_best_page_count(a.bookkey, 1), a.pagecount)
      ELSE a.pagecount
    END pagecount,
    CASE
      WHEN a.bookkey > 0 THEN dbo.rpt_get_best_insert_illus(a.bookkey, 1)
      ELSE a.illustrations
    END illustrations,
    a.quantity,
    a.volumenumber,
    a.commentkey1,
    a.commentkey2,
    COALESCE(NULLIF( a.editiondescription, ''), c.editiondesc) AS editiondescription,
    COALESCE(a.commentkey1, '-1') AS commentkey1,
    COALESCE(a.commentkey2, '-1') AS commentkey2,
    COALESCE((SELECT commenthtmllite FROM qsicomments WHERE commentkey = a.commentkey1), '') AS prosComments,
    COALESCE((SELECT commenthtmllite FROM qsicomments WHERE commentkey = a.commentkey2), '') AS consComments,
    CASE
      WHEN -1 > 0 THEN (SELECT datadesc FROM gentables WHERE tableid = 312 AND datacode = c.mediatypecode) + ' / ' + c.formatname
      ELSE g1.datadesc + ' / ' + s.datadesc
    END formatdesc,
    c.tmmheaderorg2desc coretitlepublisherdesc,
    c.isbn, 
    c.isbnx, 
    c.ean,
    c.eanx  
  FROM taqprojecttitle a
    LEFT OUTER JOIN gentables g1 ON a.mediatypecode = g1.datacode AND g1.tableid = 312
    LEFT OUTER JOIN subgentables s ON a.mediatypecode = s.datacode AND a.mediatypesubcode = s.datasubcode AND s.tableid = 312
    LEFT OUTER JOIN coretitleinfo c ON a.bookkey = c.bookkey AND c.printingkey = 1
  WHERE a.taqprojectkey = @i_projectkey AND
    a.projectrolecode = @i_projectrole AND
    a.titlerolecode = @i_titlerole
  ORDER BY a.sortorder

  -- Save the @@ERROR and @@ROWCOUNT values in local variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0
  BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectKey = ' + cast(@i_projectkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qproject_get_associatedtitles TO PUBLIC
GO
