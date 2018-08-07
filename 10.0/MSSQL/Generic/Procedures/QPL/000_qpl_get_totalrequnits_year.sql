if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_totalrequnits_year') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_totalrequnits_year
GO

CREATE PROCEDURE qpl_get_totalrequnits_year (  
  @i_projectkey     integer,
  @i_plstage        integer,
  @i_versionkey     integer,
  @i_yearcode				integer,
  @i_formatkey			integer,
  @i_result					integer output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  Name: qpl_get_totalrequnits_year
**  Desc: This stored procedure returns the total required units for the specified year code and format type.
**
**  Auth: Dustin Miller
**  Date: November 14, 2011
*****************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
	SET @i_result = (SELECT SUM(quantity) AS quantity FROM
	(SELECT taqprojectformatkey, SUM(quantity) AS quantity
		FROM taqversionaddtlunits u, taqversionaddtlunitsyear y
		WHERE u.addtlunitskey = y.addtlunitskey AND
				u.taqprojectkey = @i_projectkey AND
				u.plstagecode = @i_plstage AND 
				u.taqversionkey = @i_versionkey AND
				y.yearcode = @i_yearcode
				GROUP BY taqprojectformatkey
	UNION ALL
	SELECT taqprojectformatkey, SUM(grosssalesunits) AS quantity
		FROM taqversionsaleschannel c, taqversionsalesunit u
		WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
			c.taqprojectkey = @i_projectkey AND
			c.plstagecode = @i_plstage AND
			c.taqversionkey = @i_versionkey AND
			u.yearcode = @i_yearcode
			GROUP BY taqprojectformatkey) InnerQuery
	WHERE taqprojectformatkey=@i_formatkey)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access either taqversionsaleschannel/taqversionsalesunit or taqversionaddtlunits/taqversionaddtlunitsyear tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END
  
  DECLARE @resultSet TABLE (quantity int)
  INSERT INTO @resultSet (quantity)
  VALUES (@i_result)
  
  SELECT quantity FROM @resultSet

END
GO

GRANT EXEC ON qpl_get_totalrequnits_year TO PUBLIC
GO
