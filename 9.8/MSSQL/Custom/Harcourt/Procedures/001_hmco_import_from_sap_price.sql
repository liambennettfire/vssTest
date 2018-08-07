/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_price]    Script Date: 02/25/2009 14:08:04 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_price]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_price]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




create PROCEDURE [dbo].[hmco_import_from_SAP_price] 
	@i_bookkey int, 
	@i_userid   varchar(30),
	@i_update_mode	char(1),
	@pricetypecode	int,	
	@currencytypecode	int, 
	@priceeffdate	datetime, 
	@priceactiveind	int,
	@pricevalue		float,
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare @count	int,
@datedesc	varchar(50),
@sortorder	int,
@v_error	varchar(2000),
@v_rowcount	int

declare @pricedesc	varchar(40),
@pricedescshort	varchar(40),
@historypricevalue varchar(30),
@currencydescshort	varchar(40),
@currencydesc		varchar(40),
@pricevalue2		float,
@priceeffdate2		datetime,
@newkey				int,
@priceeffchange		char(1)


if @pricetypecode = 0
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update price.  You must populate the pricetypecode.'
	RETURN
end

if @currencytypecode = 0
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update price.  You must populate the currencytypecode.'
	RETURN
end

if isnull(@priceactiveind, -1) not in (1, 0)
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update price.  Priceactiveind must be 1 for active or 0 for inactive.'
	RETURN
end

if @pricevalue is null
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update price.  You must populate the pricevalue.'
	RETURN
end

select @pricedesc = datadesc, @pricedescshort = datadescshort
from gentables
where tableid = 306
and datacode = @pricetypecode

SELECT @v_rowcount = @@ROWCOUNT
if @v_rowcount = 0
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update price.  Pricetypecode is invalid.'
	RETURN
end

select @currencydesc = datadesc, @currencydescshort = datadescshort
from gentables
where tableid = 122
and datacode = @currencytypecode

SELECT @v_rowcount = @@ROWCOUNT
if @v_rowcount = 0
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update price.  Currencytypecode is invalid.'
	RETURN
end

set @historypricevalue = convert(varchar(20), @pricevalue) + ' ' + @currencydescshort

select @pricevalue2 = finalprice, @priceeffdate2 = effectivedate
from bookprice
where bookkey = @i_bookkey
and pricetypecode = @pricetypecode
and currencytypecode = @currencytypecode
and activeind = @priceactiveind

SELECT @count = @@ROWCOUNT

if isnull(@count,0) = 0
begin
	select @sortorder = max(isnull(sortorder,0))
	from bookprice
	where bookkey = @i_bookkey

	select @sortorder = isnull(@sortorder,0) + 1

	exec get_next_key @i_userid, @newkey output

	insert into bookprice
	(pricekey, bookkey,pricetypecode,currencytypecode, activeind, finalprice, effectivedate, lastuserid,lastmaintdate,sortorder, history_order)
	values (@newkey, @i_bookkey,@pricetypecode,@currencytypecode,@priceactiveind,@pricevalue,@priceeffdate, @i_userid,getdate(),@sortorder,@sortorder)

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to update bookprice table.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 

	exec qtitle_update_titlehistory 'bookprice', 'pricetypecode' , @i_bookkey, 1, 0, @pricedesc, 'Insert', @i_userid, 
			@sortorder, @pricedescshort, @o_error_code output, @o_error_desc output

	exec qtitle_update_titlehistory 'bookprice', 'finalprice' , @i_bookkey, 1, 0, @historypricevalue, 'Insert', @i_userid, 
			@sortorder, @pricedescshort, @o_error_code output, @o_error_desc output

	exec qtitle_update_titlehistory 'bookprice', 'currencytypecode' , @i_bookkey, 1, 0, @currencydesc, 'Insert', @i_userid, 
			@sortorder, @pricedescshort, @o_error_code output, @o_error_desc output

	if @priceeffdate is not null
		exec qtitle_update_titlehistory 'bookprice', 'effectivedate' , @i_bookkey, 1, 0, @priceeffdate, 'Insert', @i_userid, 
				@sortorder, @pricedescshort, @o_error_code output, @o_error_desc output

	if @priceactiveind = 1
		exec qtitle_update_titlehistory 'bookprice', 'activeind' , @i_bookkey, 1, 0, 'Y', 'Insert', @i_userid, 
				@sortorder, @pricedescshort, @o_error_code output, @o_error_desc output
	else if @priceactiveind = 0
		exec qtitle_update_titlehistory 'bookprice', 'activeind' , @i_bookkey, 1, 0, 'N', 'Insert', @i_userid, 
				@sortorder, @pricedescshort, @o_error_code output, @o_error_desc output
	
end
else
begin
	if isnull(@pricevalue2, -1) <> isnull(@pricevalue,-1)
	begin
		set @priceeffchange = 'Y'
		if @priceeffdate is null or @priceeffdate = @priceeffdate2
		begin
			set @priceeffdate = @priceeffdate2
			set @priceeffchange = 'N'
		end

		update bookprice
		set finalprice = @pricevalue,
		effectivedate = @priceeffdate,
		lastmaintdate = getdate(),
		lastuserid = @i_userid
		where bookkey = @i_bookkey 
		and pricetypecode = @pricetypecode
		and currencytypecode = @currencytypecode
		and activeind = @priceactiveind

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update bookdates table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'bookprice', 'finalprice' , @i_bookkey, 1, 0, @historypricevalue, 'Update', @i_userid, 
				@sortorder, @pricedescshort, @o_error_code output, @o_error_desc output

		if @priceeffchange = 'Y'
			exec qtitle_update_titlehistory 'bookprice', 'effectivedate' , @i_bookkey, 1, 0, @priceeffdate, 'Update', @i_userid, 
					@sortorder, @pricedescshort, @o_error_code output, @o_error_desc output

	end
end

end
