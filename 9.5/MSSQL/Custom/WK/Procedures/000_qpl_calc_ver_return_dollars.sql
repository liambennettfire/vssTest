if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_return_dollars') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_return_dollars
GO

CREATE PROCEDURE qpl_calc_ver_return_dollars (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_saleschanneltype  VARCHAR(50),    
  @i_formattype  VARCHAR(50),   
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_return_dollars
**  Desc: This stored procedure gets the Returns dollar value by sales channel and format grouping.
**        Sales channel is determined by gentext1 string stored on gentables_ext 118.
**        Format is determined by gentext1 string stored on gentables_ext/subgentables_ext 312.
**
**  Auth: Kate W.
**  Date: October 16 2013
*******************************************************************************************/

DECLARE
  @v_channel_returns FLOAT,
  @v_discount_percent FLOAT,
  @v_formats_clause	VARCHAR(4000),
  @v_format_price DECIMAL(9,2),
  @v_saleschannelcode INT,
  @v_sqlstring NVARCHAR(4000),
  @v_sum_returnunits INT,
  @v_total_returns FLOAT
  
BEGIN
  
  SET @o_result = NULL  

  SELECT @v_saleschannelcode = g.datacode 
  FROM gentables_ext ge
    JOIN gentables g ON ge.tableid = g.tableid AND ge.datacode = g.datacode
  WHERE ge.tableid = 118 AND g.deletestatus = 'N' AND ge.gentext1 = @i_saleschanneltype

  IF @@ROWCOUNT <> 1 
  BEGIN
    --Could not find a matching entry, maybe the setup is not done yet - return 0 
    SET @o_result = 0
    RETURN
  END
  
  CREATE TABLE #temp 
    (activeprice FLOAT,
    discountpercent FLOAT,
    returnunits INT)  

	-- Now get the where clause for media and format based on the @i_formattype parameter
  SET @v_formats_clause = dbo.qpl_calc_get_unit_by_type_clause(@i_formattype)

	SET @v_sqlstring = N'INSERT INTO #temp ' +
	  'SELECT COALESCE(f.activeprice,0), COALESCE(c.discountpercent,0) / 100, COALESCE(SUM(u.grosssalesunits),0) - COALESCE(SUM(u.netsalesunits),0) ' +
	  'FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f ' +
     'WHERE u.taqversionsaleskey = c.taqversionsaleskey' + 
      ' AND c.taqprojectformatkey = f.taqprojectformatkey' + 
      ' AND c.taqprojectkey = ' + CONVERT(VARCHAR, @i_projectkey) +
      ' AND c.plstagecode = ' + CONVERT(VARCHAR, @i_plstage) +
      ' AND c.taqversionkey = ' + CONVERT(VARCHAR, @i_plversion) +
      ' AND c.saleschannelcode = ' + CONVERT(VARCHAR, @v_saleschannelcode) +
      ' AND (' + @v_formats_clause + ') ' +
      'GROUP BY discountpercent, activeprice'

	EXECUTE sp_executesql @v_sqlstring

  -- Loop through all individual sales channel/sub channel sales unit records to calculate total Gross Sales
  DECLARE salesunits_cur CURSOR FOR  
    SELECT activeprice, discountpercent, returnunits 
    FROM #temp 

  OPEN salesunits_cur

  FETCH salesunits_cur INTO @v_format_price, @v_discount_percent, @v_sum_returnunits

  SET @v_total_returns = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
    SET @v_channel_returns = @v_format_price * @v_sum_returnunits * (1 - @v_discount_percent)
    SET @v_total_returns = @v_total_returns + @v_channel_returns

    FETCH salesunits_cur INTO @v_format_price, @v_discount_percent, @v_sum_returnunits
  END

  CLOSE salesunits_cur
  DEALLOCATE salesunits_cur

  DROP TABLE #temp

  SET @o_result = @v_total_returns
   
END
go

GRANT EXEC ON dbo.qpl_calc_ver_return_dollars TO PUBLIC
GO
