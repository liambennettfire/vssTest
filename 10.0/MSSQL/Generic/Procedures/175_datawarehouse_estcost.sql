PRINT 'STORED PROCEDURE : dbo.datawarehouse_estcost'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_estcost') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_estcost
end

GO

create proc dbo.datawarehouse_estcost
@ware_estkey  int, @ware_versionkey int,@ware_logkey int,@ware_warehousekey int,
 @ware_system_date datetime
AS


DECLARE @ware_count int

/*  I do not see how these variables are used but left in code */
DECLARE @i_totalcostall float
DECLARE @i_totalplantcost float
DECLARE @i_totaleditioncost float

DECLARE @totaltotalcost float
DECLARE @totalunitcost float
DECLARE @ware_holdcompdesc  varchar(300) 
DECLARE @i_compkey int 
DECLARE @c_compdesc varchar(32)
DECLARE @i_chgcodecode int
DECLARE @c_externalcode varchar(6)
DECLARE @c_externaldesc varchar(30)
DECLARE @c_costtype varchar(1)
DECLARE @i_unitcost float
DECLARE @i_totalcost float
DECLARE @i_estcoststatus int

select @ware_holdcompdesc = ''
select @ware_count = 1
select @i_totalcostall = 0 
select @i_totaleditioncost = 0
select @i_totalplantcost = 0

DECLARE warehousecost INSENSITIVE CURSOR
   FOR
	  SELECT E.COMPKEY, C.COMPDESC,E.CHGCODECODE,CD.EXTERNALCODE,
      	CD.EXTERNALDESC,CD.COSTTYPE,E.UNITCOST,E.TOTALCOST
 		    FROM ESTCOST E, CDLIST CD, COMPTYPE C
			     WHERE  E.CHGCODECODE = CD.INTERNALCODE
				   AND E.COMPKEY = C.COMPKEY
				   AND E.estkey = @ware_estkey
				   AND E.versionkey = @ware_versionkey
FOR READ ONLY

   OPEN  warehousecost

	FETCH NEXT FROM warehousecost
		INTO @i_compkey,@c_compdesc,@i_chgcodecode,@c_externalcode,
			@c_externaldesc,@c_costtype,@i_unitcost,@i_totalcost

	select @i_estcoststatus = @@FETCH_STATUS

	if @i_estcoststatus <> 0 /** NO PO **/
    	  begin
BEGIN tran
		INSERT INTO whestcost (estkey,estversion,compkey,chargecodekey,
			  lastuserid,lastmaintdate)
		 VALUES (@ware_estkey,@ware_versionkey,0,0,'WARE_STORED_PROC',@ware_system_date)

		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
          		 errorseverity, errorfunction,lastuserid, lastmaintdate)
  		 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
		   'Unable to insert whestcost table - for estcost',
   		('Warning/data error estkey '+ convert(varchar,@ware_estkey)),
   			'Stored procedure datawarehouse_estcost',' WARE_STORED_PROC',@ware_system_date)
commit tran
		close warehousecost
		deallocate warehousecost
		RETURN
	
   	end

	 while (@i_estcoststatus <>-1 )
	   begin

		IF (@i_estcoststatus <>-2)
		  begin
			if @c_compdesc  is null
			  begin
				select @c_compdesc = ''
			  end
			if @i_totalcost is null
			  begin
				select @i_totalcost  = 0
			  end
 		 	if @c_compdesc <> @ware_holdcompdesc
			  begin
				select @ware_holdcompdesc = @c_compdesc
			   end
 			select @i_totalcostall = @i_totalcostall + @i_totalcost
 			if @c_costtype = 'P' 
			  begin
				 select  @i_totalplantcost = @i_totalplantcost + @i_totalcost
			  end
			 else
			  begin
				select @i_totaleditioncost = @i_totaleditioncost + @i_totalcost
	 		 end
BEGIN tran
		 INSERT INTO whestcost (estkey,estversion,compkey,chargecodekey,
			  chargecode,comptype,costtype,unitcost,totalcost,lastuserid,lastmaintdate)
		 VALUES (@ware_estkey,@ware_versionkey,@i_compkey,@i_chgcodecode,
			  (@c_externalcode + ' '+ @c_externaldesc),@c_compdesc,@c_costtype,@i_unitcost,
			@i_totalcost,'WARE_STORED_PROC',@ware_system_date)
commit tran
/* if SQL%ROWCOUNT > 0 then
  commit
 else
  INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
           errorseverity, errorfunction,lastuserid, lastmaintdate)
   VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
   'Unable to insert whestcost table - for estcost',
   ('Warning/data error estkey '+to_char(@ware_estkey)),
   'Stored procedure datawarehouse_estcost','WARE_STORED_PROC',@ware_system_date)
  commit
 end if
*/
		select @ware_count = @ware_count + 1
	end
	FETCH NEXT FROM warehousecost
		INTO @i_compkey,@c_compdesc,@i_chgcodecode,@c_externalcode,
			@c_externaldesc,@c_costtype,@i_unitcost,@i_totalcost

	select @i_estcoststatus = @@FETCH_STATUS
  end

if @ware_count = 1 
 begin
BEGIN tran
	INSERT INTO whestcost (estkey,estversion,compkey,chargecodekey,
		  lastuserid,lastmaintdate)
	 VALUES (@ware_estkey,@ware_versionkey,0,0,'WARE_STORED_PROC',@ware_system_date)
commit tran
end
close warehousecost
deallocate warehousecost


GO