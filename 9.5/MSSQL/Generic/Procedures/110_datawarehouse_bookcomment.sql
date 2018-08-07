PRINT 'STORED PROCEDURE : dbo.datawarehouse_bookcomment'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_bookcomment') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_bookcomment
end

GO

CREATE  proc dbo.datawarehouse_bookcomment
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

DECLARE @ware_commenttypecode int
DECLARE @ware_commenttypesubcode int
DECLARE @ware_releasetoeloq varchar(3)
DECLARE @i_releaseeloq int
DECLARE @ware_linenumber int
DECLARE @ware_substringbegin int
DECLARE @ware_substringend int

DECLARE @i_comstatus int
DECLARE @i_comstatus2 int

DECLARE warehousecomment INSENSITIVE CURSOR
FOR
	SELECT commenttypecode,commenttypesubcode, releasetoeloquenceind
		    FROM bookcomments b
		   	WHERE  b.bookkey = @ware_bookkey
				AND b.printingkey = 1
				order by commenttypecode,commenttypesubcode

FOR READ ONLY
BEGIN tran

	INSERT INTO whtitlecomments
		(bookkey,lastuserid,lastmaintdate)
	VALUES (@ware_bookkey,'WARE_STORED_PROC',@ware_system_date);

	INSERT INTO whtitlecomments2
		(bookkey,lastuserid,lastmaintdate)
	VALUES (@ware_bookkey,'WARE_STORED_PROC',@ware_system_date);

	INSERT INTO whtitlecomments3
			(bookkey,lastuserid,lastmaintdate)
	VALUES (@ware_bookkey,'WARE_STORED_PROC',@ware_system_date);
commit tran

OPEN warehousecomment

FETCH NEXT FROM warehousecomment
INTO @ware_commenttypecode, @ware_commenttypesubcode ,@i_releaseeloq

select @i_comstatus = @@FETCH_STATUS

 while (@i_comstatus<>-1 )
   begin

	IF (@i_comstatus<>-2)
	  begin
		if @i_releaseeloq is null 
		 begin
			select @ware_releasetoeloq = 'N'
		 end
	if @i_releaseeloq  > 0 
	  begin
		select @ware_releasetoeloq = 'Y'
	  end
	else
	  begin
		select @ware_releasetoeloq = 'N'
	  end
	
	DECLARE warehousecomment2 INSENSITIVE CURSOR
	FOR
		SELECT linenumber,substringbegin,substringend 
			FROM whccommenttype 
			WHERE commenttypecode = @ware_commenttypecode 
				AND commenttypesubcode = @ware_commenttypesubcode
				 order by linenumber
	FOR READ ONLY

	OPEN warehousecomment2 

	FETCH NEXT FROM warehousecomment2 
		INTO @ware_linenumber, @ware_substringbegin,@ware_substringend

	select @i_comstatus2 = @@FETCH_STATUS

	while (@i_comstatus2<>-1 )
	   begin

		IF (@i_comstatus2<>-2)
		  begin
		 	if @ware_substringbegin is null
			  begin
				select @ware_substringbegin = 0
			  end
			if @ware_substringend is null
			  begin
				select @ware_substringend = 0
			  end
			if @ware_linenumber is null
			  begin
				select @ware_linenumber = 0
			  end

	/* go to parsing*/
		exec datawarehouse_bookcmnt_parse  @ware_bookkey,@ware_logkey, @ware_warehousekey,@ware_system_date,
		@ware_commenttypecode, @ware_commenttypesubcode ,@ware_substringbegin, @ware_substringend,@ware_linenumber,
		@ware_releasetoeloq
	    end	/*<>2*/

		FETCH NEXT FROM warehousecomment2 
		INTO @ware_linenumber, @ware_substringbegin,@ware_substringend

		select @i_comstatus2 = @@FETCH_STATUS
	end

   end	/*<>2*/
	close warehousecomment2 
	deallocate warehousecomment2 


	FETCH NEXT FROM warehousecomment
	  INTO @ware_commenttypecode, @ware_commenttypesubcode ,@i_releaseeloq

		select @i_comstatus = @@FETCH_STATUS
end


close warehousecomment
deallocate warehousecomment


GO