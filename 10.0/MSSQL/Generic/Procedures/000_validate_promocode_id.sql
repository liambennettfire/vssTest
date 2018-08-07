if exists (select * from dbo.sysobjects where id = object_id(N'dbo.validate_promocode_id') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.validate_promocode_id
GO

CREATE PROCEDURE validate_promocode_id
  @i_projectkey         INT,
  @i_elementkey         INT,
  @i_productidcode_value VARCHAR(50),
  @o_result             VARCHAR(50) OUTPUT,	
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT 
AS

/******************************************************************************************
**  Name: validate_promocode_id
**  Desc: Verifies that the Promo Code ID is unique on Project/Element ID gentable 594.
**
**  Auth: Kusum
**  Date: May 12 2015
*******************************************************************************************/

DECLARE
  @v_datacode  int,
  @v_count	   int
  
  
BEGIN
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	SELECT @v_datacode = COALESCE(datacode,0)
      FROM gentables
     WHERE tableid = 594 AND eloquencefieldtag = 'CLD_PC_PROMO_CODE_ID'
     
     IF @v_datacode > 0 BEGIN
		SELECT @v_count = COUNT(*)
		  FROM taqproductnumbers
		 WHERE productidcode = @v_datacode
		   AND productnumber = LTRIM(RTRIM(@i_productidcode_value))
		   
		IF @v_count > 0 BEGIN
			 SET @o_error_code = -1
			 SET @o_error_desc = 'Promo Code: ' + @i_productidcode_value  + ' already exists.'
		END 
		ELSE BEGIN
			SET @o_result = @i_productidcode_value
		END
	END
END
go

GRANT EXEC ON validate_promocode_id TO PUBLIC
GO