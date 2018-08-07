IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_GetProgramForSubProgram]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_GetProgramForSubProgram]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<jhess>
-- Create date: <11/29/2009>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[qweb_ecf_GetProgramForSubProgram] (@i_ProgramID int ) as
	
DECLARE @v_CategoryId int,
		@v_CurObjectID int,
		@v_ParentCategoryID int
			
BEGIN

	select @v_ParentCategoryID = ParentCategoryId FROM  Category WHERE (CategoryId = @i_ProgramID)

	if ( @v_ParentCategoryID > 5524 )
		begin
			
			SELECT      [Name]
			FROM         Category
			WHERE     (CategoryId = @v_ParentCategoryID)

		end


end

go

grant execute on [qweb_ecf_GetProgramForSubProgram] to public
go