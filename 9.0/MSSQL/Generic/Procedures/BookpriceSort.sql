SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BookpriceSort]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[BookpriceSort]
GO


CREATE PROCEDURE BookpriceSort AS

	DECLARE @v_bookkey		int
	DECLARE @v_pricekey		int
	DECLARE @v_sortorder		int
	DECLARE @i_bookkey		int
	DECLARE @i_pricekey		int

BEGIN 

	DECLARE c_count INSENSITIVE CURSOR
	FOR
		SELECT bookkey
		FROM bookprice  
		GROUP BY bookkey 
		HAVING count(*) > 1 
	FOR READ ONLY

	OPEN c_count 

	/* Loop through bookprice count rows to only process those titles with more than 1 price 
	<< loop_outer >>*/
	
		/* Get next bookkey that has more than one bookprice row */
		FETCH NEXT FROM  c_count INTO @v_bookkey
		
		select @i_bookkey  = @@FETCH_STATUS

		 while (@i_bookkey>-1 )
		  begin
			IF (@i_bookkey<>-2)
			  begin

		/* Initialize sortorder to 1 for each processed bookkey */
				select @v_sortorder = 1 

		/* Open bookprice cursor for retrieval of all bookprice rows for the given bookkey */
		/*<< loop_inner >>*/
		
			DECLARE c_bookprice INSENSITIVE CURSOR
			  FOR
				SELECT pricekey
					FROM bookprice
					WHERE bookkey = @v_bookkey 
			FOR READ ONLY
			
			OPEN c_bookprice
			/* Fetch the pricekey for each bookprice row for the currently processed bookkey */
			FETCH NEXT FROM c_bookprice INTO @v_pricekey 
			
			select @i_pricekey  = @@FETCH_STATUS

			 while (@i_pricekey>-1 )
	  		   begin
				IF (@i_pricekey<>-2)
			        begin

					UPDATE bookprice
						SET sortorder = @v_sortorder
						WHERE pricekey = @v_pricekey 

					select @v_sortorder = @v_sortorder + 1 
				 end 
	
				FETCH NEXT FROM c_bookprice
					INTO @v_pricekey
	
				select @i_pricekey  = @@FETCH_STATUS
			end /*price status status 1*/
			
			close c_bookprice
			deallocate c_bookprice
		end 	
 		FETCH NEXT FROM c_count
			INTO @v_bookkey
	
	    	  select @i_bookkey  = @@FETCH_STATUS
	
	      end /*bookkey status status 1*/

close c_count
deallocate c_count

end

/* Execute the stored procedure to update the sortorder column */
/* after procedure compiles run the next two lines

exec BookpriceSort
drop proc dbo.BookpriceSort
*/

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

