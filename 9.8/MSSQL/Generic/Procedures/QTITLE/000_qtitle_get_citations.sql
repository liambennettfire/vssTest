
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_get_citations]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qtitle_get_citations]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qtitle_get_citations]
 (@i_bookkey        integer,
  @i_citationkey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_citations
**  Desc: This stored procedure returns info from the citations table for a
**          single citation or all citations for a bookkey. 
**
**    Auth: Lisa Cormier
**    Date: 19 Aug 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  if ( @i_citationkey is not null and @i_citationkey > 0 )
  BEGIN
      SELECT bookkey, citationkey, citationsource, citationauthor, citationdate,
             citationtypecode, citationexternaltypecode, proofedind, webind, c.releasetoeloquenceind, c.sortorder,
             isNull(qsiobjectkey,0) as qsiobjectkey, citationdesc, commenttext, commenthtml, commenthtmllite, 
             i.datadesc as citationtypedesc, e.datadesc as citationexternaltypedesc, c.history_order
        FROM citation c
        left join qsicomments on qsiobjectkey = commentkey
        left join gentables i on citationtypecode = i.datacode and i.tableid = 503
        left join gentables e on citationexternaltypecode = e.datacode and e.tableid = 504
       WHERE citationkey = @i_citationkey and bookkey = @i_bookkey
       ORDER BY c.sortorder
  END
  ELSE
  BEGIN
      SELECT bookkey, citationkey, citationsource, citationauthor, citationdate,
             citationtypecode, citationexternaltypecode, proofedind, webind, c.releasetoeloquenceind, c.sortorder,
             isNull(qsiobjectkey,0) as qsiobjectkey, citationdesc, commenttext, commenthtml, commenthtmllite, 
             i.datadesc as citationtypedesc, e.datadesc as citationexternaltypedesc, c.history_order
        FROM citation c
        left join qsicomments on qsiobjectkey = commentkey
        left join gentables i on citationtypecode = i.datacode and i.tableid = 503
        left join gentables e on citationexternaltypecode = e.datacode and e.tableid = 504
       WHERE bookkey = @i_bookkey
       ORDER BY c.sortorder
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no citation data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_citations TO PUBLIC
GO

