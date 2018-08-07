if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_get_itemnumber') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.WK_get_itemnumber
GO

CREATE FUNCTION dbo.WK_get_itemnumber
    ( @bookkey as int
    ) 
    
RETURNS varchar(50)


BEGIN 
  DECLARE @RETURN varchar(50)

--Check for EAN13 first, if it does not exist then check itemnumber
SET @RETURN = ''

Select @RETURN = dbo.rpt_get_isbn(@bookkey, 17)

IF @RETURN IS NULL OR @RETURN = ''
	BEGIN
		SELECT @RETURN = itemnumber from isbn where bookkey = @bookkey
	END

IF @RETURN IS NULL 
	BEGIN
		SET @RETURN = ''
	END

   
RETURN @RETURN

END


