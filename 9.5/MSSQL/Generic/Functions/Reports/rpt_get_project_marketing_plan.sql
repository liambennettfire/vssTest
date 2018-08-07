SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_project_marketing_plan') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_project_marketing_plan
GO

CREATE FUNCTION [dbo].[rpt_get_project_marketing_plan](@i_taqprojectkey	INT,@v_column	VARCHAR(1))
RETURNS VARCHAR(255)


/*******************************************************************************************************************************/
--	The purpose of the rpt_get_project_category function is to return a specific description column from gentable tableid 529 
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
--    Date Written: 04/18/2013  
/*******************************************************************************************************************************/
AS
BEGIN
	DECLARE @v_desc					VARCHAR(255)
	DECLARE @v_marketingplancode	INT
	DECLARE @v_count 					INT
  

   SELECT @v_desc = ''
   SELECT @v_count = 0

   SELECT @v_count = count(*)
     FROM taqprojecttitle
	  WHERE taqprojectkey =  @i_taqprojectkey
      AND primaryformatind = 1 

   IF @v_count > 0
   BEGIN
		SELECT @v_marketingplancode = marketingplancode
      FROM taqprojecttitle
	   WHERE taqprojectkey =  @i_taqprojectkey
       AND primaryformatind = 1 

    IF @v_marketingplancode IS NULL 
      	SELECT @v_marketingplancode = 0

		
		IF @v_marketingplancode > 0 
		BEGIN
			IF @v_column = 'D'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(datadesc))
				  FROM gentables  
				 WHERE tableid = 524
					 AND datacode = @v_marketingplancode
			END
			IF @v_column = 'E'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(externalcode))
				  FROM gentables  
				 WHERE tableid = 524
					 AND datacode = @v_marketingplancode
			END
			IF @v_column = 'S'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(datadescshort))
				  FROM gentables  
				 WHERE tableid = 524
					 AND datacode = @v_marketingplancode
			END
			IF @v_column = 'B'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
				  FROM gentables  
				 WHERE tableid = 524
					 AND datacode = @v_marketingplancode
			END
			IF @v_column = '1'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
				  FROM gentables  
				 WHERE tableid = 524
					 AND datacode = @v_marketingplancode
			END
			IF @v_column = '2'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(datadesc))
				  FROM gentables  
				 WHERE tableid = 524
					 AND datacode = @v_marketingplancode
			END
		END
	END

	RETURN @v_desc
END
go

GRANT ALL ON dbo.rpt_get_project_marketing_plan TO PUBLIC
