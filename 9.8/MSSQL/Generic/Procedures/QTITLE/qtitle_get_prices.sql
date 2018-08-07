if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_prices') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_prices
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_prices
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  Name: qtitle_get_prices
**  Desc: This stored procedure returns all price information
**        from the bookprice table. 
**
**    Auth: Alan Katzen
**    Date: 29 March 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:        Author:        Description:
**    --------    --------        -------------------------------------------
**    02/23/2016   UK			  36096 Allow Sorting and Filtering for Title Prices
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT p.*, g1.gen2ind, p.pricetypecode as origpricetypecode, p.currencytypecode as origcurrencytypecode, 
		 COALESCE(p.activeind, 0) as origactiveind, p.budgetprice as origbudgetprice, p.finalprice as origfinalprice,
		 p.effectivedate as origeffectivedate, p.expirationdate as origexpirationdate, p.sortorder as origsortorder,		 
		 g1.datadesc as pricetypedescription, g2.datadesc as currencytypedescription
  FROM bookprice p INNER JOIN gentables g1 ON p.pricetypecode = g1.datacode AND g1.tableid = 306 
				   INNER JOIN gentables g2 ON p.currencytypecode = g2.datacode AND g2.tableid = 122 
  WHERE p.bookkey = @i_bookkey
  ORDER BY p.sortorder    

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END
GO

GRANT EXEC ON qtitle_get_prices TO PUBLIC
GO
