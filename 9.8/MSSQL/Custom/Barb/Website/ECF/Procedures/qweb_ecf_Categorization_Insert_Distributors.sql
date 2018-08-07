IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_Distributors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_Distributors]
go

Create procedure [dbo].[qweb_ecf_Categorization_Insert_Distributors] (@i_bookkey int) as

DECLARE @i_c_bookkey int,
		@catalog_object_id int,
		@i_titlefetchstatus int,
		@productid int,
		@d_datetime datetime

BEGIN

	DECLARE c_pss_distributor CURSOR fast_forward FOR

	Select bookkey
	from barb..bookorgentry o
	where orglevelkey = 3
	  and orgentrykey = 9 
		and bookkey in (Select bookkey from barb..bookdetail where publishtowebind = 1)
		and bookkey = @i_bookkey
		and exists (Select * from product where code = cast(@i_bookkey as varchar))
			
	OPEN c_pss_distributor

	FETCH NEXT FROM c_pss_distributor
		INTO @i_c_bookkey

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

			Select @productid = productid from product where code = cast(@i_c_bookkey as varchar)
			Select @catalog_object_id = objectid 
			  from CategoryEx_Title_Distributors 
			 where PSS_OrgLevelKey = 3 and PSS_Orgentrykey = 9
		
			If not exists (Select * from categorization
							where categoryid = 	@catalog_object_id
							 and objectid = @productid)
			begin

			exec CategorizationInsert

			@catalog_object_id,       --@CategoryId int,
			@productid,				--@ObjectId int,
			1,						--@ObjectTypeId int,
			NULL					--@CategorizationId int = NULL output
			
			end          
		end
		
	FETCH NEXT FROM c_pss_distributor
		INTO @i_c_bookkey
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_distributor
deallocate c_pss_distributor


END



