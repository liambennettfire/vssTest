/****** Object:  StoredProcedure [dbo].[lw_xr_assign_upc]    Script Date: 07/23/2015 16:50:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lw_xr_assign_upc]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[lw_xr_assign_upc]
GO
/****** Object:  StoredProcedure [dbo].[lw_xr_assign_upc]    Script Date: 07/23/2015 16:50:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[lw_xr_assign_upc] @v_bookkey int
as
BEGIN
DECLARE	@v_qsibatchkey	int
DECLARE @v_qsijobkey	int
DECLARE @o_error_code	int
DECLARE @v_error_code		int
DECLARE @v_upc_datacode		int
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

--UPC
declare @v_upc_CURRENT varchar(50)
declare @b_upc_exists bit

declare @v_xr_datasubcode int
declare @v_upc_datasubcode int
declare @v_upc_begin varchar(50)
declare @v_upc_end varchar(50)
declare @v_upc_next varchar(50)
declare @v_upc_mprefix varchar(50)
declare @i_upc_begin int
declare @i_upc_end int
declare @i_upc_next int
declare @num_upcs_left_in_range int

declare @v_upc_11 varchar(50)
declare @v_upc_12 varchar(50)

select @debug =1
select @sp = 'lw_xr_assign_upc'
if @debug =1 set nocount on

-- QUERY gentables,	543	QSIJOBTYPE, Custom UPC Assignment	UPCAssmt
SELECT @v_upc_datacode = datacode, @v_datadesc=datadesc,@V_shortdesc=datadescshort, @v_upc_datasubcode = datasubcode 
from subgentables 
where tableid=543 and externalcode = 'UPCAssmt'--datacode=16 and datasubcode=1 -- externalcode = 'UPCAssmt'

select @i_imprintkey = orgentrykey 
from bookorgentry 
where orglevelkey = 3 and bookkey = @v_bookkey
  
select @msg =  'Started. UPC Assignment.' -- Stored procedure (lw_xr_assign_upc) on bookkey: '+ convert(varchar(50),@v_bookkey)+ 
	--' with imprintkey: '+ convert(varchar(50),@i_imprintkey)+'.'
if @debug =1 print @msg
EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
	null,   @v_datadesc,   'qsiadmin',@v_bookkey,     0,       0,      1            ,@msg,       'started',    @o_error_code output, @o_error_desc output
	-- jobdesc, jobdescshort, userid, refkey1, refkey2, refkey3, msgtypecode, msglongdesc, msgshortdesc, errorcode, errordesc

-- QUERY gentables, 525	148	Cross Reference ID Assignment, MISCTABLES	xrIDAssign
select @v_xr_datacode = datacode 
from gentables 
where tableid = 525 and externalcode = 'xrIDAssign'

if isNull(@v_xr_datacode,0)=0 begin
	select @msg ='Aborted. Unable to get gentables where tableid=525 and externalcode=xrIDAssign.'
	if @debug =1 print @msg
	EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
		null,   @v_datadesc,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
	return 0
end

if isNull(@v_upc_datacode,0)=0 or isNull(@v_upc_datasubcode,0)=0  begin
	select @msg ='Aborted. Unable to get subgentables where tableid=543 and externalcode=UPCAssmt.'
	if @debug =1 print @msg
	EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
		null,   @v_datadesc,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
	return 0
end
 
 -- Check if the book already has a UPC and if so, do  nothing and log the message in the qsijobmessage
select @v_upc_CURRENT = upc from isbn where bookkey = @v_bookkey

 if (isnull(@v_upc_CURRENT,'')<>'') begin
	select @msg =  'Aborted. The bookkey '+convert(varchar(50),@v_bookkey)+' has a UPC='+@v_upc_CURRENT+' assigned already.'
	if @debug =1 print @msg
	EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
		null,   @v_datadesc,   'qsiadmin',@v_bookkey,0,0,5,@msg,'INFO',@o_error_code output, @o_error_desc output
	return 1
 end
  -- @v_upc_CURRENT IS null or empty string so else
 else begin
	if @debug =1 print 'the book does not have a UPC assigned already.'
	select @v_xr_datasubcode = so.datasubcode,
		@v_upc_mprefix = s.datadescshort,
		@v_upc_begin = s.alternatedesc1,
		@v_upc_end = s.alternatedesc2,
		@v_upc_next = s.externalcode
	from subgentables s 
	join subgentablesorglevel so on s.tableid = 525 
		and s.tableid = so.tableid 
		and s.datacode = so.datacode 
		and s.datasubcode = so.datasubcode
		and s.datacode = @v_xr_datacode
		and s.bisacdatacode = 'UPC'
		and so.orgentrykey = @i_imprintkey

	set @i_upc_begin = CONVERT(int, @v_upc_begin)
	set @i_upc_end = CONVERT(int, @v_upc_end)
	set @i_upc_next = CONVERT(int, @v_upc_next)
	
	if @i_upc_next is null begin
		select @msg = 'Aborted. Next UPC is missing.'--+convert(varchar(20),@i_imprintkey) + convert(varchar(20),@v_xr_datacode)
		if @debug = 1 print @msg
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
				null,   @v_datadesc,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
		return 0
	end --  @i_upc_next is null
		
	if @v_upc_mprefix is null begin
		select @msg = 'Aborted. UPC manufacturer prefix is null. Ensure proper UPC manufacturer prefix is set up in user tables.'--+convert(varchar(20),@v_xr_datacode)+convert(varchar(20),@i_imprintkey)
		if @debug = 1 print @msg
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
				null,   @v_datadesc,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
		return 0
	end	--  @v_upc_mprefix is null

	-- need to do this check and log a message; while testing, out of the first 100 next in the range only 19 aren't used
	set @num_upcs_left_in_range = @i_upc_end - @i_upc_next +1
	if @debug=1 begin
		print 'There are only '+convert(varchar(30),@num_upcs_left_in_range) + ' left in the range configured in gentables.'
		print '@i_upc_next: ' + convert(varchar(50), @i_upc_next)
		print '@v_upc_mprefix: ' + convert(varchar(50), @v_upc_mprefix)
	end
	if (@num_upcs_left_in_range) < 500 	begin
		select @msg = 'Warning: Less than 500 available numbers remain ('+convert(varchar(30),@num_upcs_left_in_range)+
			' left) in UPC range for manufacturer prefix: ['+convert(varchar(50), @v_upc_mprefix)+']. '+
			'Check availability of additional numbers or setup a new manufacturer prefix with a new range of values.'
		if @debug = 1 print @msg
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
				null,   @v_datadesc,   'qsiadmin',@v_bookkey,0,0,3,@msg,'WARNING',@o_error_code output, @o_error_desc output
	end --  (@num_upcs_left_in_range) < 500
	
	-- next upc in system is out of range
	if @i_upc_next > @i_upc_end begin
		select @msg = 'Aborted. Cannot set UPC as next value is out of range defined.'
		if @debug = 1 print @msg
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
			null,   @v_datadesc,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
		return 0
	end -- if next upc is out of range
	
	select @v_upc_11 = @v_upc_mprefix + @v_upc_next
	select @v_upc_12 = @v_upc_11 + CONVERT(varchar(50),dbo.upc_check_digit_calc(@v_upc_11))
	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT

	if len(@v_upc_11) <> 11 begin
		select @msg = 'Aborted. Ensure that UPC manufacturer prefix and number have a length of 11 characters.'
		if @debug = 1 print @msg
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
				null,   @v_datadesc,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
		return 0
	end --  @i_upc_next is null

	if @debug = 1 print 'Checking if next UPC already exists: ' + convert(varchar(50), @v_upc_12)
	select @b_upc_exists = [dbo].[check_if_upc_exists](@v_upc_12)

	-- next upc is not already in use
	if @b_upc_exists =0 begin 
	
		if @debug = 1 print '@i_upc_next does not exist so use it for this bookkey'
		if @debug = 1 print 'update isbn set upc = ' +@v_upc_12+' where bookkey = '+convert(varchar(50),@v_bookkey)
		update isbn set upc = @v_upc_12 where bookkey = @v_bookkey

		set @i_upc_next = @i_upc_next + 1
		
		
		if @debug = 1 print 'update subgentables set externalcode = '+convert(varchar(20),@i_upc_next)+' where tableid=525 and datacode ='+convert(varchar(20),@v_xr_datacode)
			+' and datasubcode='+convert(varchar(20),@v_upc_datasubcode)
		update subgentables
		set externalcode = convert(varchar(20),@i_upc_next)
		where tableid = 525 and datacode = @v_xr_datacode and datasubcode = @v_xr_datasubcode
	
		
	end -- if @b_upc_exists =0
	-- The upc is already in use, get a different one and increment the @i_upc_next in subgentables
	else begin 
		-- use temp table to populate with 500 of the next Upc codes and check if they already exist - if they all exist, then submit error
			-- trying to avoid tricky while loops 	
		if @debug=1 print '@i_upc_next ALREADY EXISTS, so find one that doesnt'	
				
		create table #check_upcs (
			id int identity(1,1),
			test_upc varchar(50),
			existant bit,
			postfix bigint          
		)
		declare @i int 
		declare @id int
		declare @maxID int
		declare @test varchar(50)
		declare @incr bigint
		declare @i_temp_upc bigint
		declare @good_upc varchar(50)
		declare @count_open_upcs int
		
		SET @i=1
		select @test = @v_upc_12
		insert #check_upcs (test_upc, postfix) values (  @test, @i_upc_next )

		WHILE @i<500 begin
			select @incr = @i_upc_next + @i
			select @test = @v_upc_mprefix + convert(varchar(50),@incr)
			select @test = @test + CONVERT(varchar(50),dbo.upc_check_digit_calc(@test))
			insert #check_upcs (test_upc,postfix) values (  @test,@incr )
			SET @i=@i+1
		end -- end while @i<50
		
		SET @i=1
		WHILE @i<501 begin
			update #check_upcs set existant = [dbo].[check_if_upc_exists](test_upc) 
			from #check_upcs
			where id = @i
			SET @i=@i+1
		end -- end while @i<50
		
		delete from #check_upcs where postfix > convert(bigint,@v_upc_end)+1
		
		select @count_open_upcs = count(*) from #check_upcs where existant=0
		select @count_open_upcs = coalesce(@count_open_upcs, -1)
		
		 -- only 1 UPC available from next 500 in range
		if @count_open_upcs = 1 begin
			select @id = MIN(id) from #check_upcs where existant=0
			select @good_upc = test_upc,@i_upc_next=(postfix) from #check_upcs where id = @id
			
			if @debug =1 select * from #check_upcs
						
			-- next AVAILABLE (unused) upc in system is out of range
			if @i_upc_next > @i_upc_end begin
			
				update subgentables
				set externalcode = convert(varchar(20),@i_upc_next)
				where tableid = 525 and datacode = @v_xr_datacode and datasubcode = @v_upc_datasubcode
			
				select @msg = 'Aborted. Cannot set UPC as next UNUSED upc is out of range defined.'
				if @debug = 1 print @msg
				EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
					null,   @v_datadesc,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
				return 0
				
			end -- if next upc is out of range
			
			if @debug =1 print '@good_upc = '+ @good_upc+' and @i_upc_next='+ convert(varchar(50),@i_upc_next)
			
			update isbn set upc = @good_upc where bookkey = @v_bookkey
			select @v_upc_12 = @good_upc
			-- so set the next_UPC in gentable to the highest in range since we just used the only one available
			-- , when the app tries to use it, it will enter this procedure and check the next 500 after that one
			select @maxID= MAX(id) from #check_upcs where existant=0
			select @i_upc_next=(postfix) from #check_upcs where id = @maxID
				
			update subgentables
			set externalcode = convert(varchar(20),@i_upc_next)
			where tableid = 525 and datacode = @v_xr_datacode and datasubcode = @v_upc_datasubcode
		end		
		else if @count_open_upcs > 1 begin
			select @id = MIN(id) from #check_upcs where existant=0
			select @good_upc = test_upc,@i_upc_next=(postfix+1) from #check_upcs where id = @id
			
			if @debug =1 select * from #check_upcs
			if @debug =1 print '@good_upc = '+ @good_upc+' and @i_upc_next='+ convert(varchar(50),@i_upc_next)
			
			update isbn set upc = @good_upc where bookkey = @v_bookkey
			select @v_upc_12 = @good_upc
			
			select @id= MIN(id) from #check_upcs where existant=0 and id>@id
			select @i_upc_next=(postfix) from #check_upcs where id = @id
			
			update subgentables
			set externalcode = convert(varchar(20),@i_upc_next)
			where tableid = 525 and datacode = @v_xr_datacode and datasubcode = @v_upc_datasubcode
		end
		else if @count_open_upcs < 1  begin
			select @msg = 'Aborted. There are no unused UPCs in the next 500 in range so set next UPC to next+500'
			if @debug= 1 print @msg
			-- so set the next_UPC in gentable to the highest in range, when the app
			-- tries to use it, it will enter this procedure and check the next 500 after that one
			select @maxID= MAX(id) from #check_upcs where existant=0
			select @i_upc_next=(postfix) from #check_upcs where id = @maxID
			update subgentables
			set externalcode = convert(varchar(20),@i_upc_next)
			where tableid = 525 and datacode = @v_xr_datacode and datasubcode = @v_upc_datasubcode
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
					null,   @v_datadesc,   'qsiadmin',@v_bookkey,0,0,5,@msg,'ABORTED',@o_error_code output, @o_error_desc output
			return 0
		end --else if @count_open_upcs < 1 
		drop table #check_upcs
	end --  @b_upc_exists <> 0
end	--  -- not (if @v_upc_CURRENT is not null or  LTRIM(rtrim(@v_upc_CURRENT))<> '')

select @msg = 'Completed. UPC Assignment.'-- Bookkey='+convert(varchar(50),@v_bookkey)+
			--' with imprintkey='+convert(varchar(50),@i_imprintkey)+' given UPC='+ @v_upc_12 

if @debug =1 print @msg

EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_upc_datacode,@v_upc_datasubcode,
	null,@v_datadesc,'qsiadmin',@v_bookkey,0,0,6,@msg,'completed',@o_error_code output, @o_error_desc output
return 1
end -- begin stored procedure creation

