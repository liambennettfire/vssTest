if exists (select * from dbo.sysobjects where id = object_id(N'dbo.BookSubjectCategorySort') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.BookSubjectCategorySort
GO

CREATE proc [dbo].[BookSubjectCategorySort]
AS

	DECLARE @bookkey		int
	DECLARE @bookkey2		int
	DECLARE @categorytableid		int
	DECLARE @v_sortorder		int
	DECLARE @i_bookkey		int
	DECLARE @subjectkey		int
	DECLARE @categorycode		int
	DECLARE @categorysubcode		int
	DECLARE @categorytableid2		int
	DECLARE @fetchstatus int
	DECLARE @fetchstatus2 int


BEGIN 

	DECLARE c_count INSENSITIVE CURSOR
	FOR

		SELECT bookkey, categorytableid
			FROM booksubjectcategory  
			GROUP BY bookkey, categorytableid
--			HAVING count(*) > 1 

	FOR READ ONLY
		
	/*<< loop_outer >>*/
	
	OPEN c_count

	FETCH NEXT FROM c_count
		INTO @bookkey, @categorytableid

	select @fetchstatus  = @@FETCH_STATUS

	 while (@fetchstatus>-1 )
		begin
		IF (@fetchstatus<>-2)
			begin

/* Initialize sortorder to 1 for each processed bookkey */
		select @v_sortorder = 1 

		DECLARE c_booksubjectcategory INSENSITIVE CURSOR
		 FOR
			SELECT bookkey, subjectkey, categorytableid, categorycode --, categorysubcode
				FROM booksubjectcategory
					WHERE bookkey = @bookkey 
					and categorytableid = @categorytableid
					ORDER BY bookkey, categorytableid, sortorder

		  FOR READ ONLY
	
/* Open booksubjectcategory cursor for retrieval of all booksubjectcategory rows for the given bookkey and categorytablid */
/*	 << loop_inner >>*/

		OPEN c_booksubjectcategory


			FETCH NEXT FROM c_booksubjectcategory
				INTO @bookkey2, @subjectkey, @categorytableid2, @categorycode --, @categorysubcode

			select  @fetchstatus2  = @@FETCH_STATUS

			 while (@fetchstatus2 >-1 )
			    begin
				IF (@fetchstatus2 <>-2)
				   begin
				
				 	UPDATE booksubjectcategory
						SET sortorder = @v_sortorder
						WHERE bookkey = @bookkey2 AND
							subjectkey = @subjectkey AND
							categorytableid = @categorytableid2 AND 
							categorycode= @categorycode 
							--AND categorysubcode = @categorysubcode

					select @v_sortorder = @v_sortorder + 1 
				   end 

				FETCH NEXT FROM c_booksubjectcategory
				INTO @bookkey2, @subjectkey, @categorytableid2, @categorycode --, @categorysubcode
	
				select @fetchstatus2  = @@FETCH_STATUS
			end 
			
			close c_booksubjectcategory
			deallocate c_booksubjectcategory
		end 	
 		FETCH NEXT FROM c_count
		INTO @bookkey, @categorytableid
	
	    	  select @fetchstatus  = @@FETCH_STATUS
	
	      end /*bookkey status status 1*/

  

close c_count
deallocate c_count

/* Execute the stored procedure to update the sortorder column */
end

/* after procedure compiles run the next two lines

TRUNCATE TABLE BookSubjectCategory

Insert into BookSubjectCategory_temp
Select * FROM BookSubjectCategory

Select * FROM BookSubjectCategory_temp
WHERE bookkey = 566330
WHERE sortorder > 100

exec BookSubjectCategorySort

drop proc dbo.BookSubjectCategorySort


*/


