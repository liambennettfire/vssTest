/****** Object:  StoredProcedure [dbo].[dup_calc_ad_count_sp]    Script Date: 10/09/2008 12:53:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dup_calc_ad_count_sp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dup_calc_ad_count_sp]


/****** Object:  StoredProcedure [dbo].[dup_calc_ad_count_sp]    Script Date: 10/09/2008 12:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[dup_calc_ad_count_sp] 
(
@projectkey int,
@elementtypecode int,
@elementtypesubcode int,
@adweight int, 
@result int OUTPUT
)
as

/* adweight tableid=525, datacode 72, subcode 2= full page, 1=half page, 3= 1/4 page, 0=all, 99=total ad page count*/
/*ad element =  20009, subelement=2*/

DECLARE @i_total_num_elements float
DECLARE @i_total_project_elements float
DECLARE @i_total_child_project_elements float


begin
	/*get any elements at the project level*/
	begin
			
		IF @adweight<>0 and @adweight <> 99
			select @i_total_project_elements= count(*) 
			from taqprojectelement te, taqelementmisc tem 
			where te.taqprojectkey=@projectkey
			and te.taqelementtypecode=@elementtypecode and te.taqelementkey=tem.taqelementkey 
			and te.taqelementtypesubcode=@elementtypesubcode
			and tem.misckey=455
			and tem.longvalue=@adweight
					
		ELSE if @adweight = 0
			select @i_total_project_elements= count(*) 
			from taqprojectelement 
			where taqprojectkey=@projectkey
			and taqelementtypecode=@elementtypecode and taqelementtypesubcode=@elementtypesubcode
		ELSE if @adweight = 99
			select @i_total_project_elements= isnull(sum(case when tem.longvalue = 1 then 0.5 else 0 end),0) 
											+ isnull(sum(case when tem.longvalue = 2 then 1 else 0 end),0)
											+ isnull(sum(case when tem.longvalue = 3 then 0.25 else 0 end),0)
			from taqprojectelement te, taqelementmisc tem 
			where te.taqprojectkey=@projectkey
			and te.taqelementtypecode=@elementtypecode and te.taqelementkey=tem.taqelementkey 
			and te.taqelementtypesubcode=@elementtypesubcode
			and tem.misckey=455
			and tem.longvalue in (1,2,3)

	end
	/*get any elements at the subproject level*/
	begin 

		IF @adweight<>0 and @adweight <> 99
			select @i_total_child_project_elements= count(*) 
			from taqprojectelement te, taqelementmisc tem 
			where te.taqprojectkey in (select taqprojectkey2 
										from taqprojectrelationship 
										where taqprojectkey1=@projectkey)
			and te.taqelementtypecode=@elementtypecode and te.taqelementkey=tem.taqelementkey 
			and te.taqelementtypesubcode=@elementtypesubcode
			and tem.misckey=455
			and tem.longvalue=@adweight

		ELSE if @adweight = 0
			select @i_total_child_project_elements= count(*) 
			from taqprojectelement 
			where taqprojectkey in (select taqprojectkey2 from taqprojectrelationship where taqprojectkey1=@projectkey)
			and taqelementtypecode=@elementtypecode and taqelementtypesubcode=@elementtypesubcode

		else if @adweight = 99
			select @i_total_child_project_elements= isnull(sum(case when tem.longvalue = 1 then 0.5 else 0 end),0) 
												+ isnull(sum(case when tem.longvalue = 2 then 1 else 0 end),0) 
												+ isnull(sum(case when tem.longvalue = 3 then 0.25 else 0 end),0)
			from taqprojectelement te, taqelementmisc tem 
			where te.taqprojectkey in (select taqprojectkey2 
										from taqprojectrelationship 
										where taqprojectkey1=@projectkey)
			and te.taqelementtypecode=@elementtypecode and te.taqelementkey=tem.taqelementkey 
			and te.taqelementtypesubcode=@elementtypesubcode
			and tem.misckey=455
			and tem.longvalue in (1, 2, 3)

	end

	select @i_total_num_elements = @i_total_project_elements + @i_total_child_project_elements

	if @adweight = 99
		select @result=ceiling(@i_total_num_elements )
	else
		select @result=@i_total_num_elements 

end



