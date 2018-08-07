if exists (select * from dbo.sysobjects where id = object_id(N'dbo.AssociatedTitleSort') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.AssociatedTitleSort
GO

CREATE proc dbo.AssociatedTitleSort
AS

	DECLARE @bookkey		int
	DECLARE @bookkey2		int
	DECLARE @associationtypecode		int
	DECLARE @sortorder int
	DECLARE @v_sortorder		int
	DECLARE @i_bookkey		int
	DECLARE @associationtypesubcode		int
	DECLARE @associatetitlebookkey		int
	DECLARE @associationtypecode2		int
	DECLARE @fetchstatus int
	DECLARE @fetchstatus2 int


BEGIN 

/*

Select bookkey, associationtypecode, associationtypesubcode, associatetitlebookkey,  sortorder, Count(*) 
FROM associatedtitles
GROUP BY bookkey, associationtypecode, associationtypesubcode, associatetitlebookkey,  sortorder
HAVING Count(*) > 1

Select bookkey, associationtypecode, associationtypesubcode,  sortorder, Count(*) 
FROM associatedtitles
GROUP BY bookkey, associationtypecode, associationtypesubcode,  sortorder
HAVING Count(*) > 1

Select bookkey, associationtypecode, associationtypesubcode, associatetitlebookkey,  Count(*) 
FROM associatedtitles
WHERE associationtypecode in (5,6,7)
and associatetitlebookkey <> 0
GROUP BY bookkey, associationtypecode, associationtypesubcode,  associatetitlebookkey
HAVING Count(*) > 1

572928	5	570959	2

Select * FROM associatedtitles_temp
where bookkey = 572928
and associationtypecode= 5
ORDER BY sortorder

ORDER By associatetitlebookkey




Select * FROM associatedtitles
WHERE associationtypesubcode <> 0
WHERE bookkey = 570766 and associationtypecode = 5

Select * FROM bookfamily


*/



DECLARE @bkey int
DECLARE @atypecode int
DECLARE @atypesubcode int
DECLARE @atitlebookkey int
DECLARE @counter int
DECLARE @fstatus int

DECLARE c_deletedups INSENSITIVE CURSOR
	FOR

		Select bookkey, associationtypecode, associationtypesubcode, associatetitlebookkey,  Count(*) 
		FROM associatedtitles
		WHERE associationtypecode in (1, 5,6,7, 9)
		and associatetitlebookkey <> 0
		GROUP BY bookkey, associationtypecode, associationtypesubcode,  associatetitlebookkey
		HAVING Count(*) > 1

	FOR READ ONLY
		
	/*<< loop_outer >>*/
	
	OPEN c_deletedups

	FETCH NEXT FROM c_deletedups
		INTO @bkey, @atypecode, @atypesubcode, @atitlebookkey, @counter

	select @fstatus  = @@FETCH_STATUS

	 while (@fstatus>-1 )
		begin
		IF (@fstatus<>-2)
			begin
				DECLARE @local_counter int
				SET @local_counter = @counter
				WHILE (@local_counter >1)
					BEGIN
						SET ROWCOUNT 1
						DECLARE @sort int
						SET @sort = 0
						
						Select TOP 1 @sort = sortorder FROM associatedtitles
						WHERE bookkey = @bkey and associationtypecode = @atypecode
						and associationtypesubcode =  @atypesubcode and associatetitlebookkey = @atitlebookkey
						ORDER BY sortorder DESC

						PRINT 'DELETING DUP NUMBER ' + Cast(@local_counter as varchar(10)) + ' for bookkey/associatetitlebookkey/sortorder: ' + Cast(@bkey as varchar(20)) + '/' + Cast(@atitlebookkey as varchar(20)) + '/' + Cast(@sort as varchar(20))  
						
						DELETE FROM associatedtitles
						WHERE bookkey = @bkey and associationtypecode = @atypecode
						and associationtypesubcode =  @atypesubcode and associatetitlebookkey = @atitlebookkey
						and sortorder = @sort

						SET @local_counter = @local_counter -1
						IF @local_counter = 1
							BREAK
						ELSE
							CONTINUE

					END
				
			end 	
 		FETCH NEXT FROM c_deletedups
		INTO @bkey, @atypecode, @atypesubcode, @atitlebookkey, @counter
	
	    	  select @fstatus  = @@FETCH_STATUS
	
	      end /*bookkey status status 1*/

  

close c_deletedups
deallocate c_deletedups

SET ROWCOUNT 0



	DECLARE c_count INSENSITIVE CURSOR
	FOR

		SELECT bookkey, associationtypecode
			FROM associatedtitles 
			WHERE associationtypecode in (1, 5,6,7, 9) --These are converted, might need to use associationtypesubcode for other associations
			GROUP BY bookkey, associationtypecode
--			HAVING count(*) > 1 

	FOR READ ONLY
		
	/*<< loop_outer >>*/
	
	OPEN c_count

	FETCH NEXT FROM c_count
		INTO @bookkey, @associationtypecode

	select @fetchstatus  = @@FETCH_STATUS

	 while (@fetchstatus>-1 )
		begin
		IF (@fetchstatus<>-2)
			begin

/* Initialize sortorder to 1 for each processed bookkey */
		select @v_sortorder = 1 

		DECLARE c_associatedtitles INSENSITIVE CURSOR
		 FOR
			SELECT bookkey, associationtypecode, associationtypesubcode, associatetitlebookkey, sortorder --, categorysubcode
				FROM associatedtitles
					WHERE bookkey = @bookkey 
					and associationtypecode = @associationtypecode
					ORDER BY sortorder


		  FOR READ ONLY
	
/* Open booksubjectcategory cursor for retrieval of all booksubjectcategory rows for the given bookkey and categorytablid */
/*	 << loop_inner >>*/

		OPEN c_associatedtitles


			FETCH NEXT FROM c_associatedtitles
				INTO @bookkey2, @associationtypecode2, @associationtypesubcode, @associatetitlebookkey, @sortorder --, @categorysubcode

			select  @fetchstatus2  = @@FETCH_STATUS

			 while (@fetchstatus2 >-1 )
			    begin
				IF (@fetchstatus2 <>-2)
				   begin
				
					PRINT Cast(@bookkey2 as varchar(20)) + '  ' +  Cast(@associationtypecode2 as varchar(20)) + '  ' + Cast(@associatetitlebookkey as varchar(20))
				 	UPDATE associatedtitles
						SET sortorder = @v_sortorder
						WHERE bookkey = @bookkey2 AND
							associationtypecode = @associationtypecode2 AND
							associationtypesubcode = @associationtypesubcode AND 
							associatetitlebookkey= @associatetitlebookkey AND
							sortorder = @sortorder
							--AND categorysubcode = @categorysubcode

					select @v_sortorder = @v_sortorder + 1 
				   end 

				FETCH NEXT FROM c_associatedtitles
				INTO @bookkey2, @associationtypecode2, @associationtypesubcode, @associatetitlebookkey, @sortorder --, @categorysubcode
	
				select @fetchstatus2  = @@FETCH_STATUS
			end 
			
			close c_associatedtitles
			deallocate c_associatedtitles
		end 	
 		FETCH NEXT FROM c_count
		INTO @bookkey, @associationtypecode
	
	    	  select @fetchstatus  = @@FETCH_STATUS
	
	      end /*bookkey status status 1*/

  

close c_count
deallocate c_count

/* Execute the stored procedure to update the sortorder column */
end

/* after procedure compiles run the next two lines

TRUNCATE TABLE associatedtitles_temp

SET ROWCOUNT 0

Select * into associatedtitles_temp FROM associatedtitles 

Select * into associatedtitles_old FROM associatedtitles 

DROP table associatedtitles_old

Insert into associatedtitles_temp
Select * FROM associatedtitles

Select * FROM associatedtitles_temp
where bookkey = 566182

Select * FROM associatedtitles
where bookkey = 566182

exec AssociatedTitleSort

drop proc dbo.AssociatedTitleSort


*/


