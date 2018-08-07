if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Categorization_Insert_Products]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Categorization_Insert_Products]
GO


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


Create procedure [dbo].[qweb_ecf_Categorization_Insert_Products] (@i_bookkey int) as
	
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
			from UNL..bookdetail 
			where bookkey = @i_bookkey


			

			Select @i_title_categoryid = dbo.qweb_ecf_get_Category_ID('Titles')
			Select @i_journal_categoryid = dbo.qweb_ecf_get_Category_ID('Journals Home')
			Select @productid = productid from product where code = cast(@i_bookkey as varchar)
			Select @i_workkey = workkey from UNL..book where bookkey = @i_bookkey


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
						    and objectid = @productid)
				
				and @i_publishtowebind = 1
				and @i_workkey = @i_bookkey



			begin
												
				exec CategorizationInsert
				@i_categoryid,          --@CategoryId int,
				@productid,				--@ObjectId int,
				1,						--@ObjectTypeId int,
				NULL					--@CategorizationId int = NULL output

			end

		
END


