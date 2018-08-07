IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_web_feed_attr_vals_sort]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[aph_web_feed_attr_vals_sort]
/****** Object:  StoredProcedure [dbo].[aph_web_feed_attr_vals_sort]    Script Date: 07/29/2008 12:08:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[aph_web_feed_attr_vals_sort](@i_attributename	varchar(20)) AS

	DECLARE @v_parentpartnumber		varchar(30)
	DECLARE @v_bookkey		int
	DECLARE @v_valuekey		int
	DECLARE @v_sortorder		int
	DECLARE @i_bookkey		int
	DECLARE @i_valuekey		int

BEGIN 

	DECLARE c_count insensitive CURSOR
	FOR
		SELECT parentpartnumber
		FROM aph_web_feed_attributevalues  
		WHERE attributename = @i_attributename
			and bookkey = 0
			and attributevalue is not null
			and attributevalue <> ''
		GROUP BY parentpartnumber 
		HAVING count(*) > 1 
	FOR READ ONLY

	OPEN c_count 

	/* Loop through aph_web_feed_attributevalues count rows to only process those titles with more than 1 attribute value 
	<< loop_outer >>*/
	
		/* Get next parentpartnumber that has more than one aph_web_feed_attributevalues row for the specific attribute type*/
		FETCH NEXT FROM  c_count INTO @v_parentpartnumber
		
		select @i_bookkey  = @@FETCH_STATUS

		 while (@i_bookkey>-1 )
		  begin
			IF (@i_bookkey<>-2)
			  begin

		/* Initialize sortorder to 1 for each processed bookkey */
				select @v_sortorder = 1 

		/* Open aph_web_feed_attributevalues cursor for retrieval of all bookprice rows for the given bookkey */
		/*<< loop_inner >>*/
		
			DECLARE c_attribute insensitive CURSOR
			  FOR
				SELECT valuekey
					FROM aph_web_feed_attributevalues
					WHERE parentpartnumber = @v_parentpartnumber 
						and attributename = @i_attributename
						and bookkey = 0
						and attributevalue is not null
						and attributevalue <> ''
			FOR READ ONLY
			
			OPEN c_attribute
			/* Fetch the pricekey for each bookprice row for the currently processed bookkey */
			FETCH NEXT FROM c_attribute INTO @v_valuekey 
			
			select @i_valuekey  = @@FETCH_STATUS

			 while (@i_valuekey>-1 )
	  		   begin
				IF (@i_valuekey<>-2)
			        begin

					UPDATE aph_web_feed_attributevalues
						SET sequence = @v_sortorder
						WHERE valuekey = @v_valuekey 

					select @v_sortorder = @v_sortorder + 1 
				 end 
	
				FETCH NEXT FROM c_attribute
					INTO @v_valuekey
	
				select @i_valuekey  = @@FETCH_STATUS
			end /*value  status 1*/
			
			close c_attribute
			deallocate c_attribute
		end 	
 		FETCH NEXT FROM c_count
			INTO @v_parentpartnumber
	
	    	  select @i_bookkey  = @@FETCH_STATUS
	
	      end /*bookkey status status 1*/

close c_count
deallocate c_count

end


