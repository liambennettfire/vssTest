IF NOT EXISTS (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_get_misc_generic') and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
BEGIN
    execute dbo.sp_executesql @statement = N'
        CREATE FUNCTION dbo.qcs_get_misc_generic (@bookkey INT,
		@productTag VARCHAR(50))

		RETURNS @generic_misc TABLE(
			Tag  VARCHAR(50),
			[Key] VARCHAR(25),
			AlternateKey VARCHAR(25),
			Value VARCHAR(4000) NULL
			)
		AS
		BEGIN

			 RETURN
		END   ' 
END

