SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FilelocationSort]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FilelocationSort]
GO


create proc dbo.FilelocationSort
AS

	DECLARE @v_bookkey		int
	DECLARE @v_printingkey		int
	DECLARE @v_filelocationkey	int
	DECLARE @v_filetypecode	 int
	DECLARE @v_sortorder		int
	DECLARE @i_bookkey 		int
	DECLARE @i_filetype	 int

BEGIN 

	DECLARE c_count INSENSITIVE CURSOR
	FOR

		SELECT bookkey, printingkey
		FROM filelocation  
		GROUP BY bookkey, printingkey
		HAVING count(*) > 1 

	FOR READ ONLY

	OPEN c_count

	/* Loop through filelocation count rows to only process those titles with more than 1 filelocation 
	<< loop_outer >>*/

		/* Get next bookkey that has more than one filelocation row */
		FETCH NEXT FROM c_count INTO @v_bookkey, @v_printingkey 
	
		select @i_bookkey  = @@FETCH_STATUS

		 while (@i_bookkey>-1 )
			begin
		IF (@i_bookkey<>-2)
			begin

		/* Initialize sortorder to 1 for each processed bookkey */
		select @v_sortorder = 1 

		DECLARE c_filelocation INSENSITIVE CURSOR
		FOR
			SELECT filelocationkey, filetypecode
				FROM filelocation
				WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
		FOR READ ONLY

		/* Open filelocation cursor for retrieval of all filelocation rows for the given bookkey */
		OPEN c_filelocation
		
		/*<< loop_inner >>
		LOOP*/
			/* Fetch the filelocationkey for each filelocation row for the currently processed bookkey */
			FETCH NEXT FROM c_filelocation INTO @v_filelocationkey, @v_filetypecode 
			
			select @i_filetype  = @@FETCH_STATUS

			 while (@i_filetype>-1 )
				begin
				IF (@i_filetype<>-2)
					begin

			
						UPDATE filelocation
							SET sortorder = @v_sortorder
								WHERE bookkey = @v_bookkey AND
									printingkey = @v_printingkey AND
									filelocationkey = @v_filelocationkey AND
									filetypecode = @v_filetypecode 

						select @v_sortorder = @v_sortorder + 1 

   					end 

				FETCH NEXT FROM c_filelocation
					INTO @v_filelocationkey, @v_filetypecode 
	
				select @i_filetype = @@FETCH_STATUS
			end /*filelocation status status 1*/
			
			close c_filelocation
			deallocate c_filelocation
		
		end 	
 		FETCH NEXT FROM c_count
			INTO @v_bookkey, @v_printingkey
	
	    	  select @i_bookkey  = @@FETCH_STATUS
	
	      end /*bookkey status status 1*/

close c_count
deallocate c_count

END 

/* after procedure compiles run the next two lines

exec FilelocationSort 
drop proc dbo.FilelocationSort
*/


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

