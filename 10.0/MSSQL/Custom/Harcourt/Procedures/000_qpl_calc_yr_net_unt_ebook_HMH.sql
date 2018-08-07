if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc089') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc089
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_net_unt_ebook_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_net_unt_ebook_HMH
GO

CREATE PROCEDURE qpl_calc_yr_net_unt_ebook_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,  
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_net_unt_ebook_HMH
**  Desc: Houghton Mifflin Item 89 - Year/Net Units - Ebook.
**
**  Auth: Kate
**  Date: March 3 2010
*******************************************************************************************/

DECLARE
  @v_ebook_net_units  INT
  
BEGIN

  SET @o_result = NULL

  SELECT @v_ebook_net_units = SUM(netsalesunits)
  FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f
  WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
      c.taqprojectkey = f.taqprojectkey AND
      c.plstagecode = f.plstagecode AND
      c.taqversionkey = f.taqversionkey AND
      c.taqprojectformatkey = f.taqprojectformatkey AND
      c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstage AND
      c.taqversionkey = @i_plversion AND
      u.yearcode = @i_yearcode AND
      f.mediatypecode = 14 

  SET @o_result = @v_ebook_net_units
  
END
GO

GRANT EXEC ON qpl_calc_yr_net_unt_ebook_HMH TO PUBLIC
GO
