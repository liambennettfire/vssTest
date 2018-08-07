IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_set_active_prices]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qtitle_set_active_prices]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[qtitle_set_active_prices]
AS

BEGIN
	DECLARE @v_count	INT
	DECLARE @v_count2	INT
	DECLARE @v_optionvalue	INT
	DECLARE	@v_qsibatchkey	int
	DECLARE @v_qsijobkey	int
	DECLARE @o_error_code	int
    DECLARE @v_error_code		int
	DECLARE @v_datacode		int
	DECLARE @o_error_desc	varchar(300)
    DECLARE @v_error_desc	varchar(300)
	DECLARE	@v_userid	varchar(30)
	DECLARE @v_currentdate	datetime
	DECLARE	@minbookkey	INT
	DECLARE @numrows	INT
	DECLARE @counter	INT
	DECLARE @v_pricetypecode	INT
	DECLARE @v_pricetypedesc varchar(40)
	DECLARE @v_historyorder	INT
	DECLARE @v_error	INT
	DECLARE @error_var	INT
	DECLARE @rowcount_var	INT
    DECLARE @v_pricekey		INT
    DECLARE @v_bookkey	INT
	
	set @v_qsibatchkey = null
	set @v_qsijobkey = null
	SET @o_error_code = 0
	SET @o_error_desc = ''
    SET @v_error_code = 0
	SET @v_error_desc = ''
	SET @v_userid = 'Auto Set Active Procedure'
	SET @v_count = 0
	SET @v_count2 = 0
	
	SELECT @v_count = count(*)
	  FROM clientoptions
	 WHERE optionid = 99

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to determine value of clientoption 99 (Auto Set Price Active Ind)' 
      return
    END 

    IF @v_count = 0 BEGIN
	  SET @o_error_code = -1
      SET @o_error_desc = 'Unable to determine value of clientoption 99 (Auto Set Price Active Ind)' 
      return
    END 
    ELSE
    BEGIN
		SELECT @v_optionvalue = optionvalue
		  FROM clientoptions
	     WHERE optionid = 99
			
		IF @v_optionvalue = 0 BEGIN
		  SET @o_error_code = 1
		  SET @o_error_desc = 'Value of clientoption 99 (Auto Set Price Active Ind)is set to 0' 
		  return
		END
    END
    
    ---Auto Set Active Procedure
	SELECT @v_datacode = datacode
	  FROM gentables 
	 WHERE tableid = 543
	   AND qsicode = 1
--print '@v_datacode'
--print @v_datacode	  

	---TMM to CIS Pub
	select @v_count = count(*)
		from qsijob q
	 where jobtypecode = @v_datacode
		  and statuscode = 1

--print '@v_count'
--print @v_count


	IF @v_count > 0 
	BEGIN
		SELECT @v_datacode = datacode
		  FROM gentables 
		WHERE tableid = 543
		  AND qsicode = 1
   
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Set Active Book Prices','Set Active Book Prices','Auto Set Active Procedure',0,0,0,1,'job started','started',@o_error_code output, @o_error_desc output
		---print '@v_qsijobkey'
		---print @v_qsijobkey
		IF @o_error_code = 1
		 BEGIN
			SET @o_error_code = 0
		 END
		SET @o_error_code = -1
		SET @o_error_desc = 'There is a qsijob record indicating this job is running. Job will not run again until previous job completes or qsijob record is cleaned up. (qsicode = 1, statuscode = 3)'
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Set Active Book Prices','Set Active Book Prices','Auto Set Active Procedure',0,0,0,5,@o_error_desc,'error',@o_error_code output, @o_error_desc output
		RETURN
	END 
	
	exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Set Active Book Prices','Set Active Book Prices','Auto Set Active Procedure',0,0,0,1,'job started','started',@o_error_code output, @o_error_desc output 
	IF @o_error_code = 1
	BEGIN
		SET @o_error_code = 0
	END
	--print '@v_qsibatchkey'
	--print @v_qsibatchkey
	--print '@v_qsijobkey'
	--print @v_qsijobkey
	
	SELECT @v_currentdate = DATEADD(day, DATEDIFF(day, 0, getdate()), 0) 
	
	create table #tmp_bookkey (bookkey int not null)

	insert into #tmp_bookkey
	select distinct bp.bookkey
	  from bookprice bp, isbn i
	 where (effectivedate <= @v_currentdate  OR effectivedate is null) 
	   and (expirationdate >= @v_currentdate OR expirationdate is NULL) 
	   and i.ean13 is not null 
	   and i.bookkey = bp.bookkey
       and bp.activeind = 0
      order by bp.bookkey asc
       
	select @minbookkey = min(bookkey), @numrows = count(distinct bookkey)
	from #tmp_bookkey

--print '@numrows'
--print @numrows

	IF @numrows is null or @numrows = 0
	 begin
 		SET @o_error_desc = 'There are no changes to process.'
		exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Set Active Book Prices','Set Active Book Prices','Auto Set Active Procedure',0,0,0,6,'job completed - There are no changes to process','completed',@o_error_code output, @o_error_desc output 
		RETURN
	end
	 	
	set @counter = 1

	while @counter <= @numrows
	begin
        DECLARE cur_related_bookprice_rows CURSOR FOR
			SELECT pricetypecode,history_order,pricekey
			  FROM bookprice
			 WHERE bookkey = @minbookkey
			   AND (effectivedate <= @v_currentdate  OR effectivedate is null) 
			   AND (expirationdate >= @v_currentdate OR expirationdate is NULL)
		 
		OPEN cur_related_bookprice_rows
					
		FETCH NEXT FROM cur_related_bookprice_rows INTO @v_pricetypecode,@v_historyorder,@v_pricekey
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN

--print '@minbookkey'
--print @minbookkey
--print '@v_pricekey 1'
--print @v_pricekey

			UPDATE bookprice
			   SET activeind = 1,
				   lastuserid = 'Auto Set Active Procedure',
				   lastmaintdate = @v_currentdate
			  WHERE bookkey = @minbookkey
				AND pricekey = @v_pricekey
		  
			SET @v_error = @@ERROR
			
			IF @v_error <> 0 BEGIN
				set @o_error_code = -1
				set @o_error_desc = 'Error updating bookprice table for Auto Set Active procedure. Error #' + cast(@v_error as varchar(20)) 
 				exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Set Active Book Prices','Set Active Book Prices','QSIADMIN',@minbookkey,0,0,0,5,@o_error_desc,null,@o_error_code output, @o_error_desc output 
			END
		
			IF @v_error = 0 BEGIN 
				---EXEC get_gentables_desc	306,@v_pricetypecode,'short',@v_pricetypedesc OUTPUT
				 SELECT @v_pricetypedesc = dbo.get_gentables_desc(306,@v_pricetypecode,'short')
--print '@v_pricetypedesc'
--print @v_pricetypedesc
							

				SET @v_error_code = 0
				SET @v_error_desc = ''
			
				EXEC dbo.qtitle_update_titlehistory 'bookprice', 'activeind', @minbookkey, 1, 0, 'N',
					'update', 'Auto Set Active Procedure', @v_historyorder, @v_pricetypedesc, @v_error_code output, @v_error_desc output
			END 
			
			FETCH NEXT FROM cur_related_bookprice_rows INTO @v_pricetypecode,@v_historyorder,@v_pricekey
		END -- end of while fetch_status <> - 1
		CLOSE cur_related_bookprice_rows 
    		DEALLOCATE cur_related_bookprice_rows
			
 		select @minbookkey = min(bookkey)
		  from #tmp_bookkey
		 where bookkey > @minbookkey
		 
 		set @counter = @counter + 1
	END 

    SET @v_bookkey = 0
    SET @v_pricekey = 0

	DECLARE cur_bookprice_rows CURSOR FOR
		SELECT distinct bookkey, pricekey
		  FROM bookprice
		 WHERE lastmaintdate = @v_currentdate

	OPEN cur_bookprice_rows

	FETCH NEXT FROM cur_bookprice_rows INTO @v_bookkey,@v_pricekey
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN

--print '@v_bookkey'
--print @v_bookkey
--print '@v_pricekey 2'
--print @v_pricekey
			SET @v_error_code = 0
			SET @v_error_desc = ''
			--bookkey,messagetype=1(will include title/product number in message),validatetype = 2 (checks active indicators and ovelapping effective and expiration dates)
			EXEC dbo.qtitle_price_validate_activeindanddates @v_bookkey,1,2, @v_error_code output, @v_error_desc output
				
			IF @v_error_code <> 0 
			BEGIN
				exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Set Active Book Prices','Set Active Book Prices','Auto Set Active Procedure',@v_pricekey,0,0,4,@v_error_desc,null,@o_error_code output, @o_error_desc output 
			END
			
			
			FETCH NEXT FROM cur_bookprice_rows INTO @v_bookkey,@v_pricekey
	END -- end of while fetch_status <> - 1
	CLOSE cur_bookprice_rows 
   	DEALLOCATE cur_bookprice_rows

	exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Set Active Book Prices','Set Active Book Prices','Auto Set Active Procedure',0,0,0,6,'job completed','completed',@o_error_code output, @o_error_desc output 
END

SET NOCOUNT OFF

GRANT EXEC ON dbo.qtitle_set_active_prices TO PUBLIC
GO