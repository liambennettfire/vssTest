if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_trading_partner_assettypes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_trading_partner_assettypes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_trading_partner_assettypes
 (@i_bookkey              integer,
  @i_listkey              integer,
  @i_partnerkey           integer,
  @i_distributiontype     integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_trading_partner_assettypes
**  Desc: This stored procedure returns a list of assettypes for the
**        trading partner that is valid for the customer.
** 
**    Auth: Alan Katzen
**    Date: 10 September 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_trading_partner_datacode INT
          
         
  IF (isnull(@i_bookkey,0) = 0 AND isnull(@i_listkey,0) = 0) BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting assettypes for the trading partner - invalid bookkey and listkey' 
    return 
  END

  SELECT @v_trading_partner_datacode = datacode
    FROM gentables
   WHERE tableid = 520
     AND qsicode = 1
 
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing gentables tableid = 520'  
    return
  END 
      
  IF @i_listkey > 0 BEGIN    
    IF @i_partnerkey > 0 BEGIN  
      SELECT DISTINCT g.datacode, g.datadesc, COALESCE(g.sortorder,0) sortorder 
        FROM qse_searchresults sr, book b, customerpartnerassets cpa, gentables g
       WHERE sr.key1 = b.bookkey
         AND b.elocustomerkey = cpa.customerkey
         AND cpa.assettypecode = g.datacode
         AND g.tableid = 287
         AND cpa.partnercontactkey = @i_partnerkey
         AND sr.listkey = @i_listkey        
       UNION
      SELECT g.datacode, g.datadesc, COALESCE(g.sortorder,0) sortorder    -- metadata asettype must be returned
        FROM gentables g
       WHERE tableid = 287
         AND qsicode = 3
    END
    ELSE BEGIN
      -- get asset types for All Partners based on distribution type
      SELECT DISTINCT g.datacode, g.datadesc, COALESCE(g.sortorder,0) sortorder 
        FROM qse_searchresults sr, book b, customerpartnerassets cpa, globalcontact gc, customerpartner cp, gentables g
       WHERE sr.key1 = b.bookkey
         AND b.elocustomerkey = cpa.customerkey
         AND cpa.customerkey = cp.customerkey
         AND cpa.partnercontactkey = gc.globalcontactkey
         AND gc.globalcontactkey = cp.partnercontactkey
         AND cpa.assettypecode = g.datacode
         AND g.tableid = 287
         AND upper(COALESCE(g.deletestatus,'N')) = 'N'
         AND gc.grouptypecode = @v_trading_partner_datacode
         AND gc.activeind = 1
         AND cp.distributiontype = @i_distributiontype
         AND sr.listkey = @i_listkey
       UNION
      SELECT g.datacode, g.datadesc, COALESCE(g.sortorder,0) sortorder    -- metadata asettype must be returned
        FROM gentables g
       WHERE tableid = 287
         AND qsicode = 3
    END
      
    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing customerpartnerassets for assettypes for the trading partner: listkey = ' + cast(isnull(@i_listkey,0) AS VARCHAR)  
    END       
  END
  ELSE BEGIN
    IF @i_partnerkey > 0 BEGIN  
      SELECT DISTINCT g.datacode, g.datadesc, COALESCE(g.sortorder,0) sortorder 
        FROM book b, customerpartnerassets cpa, gentables g
       WHERE b.elocustomerkey = cpa.customerkey
         AND cpa.assettypecode = g.datacode
         AND g.tableid = 287
         AND cpa.partnercontactkey = @i_partnerkey
         AND b.bookkey = @i_bookkey       
       UNION
      SELECT g.datacode, g.datadesc, COALESCE(g.sortorder,0) sortorder   -- metadata asettype must be returned
        FROM gentables g
       WHERE tableid = 287
         AND qsicode = 3
    END
    ELSE BEGIN
      -- get asset types for All Partners based on distribution type
      SELECT DISTINCT g.datacode, g.datadesc, COALESCE(g.sortorder,0) sortorder 
        FROM book b, customerpartnerassets cpa, globalcontact gc, customerpartner cp, gentables g
       WHERE b.elocustomerkey = cpa.customerkey
				 AND cpa.customerkey = cp.customerkey
         AND cpa.partnercontactkey = gc.globalcontactkey
         AND gc.globalcontactkey = cp.partnercontactkey
         AND cpa.assettypecode = g.datacode
         AND g.tableid = 287
         AND upper(COALESCE(g.deletestatus,'N')) = 'N'
         AND gc.grouptypecode = @v_trading_partner_datacode
         AND gc.activeind = 1
         AND cp.distributiontype = @i_distributiontype
         AND b.bookkey = @i_bookkey
       UNION
      SELECT g.datacode, g.datadesc, COALESCE(g.sortorder,0) sortorder    -- metadata asettype must be returned
        FROM gentables g
       WHERE tableid = 287
         AND qsicode = 3
    END
    
    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing customerpartnerassets for assettypes for the trading partner: bookkey = ' + cast(isnull(@i_bookkey,0) AS VARCHAR)  
    END 
  END
GO
GRANT EXEC ON qtitle_get_trading_partner_assettypes TO PUBLIC
GO



