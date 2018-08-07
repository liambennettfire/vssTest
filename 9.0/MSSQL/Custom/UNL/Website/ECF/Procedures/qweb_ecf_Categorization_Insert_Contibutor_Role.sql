if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Categorization_Insert_Contibutor_Role]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Categorization_Insert_Contibutor_Role]

go

CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_Contibutor_Role] as

DECLARE @i_bookkey int,
		@i_globalcontactkey int,
        @i_authortypecode int,
		@contributor_object_id int,
		@role_categoryid int,
		@i_titlefetchstatus int,
		@title_productid int,
		@productid int,
		@d_datetime datetime

BEGIN

	DECLARE c_pss_titles INSENSITIVE CURSOR
	FOR

	Select bookkey, authorkey, authortypecode
	from UNL..bookauthor
	where bookkey in (Select bookkey from UNL..bookdetail where publishtowebind =1)

	FOR READ ONLY
			
	OPEN c_pss_titles

	FETCH NEXT FROM c_pss_titles
		INTO @i_bookkey, @i_globalcontactkey, @i_authortypecode

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

			Select @productid = productid from product where code = @i_bookkey
			Select @contributor_object_id = objectid from CategoryEx_Contributor where pss_globalcontactkey = @i_globalcontactkey
			Select @role_categoryid = categoryid from category where parentCategoryid = @contributor_object_id
						
			exec CategorizationInsert

			@role_categoryid,       --@CategoryId int,
			@productid,				--@ObjectId int,
			1,						--@ObjectTypeId int,
			NULL					--@CategorizationId int = NULL output
                 
			end

		

	FETCH NEXT FROM c_pss_titles
		INTO @i_bookkey, @i_globalcontactkey, @i_authortypecode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_titles
deallocate c_pss_titles

END

GO
Grant execute on dbo.qweb_ecf_Categorization_Insert_Contibutor_Role to Public
GO
