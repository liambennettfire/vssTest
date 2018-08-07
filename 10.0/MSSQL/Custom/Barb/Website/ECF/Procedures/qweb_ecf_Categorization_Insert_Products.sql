IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_Products]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_Products]
go


CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_Products] (@i_bookkey int) as
	
DECLARE @i_categorycode int,
		@i_title_categoryid int,
		@i_journal_categoryid int,
		@productid int,
		@i_publishtowebind int,
		@i_workkey int,
		@i_mediatypecode int,
		@i_mediatypesubcode int,
		@i_categoryid int
		
		
BEGIN
			
			Select @i_publishtowebind = publishtowebind,
				   @i_mediatypecode = mediatypecode,
				   @i_mediatypesubcode = mediatypesubcode
			from barb..bookdetail 
			where bookkey = @i_bookkey


			

			Select @i_title_categoryid = dbo.qweb_ecf_get_Category_ID('Titles')
			Select @i_journal_categoryid = dbo.qweb_ecf_get_Category_ID('Journals Home')
			Select @productid = productid from product where code = cast(@i_bookkey as varchar)
			Select @i_workkey = workkey from barb..book where bookkey = @i_bookkey
			
			IF coalesce (@productid,0) =0
			return
			
				 

			If @i_mediatypecode = 6 and @i_mediatypesubcode = 1
			   begin
				Select @i_categoryid = @i_journal_categoryid
			   end
			Else 
				begin
				Select @i_categoryid = @i_title_categoryid
				end


			If not exists(Select * 
						  From categorization 
						  Where categoryid = @i_categoryid 
						    and objectid = @productid
							)
				
				/*and @i_publishtowebind = 1*/
				and @i_workkey = @i_bookkey



			begin
												
				exec CategorizationInsert
				@i_categoryid,          --@CategoryId int,
				@productid,				--@ObjectId int,
				1,						--@ObjectTypeId int,
				NULL					--@CategorizationId int = NULL output

			end

		
END





