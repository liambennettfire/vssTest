/******    Change History
*******************************************************************************
**    Date:    Author:     Description:
**    3/7/16  Olivia Asaro  If Exists Drop did not have correct syntax
**    -------- --------    -------------------------------------------
**   
*******************************************************************************/




/****** Object:  UserDefinedFunction [dbo].[rpt_get_minimum_project_category]    Script Date: 3/4/2016 2:00:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_minimum_project_category]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_minimum_project_category]
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_minimum_project_category]    Script Date: 3/4/2016 2:00:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE function [dbo].[rpt_get_minimum_project_category](@i_taqprojectkey int, @i_category_tableid int,@i_order int,@i_DescType varchar(10))
returns varchar(255)
as begin

/*
**		@i_desctype Parameter Options
**		D = Data Description
**		E = External code
**		S = Short Description
**		B = BISAC Data Code
**		T = Eloquence Field Tag
**		1 = Alternative Description 1
**		2 = Alternative Deccription 2
**      Q = Export to eloquence Indicator

         @i_order is the order of the category. if @i_order = 1 and there are two categories with sort order of 2 and 3, it will pick
         2, if @i_order=2 then it will pick 3.
*/

declare @i_categorycode int, @i_categorysubcode int, @i_categorysub2code int, @return varchar(255)


SELECT @i_categorycode = categorycode,@i_categorysubcode = categorysubcode, @i_categorysub2code = categorysub2code FROM (
  SELECT
    ROW_NUMBER() OVER (ORDER BY sortorder ASC) AS rownumber, categorycode, categorysubcode, categorysub2code
  FROM taqprojectsubjectcategory c where @i_taqprojectkey = taqprojectkey and @i_category_tableid = categorytableid 
) AS foo
WHERE rownumber=@i_order

IF @i_categorycode IS NULL   
       SELECT @i_categorycode = 0  
  
IF @i_categorysubcode IS NULL   
       SELECT @i_categorysubcode = 0  
  
IF @i_categorysub2code IS NULL   
       SELECT @i_categorysub2code = 0  
       
       
if @i_categorysub2code > 0 and  @i_categorysubcode > 0 and @i_categorycode>0
begin

	Select @return=dbo.rpt_get_sub2gentables_field(@i_category_tableid,@i_categorycode, @i_categorysubcode , @i_categorysub2code,@i_DescType)

end

    
if @i_categorysub2code = 0 and  @i_categorysubcode > 0 and @i_categorycode>0
begin

	Select @return=dbo.rpt_get_subgentables_field(@i_category_tableid,@i_categorycode, @i_categorysubcode ,@i_DescType)

end

    
if @i_categorysub2code = 0 and  @i_categorysubcode = 0 and @i_categorycode>0
begin

	Select @return=dbo.rpt_get_gentables_field(@i_category_tableid,@i_categorycode ,@i_DescType)

end

return isnull(@return, '')


end



GO
grant all on rpt_get_minimum_project_category to public
