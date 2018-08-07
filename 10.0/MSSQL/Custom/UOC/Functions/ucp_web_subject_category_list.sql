SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ucp_web_subject_category_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ucp_web_subject_category_list]
GO

CREATE FUNCTION ucp_web_subject_category_list(@i_bookkey INT)
RETURNS VARCHAR(200)
AS
BEGIN
--Returns a comma sep list of subject categories for use in web feed
--Assembles list from major and minor subjects and LC Category prefix

	DECLARE @result VARCHAR(200),
					@aaup_code VARCHAR(2),
					@completeCatSubjectsTableid INT,
					@lcCategoryCopyType INT,
					@lcCategoryCopySubType INT,
					@separator VARCHAR(10)

	SELECT @completeCatSubjectsTableid = 412, 
		@lcCategoryCopyType = 1, 
		@lcCategoryCopySubType = 52,
		@separator = ','

	--Get major/minor subjects
	DECLARE c_auup_codes CURSOR FOR 
		SELECT DISTINCT RIGHT('0' + CAST(CONVERT(DECIMAL(10,0), COALESCE(sg.numericdesc1, g.numericdesc1)) AS VARCHAR(2)),2)
			FROM booksubjectcategory sc
				JOIN gentables g
					ON g.tableid = @completeCatSubjectsTableid
	        AND sc.categorycode = g.datacode and sc.categorytableid=@completeCatSubjectsTableid
				LEFT JOIN subgentables sg
					ON g.tableid = sg.tableid
					AND sc.categorycode = sg.datacode
					AND sc.categorysubcode = sg.datasubcode 
			WHERE sc.bookkey = @i_bookkey
		

	SELECT @result = ''
	OPEN c_auup_codes
	FETCH c_auup_codes INTO @aaup_code
	WHILE (@@fetch_status = 0)
		BEGIN
			if @aaup_code <> '0'
			  begin
				SELECT @result = @result + @aaup_code +  @separator
			  end
			FETCH c_auup_codes INTO @aaup_code
	  END
  CLOSE c_auup_codes
  DEALLOCATE c_auup_codes


	--Get LC Subject 
	DECLARE @lcCategory AS VARCHAR(2)
	
	SELECT @lcCategory = CAST(commenttext AS VARCHAR(2)) 
		FROM bookcomments 
		WHERE bookkey = @i_bookkey
			AND commenttypecode = @lcCategoryCopyType 
			AND commenttypesubcode = @lcCategoryCopySubType
	
	--Map LC Cateogry to Web Code
	IF (@lcCategory IS NOT NULL)
		BEGIN
			IF (ISNUMERIC(SUBSTRING(@lcCategory,2,1))= 1)
				SELECT @lcCategory = LEFT(@lcCategory,1)
		
			SELECT @aaup_code = RIGHT('0' + CAST(aaup_code AS VARCHAR(2)),2)
	      FROM ucp_map_lc_category_to_web_subject_code
	      WHERE lc_category = @lcCategory
	
			IF CHARINDEX(@aaup_code, @result) = 0  --If not already in the list then add
				SELECT @result = @result + @aaup_code + @separator

		END


	--Remove trailing comma
	if LEN(@result) > 0
   	  begin
		SELECT @result = SUBSTRING(@result, 1, (LEN(@result) - LEN(@separator)))
	 end

  RETURN @result

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
