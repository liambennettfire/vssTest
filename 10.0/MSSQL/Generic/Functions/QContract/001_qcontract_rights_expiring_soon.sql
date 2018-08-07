if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_rights_expiring_soon') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qcontract_rights_expiring_soon
GO

CREATE FUNCTION dbo.qcontract_rights_expiring_soon
(
  @i_expirationdate as datetime
) 
RETURNS tinyint

/*******************************************************************************************************
**  Name: qcontract_rights_expiring_soon
**  Desc: This function returns true if the passed date is within clientdefaults 86 days of today
**
**  Auth: Colman
**  Date: Jan 26, 2017
*******************************************************************************************************/

BEGIN 
  DECLARE  @v_soon_days  INT,
           @v_datediff   INT
  
  SET @v_soon_days = 90 -- default to 90 days
  
	SELECT @v_soon_days = ISNULL(clientdefaultvalue,90) FROM clientdefaults WHERE clientdefaultid = 86

  SELECT @v_datediff = DATEDIFF(day, getdate(), @i_expirationdate)

  IF @v_datediff < @v_soon_days
    RETURN 1

  RETURN 0
END
GO

GRANT EXEC ON dbo.qcontract_rights_expiring_soon TO public
GO
