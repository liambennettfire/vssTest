if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_total_net_sales') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_total_net_sales
GO

CREATE PROCEDURE qpl_calc_yr_total_net_sales (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_plyear		INT,
  @i_formattype  VARCHAR(50),   
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_total_net_sales
**  Desc: This stored procedure gets the Total Net Sales by format grouping.
**        Format is determined by gentext1 string stored on gentables_ext/subgentables_ext 312.
**
**  Auth: Kate W.
**  Date: October 17 2013
*******************************************************************************************/

DECLARE
  @v_channel_net FLOAT,
  @v_discount_percent FLOAT,
  @v_formats_clause	VARCHAR(4000),
  @v_format_price DECIMAL(9,2),
  @v_sqlstring NVARCHAR(4000),
  @v_sum_netunits INT,
  @v_total_net FLOAT
  
BEGIN
  
  SET @o_result = NULL  
 
  CREATE TABLE #temp 
    (activeprice FLOAT,
    discountpercent FLOAT,
    netunits INT)  

	-- Now get the where clause for media and format based on the @i_formattype parameter
  SET @v_formats_clause = dbo.qpl_calc_get_unit_by_type_clause(@i_formattype)

	SET @v_sqlstring = N'INSERT INTO #temp ' +
	  'SELECT COALESCE(f.activeprice,0), COALESCE(c.discountpercent,0) / 100, COALESCE(SUM(u.netsalesunits),0) ' +
	  'FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f ' +
     'WHERE u.taqversionsaleskey = c.taqversionsaleskey' + 
      ' AND c.taqprojectformatkey = f.taqprojectformatkey' + 
      ' AND c.taqprojectkey = ' + CONVERT(VARCHAR, @i_projectkey) +
      ' AND c.plstagecode = ' + CONVERT(VARCHAR, @i_plstage) +
      ' AND c.taqversionkey = ' + CONVERT(VARCHAR, @i_plversion) +
      ' AND u.yearcode = ' + CONVERT(VARCHAR, @i_plyear) +
      ' AND (' + @v_formats_clause + ') ' +
      'GROUP BY discountpercent, activeprice'

	EXECUTE sp_executesql @v_sqlstring

  -- Loop through all individual sales channel/sub channel sales unit records to calculate total Gross Sales
  DECLARE salesunits_cur CURSOR FOR  
    SELECT activeprice, discountpercent, netunits 
    FROM #temp 

  OPEN salesunits_cur

  FETCH salesunits_cur INTO @v_format_price, @v_discount_percent, @v_sum_netunits

  SET @v_total_net = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
    SET @v_channel_net = @v_format_price * @v_sum_netunits * (1 - @v_discount_percent)
    SET @v_total_net = @v_total_net + @v_channel_net

    FETCH salesunits_cur INTO @v_format_price, @v_discount_percent, @v_sum_netunits
  END

  CLOSE salesunits_cur
  DEALLOCATE salesunits_cur

  DROP TABLE #temp

  SET @o_result = @v_total_net
   
END
go

GRANT EXEC ON dbo.qpl_calc_yr_total_net_sales TO PUBLIC
GO

