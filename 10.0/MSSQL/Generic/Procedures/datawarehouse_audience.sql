PRINT 'STORED PROCEDURE : dbo.datawarehouse_audience'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_audience') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_audience
end

GO

CREATE  proc dbo.datawarehouse_audience 
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

DECLARE @ware_count int

DECLARE @ware_audience1_long varchar(40)
DECLARE @ware_audience2_long varchar(40) 
DECLARE @ware_audience3_long varchar(40) 
DECLARE @ware_audience4_long varchar(40) 
DECLARE @ware_audience5_long varchar(40) 
DECLARE @ware_audience1_short varchar(20)
DECLARE @ware_audience2_short varchar(20) 
DECLARE @ware_audience3_short varchar(20) 
DECLARE @ware_audience4_short varchar(20) 
DECLARE @ware_audience5_short varchar(20) 
DECLARE @i_audiencecode int 
DECLARE @i_audstatus int 

DECLARE warehouseaudience INSENSITIVE CURSOR
FOR
	SELECT audiencecode
		    FROM bookaudience
		   	WHERE  bookkey = @ware_bookkey
				ORDER BY  sortorder

FOR READ ONLY


select @ware_count = 1
OPEN warehouseaudience

FETCH NEXT FROM warehouseaudience
INTO @i_audiencecode

select @i_audstatus = @@FETCH_STATUS

 while (@i_audstatus<>-1 )
   begin

	IF (@i_audstatus<>-2)
	  begin
		if @ware_count = 1 
		  begin
			if @i_audiencecode > 0 
			  begin
			      exec gentables_longdesc 460,@i_audiencecode,@ware_audience1_long OUTPUT
           			exec gentables_shortdesc 460,@i_audiencecode,@ware_audience1_short OUTPUT
			      select @ware_audience1_short = substring(@ware_audience1_short,1,20)
			  end
			else
			  begin
			      select @ware_audience1_long = ''
			      select @ware_audience1_short = ''
		 	 end
		  end
	 	if @ware_count = 2 
		  begin
			if @i_audiencecode > 0 
			  begin
			      exec gentables_longdesc 460,@i_audiencecode,@ware_audience2_long OUTPUT
           			exec gentables_shortdesc 460,@i_audiencecode,@ware_audience2_short OUTPUT
			      select @ware_audience2_short = substring(@ware_audience2_short,1,20)
			  end
			else
			  begin
			      select @ware_audience2_long = ''
			      select @ware_audience2_short = ''
		 	 end
		  end
		if @ware_count = 3 
		  begin
			if @i_audiencecode > 0 
			  begin
			      exec gentables_longdesc 460,@i_audiencecode,@ware_audience3_long OUTPUT
           			exec gentables_shortdesc 460,@i_audiencecode,@ware_audience3_short OUTPUT
			      select @ware_audience3_short = substring(@ware_audience3_short,1,20)
			  end
			else
			  begin
			      select @ware_audience3_long = ''
			      select @ware_audience3_short = ''
		 	 end
		  end
		if @ware_count = 4 
		  begin
			if @i_audiencecode > 0 
			  begin
			      exec gentables_longdesc 460,@i_audiencecode,@ware_audience4_long OUTPUT
           			exec gentables_shortdesc 460,@i_audiencecode,@ware_audience4_short OUTPUT
			      select @ware_audience4_short = substring(@ware_audience4_short,1,20)
			  end
			else
			  begin
			      select @ware_audience4_long = ''
			      select @ware_audience4_short = ''
		 	 end
		  end
		if @ware_count = 5 
		  begin
			if @i_audiencecode > 0 
			  begin
			      exec gentables_longdesc 460,@i_audiencecode,@ware_audience5_long OUTPUT
           			exec gentables_shortdesc 460,@i_audiencecode,@ware_audience5_short OUTPUT
			      select @ware_audience5_short = substring(@ware_audience5_short,1,20)
			  end
			else
			  begin
			      select @ware_audience5_long = ''
			      select @ware_audience5_short = ''
		 	 end
		  end

      end

	select @ware_count = @ware_count + 1
	FETCH NEXT FROM warehouseaudience
	INTO @i_audiencecode

	select @i_audstatus = @@FETCH_STATUS
end

	BEGIN tran 
	UPDATE whtitleclass
	set audience1 = @ware_audience1_long,
	    audience2 = @ware_audience2_long,
	    audience3 = @ware_audience3_long,
	    audience4 = @ware_audience4_long,
	    audience5 = @ware_audience5_long,
	    audienceshort1 = @ware_audience1_short,
	    audienceshort2 = @ware_audience2_short,
	    audienceshort3 = @ware_audience3_short,
	    audienceshort4 = @ware_audience4_short,
	    audienceshort5 = @ware_audience5_short
 where bookkey = @ware_bookkey
commit tran

/**if SQL%ROWCOUNT > 0 then
	commit
else
	INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
		'Unable to update whtitleclass table - for bookaudience',
		'Warning/data error',
		'Stored procedure datawarehouse_audience','STORED_PROC', @ware_system_date)
	commit
end if
**/
close warehouseaudience
deallocate warehouseaudience


GO