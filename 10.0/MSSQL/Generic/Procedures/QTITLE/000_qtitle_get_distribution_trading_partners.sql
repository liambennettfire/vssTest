if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_distribution_trading_partners') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_distribution_trading_partners
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_distribution_trading_partners
 (@i_bookkey              integer,
  @i_listkey              integer,
  @i_distributiontype     integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_distribution_trading_partners
**  Desc: This stored procedure returns a list of trading partners for the
**        distribution type that is valid for the customer.
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
    SET @o_error_desc = 'error getting trading partners - invalid bookkey and listkey' 
    return 
  END
  
  SELECT @v_trading_partner_datacode = datacode
    FROM gentables
   WHERE tableid = 520
     AND eloquencefieldtag = 'CLD_PT_Trading'
 
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing gentables tableid = 520'  
    return
  END 
  
  IF (isnull(@v_trading_partner_datacode,0)) = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting trading partners - trading partner eloquencefieldtag not setup on gentables tableid = 520' 
    return 
  END
    
  IF @i_listkey > 0 BEGIN      
    SELECT DISTINCT gc.*, LTRIM(RTRIM(gc.displayname)) AS dispname 
      FROM qse_searchresults sr, book b, customerpartner cp, globalcontact gc
     WHERE sr.key1 = b.bookkey
       AND b.elocustomerkey = cp.customerkey
       AND cp.partnercontactkey = gc.globalcontactkey
       AND gc.grouptypecode = @v_trading_partner_datacode
       AND gc.activeind = 1
       AND cp.distributiontype = @i_distributiontype
       AND sr.listkey = @i_listkey  
     ORDER BY dispname ASC             
       
    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing globalcontact for trading partner information: listkey = ' + cast(isnull(@i_listkey,0) AS VARCHAR)  
    END       
  END
  ELSE BEGIN
    SELECT DISTINCT gc.*, LTRIM(RTRIM(gc.displayname)) AS dispname 
      FROM book b, customerpartner cp, globalcontact gc
     WHERE b.elocustomerkey = cp.customerkey
       AND cp.partnercontactkey = gc.globalcontactkey
       AND gc.grouptypecode = @v_trading_partner_datacode
       AND gc.activeind = 1
       AND cp.distributiontype = @i_distributiontype 
       AND b.bookkey = @i_bookkey     
     ORDER BY dispname ASC         

    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing globalcontact for trading partner information: bookkey = ' + cast(isnull(@i_bookkey,0) AS VARCHAR)  
    END 
  END
GO
GRANT EXEC ON qtitle_get_distribution_trading_partners TO PUBLIC
GO
