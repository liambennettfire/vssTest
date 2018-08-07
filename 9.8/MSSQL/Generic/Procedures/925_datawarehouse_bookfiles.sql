PRINT 'STORED PROCEDURE : dbo.datawarehouse_bookfiles'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_bookfiles') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_bookfiles
end

GO

CREATE  proc dbo.datawarehouse_bookfiles
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

DECLARE @i_filetypecode int
DECLARE @i_fileformatcode int
DECLARE @i_filestatuscode int
DECLARE @c_pathname varchar(255)
DECLARE @c_notes varchar(255)
DECLARE @c_logical varchar(255)
DECLARE @c_physical varchar(255)

DECLARE @ware_count int
DECLARE @ware_fileline int

DECLARE @ware_pathname1 varchar(255) 
DECLARE @ware_physicaldesc1 varchar(255) 
DECLARE @ware_notes1 varchar(255) 
DECLARE @ware_logicaldesc1 varchar(255)
DECLARE @ware_pathname2 varchar(255) 
DECLARE @ware_physicaldesc2 varchar(255) 
DECLARE @ware_notes2 varchar(255) 
DECLARE @ware_logicaldesc2 varchar(255)
DECLARE @ware_pathname3 varchar(255)
DECLARE @ware_physicaldesc3 varchar(255) 
DECLARE @ware_notes3 varchar(255) 
DECLARE @ware_logicaldesc3 varchar(255) 
DECLARE @ware_pathname4 varchar(255)
DECLARE @ware_physicaldesc4 varchar(255) 
DECLARE @ware_notes4 varchar(255) 
DECLARE @ware_logicaldesc4 varchar(255) 
DECLARE @ware_pathname5 varchar(255)
DECLARE @ware_physicaldesc5 varchar(255)
DECLARE @ware_notes5 varchar(255) 
DECLARE @ware_logicaldesc5 varchar(255)
DECLARE @ware_pathname6 varchar(255)
DECLARE @ware_physicaldesc6 varchar(255) 
DECLARE @ware_notes6 varchar(255) 
DECLARE @ware_logicaldesc6 varchar(255)
DECLARE @ware_pathname7 varchar(255)
DECLARE @ware_physicaldesc7 varchar(255) 
DECLARE @ware_notes7 varchar(255) 
DECLARE @ware_logicaldesc7 varchar(255)
DECLARE @ware_pathname8 varchar(255)
DECLARE @ware_physicaldesc8 varchar(255) 
DECLARE @ware_notes8 varchar(255) 
DECLARE @ware_logicaldesc8 varchar(255)
DECLARE @ware_pathname9 varchar(255)
DECLARE @ware_physicaldesc9 varchar(255) 
DECLARE @ware_notes9 varchar(255) 
DECLARE @ware_logicaldesc9 varchar(255) 
DECLARE @ware_pathname10 varchar(255)
DECLARE @ware_physicaldesc10 varchar(255) 
DECLARE @ware_notes10 varchar(255)
DECLARE @ware_logicaldesc10 varchar(255) 

/** only 1-10 on table currently
DECLARE @ware_pathname11 varchar(255)
DECLARE @ware_physicaldesc11 varchar(255) 
DECLARE @ware_notes11 varchar(255) 
DECLARE @ware_logicaldesc11 varchar(255)
DECLARE @ware_pathname12 varchar(255) 
DECLARE @ware_physicaldesc12 varchar(255)
DECLARE @ware_notes12 varchar(255) 
DECLARE @ware_logicaldesc12 varchar(255) 
DECLARE @ware_pathname13 varchar(255)
DECLARE @ware_physicaldesc13 varchar(255)
DECLARE @ware_notes13 varchar(255) 
DECLARE @ware_logicaldesc13 varchar(255)
DECLARE @ware_pathname14 varchar(255)
DECLARE @ware_physicaldesc14 varchar(255)
DECLARE @ware_notes14 varchar(255) 
DECLARE @ware_logicaldesc14 varchar(255)
DECLARE @ware_pathname15 varchar(255)
DECLARE @ware_physicaldesc15 varchar(255) 
DECLARE @ware_notes15 varchar(255) 
DECLARE @ware_logicaldesc15 varchar(255)
DECLARE @ware_pathname16 varchar(255) 
DECLARE @ware_physicaldesc16 varchar(255)
DECLARE @ware_notes16 varchar(255) 
DECLARE @ware_logicaldesc16 varchar(255)
DECLARE @ware_pathname17 varchar(255)
DECLARE @ware_physicaldesc17 varchar(255)
DECLARE @ware_notes17 varchar(255) 
DECLARE @ware_logicaldesc17 varchar(255)
DECLARE @ware_pathname18 varchar(255)
DECLARE @ware_physicaldesc18 varchar(255)
DECLARE @ware_notes18 varchar(255) 
DECLARE @ware_logicaldesc18 varchar(255) 
DECLARE @ware_pathname19 varchar(255)
DECLARE @ware_physicaldesc19 varchar(255)
DECLARE @ware_notes19 varchar(255) 
DECLARE @ware_logicaldesc19 varchar(255)
DECLARE @ware_pathname20 varchar(255) 
DECLARE @ware_physicaldesc20 varchar(255)
DECLARE @ware_notes20 varchar(255) 
DECLARE @ware_logicaldesc20 varchar(255)
**/

DECLARE @ware_fileformat1 varchar(40) 
DECLARE @ware_fileformatshort1 varchar(20) 
DECLARE @ware_filestatus1 varchar(40) 
DECLARE @ware_filestatusshort1 varchar(20) 
DECLARE @ware_fileformat2 varchar(40) 
DECLARE @ware_fileformatshort2 varchar(20) 
DECLARE @ware_filestatus2 varchar(40)  
DECLARE @ware_filestatusshort2 varchar(20) 
DECLARE @ware_fileformat3 varchar(40) 
DECLARE @ware_fileformatshort3 varchar(20) 
DECLARE @ware_filestatus3 varchar(40) 
DECLARE @ware_filestatusshort3 varchar(20) 
DECLARE @ware_fileformat4 varchar(40) 
DECLARE @ware_fileformatshort4 varchar(20) 
DECLARE @ware_filestatus4 varchar(40) 
DECLARE @ware_filestatusshort4 varchar(20) 
DECLARE @ware_fileformat5 varchar(40) 
DECLARE @ware_fileformatshort5 varchar(40) 
DECLARE @ware_filestatus5 varchar(40) 
DECLARE @ware_filestatusshort5 varchar(20) 
DECLARE @ware_fileformat6 varchar(40) 
DECLARE @ware_fileformatshort6 varchar(20) 
DECLARE @ware_filestatus6 varchar(40) 
DECLARE @ware_filestatusshort6 varchar(20) 
DECLARE @ware_fileformat7 varchar(40) 
DECLARE @ware_fileformatshort7 varchar(20) 
DECLARE @ware_filestatus7 varchar(40)  
DECLARE @ware_filestatusshort7 varchar(20) 
DECLARE @ware_fileformat8 varchar(40) 
DECLARE @ware_fileformatshort8 varchar(20) 
DECLARE @ware_filestatus8 varchar(40) 
DECLARE @ware_filestatusshort8 varchar(20) 
DECLARE @ware_fileformat9 varchar(40) 
DECLARE @ware_fileformatshort9 varchar(20) 
DECLARE @ware_filestatus9 varchar(40) 
DECLARE @ware_filestatusshort9 varchar(20) 
DECLARE @ware_fileformat10 varchar(40) 
DECLARE @ware_fileformatshort10 varchar(40) 
DECLARE @ware_filestatus10 varchar(40) 
DECLARE @ware_filestatusshort10 varchar(20) 

DECLARE @ware_fileformat_long varchar(40) 
DECLARE @ware_fileformat_short varchar(20) 
DECLARE @ware_filestatus_long varchar(40) 
DECLARE @ware_filestatus_short varchar(20) 

DECLARE @i_filestatus int

DECLARE warehousefiles INSENSITIVE CURSOR
FOR
	select f.filetypecode,fileformatcode,filestatuscode,pathname,notes,
	 '','' /*logicaldesc, physicaldesc*/
   		 from filelocation f /* keys do not natch, filelocationtable fl*/
   			where /*f.filelocationkey = fl.filelocationkey
				AND */
				f.bookkey = @ware_bookkey
				AND f.printingkey = 1
FOR READ ONLY

select @ware_count = 1
OPEN warehousefiles

FETCH NEXT FROM warehousefiles
INTO @i_filetypecode,@i_fileformatcode,@i_filestatuscode,@c_pathname,
@c_notes,@c_logical,@c_physical 

select @i_filestatus = @@FETCH_STATUS

if @i_filestatus <> 0  /** NO book files**/
    begin
	close warehousefiles
	deallocate warehousefiles
	RETURN
   end
 while (@i_filestatus<>-1 )
   begin

	IF (@i_filestatus<>-2)
	  begin

		select @ware_count = 0
		select @ware_count = count (*)
			from whcfiletype
				where filetypecode = @i_filetypecode
		IF  @ware_count > 0 
		  begin
			select @ware_fileline = linenumber
				from whcfiletype
					where filetypecode = @i_filetypecode

			IF @ware_fileline > 0 
			  begin
				if @i_fileformatcode > 0 
			        begin
					exec gentables_longdesc 355,@i_fileformatcode,@ware_fileformat_long OUTPUT
					exec gentables_shortdesc 355,@i_fileformatcode, @ware_fileformat_short OUTPUT
					select @ware_fileformat_short  =substring(@ware_fileformat_short,1,20)
				  end
				else
				   begin
					select @ware_fileformat_long = ''
					select @ware_fileformat_short  = ''
				  end

				if @i_filestatuscode > 0 
				  begin
					exec  gentables_longdesc 357,@i_filestatuscode,@ware_filestatus_long OUTPUT
					exec  gentables_shortdesc 357,@i_filestatuscode,@ware_filestatus_short OUTPUT
					select @ware_filestatus_short = substring(@ware_filestatus_short,1,20)
				  end
				else
				  begin
					select @ware_filestatus_long = ''
					select @ware_filestatus_short = ''
				  end
			
				if @ware_fileline = 1
				  begin
					select @ware_fileformat1 = @ware_fileformat_long
					select @ware_fileformatshort1 = @ware_fileformat_short
					select @ware_filestatus1 = @ware_filestatus_long
					select @ware_filestatusshort1 = @ware_filestatus_short
					select @ware_pathname1 = @c_pathname
					select @ware_notes1 = @c_notes
					select @ware_logicaldesc1 = @c_logical
					select @ware_physicaldesc1  = @c_physical
				  end
				if @ware_fileline = 2 
				  begin 
					select @ware_fileformat2 = @ware_fileformat_long
					select @ware_fileformatshort2 = @ware_fileformat_short
					select @ware_filestatus2 = @ware_filestatus_long
					select @ware_filestatusshort2 = @ware_filestatus_short
					select @ware_pathname2 = @c_pathname
					select @ware_notes2  = @c_notes
					select @ware_logicaldesc2  = @c_logical
					select @ware_physicaldesc2  = @c_physical
				  end
				if @ware_fileline = 3 
				  begin
					select @ware_fileformat3= @ware_fileformat_long
					select @ware_fileformatshort3 = @ware_fileformat_short
					select @ware_filestatus3 = @ware_filestatus_long
					select @ware_filestatusshort3= @ware_filestatus_short
					select @ware_pathname3 = @c_pathname
					select @ware_notes3 = @c_notes
					select @ware_logicaldesc3 = @c_logical
					select @ware_physicaldesc3 = @c_physical
				  end
				if @ware_fileline = 4 
				  begin
					select @ware_fileformat4 = @ware_fileformat_long
					select @ware_fileformatshort4 = @ware_fileformat_short
					select @ware_filestatus4 = @ware_filestatus_long
					select @ware_filestatusshort4 = @ware_filestatus_short
					select @ware_pathname4 = @c_pathname
					select @ware_notes4 = @c_notes
					select @ware_logicaldesc4 = @c_logical
					select @ware_physicaldesc4 = @c_physical
				  end
				if @ware_fileline = 5 
				  begin
					select @ware_fileformat5 = @ware_fileformat_long
					select @ware_fileformatshort5 = @ware_fileformat_short
					select @ware_filestatus5 = @ware_filestatus_long
					select @ware_filestatusshort5 = @ware_filestatus_short
					select @ware_pathname5 = @c_pathname
					select @ware_notes5 = @c_notes
					select @ware_logicaldesc5 = @c_logical
					select @ware_physicaldesc5 = @c_physical
				  end
				if @ware_fileline = 6
				  begin
					select @ware_fileformat6 = @ware_fileformat_long
					select @ware_fileformatshort6 = @ware_fileformat_short
					select @ware_filestatus6 = @ware_filestatus_long
					select @ware_filestatusshort6 = @ware_filestatus_short
					select @ware_pathname6 = @c_pathname
					select @ware_notes6 = @c_notes
					select @ware_logicaldesc6 = @c_logical
					select @ware_physicaldesc6 = @c_physical
				  end
				if @ware_fileline = 7 
				  begin
					select @ware_fileformat7 = @ware_fileformat_long
					select @ware_fileformatshort7 = @ware_fileformat_short
					select @ware_filestatus7 = @ware_filestatus_long
					select @ware_filestatusshort7 = @ware_filestatus_short
					select @ware_pathname7 = @c_pathname
					select @ware_notes7 = @c_notes
					select @ware_logicaldesc7 = @c_logical
					select @ware_physicaldesc7 = @c_physical
				  end
				if @ware_fileline = 8 
				  begin
					select @ware_fileformat8 = @ware_fileformat_long
					select @ware_fileformatshort8 = @ware_fileformat_short
					select @ware_filestatus8 = @ware_filestatus_long
					select @ware_filestatusshort8 = @ware_filestatus_short
					select @ware_pathname8 = @c_pathname
					select @ware_notes8 = @c_notes
					select @ware_logicaldesc8 = @c_logical
					select @ware_physicaldesc8 = @c_physical
				  end
				if @ware_fileline = 9 
				  begin
					select @ware_fileformat9 = @ware_fileformat_long
					select @ware_fileformatshort9 = @ware_fileformat_short
					select @ware_filestatus9 = @ware_filestatus_long
					select @ware_filestatusshort9 = @ware_filestatus_short
					select @ware_pathname9 = @c_pathname
					select @ware_notes9 = @c_notes
					select @ware_logicaldesc9 = @c_logical
					select @ware_physicaldesc9 = @c_physical
				  end
				if @ware_fileline = 10
				  begin
					select @ware_fileformat10 = @ware_fileformat_long
					select @ware_fileformatshort10 = @ware_fileformat_short
					select @ware_filestatus10 = @ware_filestatus_long
					select @ware_filestatusshort10 = @ware_filestatus_short
					select @ware_pathname10 = @c_pathname
					select @ware_notes10 = @c_notes
					select @ware_logicaldesc10 = @c_logical
					select @ware_physicaldesc10 = @c_physical
				  end
			end
		end	

	end /*<>2*/
	FETCH NEXT FROM warehousefiles
	INTO @i_filetypecode,@i_fileformatcode,@i_filestatuscode,@c_pathname,
	@c_notes,@c_logical,@c_physical 

	select @i_filestatus = @@FETCH_STATUS

end

BEGIN tran
INSERT INTO  whtitlefiles
	(bookkey,pathname1 ,physicaldesc1 ,filenotes1 ,logicaldesc1,
	pathname2 ,physicaldesc2 ,filenotes2 ,logicaldesc2 ,pathname3 ,physicaldesc3 ,
	filenotes3 ,logicaldesc3 ,pathname4 ,physicaldesc4 ,filenotes4 ,logicaldesc4 ,
	pathname5 ,physicaldesc5 ,filenotes5 ,logicaldesc5 ,
	fileformat1 ,fileformatshort1 ,filestatus1 ,filestatusshort1 ,fileformat2 ,
	fileformatshort2 ,filestatus2 ,filestatusshort2 ,fileformat3 ,fileformatshort3,
	filestatus3 ,filestatusshort3 ,fileformat4 ,fileformatshort4 ,filestatus4,
	filestatusshort4 ,fileformat5 ,fileformatshort5 ,filestatus5 ,
	filestatusshort5,lastuserid,lastmaintdate,
	pathname6 ,physicaldesc6 ,filenotes6 ,logicaldesc6 ,
        fileformat6 ,fileformatshort6 ,filestatus6 ,filestatusshort6,
	pathname7 ,physicaldesc7 ,filenotes7 ,logicaldesc7 ,
        fileformat7 ,fileformatshort7 ,filestatus7 ,filestatusshort7,
	pathname8 ,physicaldesc8 ,filenotes8 ,logicaldesc8 ,
        fileformat8 ,fileformatshort8 ,filestatus8 ,filestatusshort8,
	pathname9 ,physicaldesc9 ,filenotes9 ,logicaldesc9 ,
        fileformat9 ,fileformatshort9 ,filestatus9 ,filestatusshort9,
	pathname10 ,physicaldesc10 ,filenotes10 ,logicaldesc10 ,
        fileformat10 ,fileformatshort10 ,filestatus10 ,filestatusshort10)
VALUES (@ware_bookkey,@ware_pathname1 ,@ware_physicaldesc1 ,@ware_notes1 ,@ware_logicaldesc1 ,
@ware_pathname2 ,@ware_physicaldesc2 ,@ware_notes2 ,@ware_logicaldesc2 ,
@ware_pathname3 ,@ware_physicaldesc3 ,@ware_notes3 ,@ware_logicaldesc3 ,
@ware_pathname4 ,@ware_physicaldesc4 ,@ware_notes4 ,@ware_logicaldesc4 ,
@ware_pathname5 ,@ware_physicaldesc5 ,@ware_notes5 ,@ware_logicaldesc5 ,
@ware_fileformat1 ,@ware_fileformatshort1 ,@ware_filestatus1 ,
@ware_filestatusshort1 ,@ware_fileformat2 ,@ware_fileformatshort2 ,
@ware_filestatus2 ,@ware_filestatusshort2 ,@ware_fileformat3 ,
@ware_fileformatshort3 ,@ware_filestatus3 ,@ware_filestatusshort3 ,
@ware_fileformat4 ,@ware_fileformatshort4 ,@ware_filestatus4 ,
@ware_filestatusshort4 ,@ware_fileformat5 ,@ware_fileformatshort5 ,
@ware_filestatus5 ,@ware_filestatusshort5,'STORED_PROC',@ware_system_date,
@ware_pathname6 ,@ware_physicaldesc6 ,@ware_notes6 ,@ware_logicaldesc6 ,
@ware_fileformat6 ,@ware_fileformatshort6 ,@ware_filestatus6 ,@ware_filestatusshort6,
@ware_pathname7 ,@ware_physicaldesc7 ,@ware_notes7 ,@ware_logicaldesc7 ,
@ware_fileformat7 ,@ware_fileformatshort7 ,@ware_filestatus7 ,@ware_filestatusshort7,
@ware_pathname8 ,@ware_physicaldesc8 ,@ware_notes8 ,@ware_logicaldesc8 ,
@ware_fileformat8 ,@ware_fileformatshort8 ,@ware_filestatus8 ,@ware_filestatusshort8,
@ware_pathname9 ,@ware_physicaldesc9 ,@ware_notes9 ,@ware_logicaldesc9 ,
@ware_fileformat9 ,@ware_fileformatshort9 ,@ware_filestatus9 ,@ware_filestatusshort9,
@ware_pathname10 ,@ware_physicaldesc10 ,@ware_notes10 ,@ware_logicaldesc10 ,
@ware_fileformat10 ,@ware_fileformatshort10 ,@ware_filestatus10 ,@ware_filestatusshort10) 

commit tran
/**if  > 0 then
	INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
		'Unable to insert whtitlefiles table - for book files',
		('Warning/data error bookkey '||to_char(@ware_bookkey)),
		'Stored procedure datawarehouse_bookfiles','STORED_PROC', @ware_system_date)
  end if
**/

close warehousefiles
deallocate warehousefiles


GO