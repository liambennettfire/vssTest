IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[bnpubboardtrimcalc_sp]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[bnpubboardtrimcalc_sp]
GO

SET  QUOTED_IDENTIFIER OFF 
GO
SET  ANSI_NULLS ON 
GO

CREATE proc [dbo].[bnpubboardtrimcalc_sp] 
AS 
--------DECLARES
DECLARE @i_btrimcalc_cursor_status int
DECLARE @i_bookkey int
DECLARE @i_printingkey int
DECLARE @i_subgentableind int
DECLARE @c_esttrimsizewidth varchar(10) 
DECLARE @c_esttrimsizelength varchar(10)
DECLARE @c_trimsizewidth varchar(10)
DECLARE @c_trimsizelength varchar(10)
DECLARE @c_tmmactualtrimwidth varchar(10)
DECLARE @c_tmmactualtrimlength varchar(10)
DECLARE @c_mediatypesubcode int
DECLARE @c_trimwidth_out varchar(10)
DECLARE @c_trimlength_out varchar(10)
DECLARE @c_orig_trim_width varchar(10)
DECLARE @c_orig_trim_length varchar(10)

DECLARE cursor_boardtrimkeys INSENSITIVE CURSOR
FOR
	Select p.bookkey,p.printingkey,p.esttrimsizewidth,p.esttrimsizelength,p.trimsizewidth,p.trimsizelength,p.tmmactualtrimwidth,
          p.tmmactualtrimlength,bd.mediatypesubcode
	  From printing p, bnpubboardtrimkeys bt, bookdetail bd
	 where p.bookkey = bt.bookkey 
		and p.printingkey = bt.printingkey
		and p.bookkey = bd.bookkey
		and p.bookkey <> 672536
		and p.bookkey not in (select bl.bookkey from booklock bl)
		FOR READ ONLY


OPEN cursor_boardtrimkeys

FETCH NEXT FROM cursor_boardtrimkeys INTO @i_bookkey,@i_printingkey,@c_esttrimsizewidth,@c_esttrimsizelength,@c_trimsizewidth, 
	     @c_trimsizelength,@c_tmmactualtrimwidth, @c_tmmactualtrimlength,@c_mediatypesubcode

print @i_bookkey

select @i_btrimcalc_cursor_status = @@FETCH_STATUS

while (@i_btrimcalc_cursor_status<>-1 )
begin
	IF (@i_btrimcalc_cursor_status<>-2)
	begin
		
		Select @i_subgentableind = s.Subgen1ind 
		  from bookdetail b, subgentables s
		 where s.tableid=312 
			and b.bookkey = @i_bookkey
			and b.mediatypecode=s.datacode
			and b.mediatypecode = s.datasubcode

		If @i_subgentableind = 1
		begin
			/* PRECEDENCE 
			1st: trimsizewidth
			2nd: Tmmactualtrimwidth
			3rd: esttrimsizewidth
			*/
			If @c_esttrimsizewidth is not null
			 begin 
				select @c_trimwidth_out = @c_esttrimsizewidth
			 end
			If @c_esttrimsizelength is not null
			 begin 
				select @c_trimlength_out = @c_esttrimsizelength
			 end
			If @c_tmmactualtrimwidth is not null
			 begin 
				select @c_trimwidth_out = @c_tmmactualtrimwidth
			 end
			If @c_tmmactualtrimlength is not null
			 begin 
				select @c_trimlength_out = @c_tmmactualtrimlength
			 end
			If @c_trimsizewidth is not null
			 begin 
				select @c_trimwidth_out = @c_trimsizewidth
			 end
			If @c_trimsizelength is not null
			 begin 
				select @c_trimlength_out = @c_trimsizelength
			 end
		end

      IF @c_trimlength_out IS NULL
		   SET @c_trimlength_out = ''

		IF @c_trimwidth_out IS NULL
           SET @c_trimwidth_out = ''

		/*Strip leading and trailing spaces from the fractions v rtrim, ltrim
		Replace µ÷¦ (inches) with blank*/
		
		select @c_trimwidth_out = Rtrim(Ltrim(Replace(@c_trimwidth_out,'"','')))
		select @c_trimlength_out = Rtrim(Ltrim(Replace(@c_trimlength_out,'"','')))


		-- Store original values to put in titlehistory.currenttringvalue
		select @c_orig_trim_width = @c_trimwidth_out
		select @c_orig_trim_length = @c_trimlength_out

	
		-- If we're dealing with a hardover do the calc 
		If @c_mediatypesubcode in (26,42,44,45,46,47,59,62) 
		BEGIN
			select @c_trimwidth_out = dbo.add_fraction(@c_trimwidth_out,'1/8')
			select @c_trimlength_out = dbo.add_fraction(@c_trimlength_out,'1/4')
		END
		-- Otherwise just set the boardtrim to the page trim (paperbacks)
		-- PB With Flaps length = length & width = width + 1/16
		-- Exclude for now until specs are received 9-15-05
		Else If @c_mediatypesubcode <> 48 
		BEGIN 
			select @c_trimwidth_out = @c_trimwidth_out
			select @c_trimlength_out = @c_trimlength_out
		END
		
		update printing
		   set boardtrimsizewidth = @c_trimwidth_out,
             boardtrimsizelength = @c_trimlength_out,
		       lastuserid = 'AUTOCALC',
		       lastmaintdate = getdate()	
		 where bookkey = @i_bookkey
		   and printingkey = @i_printingkey


		/* Insert boardtrimsizewidth 223 change into title history */
		insert into titlehistory
		Select @i_bookkey,@i_printingkey,223,getdate(),0,@c_trimwidth_out,NULL,NULL,'AUTOCALC','Auto-Calculated',@c_orig_trim_width,'Boardtrim Width'
	--	exec titlehistory_insert 128,@i_bookkey,@i_printingkey,0,@c_trimwidth_out
	
		/* Insert boardtrimsizelength 224 change into title history */
		insert into titlehistory
		Select @i_bookkey,@i_printingkey,224,getdate(),0,@c_trimlength_out,NULL,NULL,'AUTOCALC','Auto-Calculated',@c_orig_trim_length,'Boardtrim Length'
	--	exec titlehistory_insert 129,@i_bookkey,@i_printingkey,0,@c_trimlength_out


	end

	FETCH NEXT FROM cursor_boardtrimkeys INTO @i_bookkey,@i_printingkey,@c_esttrimsizewidth,@c_esttrimsizelength,@c_trimsizewidth, 
	     @c_trimsizelength,@c_tmmactualtrimwidth, @c_tmmactualtrimlength,@c_mediatypesubcode

select @i_btrimcalc_cursor_status = @@FETCH_STATUS

end

close cursor_boardtrimkeys
deallocate cursor_boardtrimkeys











