IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_Authors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_Authors]
go

CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_Authors] (@i_bookkey int) as
	
DECLARE @i_categorycode int,
		@productid int,
		@v_contactkey int,
		@i_categoryid int,
		@v_fetchstatus int
			
BEGIN
  DECLARE c_pss_authors CURSOR fast_forward FOR
	  Select authorkey
  	  from barb..bookauthor b, barb..bookdetail bd
	   where b.bookkey = bd.bookkey
	 	   and b.bookkey = @i_bookkey
	 	   and bd.publishtowebind=1
				
	OPEN c_pss_authors
	
	FETCH NEXT FROM c_pss_authors
		INTO @v_contactkey

	select  @v_fetchstatus  = @@FETCH_STATUS

	while (@v_fetchstatus >-1) begin
	  IF (@v_fetchstatus <>-2) begin

		  Select @i_categoryid = dbo.qweb_ecf_get_Category_ID('Authors')
		  Select @productid = productid from product where code = cast(@v_contactkey as varchar)

		  If not exists(Select * 
					    From categorization 
					    Where categoryid = @i_categoryid
					      and objectid = @productid)
		  begin
			  exec CategorizationInsert
			  @i_categoryid,          --@CategoryId int,
			  @productid,				--@ObjectId int,
			  1,						--@ObjectTypeId int,
			  NULL					--@CategorizationId int = NULL output
		  end

	    FETCH NEXT FROM c_pss_authors
		    INTO @v_contactkey

	    select  @v_fetchstatus  = @@FETCH_STATUS
    end
  end
    	
  close c_pss_authors
  deallocate c_pss_authors  		
END




