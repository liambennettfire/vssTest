SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_countries_with_exclusive_rights') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_countries_with_exclusive_rights
GO

CREATE FUNCTION rpt_get_countries_with_exclusive_rights
		(@i_bookkey	INT,
     @i_territorycode INT,
		 @v_column	VARCHAR(1))
	RETURNS VARCHAR(MAX)

/*	The purpose of the rpt_get_countries_with_exclusive_rights function is to return a 
concatenated specific description column from gentables from code2 from gentablesrelationshipdetail
where gentablesrelationshipkey = 4 (Default Countries for Territory)

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	
AS
BEGIN

	DECLARE @RETURN	VARCHAR(MAX)
	DECLARE @v_desc	    	VARCHAR(255)
  DECLARE @v_concat_desc	VARCHAR(MAX)
	DECLARE @i_countrycode int
  DECLARE @v_bisacdatacode VARCHAR(10)
	DECLARE @i_gentablesrelationshipdetail_cursor_status int
	DECLARE @i_count int

  SELECT @v_concat_desc = ''
  SELECT @v_desc = ''

	DECLARE cursor_gentablesrelationshipdetail CURSOR FOR
		SELECT code2,bisacdatacode
      FROM gentablesrelationshipdetail,gentables
     WHERE gentablesrelationshipkey = 4
       AND gentables.tableid = 114
       AND gentables.datacode = gentablesrelationshipdetail.code2
       AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
       AND code1 = @i_territorycode
       ORDER by bisacdatacode
     

	OPEN cursor_gentablesrelationshipdetail
	
	FETCH NEXT FROM cursor_gentablesrelationshipdetail INTO @i_countrycode,@v_bisacdatacode
	
	select @i_count=0
		
	select @i_gentablesrelationshipdetail_cursor_status = @@FETCH_STATUS
	
	while (@i_gentablesrelationshipdetail_cursor_status<>-1 )
	begin
		IF (@i_gentablesrelationshipdetail_cursor_status<>-2)
		begin
			IF @v_column = 'D'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(datadesc))
				  FROM gentables  
				 WHERE tableid = 114
					AND datacode = @i_countrycode
			END
			ELSE IF @v_column = 'E'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(externalcode))
				 FROM	gentables  
				WHERE tableid = 114
				  AND datacode = @i_countrycode
			END
			ELSE IF @v_column = 'S'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(datadescshort))
				  FROM gentables  
				 WHERE  tableid = 114
					AND datacode = @i_countrycode
			END
			ELSE IF @v_column = 'B'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
				  FROM gentables  
				WHERE tableid = 114
				  AND datacode = @i_countrycode
			END
			ELSE IF @v_column = '1'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
				  FROM gentables  
				 WHERE tableid = 114
					AND datacode = @i_countrycode
			END
			ELSE IF @v_column = '2'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(datadesc))
				  FROM gentables  
				 WHERE tableid = 114
					AND datacode = @i_countrycode
			END
	    IF LEN(@v_desc) > 0
			BEGIN
         IF LEN(@v_concat_desc) > 0 
         BEGIN
			 		SELECT @v_concat_desc = @v_concat_desc + ', ' + @v_desc
         END
         ELSE
         BEGIN
					SELECT @v_concat_desc =  @v_desc
         END
			END
		end /* End If status statement */
		
		FETCH NEXT FROM cursor_gentablesrelationshipdetail INTO @i_countrycode,@v_bisacdatacode
		select @i_gentablesrelationshipdetail_cursor_status = @@FETCH_STATUS
	end /** End Cursor While **/
	
	close cursor_gentablesrelationshipdetail
	deallocate cursor_gentablesrelationshipdetail
	
	
	IF LEN(@v_concat_desc) > 0
	BEGIN
		SELECT @RETURN = @v_concat_desc
	END
	ELSE
	BEGIN
		SELECT @RETURN = ''
	END
	
	RETURN @RETURN

END
go

grant execute on rpt_get_countries_with_exclusive_rights to public
go
