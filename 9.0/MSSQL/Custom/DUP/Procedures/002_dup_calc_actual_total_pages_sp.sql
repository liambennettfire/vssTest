/****** Object:  StoredProcedure [dbo].[dup_calc_actual_total_pages_sp]    Script Date: 10/09/2008 13:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dup_calc_actual_total_pages_sp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dup_calc_actual_total_pages_sp]

/****** Object:  StoredProcedure [dbo].[dup_calc_actual_total_pages_sp]    Script Date: 10/09/2008 13:04:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[dup_calc_actual_total_pages_sp] 
(
@projectkey int, 
@mode	int,
@result int OUTPUT
)
as

--@mode values
--1	calculate total typeset pages
--2	calculate total typeset pages plus ad pages

DECLARE @i_totalpages int
DECLARE @i_start int
DECLARE @i_end int
DECLARE @i_frontmatter int
DECLARE @i_adpages int

Begin
	begin
		select @result=0
		exec dup_calc_issue_ms_start_end_sp @projectkey,'E',@result output
		select @i_end=@result
	end
	begin
		select @result=0
		exec dup_calc_issue_ms_start_end_sp @projectkey,'S',@result output
		select @i_start=@result
	end
	begin
		select @result=0
		exec dup_calc_frontmatter_total_pages_sp @projectkey,@result OUTPUT
		select @i_frontmatter=@result
	end
	

	select @i_totalpages=(@i_end - @i_start)+ @i_frontmatter 

	if @mode = 2 begin
		select @result=0
		exec dup_calc_ad_count_sp @projectkey,20009,2,99,@result OUTPUT
		select @i_adpages=@result
		select @i_totalpages = @i_totalpages + @i_adpages
	end

	select @result=@i_totalpages

end

grant execute on dup_calc_actual_total_pages_sp to public

