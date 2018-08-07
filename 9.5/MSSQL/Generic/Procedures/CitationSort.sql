SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CitationSort]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CitationSort]
GO


create proc dbo.CitationSort
AS

	DECLARE @v_bookkey		int
	DECLARE @v_citationkey		int
	DECLARE @v_sortorder		int
	DECLARE @i_bookkey		int
	DECLARE @i_citationkey		int

BEGIN 

	DECLARE c_count INSENSITIVE CURSOR
	FOR

		SELECT bookkey
			FROM citation  
			GROUP BY bookkey 
			HAVING count(*) > 1 

	FOR READ ONLY
		
	/* Loop through citation count rows to only process those titles with more than 1 citation */
	/*<< loop_outer >>*/
	
	OPEN c_count

	/* Get next bookkey that has more than one citation row */	
	FETCH NEXT FROM c_count
		INTO @v_bookkey

	select @i_bookkey  = @@FETCH_STATUS

	 while (@i_bookkey>-1 )
		begin
		IF (@i_bookkey<>-2)
			begin

/* Initialize sortorder to 1 for each processed bookkey */
		select @v_sortorder = 1 

		DECLARE c_citation INSENSITIVE CURSOR
		 FOR
			SELECT citationkey
				FROM citation
					WHERE bookkey = @v_bookkey 

		  FOR READ ONLY
	
/* Open citation cursor for retrieval of all citation rows for the given bookkey */
/*	 << loop_inner >>*/

		OPEN c_citation

/* Fetch the citationkey for each citation row for the currently processed bookkey */

			FETCH NEXT FROM c_citation
				INTO @v_citationkey

			select  @i_citationkey  = @@FETCH_STATUS

			 while (@i_citationkey >-1 )
			    begin
				IF (@i_citationkey <>-2)
				   begin
				
				 	UPDATE citation
						SET sortorder = @v_sortorder
						WHERE bookkey = @v_bookkey AND
							citationkey = @v_citationkey 

					select @v_sortorder = @v_sortorder + 1 
				   end 

				FETCH NEXT FROM c_citation
					INTO @v_citationkey
	
				select @i_citationkey  = @@FETCH_STATUS
			end /*citation status status 1*/
			
			close c_citation
			deallocate c_citation
		end 	
 		FETCH NEXT FROM c_count
			INTO @v_bookkey
	
	    	  select @i_bookkey  = @@FETCH_STATUS
	
	      end /*bookkey status status 1*/

  

close c_count
deallocate c_count

/* Execute the stored procedure to update the sortorder column */
end

/* after procedure compiles run the next two lines

exec CitationSort
drop proc dbo.CitationSort
*/


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

