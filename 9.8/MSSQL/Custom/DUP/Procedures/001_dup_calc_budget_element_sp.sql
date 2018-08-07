/****** Object:  StoredProcedure [dbo].[dup_calc_budget_element_sp]    Script Date: 03/16/2009 13:58:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'dup_calc_budget_element_sp')
  BEGIN
    DROP PROCEDURE dup_calc_budget_element_sp
  END
GO

CREATE procedure [dbo].[dup_calc_budget_element_sp] 
(
@elementkey int,
@result int OUTPUT
)
as

DECLARE @i_totalestwords decimal (9,2) 
DECLARE @i_totalestpages decimal (9,2) 
DECLARE @i_totalwordsperhour int
DECLARE @i_standardhours int
DECLARE @i_invoicetype int
DECLARE @i_freelancerrate_translator int
DECLARE @i_freelancerrate_copy int
DECLARE @i_freelancerrate_index int
DECLARE @i_freelancerrate_proof int
DECLARE @i_freelancerrate_pm int
DECLARE @i_budgettotal  decimal (9,2) 

DECLARE @i_pagesperhour int
DECLARE @i_mselementkey int
DECLARE @i_budgetrole varchar (80)
DECLARE @i_globalcontact int

DECLARE @i_budgetnugget decimal (9,2)
DECLARE @i_projectkey	int
DECLARE @v_abstract_pages_to_proof int


begin

	select @i_mselementkey = taqelementkey from taqprojectelement where taqprojectkey = (select taqprojectkey from taqprojectelement
	where taqelementkey=@elementkey) and taqelementtypecode=20027 /*ms*/

	select @i_invoicetype = taqelementtypesubcode from taqprojectelement where taqelementtypecode = 20017 and taqelementkey=@elementkey
	select @i_projectkey = taqprojectkey from taqprojectelement where taqelementkey=@elementkey

--print 'invoicetype'
--print @i_invoicetype

	select @i_totalwordsperhour = coalesce (longvalue,0) 
	from taqprojectmisc 
	where taqprojectkey=@i_projectkey 
	and misckey = case when @i_invoicetype = 3 then 160
						when @i_invoicetype = 4 then 527
						when @i_invoicetype = 1 then 522
						else 0
					end

--print 'i_totalwordsperhour'
--print @i_totalwordsperhour

	select @i_pagesperhour = coalesce (longvalue,0) 
	from taqprojectmisc 
	where taqprojectkey=@i_projectkey 
	and misckey = case when @i_invoicetype = 11 then 529
						when @i_invoicetype = 5 then 156
						else 0
					end

--print '@i_pagesperhour'
--print @i_pagesperhour

	select @i_standardhours = coalesce (longvalue,0) 
	from taqprojectmisc 
	where taqprojectkey=@i_projectkey 
	and misckey = case when @i_invoicetype = 3 then 157
						when @i_invoicetype = 4 then 528
						when @i_invoicetype = 11 then 530
						when @i_invoicetype = 10 then 532
						when @i_invoicetype = 5 then 95
						when @i_invoicetype = 2 then 531
						when @i_invoicetype = 1 then 523
						else 0
					end
--print '@i_standardhours'
--print @i_standardhours

	select @i_totalestwords = coalesce (longvalue,0) from taqelementmisc where misckey=214 and taqelementkey = @i_mselementkey
	select @i_budgetrole = rolecode1 from taqprojectelement where taqelementkey=@elementkey
	select @i_globalcontact = globalcontactkey from taqprojectelement where taqelementkey=@elementkey
	exec dbo.dup_calc_element_misc_total_pages_sp @i_mselementkey,@i_totalestpages OUTPUT
	
--print '@i_totalestwords'
--print @i_totalestwords
--print '@i_totalestpages'
--print @i_totalestpages

 /*rate types
per hour=1
per page=2 */

/*need translator scale?*/ 
	IF @i_invoicetype =1 /*translator*/
		begin
			select @i_freelancerrate_translator = workrate 
			from taqprojectelement te, taqprojectcontactrole tc, taqprojectcontact tp
			where tp.globalcontactkey = @i_globalcontact
			and tp.taqprojectcontactkey=tc.taqprojectcontactkey
			and te.taqprojectkey=tc.taqprojectkey
			and te.taqelementkey=@elementkey
			and ratetypecode=1
			and tc.rolecode =@i_budgetrole

			 if @i_totalwordsperhour<>0 and @i_totalestwords <> 0
				 select @i_budgettotal = ((@i_totalestwords/@i_totalwordsperhour) + @i_standardhours)*@i_freelancerrate_translator
			 select @result=@i_budgettotal
--print @i_freelancerrate_translator
--print @result
			 if @i_budgettotal >0
					return
		end

	IF @i_invoicetype =3 /*copyedit*/
		begin
			select @i_freelancerrate_copy = workrate 
			from taqprojectelement te, taqprojectcontactrole tc, taqprojectcontact tp
			where tp.globalcontactkey = @i_globalcontact
			and tp.taqprojectcontactkey=tc.taqprojectcontactkey
			and te.taqprojectkey=tc.taqprojectkey
			and te.taqelementkey=@elementkey
			and ratetypecode=1
			and tc.rolecode =@i_budgetrole

			 if @i_totalwordsperhour<>0 and @i_totalestwords <> 0
				select @i_budgettotal = ROUND(((@i_totalestwords/@i_totalwordsperhour) + @i_standardhours), 0)*@i_freelancerrate_copy 
			 select @result=@i_budgettotal
--print @i_freelancerrate_copy
--print @result
			 if @i_budgettotal >0
					return
		end

	IF @i_invoicetype =4 /*editproofer ms */
		begin
			select @i_freelancerrate_proof = workrate from taqprojectelement te, taqprojectcontactrole tc,taqprojectcontact tp
			where tp.globalcontactkey = @i_globalcontact
			and tp.taqprojectcontactkey=tc.taqprojectcontactkey
			and te.taqprojectkey=tc.taqprojectkey
			and te.taqelementkey=@elementkey
			and ratetypecode=1
			and tc.rolecode =@i_budgetrole

			 if @i_totalwordsperhour<>0 and @i_totalestwords <> 0
				 select @i_budgettotal = ((@i_totalestwords/@i_totalwordsperhour) + @i_standardhours)*@i_freelancerrate_proof
			 select @result=@i_budgettotal 
--print @i_freelancerrate_proof
--print @result
			 if @i_budgettotal >0
					return
		end

--	IF @i_invoicetype =11 /*editproofer 1pp */
--		begin
--			select @i_freelancerrate_proof = workrate from taqprojectelement te, taqprojectcontactrole tc,taqprojectcontact tp
--			where tp.globalcontactkey = @i_globalcontact
--			and tp.taqprojectcontactkey=tc.taqprojectcontactkey
--			and te.taqprojectkey=tc.taqprojectkey
--			and te.taqelementkey=@elementkey
--			and ratetypecode=1
--			and tc.rolecode =@i_budgetrole
--		end	
--
--		begin
--		 if @i_totalwordsperhour<>0
--		 select @i_budgettotal = ((@i_totalestwords/@i_totalwordsperhour) + @i_standardhours)*@i_freelancerrate_proof
--		 select @result=@i_budgettotal 
--		 if @i_budgettotal >0
--				return
--		end

/*begin other role types*/
	IF @i_invoicetype =10 /*project manager*/
		begin
			select @i_freelancerrate_pm = workrate from taqprojectelement te, taqprojectcontactrole tc, taqprojectcontact tp
			where tp.globalcontactkey = @i_globalcontact
			and tp.taqprojectcontactkey=tc.taqprojectcontactkey
			and te.taqprojectkey=tc.taqprojectkey
			and te.taqelementkey=@elementkey
			and ratetypecode=1
			and tc.rolecode = @i_budgetrole		

			 select @i_budgettotal = @i_standardhours*@i_freelancerrate_pm
			 select @result=@i_budgettotal
--print @i_freelancerrate_pm
--print @result
		 
			 if @i_budgettotal >0
					return 
		end	

	IF @i_invoicetype =2 /*indexer=2*/
		begin
			select @i_freelancerrate_index = workrate from taqprojectelement te, taqprojectcontactrole tc, taqprojectcontact tp
			where tp.globalcontactkey = @i_globalcontact
			and tp.taqprojectcontactkey=tc.taqprojectcontactkey
			and te.taqprojectkey=tc.taqprojectkey
			and te.taqelementkey=@elementkey
			and ratetypecode=2
			and tc.rolecode = @i_budgetrole		

			if @i_totalestpages <> 0
				 select @i_budgettotal = (@i_totalestpages)*@i_freelancerrate_index
			select @result=@i_budgettotal
--print 'index rate'
--print @i_freelancerrate_index
--print 'result'
--print @result
		 
			 if @i_budgettotal >0
					return 
		end	
	IF @i_invoicetype =5 /*proofer*/
		begin
			select @i_freelancerrate_proof = workrate from taqprojectelement te, taqprojectcontactrole tc ,taqprojectcontact tp
			where tp.globalcontactkey = @i_globalcontact
			and tp.taqprojectcontactkey=tc.taqprojectcontactkey
			and te.taqprojectkey=tc.taqprojectkey
			and te.taqelementkey=@elementkey
			and ratetypecode=1
			and tc.rolecode =@i_budgetrole
--			print @i_freelancerrate_proof
--			print @i_totalestpages
--			print @i_pagesperhour
--			print @i_standardhours

			if @i_pagesperhour<>0 and @i_totalestpages <> 0 begin
			  -- case #15333 - add abstract pages to proof to total typeset pages calculation
      	 select @v_abstract_pages_to_proof = coalesce (longvalue,0) from taqelementmisc where misckey=184 and taqelementkey = @i_mselementkey
      	 if @v_abstract_pages_to_proof is null begin
      	   set @v_abstract_pages_to_proof = 0
      	 end
   			 print '@v_abstract_pages_to_proof: ' + cast(@v_abstract_pages_to_proof as varchar)
					
				 select @i_budgetnugget = ROUND((@i_totalestpages + @v_abstract_pages_to_proof)/@i_pagesperhour, 0)
				 select @i_budgettotal = (@i_budgetnugget + @i_standardhours) * @i_freelancerrate_proof 
			end
			select @result=@i_budgettotal
--print @i_freelancerrate_proof
--print @result
		
			 if @i_budgettotal >0
					return	
		end	

	IF @i_invoicetype =11 /*editproofer 1pp*/
		begin
			select @i_freelancerrate_proof = workrate from taqprojectelement te, taqprojectcontactrole tc ,taqprojectcontact tp
			where tp.globalcontactkey = @i_globalcontact
			and tp.taqprojectcontactkey=tc.taqprojectcontactkey
			and te.taqprojectkey=tc.taqprojectkey
			and te.taqelementkey=@elementkey
			and ratetypecode=1
			and tc.rolecode =@i_budgetrole
--			print @i_freelancerrate_proof
--			print @i_totalestpages
--			print @i_pagesperhour
--			print @i_standardhours

			if @i_pagesperhour<>0 and @i_totalestpages <> 0 begin
				 select @i_budgetnugget = ROUND(@i_totalestpages/@i_pagesperhour, 0)
				 select @i_budgettotal = (@i_budgetnugget + @i_standardhours) * @i_freelancerrate_proof 
			end
			select @result=@i_budgettotal
--print @i_freelancerrate_proof
--print @result
		
			 if @i_budgettotal >0
					return	
		end	


		
end




