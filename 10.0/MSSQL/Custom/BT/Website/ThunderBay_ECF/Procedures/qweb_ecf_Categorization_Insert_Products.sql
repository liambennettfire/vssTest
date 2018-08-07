USE [BT_TB_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Products]    Script Date: 01/27/2010 16:47:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER procedure [dbo].[qweb_ecf_Categorization_Insert_Products] (@i_bookkey int) as
	
DECLARE @i_categorycode int,
		@i_title_categoryid int,
		@i_journal_categoryid int,
		@i_All_Subject_CategoryID int,
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
			from BT..bookdetail 
			where bookkey = @i_bookkey


			

			Select @i_title_categoryid = dbo.qweb_ecf_get_Category_ID('Titles')
			Select @i_journal_categoryid = dbo.qweb_ecf_get_Category_ID('Journals Home')
			Select @i_All_Subject_CategoryID = dbo.qweb_ecf_get_Category_ID('All')
			Select @productid = productid from product where code = cast(@i_bookkey as varchar)
			Select @i_workkey = workkey from BT..book where bookkey = @i_bookkey
			
			IF coalesce (@productid,0) = 0
			return
			

			If @i_mediatypecode = 6 and @i_mediatypesubcode = 1
			   begin
				Select @i_categoryid = @i_journal_categoryid
			   end
			Else 
				begin
				Select @i_categoryid = @i_title_categoryid
				end

print @i_categoryid
print @productid


			If not exists(Select * 
						  From categorization 
						  Where categoryid = @i_categoryid 
						    and objectid = @productid
							)
				
				/*and @i_publishtowebind = 1*/
				--and @i_workkey = @i_bookkey
			


			begin
				print 'inside 	CategorizationInsert of 	[qweb_ecf_Categorization_Insert_Products]'					
				exec CategorizationInsert
				@i_categoryid,          --@CategoryId int,
				@productid,				--@ObjectId int,
				1,						--@ObjectTypeId int,
				NULL					--@CategorizationId int = NULL output

			end

			IF  @i_All_Subject_CategoryID > 0
				begin

				If not exists(Select * 
							  From categorization 
							  Where categoryid = @i_All_Subject_CategoryID 
								and objectid = @productid
								)
					Begin
							print 'inserting product to "All" Subject Category'					
							exec CategorizationInsert
							@i_All_Subject_CategoryID,   --@CategoryId int,
							@productid,					--@ObjectId int,
							1,							--@ObjectTypeId int,
							NULL						--@CategorizationId int = NULL output
					End
				End

		
END







