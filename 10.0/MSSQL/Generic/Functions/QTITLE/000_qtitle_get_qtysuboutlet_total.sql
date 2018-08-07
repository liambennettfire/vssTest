if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_qtysuboutlet_total') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qtitle_get_qtysuboutlet_total
GO

CREATE FUNCTION qtitle_get_qtysuboutlet_total
  (@i_bookkey as integer, @i_printingkey as integer, @i_qtyoutletcode as integer, @i_qtytype as char(1)) 

RETURNS BIGINT

/******************************************************************************
**  Name: qtitle_get_qtysuboutlet_total
**  Desc: This function returns the actual quantity
**        for a specific outlet in qtybreakdown.
**
**  Auth: Uday Khisty
**  Date: 20 June 2012
*******************************************************************************/

BEGIN 
  DECLARE @i_total      BIGINT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_total = 0

  IF @i_qtytype = 'A' --actual
    SELECT @i_total = sum(cast(qty as bigint))
    FROM bookqtybreakdown
    WHERE bookkey     = @i_bookkey and
		  printingkey = @i_printingkey and
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

GRANT EXEC ON dbo.qtitle_get_qtysuboutlet_total TO public
GO
