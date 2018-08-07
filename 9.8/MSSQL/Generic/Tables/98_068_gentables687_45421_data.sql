DECLARE @o_datacode INT,
		@o_error_code INT,
		@o_error_desc VARCHAR(2000)

SET @o_datacode = NULL
SET @o_error_code = 0
SET @o_error_desc = NULL

EXEC qutl_insert_gentable_value 687, 'PaymentMethod', 1, 'Check', 1, 1, @o_datacode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

IF @o_error_code <> 0 OR LEN(COALESCE(@o_error_desc, '')) > 0
BEGIN
	Print 'ERROR: ' + @o_error_desc
END

SET @o_datacode = NULL
SET @o_error_code = 0
SET @o_error_desc = NULL

EXEC qutl_insert_gentable_value 687, 'PaymentMethod', 2, 'Wire', 2, 1, @o_datacode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

IF @o_error_code <> 0 OR LEN(COALESCE(@o_error_desc, '')) > 0
BEGIN
	Print 'ERROR: ' + @o_error_desc
END