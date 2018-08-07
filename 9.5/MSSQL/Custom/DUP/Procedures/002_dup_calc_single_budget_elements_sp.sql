USE [DUP]
GO
/****** Object:  StoredProcedure [dbo].[dup_calc_single_budget_elements_sp]    Script Date: 03/16/2009 16:40:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[dup_calc_single_budget_elements_sp] 
(
@i_projectkey int,
@i_subelementtype int,
@result int OUTPUT
)
as

DECLARE @i_elementkey int
DECLARE @i_element_fetchstatus int
DECLARE @i_result float
DECLARE @i_budget_total float


select @i_budget_total=0

begin 
DECLARE c_budget_elements insensitive cursor for

select taqelementkey
from taqprojectelement
where taqprojectkey=@i_projectkey
and taqelementtypecode = 20017
and taqelementtypesubcode = @i_subelementtype

for read only

open c_budget_elements

fetch next from c_budget_elements
into @i_elementkey

select  @i_element_fetchstatus  = @@FETCH_STATUS

	 while (@i_element_fetchstatus >-1 )
		 begin
			IF (@i_element_fetchstatus <>-2)
			begin
			 exec dup_calc_budget_element_sp @i_elementkey, @i_result OUTPUT
			  --print @i_result
			 select @i_budget_total = coalesce(@i_result,0) + coalesce(@i_budget_total,0)
			  --print @i_budget_total 
		 
			end
		
	 FETCH NEXT FROM c_budget_elements	
		into @i_elementkey
		select @i_element_fetchstatus  = @@FETCH_STATUS
		 end
close c_budget_elements
deallocate c_budget_elements

select @result=@i_budget_total



end