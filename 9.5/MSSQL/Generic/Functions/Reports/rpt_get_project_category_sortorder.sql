IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_project_category_sortorder') )
DROP FUNCTION dbo.rpt_get_project_category_sortorder
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_project_category_sortorder](@i_taqprojectkey	INT,@i_tableid	INT,@i_order INT,@v_column	VARCHAR(1))
RETURNS VARCHAR(255)

/*******************************************************************************************************************************/
--	The purpose of the rpt_get_project_category function is to return a specific description column from gentables for any of the 
--	configurable subject categories tables
--
--	Parameter Options
--		@i_tableid
--			Returns the respective subject category table - typical category tableids are:
--			Tablid 412
--			Tablid 413
--			Tablid 414
--			Tablid 431
--			Tablid 432
--			Tablid 433
--			Tablid 434
--			Tablid 435
--			Tablid 436
--			Tablid 437
--
--		@i_order	-> Each book may have multipe subjects - enter the sort order number to pull
--			1...n
--
--		@v_column  (column from gentables)
--			D = Data Description
--			E = External code
--			S = Short Description
--			B = BISAC Data Code
--			T = Eloquence Field Tag
--			1 = Alternative Description 1
--			2 = Alternative Deccription 2 
--
--    Author: Kusum Basra
--    Date Written: 04/18/13  
/*******************************************************************************************************************************/

AS
BEGIN
	DECLARE @v_desc					VARCHAR(255)
	DECLARE @i_categorycode			INT
	DECLARE @v_count 					INT

   SELECT @v_desc = ''
   SELECT @v_count = 0

   SELECT @v_count = count(*)
     FROM taqprojectsubjectcategory
	 WHERE taqprojectkey = @i_taqprojectkey
  	   AND categorytableid = @i_tableid
	   AND sortorder = @i_order

   IF @v_count > 0
   BEGIN
		SELECT @i_categorycode = categorycode
		  FROM taqprojectsubjectcategory
		 WHERE taqprojectkey = @i_taqprojectkey
		   AND categorytableid = @i_tableid
		   AND sortorder = @i_order

      IF @i_categorycode IS NULL 
      	SELECT @i_categorycode = 0

			
		IF @i_categorycode > 0 
		BEGIN
				IF @v_column = 'D'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc)) 
					  FROM gentables  
					 WHERE tableid = @i_tableid
						AND datacode = @i_categorycode
				END
				IF @v_column = 'E'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(externalcode))	
					 FROM	gentables  
					WHERE  tableid = @i_tableid
					  AND datacode = @i_categorycode
				END
				IF @v_column = 'S'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadescshort))
					  FROM gentables  
					 WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END
				IF @v_column = 'B'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
					 FROM	gentables  
					 WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END
				IF @v_column = '1'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
					 FROM	 gentables  
					WHERE  tableid = @i_tableid
					  AND datacode = @i_categorycode
				END
				IF @v_column = '2'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					 FROM	gentables  
					WHERE  tableid = @i_tableid
					  AND datacode = @i_categorycode
				END
		END
  END
  RETURN @v_desc
END
go
grant all on rpt_get_project_category_sortorder to public
go