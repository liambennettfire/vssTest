if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_get_misc_generic') and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop function dbo.qcs_get_misc_generic
GO


CREATE FUNCTION dbo.qcs_get_misc_generic (@bookkey INT,
@productTag VARCHAR(50))

RETURNS @generic_misc TABLE(
    --[Id] [uniqueidentifier] NOT NULL,
    Tag  VARCHAR(50),
    [Key] VARCHAR(25),
    AlternateKey VARCHAR(25),
	Value VARCHAR(4000) NULL
	)
AS
BEGIN

		  INSERT INTO @generic_misc
		  SELECT 
         -- NEWID() AS Id,
          @productTag + '-' + 'ZALLAGES' AS Tag, 
          'DPIDXBIZALLAGES' AS 'Key', 
          'ZALLAGES' AS AlternateKey, 
          'Yes' AS Value
    FROM
          bookdetail  bd
		   
    WHERE bookkey = @bookkey AND coalesce(bd.allagesind,0)<>0
		 
		

	 RETURN
END
GO
GRANT SELECT ON dbo.qcs_get_misc_generic TO PUBLIC


