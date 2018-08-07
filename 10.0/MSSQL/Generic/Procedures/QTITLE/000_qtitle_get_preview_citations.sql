if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_preview_citations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_preview_citations
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_preview_citations
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/****************************************************************************************************
**  Name: qtitle_get_preview_citations
**  Desc: This stored procedure returns fragment of the citation commenttext for preview purposes
**        on Copy From Title.
**
**  Auth: Kate
**  Date: 08/06/12
*****************************************************************************************************/

DECLARE
  @v_error INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT c.bookkey, c.citationkey, c.citationsource, c.citationauthor, c.citationdate, c.sortorder, c.citationdesc, 
    COALESCE(c.citationtypecode,0) citationtypecode, 
    COALESCE(c.citationexternaltypecode,0) citationexternaltypecode,
    COALESCE(c.proofedind,0) proofedind, 
    COALESCE(c.webind,0) webind, c.qsiobjectkey, g.datadesc as datadesc ,e.datadesc as datadesc2,
    CASE 
      WHEN LEN(CONVERT(VARCHAR(250), q.commenttext)) = 250 THEN CONVERT(VARCHAR(250), q.commenttext) + '(...)'
      ELSE CONVERT(VARCHAR(250), q.commenttext) 
    END citationtext  
  FROM citation c 
    LEFT OUTER JOIN gentables g ON c.citationtypecode = g.datacode AND g.tableid = 503
    LEFT OUTER JOIN gentables e on c.citationexternaltypecode = e.datacode and e.tableid = 504
    LEFT OUTER JOIN qsicomments q ON c.qsiobjectkey = q.commentkey
  WHERE
    c.bookkey = @i_bookkey AND
    (g.deletestatus is null OR upper(g.deletestatus) = 'N')
  ORDER BY c.sortorder
    
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error retrieving citation rows for bookkey=' + CONVERT(VARCHAR, @i_bookkey) + '.'
  END
  
END
GO

GRANT EXEC ON qtitle_get_preview_citations TO PUBLIC
GO
