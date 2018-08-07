IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'feed_in_vista_bookmisc_sp')
BEGIN
  DROP  Procedure  feed_in_vista_bookmisc_sp
END
GO
CREATE PROCEDURE dbo.feed_in_vista_bookmisc_sp 
	(@i_bookkey integer,
	@i_misckey integer,
	@c_columntype varchar(10),
	@i_longvalue integer,
	@f_floatvalue numeric(18,4),
	@c_textvalue varchar(255),
	@i_return integer OUT) 
AS
BEGIN
DECLARE
@err_msg char(200),
@feed_system_date datetime,
@feed_count integer,
@feed_count2 integer,
@lv_update integer,
@i_longvalue_new integer,
@f_floatvalue_new numeric(18,4),
@c_textvalue_new varchar(255)
BEGIN

set @lv_update = 0
set @feed_system_date = getdate()


--##############################
/* check if misckey updating is present if not insert*/

		select @feed_count = count(*)
		from bookmisc
		where bookkey= @i_bookkey
		and misckey = @i_misckey

	if @feed_count = 0 begin  /*make sure misckey present */


		select @feed_count2 = count(*)
	        from bookmiscitems
		where misckey = @i_misckey

		if @feed_count2 > 0 
      begin
			insert into bookmisc (bookkey,misckey)
			values (@i_bookkey,@i_misckey)
			set @lv_update = 1

		end 
      else 
      begin
			insert into feederror (batchnumber,processdate,errordesc)
			values ('10',@feed_system_date,'Misckey does not exists on bookmiscitems table, misckey = ' + cast(@i_misckey as varchar(20)))
		end
      end
	else 
	begin
		set @lv_update = 1
	end

	if @lv_update > 0 begin
		if @c_columntype = '0' begin
			if @f_floatvalue = 0 begin
				set @f_floatvalue_new = null
			end
			if @f_floatvalue is null begin
				set @f_floatvalue_new = null
			end
			if @f_floatvalue <> 0 begin
				set @f_floatvalue_new = @f_floatvalue
			end
			update bookmisc
			   set floatvalue = @f_floatvalue_new,
				lastuserid = 'VISTAPLFEED',
				lastmaintdate = @feed_system_date
				where bookkey = @i_bookkey
					and misckey = @i_misckey
		 set @i_return = 0
		end

		if @c_columntype = '1' begin
			if @i_longvalue = 0 begin
				set @i_longvalue_new = null
			end
			if @i_longvalue is null begin
				set @i_longvalue_new = null
			end
			if @i_longvalue <> 0 begin
				set @i_longvalue_new = @i_longvalue
			end

			update bookmisc
			   set longvalue = @i_longvalue_new,
				lastuserid = 'VISTAPLFEED',
				lastmaintdate = @feed_system_date
				where bookkey = @i_bookkey
					and misckey = @i_misckey
		  set @i_return =  0
		end

		if @c_columntype = '2' begin
			if len(@c_textvalue) = 0 begin
				set @c_textvalue_new = null
			end
			if @c_textvalue is null begin
				set @c_textvalue_new = null
			end
			if len(@c_textvalue) > 0 begin
				set @c_textvalue_new = @c_textvalue
			end
			update bookmisc
			   set textvalue = @c_textvalue_new,
				lastuserid = 'VISTAPLFEED',
				lastmaintdate = @feed_system_date
				where bookkey = @i_bookkey
				and misckey = @i_misckey
			
		  set @i_return = 0
		end
	end else begin
		set @i_return = 1
	end




END
END
GO

GRANT EXEC ON dbo.feed_in_vista_bookmisc_sp TO public
GO