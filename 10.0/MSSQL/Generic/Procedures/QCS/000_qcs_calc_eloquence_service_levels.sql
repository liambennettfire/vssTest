if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_calc_eloquence_service_levels') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcs_calc_eloquence_service_levels
GO

CREATE PROCEDURE qcs_calc_eloquence_service_levels (  
  @i_userkey      INT,
  @o_result       VARCHAR(2000) OUTPUT,
  @o_error_code   integer = null output,
  @o_error_desc   varchar(2000) = null output
  )
AS

/******************************************************************************************
**  Name: qcs_calc_eloquence_service_levels
**  Desc: Misc item calculation - Service level(s) of user authorized customers.
**
**  Auth: Colman
**  Date: Jan 4, 2016
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------
**  02/12/2016   Colman	     Case 35302
**  03/01/2016   Colman	     Case 35302 join customer from orgentry.elocustomerkey
**  03/02/2016   Colman	     Case 35302 greatly simplified functionality
*******************************************************************************************/

DECLARE 
        @v_distinctlevelcount int,
        @v_servicelevel VARCHAR(40)
        
BEGIN
  SET @v_servicelevel = 'No Eloquence services'

  SELECT @v_distinctlevelcount = COUNT(DISTINCT g.datadesc) FROM customer c
  JOIN gentables g ON g.tableid = 677 AND c.servicelevelcode = g.datacode
  WHERE c.servicelevelcode IS NOT NULL 

  IF @v_distinctlevelcount = 1 BEGIN
    SELECT @v_servicelevel = g.datadesc FROM customer c
    JOIN gentables g ON g.tableid = 677 AND c.servicelevelcode = g.datacode
    WHERE c.servicelevelcode IS NOT NULL 
  END
  
  IF @v_distinctlevelcount > 1 BEGIN
    SET @v_servicelevel = 'See individual titles'
  END

  SET @o_result = @v_servicelevel
END
GO

GRANT EXEC ON qcs_calc_eloquence_service_levels TO PUBLIC
GO
