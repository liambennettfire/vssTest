USE [BT_SD_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Contibutor_Role]    Script Date: 01/27/2010 16:20:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[qweb_ecf_Categorization_Insert_Contibutor_Role] as

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
	from BT..bookauthor
	where bookkey in (Select bookkey from BT..bookdetail where publishtowebind =1)

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







