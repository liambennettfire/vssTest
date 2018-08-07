if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_establish_supply_chain_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_establish_supply_chain_info
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_establish_supply_chain_info
 (@i_listkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_establish_supply_chain_info
**  Desc: This stored procedure returns all title information
**        for establishing supply chain relationships from a list.
**
**    Auth: Alan Katzen
**    Date: 3 August 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_supply_chain_qsicode int,
          @v_supply_chain_datacode int,
          @v_is_elo_tab tinyint,
          @v_release_to_elo_ind tinyint
  
  SET @v_supply_chain_qsicode = 1
  SELECT @v_supply_chain_datacode = datacode,
         @v_is_elo_tab = COALESCE(gen1ind,0),
         @v_release_to_elo_ind = COALESCE(gen2ind,0)
    FROM gentables
   WHERE tableid = 440
     AND qsicode = @v_supply_chain_qsicode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting supply chain datacode: listkey = ' + cast(@i_listkey AS VARCHAR)  
  END 
  IF @rowcount_var = 0 BEGIN
    SET @v_supply_chain_datacode = 0
  END
       
  SELECT c.*, dbo.get_gentables_desc(312,c.mediatypecode,'long') mediadesc,
         dbo.get_subgentables_desc(312,c.mediatypecode,c.mediatypesubcode,'long') formatdesc,
         c.mediatypesubcode formatcode, 0 associatetitlebookkey,
         @v_supply_chain_datacode associationtypecode, 0 associationtypesubcode,
         @v_is_elo_tab iselotab, @v_release_to_elo_ind releasetoeloind, 0 sortorder,
         CASE
           WHEN (SELECT COUNT(*) FROM bookauthor WHERE bookkey = c.bookkey AND primaryind=1) = 1 THEN (SELECT authorkey FROM bookauthor WHERE bookkey = c.bookkey AND primaryind=1)
           ELSE 0
         END authorkey,         
         CASE (SELECT columnname FROM productnumlocation WHERE productnumlockey=1)
           WHEN 'isbn' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=1)
           WHEN 'isbn10' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=1)
           WHEN 'ean' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=2)
           WHEN 'ean13' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=2)
           WHEN 'gtin' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=3)
           WHEN 'gtin14' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=3)
           WHEN 'upc' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=4)
           WHEN 'itemnumber' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=6)
           ELSE (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=2)
         END productidtype,
         CASE
           WHEN (SELECT COUNT(*) FROM associatedtitles WHERE bookkey = c.bookkey AND associationtypecode = @v_supply_chain_datacode) > 0 THEN (SELECT COALESCE(MAX(sortorder), 0) + 1 FROM associatedtitles WHERE bookkey = c.bookkey AND associationtypecode = @v_supply_chain_datacode)
           ELSE 1
         END newsortorder           
    FROM qse_searchresults sr
         JOIN coretitleinfo c on c.bookkey = sr.key1 and c.printingkey = sr.key2           
   WHERE sr.listkey = @i_listkey  

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting supply chain: listkey = ' + cast(@i_listkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_establish_supply_chain_info TO PUBLIC
GO



