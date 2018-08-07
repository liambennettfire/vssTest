SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BookcontributorSort]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[BookcontributorSort]
GO


create proc dbo.BookcontributorSort
AS

	DECLARE @v_bookkey		int
	DECLARE @v_printingkey		int
	DECLARE @v_contributorkey	int
	DECLARE @v_roletypecode		int
	DECLARE @v_sortorder		int
	DECLARE @i_bookkey		int
	DECLARE @i_contributorkey		int


BEGIN 

	DECLARE c_count INSENSITIVE CURSOR
	FOR

		SELECT bookkey, printingkey
		FROM bookcontributor  
		GROUP BY bookkey, printingkey
		HAVING count(*) > 1 
	FOR READ ONLY

	OPEN c_count 

	/* Loop through bookcontributor count rows to only process those titles with more than 1 bookcontributor 
	<< loop_outer >> */

		/* Get next bookkey that has more than one bookcontributor row */
		FETCH NEXT FROM c_count INTO @v_bookkey, @v_printingkey 
		
		select @i_bookkey  = @@FETCH_STATUS

		 while (@i_bookkey>-1 )
			begin
			IF (@i_bookkey<>-2)
				begin

		/* Initialize sortorder to 1 for each processed bookkey */
				select @v_sortorder = 1 

				DECLARE c_contributor INSENSITIVE CURSOR
				FOR
					SELECT contributorkey, roletypecode
						FROM bookcontributor
						WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

				FOR READ ONLY

		/* Open bookcontributor cursor for retrieval of all bookcontributor rows for the given bookkey */
				OPEN c_contributor
		
		/*<< loop_inner >>*/
		
			/* Fetch the contributorkey for each bookcontributor row for the currently processed bookkey */
				FETCH NEXT FROM c_contributor INTO @v_contributorkey, @v_roletypecode 
			
			select  @i_contributorkey  = @@FETCH_STATUS

			 while (@i_contributorkey >-1 )
			    begin
				IF (@i_contributorkey <>-2)
				   begin
					UPDATE bookcontributor
						SET sortorder = @v_sortorder
						WHERE bookkey = @v_bookkey AND
							printingkey = @v_printingkey AND
							contributorkey = @v_contributorkey AND
							roletypecode = @v_roletypecode 

					select @v_sortorder = @v_sortorder + 1 
				   end 

				FETCH NEXT FROM c_contributor
				INTO @v_contributorkey, @v_roletypecode 
	
				select @i_contributorkey  = @@FETCH_STATUS
			end /*contributor status status 1*/
			
			close c_contributor 
			deallocate c_contributor 
		end 	
 		FETCH NEXT FROM c_count
			INTO @v_bookkey, @v_printingkey 
	
	    	  select @i_bookkey  = @@FETCH_STATUS
	
	      end /*bookkey status status 1*/

  

close c_count
deallocate c_count

/* Execute the stored procedure to update the sortorder column */
end

/* after procedure compiles run the next two lines

exec BookcontributorSort
drop proc dbo.BookcontributorSort
*/


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

