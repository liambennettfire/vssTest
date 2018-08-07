PRINT 'STORED PROCEDURE : dbo.datawarehouse_orgentry'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_orgentry') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_orgentry
end

GO

CREATE  proc dbo.datawarehouse_orgentry
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

DECLARE @ware_count int
DECLARE @ware_grouplevel1  varchar(40) 
DECLARE @ware_groupentry1 varchar(40) 
DECLARE @ware_grouplevel2  varchar(40) 
DECLARE @ware_groupentry2 varchar(40) 
DECLARE @ware_grouplevel3  varchar(40) 
DECLARE @ware_groupentry3 varchar(40) 
DECLARE @ware_grouplevel4  varchar(40) 
DECLARE @ware_groupentry4 varchar(40) 
DECLARE @ware_grouplevel5  varchar(40) 
DECLARE @ware_groupentry5 varchar(40) 
DECLARE @ware_grouplevel6  varchar(40) 
DECLARE @ware_groupentry6 varchar(40) 
DECLARE @ware_grouplevel7  varchar(40) 
DECLARE @ware_groupentry7 varchar(40) 
DECLARE @ware_grouplevel8  varchar(40) 
DECLARE @ware_groupentry8 varchar(40) 
DECLARE @ware_grouplevel9  varchar(40) 
DECLARE @ware_groupentry9 varchar(40) 
DECLARE @ware_orgentrydesc  varchar(40) 
DECLARE @ware_orgleveldesc  varchar(40) 
DECLARE @i_orgstatus int
DECLARE @i_orgentrykey int
DECLARE @i_orglevelkey int

DECLARE warehouseorgentry INSENSITIVE CURSOR
FOR
	SELECT  orgentrykey,  orglevelkey
		    FROM bookorgentry
		   	WHERE bookkey = @ware_bookkey
				ORDER BY  orglevelkey

FOR READ ONLY


select @ware_count = 1
OPEN warehouseorgentry 

FETCH NEXT FROM warehouseorgentry 
INTO @i_orgentrykey, @i_orglevelkey

select @i_orgstatus = @@FETCH_STATUS

if @i_orgstatus <> 0  /** NO Orglevels**/
    begin
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
     	   		 errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
			'No Bookorgentry rows for this title',
			('Warning/data error bookkey ' + convert(varchar,@ware_bookkey)),
			'Stored procedure datawarehouse_orgentry','WARE_STORED_PROC', @ware_system_date)

   end
 while (@i_orgstatus<>-1 )
   begin

	IF (@i_orgstatus<>-2)
	  begin

		if @i_orgentrykey > 0 
		  begin
			select @ware_orgentrydesc = orgentrydesc
				from orgentry
					where orgentrykey= @i_orgentrykey
		  end
		else
		  begin
			select @ware_orgentrydesc = ''
		  end

		if @i_orglevelkey > 0 
		  begin
			select @ware_orgleveldesc = orgleveldesc
				from orglevel
					where orglevelkey= @i_orglevelkey	
		  end
		else
 		  begin
			select @ware_orgleveldesc = ''
		end

	if @i_orglevelkey = 1 	
	  begin
		select @ware_grouplevel1 = @ware_orgleveldesc
		select @ware_groupentry1 = @ware_orgentrydesc
	  end
	if @i_orglevelkey = 2
	  begin
		select @ware_grouplevel2 = @ware_orgleveldesc
		select @ware_groupentry2 = @ware_orgentrydesc
	  end
	if @i_orglevelkey = 3
	  begin
		select @ware_grouplevel3 = @ware_orgleveldesc
		select @ware_groupentry3 = @ware_orgentrydesc
	  end
	if @i_orglevelkey = 4
	  begin
		select @ware_grouplevel4 = @ware_orgleveldesc
		select @ware_groupentry4 = @ware_orgentrydesc
	  end
	if @i_orglevelkey = 5 
	  begin
		select @ware_grouplevel5 = @ware_orgleveldesc
		select @ware_groupentry5 = @ware_orgentrydesc
	  end
	if @i_orglevelkey = 6 
	  begin
		select @ware_grouplevel6 = @ware_orgleveldesc
		select @ware_groupentry6 = @ware_orgentrydesc
 	  end
	if @i_orglevelkey = 7 	
	  begin
		select @ware_grouplevel7 = @ware_orgleveldesc
		select @ware_groupentry7 = @ware_orgentrydesc
	  end
	if @i_orglevelkey = 8 
	  begin
		select @ware_grouplevel8 = @ware_orgleveldesc
		select @ware_groupentry8 = @ware_orgentrydesc
	  end
	if @i_orglevelkey = 9 
	  begin
		select @ware_grouplevel9 = @ware_orgleveldesc
		select @ware_groupentry9 = @ware_orgentrydesc
	  end

  end
	FETCH NEXT FROM warehouseorgentry 
	INTO @i_orgentrykey, @i_orglevelkey

	select @i_orgstatus = @@FETCH_STATUS
end
BEGIN tran
UPDATE whtitleclass
	set grouplevel1 =  @ware_grouplevel1,
      groupentry1 = @ware_groupentry1,
  	grouplevel2 =  @ware_grouplevel2,
      groupentry2 = @ware_groupentry2,
  	grouplevel3 =  @ware_grouplevel3,
      groupentry3 = @ware_groupentry3,
  	grouplevel4 =  @ware_grouplevel4,
      groupentry4 = @ware_groupentry4,
  	grouplevel5 =  @ware_grouplevel5,
      groupentry5 = @ware_groupentry5,
  	grouplevel6 =  @ware_grouplevel6,
      groupentry6 = @ware_groupentry6,
	grouplevel7 =  @ware_grouplevel7,
      groupentry7 = @ware_groupentry7,
	grouplevel8 =  @ware_grouplevel8,
	groupentry8 = @ware_groupentry8,
	grouplevel9 =  @ware_grouplevel9,
	groupentry9 = @ware_groupentry9
		where bookkey = @ware_bookkey

commit tran
/** if SQL%ROWCOUNT > 0 then
	commit
else
	INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
		'Unable to update whtitleclass table- for group entry',
		'Warning/data error','Stored procedure datawarehouse_orgentry','WARE_STORED_PROC', @ware_system_date)
	commit
end if
**/

close warehouseorgentry 
deallocate warehouseorgentry 


GO