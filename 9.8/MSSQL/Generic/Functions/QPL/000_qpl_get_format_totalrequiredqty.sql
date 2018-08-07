if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_format_totalrequiredqty') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_get_format_totalrequiredqty
GO

CREATE FUNCTION qpl_get_format_totalrequiredqty
(  
  @i_projectkey as integer,
  @i_plstage    as integer,
  @i_versionkey as integer,
  @i_formatkey  as integer
)
RETURNS INTEGER

/*****************************************************************************************************
**  Name: qpl_get_format_totalrequiredqty
**  Desc: This funtion returns the Total Required Quantity for given P&L Version by Format.
**        Total Required Quantity = Gross Sales Units + Additional Units
**
**  Auth: Kate Wiewiora
**  Date: March 20 2008
*****************************************************************************************************/

BEGIN

  DECLARE
    @v_sum_addtlunits INT,
    @v_sum_grossunits INT,
    @v_totalrequiredqty  INT
   
  SELECT @v_sum_grossunits = SUM(u.grosssalesunits)
  FROM taqversionsaleschannel c, taqversionsalesunit u
  WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
	  c.taqprojectkey = @i_projectkey AND
	  c.plstagecode = @i_plstage AND
	  c.taqversionkey = @i_versionkey AND
    c.taqprojectformatkey = @i_formatkey
        
  SELECT @v_sum_addtlunits = SUM(y.quantity)
  FROM taqversionaddtlunits u, taqversionaddtlunitsyear y
  WHERE u.addtlunitskey = y.addtlunitskey AND
      u.taqprojectkey = @i_projectkey AND
      u.plstagecode = @i_plstage AND 
      u.taqversionkey = @i_versionkey AND
      u.taqprojectformatkey = @i_formatkey

  IF @v_sum_grossunits IS NULL
    SET @v_sum_grossunits = 0
  IF @v_sum_addtlunits IS NULL
    SET @v_sum_addtlunits = 0
    
  SET @v_totalrequiredqty = @v_sum_grossunits + @v_sum_addtlunits
  RETURN @v_totalrequiredqty
  
END
GO

GRANT EXEC ON qpl_get_format_totalrequiredqty TO PUBLIC
GO
