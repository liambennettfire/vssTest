if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_genrel_table1_multilevel_count') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_genrel_table1_multilevel_count
GO

CREATE FUNCTION qutl_genrel_table1_multilevel_count (
  @i_gentablesrelationshipkey  INT,
  @i_code1			INT,
  @i_subcode1		INT,
  @i_sub2code1	INT) 

RETURNS int

/**********************************************************************************
**  Name: qutl_genrel_table1_multilevel_count
**  Desc: Function to check if records exist on gentablesrelationshipdetail.
**        Returns 1 if count>0, 0 if count=0, or -1 for an error. 
**
**  Auth: Kate Wiewiora
**  Date: 16 August 2007
**********************************************************************************/

BEGIN 
  DECLARE
    @i_count INT,
    @v_error INT
  
  IF @i_subcode1 IS NOT NULL AND @i_subcode1 > 0
  BEGIN
		IF @i_sub2code1 IS NOT NULL AND @i_sub2code1 > 0
		BEGIN
			SELECT @i_count = COUNT(*)
			FROM gentablesrelationshipdetail d
			WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
						d.code1 = @i_code1 AND
						d.subcode1 = @i_subcode1 AND
						d.sub2code1 = @i_sub2code1
		END
		ELSE BEGIN
			SELECT @i_count = COUNT(*)
			FROM gentablesrelationshipdetail d
			WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
						d.code1 = @i_code1 AND
						d.subcode1 = @i_subcode1
		END
  END
  ELSE BEGIN
		SELECT @i_count = COUNT(*)
		FROM gentablesrelationshipdetail d
		WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
					d.code1 = @i_code1
  END
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    RETURN -1
  END 

  -- return 1 or 0 so that object can set params 
  IF @i_count > 0
    SET @i_count = 1
  ELSE
    SET @i_count = 0

  RETURN @i_count
END
GO

GRANT EXEC ON dbo.qutl_genrel_table1_multilevel_count TO public
GO
