if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_qtysuboutlet_total') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qproject_get_qtysuboutlet_total
GO

CREATE FUNCTION qproject_get_qtysuboutlet_total
  (@i_projectkey as integer, @i_qtyoutletcode as integer, @i_qtytype as char(1)) 

RETURNS BIGINT

/******************************************************************************
**  Name: qproject_get_qtysuboutlet_total
**  Desc: This function returns the total estimated or actual quantity
**        for a specific outlet in qtybreakdown.
**
**  Auth: Alan Katzen
**  Date: 25 January 2008
*******************************************************************************/

BEGIN 
  DECLARE @i_total      BIGINT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_total = 0

  IF @i_qtytype = 'E' --estimated
    SELECT @i_total = sum(cast(estqty as bigint))
    FROM taqprojectqtybreakdown
    WHERE taqprojectkey = @i_projectkey and
        qtyoutletcode = @i_qtyoutletcode
  ELSE  --actual
    SELECT @i_total = sum(cast(qty as bigint))
    FROM taqprojectqtybreakdown
    WHERE taqprojectkey = @i_projectkey and
        qtyoutletcode = @i_qtyoutletcode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_total = -1
  END 

  IF @i_total > 0 BEGIN
    RETURN @i_total
  END

  RETURN 0
END
GO

GRANT EXEC ON dbo.qproject_get_qtysuboutlet_total TO public
GO
