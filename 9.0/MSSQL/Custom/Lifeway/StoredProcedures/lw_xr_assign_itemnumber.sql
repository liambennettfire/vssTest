/****** Object:  StoredProcedure [dbo].[lw_xr_assign_itemnumber]    Script Date: 07/23/2015 16:50:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lw_xr_assign_itemnumber]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[lw_xr_assign_itemnumber]
GO
/****** Object:  StoredProcedure [dbo].[lw_xr_assign_itemnumber]    Script Date: 07/23/2015 16:50:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[lw_xr_assign_itemnumber] @v_bookkey int
as
BEGIN
DECLARE	@v_qsibatchkey	int
DECLARE @v_qsijobkey	int
DECLARE @o_error_code	int
DECLARE @v_error_code		int
DECLARE @v_ItemNo_datacode		int
declare @v_xr_datacode int
DECLARE @o_error_desc	varchar(300)
DECLARE @v_error_desc	varchar(300)
DECLARE	@v_userid	varchar(30)
DECLARE @v_datadesc varchar(255)
declare @V_shortdesc varchar(50)
DECLARE @v_currentdate	datetime
DECLARE @error_var	INT
DECLARE @rowcount_var	INT
	
declare @debug tinyint
declare @i_imprintkey int
declare @sp varchar(15)
declare @msg varchar(4000)

-- Item Number
declare @v_ItemNo_CURRENT varchar(50)
declare @b_ItemNo_exists bit

declare @v_xr_datasubcode int
declare @v_ItemNo_datasubcode int
declare @v_ItemNo_begin varchar(50)
declare @v_ItemNo_end varchar(50)
declare @v_ItemNo_next varchar(50)
declare @v_ItemNo_mprefix varchar(50)
declare @i_ItemNo_begin int
declare @i_ItemNo_end int
declare @i_ItemNo_next int
declare @secondSegment_current varchar(50)
declare @firstSegment_current varchar(50)
declare @i_secondSegment_current bigint
declare @is_child bit
declare @parent_bookkey int
declare @parent_itemNumber varchar(20)
declare @padding_count int
declare @padding_str varchar(20)

declare @V_itemNoJob_datacode int
declare @v_datadescJOB varchar(50)
declare @V_shortdescJOB  varchar(50)
declare @V_ItemNoJOB_Datasubcode int
 
declare @num_ItemNo_left_in_range int
declare @si_pubYear smallint

declare @v_ItemNo  varchar(50)

select @debug =1
select @sp = 'lw_xr_assign_itemnumber'
if @debug =1 set nocount on

-- QUERY gentables,	543	QSIJOBTYPE, Custom Item Number Assignment	ItemNumAssmt
SELECT @v_ItemNoJOB_datacode = datacode, @v_datadescJOB=datadesc,@V_shortdescJOB=datadescshort, @v_ItemNoJOB_datasubcode = datasubcode 
from subgentables 
where tableid=543 and externalcode = 'ItemNumAssmt'--datacode=16 and datasubcode=3 -- externalcode = 'ItemNumAssmt'
 -- select * from subgentables where tableid=543 and externalcode='ItemNumAssmt'

-- QUERY gentables, 525	148	Cross Reference ID Assignment, MISCTABLES	xrIDAssign
select @v_xr_datacode = datacode 
from gentables 
where tableid = 525 and externalcode = 'xrIDAssign'
 -- select * from gentables where tableid=525 and externalcode='xrIDAssign'

select @i_imprintkey = orgentrykey 
from bookorgentry 
where orglevelkey = 3 and bookkey = @v_bookkey
  
select @msg =  'Started. Item Number Assignment.'-- Stored procedure (lw_xr_assign_itemnumber) on bookkey: '+ 
	--convert(varchar(50),@v_bookkey)+ ' with imprintkey = '+ convert(varchar(50),@i_imprintkey)+'.'
if @debug =1 print @msg
EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
	null,   @v_datadescJOB,   'qsiadmin',@v_bookkey,     0,       0,      1            ,@msg,       'started',    @o_error_code output, @o_error_desc output
	-- jobdesc, jobdescshort, userid, refkey1, refkey2, refkey3, msgtypecode, msglongdesc, msgshortdesc, errorcode, errordesc



if isNull(@v_xr_datacode,0)=0 begin
	select @msg ='Aborted. Unable to get gentables where tableid=525 (Cross Reference ID Assignment) and externalcode=xrIDAssign.'
	if @debug =1 print @msg
	EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output,@v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
	null,   @v_datadescJOB,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
	return 0
end

 
 -- Check if the book already has a ItemNo and if so, do  nothing and log the message in the qsijobmessage
select @v_ItemNo_CURRENT = itemnumber from isbn where bookkey = @v_bookkey
-- Check if book has a second segment to include in Item Number
select @i_secondSegment_current = longvalue from bookmisc where misckey=408 and bookkey=@v_bookkey
-- Check if book is a child 
select @parent_bookkey=associatetitlebookkey from associatedtitles where bookkey=@v_bookkey and associationtypecode=11

if isNull(@i_secondSegment_current,0)<>0    begin
	select @secondSegment_current = datadesc from subgentables where tableid=525 and datacode=146 and datasubcode=@i_secondSegment_current
end




-- If bookkey is child but has no second segment for Item Number assigned, Abort and write error message.
if isNull(@parent_bookkey,0) <> 0 and isNull(@i_secondSegment_current,0)=0 begin
	select @msg ='Aborted. Bookkey '+convert(varchar(50),@v_bookkey)+' is a child and has no Item Number Second Segment assigned.'
	if @debug =1 print @msg
	EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output,@v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
	null,   @v_datadescJOB,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
	return 0
end


-- book has an item number already
 if (isnull(@v_ItemNo_CURRENT,'')<>'') begin
	select @msg =  'Aborted. The bookkey '+convert(varchar(50),@v_bookkey)+' has an Item Number '+@v_ItemNo_CURRENT+' assigned already.'
	if @debug =1 print @msg
	EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
	null,   @v_datadescJOB,   'qsiadmin',@v_bookkey,0,0,5,@msg,'INFO',@o_error_code output, @o_error_desc output
	return 1
 end
  -- book does not have an item number already
 else begin 
	if @debug =1 print 'The book does not have an Item Number assigned already'
	
	-- If bookkey is a child and has the necessary secondsegment assigned (and has no current itemNumber)	
	if isNull(@parent_bookkey,0) <> 0 and isNull(@secondSegment_current,'')<>'' begin	
		if @debug = 1 print '@parent_bookkey: '+ convert(varchar(20), @parent_bookkey)
		if @debug = 1 print '@secondSegment_current: '+@secondSegment_current			
		if @debug=1 print 'Assigning a child item number'				
		
		select @parent_itemNumber=itemnumber from isbn where bookkey = @parent_bookkey
		
		if isNull(@parent_itemNumber,0)=0 begin
			select @msg = 'Aborted. Parent ItemNumber is missing.'--+convert(varchar(20),@i_imprintkey) + convert(varchar(20),@v_xr_datacode)
			if @debug = 1 print @msg
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
				null,   @v_datadescJOB,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
			return 0
		end --  @parent_itemNumber is null
		
		select @v_ItemNo = @parent_itemNumber+'.'+@secondSegment_current
		
		select @b_ItemNo_exists = [dbo].[check_if_ItemNo_exists](@v_itemNo)
		
		if @b_ItemNo_exists = 1 begin
			select @msg = 'Aborted. Cannot set Item Number as it already exists with that Second Segment; '+@v_ItemNo+'. '
			if @debug = 1 print @msg
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
				null,   @v_datadescJOB,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
			return 0
		end
		update isbn set itemnumber=@v_ItemNo where bookkey = @v_bookkey
		
		select @msg = 'Completed. Bookkey='+convert(varchar(50),@v_bookkey)+
			' with imprintkey='+convert(varchar(50),@i_imprintkey)+' given ItemNo='+ @v_ItemNo
		if @debug =1 print @msg
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output,@v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
			null,   @v_datadescJOB,'qsiadmin',@v_bookkey,0,0,6,@msg,'completed',@o_error_code output, @o_error_desc output
		return 1
	end-- If bookkey is a child and has the necessary secondsegment assigned (and has no current itemNumber)
	
	select @v_ItemNo_datasubcode = s.datasubcode,
		@v_ItemNo_datacode = s.datacode,
		@v_ItemNo_begin = s.alternatedesc1, -- beginning range
		@v_ItemNo_end = s.alternatedesc2, -- end range
		@v_ItemNo_next = s.externalcode -- next item number
	from subgentables s 
	join subgentablesorglevel so on s.tableid = 525 
		and s.tableid = so.tableid 
		and s.datacode = so.datacode 
		and s.datasubcode = so.datasubcode
		and s.datacode = @v_xr_datacode
		and s.bisacdatacode = 'ItemNumber'
		and so.orgentrykey = @i_imprintkey 

	if @debug = 1 print '@v_ItemNo_next: '+@v_ItemNo_next
		
	set @i_ItemNo_begin = CONVERT(int, @v_ItemNo_begin)
	set @i_ItemNo_end = CONVERT(int, @v_ItemNo_end)
	set @i_ItemNo_next = CONVERT(int, @v_ItemNo_next)
	
	select @padding_count = LEN(@v_ItemNo_next)
	
	if @i_ItemNo_next is null begin
		select @msg = 'Aborted. Next ItemNo is missing.'--+convert(varchar(20),@i_imprintkey) + convert(varchar(20),@v_xr_datacode)
		if @debug = 1 print @msg
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
			null,   @v_datadescJOB,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
		return 0
	end --  @i_ItemNo_next is null
		
	-- need to do this check and log a message; while testing, out of the first 100 next in the range only 19 aren't used
	set @num_ItemNo_left_in_range = @i_ItemNo_end - @i_ItemNo_next +1
	if @debug=1 begin
		print 'There are only '+convert(varchar(30),@num_ItemNo_left_in_range) + ' left in the range configured in gentables.'
		print '@i_ItemNo_next: ' + @v_ItemNo_next
	end
	if (@num_ItemNo_left_in_range) < 500 	begin
		select @msg = 'Warning: Less than 500 remain ('+convert(varchar(30),@num_ItemNo_left_in_range)+
			' left) in Item Number range. Check availability of additional numbers.'

		if @debug = 1 print @msg
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output,@v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
			null,   @v_datadescJOB,  'qsiadmin',@v_bookkey,0,0,3,@msg,'WARNING',@o_error_code output, @o_error_desc output
	end --  (@num_ItemNo_left_in_range) < 500
	
	-- next @v_ItemNo in system is out of range
	if @i_ItemNo_next > @i_ItemNo_end begin
		select @msg = 'Aborted. Cannot set Item Number as next value is out of range defined.'
		if @debug = 1 print @msg
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
			null,   @v_datadescJOB,  'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
		return 0
	end -- if next @v_ItemNo is out of range
	
	select @v_ItemNo = @v_ItemNo_next
	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT

	
	if @debug = 1 print 'Checking if next Item Number already exists: ' + @v_ItemNo	
	select @b_ItemNo_exists = [dbo].[check_if_ItemNo_exists](@v_itemNo)
	-- next ItemNo is not already in use
	if @b_ItemNo_exists =0   begin 
	
		if @debug = 1 print '@i_ItemNo_next does not exist so use it for this bookkey'
		if @debug = 1 print 'update isbn set itemnumber = ' +@v_ItemNo+' where bookkey = '+convert(varchar(50),@v_bookkey)
		update isbn set itemnumber = @v_ItemNo where bookkey = @v_bookkey

		set @i_ItemNo_next = @i_ItemNo_next + 1	
		select @v_ItemNo_next = RIGHT(replicate('0',@padding_count)+convert(varchar(20),@i_itemNo_next),@padding_count)	
		
		if @debug = 1 print 'update subgentables set externalcode = '+@v_ItemNo_next+
			' where tableid=525 and datacode ='+convert(varchar(20),@v_xr_datacode)
			+' and datasubcode='+convert(varchar(20),@v_ItemNo_datasubcode)
		update subgentables
		set externalcode = @v_ItemNo_next
		where tableid = 525 and datacode = @v_ItemNo_datacode and datasubcode = @v_ItemNo_datasubcode
	end -- if @b_ItemNo_exists =0

	-- The ItemNo is already in use, get a different one and increment the @i_ItemNo_next in subgentables
	else begin 
		-- use temp table to populate with 500 of the next ItemNo and check if they already exist - if they all exist, then submit error
			-- trying to avoid tricky while loops 	
		if @debug=1 print '@i_ItemNo_next ALREADY EXISTS, so find one that doesnt'	
				
		create table #check_ItemNos (
			id int identity(1,1),
			test_ItemNo varchar(50),
			existant bit        
		)
		declare @i int 
		declare @id int
		declare @maxID int
		declare @test varchar(50)
		declare @i_test bigint
		declare @i_temp_ItemNo bigint
		declare @good_ItemNo varchar(50)
		declare @count_open_ItemNos int
		
		SET @i=1
		select @test = @v_ItemNo_next 
		insert #check_ItemNos (test_ItemNo) values (  @test )

		WHILE @i<500 begin
			select @i_test = @i_ItemNo_next + @i
			select @test = RIGHT(replicate('0',@padding_count)+convert(varchar(20),@i_test),@padding_count)
			insert #check_ItemNos (test_ItemNo) values (  @test)
			SET @i=@i+1
		end -- end while @i<50
		
		SET @i=1
		WHILE @i<501 begin
			update #check_ItemNos set existant = [dbo].[check_if_ItemNo_exists](test_ItemNo) 
			from #check_ItemNos
			where id = @i
			SET @i=@i+1
		end -- end while @i<50
		
		delete from #check_ItemNos where convert(bigint,test_ItemNo) > convert(bigint,@v_ItemNo_end)+1
		
		select @count_open_ItemNos = count(*) from #check_ItemNos where existant=0
		select @count_open_ItemNos = coalesce(@count_open_ItemNos, -1)
		
		 -- only 1 ItemNo available from next 500 in range
		if @count_open_ItemNos = 1 begin
			select @id = MIN(id) from #check_ItemNos where existant=0
			select @good_ItemNo = test_ItemNo from #check_ItemNos where id = @id
			
			if @debug =1 select * from #check_ItemNos
						
			-- next AVAILABLE (unused) ItemNo in system is out of range
			if @good_ItemNo > @i_ItemNo_end begin
						
				select @v_ItemNo_next = RIGHT(replicate('0',@padding_count)+@good_ItemNo,@padding_count)		
					
				update subgentables
				set externalcode = @v_ItemNo_next
				where tableid = 525 and datacode = @v_ItemNo_datacode and datasubcode = @v_ItemNo_datasubcode
			
				select @msg = 'Aborted. Cannot set ItemNo as next UNUSED ItemNo is out of range defined.'
				if @debug = 1 print @msg
				EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
					null,   @v_datadescJOB,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
				return 0
				
			end -- if next ItemNo is out of range
				
			-- so set the next_ItemNo in gentable to the highest in range since we just used the only one available
			-- , when the app tries to use it, it will enter this procedure and check the next 500 after that one
			select @maxID= MAX(id) from #check_ItemNos where existant=0
			select @i_ItemNo_next=CONVERT(bigint,test_ItemNo) from #check_ItemNos where id = @maxID
			select @v_ItemNo_next = RIGHT(replicate('0',@padding_count)+convert(varchar(20),@i_itemNo_next),@padding_count)	
			
			if @debug =1 print 'updating ITEMNUMBER: @good_ItemNo = '+ @good_ItemNo+' and @i_ItemNo_next='+ convert(varchar(50),@i_ItemNo_next)
			
			update isbn set itemnumber = @good_ItemNo where bookkey = @v_bookkey
			select @v_ItemNo = @good_ItemNo
			
			update subgentables
			set externalcode = @v_ItemNo_next
			where tableid = 525 and datacode = @v_ItemNo_datacode and datasubcode = @v_ItemNo_datasubcode
		end		
		else if @count_open_ItemNos > 1 begin
			select @id = MIN(id) from #check_ItemNos where existant=0
			select @good_ItemNo = test_ItemNo from #check_ItemNos where id = @id
			select @id= MIN(id) from #check_ItemNos where existant=0 and id>@id
			select @i_ItemNo_next=convert(bigint, test_ItemNo) from #check_ItemNos where id = @id
			select @v_ItemNo_next = RIGHT(replicate('0',@padding_count)+convert(varchar(20),@i_itemNo_next),@padding_count)		
			
			if @debug =1 select * from #check_ItemNos
			if @debug =1 print '@good_ItemNo = '+ @good_ItemNo+' and @i_ItemNo_next='+ @v_ItemNo_next
			
			update isbn set itemNumber = @good_ItemNo where bookkey = @v_bookkey
			select @v_ItemNo  = @good_ItemNo
			
				
			update subgentables
			set externalcode = @v_ItemNo_next
			where tableid = 525 and datacode = @v_ItemNo_datacode and datasubcode = @v_ItemNo_datasubcode
		end
		else if @count_open_ItemNos < 1  begin
			select @msg = 'Aborted. There are no unused ItemNos in the next 500 in range so set next ItemNo to next+500'
			if @debug= 1 print @msg
			-- so set the next_ItemNo in gentable to the highest in range, when the app
			-- tries to use it, it will enter this procedure and check the next 500 after that one
			select @maxID= MAX(id) from #check_ItemNos where existant=0
			select @i_ItemNo_next=convert(bigint, test_ItemNo) from #check_ItemNos where id = @maxID
			select @v_ItemNo_next = RIGHT(replicate('0',@padding_count)+convert(varchar(20),@i_itemNo_next),@padding_count)		
					
			update subgentables
			set externalcode = @v_ItemNo_next
			where tableid = 525 and datacode = @v_ItemNo_datacode and datasubcode = @v_ItemNo_datasubcode
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
				null,   @v_datadescJOB,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
			return 0
		end --else if @count_open_ItemNos < 1 
		drop table #check_ItemNos
	end --  @b_ItemNo_exists <> 0 
end	--  -- not (if @v_ItemNo_CURRENT is not null or  LTRIM(rtrim(@v_ItemNo_CURRENT))<> '')

select @msg = 'Completed. Item Number Assignment.' --Bookkey='+convert(varchar(50),@v_bookkey)+
			--' with imprintkey='+convert(varchar(50),@i_imprintkey)+' given ItemNo='+ @v_ItemNo

if @debug =1 print @msg

EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output,@v_ItemNoJOB_datacode,@v_ItemNoJOB_datasubcode,
	null,   @v_datadescJOB,'qsiadmin',@v_bookkey,0,0,6,@msg,'completed',@o_error_code output, @o_error_desc output
return 1
end -- begin stored procedure creation

