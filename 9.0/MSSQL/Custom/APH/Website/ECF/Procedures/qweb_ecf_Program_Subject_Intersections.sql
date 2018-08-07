
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Program_Subject_Intersections]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Program_Subject_Intersections]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<jhess>
-- Create date: <11/29/2009>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[qweb_ecf_Program_Subject_Intersections] (@i_ProgramID int, @i_SubjectID int ) as
	
DECLARE @v_CategoryId int,
		@v_CurObjectID int
			
BEGIN

select distinct objectid from categorization where categoryid in ( SELECT     CategoryId
FROM         Category
WHERE     (CategoryId = @i_ProgramID) OR
                      (ParentCategoryId = @i_ProgramID) )

INTERSECT

select distinct objectid from categorization where categoryid in ( SELECT     CategoryId
FROM         Category
WHERE     (CategoryId = @i_SubjectID) OR
                      (ParentCategoryId = @i_SubjectID) )

end

